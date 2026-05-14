"use client";
import { useState, useTransition } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import {
  CheckCircle2,
  AlertCircle,
  Loader2,
  Eye,
  EyeOff,
  Lightbulb,
  Target,
} from "lucide-react";
import { gradeQrResponse } from "./actions";
import { RichTextDisplay } from "@/components/rich-text/rich-text-display";

interface ResponseProps {
  id: string;
  index: number;
  statement: string;
  expected_answer?: string | null;
  scoring_grid?: string | null;
  student_answer: string | null;
  trainer_score: number | null;
  max_score: number;
  trainer_comment: string | null;
  graded_at: string | null;
  tags: string[];
}

export function QrGradingForm({
  response,
  disabled,
}: {
  response: ResponseProps;
  disabled?: boolean;
}) {
  const [score, setScore] = useState<string>(
    response.trainer_score !== null ? String(response.trainer_score) : ""
  );
  const [comment, setComment] = useState<string>(
    response.trainer_comment ?? ""
  );
  const [showExpected, setShowExpected] = useState(false);
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<"idle" | "ok" | "err">("idle");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const isGraded = !!response.graded_at;

  function onSave() {
    const num = parseFloat(score.replace(",", "."));
    if (isNaN(num) || num < 0 || num > response.max_score) {
      setErrorMsg(`Note entre 0 et ${response.max_score}`);
      return;
    }
    setErrorMsg(null);
    startTransition(async () => {
      try {
        await gradeQrResponse(response.id, num, comment.trim() || null);
        setFeedback("ok");
        setTimeout(() => setFeedback("idle"), 2000);
      } catch (e: any) {
        setFeedback("err");
        setErrorMsg(e.message ?? "Erreur");
      }
    });
  }

  // Tags lisibles (module + thème)
  const moduleTag = response.tags.find((t) => t.startsWith("module-"));
  const moduleLetter = moduleTag ? moduleTag.split("-")[1].toUpperCase() : "?";

  return (
    <Card
      className={
        isGraded
          ? "border-emerald-200"
          : feedback === "err"
          ? "border-rose-300"
          : ""
      }
    >
      <CardBody>
        <div className="flex items-center justify-between gap-3 mb-3 flex-wrap">
          <div className="flex items-center gap-2">
            <span className="h-7 w-7 rounded-md bg-brand-50 text-brand-700 flex items-center justify-center font-semibold text-xs">
              {response.index}
            </span>
            <Badge tone="navy" size="sm">
              Module {moduleLetter}
            </Badge>
            {isGraded && (
              <Badge tone="success" size="sm">
                <CheckCircle2 className="h-3 w-3" />
                Corrigée
              </Badge>
            )}
          </div>
          <span className="text-xs text-slate-500">
            Barème : {response.max_score} pt
            {response.max_score > 1 ? "s" : ""}
          </span>
        </div>

        {/* Énoncé */}
        <div className="rounded-xl border border-navy-100 bg-ivory p-4 mb-4">
          <div className="flex items-center gap-1.5 text-[10px] uppercase tracking-wider text-slate-500 mb-2">
            <Target className="h-3 w-3" />
            Énoncé
          </div>
          <RichTextDisplay
            content={response.statement}
            className="text-sm text-navy-900 leading-relaxed"
          />
        </div>

        {/* Réponse modèle (toggle) */}
        {(response.expected_answer || response.scoring_grid) && (
          <div className="mb-4">
            <button
              type="button"
              onClick={() => setShowExpected(!showExpected)}
              className="inline-flex items-center gap-1.5 text-xs text-brand-700 hover:text-brand-900 font-medium"
            >
              {showExpected ? (
                <>
                  <EyeOff className="h-3.5 w-3.5" /> Masquer le corrigé-type
                </>
              ) : (
                <>
                  <Eye className="h-3.5 w-3.5" /> Afficher le corrigé-type
                </>
              )}
            </button>
            {showExpected && (
              <div className="mt-2 rounded-xl border border-gold-200 bg-gold-50 p-4">
                <div className="flex items-center gap-1.5 mb-2">
                  <Lightbulb className="h-3.5 w-3.5 text-gold-700" />
                  <div className="text-[10px] font-semibold uppercase tracking-wider text-gold-800">
                    Réponse-modèle
                  </div>
                </div>
                {response.expected_answer && (
                  <RichTextDisplay
                    content={response.expected_answer}
                    className="text-sm text-navy-900 mb-2"
                  />
                )}
                {response.scoring_grid && (
                  <div className="mt-3 pt-3 border-t border-gold-200">
                    <div className="text-[10px] font-semibold uppercase tracking-wider text-gold-800 mb-1">
                      Barème
                    </div>
                    <RichTextDisplay
                      content={response.scoring_grid}
                      className="text-xs text-navy-900"
                    />
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* Réponse stagiaire */}
        <div className="rounded-xl border border-navy-200 bg-white p-4 mb-4">
          <div className="text-[10px] uppercase tracking-wider text-slate-500 mb-2 font-semibold">
            Réponse du stagiaire
          </div>
          {response.student_answer ? (
            <p className="text-sm text-navy-900 whitespace-pre-wrap leading-relaxed">
              {response.student_answer}
            </p>
          ) : (
            <p className="text-sm text-slate-400 italic">
              Aucune réponse fournie
            </p>
          )}
        </div>

        {/* Notation */}
        {!disabled && (
          <div className="grid md:grid-cols-[auto_1fr] gap-4 items-start">
            <div>
              <label className="block text-[10px] uppercase tracking-wider text-slate-500 mb-1 font-semibold">
                Note ({response.max_score} pt max)
              </label>
              <div className="flex items-center gap-2">
                <input
                  type="number"
                  min={0}
                  max={response.max_score}
                  step={0.25}
                  value={score}
                  onChange={(e) => setScore(e.target.value)}
                  disabled={pending}
                  placeholder="0"
                  className="w-24 h-11 rounded-xl border border-navy-200 bg-white px-3 text-center text-lg font-display font-semibold text-navy-900"
                />
                <span className="text-slate-500">/ {response.max_score}</span>
              </div>
            </div>
            <div>
              <label className="block text-[10px] uppercase tracking-wider text-slate-500 mb-1 font-semibold">
                Commentaire pédagogique (optionnel)
              </label>
              <Textarea
                value={comment}
                onChange={(e) => setComment(e.target.value)}
                disabled={pending}
                rows={3}
                placeholder="Points forts, axes d'amélioration, références…"
              />
            </div>
          </div>
        )}

        {errorMsg && (
          <div className="mt-3 flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
            <AlertCircle className="h-4 w-4" />
            {errorMsg}
          </div>
        )}

        {!disabled && (
          <div className="mt-4 flex justify-end">
            <Button
              onClick={onSave}
              disabled={pending}
              variant={isGraded ? "secondary" : "gold"}
              size="sm"
            >
              {pending ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" /> Enregistrement…
                </>
              ) : feedback === "ok" ? (
                <>
                  <CheckCircle2 className="h-4 w-4" /> Enregistré
                </>
              ) : isGraded ? (
                "Modifier la note"
              ) : (
                <>
                  <CheckCircle2 className="h-4 w-4" /> Noter cette réponse
                </>
              )}
            </Button>
          </div>
        )}
      </CardBody>
    </Card>
  );
}
