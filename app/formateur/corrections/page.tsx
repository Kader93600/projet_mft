import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  ArrowRight,
  Hourglass,
  CheckCircle2,
  Clock,
  Award,
  Filter,
} from "lucide-react";
import { findFormation } from "@/lib/formations-config";

export const dynamic = "force-dynamic";

export default async function CorrectionsListPage({
  searchParams,
}: {
  searchParams?: { f?: string };
}) {
  const supabase = createClient();
  const filter = searchParams?.f ?? "";

  // Liste des copies en attente de correction (vue créée en S7.2)
  let query = supabase
    .from("pending_qr_corrections")
    .select("*")
    .order("finished_at", { ascending: true });
  if (filter) query = query.eq("formation_slug", filter);

  const { data: pending } = await query;

  const list = (pending ?? []) as any[];

  // Stats globales : nombre par formation
  const byFormation = list.reduce<Record<string, number>>((acc, row) => {
    const slug = row.formation_slug ?? "—";
    acc[slug] = (acc[slug] ?? 0) + 1;
    return acc;
  }, {});

  return (
    <div className="space-y-8">
      <Link
        href="/formateur"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Tableau de bord
      </Link>

      <header>
        <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-brand-700">
          Pédagogie
        </span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Copies à corriger
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Examens et quiz contenant des questions rédigées en attente de votre
          correction. Plus tôt vous corrigez, plus tôt le stagiaire reçoit sa
          note.
        </p>
      </header>

      {/* KPIs */}
      <section className="grid sm:grid-cols-3 gap-4">
        <Kpi
          icon={Hourglass}
          label="Copies en attente"
          value={list.length}
          tone={list.length > 0 ? "rose" : "brand"}
        />
        <Kpi
          icon={Clock}
          label="Plus ancienne"
          value={
            list[0]?.finished_at
              ? formatRelative(list[0].finished_at)
              : "—"
          }
          tone="brand"
        />
        <Kpi
          icon={CheckCircle2}
          label="Formations couvertes"
          value={Object.keys(byFormation).length}
          tone="brand"
        />
      </section>

      {/* Filtres formation */}
      {Object.keys(byFormation).length > 1 && (
        <section className="flex flex-wrap items-center gap-2">
          <span className="inline-flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500 mr-2">
            <Filter className="h-3.5 w-3.5" />
            Filtrer par formation
          </span>
          <FilterPill
            href="/formateur/corrections"
            label={`Toutes (${list.length})`}
            active={!filter}
          />
          {Object.entries(byFormation).map(([slug, count]) => {
            const f = slug !== "—" ? findFormation(slug) : null;
            return (
              <FilterPill
                key={slug}
                href={`/formateur/corrections?f=${slug}`}
                label={`${f?.code ?? slug} (${count})`}
                active={filter === slug}
                accent={f?.accent}
              />
            );
          })}
        </section>
      )}

      {/* Liste */}
      {list.length === 0 ? (
        <Card>
          <CardBody className="text-center py-14">
            <div className="mx-auto h-12 w-12 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
              <CheckCircle2 className="h-6 w-6" />
            </div>
            <h3 className="mt-4 font-display text-lg font-semibold text-navy-900">
              Toutes les copies sont corrigées
            </h3>
            <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
              Aucune copie en attente pour le moment. Vous serez notifié dès
              qu'un stagiaire soumet un examen contenant des questions rédigées.
            </p>
          </CardBody>
        </Card>
      ) : (
        <Card>
          <CardBody className="p-0">
            <ul className="divide-y divide-navy-50">
              {list.map((row: any) => {
                const f = row.formation_slug
                  ? findFormation(row.formation_slug)
                  : null;
                const days =
                  row.finished_at &&
                  Math.floor(
                    (Date.now() - new Date(row.finished_at).getTime()) /
                      86400000
                  );
                const isUrgent = days !== null && days >= 3;

                return (
                  <li key={row.attempt_id}>
                    <Link
                      href={`/formateur/corrections/${row.attempt_id}`}
                      className="flex items-center gap-4 px-6 py-4 hover:bg-navy-50/40 transition group"
                    >
                      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-bold text-sm shrink-0">
                        {(row.student_name ?? row.student_email ?? "?")[0]?.toUpperCase()}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-navy-900 truncate">
                          {row.student_name ?? row.student_email}
                        </div>
                        <div className="text-xs text-slate-500 mt-0.5 flex items-center gap-2 flex-wrap">
                          {f && (
                            <span
                              className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold"
                              style={{
                                backgroundColor: `${f.accent}22`,
                                color: f.accent,
                                border: `1px solid ${f.accent}55`,
                              }}
                            >
                              {f.code}
                            </span>
                          )}
                          {row.is_mock_exam && (
                            <Badge tone="gold" size="sm">
                              <Award className="h-3 w-3" /> Examen blanc
                            </Badge>
                          )}
                          <span>· {row.quiz_title}</span>
                        </div>
                      </div>
                      <div className="text-right shrink-0">
                        <div className="text-xs text-slate-500">
                          {row.qr_pending} / {row.qr_total} QR
                        </div>
                        {isUrgent && (
                          <Badge tone="rose" size="sm" className="mt-1">
                            En attente {days} j
                          </Badge>
                        )}
                      </div>
                      <ArrowRight className="h-4 w-4 text-slate-400 group-hover:text-brand-700 group-hover:translate-x-1 transition-[transform,color] duration-200 ease-premium motion-reduce:transition-none" />
                    </Link>
                  </li>
                );
              })}
            </ul>
          </CardBody>
        </Card>
      )}
    </div>
  );
}

function formatRelative(iso: string): string {
  const days = Math.floor(
    (Date.now() - new Date(iso).getTime()) / 86400000
  );
  if (days === 0) return "Aujourd'hui";
  if (days === 1) return "Hier";
  return `Il y a ${days} j`;
}

function FilterPill({
  href,
  label,
  active,
  accent,
}: {
  href: string;
  label: string;
  active: boolean;
  accent?: string;
}) {
  return (
    <Link
      href={href}
      className={
        "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
        (active
          ? "text-white border-transparent"
          : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
      }
      style={
        active
          ? {
              backgroundColor: accent ?? "#0F2A4A",
              borderColor: accent ?? "#0F2A4A",
            }
          : undefined
      }
    >
      {label}
    </Link>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  tone,
}: {
  icon: any;
  label: string;
  value: number | string;
  tone: "brand" | "rose";
}) {
  const toneClass =
    tone === "rose"
      ? "bg-rose-50 text-rose-800 border-rose-200"
      : "bg-brand-50 text-brand-700 border-brand-200";
  return (
    <Card>
      <CardBody>
        <div className="flex items-center justify-between gap-3">
          <div>
            <div className="text-xs uppercase tracking-wider text-slate-500">
              {label}
            </div>
            <div className="mt-1 font-display text-2xl font-semibold text-navy-900">
              {value}
            </div>
          </div>
          <div
            className={
              "h-10 w-10 rounded-xl border flex items-center justify-center " +
              toneClass
            }
          >
            <Icon className="h-5 w-5" />
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
