"use client";

// =====================================================================
// Sanitization rich-text CÔTÉ CLIENT uniquement.
//
// Utilise DOMPurify natif (qui marche dans le browser sans jsdom).
// À utiliser pour le rendu via dangerouslySetInnerHTML afin de
// neutraliser toute injection avant insertion dans le DOM.
// =====================================================================

import DOMPurify from "dompurify";

const ALLOWED_TAGS = [
  "p", "br", "div", "span",
  "h1", "h2", "h3", "h4",
  "strong", "b", "em", "i", "u", "s", "code", "mark", "sub", "sup",
  "ul", "ol", "li",
  "table", "thead", "tbody", "tr", "th", "td", "colgroup", "col",
  "a",
  "img", "figure", "figcaption",
  "blockquote", "hr", "pre",
];

const ALLOWED_ATTR = [
  "style",
  "class",
  "href", "target", "rel", "title",
  "src", "alt", "loading", "width", "height",
  "colspan", "rowspan",
];

const PURIFY_CONFIG = {
  ALLOWED_TAGS,
  ALLOWED_ATTR,
  ALLOWED_URI_REGEXP: /^(?:https?|mailto|tel|ftp):/i,
  FORBID_TAGS: ["script", "style", "iframe", "embed", "object", "form", "input"],
  FORBID_ATTR: ["onerror", "onload", "onclick", "onmouseover", "onfocus"],
};

let hookInstalled = false;
function installLinkHook() {
  if (hookInstalled) return;
  DOMPurify.addHook("afterSanitizeAttributes", (node: any) => {
    if (node.tagName === "A") {
      node.setAttribute("target", "_blank");
      node.setAttribute("rel", "noopener noreferrer nofollow");
    }
  });
  hookInstalled = true;
}

/**
 * Sanitize côté client. Idempotent.
 * - Force target="_blank" + rel="noopener noreferrer nofollow" sur les <a>
 * - Bloque schémas dangereux (javascript:, data:text/html, etc.)
 * - Whitelist stricte tags + attributs
 */
export function sanitizeRichTextClient(html: string): string {
  if (typeof html !== "string" || !html.trim()) return "";
  installLinkHook();
  return DOMPurify.sanitize(html, PURIFY_CONFIG) as unknown as string;
}
