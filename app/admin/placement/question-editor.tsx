"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { Trash2, Plus, Save, Loader2, EyeOff, Eye } from "lucide-react";
import {
  createPlacementQuestion,
  updatePlacementQuestion,
  deletePlacementQuestion,
  togglePlacementQuestion,
} from "./actions";

type Bloc = { id: number; code: string; title: string };
type FormationOpt = { slug: string; code: string; title: string };
type QType = "qcm" | "qr" | "image";
type Q = {
  id: string;
  bloc_id: number;
  qtype?: QType;
  formation_slug?: string;
  prompt: string;
  choices: string[];
  correct_index: number;
  expected_answer?: string | null;
  image_url?: string | null;
  difficulty: string;
  order: number;
  active: boolean;
};

export function QuestionEditor({
  blocs,
  formations,
  mode,
  question,
}: {
  blocs: Bloc[];
  formations: FormationOpt[];
  mode: "create" | "edit";
  question?: Q;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [blocId, setBlocId] = useState<number>(
    question?.bloc_id ?? blocs[0]?.id ?? 0
  );
  const [qtype, setQtype] = useState<QType>(question?.qtype ?? "qcm");
  const [formationSlug, setFormationSlug] = useState<string>(
    question?.formation_slug ?? formations[0]?.slug ?? ""
  );
  const [prompt, setPrompt] = useState(question?.prompt ?? "");
  const [choices, setChoices] = useState<string[]>(
    question?.choices?.length ? question.choices : ["", ""]
  );
  const [correctIndex, setCorrectIndex] = useState<number>(
    question?.correct_index ?? 0
  );
  const [expectedAnswer, setExpectedAnswer] = useState<string>(
    question?.expected_answer ?? ""
  );
  const [imageUrl, setImageUrl] = useState<string>(question?.image_url ?? "");
  const [difficulty, setDifficulty] = useState<string>(
    question?.difficulty ?? "standard"
  );
  const [order, setOrder] = useState<number>(question?.order ?? 0);

  function addChoice() {
    if (choices.length >= 6) return;
    setChoices([...choices, ""]);
  }
  function removeChoice(i: number) {
    if (choices.length <= 2) return;
    const next = choices.filter((_, idx) => idx !== i);
    setChoices(next);
    if (correctIndex >= next.length) setCorrectIndex(0);
  }

  function save() {
    setError(null);
    if (!formationSlug) {
      setError("Sélectionnez la formation associée");
      return;
    }
    start(async () => {
      try {
        const cleanedChoices = choices.map((c) => c.trim()).filter(Boolean);
        const payload: any = {
          bloc_id: blocId,
          qtype,
          formation_slug: formationSlug,
          prompt,
          choices: qtype === "qr" ? [] : cleanedChoices,
          correct_index: qtype === "qr" ? 0 : correctIndex,
          expected_answer:
            qtype === "qr" && expectedAnswer.trim()
              ? expectedAnswer.trim()
              : null,
          image_url:
            qtype === "image" && imageUrl.trim() ? imageUrl.trim() : null,
          difficulty: difficulty as any,
          order,
          active: question?.active ?? true,
        };

        if (mode === "create") {
          await createPlacementQuestion(payload);
          setPrompt("");
          setChoices(["", ""]);
          setCorrectIndex(0);
          setExpectedAnswer("");
          setImageUrl("");
          setOrder(0);
        } else if (question) {
          await updatePlacementQuestion({ id: question.id, ...payload });
        }
        router.refresh();
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      }
    });
  }

  function remove() {
    if (!question) return;
    if (!confirm("Supprimer cette question ?")) return;
    start(async () => {
      try {
        await deletePlacementQuestion(question.id);
        router.refresh();
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      }
    });
  }

  function toggle() {
    if (!question) return;
    start(async () => {
      try {
        await togglePlacementQuestion(question.id, !question.active);
        router.refresh();
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      }
    });
  }

  return (
    <div className="space-y-3">
      <div className="grid md:grid-cols-2 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Formation associée <span className="text-rose-600">*</span>
          </span>
          <Select
            value={formationSlug}
            onChange={(e) => setFormationSlug(e.target.value)}
            required
          >
            <option value="">— Sélectionner —</option>
            {formations.map((f) => (
              <option key={f.slug} value={f.slug}>
                {f.code} — {f.title}
              </option>
            ))}
          </Select>
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Type de question
          </span>
          <Select value={qtype} onChange={(e) => setQtype(e.target.value as QType)}>
            <option value="qcm">QCM (choix multiples)</option>
            <option value="qr">QR (réponse rédigée)</option>
            <option value="image">QCM avec image</option>
          </Select>
        </label>
      </div>
      <div className="grid md:grid-cols-3 gap-3">
        <Select
          value={String(blocId)}
          onChange={(e) => setBlocId(Number(e.target.value))}
        >
          {blocs.map((b) => (
            <option key={b.id} value={b.id}>
              {b.code} — {b.title}
            </option>
          ))}
        </Select>
        <Select
          value={difficulty}
          onChange={(e) => setDifficulty(e.target.value)}
        >
          <option value="facile">Facile</option>
          <option value="standard">Standard</option>
          <option value="difficile">Difficile</option>
        </Select>
        <Input
          type="number"
          value={order}
          onChange={(e) => setOrder(Number(e.target.value))}
          placeholder="Ordre"
        />
      </div>

      <Textarea
        value={prompt}
        onChange={(e) => setPrompt(e.target.value)}
        placeholder="Énoncé de la question…"
        rows={2}
      />

      {/* Image (conditionnel) */}
      {qtype === "image" && (
        <div>
          <label className="block text-xs font-medium text-slate-600 mb-1.5">
            URL de l'image <span className="text-rose-600">*</span>
          </label>
          <Input
            value={imageUrl}
            onChange={(e) => setImageUrl(e.target.value)}
            placeholder="https://…"
          />
          {imageUrl && (
            <img
              src={imageUrl}
              alt=""
              className="mt-2 max-h-48 rounded-lg border border-navy-100 object-contain"
            />
          )}
        </div>
      )}

      {/* QR : réponse-modèle */}
      {qtype === "qr" && (
        <div>
          <label className="block text-xs font-medium text-slate-600 mb-1.5">
            Réponse-modèle (correction manuelle)
          </label>
          <Textarea
            value={expectedAnswer}
            onChange={(e) => setExpectedAnswer(e.target.value)}
            placeholder="Réponse attendue, points clés à valider…"
            rows={3}
          />
        </div>
      )}

      {/* Choices (QCM ou Image) */}
      {qtype !== "qr" && (
      <div className="space-y-2">
        {choices.map((c, i) => (
          <div key={i} className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setCorrectIndex(i)}
              className={
                "h-6 w-6 shrink-0 rounded-full border flex items-center justify-center text-xs font-semibold " +
                (correctIndex === i
                  ? "bg-emerald-500 border-emerald-500 text-white"
                  : "border-slate-300 text-slate-500 hover:border-emerald-400")
              }
              title="Marquer comme bonne réponse"
            >
              {String.fromCharCode(65 + i)}
            </button>
            <Input
              value={c}
              onChange={(e) => {
                const next = [...choices];
                next[i] = e.target.value;
                setChoices(next);
              }}
              placeholder={`Choix ${String.fromCharCode(65 + i)}`}
            />
            <button
              type="button"
              onClick={() => removeChoice(i)}
              disabled={choices.length <= 2}
              className="text-slate-400 hover:text-rose-600 disabled:opacity-30"
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        ))}
        {choices.length < 6 && (
          <button
            type="button"
            onClick={addChoice}
            className="text-xs text-navy-700 hover:text-gold-700 inline-flex items-center gap-1"
          >
            <Plus className="h-3 w-3" /> Ajouter un choix
          </button>
        )}
      </div>
      )}

      {error && (
        <p className="text-sm text-rose-700 bg-rose-50 border border-rose-200 px-3 py-2 rounded-lg">
          {error}
        </p>
      )}

      <div className="flex items-center justify-between pt-1">
        <div className="flex items-center gap-2">
          <Button variant="gold" size="sm" onClick={save} disabled={pending}>
            {pending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <Save className="h-3.5 w-3.5" />
            )}
            {mode === "create" ? "Créer" : "Enregistrer"}
          </Button>
          {mode === "edit" && question && (
            <Button
              variant="secondary"
              size="sm"
              onClick={toggle}
              disabled={pending}
            >
              {question.active ? (
                <>
                  <EyeOff className="h-3.5 w-3.5" /> Désactiver
                </>
              ) : (
                <>
                  <Eye className="h-3.5 w-3.5" /> Activer
                </>
              )}
            </Button>
          )}
        </div>
        {mode === "edit" && question && (
          <Button
            variant="secondary"
            size="sm"
            onClick={remove}
            disabled={pending}
            className="text-rose-700 hover:bg-rose-50"
          >
            <Trash2 className="h-3.5 w-3.5" /> Supprimer
          </Button>
        )}
      </div>
    </div>
  );
}
