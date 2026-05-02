"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { updateFormationSettings } from "./actions";
import { Save, Loader2 } from "lucide-react";

function Field({
  label,
  hint,
  children,
}: {
  label: string;
  hint?: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="block text-sm font-medium text-navy-900 mb-1">{label}</span>
      {children}
      {hint && <span className="block text-xs text-slate-500 mt-1">{hint}</span>}
    </label>
  );
}

function Textarea(props: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      {...props}
      className="w-full rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm shadow-soft focus:outline-none focus:ring-2 focus:ring-gold-400"
    />
  );
}

export function FormationForm({
  initial,
  formationSlug,
  formationTitle,
  formationCode,
}: {
  initial: any;
  formationSlug: string;
  formationTitle?: string;
  formationCode?: string;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState(false);
  const [f, setF] = useState({
    organisme_nom: initial?.organisme_nom ?? "",
    organisme_siret: initial?.organisme_siret ?? "",
    organisme_num_da: initial?.organisme_num_da ?? "",
    organisme_adresse: initial?.organisme_adresse ?? "",
    organisme_email: initial?.organisme_email ?? "",
    organisme_telephone: initial?.organisme_telephone ?? "",
    organisme_responsable: initial?.organisme_responsable ?? "",
    formation_titre: initial?.formation_titre ?? "",
    formation_rncp: initial?.formation_rncp ?? "",
    formation_duree_h: initial?.formation_duree_h ?? 700,
    formation_public: initial?.formation_public ?? "",
    formation_prerequis: initial?.formation_prerequis ?? "",
    formation_objectifs: initial?.formation_objectifs ?? "",
    formation_methodes: initial?.formation_methodes ?? "",
    formation_evaluation: initial?.formation_evaluation ?? "",
    formation_handicap: initial?.formation_handicap ?? "",
    formation_referent_handicap: initial?.formation_referent_handicap ?? "",
    formation_tarif: initial?.formation_tarif ?? "",
    formation_delai_acces: initial?.formation_delai_acces ?? "",
    indicateur_satisfaction: initial?.indicateur_satisfaction ?? "",
    indicateur_reussite: initial?.indicateur_reussite ?? "",
  });

  const up = (k: string) => (e: any) =>
    setF((s) => ({ ...s, [k]: e.target.value }));

  const submit = () => {
    setErr(null);
    setOk(false);
    start(async () => {
      try {
        await updateFormationSettings({
          ...f,
          formation_slug: formationSlug,
          formation_duree_h: Number(f.formation_duree_h) || 0,
          indicateur_satisfaction:
            f.indicateur_satisfaction === "" ? null : Number(f.indicateur_satisfaction),
          indicateur_reussite:
            f.indicateur_reussite === "" ? null : Number(f.indicateur_reussite),
        });
        setOk(true);
        router.refresh();
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  return (
    <div className="space-y-8">
      {/* Organisme */}
      <section className="space-y-4">
        <h3 className="font-display text-lg font-semibold text-navy-900">
          Organisme de formation
        </h3>
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Nom de l'organisme">
            <Input value={f.organisme_nom} onChange={up("organisme_nom")} />
          </Field>
          <Field label="Responsable pédagogique">
            <Input
              value={f.organisme_responsable}
              onChange={up("organisme_responsable")}
            />
          </Field>
          <Field label="SIRET">
            <Input value={f.organisme_siret} onChange={up("organisme_siret")} />
          </Field>
          <Field label="N° déclaration d'activité">
            <Input value={f.organisme_num_da} onChange={up("organisme_num_da")} />
          </Field>
          <Field label="Email" hint="Contact formation">
            <Input
              type="email"
              value={f.organisme_email}
              onChange={up("organisme_email")}
            />
          </Field>
          <Field label="Téléphone">
            <Input
              value={f.organisme_telephone}
              onChange={up("organisme_telephone")}
            />
          </Field>
          <div className="md:col-span-2">
            <Field label="Adresse complète">
              <Textarea
                rows={2}
                value={f.organisme_adresse}
                onChange={up("organisme_adresse")}
              />
            </Field>
          </div>
        </div>
      </section>

      {/* Formation */}
      <section className="space-y-4 pt-6 border-t border-navy-50">
        <h3 className="font-display text-lg font-semibold text-navy-900">
          Formation
        </h3>
        <div className="grid md:grid-cols-3 gap-4">
          <div className="md:col-span-2">
            <Field label="Intitulé">
              <Input
                value={f.formation_titre}
                onChange={up("formation_titre")}
              />
            </Field>
          </div>
          <Field label="Code RNCP">
            <Input value={f.formation_rncp} onChange={up("formation_rncp")} />
          </Field>
          <Field label="Durée (heures)">
            <Input
              type="number"
              value={f.formation_duree_h}
              onChange={up("formation_duree_h")}
            />
          </Field>
          <Field label="Tarif">
            <Input
              value={f.formation_tarif}
              onChange={up("formation_tarif")}
              placeholder="ex : 4 900 € TTC ou selon devis"
            />
          </Field>
          <Field label="Délai d'accès">
            <Input
              value={f.formation_delai_acces}
              onChange={up("formation_delai_acces")}
            />
          </Field>
          <div className="md:col-span-3">
            <Field label="Public visé">
              <Textarea
                rows={2}
                value={f.formation_public}
                onChange={up("formation_public")}
              />
            </Field>
          </div>
          <div className="md:col-span-3">
            <Field label="Prérequis">
              <Textarea
                rows={2}
                value={f.formation_prerequis}
                onChange={up("formation_prerequis")}
              />
            </Field>
          </div>
          <div className="md:col-span-3">
            <Field label="Objectifs pédagogiques" hint="Une ligne par objectif">
              <Textarea
                rows={5}
                value={f.formation_objectifs}
                onChange={up("formation_objectifs")}
              />
            </Field>
          </div>
          <div className="md:col-span-3">
            <Field label="Méthodes pédagogiques">
              <Textarea
                rows={4}
                value={f.formation_methodes}
                onChange={up("formation_methodes")}
              />
            </Field>
          </div>
          <div className="md:col-span-3">
            <Field label="Modalités d'évaluation">
              <Textarea
                rows={4}
                value={f.formation_evaluation}
                onChange={up("formation_evaluation")}
              />
            </Field>
          </div>
        </div>
      </section>

      {/* Handicap */}
      <section className="space-y-4 pt-6 border-t border-navy-50">
        <h3 className="font-display text-lg font-semibold text-navy-900">
          Accessibilité & handicap
        </h3>
        <div className="grid md:grid-cols-3 gap-4">
          <div className="md:col-span-2">
            <Field label="Message accessibilité">
              <Textarea
                rows={3}
                value={f.formation_handicap}
                onChange={up("formation_handicap")}
              />
            </Field>
          </div>
          <Field label="Référent handicap">
            <Input
              value={f.formation_referent_handicap}
              onChange={up("formation_referent_handicap")}
              placeholder="Nom et contact"
            />
          </Field>
        </div>
      </section>

      {/* Indicateurs */}
      <section className="space-y-4 pt-6 border-t border-navy-50">
        <h3 className="font-display text-lg font-semibold text-navy-900">
          Indicateurs (affichage public)
        </h3>
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Satisfaction moyenne (sur 5)" hint="Ex : 4.2">
            <Input
              type="number"
              step="0.1"
              value={f.indicateur_satisfaction}
              onChange={up("indicateur_satisfaction")}
            />
          </Field>
          <Field label="Taux de réussite (%)" hint="Ex : 85">
            <Input
              type="number"
              step="0.1"
              value={f.indicateur_reussite}
              onChange={up("indicateur_reussite")}
            />
          </Field>
        </div>
      </section>

      {err && (
        <div className="rounded-xl bg-rose-50 text-rose-800 text-sm px-4 py-3 border border-rose-200">
          {err}
        </div>
      )}
      {ok && (
        <div className="rounded-xl bg-emerald-50 text-emerald-800 text-sm px-4 py-3 border border-emerald-200">
          Paramètres enregistrés.
        </div>
      )}

      <div className="flex justify-end gap-3 pt-4 border-t border-navy-50">
        <Button onClick={submit} disabled={pending} variant="gold">
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" /> Enregistrement…
            </>
          ) : (
            <>
              <Save className="h-4 w-4" /> Enregistrer
            </>
          )}
        </Button>
      </div>
    </div>
  );
}
