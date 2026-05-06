"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { createAdminClient } from "@/lib/supabase/admin";
import { updateProfileSchema, uuid } from "@/lib/validations";
import { z } from "zod";

// ─── Schéma de création stagiaire ──────────────────────────────────────
const createStudentSchema = z.object({
  // Personnel
  email: z.string().trim().email("Email invalide").max(254),
  full_name: z.string().trim().min(2, "Nom complet requis").max(160),
  phone: z.string().trim().max(30).optional().nullable(),
  date_naissance: z
    .string()
    .trim()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Format YYYY-MM-DD")
    .optional()
    .nullable(),
  adresse: z.string().trim().max(300).optional().nullable(),
  code_postal: z.string().trim().max(10).optional().nullable(),
  ville: z.string().trim().max(100).optional().nullable(),

  // Pédagogique
  formation_slug: z.string().trim().min(1, "Formation requise"),
  session_label: z.string().trim().max(120).optional().nullable(),
  entry_date: z
    .string()
    .trim()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Format YYYY-MM-DD")
    .optional()
    .nullable(),
  referent_id: z.string().uuid().optional().nullable(),
  trainer_id: z.string().uuid().optional().nullable(),

  // Administratif
  funder_id: z.string().uuid().optional().nullable(),
  funding_kind: z
    .enum(["opco", "cpf", "employeur", "pole_emploi", "auto", "autre"])
    .optional(),
  enrollment_status: z
    .enum([
      "prospect",
      "devis",
      "accord_financeur",
      "a_payer",
      "en_cours",
      "termine",
    ])
    .default("en_cours"),
  total_amount_cents: z.number().int().min(0).max(99_999_999).optional(),

  // Accès
  access_mode: z.enum(["invite", "password"]).default("invite"),
  initial_password: z
    .string()
    .min(8, "8 caractères minimum")
    .max(72)
    .optional()
    .nullable(),
});

/**
 * Crée un compte stagiaire complet :
 *  1. Création du user auth (Supabase Admin API)
 *  2. Profil stagiaire avec coordonnées
 *  3. Inscription (enrollments) sur la formation choisie
 *  4. Bypass automatique de l'onboarding et du positionnement
 *  5. Email d'invitation OU mot de passe initial selon access_mode
 *
 * Sécurité : action gardée par requireAdmin (admin / super_admin uniquement).
 */
export async function createStudent(raw: unknown) {
  // Log de phase pour diagnostiquer en prod (visible dans Vercel logs).
  // Les server actions Next.js sanitisent les erreurs côté client : sans
  // log, on ne sait pas QUELLE étape a planté.
  const log = (step: string, extra?: any) =>
    console.log(`[createStudent] ${step}`, extra ?? "");

  log("0/ start");
  const { admin } = await requireAdmin();
  log("1/ requireAdmin OK", { adminId: admin.id });
  let data: z.infer<typeof createStudentSchema>;
  try {
    data = validate(createStudentSchema, raw);
  } catch (e: any) {
    console.error("[createStudent] validation failed", e?.message ?? e);
    throw e;
  }
  log("2/ validate OK", {
    email: data.email,
    formation: data.formation_slug,
    access_mode: data.access_mode,
  });

  // Validation conditionnelle : si mode 'password', le mot de passe est requis
  if (data.access_mode === "password" && !data.initial_password) {
    throw new Error("Mot de passe initial requis en mode 'password'");
  }

  // Vérification rapide des env vars critiques — message clair à l'admin
  // au lieu d'une 500 muette en cas d'oubli côté Vercel.
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    console.error("[createStudent] missing SUPABASE_SERVICE_ROLE_KEY");
    throw new Error(
      "Configuration serveur incomplète : SUPABASE_SERVICE_ROLE_KEY manquant côté Vercel."
    );
  }
  if (data.access_mode === "invite" && !process.env.NEXT_PUBLIC_APP_URL) {
    console.warn(
      "[createStudent] NEXT_PUBLIC_APP_URL non défini, redirectTo invitation sera relatif"
    );
  }

  const sb = createAdminClient();

  // Vérifier que la formation existe et récupérer son id
  const { data: formation, error: fErr } = await sb
    .from("formations")
    .select("id, slug, title")
    .eq("slug", data.formation_slug)
    .maybeSingle();
  if (fErr) throw new Error(fErr.message);
  if (!formation) throw new Error(`Formation "${data.formation_slug}" introuvable`);

  // 1) Création du user auth
  let userId: string;
  if (data.access_mode === "invite") {
    log("3/ invite mode");
    const redirectTo =
      (process.env.NEXT_PUBLIC_APP_URL ?? "") + "/login";
    const { data: invited, error: invErr } = await sb.auth.admin.inviteUserByEmail(
      data.email,
      {
        data: { full_name: data.full_name, created_by: admin.id },
        redirectTo,
      }
    );
    if (invErr) {
      console.error("[createStudent] inviteUserByEmail failed", invErr);
      throw new Error(`Invitation impossible : ${invErr.message}`);
    }
    userId = invited.user.id;
  } else {
    log("3/ password mode");
    const { data: created, error: cErr } = await sb.auth.admin.createUser({
      email: data.email,
      password: data.initial_password!,
      email_confirm: true,
      user_metadata: { full_name: data.full_name, created_by: admin.id },
    });
    if (cErr) {
      console.error("[createStudent] createUser failed", cErr);
      throw new Error(`Création impossible : ${cErr.message}`);
    }
    userId = created.user.id;
  }
  log("4/ auth user created", { userId });

  // 2) Profil stagiaire complet (le trigger handle_new_user a peut-être déjà
  //    créé une ligne minimale ; on fait un upsert pour compléter)
  const profilePayload: Record<string, any> = {
    id: userId,
    email: data.email,
    full_name: data.full_name,
    role: "student",
    phone: data.phone || null,
    date_naissance: data.date_naissance || null,
    adresse: data.adresse || null,
    code_postal: data.code_postal || null,
    ville: data.ville || null,
    referent_id: data.referent_id || null,
    trainer_id: data.trainer_id || null,
    entry_date: data.entry_date || null,
    // L'admin gère l'onboarding et le placement → bypass pour le stagiaire
    onboarding_completed_at: new Date().toISOString(),
    placement_completed_at: new Date().toISOString(),
  };

  const { error: pErr } = await sb
    .from("profiles")
    .upsert(profilePayload, { onConflict: "id" });
  if (pErr) {
    console.error("[createStudent] profile upsert failed", pErr);
    await sb.auth.admin.deleteUser(userId).catch(() => {});
    throw new Error(`Création du profil impossible : ${pErr.message}`);
  }
  log("5/ profile upserted");

  // 3) Création de l'enrollment
  const enrollmentPayload: Record<string, any> = {
    user_id: userId,
    formation_slug: formation.slug,
    formation_id: formation.id,
    funder_id: data.funder_id || null,
    funding_kind: data.funding_kind || "auto",
    session_label:
      data.session_label || `${formation.slug}-${new Date().getFullYear()}`,
    start_date: data.entry_date || null,
    status: data.enrollment_status,
    total_amount_cents: data.total_amount_cents ?? 0,
  };

  const { error: eErr } = await sb.from("enrollments").insert(enrollmentPayload);
  if (eErr) {
    console.error("[createStudent] enrollment insert failed", eErr);
    // Non-bloquant : on garde le compte mais on signale
  } else {
    log("6/ enrollment inserted");
  }

  // 4) Audit log — wrap dans try/catch pour ne pas planter si la table
  // audit_log n'est pas dispo (cas exceptionnel mais déjà vu).
  try {
    await auditLog("create_student", "profile", userId, {
      email: data.email,
      formation_slug: data.formation_slug,
      access_mode: data.access_mode,
    });
    log("7/ audit log written");
  } catch (e: any) {
    console.error("[createStudent] audit log failed (non-fatal)", e?.message ?? e);
  }

  revalidatePath("/admin/users");
  revalidatePath("/admin/enrollments");
  log("8/ done", { userId });

  return { ok: true, userId, email: data.email, accessMode: data.access_mode };
}

export async function updateUserProfile(userId: string, raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  validate(uuid, userId);
  const patch = validate(updateProfileSchema, raw);

  // Protection anti auto-rétrogradation : un admin ne peut pas se retirer son
  // propre rôle admin (éviter de se verrouiller hors de l'interface)
  if (userId === admin.id && patch.role && patch.role !== "admin") {
    throw new Error("Vous ne pouvez pas retirer votre propre rôle admin");
  }
  if (userId === admin.id && patch.disabled === true) {
    throw new Error("Vous ne pouvez pas désactiver votre propre compte");
  }

  const { error } = await supabase.from("profiles").update(patch).eq("id", userId);
  if (error) throw new Error(error.message);
  await auditLog("update_profile", "profile", userId, { fields: Object.keys(patch) });
  revalidatePath("/admin/users");
  revalidatePath(`/admin/users/${userId}`);
  return { ok: true };
}

export async function toggleUserDisabled(userId: string, disabled: boolean) {
  return updateUserProfile(userId, { disabled });
}

export async function deleteUser(userId: string) {
  const { admin } = await requireAdmin();
  validate(uuid, userId);
  if (userId === admin.id) {
    throw new Error("Vous ne pouvez pas supprimer votre propre compte");
  }

  // ⚠️ Important : il faut supprimer le user de `auth.users` (pas seulement
  // `public.profiles`) sinon Supabase Auth garde l'email "réservé" et toute
  // ré-invitation échoue avec "User with this email already registered".
  //
  // Ordre privilégié :
  //   1. auth.admin.deleteUser() → cascade ON DELETE vers profiles +
  //      enrollments + quiz_attempts + ... grâce aux FK définies en schema.
  //   2. Fallback : si l'auth user a déjà disparu (orphan profile d'un
  //      ancien delete partiel), on nettoie public.profiles directement.
  const sb = createAdminClient();
  const { error: authErr } = await sb.auth.admin.deleteUser(userId);

  if (authErr) {
    // Cas typique : "User not found" → orphan dans profiles seulement.
    const isNotFound =
      /not[\s_-]?found|does not exist/i.test(authErr.message ?? "") ||
      (authErr as any).status === 404;

    if (isNotFound) {
      const { error: pErr } = await sb
        .from("profiles")
        .delete()
        .eq("id", userId);
      if (pErr) throw new Error(pErr.message);
    } else {
      throw new Error(authErr.message);
    }
  }

  await auditLog("delete_user", "profile", userId);
  revalidatePath("/admin/users");
  return { ok: true };
}

export async function resetUserResults(userId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, userId);
  const { error: e1 } = await supabase.from("quiz_attempts").delete().eq("user_id", userId);
  const { error: e2 } = await supabase.from("lesson_progress").delete().eq("user_id", userId);
  if (e1 || e2) throw new Error((e1 || e2)!.message);
  await auditLog("reset_user_results", "profile", userId);
  revalidatePath(`/admin/users/${userId}`);
  return { ok: true };
}

export async function deleteAttempt(attemptId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, attemptId);
  const { error } = await supabase.from("quiz_attempts").delete().eq("id", attemptId);
  if (error) throw new Error(error.message);
  // audit fait automatiquement via trigger SQL
  revalidatePath("/admin/analytics");
  return { ok: true };
}
