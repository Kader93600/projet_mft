// =====================================================================
// Markdown renderer — version premium pour les leçons MA FORMATION TRANSPORT.
//
// Refonte 2026-05 : tokenizer ligne par ligne pour gérer correctement les
// blocs multi-lignes (blockquotes, code blocks, listes, tables) et
// détecter les callouts pédagogiques par emoji en tête de blockquote.
//
// API publique inchangée : `renderMarkdown(md: string): string`.
//
// Couvre :
//  - headings h1-h4
//  - paragraphes
//  - listes ordonnées et non ordonnées
//  - tableaux GFM (avec alignement)
//  - blockquotes multi-lignes (regroupées)
//  - **callouts pédagogiques** : blockquote dont la 1re ligne commence par
//    un emoji défini → rendu en card stylée (objectifs / info / etc.)
//  - fenced code blocks ``` (optional language)
//  - bold / italic / code inline / liens
//  - horizontal rules ---
//  - line breaks dans paragraphes
// =====================================================================

const CALLOUT_EMOJIS: Record<
  string,
  { variant: string; defaultTitle: string }
> = {
  "🎯": { variant: "objectifs", defaultTitle: "Objectifs" },
  "📌": { variant: "important", defaultTitle: "À retenir" },
  "⚠️": { variant: "attention", defaultTitle: "Attention" },
  "⚠": { variant: "attention", defaultTitle: "Attention" },
  "💡": { variant: "astuce", defaultTitle: "Astuce" },
  "✅": { variant: "synthese", defaultTitle: "À retenir" },
  "🔍": { variant: "focus", defaultTitle: "Focus" },
  "❌": { variant: "piege", defaultTitle: "Piège à éviter" },
  "📚": { variant: "ressource", defaultTitle: "Ressource" },
  "🎓": { variant: "examen", defaultTitle: "Examen" },
};

const ESCAPE_HTML: Record<string, string> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
};

function escapeHtml(s: string): string {
  return s.replace(/[&<>]/g, (c) => ESCAPE_HTML[c]);
}

// ---------------------------------------------------------------------
// Inline (gras / italique / code inline / liens) — appliqué APRÈS l'échappement HTML
// ---------------------------------------------------------------------

function renderInline(text: string): string {
  let out = text;
  // Code inline d'abord pour ne pas être altéré par le gras/italique
  out = out.replace(/`([^`]+)`/g, (_, code) => `<code>${code}</code>`);
  // Liens [txt](url) — url commence par http(s)://, mailto: ou /
  out = out.replace(
    /\[([^\]]+)\]\(((?:https?:\/\/|mailto:|\/)[^)\s]+)\)/g,
    '<a href="$2" target="_blank" rel="noopener noreferrer">$1</a>'
  );
  // Gras (** ou __)
  out = out.replace(/\*\*([^*]+?)\*\*/g, "<strong>$1</strong>");
  out = out.replace(/__([^_]+?)__/g, "<strong>$1</strong>");
  // Italique (* ou _) — précédé d'un non-* / non-_
  out = out.replace(/(^|[\s(])\*([^*\n]+?)\*/g, "$1<em>$2</em>");
  out = out.replace(/(^|[\s(])_([^_\n]+?)_/g, "$1<em>$2</em>");
  return out;
}

// ---------------------------------------------------------------------
// Détection des emojis callout en tête de blockquote
// ---------------------------------------------------------------------

interface CalloutInfo {
  variant: string;
  title: string;
  emoji: string;
}

function detectCallout(firstLine: string): CalloutInfo | null {
  const trimmed = firstLine.trim();
  for (const [emoji, info] of Object.entries(CALLOUT_EMOJIS)) {
    if (trimmed.startsWith(emoji)) {
      const rest = trimmed.slice(emoji.length).trim();
      let title = info.defaultTitle;
      const boldMatch = rest.match(/^\*\*([^*]+?)\*\*/);
      if (boldMatch) {
        title = boldMatch[1];
      } else if (rest && !rest.startsWith("-")) {
        const colonMatch = rest.match(/^([^:.\n]+)[:.](\s|$)/);
        if (colonMatch) title = colonMatch[1].trim();
        else if (rest.length < 60) title = rest;
      }
      return { variant: info.variant, title, emoji };
    }
  }
  return null;
}

// ---------------------------------------------------------------------
// Renderer principal — block tokenizer ligne par ligne
// ---------------------------------------------------------------------

export function renderMarkdown(md: string): string {
  const escaped = escapeHtml(md);
  const lines = escaped.split("\n");
  const out: string[] = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];

    // ---- Fenced code block ``` (optional language) ----
    const codeFence = line.match(/^```(\w*)\s*$/);
    if (codeFence) {
      const lang = codeFence[1] || "";
      const codeLines: string[] = [];
      i++;
      while (i < lines.length && !/^```\s*$/.test(lines[i])) {
        codeLines.push(lines[i]);
        i++;
      }
      i++; // saute le ``` fermant (ou EOF)
      const content = codeLines.join("\n");
      out.push(
        `<pre data-lang="${lang}"><code class="lang-${lang}">${content}</code></pre>`
      );
      continue;
    }

    // ---- Horizontal rule ----
    if (/^\s*---\s*$/.test(line) || /^\s*\*\*\*\s*$/.test(line)) {
      out.push("<hr/>");
      i++;
      continue;
    }

    // ---- Headings ----
    const h = line.match(/^(#{1,4})\s+(.+)$/);
    if (h) {
      const level = h[1].length;
      const text = renderInline(h[2].trim());
      out.push(`<h${level}>${text}</h${level}>`);
      i++;
      continue;
    }

    // ---- Tables GFM ----
    if (
      /^\s*\|.*\|\s*$/.test(line) &&
      i + 1 < lines.length &&
      /^\s*\|[\s:|-]+\|\s*$/.test(lines[i + 1])
    ) {
      const tableLines: string[] = [];
      while (i < lines.length && /^\s*\|.*\|\s*$/.test(lines[i])) {
        tableLines.push(lines[i]);
        i++;
      }
      out.push(renderTable(tableLines));
      continue;
    }

    // ---- Blockquote (groupée multi-lignes) ----
    if (/^&gt;\s?/.test(line)) {
      const bqLines: string[] = [];
      while (i < lines.length && /^&gt;\s?/.test(lines[i])) {
        bqLines.push(lines[i].replace(/^&gt;\s?/, ""));
        i++;
      }
      out.push(renderBlockquote(bqLines));
      continue;
    }

    // ---- Liste non ordonnée (- ou *) ----
    if (/^\s*[-*]\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\s*[-*]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\s*[-*]\s+/, ""));
        i++;
      }
      out.push(
        `<ul>${items.map((it) => `<li>${renderInline(it)}</li>`).join("")}</ul>`
      );
      continue;
    }

    // ---- Liste ordonnée (1. 2. ...) ----
    if (/^\s*\d+\.\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\s*\d+\.\s+/, ""));
        i++;
      }
      out.push(
        `<ol>${items.map((it) => `<li>${renderInline(it)}</li>`).join("")}</ol>`
      );
      continue;
    }

    // ---- Ligne vide ----
    if (line.trim() === "") {
      i++;
      continue;
    }

    // ---- Paragraphe ----
    const paraLines: string[] = [line];
    i++;
    while (i < lines.length) {
      const l = lines[i];
      if (
        l.trim() === "" ||
        /^(#{1,4})\s+/.test(l) ||
        /^&gt;\s?/.test(l) ||
        /^\s*[-*]\s+/.test(l) ||
        /^\s*\d+\.\s+/.test(l) ||
        /^```/.test(l) ||
        /^\s*---\s*$/.test(l) ||
        /^\s*\|.*\|\s*$/.test(l)
      ) {
        break;
      }
      paraLines.push(l);
      i++;
    }
    const paraText = paraLines.map((l) => renderInline(l)).join("<br/>");
    out.push(`<p>${paraText}</p>`);
  }

  return out.join("\n");
}

// ---------------------------------------------------------------------
// Rendus de blocs
// ---------------------------------------------------------------------

function renderTable(lines: string[]): string {
  const rows = lines.map((r) =>
    r.trim().replace(/^\||\|$/g, "").split("|").map((c) => c.trim())
  );
  if (rows.length < 2) return lines.join("\n");
  const [head, sep, ...body] = rows;
  if (!sep.every((s) => /^:?-+:?$/.test(s))) return lines.join("\n");

  const aligns = sep.map((s) => {
    const left = s.startsWith(":");
    const right = s.endsWith(":");
    if (left && right) return "center";
    if (right) return "right";
    return "left";
  });

  const thead =
    "<thead><tr>" +
    head
      .map(
        (c, idx) =>
          `<th style="text-align:${aligns[idx]}">${renderInline(c)}</th>`
      )
      .join("") +
    "</tr></thead>";

  const tbody =
    "<tbody>" +
    body
      .map(
        (row) =>
          "<tr>" +
          row
            .map(
              (cell, idx) =>
                `<td style="text-align:${aligns[idx]}">${renderInline(cell)}</td>`
            )
            .join("") +
          "</tr>"
      )
      .join("") +
    "</tbody>";

  return `<div class="table-wrap"><table>${thead}${tbody}</table></div>`;
}

function renderBlockquote(lines: string[]): string {
  const firstNonEmpty = lines.find((l) => l.trim() !== "") ?? "";
  const callout = detectCallout(firstNonEmpty);

  if (callout) {
    const indexFirst = lines.indexOf(firstNonEmpty);
    const headerLine = lines[indexFirst];
    let contentLines = lines.slice(indexFirst + 1);
    // Si après l'emoji + titre il reste du texte sur la même ligne, on le garde
    const remaining = headerLine
      .trim()
      .replace(callout.emoji, "")
      .trim()
      .replace(/^\*\*[^*]+?\*\*\s*[:.]?/, "")
      .trim();
    if (remaining) {
      contentLines = [remaining, ...contentLines];
    }
    while (contentLines.length && contentLines[0].trim() === "") contentLines.shift();
    while (contentLines.length && contentLines[contentLines.length - 1].trim() === "")
      contentLines.pop();

    const innerHtml = renderInnerBlock(contentLines.join("\n"));

    return `<aside class="callout callout--${callout.variant}" role="note"><div class="callout__header"><span class="callout__emoji" aria-hidden="true">${callout.emoji}</span><span class="callout__title">${escapeHtml(callout.title)}</span></div><div class="callout__body">${innerHtml}</div></aside>`;
  }

  const innerHtml = renderInnerBlock(lines.join("\n"));
  return `<blockquote>${innerHtml}</blockquote>`;
}

function renderInnerBlock(content: string): string {
  const lines = content.split("\n");
  const parts: string[] = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    if (line.trim() === "") {
      i++;
      continue;
    }
    if (/^\s*[-*]\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\s*[-*]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\s*[-*]\s+/, ""));
        i++;
      }
      parts.push(
        `<ul>${items.map((it) => `<li>${renderInline(it)}</li>`).join("")}</ul>`
      );
      continue;
    }
    if (/^\s*\d+\.\s+/.test(line)) {
      const items: string[] = [];
      while (i < lines.length && /^\s*\d+\.\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\s*\d+\.\s+/, ""));
        i++;
      }
      parts.push(
        `<ol>${items.map((it) => `<li>${renderInline(it)}</li>`).join("")}</ol>`
      );
      continue;
    }
    const para: string[] = [line];
    i++;
    while (
      i < lines.length &&
      lines[i].trim() !== "" &&
      !/^\s*[-*]\s+/.test(lines[i]) &&
      !/^\s*\d+\.\s+/.test(lines[i])
    ) {
      para.push(lines[i]);
      i++;
    }
    parts.push(`<p>${para.map((l) => renderInline(l)).join("<br/>")}</p>`);
  }
  return parts.join("\n");
}
