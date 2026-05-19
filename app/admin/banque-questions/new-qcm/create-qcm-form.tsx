"use client";
import { useState, useTransition, useMemo } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { useToast } from "@/components/ui/toast";
import { createQcmQuestion } from "../actions";
import {
  Save,
  Loader2,
  Plus,
  Trash2,
  CheckCircle2,
  CheckSquare,
  Square,
  AlertCircle,
} from "lucide-react";

interface Formation {
  slug: string;
  code: string;
  title: string;
}
interface ModuleOpt {
  id: string;
  title: string;
  slug: string;
  formation_modules: Array<{ formation_id: string }>;
}

export function CreateQcmForm({
  formations,
  modules,
}: {
  formations: Formation[];
  modules: ModuleOpt[];
}) {
  const { toast } = useToast();
  const [pending, start] = useTransition();
  const [success, setSuccess] = useState(false);

  const [f, setF] = useState({
    formation_slug: formations[0]?.slug ?? "",
    module_id: "",
    statement: "",
    choices: [
      { label: "", is_correct: false },
      { label: "", is_correct: false },
    ],
    difficulty: "moyen" as "facile" | "moyen" | "difficile",
    max_score: 1,
    tags_csv: "",
    explanation: "",
    active: true,
  });

  // Filtre les modules rattachés à la formation sélectionnée
  const formationIdBySlug = useMemo(() => {
    return null; // côté client on n'a pas l'id, on laisse tous les modules pour l'instant
  }, []);

  function addChoice() {
    if (f.choices.length >= 8) return;
    setF((s) => ({
      ...s,
      choices: [...s.choices, { label: "", is_correct: false }],
    }));
  }
  function removeChoice(idx: number) {
    if (f.choices.length <= 2) return;
    setF((s) => ({
      ...s,
      choices: s.choices.filter((_, i) => i !== idx),
    }));
  }
  function updateChoice(idx: number, patch: Partial<{ label: string; is_correct: boolean }>) {
    setF((s) => ({
      ...s,
      choices: s.choices.map((c, i) => (i === idx ? { ...c, ...patch } : c)),
    }));
  }

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!f.statement.trim()) {
      toast("Énoncé requis", "error");
      return;
    }
    if (f.choices.filter((c) => c.label.trim()).length < 2) {
      toast("Au moins 2 choix non-vides requis", "error");
      return;
    }
    if (!f.choices.some((c) => c.is_correct)) {
      toast("Cochez au moins une bonne réponse", "error");
      return;
    }

    const tags = f.tags_csv
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);

    start(async () => {
      const res = await createQcmQuestion({
        formation_slug: f.formation_slug,
        module_id: f.module_id || null,
        statement: f.statement.trim(),
        choices: f.choices
          .filter((c) => c.label.trim())
          .map((c) => ({ label: c.label.trim(), is_correct: c.is_correct })),
        difficulty: f.difficulty,
        max_score: f.max_score,
        tags,
        explanation: f.explanation.trim() || null,
        active: f.active,
      });
      if (!res.ok) {
        toast(res.error, "error");
        return;
      }
      setSuccess(true);
      toast("QCM créé avec succès", "success");
    });
  }

  if (success) {
    return (
      <div className="space-y-4 text-center py-6">
        <div className="mx-auto h-14 w-14 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
          <CheckCircle2 className="h-7 w-7" />
        </div>
        <h2 className="font-display text-xl font-semibold text-navy-900">
          QCM créé
        </h2>
        <p className="text-sm text-slate-600 max-w-md mx-auto">
          La question est ajoutée à la banque{" "}
          {f.active ? "et active" : "(en brouillon)"}.
        </p>
        <div className="flex items-center justify-center gap-2 pt-2">
          <Link href="/admin/banque-questions">
            <Button variant="secondary">Retour à la banque</Button>
          </Link>
          <Button onClick={() => window.location.reload()}>
            Créer un autre QCM
          </Button>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} className="space-y-6">
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <Label>
            Formation <span className="text-rose-600">*</span>
          </Label>
          <Select
            value={f.formation_slug}
            onChange={(e) => setF((s) => ({ ...s, formation_slug: e.target.value }))}
            required
          >
            {formations.map((fo) => (
              <option key={fo.slug} value={fo.slug}>
                {fo.code} — {fo.title}
              </option>
            ))}
          </Select>
        </div>
        <div>
          <Label>Module (optionnel)</Label>
          <Select
            value={f.module_id}
            onChange={(e) => setF((s) => ({ ...s, module_id: e.target.value }))}
          >
            <option value="">— Sans module spécifique —</option>
            {modules.map((m) => (
              <option key={m.id} value={m.id}>
                {m.title}
              </option>
            ))}
          </Select>
        </div>
      </div>

      <div>
        <Label>
          Énoncé <span className="text-rose-600">*</span>
        </Label>
        <Textarea
          value={f.statement}
          onChange={(e) => setF((s) => ({ ...s, statement: e.target.value }))}
          placeholder="Quelle est la durée maximale de conduite hebdomadaire selon le règlement (CE) 561/2006 ?"
          rows={3}
          autoFocus
        />
      </div>

      <div>
        <div className="flex items-center justify-between mb-2">
          <Label>
            Choix de réponses <span className="text-rose-600">*</span>
          </Label>
          <span className="text-xs text-slate-500">
            Cochez la (ou les) bonne(s) réponse(s)
          </span>
        </div>
        <div className="space-y-2">
          {f.choices.map((c, idx) => (
            <div key={idx} className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => updateChoice(idx, { is_correct: !c.is_correct })}
                className={
                  "shrink-0 h-9 w-9 rounded-lg border flex items-center justify-center transition " +
                  (c.is_correct
                    ? "bg-emerald-50 border-emerald-400 text-emerald-700"
                    : "bg-white border-navy-200 text-slate-400 hover:text-navy-700")
                }
                title={c.is_correct ? "Bonne réponse" : "Marquer comme bonne réponse"}
              >
                {c.is_correct ? (
                  <CheckSquare className="h-4 w-4" />
                ) : (
                  <Square className="h-4 w-4" />
                )}
              </button>
              <Input
                value={c.label}
                onChange={(e) => updateChoice(idx, { label: e.target.value })}
                placeholder={`Choix ${idx + 1}`}
              />
              <button
                type="button"
                onClick={() => removeChoice(idx)}
                disabled={f.choices.length <= 2}
                className="shrink-0 h-9 w-9 rounded-lg border border-rose-200 bg-rose-50 text-rose-700 hover:bg-rose-100 disabled:opacity-30 disabled:cursor-not-allowed flex items-center justify-center"
                title="Supprimer ce choix"
              >
                <Trash2 className="h-3.5 w-3.5" />
              </button>
            </div>
          ))}
        </div>
        <button
          type="button"
          onClick={addChoice}
          disabled={f.choices.length >= 8}
          className="mt-2 inline-flex items-center gap-1.5 text-sm text-brand-700 hover:text-brand-900 disabled:opacity-50"
        >
          <Plus className="h-3.5 w-3.5" /> Ajouter un choix ({f.choices.length}/8)
        </button>
        {!f.choices.some((c) => c.is_correct) && (
          <div className="mt-3 rounded-lg border border-amber-300 bg-amber-50/60 px-3 py-2 text-xs text-amber-900 flex items-start gap-2">
            <AlertCircle className="h-4 w-4 mt-0.5 shrink-0" />
            <span>
              Aucune bonne réponse cochée — la question ne sera pas valide.
            </span>
          </div>
        )}
      </div>

      <div className="grid md:grid-cols-3 gap-4">
        <div>
          <Label>Difficulté</Label>
          <Select
            value={f.difficulty}
            onChange={(e) =>
              setF((s) => ({ ...s, difficulty: e.target.value as any }))
            }
          >
            <option value="facile">Facile</option>
            <option value="moyen">Moyen</option>
            <option value="difficile">Difficile</option>
          </Select>
        </div>
        <div>
          <Label>Points (max_score)</Label>
          <Input
            type="number"
            min={0.5}
            max={20}
            step={0.5}
            value={f.max_score}
            onChange={(e) =>
              setF((s) => ({ ...s, max_score: Number(e.target.value) }))
            }
          />
        </div>
        <div>
          <Label>Tags (séparés par virgule)</Label>
          <Input
            value={f.tags_csv}
            onChange={(e) => setF((s) => ({ ...s, tags_csv: e.target.value }))}
            placeholder="ch:01, theme:reglementation"
          />
        </div>
      </div>

      <div>
        <Label>Explication (optionnelle, visible après réponse)</Label>
        <Textarea
          value={f.explanation}
          onChange={(e) => setF((s) => ({ ...s, explanation: e.target.value }))}
          placeholder="56 h max sur une semaine (du lundi 00:00 au dimanche 24:00), avec un repos compensateur si dépassement."
          rows={2}
        />
      </div>

      <label className="flex items-center gap-2 text-sm text-navy-900">
        <input
          type="checkbox"
          checked={f.active}
          onChange={(e) => setF((s) => ({ ...s, active: e.target.checked }))}
          className="h-4 w-4 rounded border-navy-300"
        />
        <span>
          <strong>Active immédiatement</strong> (sinon brouillon — à valider plus tard)
        </span>
      </label>

      <div className="flex items-center justify-end gap-2 pt-4 border-t border-navy-50">
        <Link href="/admin/banque-questions">
          <Button variant="secondary" type="button" disabled={pending}>
            Annuler
          </Button>
        </Link>
        <Button type="submit" variant="gold" disabled={pending}>
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Création…
            </>
          ) : (
            <>
              <Save className="h-4 w-4" />
              Créer le QCM
            </>
          )}
        </Button>
      </div>
    </form>
  );
}
