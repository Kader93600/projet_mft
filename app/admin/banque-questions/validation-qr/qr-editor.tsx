"use client";
import { useState, useTransition } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { Input, Label } from "@/components/ui/input";
import {
  CheckCircle2,
  AlertCircle,
  Loader2,
  Save,
  Power,
  PowerOff,
} from "lucide-react";
import { updateQrMetadata, activateQr, deactivateQr } from "./actions";

interface QrData {
  id: string;
  statement: string;
  expected_answer: string | null;
  scoring_grid: string | null;
  max_score: number;
  difficulty: string;
  tags: string[];
  source_ref: string | null;
  active: boolean;
}

export function QrEditor({
  question,
  index,
  total,
}: {
  question: QrData;
  index: number;
  total: number;
}) {
  const [expected, setExpected] = useState(question.expected_answer ?? "");
  const [grid, setGrid] = useState(question.scoring_grid ?? "");
  const [maxScore, setMaxScore] = useState(String(question.max_score));
  const [difficulty, setDifficulty] = useState(question.difficulty);
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<"idle" | "ok" | "err">("idle");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const moduleTag = question.tags.find((t) => t.startsWith("module-"));
  const moduleLetter = moduleTag ? moduleTag.split("-")[1].toUpperCase() : "?";

  function onSave() {
    setErrorMsg(null);
    startTransition(async () => {
      try {
        await updateQrMetadata(question.id, {
          expected_answer: expected.trim() || null,
          scoring_grid: grid.trim() || null,
          max_score: parseFloat(maxScore.replace(",", ".")) || 1,
          difficulty,
        });
        setFeedback("ok");
        setTimeout(() => setFeedback("idle"), 2000);
      } catch (e: any) {
        setFeedback("err");
        setErrorMsg(e.message);
      }
    });
  }

  function onToggleActive() {
    startTransition(async () => {
      try {
        if (question.active) {
          await deactivateQr(question.id);
        } else {
          await activateQr(question.id);
        }
      } catch (e: any) {
        alert(e.message);
      }
    });
  }

  return (
    <Card
      className={
        question.active
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
              {index}
            </span>
            <Badge tone="navy" size="sm">
              Module {moduleLetter}
            </Badge>
            {question.active ? (
              <Badge tone="success" size="sm">
                <CheckCircle2 className="h-3 w-3" /> Active
              </Badge>
            ) : (
              <Badge tone="rose" size="sm">
                Inactive
              </Badge>
            )}
            {question.source_ref && (
              <code className="text-[10px] font-mono text-slate-400">
                {question.source_ref}
              </code>
            )}
          </div>
          <span className="text-xs text-slate-500">
            {index} / {total}
          </span>
        </div>

        {/* Énoncé */}
        <div className="rounded-xl border border-navy-100 bg-ivory p-4 mb-4">
          <div className="text-[10px] uppercase tracking-wider text-slate-500 mb-2 font-semibold">
            Énoncé (visible stagiaire)
          </div>
          <p className="text-sm text-navy-900 whitespace-pre-wrap leading-relaxed">
            {question.statement}
          </p>
        </div>

        {/* Édition réponse-modèle */}
        <div className="space-y-3">
          <div>
            <Label htmlFor={`exp-${question.id}`}>
              Réponse-modèle (visible formateur uniquement)
            </Label>
            <Textarea
              id={`exp-${question.id}`}
              value={expected}
              onChange={(e) => setExpected(e.target.value)}
              rows={4}
              placeholder="Éléments attendus dans la réponse du stagiaire (concepts-clés, mots du référentiel…)"
            />
          </div>
          <div>
            <Label htmlFor={`grid-${question.id}`}>Barème détaillé</Label>
            <Textarea
              id={`grid-${question.id}`}
              value={grid}
              onChange={(e) => setGrid(e.target.value)}
              rows={3}
              placeholder="Ex. Définition 2 pts + exemple 1 pt + 2 conditions 2 pts"
            />
          </div>
          <div className="grid sm:grid-cols-2 gap-3">
            <div>
              <Label htmlFor={`max-${question.id}`}>Note maximale</Label>
              <Input
                id={`max-${question.id}`}
                type="number"
                min={0}
                step={0.5}
                value={maxScore}
                onChange={(e) => setMaxScore(e.target.value)}
              />
            </div>
            <div>
              <Label htmlFor={`diff-${question.id}`}>Difficulté</Label>
              <select
                id={`diff-${question.id}`}
                value={difficulty}
                onChange={(e) => setDifficulty(e.target.value)}
                className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5"
              >
                <option value="facile">Facile</option>
                <option value="moyen">Moyen</option>
                <option value="difficile">Difficile</option>
              </select>
            </div>
          </div>
        </div>

        {errorMsg && (
          <div className="mt-3 flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
            <AlertCircle className="h-4 w-4" />
            {errorMsg}
          </div>
        )}

        <div className="mt-4 flex justify-between items-center flex-wrap gap-2">
          <button
            type="button"
            onClick={onToggleActive}
            disabled={pending}
            className={
              "inline-flex items-center gap-1.5 text-xs font-medium " +
              (question.active
                ? "text-rose-600 hover:text-rose-800"
                : "text-emerald-600 hover:text-emerald-800")
            }
          >
            {question.active ? (
              <>
                <PowerOff className="h-3.5 w-3.5" /> Désactiver
              </>
            ) : (
              <>
                <Power className="h-3.5 w-3.5" /> Activer
              </>
            )}
          </button>
          <Button
            onClick={onSave}
            disabled={pending}
            variant="gold"
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
            ) : (
              <>
                <Save className="h-4 w-4" /> Enregistrer
              </>
            )}
          </Button>
        </div>
      </CardBody>
    </Card>
  );
}
