import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { LEGAL } from "@/lib/legal-config";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/* ─── Styles ───────────────────────────────────────────────────────── */
const s = StyleSheet.create({
  page: {
    padding: 50,
    paddingBottom: 70,
    fontSize: 10,
    fontFamily: "Helvetica",
    color: "#0f172a",
    lineHeight: 1.5,
  },
  topBar: { height: 6, backgroundColor: "#9FE220", marginBottom: 18 },
  headerRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    marginBottom: 18,
    paddingBottom: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#0E1240",
  },
  brand: { fontSize: 14, fontWeight: "bold", color: "#0E1240", letterSpacing: 1 },
  brandSub: { fontSize: 8, color: "#64748b", marginTop: 2 },
  meta: { fontSize: 8, color: "#64748b", textAlign: "right" },
  title: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 6,
    marginBottom: 4,
  },
  underline: { width: 36, height: 2, backgroundColor: "#9FE220", marginBottom: 14 },
  h1: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 16,
    marginBottom: 6,
  },
  h2: {
    fontSize: 12,
    fontWeight: "bold",
    color: "#0E1240",
    textTransform: "uppercase",
    letterSpacing: 0.8,
    marginTop: 14,
    marginBottom: 4,
    borderBottomWidth: 0.6,
    borderBottomColor: "#9FE220",
    paddingBottom: 3,
  },
  h3: {
    fontSize: 11,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 10,
    marginBottom: 3,
  },
  para: { fontSize: 10, lineHeight: 1.55, color: "#334155", marginBottom: 5 },
  italic: { fontStyle: "italic", color: "#64748b" },
  bold: { fontWeight: "bold", color: "#0E1240" },
  hr: {
    borderBottomWidth: 0.5,
    borderBottomColor: "#cbd5e1",
    marginVertical: 10,
  },
  bulletRow: { flexDirection: "row", marginBottom: 3 },
  bulletDot: { width: 12, fontSize: 10, color: "#609015" },
  bulletText: { flex: 1, fontSize: 10, lineHeight: 1.5, color: "#334155" },
  table: {
    marginTop: 6,
    marginBottom: 8,
    borderWidth: 0.6,
    borderColor: "#cbd5e1",
  },
  tr: {
    flexDirection: "row",
    borderBottomWidth: 0.4,
    borderBottomColor: "#e2e8f0",
  },
  th: {
    flex: 1,
    backgroundColor: "#f1f5f9",
    fontSize: 8,
    fontWeight: "bold",
    color: "#0E1240",
    textTransform: "uppercase",
    padding: 5,
  },
  td: { flex: 1, fontSize: 9, padding: 5, color: "#334155" },
  footer: {
    position: "absolute",
    bottom: 24,
    left: 50,
    right: 50,
    fontSize: 7,
    color: "#94a3b8",
    borderTopWidth: 0.4,
    borderTopColor: "#cbd5e1",
    paddingTop: 4,
    textAlign: "center",
  },
  signatures: {
    marginTop: 28,
    flexDirection: "row",
    justifyContent: "space-between",
    gap: 24,
  },
  signBlock: {
    flex: 1,
    borderTopWidth: 0.6,
    borderTopColor: "#0E1240",
    paddingTop: 6,
    fontSize: 9,
    color: "#0E1240",
  },
});

/* ─── Markdown light parser → React-PDF nodes ─────────────────────── */

/**
 * Renders **bold** and _italic_ inline within a paragraph.
 * Splits by alternating tokens; handles `**...**` first then `_..._`.
 */
function renderInline(text: string): React.ReactNode[] {
  // Tokenize **bold**
  const parts: { kind: "plain" | "bold" | "italic"; text: string }[] = [];
  const boldRe = /\*\*([^*]+)\*\*/g;
  let lastIdx = 0;
  let m: RegExpExecArray | null;
  while ((m = boldRe.exec(text)) !== null) {
    if (m.index > lastIdx) {
      parts.push({ kind: "plain", text: text.slice(lastIdx, m.index) });
    }
    parts.push({ kind: "bold", text: m[1] });
    lastIdx = m.index + m[0].length;
  }
  if (lastIdx < text.length) parts.push({ kind: "plain", text: text.slice(lastIdx) });

  // Then split each "plain" part by _italic_
  const out: React.ReactNode[] = [];
  parts.forEach((p, i) => {
    if (p.kind !== "plain") {
      out.push(
        <Text key={`b-${i}`} style={p.kind === "bold" ? s.bold : s.italic}>
          {p.text}
        </Text>
      );
      return;
    }
    const italRe = /_([^_]+)_/g;
    let last = 0;
    let mm: RegExpExecArray | null;
    let k = 0;
    while ((mm = italRe.exec(p.text)) !== null) {
      if (mm.index > last) {
        out.push(<Text key={`p-${i}-${k++}`}>{p.text.slice(last, mm.index)}</Text>);
      }
      out.push(
        <Text key={`i-${i}-${k++}`} style={s.italic}>
          {mm[1]}
        </Text>
      );
      last = mm.index + mm[0].length;
    }
    if (last < p.text.length) {
      out.push(<Text key={`p-${i}-end`}>{p.text.slice(last)}</Text>);
    }
  });
  return out;
}

type Block =
  | { type: "h1" | "h2" | "h3"; text: string }
  | { type: "p"; text: string }
  | { type: "hr" }
  | { type: "ul"; items: string[] }
  | { type: "ol"; items: string[] }
  | { type: "table"; header: string[]; rows: string[][] };

function parseMarkdown(md: string): Block[] {
  const lines = md.split("\n");
  const blocks: Block[] = [];
  let i = 0;
  const isTableRow = (l: string) =>
    l.trim().startsWith("|") && l.trim().endsWith("|");

  while (i < lines.length) {
    const line = lines[i];
    const trimmed = line.trim();

    if (!trimmed) {
      i++;
      continue;
    }

    if (trimmed === "---" || trimmed === "***") {
      blocks.push({ type: "hr" });
      i++;
      continue;
    }

    if (trimmed.startsWith("### ")) {
      blocks.push({ type: "h3", text: trimmed.slice(4) });
      i++;
      continue;
    }
    if (trimmed.startsWith("## ")) {
      blocks.push({ type: "h2", text: trimmed.slice(3) });
      i++;
      continue;
    }
    if (trimmed.startsWith("# ")) {
      blocks.push({ type: "h1", text: trimmed.slice(2) });
      i++;
      continue;
    }

    // Bullet list
    if (/^[-*]\s+/.test(trimmed)) {
      const items: string[] = [];
      while (i < lines.length && /^[-*]\s+/.test(lines[i].trim())) {
        items.push(lines[i].trim().replace(/^[-*]\s+/, ""));
        i++;
      }
      blocks.push({ type: "ul", items });
      continue;
    }

    // Numbered list
    if (/^\d+\.\s+/.test(trimmed)) {
      const items: string[] = [];
      while (i < lines.length && /^\d+\.\s+/.test(lines[i].trim())) {
        items.push(lines[i].trim().replace(/^\d+\.\s+/, ""));
        i++;
      }
      blocks.push({ type: "ol", items });
      continue;
    }

    // Table
    if (isTableRow(trimmed) && i + 1 < lines.length && /^\|[\s\-:|]+\|$/.test(lines[i + 1].trim())) {
      const headerCells = trimmed
        .slice(1, -1)
        .split("|")
        .map((c) => c.trim());
      i += 2; // skip header + separator
      const rows: string[][] = [];
      while (i < lines.length && isTableRow(lines[i].trim())) {
        const t = lines[i].trim();
        rows.push(
          t
            .slice(1, -1)
            .split("|")
            .map((c) => c.trim())
        );
        i++;
      }
      blocks.push({ type: "table", header: headerCells, rows });
      continue;
    }

    // Paragraph (peut s'étaler sur plusieurs lignes consécutives non vides)
    const paraLines: string[] = [trimmed];
    i++;
    while (
      i < lines.length &&
      lines[i].trim() &&
      !/^#{1,3}\s/.test(lines[i].trim()) &&
      !/^[-*]\s+/.test(lines[i].trim()) &&
      !/^\d+\.\s+/.test(lines[i].trim()) &&
      lines[i].trim() !== "---" &&
      !isTableRow(lines[i].trim())
    ) {
      paraLines.push(lines[i].trim());
      i++;
    }
    blocks.push({ type: "p", text: paraLines.join(" ") });
  }
  return blocks;
}

function MarkdownPdf({ blocks }: { blocks: Block[] }) {
  return (
    <>
      {blocks.map((b, i) => {
        switch (b.type) {
          case "h1":
            return (
              <Text key={i} style={s.h1}>
                {b.text}
              </Text>
            );
          case "h2":
            return (
              <Text key={i} style={s.h2}>
                {b.text}
              </Text>
            );
          case "h3":
            return (
              <Text key={i} style={s.h3}>
                {b.text}
              </Text>
            );
          case "hr":
            return <View key={i} style={s.hr} />;
          case "p":
            return (
              <Text key={i} style={s.para}>
                {renderInline(b.text)}
              </Text>
            );
          case "ul":
            return (
              <View key={i} style={{ marginBottom: 6 }}>
                {b.items.map((it, j) => (
                  <View key={j} style={s.bulletRow}>
                    <Text style={s.bulletDot}>•</Text>
                    <Text style={s.bulletText}>{renderInline(it)}</Text>
                  </View>
                ))}
              </View>
            );
          case "ol":
            return (
              <View key={i} style={{ marginBottom: 6 }}>
                {b.items.map((it, j) => (
                  <View key={j} style={s.bulletRow}>
                    <Text style={s.bulletDot}>{j + 1}.</Text>
                    <Text style={s.bulletText}>{renderInline(it)}</Text>
                  </View>
                ))}
              </View>
            );
          case "table":
            return (
              <View key={i} style={s.table}>
                <View style={s.tr}>
                  {b.header.map((h, j) => (
                    <Text key={j} style={s.th}>
                      {h}
                    </Text>
                  ))}
                </View>
                {b.rows.map((r, k) => (
                  <View key={k} style={s.tr}>
                    {r.map((c, j) => (
                      <Text key={j} style={s.td}>
                        {renderInline(c)}
                      </Text>
                    ))}
                  </View>
                ))}
              </View>
            );
        }
      })}
    </>
  );
}

/* ─── Documents ───────────────────────────────────────────────────── */

function DocumentPdf({
  title,
  version,
  type,
  contentMd,
  generatedAt,
}: {
  title: string;
  version: number;
  type: string;
  contentMd: string;
  generatedAt: string;
}) {
  const blocks = parseMarkdown(contentMd);
  const typeLabel =
    type === "convention"
      ? "Convention"
      : type === "reglement"
      ? "Règlement intérieur"
      : type === "livret"
      ? "Livret d'accueil"
      : "Document";

  return (
    <Document
      title={`${title} — v${version}`}
      author={LEGAL.legalName}
      creator={LEGAL.legalName}
      subject={typeLabel}
    >
      <Page size="A4" style={s.page}>
        <View style={s.topBar} fixed />
        <View style={s.headerRow} fixed>
          <View>
            <Text style={s.brand}>{LEGAL.brand}</Text>
            <Text style={s.brandSub}>
              {LEGAL.address.street} — {LEGAL.address.postalCode}{" "}
              {LEGAL.address.city}
            </Text>
            <Text style={s.brandSub}>
              SIRET {LEGAL.siret} · NDA {LEGAL.trainingActivityNumber} ·
              Qualiopi {LEGAL.qualiopiNumber}
            </Text>
          </View>
          <View>
            <Text style={s.meta}>{typeLabel}</Text>
            <Text style={s.meta}>
              Version {version} · Édité le {generatedAt}
            </Text>
          </View>
        </View>

        <Text style={s.title}>{title}</Text>
        <View style={s.underline} />

        <MarkdownPdf blocks={blocks} />

        {/* Cartouche signatures pour la convention seulement */}
        {type === "convention" && (
          <View style={s.signatures} wrap={false}>
            <View style={s.signBlock}>
              <Text style={s.bold}>Pour l'organisme</Text>
              <Text>{LEGAL.director}</Text>
              <Text>Président — {LEGAL.legalName}</Text>
              <Text style={{ marginTop: 36 }}>Cachet et signature</Text>
            </View>
            <View style={s.signBlock}>
              <Text style={s.bold}>Le bénéficiaire</Text>
              <Text>Nom, prénom :</Text>
              <Text style={{ marginTop: 36 }}>Date et signature</Text>
            </View>
          </View>
        )}

        <Text
          style={s.footer}
          render={({ pageNumber, totalPages }) =>
            `${LEGAL.legalName} · SIRET ${LEGAL.siret} · NDA ${LEGAL.trainingActivityNumber} · ${typeLabel} v${version} · Page ${pageNumber} / ${totalPages}`
          }
          fixed
        />
      </Page>
    </Document>
  );
}

/* ─── Route handler ──────────────────────────────────────────────── */

export async function GET(
  _req: NextRequest,
  { params }: { params: { id: string } }
) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "Non authentifié" }, { status: 401 });
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("role, disabled")
    .eq("id", user.id)
    .single();
  if (!profile || profile.disabled || !["admin", "super_admin"].includes(profile.role)) {
    return NextResponse.json({ error: "Accès refusé" }, { status: 403 });
  }

  const { data: doc, error } = await supabase
    .from("onboarding_documents")
    .select("id, type, title, content_md, version")
    .eq("id", params.id)
    .single();
  if (error || !doc) {
    return NextResponse.json({ error: "Document introuvable" }, { status: 404 });
  }

  const generatedAt = new Intl.DateTimeFormat("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(new Date());

  const buffer = await renderToBuffer(
    <DocumentPdf
      title={doc.title}
      version={doc.version}
      type={doc.type}
      contentMd={doc.content_md}
      generatedAt={generatedAt}
    />
  );

  const slug = doc.type;
  const filename = `${slug}-v${doc.version}-${LEGAL.brand
    .toLowerCase()
    .replace(/\s+/g, "-")}.pdf`;

  return new NextResponse(buffer as any, {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "private, no-store",
    },
  });
}
