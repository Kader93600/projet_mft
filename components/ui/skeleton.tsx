import { cn } from "@/lib/utils";

export function Skeleton({
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      aria-hidden
      className={cn(
        "animate-pulse rounded-xl bg-navy-100/60 dark:bg-white/5",
        className
      )}
      {...props}
    />
  );
}

// Skeleton générique pour une ligne de carte (liste, dashboard…)
export function CardSkeleton() {
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-5">
      <Skeleton className="h-4 w-24" />
      <Skeleton className="h-7 w-3/4 mt-3" />
      <Skeleton className="h-3 w-full mt-3" />
      <Skeleton className="h-3 w-5/6 mt-2" />
    </div>
  );
}

export function HeaderSkeleton() {
  return (
    <div>
      <Skeleton className="h-3 w-24 mb-3" />
      <Skeleton className="h-10 w-72" />
      <Skeleton className="h-4 w-2/3 mt-3" />
    </div>
  );
}

export function ListSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <div className="rounded-2xl border border-navy-100 bg-white divide-y divide-navy-50">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="px-5 py-4 flex items-center gap-4">
          <Skeleton className="h-10 w-10 rounded-xl" />
          <div className="flex-1">
            <Skeleton className="h-4 w-1/2" />
            <Skeleton className="h-3 w-1/3 mt-2" />
          </div>
          <Skeleton className="h-5 w-16" />
        </div>
      ))}
    </div>
  );
}
