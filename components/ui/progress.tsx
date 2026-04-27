import { cn } from "@/lib/utils";

export function ProgressBar({
  value,
  className,
  variant = "navy",
}: {
  value: number;
  className?: string;
  variant?: "navy" | "gold" | "gradient";
}) {
  const v = Math.min(100, Math.max(0, value));
  const fill = {
    navy: "bg-navy-900",
    gold: "bg-gold-500",
    gradient: "bg-gradient-to-r from-navy-800 via-navy-600 to-gold-500",
  }[variant];
  return (
    <div
      className={cn(
        "w-full h-1.5 rounded-full bg-navy-100 overflow-hidden",
        className
      )}
    >
      <div
        className={cn("h-full rounded-full transition-all duration-700 ease-out", fill)}
        style={{ width: `${v}%` }}
      />
    </div>
  );
}

export function RadialProgress({
  value,
  size = 96,
  strokeWidth = 8,
  label,
}: {
  value: number;
  size?: number;
  strokeWidth?: number;
  label?: React.ReactNode;
}) {
  const v = Math.min(100, Math.max(0, value));
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (v / 100) * circumference;
  return (
    <div className="relative inline-flex items-center justify-center">
      <svg width={size} height={size} className="-rotate-90">
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={strokeWidth}
          className="stroke-navy-100 fill-none"
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={strokeWidth}
          className="stroke-navy-900 fill-none transition-all duration-700 ease-out"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center">
        {label ?? (
          <span className="font-display text-xl font-semibold text-navy-900">
            {v}%
          </span>
        )}
      </div>
    </div>
  );
}
