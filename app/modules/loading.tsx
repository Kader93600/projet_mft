import { HeaderSkeleton, CardSkeleton } from "@/components/ui/skeleton";

export default function ModulesLoading() {
  return (
    <div className="space-y-10">
      <HeaderSkeleton />
      <div className="grid md:grid-cols-2 gap-4">
        {Array.from({ length: 6 }).map((_, i) => (
          <CardSkeleton key={i} />
        ))}
      </div>
    </div>
  );
}
