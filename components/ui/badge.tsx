import { cn } from "@/lib/utils";

type Tone = "navy" | "gold" | "success" | "slate" | "rose" | "amber" | "bc1" | "bc2" | "bc3";

export function Badge({
  children,
  tone = "navy",
  className,
  size = "md",
}: {
  children: React.ReactNode;
  tone?: Tone;
  className?: string;
  size?: "sm" | "md";
}) {
  const tones: Record<Tone, string> = {
    navy: "bg-navy-50 text-navy-700 border-navy-100 dark:bg-navy-900/50 dark:text-navy-200 dark:border-navy-700/60",
    gold: "bg-gold-50 text-gold-800 border-gold-200 dark:bg-gold-900/40 dark:text-gold-300 dark:border-gold-700/50",
    success: "bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-900/30 dark:text-emerald-300 dark:border-emerald-700/40",
    slate: "bg-slate-100 text-slate-700 border-slate-200 dark:bg-slate-800/60 dark:text-slate-300 dark:border-slate-700",
    rose: "bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-900/30 dark:text-rose-300 dark:border-rose-700/40",
    amber: "bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-500/10 dark:text-amber-300 dark:border-amber-500/30",
    bc1: "bg-navy-50 text-navy-800 border-navy-200 dark:bg-signal-500/15 dark:text-signal-300 dark:border-signal-500/30",
    bc2: "bg-emerald-50 text-emerald-800 border-emerald-200 dark:bg-emerald-900/30 dark:text-emerald-300 dark:border-emerald-700/40",
    bc3: "bg-gold-50 text-gold-800 border-gold-300 dark:bg-gold-900/40 dark:text-gold-300 dark:border-gold-700/50",
  };
  const sizes = {
    sm: "text-[10px] px-1.5 py-0.5",
    md: "text-xs px-2 py-0.5",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 rounded-md border font-semibold tracking-wide uppercase",
        tones[tone],
        sizes[size],
        className
      )}
    >
      {children}
    </span>
  );
}
