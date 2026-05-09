// =====================================================================
// PDF "Preuves de communication" — toutes les conversations d'un user
// Réutilise les pieces de conversation-pdf.tsx pour cohérence visuelle.
// =====================================================================
import React from "react";
import { Document, Page, Text, View, StyleSheet } from "@react-pdf/renderer";
import {
  PDF_COLORS,
  pdfStyles as s,
  formatDateLong,
  formatDayKey,
  formatTime,
  roleLabel,
  conversationKindLabel,
  MessageBlock,
  type PdfData,
  type PdfMessage,
  type PdfParticipant,
} from "@/lib/pdf/conversation-pdf";

// Styles spécifiques au multi-PDF (cover page + section header)
const ms = StyleSheet.create({
  // Cover page
  coverHero: {
    backgroundColor: PDF_COLORS.NAVY,
    color: "white",
    padding: 22,
    borderRadius: 8,
    marginBottom: 16,
  },
  coverEyebrow: {
    fontSize: 9,
    color: PDF_COLORS.SIGNAL,
    letterSpacing: 2,
    textTransform: "uppercase",
    fontWeight: "bold",
    marginBottom: 6,
  },
  coverTitle: {
    fontSize: 24,
    fontWeight: "bold",
    color: "white",
    letterSpacing: -0.4,
    marginBottom: 4,
  },
  coverSubject: {
    fontSize: 14,
    color: "white",
    opacity: 0.9,
    marginTop: 2,
  },

  // Stats grid
  statsGrid: {
    flexDirection: "row",
    gap: 8,
    marginBottom: 18,
  },
  statCard: {
    flex: 1,
    backgroundColor: PDF_COLORS.NAVY_50,
    border: `1pt solid ${PDF_COLORS.NAVY_100}`,
    borderRadius: 6,
    padding: 10,
  },
  statValue: {
    fontSize: 22,
    fontWeight: "bold",
    color: PDF_COLORS.NAVY,
    letterSpacing: -0.3,
  },
  statLabel: {
    fontSize: 8,
    color: PDF_COLORS.SLATE_500,
    textTransform: "uppercase",
    letterSpacing: 0.6,
    fontWeight: "bold",
    marginTop: 2,
  },

  // Table of contents
  tocTitle: {
    fontSize: 11,
    fontWeight: "bold",
    color: PDF_COLORS.NAVY,
    marginTop: 6,
    marginBottom: 8,
    letterSpacing: 0.4,
    textTransform: "uppercase",
  },
  tocRow: {
    flexDirection: "row",
    paddingVertical: 6,
    borderBottom: `0.5pt solid ${PDF_COLORS.NAVY_100}`,
  },
  tocIndex: {
    width: 22,
    fontSize: 9,
    fontWeight: "bold",
    color: PDF_COLORS.SLATE_500,
  },
  tocTitleText: {
    flex: 1,
    fontSize: 10,
    color: PDF_COLORS.SLATE_900,
  },
  tocMeta: {
    width: 80,
    textAlign: "right",
    fontSize: 8,
    color: PDF_COLORS.SLATE_500,
  },

  // Section header (per conv)
  convSectionHero: {
    backgroundColor: PDF_COLORS.NAVY_50,
    border: `1pt solid ${PDF_COLORS.NAVY_100}`,
    borderLeft: `3pt solid ${PDF_COLORS.SIGNAL}`,
    borderRadius: 4,
    padding: 10,
    marginBottom: 10,
  },
  convSectionEyebrow: {
    fontSize: 8,
    color: PDF_COLORS.SLATE_500,
    textTransform: "uppercase",
    letterSpacing: 0.6,
    fontWeight: "bold",
  },
  convSectionTitle: {
    fontSize: 14,
    fontWeight: "bold",
    color: PDF_COLORS.NAVY,
    marginTop: 2,
    letterSpacing: -0.2,
  },
  convSectionMeta: {
    fontSize: 9,
    color: PDF_COLORS.SLATE_700,
    marginTop: 4,
    lineHeight: 1.4,
  },

  // Day separator (réutilisé)
  dayDivider: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 8,
  },
  dayLine: { flex: 1, height: 0.5, backgroundColor: PDF_COLORS.NAVY_100 },
  dayLabel: {
    fontSize: 8,
    fontWeight: "bold",
    textTransform: "uppercase",
    letterSpacing: 1,
    color: PDF_COLORS.SLATE_500,
    paddingHorizontal: 8,
  },

  emptyConv: {
    fontSize: 9,
    color: PDF_COLORS.SLATE_500,
    fontStyle: "italic",
    paddingVertical: 8,
    textAlign: "center",
  },
});

export interface MultiPdfData {
  /** Utilisateur cible (formateur ou stagiaire dont on extrait les conv) */
  targetUser: PdfParticipant;
  /** Liste des conversations à inclure (chacune déjà préparée pour le PDF). */
  conversations: PdfData[];
  generatedAt: string;
  generatedBy: string;
}

/** Bucket par jour pour les séparateurs */
function bucketByDay(messages: PdfMessage[]) {
  const buckets: { dayKey: string; label: string; messages: PdfMessage[] }[] =
    [];
  for (const m of messages) {
    const k = formatDayKey(m.created_at);
    const last = buckets[buckets.length - 1];
    if (last && last.dayKey === k) last.messages.push(m);
    else
      buckets.push({
        dayKey: k,
        label: formatDateLong(m.created_at),
        messages: [m],
      });
  }
  return buckets;
}

export function MultiConversationPDF({ data }: { data: MultiPdfData }) {
  const { targetUser, conversations, generatedAt, generatedBy } = data;

  const totalConvs = conversations.length;
  const totalMessages = conversations.reduce(
    (sum, c) => sum + c.messages.length,
    0
  );
  const totalAttachments = conversations.reduce(
    (sum, c) =>
      sum +
      c.messages.reduce((sm, m) => sm + (m.attachments?.length ?? 0), 0),
    0
  );

  // Plage de date globale
  let firstDate: string | null = null;
  let lastDate: string | null = null;
  for (const c of conversations) {
    if (c.messages.length === 0) continue;
    const f = c.messages[0].created_at;
    const l = c.messages[c.messages.length - 1].created_at;
    if (!firstDate || new Date(f).getTime() < new Date(firstDate).getTime())
      firstDate = f;
    if (!lastDate || new Date(l).getTime() > new Date(lastDate).getTime())
      lastDate = l;
  }
  const dateRange = (() => {
    if (!firstDate || !lastDate) return "Aucun message";
    if (formatDayKey(firstDate) === formatDayKey(lastDate))
      return formatDateLong(firstDate);
    return `Du ${formatDateLong(firstDate)} au ${formatDateLong(lastDate)}`;
  })();

  const targetName =
    targetUser.full_name ?? targetUser.email ?? "Utilisateur";

  return (
    <Document
      title={`Preuves de communication — ${targetName}`}
      author="MA FORMATION TRANSPORT"
      subject="Preuves de communication"
      creator="MA FORMATION TRANSPORT"
    >
      {/* ── COVER PAGE ─────────────────────────────────────────── */}
      <Page size="A4" style={s.page}>
        <View style={s.topBar} fixed />
        <View style={s.brandRow} fixed>
          <Text style={s.brandTitle}>MA FORMATION TRANSPORT</Text>
          <Text style={s.brandSub}>Preuves de communication</Text>
        </View>

        {/* Hero */}
        <View style={ms.coverHero}>
          <Text style={ms.coverEyebrow}>Audit Qualiopi</Text>
          <Text style={ms.coverTitle}>Preuves de communication</Text>
          <Text style={ms.coverSubject}>
            Toutes les communications électroniques de{" "}
            <Text style={{ fontWeight: "bold" }}>{targetName}</Text> (
            {roleLabel(targetUser.role)})
          </Text>
        </View>

        {/* Stats */}
        <View style={ms.statsGrid}>
          <View style={ms.statCard}>
            <Text style={ms.statValue}>{totalConvs}</Text>
            <Text style={ms.statLabel}>Conversations</Text>
          </View>
          <View style={ms.statCard}>
            <Text style={ms.statValue}>{totalMessages}</Text>
            <Text style={ms.statLabel}>Messages</Text>
          </View>
          <View style={ms.statCard}>
            <Text style={ms.statValue}>{totalAttachments}</Text>
            <Text style={ms.statLabel}>Pièces jointes</Text>
          </View>
        </View>

        <Text style={s.intro}>
          Ce document constitue une preuve formelle des échanges électroniques
          intervenus entre {targetName} et l&apos;ensemble des participants
          (formateurs, équipe administrative, autres stagiaires) sur la
          plateforme MA FORMATION TRANSPORT, conformément aux exigences de
          traçabilité Qualiopi.
        </Text>

        {/* Métadonnées */}
        <View style={s.summaryCard}>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Sujet</Text>
            <Text style={s.summaryValue}>
              {targetName} — {targetUser.email}
            </Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Rôle</Text>
            <Text style={s.summaryValue}>{roleLabel(targetUser.role)}</Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Période</Text>
            <Text style={s.summaryValue}>{dateRange}</Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Généré le</Text>
            <Text style={s.summaryValue}>
              {formatDateLong(generatedAt)} à {formatTime(generatedAt)}
            </Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Généré par</Text>
            <Text style={s.summaryValue}>{generatedBy}</Text>
          </View>
        </View>

        {/* Table des matières */}
        <Text style={ms.tocTitle}>
          Sommaire — {totalConvs} conversation{totalConvs > 1 ? "s" : ""}
        </Text>
        {conversations.length === 0 ? (
          <Text style={s.intro}>Aucune conversation à présenter.</Text>
        ) : (
          conversations.map((c, idx) => (
            <View key={c.conversation.id} style={ms.tocRow}>
              <Text style={ms.tocIndex}>{idx + 1}.</Text>
              <Text style={ms.tocTitleText}>
                {c.conversation.title}
                {"  "}
                <Text style={{ color: PDF_COLORS.SLATE_500 }}>
                  ({conversationKindLabel(c.conversation)})
                </Text>
              </Text>
              <Text style={ms.tocMeta}>
                {c.messages.length} msg
              </Text>
            </View>
          ))
        )}

        {/* Footer */}
        <View style={s.footer} fixed>
          <Text>
            <Text style={s.footerBrand}>MA FORMATION TRANSPORT</Text>
            {" — "}Preuves de communication · {targetName}
          </Text>
          <Text
            render={({ pageNumber, totalPages }) =>
              `Page ${pageNumber} / ${totalPages}`
            }
          />
        </View>
      </Page>

      {/* ── UNE PAGE PAR CONVERSATION ──────────────────────────── */}
      {conversations.map((conv, idx) => (
        <Page
          key={conv.conversation.id}
          size="A4"
          style={s.page}
        >
          <View style={s.topBar} fixed />
          <View style={s.brandRow} fixed>
            <Text style={s.brandTitle}>MA FORMATION TRANSPORT</Text>
            <Text style={s.brandSub}>
              Preuves de communication · {targetName}
            </Text>
          </View>

          {/* En-tête de section */}
          <View style={ms.convSectionHero}>
            <Text style={ms.convSectionEyebrow}>
              Conversation {idx + 1} sur {totalConvs} ·{" "}
              {conversationKindLabel(conv.conversation)}
            </Text>
            <Text style={ms.convSectionTitle}>
              {conv.conversation.title}
            </Text>
            <Text style={ms.convSectionMeta}>
              {conv.participants.length} participant
              {conv.participants.length > 1 ? "s" : ""} ·{" "}
              {conv.messages.length} message
              {conv.messages.length > 1 ? "s" : ""}
              {conv.truncated && ` (sur ${conv.totalMessageCount} au total)`}
            </Text>
            <Text style={ms.convSectionMeta}>
              <Text style={{ fontWeight: "bold" }}>Participants : </Text>
              {conv.participants
                .map((p) => `${p.full_name ?? p.email} (${roleLabel(p.role)})`)
                .join(", ")}
            </Text>
          </View>

          {/* Bandeau troncature local */}
          {conv.truncated && (
            <View style={s.truncBanner}>
              <Text>
                Cette conversation contient {conv.totalMessageCount} messages
                au total. Seuls les {conv.messages.length} messages les plus
                récents sont reproduits ici.
              </Text>
            </View>
          )}

          {/* Messages */}
          {conv.messages.length === 0 ? (
            <Text style={ms.emptyConv}>
              Aucun message dans cette conversation.
            </Text>
          ) : (
            bucketByDay(conv.messages).map((bucket) => (
              <View key={bucket.dayKey} wrap={false}>
                <View style={ms.dayDivider}>
                  <View style={ms.dayLine} />
                  <Text style={ms.dayLabel}>{bucket.label}</Text>
                  <View style={ms.dayLine} />
                </View>
                {bucket.messages.map((m) => {
                  const profMap: Record<string, PdfParticipant> = {};
                  for (const p of conv.participants) profMap[p.user_id] = p;
                  return (
                    <MessageBlock
                      key={m.id}
                      message={m}
                      profileMap={profMap}
                      allMessages={conv.messages}
                    />
                  );
                })}
              </View>
            ))
          )}

          {/* Footer */}
          <View style={s.footer} fixed>
            <Text>
              <Text style={s.footerBrand}>MA FORMATION TRANSPORT</Text>
              {" — "}Preuves de communication · {targetName}
            </Text>
            <Text
              render={({ pageNumber, totalPages }) =>
                `Page ${pageNumber} / ${totalPages}`
              }
            />
          </View>
        </Page>
      ))}
    </Document>
  );
}
