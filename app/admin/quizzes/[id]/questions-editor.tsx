"use client";
import { useState, useTransition, useRef } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/components/ui/toast";
import {
  Plus,
  Trash2,
  Check,
  Image as ImageIcon,
  X,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
import {
  createQuestion,
  updateQuestion,
  deleteQuestion,
  setChoices,
} from "../actions";
import { ImageUploader } from "@/components/admin/image-uploader";
import { useRouter } from "next/navigation";

interface Choice {
  id?: string;
  label: string;
  is_correct: boolean;
  order: number;
}

interface Question {
  id: string;
  statement: string;
  explanation: string | null;
  image_url: string | null;
  order: number;
  choices: Choice[];
}

export function QuestionsEditor({
  quizId,
  initialQuestions,
}: {
  quizId: string;
  initialQuestions: Question[];
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [openId, setOpenId] = useState<string | null>(null);

  function addQuestion() {
    startTransition(async () => {
      try {
        const next = initialQuestions.length;
        const q = await createQuestion({
          quiz_id: quizId,
          statement: "Nouvelle question",
          order: next,
        });
        toast("Question ajoutée", "success");
        setOpenId(q.id);
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div className="space-y-3">
      {initialQuestions.length === 0 && (
        <div className="text-center py-8 text-sm text-slate-400">
          Aucune question. Ajoutez-en une ci-dessous.
        </div>
      )}
      {initialQuestions.map((q, i) => (
        <QuestionCard
          key={q.id}
          quizId={quizId}
          question={q}
          index={i}
          open={openId === q.id}
          onToggle={() => setOpenId(openId === q.id ? null : q.id)}
        />
      ))}
      <div className="pt-2">
        <Button variant="gold" onClick={addQuestion} disabled={isPending}>
          <Plus className="h-4 w-4" /> Ajouter une question
        </Button>
      </div>
    </div>
  );
}

function QuestionCard({
  quizId,
  question,
  index,
  open,
  onToggle,
}: {
  quizId: string;
  question: Question;
  index: number;
  open: boolean;
  onToggle: () => void;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  const [statement, setStatement] = useState(question.statement);
  const [explanation, setExplanation] = useState(question.explanation ?? "");
  const [imageUrl, setImageUrl] = useState(question.image_url ?? "");
  const [choices, setLocalChoices] = useState<Choice[]>(
    question.choices
      .slice()
      .sort((a, b) => a.order - b.order)
      .map((c) => ({
        label: c.label,
        is_correct: c.is_correct,
        order: c.order,
      }))
  );

  function updateChoice(i: number, patch: Partial<Choice>) {
    setLocalChoices((cs) => cs.map((c, j) => (i === j ? { ...c, ...patch } : c)));
  }

  function addChoice() {
    setLocalChoices((cs) => [
      ...cs,
      { label: "", is_correct: false, order: cs.length },
    ]);
  }

  function removeChoice(i: number) {
    setLocalChoices((cs) => cs.filter((_, j) => j !== i).map((c, j) => ({ ...c, order: j })));
  }

  function onSave() {
    if (!choices.some((c) => c.is_correct)) {
      toast("Indiquez au moins une bonne réponse", "error");
      return;
    }
    if (choices.some((c) => !c.label.trim())) {
      toast("Toutes les réponses doivent avoir un libellé", "error");
      return;
    }
    startTransition(async () => {
      try {
        await updateQuestion(question.id, quizId, {
          statement,
          explanation: explanation || null,
          image_url: imageUrl || null,
          order: index,
        });
        await setChoices(question.id, quizId, choices);
        toast("Question enregistrée", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onDelete() {
    if (!confirm("Supprimer cette question ?")) return;
    startTransition(async () => {
      try {
        await deleteQuestion(question.id, quizId);
        toast("Question supprimée", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div className="rounded-xl border border-navy-100 bg-white overflow-hidden">
      <button
        type="button"
        onClick={onToggle}
        className="w-full flex items-center gap-3 px-4 py-3 hover:bg-navy-50/40 text-left"
      >
        <div className="h-7 w-7 rounded-lg bg-navy-900 text-gold-400 flex items-center justify-center text-xs font-semibold">
          {index + 1}
        </div>
        <div className="flex-1 min-w-0">
          <div className="text-sm font-medium text-navy-900 truncate">
            {statement || <span className="text-slate-400">Question sans titre</span>}
          </div>
          <div className="text-xs text-slate-500">
            {choices.length} réponse{choices.length > 1 ? "s" : ""} ·{" "}
            {choices.filter((c) => c.is_correct).length} correcte
            {choices.filter((c) => c.is_correct).length > 1 ? "s" : ""}
          </div>
        </div>
        {open ? (
          <ChevronUp className="h-4 w-4 text-slate-400" />
        ) : (
          <ChevronDown className="h-4 w-4 text-slate-400" />
        )}
      </button>

      {open && (
        <div className="px-4 py-4 border-t border-navy-100 space-y-4">
          <label className="block">
            <span className="block text-xs font-medium text-slate-600 mb-1.5">
              Énoncé
            </span>
            <Textarea
              rows={2}
              value={statement}
              onChange={(e) => setStatement(e.target.value)}
              placeholder="Énoncé de la question…"
            />
          </label>

          {/* Image (illustration de la question) */}
          <ImageUploader
            value={imageUrl}
            onChange={(url) => setImageUrl(url ?? "")}
            prefix={`questions/${question.id}`}
            label="Illustration de la question (optionnel)"
            ratio="video"
            hint="Image affichée au-dessus de l'énoncé. PNG/JPG/WebP, 5 Mo max."
          />

          {/* Choices */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-medium text-slate-600">
                Réponses ({choices.length})
              </span>
              <button
                type="button"
                onClick={addChoice}
                className="text-xs text-navy-700 hover:text-gold-700 inline-flex items-center gap-1"
              >
                <Plus className="h-3.5 w-3.5" /> Ajouter
              </button>
            </div>
            <div className="space-y-2">
              {choices.map((c, i) => (
                <div
                  key={i}
                  className={`flex items-center gap-2 p-2 rounded-lg border ${
                    c.is_correct
                      ? "border-emerald-200 bg-emerald-50/40"
                      : "border-navy-100 bg-white"
                  }`}
                >
                  <button
                    type="button"
                    onClick={() => updateChoice(i, { is_correct: !c.is_correct })}
                    title={c.is_correct ? "Retirer comme bonne réponse" : "Marquer comme bonne réponse"}
                    className={`h-7 w-7 rounded-md flex items-center justify-center shrink-0 ${
                      c.is_correct
                        ? "bg-emerald-600 text-white"
                        : "bg-navy-50 text-slate-400 hover:text-navy-700"
                    }`}
                  >
                    <Check className="h-4 w-4" />
                  </button>
                  <Input
                    value={c.label}
                    onChange={(e) => updateChoice(i, { label: e.target.value })}
                    placeholder={`Réponse ${String.fromCharCode(65 + i)}`}
                    className="flex-1"
                  />
                  <button
                    type="button"
                    onClick={() => removeChoice(i)}
                    className="h-7 w-7 rounded-md text-slate-400 hover:text-rose-600 hover:bg-rose-50 flex items-center justify-center"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              ))}
              {choices.length === 0 && (
                <div className="text-xs text-slate-400 py-4 text-center border border-dashed border-navy-100 rounded-lg">
                  Aucune réponse. Ajoutez-en au moins deux.
                </div>
              )}
            </div>
          </div>

          <label className="block">
            <span className="block text-xs font-medium text-slate-600 mb-1.5">
              Explication (affichée après la réponse)
            </span>
            <Textarea
              rows={3}
              value={explanation}
              onChange={(e) => setExplanation(e.target.value)}
              placeholder="Correction pédagogique, sources, rappel de cours…"
            />
          </label>

          <div className="flex items-center justify-between pt-2 border-t border-navy-100">
            <Button
              type="button"
              variant="danger"
              size="sm"
              onClick={onDelete}
              disabled={isPending}
            >
              <Trash2 className="h-4 w-4" /> Supprimer
            </Button>
            <Button type="button" onClick={onSave} disabled={isPending} size="sm">
              {isPending ? "Enregistrement…" : "Enregistrer la question"}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
