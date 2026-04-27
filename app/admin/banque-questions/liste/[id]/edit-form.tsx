"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { CheckCircle2, AlertCircle, Loader2 } from "lucide-react";

interface QuestionData {
  id: string;
  type: "qcm" | "qr";
  statement: string;
  choices: any[] | null;
  expected_answer: string | null;
  scoring_grid: string | null;
  max_score: number;
  difficulty: string;
  tags: string[];
  active: boolean;
}

export function EditQuestionForm({ question }: { question: QuestionData }) {
  const router = useRouter();
  const [statement, setStatement] = useState(question.statement);
  const [difficulty, setDifficulty] = useState(question.difficulty);
  const [maxScore, setMaxScore] = useState(String(question.max_score));
  const [expectedAnswer, setExpectedAnswer] = useState(
    question.expected_answer ?? ""
  );
  const [scoringGrid, setScoringGrid] = useState(question.scoring_grid ?? "");
  const [choices, setChoices] = useState<any[]>(question.choices ?? []);
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<"idle" | "ok" | "err">("idle");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  function updateChoice(idx: number, patch: Partial<any>) {
    setChoices(choices.map((c, i) => (i === idx ? { ...c, ...patch } : c)));
  }

  function setCorrect(idx: number) {
    setChoices(choices.map((c, i) => ({ ...c, is_correct: i === idx })));
  }

  function onSave() {
    setErrorMsg(null);
    startTransition(async () => {
      const supabase = createClient();
      const payload: any = {
        statement: statement.trim(),
        difficulty,
        max_score: parseFloat(maxScore.replace(",", ".")) || 1,
      };
      if (question.type === "qcm") {
        payload.choices = choices;
      } else {
        payload.expected_answer = expectedAnswer.trim() || null;
        payload.scoring_grid = scoringGrid.trim() || null;
      }
      const { error } = await supabase
        .from("question_bank")
        .update(payload)
        .eq("id", question.id);
      if (error) {
        setFeedback("err");
        setErrorMsg(error.message);
        return;
      }
      setFeedback("ok");
      router.refresh();
      setTimeout(() => setFeedback("idle"), 2000);
    });
  }

  return (
    <div className="space-y-5">
      <div>
        <Label htmlFor="statement">Énoncé</Label>
        <Textarea
          id="statement"
          value={statement}
          onChange={(e) => setStatement(e.target.value)}
          rows={4}
        />
      </div>

      <div className="grid sm:grid-cols-2 gap-4">
        <div>
          <Label htmlFor="difficulty">Difficulté</Label>
          <select
            id="difficulty"
            value={difficulty}
            onChange={(e) => setDifficulty(e.target.value)}
            className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5"
          >
            <option value="facile">Facile</option>
            <option value="moyen">Moyen</option>
            <option value="difficile">Difficile</option>
          </select>
        </div>
        <div>
          <Label htmlFor="max_score">Note maximale</Label>
          <Input
            id="max_score"
            type="number"
            min={0}
            step={0.5}
            value={maxScore}
            onChange={(e) => setMaxScore(e.target.value)}
          />
        </div>
      </div>

      {question.type === "qcm" && (
        <div>
          <Label>Choix de réponse (cocher la bonne)</Label>
          <div className="space-y-2 mt-2">
            {choices.map((c, idx) => (
              <div
                key={c.id ?? idx}
                className={
                  "flex items-center gap-3 px-3 py-2 rounded-xl border " +
                  (c.is_correct
                    ? "border-emerald-300 bg-emerald-50"
                    : "border-navy-100 bg-white")
                }
              >
                <input
                  type="radio"
                  name="correct"
                  checked={!!c.is_correct}
                  onChange={() => setCorrect(idx)}
                  className="h-4 w-4 text-emerald-600"
                />
                <span className="font-mono text-xs font-bold text-slate-500 uppercase w-5">
                  {c.id ?? String.fromCharCode(97 + idx)}
                </span>
                <input
                  type="text"
                  value={c.label ?? ""}
                  onChange={(e) =>
                    updateChoice(idx, { label: e.target.value })
                  }
                  className="flex-1 h-9 rounded-lg border border-navy-200 px-2 text-sm"
                />
              </div>
            ))}
          </div>
        </div>
      )}

      {question.type === "qr" && (
        <>
          <div>
            <Label htmlFor="expected">Réponse-modèle (corrigé pour formateur)</Label>
            <Textarea
              id="expected"
              value={expectedAnswer}
              onChange={(e) => setExpectedAnswer(e.target.value)}
              rows={5}
              placeholder="Éléments attendus dans la réponse du stagiaire…"
            />
          </div>
          <div>
            <Label htmlFor="grid">Barème détaillé</Label>
            <Textarea
              id="grid"
              value={scoringGrid}
              onChange={(e) => setScoringGrid(e.target.value)}
              rows={3}
              placeholder="Ex. Définition 2 pts + exemple 1 pt + 2 conditions 2 pts"
            />
          </div>
        </>
      )}

      {errorMsg && (
        <div className="flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
          <AlertCircle className="h-4 w-4" />
          {errorMsg}
        </div>
      )}

      <div className="flex justify-end">
        <Button onClick={onSave} disabled={pending} variant="gold">
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" /> Enregistrement…
            </>
          ) : feedback === "ok" ? (
            <>
              <CheckCircle2 className="h-4 w-4" /> Enregistré
            </>
          ) : (
            "Enregistrer les modifications"
          )}
        </Button>
      </div>
    </div>
  );
}
