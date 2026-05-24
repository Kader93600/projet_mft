"use client";
import { useState, useTransition } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Check } from "lucide-react";
import { useRouter } from "next/navigation";
import { ModuleCompleteCelebration } from "@/components/celebration/module-complete-celebration";

export function MarkDoneButton({
  lessonId,
  initialDone,
  moduleTitle,
  lessonsTotal = 1,
  moduleDoneOthers = 0,
  continueHref,
}: {
  lessonId: string;
  initialDone: boolean;
  /** Titre du module — pour la célébration de validation. */
  moduleTitle?: string;
  /** Nombre total de leçons du module. */
  lessonsTotal?: number;
  /** Leçons du module déjà terminées, hors leçon courante. */
  moduleDoneOthers?: number;
  /** Lien « continuer » (vue module) affiché dans la célébration. */
  continueHref?: string;
}) {
  const [done, setDone] = useState(initialDone);
  const [pending, start] = useTransition();
  const [celebrate, setCelebrate] = useState(false);
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
      // Célébration : cette leçon valide le dernier maillon du module.
      if (
        newDone &&
        moduleTitle &&
        moduleDoneOthers + 1 >= lessonsTotal
      ) {
        setCelebrate(true);
      }
      router.refresh();
    });
  }

  return (
    <>
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

      {celebrate && moduleTitle && (
        <ModuleCompleteCelebration
          moduleTitle={moduleTitle}
          lessonsTotal={lessonsTotal}
          continueHref={continueHref ?? "/modules"}
          onClose={() => setCelebrate(false)}
        />
      )}
    </>
  );
}
