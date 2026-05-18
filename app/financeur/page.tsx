import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Users,
  Wallet,
  TrendingUp,
  CheckCircle2,
  AlertTriangle,
  GraduationCap,
  Award,
  Calendar,
  ArrowRight,
  Download,
  FileJson,
} from "lucide-react";
import { getFunderAccess } from "@/lib/funder/access";

export const dynamic = "force-dynamic";

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  });

export default async function FinanceurPage() {
  const access = await getFunderAccess();
  if (!access.allowed) {
    if (access.reason === "unauthenticated") redirect("/login");
    return (
      <div className="space-y-6 max-w-2xl">
        <header>
          <span className="eyebrow text-gold-700">Espace financeur</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
            Accès réservé
          </h1>
        </header>
        <Card>
          <CardBody className="text-sm text-slate-600">
            {access.reason ??
              "Votre compte n'est pas rattaché à un financeur. Contactez l'administration MFT."}
          </CardBody>
        </Card>
      </div>
    );
  }

  const supabase = createClient();

  // KPIs via RPC (security definer)
  const { data: kpis } = await supabase
    .rpc("funder_dashboard_kpis", { p_funder_id: access.funder_id })
    .single();
  const k = (kpis as any) ?? {};

  // Événements récents (timeline)
  let eventsQuery = supabase
    .from("funder_recent_events")
    .select("*")
    .order("occurred_at", { ascending: false })
    .limit(15);
  if (access.funder_id) {
    eventsQuery = eventsQuery.eq("funder_id", access.funder_id);
  }
  const { data: events } = await eventsQuery;

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Espace financeur</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            {access.funder_name ?? "Mon portfolio"}
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Suivi temps réel des stagiaires que vous financez. Données extraites
            de la plateforme MFT, mises à jour en continu.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Link
            href="/api/funder/export?format=csv"
            className="inline-flex items-center gap-1.5 rounded-xl bg-navy-900 hover:bg-navy-800 text-white px-3.5 py-2 text-sm font-medium transition-colors"
          >
            <Download className="h-4 w-4" />
            Export CSV
          </Link>
          <Link
            href="/api/funder/export?format=json"
            className="inline-flex items-center gap-1.5 rounded-xl bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-3.5 py-2 text-sm font-medium transition-colors"
          >
            <FileJson className="h-4 w-4" />
            Export JSON
          </Link>
        </div>
      </header>

      {/* KPIs principaux */}
      <section className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={Users}
          label="Stagiaires financés"
          value={String(k.enrollments_total ?? 0)}
          hint={`${k.enrollments_active ?? 0} en cours · ${k.enrollments_done ?? 0} terminés`}
        />
        <Kpi
          icon={TrendingUp}
          label="Progression moyenne"
          value={`${k.avg_progress_pct ?? 0}%`}
          hint={k.avg_score != null ? `Score moyen : ${k.avg_score}%` : undefined}
        />
        <Kpi
          icon={Award}
          label="Certifiés"
          value={String(k.certified_count ?? 0)}
          hint={
            k.enrollments_total > 0
              ? `${Math.round(((k.certified_count ?? 0) / k.enrollments_total) * 100)}% du total`
              : "—"
          }
          tone="success"
        />
        <Kpi
          icon={AlertTriangle}
          label="En vigilance"
          value={String(k.enrollments_at_risk ?? 0)}
          hint="Inactifs depuis > 14 jours"
          tone={k.enrollments_at_risk > 0 ? "warning" : "default"}
        />
      </section>

      {/* Budget */}
      <section>
        <Card variant="gold">
          <CardBody className="grid grid-cols-2 md:grid-cols-3 gap-6">
            <Stat
              icon={Wallet}
              label="Budget engagé"
              value={fmtEuros(k.total_budget_cents ?? 0)}
            />
            <Stat
              icon={CheckCircle2}
              label="Encaissé"
              value={fmtEuros(k.total_paid_cents ?? 0)}
            />
            <Stat
              icon={Calendar}
              label="Reste à percevoir"
              value={fmtEuros(
                (k.total_budget_cents ?? 0) - (k.total_paid_cents ?? 0)
              )}
            />
          </CardBody>
        </Card>
      </section>

      {/* CTA voir stagiaires */}
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <h2 className="font-display text-xl font-semibold text-navy-900 inline-flex items-center gap-2">
          <GraduationCap className="h-5 w-5 text-gold-700" />
          Activité récente
        </h2>
        <Link
          href="/financeur/stagiaires"
          className="inline-flex items-center gap-1.5 text-sm font-medium text-navy-900 hover:text-gold-700"
        >
          Voir tous les stagiaires
          <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </div>

      {/* Timeline événements */}
      <Card>
        <CardBody className="p-0">
          {(events ?? []).length === 0 ? (
            <div className="text-center py-10 px-5">
              <div className="mx-auto h-12 w-12 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center">
                <Calendar className="h-6 w-6" />
              </div>
              <p className="mt-4 font-medium text-navy-900">
                Aucun événement récent
              </p>
              <p className="text-sm text-slate-600 mt-1 max-w-md mx-auto">
                Les nouvelles inscriptions, examens blancs et certifications de
                vos stagiaires apparaîtront ici.
              </p>
            </div>
          ) : (
            <ul className="divide-y divide-navy-50">
              {(events as any[]).map((e) => {
                const isCert = e.event_kind === "certificate";
                const Icon = isCert ? Award : GraduationCap;
                const eventTone = isCert ? "success" : "navy";
                const eventLabel = isCert ? "Certification" : "Inscription";
                return (
                  <li
                    key={`${e.event_kind}-${e.ref_id}`}
                    className="px-5 py-3.5 flex items-center justify-between gap-3"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div
                        className={
                          isCert
                            ? "h-9 w-9 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center shrink-0"
                            : "h-9 w-9 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0"
                        }
                      >
                        <Icon className="h-4 w-4" />
                      </div>
                      <div className="min-w-0">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="font-medium text-navy-900">
                            {e.student_name ?? "Stagiaire"}
                          </span>
                          <Badge tone={eventTone} size="sm">
                            {eventLabel}
                          </Badge>
                        </div>
                        <div className="text-xs text-slate-500">
                          {e.formation_title}
                        </div>
                      </div>
                    </div>
                    <div className="text-xs text-slate-500 shrink-0">
                      {new Date(e.occurred_at).toLocaleDateString("fr-FR", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                    </div>
                  </li>
                );
              })}
            </ul>
          )}
        </CardBody>
      </Card>
    </div>
  );
}

// ─── Internes ────────────────────────────────────────────────────────

function Kpi({
  icon: Icon,
  label,
  value,
  hint,
  tone = "default",
}: {
  icon: any;
  label: string;
  value: string;
  hint?: string;
  tone?: "default" | "warning" | "success";
}) {
  const iconBg =
    tone === "warning"
      ? "bg-amber-50 border-amber-200 text-amber-700"
      : tone === "success"
      ? "bg-emerald-50 border-emerald-200 text-emerald-700"
      : "bg-gold-50 border-gold-200 text-gold-700";
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div
            className={`h-10 w-10 rounded-xl border flex items-center justify-center shrink-0 ${iconBg}`}
          >
            <Icon className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
              {label}
            </div>
            <div className="font-display text-2xl sm:text-[28px] font-semibold text-navy-900 mt-0.5 tabular-nums leading-none">
              {value}
            </div>
            {hint && (
              <div className="text-[11px] text-slate-500 mt-1.5">{hint}</div>
            )}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}

function Stat({
  icon: Icon,
  label,
  value,
}: {
  icon: any;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-center gap-3">
      <Icon className="h-5 w-5 text-gold-700 shrink-0" />
      <div>
        <div className="text-[11px] uppercase tracking-wider text-gold-800 font-medium">
          {label}
        </div>
        <div className="font-display text-xl font-semibold text-navy-900 mt-0.5 tabular-nums">
          {value}
        </div>
      </div>
    </div>
  );
}
