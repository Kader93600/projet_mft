"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
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
  Sparkles,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
import { gradeQrResponse } from "./actions";
import { RichTextDisplay } from "@/components/rich-text/rich-text-display";
import { renderMarkdown } from "@/lib/markdown";

interface AiCriterion {
  name: string;
  weight: number;
  awarded: number;
}

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
  // Proposition IA (Sprint 3.3) — optionnel
  ai_score?: number | null;
  ai_feedback_md?: string | null;
  ai_criteria?: AiCriterion[] | null;
  ai_confidence?: "low" | "medium" | "high" | null;
  ai_concerns?: string | null;
  ai_graded_at?: string | null;
}

export function QrGradingForm({
  response,
  disabled,
  aiEnabled = false,
}: {
  response: ResponseProps;
  disabled?: boolean;
  aiEnabled?: boolean;
}) {
  const router = useRouter();
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
  // Sprint 3.3 — proposition IA
  const [aiPending, setAiPending] = useState(false);
  const [aiError, setAiError] = useState<string | null>(null);
  const [showAi, setShowAi] = useState(true);
  const [aiProposal, setAiProposal] = useState<{
    ai_score: number | null;
    ai_feedback_md: string | null;
    ai_criteria: AiCriterion[] | null;
    ai_confidence: "low" | "medium" | "high" | null;
    ai_concerns: string | null;
    ai_graded_at: string | null;
  }>({
    ai_score: response.ai_score ?? null,
    ai_feedback_md: response.ai_feedback_md ?? null,
    ai_criteria: response.ai_criteria ?? null,
    ai_confidence: response.ai_confidence ?? null,
    ai_concerns: response.ai_concerns ?? null,
    ai_graded_at: response.ai_graded_at ?? null,
  });
  const hasAi = aiProposal.ai_graded_at != null;

  const isGraded = !!response.graded_at;

  async function requestAiGrading() {
    setAiError(null);
    setAiPending(true);
    try {
      const res = await fetch("/api/tutor/grade-qr", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ response_id: response.id }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.message || err.error || `HTTP ${res.status}`);
      }
      const json = await res.json();
      setAiProposal({
        ai_score: json.ai_score ?? null,
        ai_feedback_md: json.ai_feedback_md ?? null,
        ai_criteria: json.ai_criteria ?? null,
        ai_confidence: json.ai_confidence ?? null,
        ai_concerns: json.ai_concerns ?? null,
        ai_graded_at: new Date().toISOString(),
      });
      setShowAi(true);
      // Rafraîchit la SSR pour persister les ai_* visibles au prochain reload
      router.refresh();
    } catch (e: any) {
      setAiError(e?.message ?? "Erreur");
    } finally {
      setAiPending(false);
    }
  }

  function adoptAiProposal() {
    if (aiProposal.ai_score != null) {
      setScore(String(aiProposal.ai_score));
    }
    if (aiProposal.ai_feedback_md) {
      setComment(aiProposal.ai_feedback_md);
    }
  }

  /**
   * Validation 1-clic : reprend la note IA + le feedback IA et les
   * enregistre directement comme note finale du formateur. Évite le
   * détour "Reprendre cette proposition" → "Noter cette réponse" en
   * 2 clics. Une confirmation est demandée pour éviter les clics
   * accidentels.
   */
  function validateAiProposalDirectly() {
    if (aiProposal.ai_score == null) return;
    const ok = window.confirm(
      `Valider la proposition IA (${aiProposal.ai_score} / ${response.max_score}) telle quelle ?\n\n` +
        `Le score et l'appréciation seront enregistrés comme votre note finale. ` +
        `Cette action peut être modifiée plus tard via "Modifier la note".`
    );
    if (!ok) return;

    const num = Number(aiProposal.ai_score);
    setErrorMsg(null);
    // On reflète aussi dans les champs UI pour le feedback visuel post-validation
    setScore(String(num));
    if (aiProposal.ai_feedback_md) {
      setComment(aiProposal.ai_feedback_md);
    }
    startTransition(async () => {
      try {
        await gradeQrResponse(
          response.id,
          num,
          aiProposal.ai_feedback_md?.trim() || null
        );
        setFeedback("ok");
        setTimeout(() => setFeedback("idle"), 2200);
        router.refresh();
      } catch (e: any) {
        setFeedback("err");
        setErrorMsg(e.message ?? "Erreur lors de la validation");
      }
    });
  }

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

        {/* ──── Sprint 3.3 — Proposition IA ──────────────────────── */}
        {aiEnabled && !disabled && !isGraded && (
          <div className="mb-4 rounded-xl border border-gold-200 bg-gold-50/60">
            <div className="flex items-center justify-between gap-2 px-3.5 py-2 border-b border-gold-200">
              <div className="inline-flex items-center gap-1.5 text-[12px] font-semibold text-gold-800">
                <Sparkles className="h-3.5 w-3.5" />
                Tuteur IA — Claude Sonnet 4.6
                {hasAi && aiProposal.ai_confidence && (
                  <span
                    className={
                      aiProposal.ai_confidence === "high"
                        ? "ml-2 inline-flex items-center rounded px-1.5 py-0.5 text-[10px] font-medium bg-emerald-100 text-emerald-800 border border-emerald-200"
                        : aiProposal.ai_confidence === "medium"
                        ? "ml-2 inline-flex items-center rounded px-1.5 py-0.5 text-[10px] font-medium bg-amber-100 text-amber-800 border border-amber-200"
                        : "ml-2 inline-flex items-center rounded px-1.5 py-0.5 text-[10px] font-medium bg-rose-100 text-rose-800 border border-rose-200"
                    }
                  >
                    Confiance {aiProposal.ai_confidence}
                  </span>
                )}
              </div>
              <div className="flex items-center gap-1.5">
                {hasAi && (
                  <button
                    type="button"
                    onClick={() => setShowAi((v) => !v)}
                    className="text-[11px] text-slate-600 hover:text-navy-900 inline-flex items-center gap-1"
                  >
                    {showAi ? (
                      <>
                        <ChevronUp className="h-3 w-3" />
                        Masquer
                      </>
                    ) : (
                      <>
                        <ChevronDown className="h-3 w-3" />
                        Voir la proposition
                      </>
                    )}
                  </button>
                )}
                {!hasAi && (
                  <Button
                    onClick={requestAiGrading}
                    disabled={aiPending}
                    size="sm"
                    variant="gold"
                  >
                    {aiPending ? (
                      <>
                        <Loader2 className="h-3.5 w-3.5 animate-spin" />
                        Analyse en cours…
                      </>
                    ) : (
                      <>
                        <Sparkles className="h-3.5 w-3.5" />
                        Proposer une note IA
                      </>
                    )}
                  </Button>
                )}
              </div>
            </div>

            {aiError && (
              <div className="px-3.5 py-2 text-[12px] text-rose-800 inline-flex items-center gap-1.5">
                <AlertCircle className="h-3.5 w-3.5" />
                {aiError}
              </div>
            )}

            {hasAi && showAi && (
              <div className="px-3.5 py-3 space-y-3">
                {/* Score proposé */}
                <div className="flex items-center justify-between gap-3 flex-wrap">
                  <div>
                    <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-0.5">
                      Note proposée
                    </div>
                    <div className="font-display text-2xl font-semibold text-navy-900 tabular-nums">
                      {aiProposal.ai_score}{" "}
                      <span className="text-slate-400 text-lg font-normal">
                        / {response.max_score}
                      </span>
                    </div>
                  </div>
                  <div className="flex flex-col sm:flex-row gap-2 self-end">
                    <Button
                      onClick={adoptAiProposal}
                      size="sm"
                      variant="secondary"
                      disabled={pending}
                    >
                      Reprendre puis ajuster
                    </Button>
                    <Button
                      onClick={validateAiProposalDirectly}
                      size="sm"
                      variant="gold"
                      disabled={pending}
                    >
                      {pending ? (
                        <>
                          <Loader2 className="h-3.5 w-3.5 animate-spin" />
                          Validation…
                        </>
                      ) : (
                        <>
                          <CheckCircle2 className="h-3.5 w-3.5" />
                          Valider la note IA
                        </>
                      )}
                    </Button>
                  </div>
                </div>

                {/* Feedback */}
                {aiProposal.ai_feedback_md && (
                  <div>
                    <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1">
                      Appréciation
                    </div>
                    <div
                      className="prose-tutor text-[13px] text-navy-900 leading-relaxed bg-white border border-gold-200 rounded-lg p-3"
                      dangerouslySetInnerHTML={{
                        __html: renderMarkdown(aiProposal.ai_feedback_md),
                      }}
                    />
                  </div>
                )}

                {/* Critères */}
                {Array.isArray(aiProposal.ai_criteria) &&
                  aiProposal.ai_criteria.length > 0 && (
                    <div>
                      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold mb-1">
                        Détail des critères
                      </div>
                      <ul className="space-y-1">
                        {aiProposal.ai_criteria.map((c, i) => (
                          <li
                            key={i}
                            className="flex items-center justify-between gap-3 text-[12px] bg-white rounded-md px-2.5 py-1.5 border border-gold-200"
                          >
                            <span className="text-navy-900">{c.name}</span>
                            <span className="tabular-nums text-gold-800 font-medium">
                              {c.awarded} / {c.weight}
                            </span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}

                {/* Concerns (note interne) */}
                {aiProposal.ai_concerns && (
                  <div className="text-[12px] text-amber-900 bg-amber-50 border border-amber-200 rounded-lg px-3 py-2">
                    <span className="font-semibold">⚠ Note IA : </span>
                    {aiProposal.ai_concerns}
                  </div>
                )}
              </div>
            )}
          </div>
        )}

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
