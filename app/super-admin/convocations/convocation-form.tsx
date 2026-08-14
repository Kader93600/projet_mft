"use client";

// =====================================================================
// Formulaire de convocation (candidat OU jury) avec aperçu temps réel.
// Préremplissage : sélectionner une inscription (ou un formateur) remplit
// identité, formation, session, coordonnées ; le lieu vient des lieux
// enregistrés. L'utilisateur ne complète que ce qui manque.
// =====================================================================

import * as React from "react";
import {
  Download, Eye, Printer, Copy, RotateCcw, Loader2, Plus, CheckCircle2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { DateField } from "@/components/ui/date-field";
import { Dialog, DialogHeader, DialogBody, DialogFooter } from "@/components/ui/dialog";
import { useToast } from "@/components/ui/toast";
import {
  CONSIGNES_CANDIDAT, INFOS_JURY, ROLES_JURY, TYPES_EPREUVE, TEMPLATES,
  emptyPayload,
  type ConvocationKind, type ConvocationPayload, type ConvocationTemplate,
} from "@/lib/convocations";
import {
  createLieu, listCandidats, listJurys, saveConvocation,
  type CandidatOption, type JuryOption, type LieuRow,
} from "./actions";
import { ConvocationPreview } from "./preview";
import { Field, Grid2, Section, TimeInput, ToggleRow } from "./form-shared";

export interface FormationOption { id: string; title: string }

const DETAIL_FIELDS: Record<string, string> = {
  materiel: "Préciser le matériel attendu",
  documents_ok: "Préciser les documents autorisés",
  tenue: "Préciser la tenue / les EPI attendus",
  securite: "Préciser les consignes de sécurité",
  nb_candidats: "Nombre de candidats (ex. 8)",
  liste_candidats: "Liste des candidats (un par ligne ou séparés par des virgules)",
  duree_par_candidat: "Durée moyenne (ex. 30 minutes)",
  remuneration: "Modalités de rémunération / indemnisation",
  frais: "Modalités de prise en charge des frais",
};

export function ConvocationForm({
  kind,
  formations,
  lieux: lieuxInit,
  initial,
  editId,
  onSaved,
}: {
  kind: ConvocationKind;
  formations: FormationOption[];
  lieux: LieuRow[];
  /** Pré-chargement (Modifier / Dupliquer depuis l'historique). */
  initial?: ConvocationPayload;
  editId?: string;
  onSaved?: () => void;
}) {
  const { toast } = useToast();
  const [payload, setPayload] = React.useState<ConvocationPayload>(
    () => initial ?? emptyPayload(kind),
  );
  const [template, setTemplate] = React.useState<ConvocationTemplate>("moderne");
  const [lieux, setLieux] = React.useState<LieuRow[]>(lieuxInit);
  const [lieuId, setLieuId] = React.useState<string>("");
  const [candidats, setCandidats] = React.useState<CandidatOption[]>([]);
  const [jurys, setJurys] = React.useState<JuryOption[]>([]);
  const [filtreFormation, setFiltreFormation] = React.useState("");
  const [saving, setSaving] = React.useState<null | "download" | "preview">(null);
  const [savedId, setSavedId] = React.useState<string | null>(editId ?? null);
  const [dirty, setDirty] = React.useState(false);
  const [lieuDialog, setLieuDialog] = React.useState(false);

  // Chargement des personnes (une fois)
  React.useEffect(() => {
    let alive = true;
    if (kind === "candidat") {
      void listCandidats().then((r) => alive && setCandidats(r));
    } else {
      void listJurys().then((r) => alive && setJurys(r));
    }
    return () => { alive = false; };
  }, [kind]);

  const patch = React.useCallback(
    (fn: (p: ConvocationPayload) => ConvocationPayload) => {
      setPayload(fn);
      setDirty(true);
    },
    [],
  );

  /* ── Préremplissages ─────────────────────────────────────────────── */

  const candidatsFiltres = filtreFormation
    ? candidats.filter((c) => c.formation_id === filtreFormation)
    : candidats;

  function prefillCandidat(idx: number) {
    const c = candidatsFiltres[idx];
    if (!c) return;
    patch((p) => ({
      ...p,
      destinataire: {
        ...p.destinataire,
        nom: c.nom, prenom: c.prenom,
        email: c.email ?? undefined, telephone: c.telephone ?? undefined,
      },
      formation: { ...p.formation, titre: c.formation_titre ?? p.formation.titre },
      session: {
        ...p.session,
        label: c.session_label ?? p.session.label,
        debut: c.start_date ?? undefined, fin: c.end_date ?? undefined,
      },
    }));
  }

  function prefillJury(idx: number) {
    const j = jurys[idx];
    if (!j) return;
    patch((p) => ({
      ...p,
      destinataire: {
        ...p.destinataire,
        nom: j.nom, prenom: j.prenom,
        email: j.email ?? undefined, telephone: j.telephone ?? undefined,
      },
      formation: { ...p.formation, titre: j.formations[0] ?? p.formation.titre },
    }));
  }

  function applyLieu(id: string) {
    setLieuId(id);
    const l = lieux.find((x) => x.id === id);
    if (!l) return;
    patch((p) => ({
      ...p,
      lieu: {
        nom: l.name, adresse: l.address, code_postal: l.postal_code, ville: l.city,
        salle: l.room ?? undefined, etage: l.floor ?? undefined, acces: l.access_info ?? undefined,
      },
    }));
  }

  /* ── Génération ──────────────────────────────────────────────────── */

  async function save(mode: "download" | "preview") {
    setSaving(mode);
    const formationId = formations.find((f) => f.title === payload.formation.titre)?.id ?? null;
    const res = await saveConvocation({
      id: dirty || !savedId ? (editId && savedId === editId ? editId : savedId ?? undefined) : savedId,
      payload,
      template,
      formation_id: formationId,
    });
    setSaving(null);
    if (!res.ok || !res.row) {
      toast(res.error ?? "Enregistrement impossible.", "error");
      return;
    }
    setSavedId(res.row.id);
    setPayload(res.row.payload);
    setDirty(false);
    onSaved?.();
    const url = `/super-admin/convocations/pdf?id=${res.row.id}${mode === "download" ? "&download=1" : ""}`;
    window.open(url, "_blank", "noopener");
    toast(mode === "download" ? "Convocation générée et téléchargée." : "Aperçu PDF ouvert.", "success");
  }

  function dupliquer() {
    setSavedId(null);
    patch((p) => ({ ...p, reference: "" }));
    toast("Copie prête : ajustez puis générez.", "info");
  }

  function reinitialiser() {
    setPayload(emptyPayload(kind));
    setSavedId(null);
    setDirty(false);
    setLieuId("");
  }

  const dico = kind === "jury" ? INFOS_JURY : CONSIGNES_CANDIDAT;

  /* ── Rendu ───────────────────────────────────────────────────────── */

  return (
    <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_400px]">
      <div className="space-y-4">
        {/* Préremplissage rapide */}
        <Section title="Préremplissage" hint="sélectionnez pour remplir automatiquement">
          <Grid2>
            {kind === "candidat" ? (
              <>
                <Field label="Filtrer par formation">
                  <Select value={filtreFormation} onChange={(e) => setFiltreFormation(e.target.value)}>
                    <option value="">Toutes les formations</option>
                    {formations.map((f) => <option key={f.id} value={f.id}>{f.title}</option>)}
                  </Select>
                </Field>
                <Field label={`Candidat inscrit (${candidatsFiltres.length})`}>
                  <Select defaultValue="" onChange={(e) => prefillCandidat(Number(e.target.value))}>
                    <option value="" disabled>Choisir un candidat…</option>
                    {candidatsFiltres.map((c, i) => (
                      <option key={c.user_id + i} value={i}>
                        {c.prenom} {c.nom}{c.session_label ? ` — ${c.session_label}` : ""}
                      </option>
                    ))}
                  </Select>
                </Field>
              </>
            ) : (
              <Field label={`Formateur habilité (${jurys.length})`} className="sm:col-span-2">
                <Select defaultValue="" onChange={(e) => prefillJury(Number(e.target.value))}>
                  <option value="" disabled>Choisir dans l'équipe (ou saisir librement ci-dessous)…</option>
                  {jurys.map((j, i) => (
                    <option key={j.user_id} value={i}>
                      {j.prenom} {j.nom}{j.formations.length ? ` — ${j.formations.join(", ")}` : ""}
                    </option>
                  ))}
                </Select>
              </Field>
            )}
          </Grid2>
        </Section>

        {/* Destinataire */}
        <Section title={kind === "jury" ? "Membre du jury" : "Candidat"}>
          <Grid2>
            <Field label="Civilité">
              <Select
                value={payload.destinataire.civilite}
                onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, civilite: e.target.value as ConvocationPayload["destinataire"]["civilite"] } }))}
              >
                <option value="">—</option>
                <option>Monsieur</option>
                <option>Madame</option>
              </Select>
            </Field>
            {kind === "jury" && (
              <Field label="Rôle dans le jury">
                <Select
                  value={payload.destinataire.role_jury ?? ""}
                  onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, role_jury: e.target.value } }))}
                >
                  <option value="">—</option>
                  {ROLES_JURY.map((r) => <option key={r}>{r}</option>)}
                </Select>
              </Field>
            )}
            <Field label="Prénom" required>
              <Input value={payload.destinataire.prenom}
                onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, prenom: e.target.value } }))} />
            </Field>
            <Field label="Nom" required>
              <Input value={payload.destinataire.nom}
                onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, nom: e.target.value } }))} />
            </Field>
            {kind === "candidat" ? (
              <Field label="Identifiant candidat">
                <Input value={payload.destinataire.identifiant ?? ""}
                  onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, identifiant: e.target.value } }))} />
              </Field>
            ) : (
              <>
                <Field label="Fonction">
                  <Input value={payload.destinataire.fonction ?? ""}
                    onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, fonction: e.target.value } }))} />
                </Field>
                <Field label="Organisation / entreprise">
                  <Input value={payload.destinataire.organisation ?? ""}
                    onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, organisation: e.target.value } }))} />
                </Field>
              </>
            )}
            <Field label="Email">
              <Input type="email" value={payload.destinataire.email ?? ""}
                onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, email: e.target.value } }))} />
            </Field>
            <Field label="Téléphone">
              <Input value={payload.destinataire.telephone ?? ""}
                onChange={(e) => patch((p) => ({ ...p, destinataire: { ...p.destinataire, telephone: e.target.value } }))} />
            </Field>
          </Grid2>
        </Section>

        {/* Formation & épreuve */}
        <Section title="Formation et épreuve">
          <Grid2>
            <Field label="Formation / certification" required className="sm:col-span-2">
              <Select
                value={formations.some((f) => f.title === payload.formation.titre) ? payload.formation.titre : ""}
                onChange={(e) => patch((p) => ({ ...p, formation: { ...p.formation, titre: e.target.value } }))}
              >
                <option value="" disabled>Choisir une formation…</option>
                {formations.map((f) => <option key={f.id}>{f.title}</option>)}
              </Select>
            </Field>
            <Field label="Bloc de compétences">
              <Input placeholder="ex. CCP 1" value={payload.formation.bloc ?? ""}
                onChange={(e) => patch((p) => ({ ...p, formation: { ...p.formation, bloc: e.target.value } }))} />
            </Field>
            <Field label="Session">
              <Input placeholder="ex. Septembre 2026" value={payload.session.label}
                onChange={(e) => patch((p) => ({ ...p, session: { ...p.session, label: e.target.value } }))} />
            </Field>
            <Field label="Type d'épreuve" required>
              <Select value={payload.epreuve.type}
                onChange={(e) => patch((p) => ({ ...p, epreuve: { ...p.epreuve, type: e.target.value } }))}>
                {TYPES_EPREUVE.map((t) => <option key={t}>{t}</option>)}
              </Select>
            </Field>
            <Field label="Intitulé de l'épreuve">
              <Input placeholder="ex. Mise en situation professionnelle" value={payload.epreuve.intitule}
                onChange={(e) => patch((p) => ({ ...p, epreuve: { ...p.epreuve, intitule: e.target.value } }))} />
            </Field>
            {kind === "jury" && (
              <Field label="Groupe de candidats">
                <Input placeholder="ex. Groupe A" value={payload.session.groupe ?? ""}
                  onChange={(e) => patch((p) => ({ ...p, session: { ...p.session, groupe: e.target.value } }))} />
              </Field>
            )}
          </Grid2>
        </Section>

        {/* Date & horaires */}
        <Section title="Date et horaires">
          <div className="grid gap-3 sm:grid-cols-3">
            <Field label="Date de l'épreuve" required>
              <DateField value={payload.horaires.date}
                onChange={(iso) => patch((p) => ({ ...p, horaires: { ...p.horaires, date: iso } }))} />
            </Field>
            <Field label={kind === "jury" ? "Heure d'arrivée demandée" : "Heure de convocation"}>
              <TimeInput value={payload.horaires.convocation ?? ""}
                onChange={(v) => patch((p) => ({ ...p, horaires: { ...p.horaires, convocation: v } }))} />
            </Field>
            <Field label="Début de l'épreuve" required>
              <TimeInput value={payload.horaires.debut}
                onChange={(v) => patch((p) => ({ ...p, horaires: { ...p.horaires, debut: v } }))} />
            </Field>
            <Field label="Fin prévue">
              <TimeInput value={payload.horaires.fin ?? ""}
                onChange={(v) => patch((p) => ({ ...p, horaires: { ...p.horaires, fin: v } }))} />
            </Field>
            <Field label="Durée estimée">
              <Input placeholder="ex. 1 h 30" value={payload.horaires.duree ?? ""}
                onChange={(e) => patch((p) => ({ ...p, horaires: { ...p.horaires, duree: e.target.value } }))} />
            </Field>
            {kind === "jury" ? (
              <Field label="Pause éventuelle">
                <Input placeholder="ex. 12 h 30 à 13 h 30" value={payload.horaires.pause ?? ""}
                  onChange={(e) => patch((p) => ({ ...p, horaires: { ...p.horaires, pause: e.target.value } }))} />
              </Field>
            ) : (
              <Field label="Arrivée conseillée (minutes avant)">
                <Input type="number" min={0} max={120} value={payload.horaires.arrivee_minutes ?? ""}
                  onChange={(e) => patch((p) => ({ ...p, horaires: { ...p.horaires, arrivee_minutes: e.target.value ? Number(e.target.value) : undefined } }))} />
              </Field>
            )}
          </div>
          {payload.horaires.debut && payload.horaires.duree === undefined && payload.horaires.fin && (
            <p className="mt-2 text-xs text-slate-500">
              Astuce : renseignez la durée pour l'afficher sur la convocation.
            </p>
          )}
        </Section>

        {/* Lieu */}
        <Section title="Lieu">
          <Grid2>
            <Field label="Lieu enregistré" className="sm:col-span-2">
              <div className="flex gap-2">
                <div className="flex-1">
                  <Select value={lieuId} onChange={(e) => applyLieu(e.target.value)}>
                    <option value="" disabled>Choisir un lieu…</option>
                    {lieux.map((l) => (
                      <option key={l.id} value={l.id}>{l.name} — {l.city}</option>
                    ))}
                  </Select>
                </div>
                <Button type="button" variant="secondary" onClick={() => setLieuDialog(true)}>
                  <Plus className="h-4 w-4" /> Nouveau lieu
                </Button>
              </div>
            </Field>
            <Field label="Salle">
              <Input value={payload.lieu.salle ?? ""}
                onChange={(e) => patch((p) => ({ ...p, lieu: { ...p.lieu, salle: e.target.value } }))} />
            </Field>
            <Field label="Étage / bâtiment">
              <Input value={payload.lieu.etage ?? ""}
                onChange={(e) => patch((p) => ({ ...p, lieu: { ...p.lieu, etage: e.target.value } }))} />
            </Field>
            <Field label="Informations d'accès" className="sm:col-span-2">
              <Input value={payload.lieu.acces ?? ""}
                onChange={(e) => patch((p) => ({ ...p, lieu: { ...p.lieu, acces: e.target.value } }))} />
            </Field>
          </Grid2>
          {payload.lieu.nom && (
            <p className="mt-2 text-xs text-slate-500">
              {payload.lieu.nom} · {payload.lieu.adresse}, {payload.lieu.code_postal} {payload.lieu.ville}
            </p>
          )}
        </Section>

        {/* Consignes */}
        <Section title={kind === "jury" ? "Informations pour le jury" : "Consignes au candidat"} defaultOpen={false}>
          <div className="space-y-2">
            {dico.map((c) => {
              const checked = payload.consignes.includes(c.id);
              const detailKey = c.id in DETAIL_FIELDS ? c.id : null;
              return (
                <ToggleRow
                  key={c.id}
                  label={c.label}
                  checked={checked}
                  onChange={(v) =>
                    patch((p) => ({
                      ...p,
                      consignes: v
                        ? [...p.consignes, c.id]
                        : p.consignes.filter((x) => x !== c.id),
                    }))
                  }
                >
                  {detailKey ? (
                    <Input
                      placeholder={DETAIL_FIELDS[detailKey]}
                      value={(payload.details as Record<string, string | undefined>)[detailKey] ?? ""}
                      onChange={(e) =>
                        patch((p) => ({ ...p, details: { ...p.details, [detailKey]: e.target.value } }))
                      }
                    />
                  ) : null}
                </ToggleRow>
              );
            })}
          </div>
          <Field label="Remarques complémentaires" className="mt-3">
            <Textarea rows={3} value={payload.remarques ?? ""}
              onChange={(e) => patch((p) => ({ ...p, remarques: e.target.value }))} />
          </Field>
        </Section>

        {/* Signataire */}
        <Section title="Signataire et contact" defaultOpen={false}>
          <Grid2>
            <Field label="Fonction du signataire">
              <Input value={payload.signataire.fonction}
                onChange={(e) => patch((p) => ({ ...p, signataire: { ...p.signataire, fonction: e.target.value } }))} />
            </Field>
            <Field label="Nom du signataire" required>
              <Input value={payload.signataire.nom}
                onChange={(e) => patch((p) => ({ ...p, signataire: { ...p.signataire, nom: e.target.value } }))} />
            </Field>
            <Field label="Téléphone du centre">
              <Input value={payload.contact.telephone}
                onChange={(e) => patch((p) => ({ ...p, contact: { ...p.contact, telephone: e.target.value } }))} />
            </Field>
            <Field label="Email du centre">
              <Input value={payload.contact.email}
                onChange={(e) => patch((p) => ({ ...p, contact: { ...p.contact, email: e.target.value } }))} />
            </Field>
          </Grid2>
        </Section>
      </div>

      {/* ── Colonne aperçu ── */}
      <div className="space-y-3 xl:sticky xl:top-6 xl:self-start">
        <div className="flex items-center gap-2">
          <Select value={template} onChange={(e) => setTemplate(e.target.value as ConvocationTemplate)} className="h-10">
            {Object.entries(TEMPLATES).map(([k, t]) => (
              <option key={k} value={k}>Modèle {t.label} — {t.hint}</option>
            ))}
          </Select>
        </div>
        <ConvocationPreview payload={payload} template={template} />
        <div className="grid grid-cols-2 gap-2">
          <Button onClick={() => save("download")} disabled={saving !== null} className="col-span-2">
            {saving === "download"
              ? <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
              : <Download className="h-4 w-4" />}
            Générer le PDF
          </Button>
          <Button variant="secondary" onClick={() => save("preview")} disabled={saving !== null}>
            {saving === "preview"
              ? <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />
              : <Eye className="h-4 w-4" />}
            Prévisualiser
          </Button>
          <Button variant="secondary" disabled={!savedId}
            onClick={() => savedId && window.open(`/super-admin/convocations/pdf?id=${savedId}`, "_blank", "noopener")}>
            <Printer className="h-4 w-4" /> Imprimer
          </Button>
          <Button variant="ghost" onClick={dupliquer} disabled={!savedId}>
            <Copy className="h-4 w-4" /> Dupliquer
          </Button>
          <Button variant="ghost" onClick={reinitialiser}>
            <RotateCcw className="h-4 w-4" /> Réinitialiser
          </Button>
        </div>
        {savedId && !dirty && (
          <p className="flex items-center gap-1.5 text-xs text-emerald-700">
            <CheckCircle2 className="h-3.5 w-3.5" /> Enregistrée dans l'historique.
          </p>
        )}
      </div>

      {/* ── Dialog nouveau lieu ── */}
      <NouveauLieuDialog
        open={lieuDialog}
        onClose={() => setLieuDialog(false)}
        onCreated={(l) => {
          setLieux((ls) => [...ls, l]);
          applyLieu(l.id);
          setLieuDialog(false);
        }}
      />
    </div>
  );
}

function NouveauLieuDialog({
  open, onClose, onCreated,
}: {
  open: boolean; onClose: () => void; onCreated: (l: LieuRow) => void;
}) {
  const { toast } = useToast();
  const [busy, setBusy] = React.useState(false);
  const [form, setForm] = React.useState({
    name: "", address: "", postal_code: "", city: "", room: "", floor: "", access_info: "",
  });
  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm((f) => ({ ...f, [k]: e.target.value }));

  async function submit() {
    setBusy(true);
    const res = await createLieu({
      name: form.name, address: form.address, postal_code: form.postal_code, city: form.city,
      room: form.room || null, floor: form.floor || null, access_info: form.access_info || null,
    });
    setBusy(false);
    if (!res.ok || !res.lieu) { toast(res.error ?? "Enregistrement impossible.", "error"); return; }
    toast("Lieu enregistré.", "success");
    setForm({ name: "", address: "", postal_code: "", city: "", room: "", floor: "", access_info: "" });
    onCreated(res.lieu);
  }

  return (
    <Dialog open={open} onClose={onClose} size="md">
      <DialogHeader title="Ajouter un lieu" description="Réutilisable pour toutes les convocations." onClose={onClose} />
      <DialogBody className="space-y-3">
        <Field label="Nom du centre / site" required>
          <Input value={form.name} onChange={set("name")} placeholder="ex. Centre d'examen de Meaux" />
        </Field>
        <Field label="Adresse" required>
          <Input value={form.address} onChange={set("address")} />
        </Field>
        <Grid2>
          <Field label="Code postal" required>
            <Input value={form.postal_code} onChange={set("postal_code")} />
          </Field>
          <Field label="Ville" required>
            <Input value={form.city} onChange={set("city")} />
          </Field>
          <Field label="Salle">
            <Input value={form.room} onChange={set("room")} />
          </Field>
          <Field label="Étage / bâtiment">
            <Input value={form.floor} onChange={set("floor")} />
          </Field>
        </Grid2>
        <Field label="Informations d'accès">
          <Input value={form.access_info} onChange={set("access_info")} />
        </Field>
      </DialogBody>
      <DialogFooter>
        <Button variant="ghost" onClick={onClose}>Annuler</Button>
        <Button onClick={submit} disabled={busy}>
          {busy && <Loader2 className="h-4 w-4 animate-spin motion-reduce:animate-none" />}
          Enregistrer le lieu
        </Button>
      </DialogFooter>
    </Dialog>
  );
}
