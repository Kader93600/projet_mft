"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Star } from "lucide-react";
import { submitSurvey } from "./actions";

export function SurveyForm({ type }: { type: "chaud" | "froid" }) {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  async function action(fd: FormData) {
    setError(null);
    setPending(true);
    try {
      await submitSurvey(type, fd);
      router.refresh();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Erreur");
      setPending(false);
    }
  }

  return (
    <form action={action} className="space-y-5">
      <Rating
        name="note_globale"
        label="Note globale de la formation"
        required
      />
      <Rating name="note_contenu" label="Qualité des contenus" />
      <Rating name="note_pedagogie" label="Pédagogie / clarté" />
      <Rating name="note_plateforme" label="Plateforme et outils" />
      <Rating name="note_accompagnement" label="Accompagnement" />

      <div>
        <Label htmlFor="recommandation">
          Recommanderiez-vous cette formation ? (NPS, 0–10){" "}
          <span className="text-rose-700">*</span>
        </Label>
        <NpsScale name="recommandation" />
      </div>

      <div>
        <Label htmlFor="points_forts">Points forts</Label>
        <Textarea id="points_forts" name="points_forts" rows={3} />
      </div>
      <div>
        <Label htmlFor="points_ameliorer">Points à améliorer</Label>
        <Textarea id="points_ameliorer" name="points_ameliorer" rows={3} />
      </div>

      {type === "froid" && (
        <>
          <div>
            <Label htmlFor="situation_pro">Votre situation actuelle</Label>
            <select
              id="situation_pro"
              name="situation_pro"
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
            <Textarea id="situation_detail" name="situation_detail" rows={2} />
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

function Rating({
  name,
  label,
  required,
}: {
  name: string;
  label: string;
  required?: boolean;
}) {
  const [v, setV] = useState<number>(0);
  return (
    <div>
      <Label>
        {label}
        {required && <span className="text-rose-700"> *</span>}
      </Label>
      <input type="hidden" name={name} value={v || ""} />
      <div className="flex gap-1">
        {[1, 2, 3, 4, 5].map((n) => (
          <button
            type="button"
            key={n}
            onClick={() => setV(n)}
            aria-label={`${n} étoile${n > 1 ? "s" : ""}`}
            className="p-1"
          >
            <Star
              className={
                "h-7 w-7 " +
                (n <= v
                  ? "fill-gold-500 text-gold-500"
                  : "text-slate-300 hover:text-gold-400")
              }
            />
          </button>
        ))}
      </div>
    </div>
  );
}

function NpsScale({ name }: { name: string }) {
  const [v, setV] = useState<number | null>(null);
  return (
    <div>
      <input type="hidden" name={name} value={v ?? ""} />
      <div className="grid grid-cols-11 gap-1 mt-1">
        {Array.from({ length: 11 }).map((_, i) => {
          const active = v === i;
          return (
            <button
              type="button"
              key={i}
              onClick={() => setV(i)}
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
