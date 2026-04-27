"use client";
import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { Eye, EyeOff, Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export function ToggleActiveButton({
  questionId,
  active,
}: {
  questionId: string;
  active: boolean;
}) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();

  function onToggle() {
    startTransition(async () => {
      const supabase = createClient();
      const { error } = await supabase
        .from("question_bank")
        .update({ active: !active })
        .eq("id", questionId);
      if (error) {
        alert(error.message);
        return;
      }
      router.refresh();
    });
  }

  return (
    <button
      type="button"
      onClick={onToggle}
      disabled={pending}
      className="h-8 w-8 rounded-lg border border-navy-200 hover:bg-navy-50 flex items-center justify-center text-slate-600 disabled:opacity-50"
      aria-label={active ? "Désactiver" : "Activer"}
      title={active ? "Désactiver" : "Activer"}
    >
      {pending ? (
        <Loader2 className="h-3.5 w-3.5 animate-spin" />
      ) : active ? (
        <EyeOff className="h-3.5 w-3.5" />
      ) : (
        <Eye className="h-3.5 w-3.5" />
      )}
    </button>
  );
}
