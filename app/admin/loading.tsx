import { HeaderSkeleton, CardSkeleton, ListSkeleton } from "@/components/ui/skeleton";

export default function AdminLoading() {
  return (
    <div className="space-y-10">
      <HeaderSkeleton />
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <CardSkeleton key={i} />
        ))}
      </div>
      <ListSkeleton rows={6} />
    </div>
  );
}
