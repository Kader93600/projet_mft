import { HeaderSkeleton, ListSkeleton } from "@/components/ui/skeleton";

export default function QuizLoading() {
  return (
    <div className="space-y-8">
      <HeaderSkeleton />
      <ListSkeleton rows={6} />
    </div>
  );
}
