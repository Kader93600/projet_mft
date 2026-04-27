"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import {
  CheckCircle2,
  AlertTriangle,
  Loader2,
  MessageSquare,
} from "lucide-react";
import { finalizeQuizGrading } from "./actions";

export function FinalizeForm({
  attemptId,
  disabled,
  ungradedCount,
}: {
  attemptId: string;
  disabled: boolean;
  ungradedCount: number;
}) {
  const router = useRouter();
  const [globalComment, setGlobalComment] = useState<string>("");
  const [pending, startTransition] = useTransition();
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  function onFinalize() {
    if (
      !confirm(
        "Finaliser cette correction ? La note sera calculée et le stagiaire recevra une notification. Cette action est définitive."
      )
    ) {
      return;
    }
    setErrorMsg(null);
    startTransition(async () => {
      try {
        await finalizeQuizGrading(attemptId, globalComment.trim() || null);
        router.push("/formateur/corrections");
      } catch (e: any) {
        setErrorMsg(e.message ?? "Erreur lors de la finalisation");
      }
    });
  }

  return (
    <div className="space-y-4">
      {disabled ? (
        <div className="flex items-start gap-2 rounded-xl bg-amber-50 border border-amber-200 p-4 text-sm text-amber-900">
          <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
          <div>
            Il reste <strong>{ungradedCount}</strong> question
            {ungradedCount > 1 ? "s" : ""} à corriger avant de pouvoir
            finaliser. Notez chaque réponse rédigée ci-dessus.
          </div>
        </div>
      ) : (
        <p className="text-sm text-slate-600">
          Toutes les réponses sont notées. Vous pouvez finaliser : la note
          totale sera calculée (pondération 70 % QCM + 30 % rédigées par
          défaut), le stagiaire sera notifié et pourra consulter sa note et
          vos commentaires.
        </p>
      )}

      <div>
        <label className="flex items-center gap-1.5 text-[11px] uppercase tracking-wider text-slate-500 font-semibold mb-1">
          <MessageSquare className="h-3 w-3" />
          Commentaire global (optionnel)
        </label>
        <Textarea
          value={globalComment}
          onChange={(e) => setGlobalComment(e.target.value)}
          disabled={pending || disabled}
          rows={4}
          placeholder="Synthèse globale de la copie, axes d'amélioration prioritaires, encouragements…"
        />
      </div>

      {errorMsg && (
        <div className="flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
          <AlertTriangle className="h-4 w-4" />
          {errorMsg}
        </div>
      )}

      <div className="flex justify-end">
        <Button
          onClick={onFinalize}
          disabled={pending || disabled}
          variant="gold"
        >
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" /> Finalisation…
            </>
          ) : (
            <>
              <CheckCircle2 className="h-4 w-4" /> Finaliser & notifier le
              stagiaire
            </>
          )}
        </Button>
      </div>
    </div>
  );
}
