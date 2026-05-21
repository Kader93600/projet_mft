import clsx, { type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: string | Date) {
  return new Date(date).toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

/**
 * Date + heure (HH:mm), fuseau Europe/Paris.
 * Utilisé là où l'horodatage précis compte (journal d'audit). Le fuseau est figé
 * car la page est rendue côté serveur (UTC en prod) : sans cela l'heure serait décalée.
 */
export function formatDateTime(date: string | Date) {
  return new Date(date).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    timeZone: "Europe/Paris",
  });
}

export function scoreColor(pct: number) {
  if (pct >= 80) return "text-emerald-600";
  if (pct >= 60) return "text-gold-600";
  return "text-rose-600";
}

export function initials(name?: string | null) {
  if (!name) return "?";
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0]?.toUpperCase() ?? "")
    .join("");
}

/** Map un code de bloc vers une tonalité visuelle cohérente */
export function blocTone(code?: string): "bc1" | "bc2" | "bc3" | "navy" {
  if (code === "BC1") return "bc1";
  if (code === "BC2") return "bc2";
  if (code === "BC3") return "bc3";
  return "navy";
}
