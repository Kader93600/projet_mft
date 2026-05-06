"use client";
import { useState, useTransition } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";
import { useRouter } from "next/navigation";

export function MarkDoneButton({
  lessonId,
  initialDone,
}: {
  lessonId: string;
  initialDone: boolean;
}) {
  const [done, setDone] = useState(initialDone);
  const [pending, start] = useTransition();
  const router = useRouter();

  async function toggle() {
    start(async () => {
      const supabase = createClient();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;
      const newDone = !done;
      // 1) Source explicite : lesson_progress (utilisée par la page détail)
      await supabase.from("lesson_progress").upsert(
        {
          user_id: user.id,
          lesson_id: lessonId,
          completed: newDone,
          completed_at: newDone ? new Date().toISOString() : null,
        },
        { onConflict: "user_id,lesson_id" }
      );
      // 2) Source de tracking : lesson_views (utilisée par /modules)
      //    On synchronise via la RPC ping_lesson_view pour empêcher la
      //    divergence entre les 2 vues. La RPC ne fait que OR sur
      //    completed, donc le toggle off n'est répliqué qu'à demi (on
      //    s'appuie sur l'union côté lecture).
      if (newDone) {
        try {
          await supabase.rpc("ping_lesson_view", {
            p_lesson_id: lessonId,
            p_completed: true,
          });
        } catch {
          /* non-bloquant : la lecture fait l'union des 2 tables */
        }
      }
      setDone(newDone);
      router.refresh();
    });
  }

  return (
    <Button
      variant={done ? "secondary" : "gold"}
      onClick={toggle}
      disabled={pending}
      size="md"
    >
      {done ? (
        <>
          <Check className="w-4 h-4" /> Terminé
        </>
      ) : (
        "Marquer terminé"
      )}
    </Button>
  );
}
