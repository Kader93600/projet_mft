"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { submitSurvey } from "./actions";
import { Loader2, Send, Star } from "lucide-react";

function Stars({
  value,
  onChange,
}: {
  value: number;
  onChange: (n: number) => void;
}) {
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4, 5].map((n) => (
        <button
          key={n}
          type="button"
          onClick={() => onChange(n)}
          className="p-1 hover:scale-110 transition-transform"
          aria-label={`${n} étoile${n > 1 ? "s" : ""}`}
        >
          <Star
            className={
              n <= value
                ? "h-6 w-6 fill-gold-400 text-gold-500"
                : "h-6 w-6 text-slate-300"
            }
          />
        </button>
      ))}
    </div>
  );
}

function NPS({
  value,
  onChange,
}: {
  value: number | null;
  onChange: (n: number) => void;
}) {
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

function Row({
  label,
  value,
  onChange,
}: {
  label: string;
  value: number;
  onChange: (n: number) => void;
}) {
  return (
    <div className="flex items-center justify-between py-3 border-b border-navy-50">
      <span className="text-sm text-navy-900 font-medium">{label}</span>
      <Stars value={value} onChange={onChange} />
    </div>
  );
}

export function SurveyForm({ type }: { type: "chaud" | "froid" }) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState(false);
  const [f, setF] = useState({
    note_globale: 0,
    note_contenu: 0,
    note_pedagogie: 0,
    note_plateforme: 0,
    note_accompagnement: 0,
    recommandation: null as number | null,
    points_forts: "",
    points_ameliorer: "",
    situation_pro: "emploi" as "emploi" | "formation" | "recherche" | "autre",
    situation_detail: "",
  });

  const submit = () => {
    setErr(null);
    // Validations côté client
    const required = [
      f.note_globale,
      f.note_contenu,
      f.note_pedagogie,
      f.note_plateforme,
      f.note_accompagnement,
    ];
    if (required.some((v) => !v)) {
      setErr("Merci de noter tous les critères.");
      return;
    }
    if (f.recommandation === null) {
      setErr("Merci d'indiquer votre recommandation.");
      return;
    }
    start(async () => {
      try {
        const payload: any = {
          type,
          note_globale: f.note_globale,
          note_contenu: f.note_contenu,
          note_pedagogie: f.note_pedagogie,
          note_plateforme: f.note_plateforme,
          note_accompagnement: f.note_accompagnement,
          recommandation: f.recommandation,
          points_forts: f.points_forts || undefined,
          points_ameliorer: f.points_ameliorer || undefined,
        };
        if (type === "froid") {
          payload.situation_pro = f.situation_pro;
          payload.situation_detail = f.situation_detail || undefined;
        }
        await submitSurvey(payload);
        setOk(true);
        setTimeout(() => router.push("/dashboard"), 1600);
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  if (ok) {
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

  return (
    <div className="space-y-6">
      <div>
        <h3 className="font-display font-semibold text-navy-900 mb-1">
          Votre appréciation
        </h3>
        <p className="text-xs text-slate-500 mb-3">Notez chaque critère de 1 à 5.</p>
        <Row
          label="Satisfaction globale"
          value={f.note_globale}
          onChange={(n) => setF({ ...f, note_globale: n })}
        />
        <Row
          label="Qualité du contenu pédagogique"
          value={f.note_contenu}
          onChange={(n) => setF({ ...f, note_contenu: n })}
        />
        <Row
          label="Pédagogie et clarté"
          value={f.note_pedagogie}
          onChange={(n) => setF({ ...f, note_pedagogie: n })}
        />
        <Row
          label="Plateforme et ergonomie"
          value={f.note_plateforme}
          onChange={(n) => setF({ ...f, note_plateforme: n })}
        />
        <Row
          label="Accompagnement / support"
          value={f.note_accompagnement}
          onChange={(n) => setF({ ...f, note_accompagnement: n })}
        />
      </div>

      <div>
        <h3 className="font-display font-semibold text-navy-900 mb-2">
          Recommanderiez-vous cette formation ?
        </h3>
        <p className="text-xs text-slate-500 mb-3">
          0 = très peu probable · 10 = extrêmement probable
        </p>
        <NPS
          value={f.recommandation}
          onChange={(n) => setF({ ...f, recommandation: n })}
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
                onClick={() => setF({ ...f, situation_pro: o.v as any })}
                className={
                  "px-4 py-2.5 rounded-xl border text-sm font-medium transition-all " +
                  (f.situation_pro === o.v
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
            value={f.situation_detail}
            onChange={(e) => setF({ ...f, situation_detail: e.target.value })}
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
            value={f.points_forts}
            onChange={(e) => setF({ ...f, points_forts: e.target.value })}
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
            value={f.points_ameliorer}
            onChange={(e) => setF({ ...f, points_ameliorer: e.target.value })}
            className="w-full rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm"
            placeholder="Suggestions d'amélioration…"
          />
        </label>
      </div>

      {err && (
        <div className="rounded-xl bg-rose-50 text-rose-800 text-sm px-4 py-3 border border-rose-200">
          {err}
        </div>
      )}

      <div className="flex justify-end pt-4 border-t border-navy-50">
        <Button onClick={submit} disabled={pending} variant="gold" size="lg">
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
