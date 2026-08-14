"use client";

// =====================================================================
// Génération en masse : une session + une épreuve + N candidats →
// planning horaire calculé automatiquement (durée + pause), éditable,
// puis N convocations personnalisées (ZIP, PDF unique ou téléchargements
// individuels).
// =====================================================================

import * as React from "react";
import { Archive, FileStack, Loader2, Users2, Wand2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { DateField } from "@/components/ui/date-field";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/components/ui/toast";
import {
  TYPES_EPREUVE, TEMPLATES, computeSchedule, emptyPayload, formatHeure,
  type ConvocationTemplate,
} from "@/lib/convocations";
import { listCandidats, saveBatch, type CandidatOption, type LieuRow } from "./actions";
import { Field, Section, TimeInput } from "./form-shared";
import type { FormationOption } from "./convocation-form";

export function MasseTab({
  formations,
  lieux,
  onSaved,
}: {
  formations: FormationOption[];
  lieux: LieuRow[];
  onSaved?: () => void;
}) {
  const { toast } = useToast();
  const [formationId, setFormationId] = React.useState("");
  const [candidats, setCandidats] = React.useState<CandidatOption[]>([]);
  const [selection, setSelection] = React.useState<Set<string>>(new Set());
  const [chargement, setChargement] = React.useState(false);

  const [epreuveType, setEpreuveType] = React.useState<string>("Épreuve orale");
  const [epreuveIntitule, setEpreuveIntitule] = React.useState("");
  const [date, setDate] = React.useState("");
  const [premier, setPremier] = React.useState("09:00");
  const [duree, setDuree] = React.useState(30);
  const [pause, setPause] = React.useState(5);
  const [arriveeMin, setArriveeMin] = React.useState(15);
  const [lieuId, setLieuId] = React.useState("");
  const [template, setTemplate] = React.useState<ConvocationTemplate>("moderne");
  const [signataire, setSignataire] = React.useState("");
  const [creneaux, setCreneaux] = React.useState<Array<{ debut: string; fin: string }>>([]);
  const [busy, setBusy] = React.useState<null | "zip" | "merged">(null);
  const [lastIds, setLastIds] = React.useState<string[]>([]);

  React.useEffect(() => {
    if (!formationId) { setCandidats([]); setSelection(new Set()); return; }
    setChargement(true);
    let alive = true;
    void listCandidats(formationId).then((r) => {
      if (!alive) return;
      setCandidats(r);
      setSelection(new Set(r.map((c) => c.user_id)));
      setChargement(false);
    });
    return () => { alive = false; };
  }, [formationId]);

  const retenus = candidats.filter((c) => selection.has(c.user_id));

  /* Le planning suit automatiquement la sélection et les paramètres,
     tant que l'utilisateur ne l'a pas édité à la main. */
  const [planningManuel, setPlanningManuel] = React.useState(false);
  React.useEffect(() => {
    if (planningManuel) return;
    setCreneaux(computeSchedule(premier, duree, pause, retenus.length));
  }, [premier, duree, pause, retenus.length, planningManuel]);

  function recalculer() {
    setPlanningManuel(false);
    setCreneaux(computeSchedule(premier, duree, pause, retenus.length));
  }

  function toggle(id: string) {
    setSelection((s) => {
      const n = new Set(s);
      if (n.has(id)) n.delete(id); else n.add(id);
      return n;
    });
  }

  async function generer(mode: "zip" | "merged") {
    if (retenus.length === 0) { toast("Sélectionnez au moins un candidat.", "error"); return; }
    if (!date) { toast("Choisissez la date de l'épreuve.", "error"); return; }
    if (!lieuId) { toast("Choisissez le lieu.", "error"); return; }
    if (!signataire.trim()) { toast("Renseignez le nom du signataire.", "error"); return; }
    const lieu = lieux.find((l) => l.id === lieuId)!;
    const formation = formations.find((f) => f.id === formationId);

    setBusy(mode);
    const items = retenus.map((c, i) => {
      const base = emptyPayload("candidat");
      const slot = creneaux[i] ?? { debut: premier, fin: premier };
      return {
        payload: {
          ...base,
          destinataire: {
            ...base.destinataire,
            prenom: c.prenom, nom: c.nom,
            email: c.email ?? undefined, telephone: c.telephone ?? undefined,
          },
          formation: { titre: formation?.title ?? c.formation_titre ?? "" },
          session: { label: c.session_label ?? "" },
          epreuve: { type: epreuveType, intitule: epreuveIntitule },
          horaires: {
            date,
            debut: slot.debut,
            fin: slot.fin,
            arrivee_minutes: arriveeMin || undefined,
          },
          lieu: {
            nom: lieu.name, adresse: lieu.address,
            code_postal: lieu.postal_code, ville: lieu.city,
            salle: lieu.room ?? undefined, etage: lieu.floor ?? undefined,
            acces: lieu.access_info ?? undefined,
          },
          signataire: { ...base.signataire, nom: signataire },
        },
        template,
        related_user_id: c.user_id,
        formation_id: formationId || null,
      };
    });

    const res = await saveBatch(items);
    setBusy(null);
    if (!res.ok || !res.ids) { toast(res.error ?? "Génération impossible.", "error"); return; }
    setLastIds(res.ids);
    onSaved?.();
    const url = `/super-admin/convocations/pdf?ids=${res.ids.join(",")}&mode=${mode}${mode === "merged" ? "&download=1" : ""}`;
    window.open(url, "_blank", "noopener");
    toast(`${res.ids.length} convocations générées.`, "success");
  }

  return (
    <div className="space-y-4">
      <Section title="Session et candidats">
        <div className="grid gap-3 sm:grid-cols-2">
          <Field label="Formation" required>
            <Select value={formationId} onChange={(e) => setFormationId(e.target.value)}>
              <option value="" disabled>Choisir une formation…</option>
              {formations.map((f) => <option key={f.id} value={f.id}>{f.title}</option>)}
            </Select>
          </Field>
          <div className="flex items-end">
            <Badge tone="navy" size="md">
              <Users2 className="h-3 w-3" /> {retenus.length} candidat{retenus.length > 1 ? "s" : ""} sélectionné{retenus.length > 1 ? "s" : ""}
            </Badge>
          </div>
        </div>

        {chargement ? (
          <p className="mt-3 flex items-center gap-2 text-sm text-slate-500">
            <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" /> Chargement des inscrits…
          </p>
        ) : candidats.length > 0 ? (
          <div className="mt-3 max-h-56 overflow-y-auto rounded-xl border border-navy-100">
            {candidats.map((c, i) => (
              <label
                key={c.user_id + i}
                className="flex cursor-pointer items-center gap-3 border-b border-navy-50 px-3 py-2 last:border-b-0 hover:bg-navy-50/50"
              >
                <input
                  type="checkbox"
                  checked={selection.has(c.user_id)}
                  onChange={() => toggle(c.user_id)}
                  className="h-4 w-4 rounded border-navy-300 text-navy-900 focus:ring-navy-600/30"
                />
                <span className="flex-1 text-sm text-navy-900">
                  {c.prenom} {c.nom}
                  {c.session_label && <span className="text-slate-500"> — {c.session_label}</span>}
                </span>
                <span className="text-xs text-slate-400">{c.email ?? ""}</span>
              </label>
            ))}
          </div>
        ) : formationId ? (
          <p className="mt-3 text-sm text-slate-500">Aucun inscrit actif sur cette formation.</p>
        ) : null}
      </Section>

      <Section title="Épreuve, planning et lieu">
        <div className="grid gap-3 sm:grid-cols-3">
          <Field label="Type d'épreuve" required>
            <Select value={epreuveType} onChange={(e) => setEpreuveType(e.target.value)}>
              {TYPES_EPREUVE.map((t) => <option key={t}>{t}</option>)}
            </Select>
          </Field>
          <Field label="Intitulé" className="sm:col-span-2">
            <Input value={epreuveIntitule} onChange={(e) => setEpreuveIntitule(e.target.value)}
              placeholder="ex. Entretien technique CCP 1" />
          </Field>
          <Field label="Date" required>
            <DateField value={date} onChange={setDate} />
          </Field>
          <Field label="Premier créneau">
            <TimeInput value={premier} onChange={setPremier} />
          </Field>
          <Field label="Arrivée conseillée (min avant)">
            <Input type="number" min={0} max={120} value={arriveeMin}
              onChange={(e) => setArriveeMin(Number(e.target.value) || 0)} />
          </Field>
          <Field label="Durée par candidat (min)">
            <Input type="number" min={5} max={480} value={duree}
              onChange={(e) => setDuree(Math.max(5, Number(e.target.value) || 30))} />
          </Field>
          <Field label="Pause entre candidats (min)">
            <Input type="number" min={0} max={120} value={pause}
              onChange={(e) => setPause(Math.max(0, Number(e.target.value) || 0))} />
          </Field>
          <Field label="Lieu" required>
            <Select value={lieuId} onChange={(e) => setLieuId(e.target.value)}>
              <option value="" disabled>Choisir un lieu…</option>
              {lieux.map((l) => <option key={l.id} value={l.id}>{l.name} — {l.city}</option>)}
            </Select>
          </Field>
        </div>

        {retenus.length > 0 && (
          <div className="mt-4">
            <div className="mb-2 flex items-center justify-between">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">
                Planning ({retenus.length} créneaux{planningManuel ? " · édité manuellement" : " · automatique"})
              </span>
              <Button size="sm" variant="ghost" onClick={recalculer}>
                <Wand2 className="h-3.5 w-3.5" /> Recalculer
              </Button>
            </div>
            <div className="max-h-64 overflow-y-auto rounded-xl border border-navy-100">
              <table className="w-full text-sm">
                <thead className="sticky top-0 bg-navy-50/80 text-left text-[11px] uppercase tracking-wider text-slate-500 backdrop-blur">
                  <tr>
                    <th className="px-3 py-2 font-semibold">Candidat</th>
                    <th className="w-28 px-3 py-2 font-semibold">Début</th>
                    <th className="w-28 px-3 py-2 font-semibold">Fin</th>
                  </tr>
                </thead>
                <tbody>
                  {retenus.map((c, i) => (
                    <tr key={c.user_id + i} className="border-t border-navy-50">
                      <td className="px-3 py-1.5 text-navy-900">{c.prenom} {c.nom}</td>
                      <td className="px-2 py-1">
                        <TimeInput className="h-9" value={creneaux[i]?.debut ?? ""} onChange={(v) => {
                          setPlanningManuel(true);
                          setCreneaux((cs) => cs.map((s, j) => (j === i ? { ...s, debut: v } : s)));
                        }} />
                      </td>
                      <td className="px-2 py-1">
                        <TimeInput className="h-9" value={creneaux[i]?.fin ?? ""} onChange={(v) => {
                          setPlanningManuel(true);
                          setCreneaux((cs) => cs.map((s, j) => (j === i ? { ...s, fin: v } : s)));
                        }} />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {creneaux.length > 0 && (
              <p className="mt-1.5 text-xs text-slate-500">
                Dernier créneau : {formatHeure(creneaux[creneaux.length - 1]?.debut)} à {formatHeure(creneaux[creneaux.length - 1]?.fin)}.
              </p>
            )}
          </div>
        )}
      </Section>

      <Section title="Génération">
        <div className="grid gap-3 sm:grid-cols-2">
          <Field label="Modèle de convocation">
            <Select value={template} onChange={(e) => setTemplate(e.target.value as ConvocationTemplate)}>
              {Object.entries(TEMPLATES).map(([k, t]) => (
                <option key={k} value={k}>Modèle {t.label} — {t.hint}</option>
              ))}
            </Select>
          </Field>
          <Field label="Nom du signataire" required>
            <Input value={signataire} onChange={(e) => setSignataire(e.target.value)}
              placeholder="ex. SFAXI Ayman" />
          </Field>
        </div>
        <div className="mt-4 flex flex-wrap gap-2">
          <Button onClick={() => generer("zip")} disabled={busy !== null || retenus.length === 0}>
            {busy === "zip"
              ? <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
              : <Archive className="h-4 w-4" />}
            Générer le ZIP ({retenus.length} PDF)
          </Button>
          <Button variant="secondary" onClick={() => generer("merged")} disabled={busy !== null || retenus.length === 0}>
            {busy === "merged"
              ? <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
              : <FileStack className="h-4 w-4" />}
            PDF unique ({retenus.length} pages)
          </Button>
          {lastIds.length > 0 && (
            <span className="self-center text-xs text-slate-500">
              Dernier lot : {lastIds.length} convocations, disponibles dans l'historique.
            </span>
          )}
        </div>
      </Section>
    </div>
  );
}
