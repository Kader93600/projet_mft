import { cn } from "@/lib/utils";

interface KeyFigure {
  value: string;
  unit?: string;
  label: string;
}

export function KeyFigures({
  items,
  className,
}: {
  items: KeyFigure[];
  className?: string;
}) {
  return (
    <div
      className={cn(
        "my-6 grid gap-3",
        items.length === 2
          ? "sm:grid-cols-2"
          : items.length === 3
          ? "sm:grid-cols-3"
          : "sm:grid-cols-2 md:grid-cols-4",
        className
      )}
    >
      {items.map((it, i) => (
        <div
          key={i}
          className="rounded-2xl border border-navy-100 bg-white p-5 text-center"
        >
          <div className="font-display text-3xl font-semibold text-navy-950 leading-none">
            {it.value}
            {it.unit && (
              <span className="ml-1 text-base font-medium text-slate-500">
                {it.unit}
              </span>
            )}
          </div>
          <div className="mt-2 text-xs uppercase tracking-wider text-slate-500">
            {it.label}
          </div>
        </div>
      ))}
    </div>
  );
}
