/**
 * Sanitisation des termes de recherche destinés aux filtres PostgREST
 * (`.or(...)`, `.ilike(...)`) de supabase-js.
 *
 * POURQUOI : un filtre `.or("a.ilike.%x%,b.ilike.%x%")` est une **chaîne**
 * envoyée telle quelle à PostgREST sous la forme `or=(a.ilike.%x%,b.ilike.%x%)`.
 * Si on interpole un terme utilisateur brut dans cette chaîne, l'utilisateur
 * peut casser la grammaire du filtre :
 *   - la **virgule** sépare les conditions d'un `or=(...)` → injection de
 *     conditions arbitraires (`,role.eq.admin`) ;
 *   - les **parenthèses** groupent les conditions et peuvent fermer le
 *     `or(...)` prématurément ;
 *   - l'**antislash** sert d'échappement ;
 *   - l'**astérisque** est un wildcard `ilike` côté PostgREST.
 * La RLS borne toujours les lignes accessibles, mais l'injection permet des
 * requêtes non prévues (erreurs 500, énumération booléenne, opérateurs
 * coûteux). On neutralise donc ces métacaractères avant interpolation.
 *
 * On conserve volontairement `.` et `@` : dans la position « valeur » d'une
 * condition PostgREST, seuls les deux premiers points sont structurels
 * (`champ.operateur.valeur`) ; les points suivants font partie de la valeur.
 * Les garder permet la recherche d'e-mails (`jean.dupont@...`).
 *
 * En complément on échappe les wildcards SQL `%` et `_` pour qu'ils restent
 * littéraux dans le motif `LIKE`.
 */
export function sanitizeSearchTerm(input: string): string {
  return input
    .trim()
    // Métacaractères de la grammaire de filtre PostgREST → espace.
    .replace(/[,()\\*]/g, " ")
    // Wildcards SQL LIKE → littéraux.
    .replace(/[%_]/g, "\\$&")
    // Normalise les espaces laissés par les remplacements.
    .replace(/\s+/g, " ")
    .trim();
}
