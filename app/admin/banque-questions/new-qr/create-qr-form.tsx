"use client";
import { useState, useTransition } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { useToast } from "@/components/ui/toast";
import { createQrQuestion } from "../actions";
import { Save, Loader2, CheckCircle2 } from "lucide-react";

interface Formation {
  slug: string;
  code: string;
  title: string;
}
interface ModuleOpt {
  id: string;
  title: string;
  slug: string;
}

export function CreateQrForm({
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
    expected_answer: "",
    scoring_grid: "",
    difficulty: "moyen" as "facile" | "moyen" | "difficile",
    max_score: 2,
    tags_csv: "",
    explanation: "",
    active: true,
  });

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!f.statement.trim()) {
      toast("Énoncé requis", "error");
      return;
    }
    if (!f.expected_answer.trim()) {
      toast("Réponse modèle requise", "error");
      return;
    }
    const tags = f.tags_csv
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);
    start(async () => {
      const res = await createQrQuestion({
        formation_slug: f.formation_slug,
        module_id: f.module_id || null,
        statement: f.statement.trim(),
        expected_answer: f.expected_answer.trim(),
        scoring_grid: f.scoring_grid.trim() || null,
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
      toast("Question rédigée créée", "success");
    });
  }

  if (success) {
    return (
      <div className="space-y-4 text-center py-6">
        <div className="mx-auto h-14 w-14 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
          <CheckCircle2 className="h-7 w-7" />
        </div>
        <h2 className="font-display text-xl font-semibold text-navy-900">
          QR créée
        </h2>
        <p className="text-sm text-slate-600 max-w-md mx-auto">
          La question rédigée est ajoutée à la banque{" "}
          {f.active ? "et active" : "(en brouillon)"}. Les formateurs
          habilités pourront corriger les copies des stagiaires.
        </p>
        <div className="flex items-center justify-center gap-2 pt-2">
          <Link href="/admin/banque-questions">
            <Button variant="secondary">Retour à la banque</Button>
          </Link>
          <Button onClick={() => window.location.reload()}>
            Créer une autre QR
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
          placeholder="Expliquez le rôle du gestionnaire de transport dans une entreprise de transport routier de marchandises (5 lignes minimum)."
          rows={3}
          autoFocus
        />
      </div>

      <div>
        <Label>
          Réponse modèle (référence formateur) <span className="text-rose-600">*</span>
        </Label>
        <Textarea
          value={f.expected_answer}
          onChange={(e) => setF((s) => ({ ...s, expected_answer: e.target.value }))}
          placeholder="Le gestionnaire de transport est responsable de la conformité réglementaire de l'entreprise (capacité professionnelle), du respect des temps de conduite/repos, de la sécurité des opérations, du choix des conducteurs et de la maintenance du parc..."
          rows={5}
        />
        <p className="mt-1 text-xs text-slate-500">
          Non visible par le stagiaire. Sert au formateur pour comparer la copie.
        </p>
      </div>

      <div>
        <Label>Barème détaillé (optionnel)</Label>
        <Textarea
          value={f.scoring_grid}
          onChange={(e) => setF((s) => ({ ...s, scoring_grid: e.target.value }))}
          placeholder="Capacité professionnelle 1pt · Temps de conduite 1pt · Sécurité opérations 1pt · Maintenance parc 1pt · Rédaction claire 1pt"
          rows={2}
        />
        <p className="mt-1 text-xs text-slate-500">
          Décompose les points attendus. Affiché au formateur pendant la correction.
        </p>
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
            placeholder="ch:03, theme:management"
          />
        </div>
      </div>

      <div>
        <Label>Explication (optionnelle, visible stagiaire après correction)</Label>
        <Textarea
          value={f.explanation}
          onChange={(e) => setF((s) => ({ ...s, explanation: e.target.value }))}
          placeholder="Cette question évalue votre compréhension globale du rôle réglementaire du gestionnaire de transport."
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
              Créer la QR
            </>
          )}
        </Button>
      </div>
    </form>
  );
}
