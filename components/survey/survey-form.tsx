"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Loader2, Send, Star } from "lucide-react";

export type SurveyType = "chaud" | "froid";
// "hub" = tuile compacte de /satisfaction (refresh en place, notes partielles OK).
// "page" = formulaire plein écran de /evaluation/[type] (écran de succès + redirect).
export type SurveyVariant = "hub" | "page";

export interface SurveyValues {
  note_globale: number;
  note_contenu: number;
  note_pedagogie: number;
  note_plateforme: number;
  note_accompagnement: number;
  recommandation: number | null;
  points_forts: string;
  points_ameliorer: string;
  situation_pro: string;
  situation_detail: string;
}

type NoteKey =
  | "note_globale"
  | "note_contenu"
  | "note_pedagogie"
  | "note_plateforme"
  | "note_accompagnement";

// Libellés des critères : volontairement distincts entre les deux parcours.
const HUB_NOTES: { field: NoteKey; label: string; required?: boolean }[] = [
  { field: "note_globale", label: "Note globale de la formation", required: true },
  { field: "note_contenu", label: "Qualité des contenus" },
  { field: "note_pedagogie", label: "Pédagogie / clarté" },
  { field: "note_plateforme", label: "Plateforme et outils" },
  { field: "note_accompagnement", label: "Accompagnement" },
];

const PAGE_NOTES: { field: NoteKey; label: string }[] = [
  { field: "note_globale", label: "Satisfaction globale" },
  { field: "note_contenu", label: "Qualité du contenu pédagogique" },
  { field: "note_pedagogie", label: "Pédagogie et clarté" },
  { field: "note_plateforme", label: "Plateforme et ergonomie" },
  { field: "note_accompagnement", label: "Accompagnement / support" },
];

interface SurveyFormProps {
  type: SurveyType;
  variant: SurveyVariant;
  onSubmit: (values: SurveyValues) => Promise<void>;
  // Variant "page" : route vers laquelle rediriger après l'écran de succès.
  redirectTo?: string;
}

export function SurveyForm({ type, variant, onSubmit, redirectTo }: SurveyFormProps) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [ok, setOk] = useState(false);
  const [values, setValues] = useState<SurveyValues>(() => ({
    note_globale: 0,
    note_contenu: 0,
    note_pedagogie: 0,
    note_plateforme: 0,
    note_accompagnement: 0,
    recommandation: null,
    points_forts: "",
    points_ameliorer: "",
    situation_pro: variant === "page" ? "emploi" : "",
    situation_detail: "",
  }));

  const set = <K extends keyof SurveyValues>(k: K, v: SurveyValues[K]) =>
    setValues((s) => ({ ...s, [k]: v }));

  function handleSubmit() {
    setError(null);
    // Validation client : uniquement le parcours "page". Le "hub" s'appuie sur
    // la validation serveur (note_globale + NPS), comme à l'origine.
    if (variant === "page") {
      const notes = [
        values.note_globale,
        values.note_contenu,
        values.note_pedagogie,
        values.note_plateforme,
        values.note_accompagnement,
      ];
      if (notes.some((v) => !v)) {
        setError("Merci de noter tous les critères.");
        return;
      }
      if (values.recommandation === null) {
        setError("Merci d'indiquer votre recommandation.");
        return;
      }
    }
    start(async () => {
      try {
        await onSubmit(values);
        if (variant === "page") {
          setOk(true);
          if (redirectTo) setTimeout(() => router.push(redirectTo), 1600);
        } else {
          router.refresh();
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : "Erreur");
      }
    });
  }

  if (ok && variant === "page") {
    return (
      <div className="text-center py-10">
        <div className="mx-auto h-12 w-12 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
          <Send className="h-5 w-5" />
        </div>
        <p className="mt-4 font-medium text-navy-900">
          Merci ! Votre retour nous aide à progresser.
        </p>
      </div>
    );
  }

  const layoutProps = { type, values, set, pending, error, onSubmit: handleSubmit };
  return variant === "hub" ? (
    <HubLayout {...layoutProps} />
  ) : (
    <PageLayout {...layoutProps} />
  );
}

interface LayoutProps {
  type: SurveyType;
  values: SurveyValues;
  set: <K extends keyof SurveyValues>(k: K, v: SurveyValues[K]) => void;
  pending: boolean;
  error: string | null;
  onSubmit: () => void;
}

function HubLayout({ type, values, set, pending, error, onSubmit }: LayoutProps) {
  return (
    <form
      className="space-y-5"
      onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
    >
      {HUB_NOTES.map((n) => (
        <div key={n.field}>
          <Label>
            {n.label}
            {n.required && <span className="text-rose-700"> *</span>}
          </Label>
          <Stars
            value={values[n.field]}
            onChange={(v) => set(n.field, v)}
            variant="hub"
          />
        </div>
      ))}

      <div>
        <Label htmlFor="recommandation">
          Recommanderiez-vous cette formation ? (NPS, 0–10){" "}
          <span className="text-rose-700">*</span>
        </Label>
        <Nps
          value={values.recommandation}
          onChange={(v) => set("recommandation", v)}
          variant="hub"
        />
      </div>

      <div>
        <Label htmlFor="points_forts">Points forts</Label>
        <Textarea
          id="points_forts"
          rows={3}
          value={values.points_forts}
          onChange={(e) => set("points_forts", e.target.value)}
        />
      </div>
      <div>
        <Label htmlFor="points_ameliorer">Points à améliorer</Label>
        <Textarea
          id="points_ameliorer"
          rows={3}
          value={values.points_ameliorer}
          onChange={(e) => set("points_ameliorer", e.target.value)}
        />
      </div>

      {type === "froid" && (
        <>
          <div>
            <Label htmlFor="situation_pro">Votre situation actuelle</Label>
            <select
              id="situation_pro"
              value={values.situation_pro}
              onChange={(e) => set("situation_pro", e.target.value)}
              className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
            >
              <option value="">— Sélectionner —</option>
              <option value="emploi">En emploi dans le secteur visé</option>
              <option value="emploi_autre">En emploi hors secteur visé</option>
              <option value="formation">En poursuite d'études</option>
              <option value="recherche">En recherche d'emploi</option>
              <option value="autre">Autre</option>
            </select>
          </div>
          <div>
            <Label htmlFor="situation_detail">
              Précisez (entreprise, poste, projet…)
            </Label>
            <Textarea
              id="situation_detail"
              rows={2}
              value={values.situation_detail}
              onChange={(e) => set("situation_detail", e.target.value)}
            />
          </div>
        </>
      )}

      {error && (
        <div className="text-sm text-rose-700 bg-rose-50 border border-rose-200 rounded-lg p-3">
          {error}
        </div>
      )}

      <div className="flex justify-end">
        <Button type="submit" variant="gold" disabled={pending}>
          {pending ? "Envoi…" : "Soumettre"}
        </Button>
      </div>
    </form>
  );
}

function PageLayout({ type, values, set, pending, error, onSubmit }: LayoutProps) {
  return (
    <div className="space-y-6">
      <div>
        <h3 className="font-display font-semibold text-navy-900 mb-1">
          Votre appréciation
        </h3>
        <p className="text-xs text-slate-500 mb-3">Notez chaque critère de 1 à 5.</p>
        {PAGE_NOTES.map((n) => (
          <div
            key={n.field}
            className="flex items-center justify-between py-3 border-b border-navy-50"
          >
            <span className="text-sm text-navy-900 font-medium">{n.label}</span>
            <Stars
              value={values[n.field]}
              onChange={(v) => set(n.field, v)}
              variant="page"
            />
          </div>
        ))}
      </div>

      <div>
        <h3 className="font-display font-semibold text-navy-900 mb-2">
          Recommanderiez-vous cette formation ?
        </h3>
        <p className="text-xs text-slate-500 mb-3">
          0 = très peu probable · 10 = extrêmement probable
        </p>
        <Nps
          value={values.recommandation}
          onChange={(v) => set("recommandation", v)}
          variant="page"
        />
      </div>

      {type === "froid" && (
        <div>
          <h3 className="font-display font-semibold text-navy-900 mb-2">
            Votre situation professionnelle actuelle
          </h3>
          <div className="grid grid-cols-2 gap-2">
            {[
              { v: "emploi", l: "En emploi" },
              { v: "formation", l: "En formation" },
              { v: "recherche", l: "En recherche" },
              { v: "autre", l: "Autre" },
            ].map((o) => (
              <button
                key={o.v}
                type="button"
                onClick={() => set("situation_pro", o.v)}
                className={
                  "px-4 py-2.5 rounded-xl border text-sm font-medium transition-all " +
                  (values.situation_pro === o.v
                    ? "bg-navy-900 text-white border-navy-900"
                    : "bg-white text-slate-700 border-navy-100 hover:border-navy-300")
                }
              >
                {o.l}
              </button>
            ))}
          </div>
          <textarea
            rows={2}
            placeholder="Précisez si vous le souhaitez…"
            value={values.situation_detail}
            onChange={(e) => set("situation_detail", e.target.value)}
            className="mt-3 w-full rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm"
          />
        </div>
      )}

      <div className="grid md:grid-cols-2 gap-4">
        <label className="block">
          <span className="block text-sm font-medium text-navy-900 mb-1">
            Points forts
          </span>
          <textarea
            rows={4}
            value={values.points_forts}
            onChange={(e) => set("points_forts", e.target.value)}
            className="w-full rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm"
            placeholder="Ce qui vous a plu…"
          />
        </label>
        <label className="block">
          <span className="block text-sm font-medium text-navy-900 mb-1">
            À améliorer
          </span>
          <textarea
            rows={4}
            value={values.points_ameliorer}
            onChange={(e) => set("points_ameliorer", e.target.value)}
            className="w-full rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm"
            placeholder="Suggestions d'amélioration…"
          />
        </label>
      </div>

      {error && (
        <div className="rounded-xl bg-rose-50 text-rose-800 text-sm px-4 py-3 border border-rose-200">
          {error}
        </div>
      )}

      <div className="flex justify-end pt-4 border-t border-navy-50">
        <Button onClick={onSubmit} disabled={pending} variant="gold" size="lg">
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" /> Envoi…
            </>
          ) : (
            <>
              <Send className="h-4 w-4" /> Envoyer mon évaluation
            </>
          )}
        </Button>
      </div>
    </div>
  );
}

function Stars({
  value,
  onChange,
  variant,
}: {
  value: number;
  onChange: (n: number) => void;
  variant: SurveyVariant;
}) {
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4, 5].map((n) => (
        <button
          key={n}
          type="button"
          onClick={() => onChange(n)}
          aria-label={`${n} étoile${n > 1 ? "s" : ""}`}
          className={variant === "hub" ? "p-1" : "p-1 hover:scale-110 transition-transform"}
        >
          <Star
            className={
              variant === "hub"
                ? "h-7 w-7 " +
                  (n <= value
                    ? "fill-gold-500 text-gold-500"
                    : "text-slate-300 hover:text-gold-400")
                : n <= value
                ? "h-6 w-6 fill-gold-400 text-gold-500"
                : "h-6 w-6 text-slate-300"
            }
          />
        </button>
      ))}
    </div>
  );
}

function Nps({
  value,
  onChange,
  variant,
}: {
  value: number | null;
  onChange: (n: number) => void;
  variant: SurveyVariant;
}) {
  if (variant === "hub") {
    return (
      <div>
        <div className="grid grid-cols-11 gap-1 mt-1">
          {Array.from({ length: 11 }).map((_, i) => {
            const active = value === i;
            return (
              <button
                type="button"
                key={i}
                onClick={() => onChange(i)}
                aria-label={`Note ${i}`}
                className={
                  "h-10 rounded-lg text-sm font-semibold border transition " +
                  (active
                    ? "bg-navy-900 text-white border-navy-900"
                    : i <= 6
                    ? "bg-white text-rose-700 border-rose-200 hover:border-rose-400"
                    : i <= 8
                    ? "bg-white text-amber-700 border-amber-200 hover:border-amber-400"
                    : "bg-white text-emerald-700 border-emerald-200 hover:border-emerald-400")
                }
              >
                {i}
              </button>
            );
          })}
        </div>
        <div className="flex justify-between mt-1 text-[10px] text-slate-500 font-mono">
          <span>0 — Pas du tout</span>
          <span>10 — Absolument</span>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-wrap gap-1.5">
      {Array.from({ length: 11 }, (_, n) => (
        <button
          key={n}
          type="button"
          onClick={() => onChange(n)}
          className={
            "h-9 w-9 rounded-lg border text-sm font-semibold transition-all " +
            (value === n
              ? n >= 9
                ? "bg-emerald-600 text-white border-emerald-600"
                : n >= 7
                ? "bg-gold-500 text-navy-900 border-gold-500"
                : "bg-rose-500 text-white border-rose-500"
              : "bg-white text-slate-700 border-navy-100 hover:border-navy-300")
          }
        >
          {n}
        </button>
      ))}
    </div>
  );
}
