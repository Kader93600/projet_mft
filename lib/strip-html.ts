/**
 * Convertit un fragment HTML (issu de TipTap, d'un import PDF, etc.)
 * en texte brut lisible : balises supprimées, entités décodées,
 * espaces compactés.
 *
 * Utilisé pour afficher les énoncés de questions dans les listes
 * et sélecteurs admin (où on ne veut pas du HTML brut visible).
 */
export function stripHtml(input: string | null | undefined): string {
  if (!input) return "";
  return input
    // Tags de structure → retour ligne logique (avant strip global)
    .replace(/<\/(p|div|h[1-6]|li|tr|br)>/gi, " ")
    .replace(/<br\s*\/?>(\s*)/gi, " ")
    .replace(/<li[^>]*>/gi, "• ")
    // Strip style/script blocs (au cas où)
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
    // Strip toutes les autres balises
    .replace(/<[^>]+>/g, "")
    // Décodage des entités HTML courantes
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/&apos;/gi, "'")
    .replace(/&hellip;/gi, "…")
    .replace(/&mdash;/gi, "—")
    .replace(/&ndash;/gi, "–")
    .replace(/&rsquo;/gi, "'")
    .replace(/&lsquo;/gi, "'")
    .replace(/&rdquo;/gi, "”")
    .replace(/&ldquo;/gi, "“")
    // Décodage générique des entités numériques (&#1234; et &#xAB;)
    .replace(/&#(\d+);/g, (_, d) => String.fromCharCode(parseInt(d, 10)))
    .replace(/&#x([0-9a-f]+);/gi, (_, h) => String.fromCharCode(parseInt(h, 16)))
    // Compactage des espaces
    .replace(/\s+/g, " ")
    .trim();
}

/**
 * Variante qui tronque proprement à `max` caractères avec une ellipse.
 * Pratique pour les modales de confirmation : on veut un aperçu lisible
 * et borné, pas du HTML brut.
 */
export function stripHtmlPreview(
  input: string | null | undefined,
  max = 100,
): string {
  const txt = stripHtml(input);
  if (txt.length <= max) return txt;
  return txt.slice(0, max) + "…";
}
