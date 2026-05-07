// Parseur de blocs pédagogiques riches.
// Étend le markdown avec une syntaxe ::: directive ::: pour insérer
// des composants React (callouts, articles de loi, chiffres-clés…).
//
// Syntaxe supportée :
//
//   :::callout type=info title="Bon à savoir"
//   Texte markdown ici…
//   :::
//
//   :::law code="Code des transports" article="L. 3261-1" href="https://…" date="01/01/2025"
//   Texte cité…
//   :::
//
//   :::figures
//   - 9h | conduite max / jour
//   - 45min | pause minimale après 4h30
//   - 56h | semaine isolée max
//   :::

import * as React from "react";
import { renderMarkdown, renderFlowDiagram, renderTimeline } from "./markdown";
import { Callout } from "@/components/lesson/callout";
import { LawArticle } from "@/components/lesson/law-article";
import { KeyFigures } from "@/components/lesson/key-figure";
import { ScrollReveal } from "@/components/lesson/scroll-reveal";
import {
  Memo,
  Piege,
  CasPratique,
  Conseil,
  Objectifs,
} from "@/components/lesson/pedagogy-blocks";

type Segment =
  | { kind: "md"; content: string }
  | { kind: "block"; name: string; attrs: Record<string, string>; body: string };

// "key=value" ou key="quoted value"
function parseAttrs(s: string): Record<string, string> {
  const attrs: Record<string, string> = {};
  const re = /(\w+)\s*=\s*(?:"([^"]*)"|'([^']*)'|(\S+))/g;
  let m;
  while ((m = re.exec(s))) {
    attrs[m[1]] = m[2] ?? m[3] ?? m[4] ?? "";
  }
  return attrs;
}

function tokenize(src: string): Segment[] {
  const segments: Segment[] = [];
  const lines = src.split("\n");
  let buf: string[] = [];
  let i = 0;
  const flush = () => {
    if (buf.length) {
      segments.push({ kind: "md", content: buf.join("\n") });
      buf = [];
    }
  };
  while (i < lines.length) {
    const line = lines[i];
    const open = line.match(/^:::(\w+)(?:\s+(.*))?$/);
    if (open) {
      flush();
      const name = open[1];
      const attrs = parseAttrs(open[2] ?? "");
      const body: string[] = [];
      i++;
      while (i < lines.length && !/^:::\s*$/.test(lines[i])) {
        body.push(lines[i]);
        i++;
      }
      // i pointe sur la ligne ":::" (ou hors tableau si non fermé)
      i++;
      segments.push({ kind: "block", name, attrs, body: body.join("\n") });
    } else {
      buf.push(line);
      i++;
    }
  }
  flush();
  return segments;
}

function parseFigures(body: string) {
  return body
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l.startsWith("- "))
    .map((l) => {
      const [val, label] = l.slice(2).split("|").map((s) => s.trim());
      // val peut être "9h", "45min" — séparer chiffres / unité
      const m = val?.match(/^([\d.,]+)(.*)$/);
      return {
        value: m?.[1] ?? val ?? "",
        unit: m?.[2]?.trim() || undefined,
        label: label ?? "",
      };
    });
}

export function LessonContent({ source }: { source: string }) {
  const segments = tokenize(source);

  // Sub-segmentation des segments md : on découpe par double saut de ligne
  // pour pouvoir animer paragraphe par paragraphe (effet Apple).
  type AnimItem =
    | { kind: "md-block"; content: string; keyId: string }
    | { kind: "block"; seg: Extract<Segment, { kind: "block" }>; keyId: string };
  const animated: AnimItem[] = segments.flatMap((seg, idx): AnimItem[] => {
    if (seg.kind === "md") {
      const blocks = seg.content
        .split(/\n\n+/)
        .map((b) => b.trim())
        .filter(Boolean);
      return blocks.map((block, j) => ({
        kind: "md-block",
        content: block,
        keyId: `${idx}-${j}`,
      }));
    }
    return [{ kind: "block", seg, keyId: String(idx) }];
  });

  return (
    <div className="prose-lesson">
      {animated.map((item, i) => {
        // Stagger doux : 60ms par item (cap à 8 items pour éviter
        // un délai cumulé trop long sur les longues leçons)
        const delay = Math.min(i, 8) * 60;
        if (item.kind === "md-block") {
          return (
            <ScrollReveal key={item.keyId} delay={delay}>
              <div
                dangerouslySetInnerHTML={{
                  __html: renderMarkdown(item.content),
                }}
              />
            </ScrollReveal>
          );
        }
        const seg = item.seg;
        // Wrap avec ScrollReveal pour les blocs riches aussi
        const block = renderRichBlock(seg, item.keyId);
        if (!block) return null;
        return (
          <ScrollReveal key={item.keyId} delay={delay}>
            {block}
          </ScrollReveal>
        );
      })}
    </div>
  );
}

function renderRichBlock(
  seg: Extract<Segment, { kind: "block" }>,
  idx: string
): React.ReactNode {
  // (Bloc de fallback déplacé en haut pour réutilisation)
  const md = (body: string) => (
    <div dangerouslySetInnerHTML={{ __html: renderMarkdown(body) }} />
  );
  if (seg.name === "callout") {
    const variant = (seg.attrs.type ?? "info") as any;
    return (
      <Callout key={idx} variant={variant} title={seg.attrs.title}>
        {md(seg.body)}
      </Callout>
    );
  }
  if (seg.name === "law") {
    return (
      <LawArticle
        key={idx}
        code={seg.attrs.code ?? "Code"}
        article={seg.attrs.article ?? ""}
        href={seg.attrs.href}
        date={seg.attrs.date}
      >
        {md(seg.body)}
      </LawArticle>
    );
  }
  if (seg.name === "figures") return <KeyFigures key={idx} items={parseFigures(seg.body)} />;
  if (seg.name === "memo")
    return <Memo key={idx} title={seg.attrs.title}>{md(seg.body)}</Memo>;
  if (seg.name === "piege")
    return <Piege key={idx} title={seg.attrs.title}>{md(seg.body)}</Piege>;
  if (seg.name === "caspratique")
    return <CasPratique key={idx} title={seg.attrs.title}>{md(seg.body)}</CasPratique>;
  if (seg.name === "conseil")
    return <Conseil key={idx} title={seg.attrs.title}>{md(seg.body)}</Conseil>;
  if (seg.name === "objectifs") {
    const items = seg.body
      .split("\n")
      .map((l) => l.trim())
      .filter((l) => l.startsWith("- "))
      .map((l) => l.slice(2).trim());
    return <Objectifs key={idx} items={items} />;
  }
  if (seg.name === "flow") {
    return (
      <div
        key={idx}
        dangerouslySetInnerHTML={{
          __html: renderFlowDiagram(seg.body.split("\n")),
        }}
      />
    );
  }
  if (seg.name === "timeline") {
    return (
      <div
        key={idx}
        dangerouslySetInnerHTML={{
          __html: renderTimeline(seg.body.split("\n")),
        }}
      />
    );
  }
  return (
    <div
      key={idx}
      className="my-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-3 text-xs text-slate-500"
    >
      <span className="font-mono font-semibold">:::{seg.name}</span>
      <pre className="whitespace-pre-wrap mt-1 text-slate-700">{seg.body}</pre>
    </div>
  );
}

function _legacyRender({ source }: { source: string }) {
  // Conservé pour rétro-compat éventuelle, non utilisé
  const segments = tokenize(source);
  return (
    <div className="prose-lesson">
      {segments.map((seg, idx) => {
        if (seg.kind === "md") {
          if (!seg.content.trim()) return null;
          return (
            <div
              key={idx}
              dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.content) }}
            />
          );
        }
        // Blocks
        if (seg.name === "callout") {
          const variant = (seg.attrs.type ?? "info") as any;
          return (
            <Callout key={idx} variant={variant} title={seg.attrs.title}>
              <div
                dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.body) }}
              />
            </Callout>
          );
        }
        if (seg.name === "law") {
          return (
            <LawArticle
              key={idx}
              code={seg.attrs.code ?? "Code"}
              article={seg.attrs.article ?? ""}
              href={seg.attrs.href}
              date={seg.attrs.date}
            >
              <div
                dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.body) }}
              />
            </LawArticle>
          );
        }
        if (seg.name === "figures") {
          return <KeyFigures key={idx} items={parseFigures(seg.body)} />;
        }
        if (seg.name === "memo") {
          return (
            <Memo key={idx} title={seg.attrs.title}>
              <div
                dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.body) }}
              />
            </Memo>
          );
        }
        if (seg.name === "piege") {
          return (
            <Piege key={idx} title={seg.attrs.title}>
              <div
                dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.body) }}
              />
            </Piege>
          );
        }
        if (seg.name === "caspratique") {
          return (
            <CasPratique key={idx} title={seg.attrs.title}>
              <div
                dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.body) }}
              />
            </CasPratique>
          );
        }
        if (seg.name === "conseil") {
          return (
            <Conseil key={idx} title={seg.attrs.title}>
              <div
                dangerouslySetInnerHTML={{ __html: renderMarkdown(seg.body) }}
              />
            </Conseil>
          );
        }
        if (seg.name === "objectifs") {
          // Lignes type "- objectif" → array
          const items = seg.body
            .split("\n")
            .map((l) => l.trim())
            .filter((l) => l.startsWith("- "))
            .map((l) => l.slice(2).trim());
          return <Objectifs key={idx} items={items} />;
        }
        // Inconnu : on rend en bloc neutre pour ne pas perdre le contenu
        return (
          <div
            key={idx}
            className="my-4 rounded-xl border border-dashed border-slate-300 bg-slate-50 p-3 text-xs text-slate-500"
          >
            <span className="font-mono font-semibold">:::{seg.name}</span>
            <pre className="whitespace-pre-wrap mt-1 text-slate-700">
              {seg.body}
            </pre>
          </div>
        );
      })}
    </div>
  );
}
