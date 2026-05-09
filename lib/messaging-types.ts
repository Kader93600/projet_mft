// ============================================================
// Types partagés du système de messagerie v2
// ============================================================

export type ConversationKind = "dm" | "group";
export type ConversationScope = "admin_team" | "class" | "custom" | null;
export type ParticipantRole = "owner" | "admin" | "member";
export type MessageSenderRole = "student" | "trainer" | "admin";

/** Ligne retournée par list_my_conversations() */
export interface ConversationSummary {
  id: string;
  kind: ConversationKind;
  scope: ConversationScope;
  /** Pour DM : nom de l'autre participant. Pour groupe : title. */
  title: string | null;
  group_id: string | null;
  class_writable: boolean;
  archived_at: string | null;
  pinned_at: string | null;
  muted: boolean;
  last_read_at: string | null;
  last_message_at: string | null;
  last_message_preview: string | null;
  last_message_sender_id: string | null;
  unread_count: number;
  participants_count: number;
  /** Pour DM : id de l'autre participant. */
  other_participant_id: string | null;
  other_participant_name: string | null;
  other_participant_role: string | null;
}

/** Ligne `messages` enrichie pour l'UI */
export interface MessageRow {
  id: string;
  conversation_id: string;
  sender_id: string;
  sender_role: MessageSenderRole;
  body: string;
  reply_to_id: string | null;
  edited_at: string | null;
  deleted_at: string | null;
  created_at: string;
  read_at: string | null; // legacy column
}

/** Profil minimal pour l'affichage (avatar, nom, rôle) */
export interface MinimalProfile {
  id: string;
  full_name: string | null;
  email: string;
  role: string;
}

/** Destinataire potentiel pour la modal "Nouveau message" */
export interface RecipientOption {
  /** 'user' = DM avec une personne · 'class' = conv de groupe sur une classe · 'admin_team' = pseudo-groupe */
  kind: "user" | "class" | "admin_team";
  user_id: string | null;
  group_id: string | null;
  display_name: string;
  user_role: string | null;
  /** Texte secondaire pour discrimination visuelle. */
  subtitle: string | null;
}

/** État d'un participant à une conversation (pour resolver les avatars dans l'UI) */
export interface ConversationParticipantInfo {
  conversation_id: string;
  user_id: string;
  role_in_conv: ParticipantRole;
  joined_at: string;
  last_read_at: string | null;
  pinned_at: string | null;
  muted: boolean;
  archived_at: string | null;
}

/** Participant + profil minimal + dernier read — pour les read receipts */
export interface ParticipantWithReadState {
  user_id: string;
  full_name: string | null;
  email: string;
  role: string;
  last_read_at: string | null;
}

/** Utilisateur en train de taper (état UI éphémère, alimenté par Realtime broadcast) */
export interface TypingUser {
  user_id: string;
  name: string;
  /** Timestamp d'expiration côté client (Date.now() + 5s typiquement). */
  expires_at: number;
}

/** Pièce jointe d'un message (lecture seule côté UI). */
export interface MessageAttachment {
  id: string;
  message_id: string;
  storage_path: string;
  mime_type: string;
  size_bytes: number;
  original_name: string;
  width: number | null;
  height: number | null;
  created_at: string;
}

/** Réaction emoji posée par un user sur un message. */
export interface MessageReaction {
  message_id: string;
  user_id: string;
  emoji: string;
  created_at: string;
}

/** Réactions agrégées pour l'affichage : 1 entrée par emoji, avec compteur et user_ids. */
export interface ReactionAggregate {
  emoji: string;
  count: number;
  user_ids: string[];
  /** Vrai si l'utilisateur courant a posé cet emoji. */
  mine: boolean;
}
