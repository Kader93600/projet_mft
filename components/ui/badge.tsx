import { cn } from "@/lib/utils";

type Tone = "navy" | "gold" | "success" | "slate" | "rose" | "bc1" | "bc2" | "bc3";

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
    navy: "bg-navy-50 text-navy-700 border-navy-100",
    gold: "bg-gold-50 text-gold-800 border-gold-200",
    success: "bg-emerald-50 text-emerald-700 border-emerald-200",
    slate: "bg-slate-100 text-slate-700 border-slate-200",
    rose: "bg-rose-50 text-rose-700 border-rose-200",
    bc1: "bg-navy-50 text-navy-800 border-navy-200",
    bc2: "bg-emerald-50 text-emerald-800 border-emerald-200",
    bc3: "bg-gold-50 text-gold-800 border-gold-300",
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
