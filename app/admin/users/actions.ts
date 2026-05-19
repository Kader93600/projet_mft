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
type CreateStudentResult =
  | {
      ok: true;
      userId: string;
      email: string;
      accessMode: "invite" | "password";
    }
  | { ok: false; error: string; step?: string };

export async function createStudent(raw: unknown): Promise<CreateStudentResult> {
  // Stratégie : on RETOURNE les erreurs (ok:false) au lieu de throw, car
  // Next.js sanitise les erreurs lancées par les server actions en prod
  // ("An error occurred in the Server Components render…"). Avec un retour
  // structuré, le client voit le vrai message.
  const fail = (step: string, error: string): CreateStudentResult => {
    console.error(`[createStudent] ${step}: ${error}`);
    return { ok: false, error, step };
  };

  console.log("[createStudent] 0/ start");
  let admin: { id: string };
  try {
    const r = await requireAdmin();
    admin = r.admin;
  } catch (e: any) {
    return fail("requireAdmin", e?.message ?? "Authentification requise");
  }

  let data: z.infer<typeof createStudentSchema>;
  try {
    data = validate(createStudentSchema, raw);
  } catch (e: any) {
    return fail("validate", e?.message ?? "Données invalides");
  }
  console.log("[createStudent] 2/ validate OK", {
    email: data.email,
    formation: data.formation_slug,
    access_mode: data.access_mode,
  });

  // Validation conditionnelle : si mode 'password', le mot de passe est requis
  if (data.access_mode === "password" && !data.initial_password) {
    return fail(
      "validate",
      "Mot de passe initial requis en mode 'password'"
    );
  }

  // Vérification rapide des env vars critiques
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    return fail(
      "env",
      "Configuration serveur incomplète : SUPABASE_SERVICE_ROLE_KEY manquant côté Vercel."
    );
  }
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL) {
    return fail(
      "env",
      "Configuration serveur incomplète : NEXT_PUBLIC_SUPABASE_URL manquant côté Vercel."
    );
  }

  const sb = createAdminClient();

  // Vérifier que la formation existe et récupérer son id
  const { data: formation, error: fErr } = await sb
    .from("formations")
    .select("id, slug, title")
    .eq("slug", data.formation_slug)
    .maybeSingle();
  if (fErr) return fail("formation_lookup", fErr.message);
  if (!formation)
    return fail(
      "formation_lookup",
      `Formation "${data.formation_slug}" introuvable`
    );

  // 1) Création du user auth
  let userId: string;
  if (data.access_mode === "invite") {
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
      // Cas connu : quota SMTP intégré Supabase atteint (~3-4/h en gratuit).
      // Suggère le mode password en attendant la config SMTP custom.
      const msg = invErr.message ?? "";
      const isRateLimit = /rate[\s_-]?limit|too[_\s]many/i.test(msg);
      const friendly = isRateLimit
        ? "Quota d'envoi d'emails Supabase atteint (limite intégrée). Utilisez le mode « Mot de passe initial » pour ce stagiaire, ou configurez SMTP custom (Resend) dans Supabase → Auth → SMTP Settings pour lever la limite."
        : `Invitation impossible : ${msg}`;
      return fail("invite", friendly);
    }
    userId = invited.user.id;
  } else {
    const { data: created, error: cErr } = await sb.auth.admin.createUser({
      email: data.email,
      password: data.initial_password!,
      email_confirm: true,
      user_metadata: { full_name: data.full_name, created_by: admin.id },
    });
    if (cErr) {
      return fail("create_user", `Création impossible : ${cErr.message}`);
    }
    userId = created.user.id;
  }
  console.log("[createStudent] 4/ auth user created", { userId });

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
    await sb.auth.admin.deleteUser(userId).catch(() => {});
    return fail(
      "profile_upsert",
      `Création du profil impossible : ${pErr.message}`
    );
  }
  console.log("[createStudent] 5/ profile upserted");

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
    console.error("[createStudent] enrollment insert failed (non-fatal)", eErr);
  } else {
    console.log("[createStudent] 6/ enrollment inserted");
  }

  // 4) Auto-marquage des leads correspondants en "inscrit". Si l'admin
  //    a créé ce stagiaire depuis le CRM (bouton "Convertir") ou même
  //    manuellement avec un email qui matche un lead existant, on
  //    marque tous les leads avec cet email comme convertis pour qu'ils
  //    apparaissent dans la section "Convertis & refusés" sans rester
  //    bloqués en attente dans le pipeline.
  try {
    const { data: updated } = await sb
      .from("enrollment_requests")
      .update({ status: "inscrit" })
      .ilike("email", data.email)
      .not("status", "eq", "refuse")
      .select("id");
    if (updated && updated.length > 0) {
      console.log(
        "[createStudent] 7/ leads CRM auto-marqués inscrit",
        updated.length
      );
    }
  } catch (e: any) {
    console.error(
      "[createStudent] auto-mark lead failed (non-fatal)",
      e?.message ?? e
    );
  }

  // 5) Audit log — non-bloquant si la table audit_log n'est pas dispo.
  try {
    await auditLog("create_student", "profile", userId, {
      email: data.email,
      formation_slug: data.formation_slug,
      access_mode: data.access_mode,
    });
  } catch (e: any) {
    console.error(
      "[createStudent] audit log failed (non-fatal)",
      e?.message ?? e
    );
  }

  revalidatePath("/admin/users");
  revalidatePath("/admin/enrollments");
  revalidatePath("/admin/crm");
  console.log("[createStudent] 8/ done", { userId });

  return { ok: true, userId, email: data.email, accessMode: data.access_mode };
}

export async function updateUserProfile(userId: string, raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  validate(uuid, userId);
  const patch = validate(updateProfileSchema, raw);

  // Protection anti auto-rétrogradation : un staff (admin OU super_admin) ne
  // peut pas se rétrograder vers un rôle non-staff (student / trainer) — ça
  // le verrouillerait hors de l'interface admin. En revanche un admin PEUT
  // se promouvoir en super_admin, et inversement (entre rôles staff).
  if (userId === admin.id && patch.role) {
    const targetIsStaff = patch.role === "admin" || patch.role === "super_admin";
    if (!targetIsStaff) {
      throw new Error(
        "Vous ne pouvez pas retirer votre propre rôle d'administration. Demandez à un autre super administrateur."
      );
    }
  }
  if (userId === admin.id && patch.disabled === true) {
    throw new Error("Vous ne pouvez pas désactiver votre propre compte");
  }

  const { error } = await supabase.from("profiles").update(patch).eq("id", userId);
  if (error) throw new Error(error.message);
  await auditLog("update_profile", "profile", userId, { fields: Object.keys(patch) });
  revalidatePath("/admin/users");
  revalidatePath(`/admin/users/${userId}`);
  // Force le rafraîchissement du shell complet : sidebar, user-menu, etc.
  // (le rôle apparaît dans le header et conditionne les liens visibles).
  revalidatePath("/", "layout");
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
