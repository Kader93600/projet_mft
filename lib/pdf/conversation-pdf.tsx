// =====================================================================
// PDF "Export de conversation" — preuve de communication formateur/stagiaire
// Charte alignée sur scripts/generate-content-audit-pdf.tsx
// =====================================================================
import React from "react";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
} from "@react-pdf/renderer";

// ─── Charte couleur (DESIGN.md) ───────────────────────────────
export const PDF_COLORS = {
  NAVY: "#0E1240",
  NAVY_700: "#1E26B0",
  BRAND: "#2530D9",
  SIGNAL: "#9FE220",
  SIGNAL_DARK: "#609015",
  EMERALD: "#059669",
  EMERALD_BG: "#ECFDF5",
  ROSE: "#E11D48",
  ROSE_BG: "#FEF2F2",
  GOLD_BG: "#F4FCE0",
  SLATE_400: "#94A3B8",
  SLATE_500: "#64748b",
  SLATE_700: "#334155",
  SLATE_900: "#0f172a",
  NAVY_50: "#f8fafc",
  NAVY_100: "#EEF0F7",
  SKY_BG: "#EFF6FF",
  SKY: "#0369A1",
} as const;

const NAVY = PDF_COLORS.NAVY;
const NAVY_700 = PDF_COLORS.NAVY_700;
const SIGNAL = PDF_COLORS.SIGNAL;
const SIGNAL_DARK = PDF_COLORS.SIGNAL_DARK;
const EMERALD = PDF_COLORS.EMERALD;
const EMERALD_BG = PDF_COLORS.EMERALD_BG;
const ROSE = PDF_COLORS.ROSE;
const ROSE_BG = PDF_COLORS.ROSE_BG;
const GOLD_BG = PDF_COLORS.GOLD_BG;
const SLATE_400 = PDF_COLORS.SLATE_400;
const SLATE_500 = PDF_COLORS.SLATE_500;
const SLATE_700 = PDF_COLORS.SLATE_700;
const SLATE_900 = PDF_COLORS.SLATE_900;
const NAVY_50 = PDF_COLORS.NAVY_50;
const NAVY_100 = PDF_COLORS.NAVY_100;
const SKY_BG = PDF_COLORS.SKY_BG;
const SKY = PDF_COLORS.SKY;

// ─── Types ────────────────────────────────────────────────────
export interface PdfConversation {
  id: string;
  kind: "dm" | "group";
  scope: "admin_team" | "class" | "custom" | null;
  title: string;
  created_at: string;
}

export interface PdfParticipant {
  user_id: string;
  full_name: string | null;
  email: string;
  role: string;
}

export interface PdfMessage {
  id: string;
  sender_id: string;
  sender_role: "student" | "trainer" | "admin";
  body: string;
  reply_to_id: string | null;
  edited_at: string | null;
  deleted_at: string | null;
  created_at: string;
  is_pinned: boolean;
  attachments: { mime_type: string; original_name: string; size_bytes: number }[];
  reactions: { emoji: string; count: number }[];
}

export interface PdfData {
  conversation: PdfConversation;
  participants: PdfParticipant[];
  messages: PdfMessage[];
  generatedAt: string;
  generatedBy: string;
  truncated: boolean;
  totalMessageCount: number;
}

// ─── Styles ────────────────────────────────────────────────────
export const pdfStyles = StyleSheet.create({
  page: {
    paddingTop: 36,
    paddingBottom: 60,
    paddingHorizontal: 40,
    fontFamily: "Helvetica",
    fontSize: 9.5,
    color: SLATE_900,
  },
  topBar: { height: 4, backgroundColor: SIGNAL, marginBottom: 14 },
  brandRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 6,
  },
  brandTitle: {
    fontSize: 12,
    fontWeight: "bold",
    color: NAVY,
    letterSpacing: 0.4,
  },
  brandSub: {
    fontSize: 8,
    color: SLATE_500,
    textTransform: "uppercase",
    letterSpacing: 1.2,
  },

  h1: {
    fontSize: 20,
    fontWeight: "bold",
    color: NAVY,
    marginTop: 14,
    marginBottom: 4,
    letterSpacing: -0.3,
  },
  intro: {
    fontSize: 9.5,
    color: SLATE_700,
    lineHeight: 1.55,
    marginBottom: 14,
  },

  // Bloc résumé conv
  summaryCard: {
    backgroundColor: NAVY_50,
    border: `1pt solid ${NAVY_100}`,
    borderRadius: 6,
    padding: 12,
    marginBottom: 18,
  },
  summaryRow: { flexDirection: "row", marginBottom: 4 },
  summaryLabel: {
    width: 110,
    fontSize: 8.5,
    color: SLATE_500,
    textTransform: "uppercase",
    letterSpacing: 0.6,
    fontWeight: "bold",
  },
  summaryValue: { flex: 1, fontSize: 10, color: SLATE_900 },

  // Section header "Échanges"
  sectionHeader: {
    backgroundColor: NAVY,
    color: "white",
    padding: 6,
    borderRadius: 3,
    marginTop: 6,
    marginBottom: 10,
    fontSize: 9,
    fontWeight: "bold",
    letterSpacing: 0.6,
    textTransform: "uppercase",
  },

  // Day separator
  dayDivider: {
    flexDirection: "row",
    alignItems: "center",
    marginVertical: 10,
  },
  dayLine: { flex: 1, height: 0.5, backgroundColor: NAVY_100 },
  dayLabel: {
    fontSize: 8,
    fontWeight: "bold",
    textTransform: "uppercase",
    letterSpacing: 1,
    color: SLATE_500,
    paddingHorizontal: 8,
  },

  // Message card
  msg: {
    border: `0.5pt solid ${NAVY_100}`,
    borderRadius: 5,
    padding: 8,
    marginBottom: 6,
    backgroundColor: "white",
  },
  msgPinned: {
    backgroundColor: GOLD_BG,
    border: `0.5pt solid ${SIGNAL_DARK}`,
  },
  msgDeleted: {
    backgroundColor: ROSE_BG,
    border: `0.5pt solid ${ROSE}`,
  },
  msgHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 4,
  },
  senderName: {
    fontSize: 9.5,
    fontWeight: "bold",
    color: NAVY,
    marginRight: 6,
  },
  rolePill: {
    fontSize: 7,
    fontWeight: "bold",
    paddingHorizontal: 5,
    paddingVertical: 1,
    borderRadius: 2,
    marginRight: 6,
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },
  roleStudent: { backgroundColor: SKY_BG, color: SKY },
  roleTrainer: { backgroundColor: EMERALD_BG, color: EMERALD },
  roleAdmin: { backgroundColor: ROSE_BG, color: ROSE },
  timestamp: {
    fontSize: 7.5,
    color: SLATE_500,
    marginLeft: "auto",
  },
  pinnedTag: {
    fontSize: 7,
    color: SIGNAL_DARK,
    fontWeight: "bold",
    marginLeft: 6,
    textTransform: "uppercase",
    letterSpacing: 0.5,
  },

  // Reply preview
  replyPreview: {
    borderLeft: `1.5pt solid ${SIGNAL}`,
    paddingLeft: 6,
    marginBottom: 4,
    backgroundColor: NAVY_50,
    paddingVertical: 3,
    paddingRight: 6,
    borderTopRightRadius: 3,
    borderBottomRightRadius: 3,
  },
  replyLabel: {
    fontSize: 7,
    color: NAVY_700,
    fontWeight: "bold",
    textTransform: "uppercase",
    letterSpacing: 0.5,
    marginBottom: 1,
  },
  replyBody: { fontSize: 8.5, color: SLATE_700, fontStyle: "italic" },

  // Body
  body: { fontSize: 10, color: SLATE_900, lineHeight: 1.4 },
  bodyDeleted: { fontStyle: "italic", color: SLATE_500 },
  edited: { fontSize: 7.5, color: SLATE_400, fontStyle: "italic", marginTop: 2 },

  // Attachments
  attBlock: { marginTop: 5 },
  attTitle: {
    fontSize: 7.5,
    color: SLATE_500,
    textTransform: "uppercase",
    letterSpacing: 0.6,
    fontWeight: "bold",
    marginBottom: 2,
  },
  attRow: {
    fontSize: 9,
    color: SLATE_700,
    marginLeft: 6,
    marginTop: 1,
  },

  // Reactions
  reactBlock: { marginTop: 5, flexDirection: "row", flexWrap: "wrap", gap: 4 },
  reactPill: {
    fontSize: 8,
    color: NAVY_700,
    backgroundColor: NAVY_50,
    border: `0.5pt solid ${NAVY_100}`,
    paddingHorizontal: 4,
    paddingVertical: 1,
    borderRadius: 3,
    marginRight: 3,
  },

  // Footer
  footer: {
    position: "absolute",
    bottom: 24,
    left: 40,
    right: 40,
    flexDirection: "row",
    justifyContent: "space-between",
    fontSize: 8,
    color: SLATE_400,
    borderTop: `0.5pt solid ${NAVY_100}`,
    paddingTop: 6,
  },
  footerBrand: { color: NAVY, fontWeight: "bold" },

  // Truncation banner
  truncBanner: {
    backgroundColor: GOLD_BG,
    border: `1pt solid ${SIGNAL_DARK}`,
    padding: 8,
    borderRadius: 4,
    marginBottom: 12,
    fontSize: 9,
    color: NAVY_700,
  },
});

// ─── Helpers de format ─────────────────────────────────────────
export function formatDateLong(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

export function formatDayKey(iso: string): string {
  const d = new Date(iso);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

export function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString("fr-FR", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} o`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} Ko`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} Mo`;
}

export function roleLabel(role: string): string {
  switch (role) {
    case "student":
      return "Stagiaire";
    case "trainer":
      return "Formateur";
    case "admin":
    case "super_admin":
      return "Admin";
    default:
      return role;
  }
}

function roleStyle(role: string) {
  switch (role) {
    case "student":
      return pdfStyles.roleStudent;
    case "trainer":
      return pdfStyles.roleTrainer;
    default:
      return pdfStyles.roleAdmin;
  }
}

export function conversationKindLabel(c: PdfConversation): string {
  if (c.kind === "dm") return "Message direct";
  if (c.scope === "admin_team") return "Conversation Équipe admin";
  if (c.scope === "class") return "Conversation de classe";
  return "Conversation de groupe";
}

// ─── Document ─────────────────────────────────────────────────
export function ConversationPDF({ data }: { data: PdfData }) {
  const profByUser: Record<string, PdfParticipant> = {};
  for (const p of data.participants) profByUser[p.user_id] = p;

  // Group messages by day for separators
  const buckets: { dayKey: string; label: string; messages: PdfMessage[] }[] = [];
  for (const m of data.messages) {
    const k = formatDayKey(m.created_at);
    const last = buckets[buckets.length - 1];
    if (last && last.dayKey === k) {
      last.messages.push(m);
    } else {
      buckets.push({
        dayKey: k,
        label: formatDateLong(m.created_at),
        messages: [m],
      });
    }
  }

  const dateRange = (() => {
    if (data.messages.length === 0) return "Aucun message";
    const first = data.messages[0];
    const last = data.messages[data.messages.length - 1];
    if (formatDayKey(first.created_at) === formatDayKey(last.created_at)) {
      return formatDateLong(first.created_at);
    }
    return `Du ${formatDateLong(first.created_at)} au ${formatDateLong(last.created_at)}`;
  })();

  return (
    <Document
      title={`Export de conversation — ${data.conversation.title}`}
      author="MA FORMATION TRANSPORT"
      subject="Preuve de communication"
      creator="MA FORMATION TRANSPORT"
    >
      <Page size="A4" style={pdfStyles.page}>
        <View style={pdfStyles.topBar} fixed />
        <View style={pdfStyles.brandRow} fixed>
          <Text style={pdfStyles.brandTitle}>MA FORMATION TRANSPORT</Text>
          <Text style={pdfStyles.brandSub}>Export de conversation</Text>
        </View>

        {/* Titre */}
        <Text style={pdfStyles.h1}>Export de conversation</Text>
        <Text style={pdfStyles.intro}>
          Ce document constitue une preuve formelle des échanges électroniques
          intervenus dans la conversation indiquée ci-dessous, conformément au
          parcours pédagogique du stagiaire et aux exigences de traçabilité
          Qualiopi.
        </Text>

        {/* Résumé conv */}
        <View style={pdfStyles.summaryCard}>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Titre</Text>
            <Text style={pdfStyles.summaryValue}>{data.conversation.title}</Text>
          </View>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Type</Text>
            <Text style={pdfStyles.summaryValue}>
              {conversationKindLabel(data.conversation)}
            </Text>
          </View>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Participants</Text>
            <Text style={pdfStyles.summaryValue}>
              {data.participants.length === 0
                ? "Aucun"
                : data.participants
                    .map(
                      (p) =>
                        `${p.full_name ?? p.email} (${roleLabel(p.role)})`
                    )
                    .join(", ")}
            </Text>
          </View>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Période</Text>
            <Text style={pdfStyles.summaryValue}>{dateRange}</Text>
          </View>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Messages</Text>
            <Text style={pdfStyles.summaryValue}>
              {data.totalMessageCount}
              {data.truncated
                ? ` — ${data.messages.length} affichés dans cet export (limite atteinte)`
                : ""}
            </Text>
          </View>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Généré le</Text>
            <Text style={pdfStyles.summaryValue}>
              {formatDateLong(data.generatedAt)} à {formatTime(data.generatedAt)}
            </Text>
          </View>
          <View style={pdfStyles.summaryRow}>
            <Text style={pdfStyles.summaryLabel}>Généré par</Text>
            <Text style={pdfStyles.summaryValue}>{data.generatedBy}</Text>
          </View>
        </View>

        {/* Bandeau troncature si applicable */}
        {data.truncated && (
          <View style={pdfStyles.truncBanner}>
            <Text>
              Cette conversation contient {data.totalMessageCount} messages au
              total. Pour des raisons de lisibilité du document, seuls les{" "}
              {data.messages.length} messages les plus récents sont reproduits
              ci-aprèpdfStyles. La copie intégrale est disponible sur demande auprès
              de l&apos;organisme de formation.
            </Text>
          </View>
        )}

        {/* Section échanges */}
        <Text style={pdfStyles.sectionHeader}>Historique des échanges</Text>

        {data.messages.length === 0 ? (
          <Text style={pdfStyles.intro}>Aucun message dans cette conversation.</Text>
        ) : (
          buckets.map((bucket) => (
            <View key={bucket.dayKey} wrap={false}>
              <View style={pdfStyles.dayDivider}>
                <View style={pdfStyles.dayLine} />
                <Text style={pdfStyles.dayLabel}>{bucket.label}</Text>
                <View style={pdfStyles.dayLine} />
              </View>
              {bucket.messages.map((m) => (
                <MessageBlock
                  key={m.id}
                  message={m}
                  profileMap={profByUser}
                  allMessages={data.messages}
                />
              ))}
            </View>
          ))
        )}

        {/* Footer */}
        <View style={pdfStyles.footer} fixed>
          <Text>
            <Text style={pdfStyles.footerBrand}>MA FORMATION TRANSPORT</Text>
            {" — "}Document généré le {new Date(data.generatedAt).toLocaleDateString("fr-FR")}
          </Text>
          <Text
            render={({ pageNumber, totalPages }) =>
              `Page ${pageNumber} / ${totalPages}`
            }
          />
        </View>
      </Page>
    </Document>
  );
}

// ─── Message block ─────────────────────────────────────────────
export function MessageBlock({
  message,
  profileMap,
  allMessages,
}: {
  message: PdfMessage;
  profileMap: Record<string, PdfParticipant>;
  allMessages: PdfMessage[];
}) {
  const sender = profileMap[message.sender_id];
  const senderName = sender?.full_name ?? sender?.email ?? "Utilisateur";
  const replyTarget = message.reply_to_id
    ? allMessages.find((m) => m.id === message.reply_to_id)
    : null;
  const replySender = replyTarget
    ? profileMap[replyTarget.sender_id]
    : null;

  const containerStyle = [
    pdfStyles.msg,
    ...(message.is_pinned ? [pdfStyles.msgPinned] : []),
    ...(message.deleted_at ? [pdfStyles.msgDeleted] : []),
  ];

  return (
    <View style={containerStyle} wrap={false}>
      {/* Header : sender + role + time + flags */}
      <View style={pdfStyles.msgHeader}>
        <Text style={pdfStyles.senderName}>{senderName}</Text>
        <Text style={[pdfStyles.rolePill, roleStyle(message.sender_role)]}>
          {roleLabel(message.sender_role)}
        </Text>
        {message.is_pinned && <Text style={pdfStyles.pinnedTag}>· Épinglé</Text>}
        <Text style={pdfStyles.timestamp}>
          {formatTime(message.created_at)}
        </Text>
      </View>

      {/* Reply preview */}
      {replyTarget && (
        <View style={pdfStyles.replyPreview}>
          <Text style={pdfStyles.replyLabel}>
            Réponse à{" "}
            {replySender?.full_name ?? replySender?.email ?? "Utilisateur"}
          </Text>
          <Text style={pdfStyles.replyBody}>
            {replyTarget.deleted_at
              ? "Message supprimé"
              : truncate(replyTarget.body, 200)}
          </Text>
        </View>
      )}

      {/* Body */}
      {message.deleted_at ? (
        <Text style={[pdfStyles.body, pdfStyles.bodyDeleted]}>Message supprimé</Text>
      ) : message.body && message.body.trim().length > 0 ? (
        <Text style={pdfStyles.body}>{message.body}</Text>
      ) : null}

      {message.edited_at && !message.deleted_at && (
        <Text style={pdfStyles.edited}>Modifié le {formatTime(message.edited_at)}</Text>
      )}

      {/* Attachments */}
      {message.attachments.length > 0 && (
        <View style={pdfStyles.attBlock}>
          <Text style={pdfStyles.attTitle}>
            Pièces jointes ({message.attachments.length})
          </Text>
          {message.attachments.map((a, i) => (
            <Text key={i} style={pdfStyles.attRow}>
              • {a.original_name} ({a.mime_type}, {formatBytes(a.size_bytes)})
            </Text>
          ))}
        </View>
      )}

      {/* Réactions */}
      {message.reactions.length > 0 && (
        <View style={pdfStyles.reactBlock}>
          {message.reactions.map((r, i) => (
            <Text key={i} style={pdfStyles.reactPill}>
              {r.emoji} ×{r.count}
            </Text>
          ))}
        </View>
      )}
    </View>
  );
}

function truncate(text: string, max: number): string {
  if (!text) return "";
  if (text.length <= max) return text;
  return text.slice(0, max - 1) + "…";
}
