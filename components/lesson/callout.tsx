import {
  Info,
  AlertTriangle,
  Lightbulb,
  CheckCircle2,
  XCircle,
  Scale,
} from "lucide-react";
import { cn } from "@/lib/utils";

type Variant = "info" | "warn" | "tip" | "success" | "danger" | "law";

const STYLES: Record<
  Variant,
  { icon: any; bg: string; border: string; text: string; title: string }
> = {
  info: {
    icon: Info,
    bg: "bg-navy-50",
    border: "border-navy-200",
    text: "text-navy-900",
    title: "text-navy-900",
  },
  tip: {
    icon: Lightbulb,
    bg: "bg-gold-50",
    border: "border-gold-200",
    text: "text-navy-900",
    title: "text-gold-800",
  },
  warn: {
    icon: AlertTriangle,
    bg: "bg-amber-50",
    border: "border-amber-200",
    text: "text-amber-900",
    title: "text-amber-900",
  },
  danger: {
    icon: XCircle,
    bg: "bg-rose-50",
    border: "border-rose-200",
    text: "text-rose-900",
    title: "text-rose-900",
  },
  success: {
    icon: CheckCircle2,
    bg: "bg-emerald-50",
    border: "border-emerald-200",
    text: "text-emerald-900",
    title: "text-emerald-900",
  },
  law: {
    icon: Scale,
    bg: "bg-slate-50",
    border: "border-slate-300",
    text: "text-slate-800",
    title: "text-slate-900",
  },
};

export function Callout({
  variant = "info",
  title,
  children,
}: {
  variant?: Variant;
  title?: string;
  children: React.ReactNode;
}) {
  const s = STYLES[variant];
  const Icon = s.icon;
  return (
    <aside
      role="note"
      className={cn(
        "my-6 rounded-2xl border p-4 md:p-5 flex items-start gap-3",
        s.bg,
        s.border,
        s.text
      )}
    >
      <div className="shrink-0 mt-0.5">
        <Icon className="h-5 w-5" />
      </div>
      <div className="flex-1 min-w-0">
        {title && (
          <div className={cn("font-semibold mb-1", s.title)}>{title}</div>
        )}
        <div className="text-sm leading-relaxed">{children}</div>
      </div>
    </aside>
  );
}
