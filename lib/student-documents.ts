/**
 * Configuration partagée des documents importés par le stagiaire
 * (motifs, formats acceptés, taille max, type de fichier). Pure & testable,
 * utilisée côté client (validation/UI) ET côté serveur (validation stricte).
 */

export const MAX_DOC_SIZE = 10 * 1024 * 1024; // 10 Mo

// ── Motifs prédéfinis ────────────────────────────────────────────────
export const DOC_REASONS = [
  { key: "justificatif_absence", label: "Justificatif d'absence" },
  { key: "rapport_stage", label: "Rapport de stage" },
  { key: "convention_stage", label: "Convention de stage" },
  { key: "administratif", label: "Document administratif" },
  { key: "piece_identite", label: "Pièce d'identité" },
  { key: "attestation", label: "Attestation" },
  { key: "certificat_medical", label: "Certificat médical" },
  { key: "contrat", label: "Contrat" },
  { key: "pedagogique", label: "Document pédagogique" },
  { key: "excel", label: "Fichier Excel" },
  { key: "autres", label: "Autres" },
] as const;

export type DocReasonKey = (typeof DOC_REASONS)[number]["key"];

export function reasonLabel(
  key: string,
  customReason?: string | null
): string {
  if (key === "autres") return customReason?.trim() || "Autres";
  return DOC_REASONS.find((r) => r.key === key)?.label ?? key;
}

export function isValidReason(key: string): boolean {
  return DOC_REASONS.some((r) => r.key === key);
}

// ── Types de fichiers ────────────────────────────────────────────────
export type FileKind = "pdf" | "word" | "excel" | "image" | "other";

export const ACCEPTED_EXTENSIONS = [
  ".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png", ".xls", ".xlsx",
] as const;

/** Attribut `accept` pour <input type="file">. */
export const ACCEPT_ATTR = [
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "image/jpeg",
  "image/png",
  "application/vnd.ms-excel",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  ...ACCEPTED_EXTENSIONS,
].join(",");

const EXT_KIND: Record<string, FileKind> = {
  pdf: "pdf",
  doc: "word",
  docx: "word",
  jpg: "image",
  jpeg: "image",
  png: "image",
  xls: "excel",
  xlsx: "excel",
};

export function extOf(fileName: string): string {
  const i = fileName.lastIndexOf(".");
  return i >= 0 ? fileName.slice(i + 1).toLowerCase() : "";
}

export function fileKind(fileName: string): FileKind {
  return EXT_KIND[extOf(fileName)] ?? "other";
}

/** Validation par extension (source de vérité : la liste blanche). */
export function isAcceptedFile(fileName: string): boolean {
  return extOf(fileName) in EXT_KIND;
}

export function formatBytes(bytes: number): string {
  if (!bytes || bytes < 0) return "0 o";
  const units = ["o", "Ko", "Mo", "Go"];
  const i = Math.min(units.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)));
  const val = bytes / Math.pow(1024, i);
  const str = i === 0 ? String(Math.round(val)) : String(Math.round(val * 10) / 10);
  return `${str} ${units[i]}`;
}

// ── Statuts ──────────────────────────────────────────────────────────
export const DOC_STATUS = {
  recu: { label: "Reçu", tone: "navy" },
  en_attente: { label: "En attente", tone: "gold" },
  valide: { label: "Validé", tone: "success" },
  refuse: { label: "Refusé", tone: "rose" },
} as const;

export type DocStatus = keyof typeof DOC_STATUS;
