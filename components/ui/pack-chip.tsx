/**
 * Petit badge « pack » (Initial / Medium / Premium) — repérage visuel rapide
 * depuis les listes admin (dossiers, leads). Composant pur, réutilisable.
 */
const PACK_STYLES: Record<string, { cls: string; label: string }> = {
  initial: {
    cls: "bg-signal-100/60 border-signal-300 text-signal-800",
    label: "Initial",
  },
  medium: {
    cls: "bg-brand-50 border-brand-200 text-brand-700",
    label: "Medium",
  },
  premium: {
    cls: "bg-amber-50 border-amber-200 text-amber-700",
    label: "Premium",
  },
};

export function PackChip({ pack }: { pack: string | null | undefined }) {
  const s = PACK_STYLES[pack ?? "initial"] ?? PACK_STYLES.initial;
  return (
    <span
      className={`inline-flex items-center px-1.5 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-[0.10em] border ${s.cls}`}
      title={`Pack ${s.label}`}
    >
      {s.label}
    </span>
  );
}
