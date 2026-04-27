import { HeaderSkeleton, CardSkeleton } from "@/components/ui/skeleton";

export default function RootLoading() {
  return (
    <div className="max-w-7xl mx-auto px-4 md:px-8 py-6 md:py-10 space-y-8">
      <HeaderSkeleton />
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
        {Array.from({ length: 6 }).map((_, i) => (
          <CardSkeleton key={i} />
        ))}
      </div>
    </div>
  );
}
