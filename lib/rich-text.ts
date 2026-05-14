// =====================================================================
// Helpers ISOMORPHIC pour le rich text — utilisables client + server.
//
// Ne contient AUCUNE dépendance lourde (pas de DOMPurify, pas de jsdom).
// Pour le sanitize HTML :
//   - Côté CLIENT : import depuis `@/lib/rich-text-client` (utilise
//     DOMPurify natif du browser).
//   - Côté SERVER : import depuis `@/lib/rich-text-server` (regex
//     strict + DOMPurify si un DOM est disponible).
// =====================================================================

/**
 * Détecte si un contenu est du HTML rich-text (produit par TipTap)
 * ou du texte brut (questions importées avant l'éditeur).
 *
 * Heuristique simple : présence d'au moins une balise structurelle.
 */
export function isRichTextHtml(content: string | null | undefined): boolean {
  if (!content) return false;
  return /<(p|h[1-4]|ul|ol|table|blockquote|figure)\b[^>]*>/i.test(content);
}

/**
 * Convertit du texte brut en un HTML simple compatible TipTap.
 * Utile pour pré-remplir l'éditeur avec un contenu historique.
 */
export function plainTextToHtml(text: string): string {
  if (!text) return "";
  const escaped = text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
  const blocks = escaped.split(/\n{2,}/);
  return blocks
    .map((block) => {
      const withBr = block.replace(/\n/g, "<br />");
      return `<p>${withBr}</p>`;
    })
    .join("");
}

/**
 * Extrait du texte brut depuis un HTML rich-text.
 * Utile pour la recherche, les previews tronqués, etc.
 */
export function richTextToPlain(html: string): string {
  if (!html) return "";
  return html
    .replace(/<\/(p|h[1-4]|li|tr|div)>/gi, "\n")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<[^>]+>/g, "")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}

// =====================================================================
// SANITIZATION CÔTÉ SERVER (defense in depth)
// =====================================================================
//
// Approche regex stricte : on enlève les balises dangereuses + tous les
// event handlers + les schémas d'URI dangereux. C'est moins permissif
// qu'un vrai parser DOM mais ça suffit pour bloquer les injections
// usuelles. Le sanitize "fort" est fait côté CLIENT via DOMPurify
// dans rich-text-client.ts ; côté server c'est juste une 2e barrière.
//
// On garde cette fonction ici (isomorphic) car elle est appelée depuis
// les Server Actions / API routes.
// =====================================================================

const DANGEROUS_TAGS_RE =
  /<\s*\/?\s*(script|iframe|object|embed|form|input|button|textarea|select|option|meta|link|style|base|frame|frameset|applet|portal)\b[^>]*>/gi;

const DANGEROUS_ATTR_RE =
  /\s+(on\w+|formaction|srcdoc|xlink:href|action)\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/gi;

const DANGEROUS_URI_RE =
  /\s+(href|src|data|background|action)\s*=\s*("(?:\s*javascript:|\s*data:(?:[^,;]*;)?(?:base64,)?(?:text\/html|application\/xhtml))[^"]*"|'(?:\s*javascript:|\s*data:(?:[^,;]*;)?(?:base64,)?(?:text\/html|application\/xhtml))[^']*')/gi;

/**
 * Sanitize basique côté server. À n'utiliser QUE en defense in depth :
 * le vrai sanitize doit toujours être fait côté client (DOMPurify) avant
 * le rendu via dangerouslySetInnerHTML.
 *
 * Bloque :
 *   - <script>, <iframe>, <style>, <object>, <embed>, <form>, etc.
 *   - Tous les attributs `on*` (onclick, onerror, onload…)
 *   - href/src en `javascript:` ou `data:text/html`
 */
export function sanitizeRichTextServer(html: string): string {
  if (typeof html !== "string" || !html.trim()) return "";
  return html
    .replace(DANGEROUS_TAGS_RE, "")
    .replace(DANGEROUS_ATTR_RE, "")
    .replace(DANGEROUS_URI_RE, "");
}
