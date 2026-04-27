"use client";
import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { useToast } from "@/components/ui/toast";
import { Trash2 } from "lucide-react";
import { deleteAttempt } from "./actions";

export function DeleteAttemptButton({ id }: { id: string }) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  function onClick() {
    if (!confirm("Supprimer cette tentative ?")) return;
    startTransition(async () => {
      try {
        await deleteAttempt(id);
        toast("Tentative supprimée", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <button
      onClick={onClick}
      disabled={isPending}
      className="h-7 w-7 rounded-md text-slate-400 hover:text-rose-600 hover:bg-rose-50 inline-flex items-center justify-center disabled:opacity-40"
      title="Supprimer cette tentative"
    >
      <Trash2 className="h-3.5 w-3.5" />
    </button>
  );
}
