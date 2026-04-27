"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { useToast } from "@/components/ui/toast";
import { Button } from "@/components/ui/button";
import { Select } from "@/components/ui/select";
import { RotateCcw, Download, AlertTriangle } from "lucide-react";
import { resetQuizResults, resetAllResults } from "./actions";

interface Quiz {
  id: string;
  title: string;
}

export function AnalyticsToolbar({ quizzes }: { quizzes: Quiz[] }) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [quizId, setQuizId] = useState("");

  function onResetQuiz() {
    if (!quizId) {
      toast("Choisissez un quiz", "error");
      return;
    }
    if (!confirm("Supprimer toutes les tentatives de ce quiz ?")) return;
    startTransition(async () => {
      try {
        await resetQuizResults(quizId);
        toast("Résultats du quiz réinitialisés", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onResetAll() {
    if (
      !confirm(
        "⚠️ Supprimer TOUTES les tentatives et progressions de TOUS les étudiants ? Irréversible."
      )
    )
      return;
    startTransition(async () => {
      try {
        await resetAllResults();
        toast("Toutes les statistiques ont été remises à zéro", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div className="flex flex-wrap items-center gap-3">
      <a href="/admin/analytics/export/pdf" target="_blank">
        <Button variant="gold" size="sm">
          <Download className="h-4 w-4" /> Export PDF global
        </Button>
      </a>
      <div className="flex items-center gap-2">
        <Select
          value={quizId}
          onChange={(e) => setQuizId(e.target.value)}
          className="h-9 text-xs"
        >
          <option value="">Réinitialiser un quiz…</option>
          {quizzes.map((q) => (
            <option key={q.id} value={q.id}>
              {q.title}
            </option>
          ))}
        </Select>
        <Button
          variant="secondary"
          size="sm"
          onClick={onResetQuiz}
          disabled={isPending || !quizId}
        >
          <RotateCcw className="h-4 w-4" /> Reset quiz
        </Button>
      </div>
      <Button
        variant="danger"
        size="sm"
        onClick={onResetAll}
        disabled={isPending}
        className="ml-auto"
      >
        <AlertTriangle className="h-4 w-4" /> Tout réinitialiser
      </Button>
    </div>
  );
}
