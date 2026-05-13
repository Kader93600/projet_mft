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
  Pencil,
  X,
  Trash2,
} from "lucide-react";
import {
  updateQrMetadata,
  activateQr,
  deactivateQr,
  deleteQuestion,
} from "./actions";
import { ConfirmAction } from "@/components/ui/confirm-action";
import { getQuestionFilterConfig } from "@/lib/question-filters";

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
  formationSlug,
}: {
  question: QrData;
  index: number;
  total: number;
  formationSlug: string;
}) {
  const filterConfig = getQuestionFilterConfig(formationSlug);
  // Tag de groupe courant (chapitre-N ou module-X)
  const currentGroupTag = question.tags.find((t) =>
    t.startsWith(filterConfig.tagPrefix),
  );
  const currentGroupKey = currentGroupTag
    ? currentGroupTag.slice(filterConfig.tagPrefix.length)
    : "";
  const [groupKey, setGroupKey] = useState(currentGroupKey);
  // États édition contenu pédagogique
  const [statement, setStatement] = useState(question.statement);
  const [tagsInput, setTagsInput] = useState(question.tags.join(", "));
  const [expected, setExpected] = useState(question.expected_answer ?? "");
  const [grid, setGrid] = useState(question.scoring_grid ?? "");
  const [maxScore, setMaxScore] = useState(String(question.max_score));
  const [difficulty, setDifficulty] = useState(question.difficulty);

  // États UI
  const [editStatement, setEditStatement] = useState(false);
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<"idle" | "ok" | "err">("idle");
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // Affectation rapide à un chapitre / module — met à jour le tag DB
  // (retire l'ancien tag de groupe, ajoute le nouveau) en une transition.
  function onChangeGroup(newKey: string) {
    setGroupKey(newKey);
    startTransition(async () => {
      try {
        const baseTags = question.tags.filter(
          (t) => !t.startsWith(filterConfig.tagPrefix),
        );
        const nextTags = newKey
          ? [...baseTags, `${filterConfig.tagPrefix}${newKey}`]
          : baseTags;
        await updateQrMetadata(question.id, { tags: nextTags });
        setTagsInput(nextTags.join(", "));
        setFeedback("ok");
        setTimeout(() => setFeedback("idle"), 1500);
      } catch (e: any) {
        setFeedback("err");
        setErrorMsg(e.message);
      }
    });
  }

  const statementChanged = statement.trim() !== question.statement.trim();
  const tagsChanged = tagsInput.trim() !== question.tags.join(", ").trim();

  function onSave() {
    setErrorMsg(null);
    if (!statement.trim()) {
      setFeedback("err");
      setErrorMsg("L'énoncé ne peut pas être vide.");
      return;
    }
    startTransition(async () => {
      try {
        // Parse les tags depuis la chaîne (séparateur virgule)
        const parsedTags = tagsInput
          .split(",")
          .map((t) => t.trim())
          .filter(Boolean);

        await updateQrMetadata(question.id, {
          statement: statement.trim(),
          tags: parsedTags,
          expected_answer: expected.trim() || null,
          scoring_grid: grid.trim() || null,
          max_score: parseFloat(maxScore.replace(",", ".")) || 1,
          difficulty,
        });
        setFeedback("ok");
        setEditStatement(false);
        setTimeout(() => setFeedback("idle"), 2000);
      } catch (e: any) {
        setFeedback("err");
        setErrorMsg(e.message);
      }
    });
  }

  function onCancelStatementEdit() {
    setStatement(question.statement);
    setTagsInput(question.tags.join(", "));
    setEditStatement(false);
    setErrorMsg(null);
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
            {/* Affectation rapide chapitre / module */}
            <div className="inline-flex items-center gap-1.5">
              <label
                htmlFor={`group-${question.id}`}
                className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold"
              >
                {filterConfig.label}
              </label>
              <select
                id={`group-${question.id}`}
                value={groupKey}
                onChange={(e) => onChangeGroup(e.target.value)}
                disabled={pending}
                className={
                  "h-7 px-2 rounded-md text-[12px] font-semibold border " +
                  (groupKey
                    ? "bg-navy-900 text-white border-navy-900"
                    : "bg-amber-50 text-amber-800 border-amber-300 hover:border-amber-400")
                }
                title={
                  groupKey
                    ? `Affectée à : ${filterConfig.formatLong ? filterConfig.formatLong(groupKey) : filterConfig.formatPill(groupKey)}`
                    : `Question non affectée — choisir un ${filterConfig.label.toLowerCase()}`
                }
              >
                <option value="">— non affectée —</option>
                {filterConfig.keys.map((k) => (
                  <option key={k} value={k}>
                    {filterConfig.formatLong
                      ? filterConfig.formatLong(k)
                      : filterConfig.formatPill(k)}
                  </option>
                ))}
                {/* Si le tag actuel n'est pas dans la config (ex. Ch. 13
                    futur), on l'ajoute comme option pour ne pas le perdre */}
                {currentGroupKey &&
                  !filterConfig.keys.includes(currentGroupKey as any) && (
                    <option value={currentGroupKey}>
                      {filterConfig.formatPill(currentGroupKey)} (extra)
                    </option>
                  )}
              </select>
            </div>
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
          <div className="flex items-center gap-2">
            <span className="text-xs text-slate-500">
              {index} / {total}
            </span>
            {/* Toggle édition énoncé */}
            <button
              type="button"
              onClick={() =>
                editStatement ? onCancelStatementEdit() : setEditStatement(true)
              }
              disabled={pending}
              className={
                "inline-flex items-center justify-center h-8 w-8 rounded-lg border transition " +
                (editStatement
                  ? "border-rose-200 bg-rose-50 text-rose-600 hover:bg-rose-100"
                  : "border-navy-200 bg-white text-navy-700 hover:bg-navy-50")
              }
              title={editStatement ? "Annuler l'édition" : "Éditer l'énoncé et les tags"}
              aria-label={editStatement ? "Annuler l'édition" : "Éditer l'énoncé et les tags"}
            >
              {editStatement ? (
                <X className="h-4 w-4" />
              ) : (
                <Pencil className="h-4 w-4" />
              )}
            </button>
          </div>
        </div>

        {/* Énoncé : lecture seule OU édition */}
        {!editStatement ? (
          <div className="rounded-xl border border-navy-100 bg-ivory p-4 mb-4 group relative">
            <div className="flex items-center justify-between mb-2">
              <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
                Énoncé (visible stagiaire)
              </div>
              {(statementChanged || tagsChanged) && (
                <Badge tone="gold" size="sm">
                  Non enregistré
                </Badge>
              )}
            </div>
            <p className="text-sm text-navy-900 whitespace-pre-wrap leading-relaxed">
              {statement}
            </p>
            {question.tags.length > 0 && (
              <div className="mt-3 pt-3 border-t border-navy-100/60 flex flex-wrap gap-1">
                {question.tags.map((tag) => (
                  <span
                    key={tag}
                    className="inline-flex items-center text-[10px] font-mono text-slate-500 bg-white px-1.5 py-0.5 rounded border border-navy-100"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div className="rounded-xl border-2 border-brand-300 bg-brand-50/30 p-4 mb-4 space-y-3">
            <div className="text-[10px] uppercase tracking-wider text-brand-700 font-semibold">
              Édition de l'énoncé (visible stagiaire)
            </div>
            <Textarea
              value={statement}
              onChange={(e) => setStatement(e.target.value)}
              rows={6}
              placeholder="Texte de la question rédigée…"
              className="bg-white"
            />
            <div>
              <Label htmlFor={`tags-${question.id}`} className="text-xs">
                Tags (séparés par des virgules)
              </Label>
              <Input
                id={`tags-${question.id}`}
                value={tagsInput}
                onChange={(e) => setTagsInput(e.target.value)}
                placeholder="module-c, capa-3-5t, qr, ..."
                className="font-mono text-xs"
              />
              <p className="text-[11px] text-slate-500 mt-1">
                Le préfixe <code>module-x</code> sert au filtrage par module.
              </p>
            </div>
          </div>
        )}

        {/* Édition réponse-modèle, barème, note max, difficulté */}
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
          <div className="flex items-center gap-3">
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
            <ConfirmAction
              action={deleteQuestion.bind(null, question.id)}
              title="Supprimer cette question ?"
              description={`L'énoncé "${question.statement.slice(0, 100)}${question.statement.length > 100 ? "…" : ""}" sera supprimé définitivement, ainsi que son rattachement à tous les quiz. Cette action est irréversible.`}
              confirmLabel="Supprimer définitivement"
              successMsg="Question supprimée"
              icon={<Trash2 className="h-3.5 w-3.5" />}
              iconLabel="Supprimer la question"
              tone="rose"
              variant="soft"
            />
          </div>
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
