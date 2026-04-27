import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Download, BookOpen, Users, Wallet, Activity } from "lucide-react";

export const dynamic = "force-dynamic";

function fmtEuros(eur: number) {
  return new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format(eur);
}

export default async function BpfPage({
  searchParams,
}: {
  searchParams?: { year?: string };
}) {
  const year = Number(searchParams?.year ?? new Date().getFullYear() - 1);
  const supabase = createClient();
  const { data: summary } = await supabase.rpc("bpf_summary", { p_year: year });

  const s = (summary ?? {}) as any;
  const revenues = (s.recettes_par_financeur ?? []) as any[];

  const yearOptions = [year + 1, year, year - 1, year - 2].filter(
    (y) => y <= new Date().getFullYear()
  );

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Reporting</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Bilan Pédagogique et Financier
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Synthèse pour la déclaration BPF DGEFP (à transmettre avant le 30
            avril). Les chiffres ci-dessous sont à reporter dans le formulaire
            CERFA n° 10443*16.
          </p>
        </div>

        <form
          action=""
          className="flex items-center gap-2 text-sm"
          method="get"
        >
          <label className="text-slate-600">Exercice</label>
          <select
            name="year"
            defaultValue={year}
            className="h-10 rounded-xl border border-navy-200 bg-white px-3 text-navy-900"
          >
            {yearOptions.map((y) => (
              <option key={y} value={y}>
                {y}
              </option>
            ))}
          </select>
          <Button type="submit" variant="secondary" size="sm">
            Afficher
          </Button>
        </form>
      </header>

      {/* KPIs */}
      <section className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Kpi
          icon={Users}
          label="Stagiaires"
          value={String(s.stagiaires_total ?? 0)}
          sub="Personnes ayant suivi ≥ 1 h"
        />
        <Kpi
          icon={Activity}
          label="Heures réalisées"
          value={String(s.heures_realisees ?? 0)}
          sub="Total h-stagiaires"
        />
        <Kpi
          icon={Wallet}
          label="Chiffre d'affaires"
          value={fmtEuros(Number(s.recette_totale_eur ?? 0))}
          sub={`Exercice ${year}`}
        />
        <Kpi
          icon={BookOpen}
          label="Action"
          value="RNCP 40990"
          sub="Titre professionnel"
        />
      </section>

      {/* Recettes par financeur */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Recettes par type de financement
        </h2>
        <Card>
          <CardBody className="p-0">
            {revenues.length === 0 ? (
              <div className="p-10 text-center text-sm text-slate-500">
                Aucune recette enregistrée sur {year}.
              </div>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-6 py-3">Type</th>
                    <th className="text-left px-6 py-3">Financeur</th>
                    <th className="text-right px-6 py-3">Stagiaires</th>
                    <th className="text-right px-6 py-3">Recette (€)</th>
                  </tr>
                </thead>
                <tbody>
                  {revenues.map((r, i) => (
                    <tr key={i} className="border-t border-navy-50">
                      <td className="px-6 py-3">
                        <Badge tone="navy" size="sm">
                          {r.kind}
                        </Badge>
                      </td>
                      <td className="px-6 py-3 text-navy-900 font-medium">
                        {r.name}
                      </td>
                      <td className="px-6 py-3 text-right">{r.stagiaires}</td>
                      <td className="px-6 py-3 text-right font-mono">
                        {fmtEuros(Number(r.recette_eur))}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr className="bg-navy-50 font-semibold">
                    <td className="px-6 py-3" colSpan={2}>
                      Total
                    </td>
                    <td className="px-6 py-3 text-right">
                      {revenues.reduce(
                        (sum, r) => sum + (r.stagiaires ?? 0),
                        0
                      )}
                    </td>
                    <td className="px-6 py-3 text-right font-mono">
                      {fmtEuros(Number(s.recette_totale_eur ?? 0))}
                    </td>
                  </tr>
                </tfoot>
              </table>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Exports */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Exports
        </h2>
        <div className="grid md:grid-cols-2 gap-4">
          <ExportCard
            href={`/api/admin/bpf/export?year=${year}&type=stagiaires`}
            title="Détail stagiaires (CSV)"
            desc="Liste nominative avec heures réalisées par stagiaire — base pour les annexes."
          />
          <ExportCard
            href={`/api/admin/bpf/export?year=${year}&type=recettes`}
            title="Recettes par financeur (CSV)"
            desc="Détail des encaissements par dispositif et par organisme financeur."
          />
        </div>
      </section>

      <div className="text-xs text-slate-500">
        Référence légale : article L. 6352-11 du Code du travail. Dépôt sur{" "}
        <a
          href="https://www.demarches-simplifiees.fr/commencer/bpf"
          target="_blank"
          rel="noreferrer"
          className="underline text-navy-900"
        >
          demarches-simplifiees.fr
        </a>{" "}
        avant le 30 avril.
      </div>
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  sub,
}: {
  icon: any;
  label: string;
  value: string;
  sub: string;
}) {
  return (
    <Card>
      <CardBody>
        <div className="flex items-start justify-between gap-3">
          <div>
            <div className="text-[11px] uppercase tracking-wider text-slate-500">
              {label}
            </div>
            <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
              {value}
            </div>
            <div className="text-xs text-slate-500 mt-0.5">{sub}</div>
          </div>
          <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-900 flex items-center justify-center">
            <Icon className="h-5 w-5" />
          </div>
        </div>
      </CardBody>
    </Card>
  );
}

function ExportCard({
  href,
  title,
  desc,
}: {
  href: string;
  title: string;
  desc: string;
}) {
  return (
    <Card>
      <CardBody>
        <CardTitle>{title}</CardTitle>
        <p className="text-sm text-slate-600 mt-1">{desc}</p>
        <Link
          href={href}
          className="mt-4 inline-flex items-center gap-2 px-3 py-1.5 rounded-lg border border-navy-200 text-sm font-medium text-navy-900 hover:bg-navy-50"
        >
          <Download className="h-4 w-4" /> Télécharger CSV
        </Link>
      </CardBody>
    </Card>
  );
}
