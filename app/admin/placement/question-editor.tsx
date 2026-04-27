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
type Q = {
  id: string;
  bloc_id: number;
  prompt: string;
  choices: string[];
  correct_index: number;
  difficulty: string;
  order: number;
  active: boolean;
};

export function QuestionEditor({
  blocs,
  mode,
  question,
}: {
  blocs: Bloc[];
  mode: "create" | "edit";
  question?: Q;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [blocId, setBlocId] = useState<number>(
    question?.bloc_id ?? blocs[0]?.id ?? 0
  );
  const [prompt, setPrompt] = useState(question?.prompt ?? "");
  const [choices, setChoices] = useState<string[]>(
    question?.choices?.length ? question.choices : ["", ""]
  );
  const [correctIndex, setCorrectIndex] = useState<number>(
    question?.correct_index ?? 0
  );
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
    start(async () => {
      try {
        const payload = {
          bloc_id: blocId,
          prompt,
          choices: choices.map((c) => c.trim()).filter(Boolean),
          correct_index: correctIndex,
          difficulty: difficulty as any,
          order,
          active: question?.active ?? true,
        };
        if (payload.choices.length < 2) throw new Error("Au moins 2 choix");
        if (mode === "create") {
          await createPlacementQuestion(payload);
          // reset
          setPrompt("");
          setChoices(["", ""]);
          setCorrectIndex(0);
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
