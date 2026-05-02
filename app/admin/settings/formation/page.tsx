import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { FormationBadge } from "@/components/formation/formation-badge";
import { FormationForm } from "./formation-form";
import { Settings, AlertCircle, ChevronDown } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function FormationSettingsPage({
  searchParams,
}: {
  searchParams?: { formation?: string };
}) {
  const supabase = createClient();

  // 1) Liste des formations actives
  const { data: formations } = await supabase
    .from("formations")
    .select("slug, code, title, active")
    .eq("active", true)
    .order("code");

  const list = formations ?? [];

  // 2) Slug courant : ?formation=xxx ou la 1ère par défaut
  const currentSlug =
    searchParams?.formation && list.find((f) => f.slug === searchParams.formation)
      ? searchParams.formation
      : list[0]?.slug ?? "";

  const current = list.find((f) => f.slug === currentSlug);

  // 3) Récupérer les paramètres pour la formation courante
  let settings: any = null;
  if (current) {
    const { data: f } = await supabase
      .from("formations")
      .select("id")
      .eq("slug", currentSlug)
      .maybeSingle();
    if (f?.id) {
      const { data } = await supabase
        .from("formation_settings")
        .select("*")
        .eq("formation_id", f.id)
        .maybeSingle();
      settings = data;
    }
  }

  // 4) Compteurs : nb de formations totalement renseignées vs partielles
  const { data: allSettings } = await supabase
    .from("formation_settings")
    .select("formation_id, formation_titre, formation_objectifs, organisme_siret");

  const completed = (allSettings ?? []).filter(
    (s) =>
      s.formation_titre &&
      s.formation_objectifs &&
      s.organisme_siret &&
      s.organisme_siret.length > 0
  ).length;

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Qualiopi · Paramètres</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Programme de formation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Informations de référence utilisées pour générer les documents
          officiels (programme, attestations, certificats, feuilles de
          présence). Une fiche par formation.
        </p>
      </header>

      {/* Sélecteur de formation */}
      <Card>
        <div className="px-6 py-4 border-b border-navy-50 flex items-center justify-between gap-4 flex-wrap">
          <div className="flex items-center gap-3 min-w-0">
            <Settings className="h-4 w-4 text-slate-500 shrink-0" />
            <div className="min-w-0">
              <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium">
                Formation sélectionnée
              </div>
              <div className="font-display font-semibold text-navy-900 truncate">
                {current ? `${current.code} — ${current.title}` : "Aucune formation"}
              </div>
            </div>
          </div>

          <div className="text-xs text-slate-500">
            <strong className="text-navy-900">{completed}</strong> /{" "}
            {list.length} formations renseignées
          </div>
        </div>

        {/* Onglets visuels (toutes les formations) */}
        <div className="px-2 py-3 border-b border-navy-50 overflow-x-auto">
          <div className="flex gap-1 min-w-max">
            {list.map((f) => {
              const active = f.slug === currentSlug;
              return (
                <Link
                  key={f.slug}
                  href={`/admin/settings/formation?formation=${f.slug}`}
                  className={
                    "px-3 py-2 rounded-xl text-xs font-medium transition inline-flex items-center gap-2 " +
                    (active
                      ? "bg-navy-900 text-white shadow-soft"
                      : "bg-white text-slate-700 hover:bg-navy-50 border border-navy-100")
                  }
                >
                  <FormationBadge
                    slug={f.slug}
                    size="xs"
                    icon
                    variant={active ? "solid" : "soft"}
                  />
                  <span className="hidden sm:inline truncate max-w-[180px]">
                    {f.title}
                  </span>
                </Link>
              );
            })}
          </div>
        </div>

        {/* Avertissement si pas encore configuré */}
        {!settings && current && (
          <div className="px-6 py-4 bg-amber-50 border-b border-amber-200 flex items-start gap-3">
            <AlertCircle className="h-5 w-5 text-amber-700 shrink-0 mt-0.5" />
            <div className="text-sm text-amber-900">
              <strong>Première configuration</strong> de cette formation. Les
              valeurs ci-dessous sont des défauts — pensez à compléter et
              enregistrer.
            </div>
          </div>
        )}

        <CardBody>
          {current && (
            <FormationForm
              key={currentSlug /* reset state on formation change */}
              initial={settings}
              formationSlug={currentSlug}
              formationTitle={current.title}
              formationCode={current.code}
            />
          )}
          {!current && (
            <div className="py-10 text-center text-sm text-slate-500">
              Aucune formation active. Activez une formation dans
              /admin/formations pour configurer son programme.
            </div>
          )}
        </CardBody>
      </Card>
    </div>
  );
}
