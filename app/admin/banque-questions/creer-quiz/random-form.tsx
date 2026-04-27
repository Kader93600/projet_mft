"use client";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Shuffle } from "lucide-react";
import { createRandomQuiz } from "./actions";

export function RandomQuizForm({
  formationStats,
  initialFormation,
}: {
  formationStats: any[];
  initialFormation?: string;
}) {
  const [formationSlug, setFormationSlug] = useState(initialFormation ?? "");
  const focused = formationStats.find((f) => f.slug === formationSlug);

  return (
    <form action={createRandomQuiz} className="space-y-5">
      <div>
        <Label htmlFor="title">Titre du quiz</Label>
        <Input
          id="title"
          name="title"
          required
          placeholder="Ex. Examen blanc — Capacité -3,5T n°1"
        />
      </div>

      <div>
        <Label htmlFor="description">Description (optionnel)</Label>
        <Textarea id="description" name="description" rows={2} />
      </div>

      <div>
        <Label htmlFor="formation_slug">Formation</Label>
        <select
          id="formation_slug"
          name="formation_slug"
          required
          value={formationSlug}
          onChange={(e) => setFormationSlug(e.target.value)}
          className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5"
        >
          <option value="">— Choisir —</option>
          {formationStats
            .filter((f) => (f.qcm + f.qr) > 0)
            .map((f) => (
              <option key={f.slug} value={f.slug}>
                {f.code} ({f.qcm} QCM · {f.qr} QR)
              </option>
            ))}
        </select>
        {focused && (
          <p className="mt-1.5 text-xs text-slate-500">
            <strong>{focused.qcm}</strong> QCM actifs ·{" "}
            <strong>{focused.qr}</strong> QR actives disponibles
          </p>
        )}
      </div>

      <div className="grid sm:grid-cols-2 gap-4">
        <div>
          <Label htmlFor="qcm_count">Nombre de QCM</Label>
          <Input
            id="qcm_count"
            name="qcm_count"
            type="number"
            min={0}
            max={focused?.qcm ?? 100}
            defaultValue={Math.min(30, focused?.qcm ?? 30)}
            required
          />
        </div>
        <div>
          <Label htmlFor="qr_count">Nombre de questions rédigées</Label>
          <Input
            id="qr_count"
            name="qr_count"
            type="number"
            min={0}
            max={focused?.qr ?? 20}
            defaultValue={0}
          />
        </div>
      </div>

      <fieldset>
        <Label>Difficultés à inclure</Label>
        <div className="grid sm:grid-cols-3 gap-2 mt-2">
          {(["facile", "moyen", "difficile"] as const).map((d) => (
            <label
              key={d}
              className="flex items-center gap-2 px-3 py-2 rounded-xl border border-navy-100 bg-ivory cursor-pointer hover:border-brand-300"
            >
              <input
                type="checkbox"
                name="difficulties[]"
                value={d}
                defaultChecked
                className="h-4 w-4 rounded border-navy-300"
              />
              <span className="text-sm capitalize">{d}</span>
            </label>
          ))}
        </div>
        <p className="text-xs text-slate-500 mt-1">
          Aucune cochée = toutes difficultés.
        </p>
      </fieldset>

      <div className="grid sm:grid-cols-2 gap-4">
        <div>
          <Label htmlFor="time_limit_min">Durée (minutes, 0 = illimité)</Label>
          <Input
            id="time_limit_min"
            name="time_limit_min"
            type="number"
            min={0}
            defaultValue={60}
          />
        </div>
        <div>
          <Label htmlFor="pass_threshold">Seuil de réussite (%)</Label>
          <Input
            id="pass_threshold"
            name="pass_threshold"
            type="number"
            min={0}
            max={100}
            defaultValue={70}
          />
        </div>
      </div>

      <label className="flex items-center gap-2 px-3 py-2 rounded-xl border border-gold-200 bg-gold-50 cursor-pointer">
        <input
          type="checkbox"
          name="is_mock_exam"
          className="h-4 w-4 rounded border-navy-300"
        />
        <span className="text-sm text-navy-900">
          <strong>Examen blanc officiel</strong> (mode chrono visible, anti-copie,
          détection sortie d'onglet)
        </span>
      </label>

      <div className="flex justify-end pt-2">
        <Button type="submit" variant="gold">
          <Shuffle className="h-4 w-4" /> Créer le quiz aléatoire
        </Button>
      </div>
    </form>
  );
}
