import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Accessibility, FileText, MessageSquareWarning, CheckCircle2, Clock } from "lucide-react";
import { saveA11yPrefs, submitA11yRequest } from "./actions";

export const dynamic = "force-dynamic";

const STATUS_TONE: Record<string, "navy" | "gold" | "success" | "slate" | "rose"> = {
  nouveau: "gold",
  en_cours: "navy",
  valide: "success",
  refuse: "rose",
  clos: "slate",
};

const CATEGORY_LABEL: Record<string, string> = {
  visuel: "Visuel",
  auditif: "Auditif",
  moteur: "Moteur",
  cognitif: "Cognitif",
  dys: "Troubles DYS",
  autre: "Autre",
};

export default async function AccessibilitePage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: profile }, { data: requests }, { data: settings }] = await Promise.all([
    supabase
      .from("profiles")
      .select(
        "a11y_font_scale, a11y_dyslexia_font, a11y_high_contrast, a11y_reduced_motion, a11y_underline_links, a11y_notes, a11y_rqth"
      )
      .eq("id", user.id)
      .single(),
    supabase
      .from("accessibility_requests")
      .select("*")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false })
      .limit(20),
    supabase
      .from("formation_settings")
      .select("formation_handicap, formation_referent_handicap, organisme_email, organisme_telephone")
      .eq("id", 1)
      .maybeSingle(),
  ]);

  const p: any = profile ?? {};

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">RGAA · Inclusion</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Accessibilité & adaptations
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Notre plateforme vise la conformité au <strong>RGAA 4.1 niveau AA</strong>. Vous
          pouvez personnaliser l'affichage et solliciter le référent handicap pour toute
          adaptation pédagogique.
        </p>
      </header>

      {/* Référent handicap */}
      {(settings?.formation_referent_handicap || settings?.formation_handicap) && (
        <Card variant="gold">
          <CardBody className="flex flex-col md:flex-row md:items-center gap-5">
            <div className="h-14 w-14 rounded-2xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
              <Accessibility className="h-7 w-7" />
            </div>
            <div className="flex-1 text-[15px] text-slate-700">
              {settings?.formation_referent_handicap && (
                <div className="font-semibold text-navy-900 mb-1">
                  Référent handicap : {settings.formation_referent_handicap}
                </div>
              )}
              {settings?.formation_handicap && <p>{settings.formation_handicap}</p>}
              <div className="mt-2 text-sm flex flex-wrap gap-4">
                {settings?.organisme_email && (
                  <a href={`mailto:${settings.organisme_email}`} className="text-navy-900 underline">
                    {settings.organisme_email}
                  </a>
                )}
                {settings?.organisme_telephone && (
                  <span className="text-slate-600">{settings.organisme_telephone}</span>
                )}
              </div>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Préférences d'affichage */}
      <section>
        <Card>
          <CardBody>
            <CardTitle className="flex items-center gap-2">
              <FileText className="h-4 w-4 text-gold-600" /> Préférences d'affichage
            </CardTitle>
            <p className="text-sm text-slate-600 mt-1">
              Appliquées à toute la plateforme. Elles sont personnelles.
            </p>
            <form action={saveA11yPrefs} className="mt-6 grid md:grid-cols-2 gap-6">
              <div>
                <Label htmlFor="a11y_font_scale">
                  Taille du texte ({Math.round((p.a11y_font_scale ?? 1) * 100)} %)
                </Label>
                <input
                  id="a11y_font_scale"
                  name="a11y_font_scale"
                  type="range"
                  min="0.85"
                  max="1.6"
                  step="0.05"
                  defaultValue={p.a11y_font_scale ?? 1}
                  className="w-full accent-gold-600"
                />
                <div className="flex justify-between text-xs text-slate-500 mt-1">
                  <span>85 %</span>
                  <span>100 %</span>
                  <span>160 %</span>
                </div>
              </div>

              <div className="space-y-3">
                <Toggle
                  name="a11y_dyslexia_font"
                  checked={!!p.a11y_dyslexia_font}
                  label="Police adaptée aux troubles DYS"
                  hint="Espacement et lisibilité renforcés"
                />
                <Toggle
                  name="a11y_high_contrast"
                  checked={!!p.a11y_high_contrast}
                  label="Contraste élevé"
                  hint="Noir et blanc, bords marqués"
                />
                <Toggle
                  name="a11y_reduced_motion"
                  checked={!!p.a11y_reduced_motion}
                  label="Réduire les animations"
                />
                <Toggle
                  name="a11y_underline_links"
                  checked={!!p.a11y_underline_links}
                  label="Souligner tous les liens"
                />
                <Toggle
                  name="a11y_rqth"
                  checked={!!p.a11y_rqth}
                  label="Je suis bénéficiaire d'une RQTH"
                  hint="Déclaratif. Permet au référent d'adapter le suivi."
                />
              </div>

              <div className="md:col-span-2">
                <Label htmlFor="a11y_notes">Notes pour l'équipe pédagogique</Label>
                <Textarea
                  id="a11y_notes"
                  name="a11y_notes"
                  rows={3}
                  defaultValue={p.a11y_notes ?? ""}
                  placeholder="Informations utiles pour adapter votre parcours (optionnel)"
                />
              </div>

              <div className="md:col-span-2 flex justify-end">
                <Button type="submit" variant="gold">
                  Enregistrer mes préférences
                </Button>
              </div>
            </form>
          </CardBody>
        </Card>
      </section>

      {/* Demande d'adaptation */}
      <section className="grid lg:grid-cols-[1.2fr_1fr] gap-6">
        <Card>
          <CardBody>
            <CardTitle className="flex items-center gap-2">
              <MessageSquareWarning className="h-4 w-4 text-gold-600" /> Demander une
              adaptation
            </CardTitle>
            <p className="text-sm text-slate-600 mt-1">
              Votre demande sera transmise au référent handicap. Réponse sous 5 jours ouvrés.
            </p>
            <form action={submitA11yRequest} className="mt-5 space-y-4">
              <div>
                <Label htmlFor="category">Type d'adaptation</Label>
                <select
                  id="category"
                  name="category"
                  required
                  className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
                >
                  {Object.entries(CATEGORY_LABEL).map(([v, l]) => (
                    <option key={v} value={v}>
                      {l}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <Label htmlFor="description">Décrivez votre besoin</Label>
                <Textarea
                  id="description"
                  name="description"
                  rows={4}
                  required
                  placeholder="Décrivez le contexte et les difficultés rencontrées"
                />
              </div>
              <div>
                <Label htmlFor="adaptations_requested">
                  Adaptations envisagées (optionnel)
                </Label>
                <Textarea
                  id="adaptations_requested"
                  name="adaptations_requested"
                  rows={3}
                  placeholder="Temps majoré, supports agrandis, sous-titres, etc."
                />
              </div>
              <div className="flex justify-end">
                <Button type="submit">Envoyer la demande</Button>
              </div>
            </form>
          </CardBody>
        </Card>

        <Card variant="outline">
          <CardBody>
            <CardTitle>Mes demandes</CardTitle>
            <div className="mt-4 divide-y divide-navy-50">
              {requests && requests.length > 0 ? (
                requests.map((r: any) => (
                  <div key={r.id} className="py-3">
                    <div className="flex items-center justify-between gap-3">
                      <div className="font-medium text-navy-900 text-sm">
                        {CATEGORY_LABEL[r.category] ?? r.category}
                      </div>
                      <Badge size="sm" tone={STATUS_TONE[r.status] ?? "slate"}>
                        {r.status}
                      </Badge>
                    </div>
                    <p className="text-xs text-slate-600 mt-1 line-clamp-2">
                      {r.description}
                    </p>
                    <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-1">
                      <Clock className="h-3 w-3" />
                      {new Date(r.created_at).toLocaleDateString("fr-FR")}
                    </div>
                    {r.admin_response && (
                      <div className="mt-2 rounded-lg bg-navy-50 p-2 text-xs text-slate-700">
                        <CheckCircle2 className="inline h-3 w-3 text-emerald-600 mr-1" />
                        {r.admin_response}
                      </div>
                    )}
                  </div>
                ))
              ) : (
                <p className="text-sm text-slate-500 py-4">Aucune demande pour le moment.</p>
              )}
            </div>
          </CardBody>
        </Card>
      </section>

      {/* Déclaration RGAA — source unique : la déclaration publique canonique
          (évite toute divergence de statut de conformité entre deux pages). */}
      <section>
        <Card>
          <CardBody>
            <CardTitle>Déclaration d'accessibilité</CardTitle>
            <p className="text-sm text-slate-600 mt-1 max-w-2xl">
              L'état de conformité RGAA officiel, les mesures déjà en place et
              les voies de recours (Défenseur des droits) sont publiés sur notre
              déclaration d'accessibilité, tenue à jour après chaque audit.
            </p>
            <div className="mt-4">
              <Link
                href="/declaration-accessibilite"
                className="inline-flex items-center gap-1.5 text-navy-900 font-medium underline"
              >
                Consulter la déclaration d'accessibilité
              </Link>
            </div>
          </CardBody>
        </Card>
      </section>
    </div>
  );
}

function Toggle({
  name,
  checked,
  label,
  hint,
}: {
  name: string;
  checked: boolean;
  label: string;
  hint?: string;
}) {
  return (
    <label className="flex items-start gap-3 cursor-pointer">
      <input
        type="checkbox"
        name={name}
        defaultChecked={checked}
        className="mt-1 h-4 w-4 rounded border-navy-300 text-gold-600 focus:ring-gold-500"
      />
      <span className="flex-1">
        <span className="text-sm font-medium text-navy-900">{label}</span>
        {hint && <span className="block text-xs text-slate-500 mt-0.5">{hint}</span>}
      </span>
    </label>
  );
}
