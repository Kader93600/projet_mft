// =====================================================================
// Helpers de permissions côté TypeScript.
// Mirror des helpers SQL (is_admin, is_super_admin, is_staff, is_trainer).
// À utiliser PARTOUT pour vérifier les rôles, jamais de comparaisons en dur.
// =====================================================================

export type Role = "student" | "trainer" | "admin" | "super_admin";

/** True si admin OU super_admin (équivalent du SQL is_admin()). */
export function isStaff(role: Role | string | null | undefined): boolean {
  return role === "admin" || role === "super_admin";
}

/** Alias plus explicite. */
export const isAdmin = isStaff;

/** True uniquement pour super_admin (régalien). */
export function isSuperAdmin(role: Role | string | null | undefined): boolean {
  return role === "super_admin";
}

/** True pour les rôles qui peuvent encadrer des stagiaires. */
export function canManageStudents(
  role: Role | string | null | undefined
): boolean {
  return role === "trainer" || isStaff(role);
}

/** True pour le rôle stagiaire (utile pour gates UI). */
export function isStudent(role: Role | string | null | undefined): boolean {
  return role === "student";
}

/** True pour formateur (uniquement). */
export function isTrainer(role: Role | string | null | undefined): boolean {
  return role === "trainer";
}

/**
 * Routes /admin/* ouvertes aux formateurs (pédagogie).
 * Le scope par formation est appliqué au niveau des actions et des
 * requêtes (RLS / filtres). Ces routes sont en LECTURE pour les
 * formateurs ; les écritures sont gardées par requireStaffOrFormationTrainer.
 */
export const TRAINER_ALLOWED_ADMIN_PREFIXES = [
  "/admin/modules",
  "/admin/quizzes",
  "/admin/banque-questions",
  "/admin/placement",
] as const;

/** True si la route /admin/* est accessible à un formateur. */
export function isTrainerAllowedAdminRoute(pathname: string): boolean {
  return TRAINER_ALLOWED_ADMIN_PREFIXES.some((p) => pathname.startsWith(p));
}

/**
 * True si l'utilisateur peut accéder à une route /admin/* selon son rôle.
 * - admin / super_admin : tout
 * - trainer : uniquement les routes pédagogiques listées ci-dessus
 * - student : rien
 */
export function canAccessAdminRoute(
  role: Role | string | null | undefined,
  pathname: string
): boolean {
  if (isStaff(role)) return true;
  if (isTrainer(role) && isTrainerAllowedAdminRoute(pathname)) return true;
  return false;
}
