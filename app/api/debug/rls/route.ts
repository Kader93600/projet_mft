/**
 * /api/debug/rls — Endpoint diagnostic RLS
 *
 * Compare, pour l'admin connecté, ce que voient :
 *   - le client SESSION (cookies → JWT → RLS appliqué)
 *   - le client SERVICE_ROLE (bypass RLS)
 *
 * Si l'écart est anormal, on a identifié laquelle des hypothèses H1/H2/H3/H4
 * (cf. CLAUDE.md + ticket bug RLS) est la cause racine :
 *
 *   H1 — JWT non propagé : `auth.uid()` retourne NULL côté server (via RPC
 *        `whoami`). Toutes les policies qui dépendent de auth.uid() se
 *        comportent comme si l'utilisateur n'était pas connecté.
 *
 *   H2 — Function buggy : `is_admin()` retourne FALSE pour un super_admin.
 *        Symptôme classique d'un SECURITY DEFINER sans `SET search_path`
 *        (le schéma `auth` n'est pas trouvé, donc `auth.uid()` lui-même
 *        retourne NULL à l'intérieur de la function).
 *
 *   H3 — Policy restrictive : une des policies ALL sur enrollments crée
 *        un AND silencieux. Multiple policies du même type (PERMISSIVE)
 *        se cumulent via OR, mais une RESTRICTIVE crée un AND. Voir
 *        2026_05_19_organizations.sql qui ajoute enrollments_org_admin.
 *
 *   H4 — RLS active mais 0 policy ne match : audit complet via pg_policies.
 *
 * Auth : seul un admin/super_admin connecté peut accéder à cet endpoint.
 */

import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";
export const revalidate = 0;

/** Message d'erreur d'un `catch` (la valeur levée est de type `unknown`). */
function errMessage(e: unknown): string {
  return e instanceof Error ? e.message : String(e);
}

/** Query builder d'un `select(...)` — le nom de table est dynamique ici, donc
 *  on dérive le type du builder depuis les clients eux-mêmes. */
type SessionCountQuery = ReturnType<
  ReturnType<Awaited<ReturnType<typeof createClient>>["from"]>["select"]
>;
type ServiceCountQuery = ReturnType<
  ReturnType<ReturnType<typeof createAdminClient>["from"]>["select"]
>;

type DebugReport = {
  generated_at: string;
  session: {
    user_id_from_auth_getUser: string | null;
    user_id_from_supabase_auth_uid_rpc: string | null;
    match: boolean;
    has_session_cookie: boolean;
  };
  profile: { id?: string; role?: string; email?: string; disabled?: boolean } | null;
  rpc_results: {
    is_admin: boolean | null;
    is_super_admin: boolean | null;
    is_staff: boolean | null;
    has_formation_access_gotrm: boolean | null;
    errors: Record<string, string | null>;
  };
  rls_visible_data: {
    enrollments_via_session_client: number | null;
    enrollments_via_service_role: number | null;
    modules_via_session_client: number | null;
    modules_via_service_role: number | null;
    lessons_via_session_client: number | null;
    lessons_via_service_role: number | null;
    profiles_self_via_session: number | null;
    errors: Record<string, string | null>;
  };
  active_policies: Array<{
    schemaname: string;
    tablename: string;
    policyname: string;
    cmd: string;
    permissive: string;
    roles: string[];
    qual: string | null;
    with_check: string | null;
  }>;
  hypothesis_hint: string;
};

export async function GET() {
  // Endpoint de diagnostic : ne doit JAMAIS répondre en production (il révèle
  // la structure des policies RLS et l'écart session/service-role). Le bug RLS
  // d'origine étant résolu, on le neutralise sauf activation explicite.
  if (
    process.env.NODE_ENV === "production" &&
    process.env.DEBUG_RLS_ENABLED !== "1"
  ) {
    return new Response("Not found", { status: 404 });
  }

  const report: DebugReport = {
    generated_at: new Date().toISOString(),
    session: {
      user_id_from_auth_getUser: null,
      user_id_from_supabase_auth_uid_rpc: null,
      match: false,
      has_session_cookie: false,
    },
    profile: null,
    rpc_results: {
      is_admin: null,
      is_super_admin: null,
      is_staff: null,
      has_formation_access_gotrm: null,
      errors: {},
    },
    rls_visible_data: {
      enrollments_via_session_client: null,
      enrollments_via_service_role: null,
      modules_via_session_client: null,
      modules_via_service_role: null,
      lessons_via_session_client: null,
      lessons_via_service_role: null,
      profiles_self_via_session: null,
      errors: {},
    },
    active_policies: [],
    hypothesis_hint: "",
  };

  // ─── 1) Auth session ────────────────────────────────────────────────────
  const supabase = await createClient();
  const { data: userData, error: userErr } = await supabase.auth.getUser();
  const sessionUser = userData?.user ?? null;
  report.session.has_session_cookie = !!sessionUser;
  report.session.user_id_from_auth_getUser = sessionUser?.id ?? null;

  if (!sessionUser) {
    return NextResponse.json(
      { error: "Non authentifié — connectez-vous comme admin avant d'appeler /api/debug/rls", report },
      { status: 401 }
    );
  }

  // Garde admin (lecture via service_role pour ne PAS dépendre du bug RLS
  // que l'on est précisément en train de diagnostiquer).
  let serviceClient: ReturnType<typeof createAdminClient>;
  try {
    serviceClient = createAdminClient();
  } catch (e) {
    return NextResponse.json(
      { error: "SUPABASE_SERVICE_ROLE_KEY manquante", details: errMessage(e) },
      { status: 500 }
    );
  }

  const { data: profileRow } = await serviceClient
    .from("profiles")
    .select("id, role, email, disabled")
    .eq("id", sessionUser.id)
    .single();
  const adminProfile: Pick<
    Tables<"profiles">,
    "id" | "role" | "email" | "disabled"
  > | null = profileRow;

  report.profile = adminProfile ?? null;

  if (!adminProfile || (adminProfile.role !== "admin" && adminProfile.role !== "super_admin")) {
    return NextResponse.json(
      { error: "Accès refusé — staff requis", report },
      { status: 403 }
    );
  }

  // ─── 2) auth.uid() côté DB via RPC (compare avec session côté Next) ────
  // On crée une RPC inline via `select auth.uid() as uid` exécutée par le
  // client SESSION (donc avec le JWT du user). Si la valeur est null, le
  // JWT n'arrive pas jusqu'à PostgreSQL → H1 confirmée.
  //
  // Note : Supabase n'expose pas auth.uid() directement en SELECT depuis
  // postgrest. On crée donc une RPC dédiée `public.debug_whoami()` (à
  // installer via _diagnostic_rls.sql) — fallback : on lit `auth.uid()`
  // depuis un select sur une vue. Si la RPC n'existe pas encore on log
  // l'erreur et on continue (l'endpoint reste utilisable pour les autres
  // checks).
  try {
    const { data: whoami, error: whoamiErr } = await supabase.rpc("debug_whoami");
    if (whoamiErr) {
      report.rpc_results.errors.whoami = whoamiErr.message;
    } else {
      // La RPC renvoie soit `{ uid }`, soit l'uid brut (string).
      const w: { uid?: string | null } | string | null = whoami;
      report.session.user_id_from_supabase_auth_uid_rpc =
        typeof w === "string" ? w : w?.uid ?? null;
    }
  } catch (e) {
    report.rpc_results.errors.whoami = errMessage(e);
  }

  report.session.match =
    !!report.session.user_id_from_auth_getUser &&
    report.session.user_id_from_auth_getUser ===
      report.session.user_id_from_supabase_auth_uid_rpc;

  // ─── 3) RPCs `is_admin`, `is_super_admin`, `is_staff`, `has_formation_access` ──
  // Tous appelés via le client SESSION (= avec JWT du user). C'est le test
  // direct des fonctions SECURITY DEFINER. Si elles renvoient false pour un
  // super_admin, on a confirmé H2 (function buggy).
  const callRpcBool = async (
    fn: string,
    args?: Record<string, string>
  ): Promise<boolean | null> => {
    try {
      const { data, error } = await supabase.rpc(fn, args ?? {});
      if (error) {
        report.rpc_results.errors[fn] = error.message;
        return null;
      }
      // Supabase RPC renvoie soit le booléen brut, soit un objet
      return typeof data === "boolean" ? data : Boolean(data);
    } catch (e) {
      report.rpc_results.errors[fn] = errMessage(e);
      return null;
    }
  };

  report.rpc_results.is_admin = await callRpcBool("is_admin");
  report.rpc_results.is_super_admin = await callRpcBool("is_super_admin");
  report.rpc_results.is_staff = await callRpcBool("is_staff");
  report.rpc_results.has_formation_access_gotrm = await callRpcBool(
    "has_formation_access",
    { p_user: sessionUser.id, p_slug: "gotrm" }
  );

  // ─── 4) Compteurs via client SESSION (RLS appliqué) ────────────────────
  const countSession = async (
    table: string,
    extra?: (q: SessionCountQuery) => SessionCountQuery
  ): Promise<number | null> => {
    try {
      let q: SessionCountQuery = supabase
        .from(table)
        .select("*", { count: "exact", head: true });
      if (extra) q = extra(q);
      const { count, error } = await q;
      if (error) {
        report.rls_visible_data.errors[`session_${table}`] = error.message;
        return null;
      }
      return count ?? 0;
    } catch (e) {
      report.rls_visible_data.errors[`session_${table}`] = errMessage(e);
      return null;
    }
  };

  const countService = async (
    table: string,
    extra?: (q: ServiceCountQuery) => ServiceCountQuery
  ): Promise<number | null> => {
    try {
      let q: ServiceCountQuery = serviceClient
        .from(table)
        .select("*", { count: "exact", head: true });
      if (extra) q = extra(q);
      const { count, error } = await q;
      if (error) {
        report.rls_visible_data.errors[`service_${table}`] = error.message;
        return null;
      }
      return count ?? 0;
    } catch (e) {
      report.rls_visible_data.errors[`service_${table}`] = errMessage(e);
      return null;
    }
  };

  report.rls_visible_data.enrollments_via_session_client = await countSession("enrollments");
  report.rls_visible_data.enrollments_via_service_role = await countService("enrollments");
  report.rls_visible_data.modules_via_session_client = await countSession("modules");
  report.rls_visible_data.modules_via_service_role = await countService("modules");
  report.rls_visible_data.lessons_via_session_client = await countSession("lessons");
  report.rls_visible_data.lessons_via_service_role = await countService("lessons");
  report.rls_visible_data.profiles_self_via_session = await countSession(
    "profiles",
    (q) => q.eq("id", sessionUser.id)
  );

  // ─── 5) Liste des policies actives sur les tables sensibles ────────────
  const policiesSql = `
    select schemaname, tablename, policyname, cmd, permissive, roles, qual, with_check
      from pg_policies
     where schemaname = 'public'
       and tablename in ('enrollments','modules','lessons','quizzes','profiles')
     order by tablename, policyname
  `;
  try {
    // pg_policies n'est pas accessible depuis postgrest classique : on
    // passe par une RPC `debug_list_policies()` (à installer via
    // _diagnostic_rls.sql).
    const { data: policies, error: polErr } = await serviceClient.rpc(
      "debug_list_policies"
    );
    if (polErr) {
      report.rls_visible_data.errors.policies = polErr.message;
    } else if (Array.isArray(policies)) {
      report.active_policies = policies as DebugReport["active_policies"];
    }
  } catch (e) {
    report.rls_visible_data.errors.policies = errMessage(e);
  }

  // ─── 6) Diagnostic auto-hint ──────────────────────────────────────────
  const hints: string[] = [];

  if (!report.session.match && report.session.user_id_from_supabase_auth_uid_rpc === null) {
    hints.push(
      "H1 PROBABLE — auth.uid() retourne NULL côté DB alors que le user est bien identifié côté Next. " +
        "Le JWT n'est pas propagé dans la session Postgres. Vérifier lib/supabase/server.ts (cookies → headers Authorization)."
    );
  }
  if (
    report.profile?.role === "super_admin" &&
    (report.rpc_results.is_admin === false || report.rpc_results.is_super_admin === false)
  ) {
    hints.push(
      "H2 PROBABLE — is_admin()/is_super_admin() retourne FALSE pour un super_admin. " +
        "Très probablement un SECURITY DEFINER sans `SET search_path = public, auth`. " +
        "Voir migration 2026_05_21_fix_rls_silencieux.sql."
    );
  }
  if (
    report.rpc_results.is_admin === true &&
    report.rls_visible_data.enrollments_via_session_client === 0 &&
    (report.rls_visible_data.enrollments_via_service_role ?? 0) > 0
  ) {
    hints.push(
      "H3 PROBABLE — is_admin()=true mais 0 enrollment visible via session. " +
        "Une policy RESTRICTIVE ou un AND silencieux. Auditer les 4 policies " +
        "(enrollments_self, enrollments_admin, enrollments_funder_read, enrollments_org_admin)."
    );
  }
  if (report.active_policies.length === 0) {
    hints.push(
      "H4 POSSIBLE — Aucune policy listée. Soit la RPC debug_list_policies n'est pas installée, " +
        "soit RLS est activée sans aucune policy → tout est refusé par défaut."
    );
  }
  if (hints.length === 0) {
    hints.push(
      "Aucun symptôme évident détecté par l'auto-hint. Comparer manuellement les compteurs session vs service_role."
    );
  }
  report.hypothesis_hint = hints.join(" | ");

  return NextResponse.json(report, { status: 200 });
}
