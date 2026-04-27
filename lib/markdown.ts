// Minimaliste : convertit le markdown pédagogique en HTML propre pour les leçons.
// Couvre : headings, gras, italic, listes, tableaux, blockquote, code inline.
// Suffisant pour le contenu seedé. Pour du markdown avancé : react-markdown + remark-gfm.

export function renderMarkdown(md: string): string {
  let html = md;

  // Échapper HTML brut
  html = html.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

  // Tableaux (simple GFM)
  html = html.replace(/((?:^\|.*\|\s*\n)+)/gm, (block) => {
    const rows = block.trim().split("\n").map((r) => r.replace(/^\||\|$/g, "").split("|").map((c) => c.trim()));
    if (rows.length < 2) return block;
    const [head, sep, ...body] = rows;
    if (!sep.every((s) => /^:?-+:?$/.test(s))) return block;
    const thead = "<thead><tr>" + head.map((c) => `<th class="text-left px-3 py-2 bg-gray-50 border-b">${c}</th>`).join("") + "</tr></thead>";
    const tbody = "<tbody>" + body.map((r) => "<tr>" + r.map((c) => `<td class="px-3 py-2 border-b border-gray-100">${c}</td>`).join("") + "</tr>").join("") + "</tbody>";
    return `<table class="w-full text-sm my-4 border border-gray-200 rounded-lg overflow-hidden">${thead}${tbody}</table>`;
  });

  // Headings
  html = html.replace(/^### (.+)$/gm, "<h3>$1</h3>");
  html = html.replace(/^## (.+)$/gm, "<h2>$1</h2>");
  html = html.replace(/^# (.+)$/gm, "<h1>$1</h1>");

  // Blockquote
  html = html.replace(/^&gt; (.+)$/gm, "<blockquote>$1</blockquote>");

  // Listes non ordonnées
  html = html.replace(/(?:^- .+\n?)+/gm, (block) => {
    const items = block.trim().split("\n").map((l) => `<li>${l.replace(/^- /, "")}</li>`).join("");
    return `<ul>${items}</ul>`;
  });

  // Gras / italique / code
  html = html.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
  html = html.replace(/\*(.+?)\*/g, "<em>$1</em>");
  html = html.replace(/`([^`]+)`/g, '<code class="px-1 py-0.5 rounded bg-gray-100 text-xs">$1</code>');

  // Paragraphes
  html = html
    .split(/\n\n+/)
    .map((block) => {
      if (/^<(h\d|ul|ol|blockquote|table)/.test(block.trim())) return block;
      return `<p>${block.replace(/\n/g, "<br/>")}</p>`;
    })
    .join("\n");

  return html;
}
