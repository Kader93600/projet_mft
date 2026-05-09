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
const NAVY = "#0E1240";
const NAVY_700 = "#1E26B0";
const BRAND = "#2530D9";
const SIGNAL = "#9FE220";
const SIGNAL_DARK = "#609015";
const EMERALD = "#059669";
const EMERALD_BG = "#ECFDF5";
const ROSE = "#E11D48";
const ROSE_BG = "#FEF2F2";
const GOLD_BG = "#F4FCE0";
const SLATE_400 = "#94A3B8";
const SLATE_500 = "#64748b";
const SLATE_700 = "#334155";
const SLATE_900 = "#0f172a";
const NAVY_50 = "#f8fafc";
const NAVY_100 = "#EEF0F7";
const SKY_BG = "#EFF6FF";
const SKY = "#0369A1";

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
const s = StyleSheet.create({
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
function formatDateLong(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

function formatDayKey(iso: string): string {
  const d = new Date(iso);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

function formatTime(iso: string): string {
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

function roleLabel(role: string): string {
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
      return s.roleStudent;
    case "trainer":
      return s.roleTrainer;
    default:
      return s.roleAdmin;
  }
}

function conversationKindLabel(c: PdfConversation): string {
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
      <Page size="A4" style={s.page}>
        <View style={s.topBar} fixed />
        <View style={s.brandRow} fixed>
          <Text style={s.brandTitle}>MA FORMATION TRANSPORT</Text>
          <Text style={s.brandSub}>Export de conversation</Text>
        </View>

        {/* Titre */}
        <Text style={s.h1}>Export de conversation</Text>
        <Text style={s.intro}>
          Ce document constitue une preuve formelle des échanges électroniques
          intervenus dans la conversation indiquée ci-dessous, conformément au
          parcours pédagogique du stagiaire et aux exigences de traçabilité
          Qualiopi.
        </Text>

        {/* Résumé conv */}
        <View style={s.summaryCard}>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Titre</Text>
            <Text style={s.summaryValue}>{data.conversation.title}</Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Type</Text>
            <Text style={s.summaryValue}>
              {conversationKindLabel(data.conversation)}
            </Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Participants</Text>
            <Text style={s.summaryValue}>
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
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Période</Text>
            <Text style={s.summaryValue}>{dateRange}</Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Messages</Text>
            <Text style={s.summaryValue}>
              {data.totalMessageCount}
              {data.truncated
                ? ` — ${data.messages.length} affichés dans cet export (limite atteinte)`
                : ""}
            </Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Généré le</Text>
            <Text style={s.summaryValue}>
              {formatDateLong(data.generatedAt)} à {formatTime(data.generatedAt)}
            </Text>
          </View>
          <View style={s.summaryRow}>
            <Text style={s.summaryLabel}>Généré par</Text>
            <Text style={s.summaryValue}>{data.generatedBy}</Text>
          </View>
        </View>

        {/* Bandeau troncature si applicable */}
        {data.truncated && (
          <View style={s.truncBanner}>
            <Text>
              Cette conversation contient {data.totalMessageCount} messages au
              total. Pour des raisons de lisibilité du document, seuls les{" "}
              {data.messages.length} messages les plus récents sont reproduits
              ci-après. La copie intégrale est disponible sur demande auprès
              de l&apos;organisme de formation.
            </Text>
          </View>
        )}

        {/* Section échanges */}
        <Text style={s.sectionHeader}>Historique des échanges</Text>

        {data.messages.length === 0 ? (
          <Text style={s.intro}>Aucun message dans cette conversation.</Text>
        ) : (
          buckets.map((bucket) => (
            <View key={bucket.dayKey} wrap={false}>
              <View style={s.dayDivider}>
                <View style={s.dayLine} />
                <Text style={s.dayLabel}>{bucket.label}</Text>
                <View style={s.dayLine} />
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
        <View style={s.footer} fixed>
          <Text>
            <Text style={s.footerBrand}>MA FORMATION TRANSPORT</Text>
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
function MessageBlock({
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
    s.msg,
    ...(message.is_pinned ? [s.msgPinned] : []),
    ...(message.deleted_at ? [s.msgDeleted] : []),
  ];

  return (
    <View style={containerStyle} wrap={false}>
      {/* Header : sender + role + time + flags */}
      <View style={s.msgHeader}>
        <Text style={s.senderName}>{senderName}</Text>
        <Text style={[s.rolePill, roleStyle(message.sender_role)]}>
          {roleLabel(message.sender_role)}
        </Text>
        {message.is_pinned && <Text style={s.pinnedTag}>· Épinglé</Text>}
        <Text style={s.timestamp}>
          {formatTime(message.created_at)}
        </Text>
      </View>

      {/* Reply preview */}
      {replyTarget && (
        <View style={s.replyPreview}>
          <Text style={s.replyLabel}>
            Réponse à{" "}
            {replySender?.full_name ?? replySender?.email ?? "Utilisateur"}
          </Text>
          <Text style={s.replyBody}>
            {replyTarget.deleted_at
              ? "Message supprimé"
              : truncate(replyTarget.body, 200)}
          </Text>
        </View>
      )}

      {/* Body */}
      {message.deleted_at ? (
        <Text style={[s.body, s.bodyDeleted]}>Message supprimé</Text>
      ) : message.body && message.body.trim().length > 0 ? (
        <Text style={s.body}>{message.body}</Text>
      ) : null}

      {message.edited_at && !message.deleted_at && (
        <Text style={s.edited}>Modifié le {formatTime(message.edited_at)}</Text>
      )}

      {/* Attachments */}
      {message.attachments.length > 0 && (
        <View style={s.attBlock}>
          <Text style={s.attTitle}>
            Pièces jointes ({message.attachments.length})
          </Text>
          {message.attachments.map((a, i) => (
            <Text key={i} style={s.attRow}>
              • {a.original_name} ({a.mime_type}, {formatBytes(a.size_bytes)})
            </Text>
          ))}
        </View>
      )}

      {/* Réactions */}
      {message.reactions.length > 0 && (
        <View style={s.reactBlock}>
          {message.reactions.map((r, i) => (
            <Text key={i} style={s.reactPill}>
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
