import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ProgressBar } from "@/components/ui/progress";
import {
  ArrowRight,
  Clock,
  Calendar,
  Award,
  Sparkles,
  Truck,
  Bus,
  Car,
  GraduationCap,
  Briefcase,
  Package,
  ShieldCheck,
} from "lucide-react";
import { findFormation } from "@/lib/formations-config";

const ICONS: Record<string, any> = {
  Truck,
  Bus,
  GraduationCap,
  Car,
  Briefcase,
  Package,
  Award,
  ShieldCheck,
};

const STATUS_TONE: Record<
  string,
  "gold" | "navy" | "success" | "slate" | "rose"
> = {
  prospect: "slate",
  devis: "gold",
  accord_financeur: "gold",
  a_payer: "gold",
  en_cours: "navy",
  termine: "success",
  abandon: "slate",
  refuse: "rose",
};

const STATUS_LABEL: Record<string, string> = {
  prospect: "À valider",
  devis: "Devis envoyé",
  accord_financeur: "Accord financeur",
  a_payer: "À régler",
  en_cours: "En cours",
  termine: "Terminée",
  abandon: "Abandonnée",
  refuse: "Refusée",
};

/**
 * Section "Mes formations" affichée en tête du dashboard stagiaire.
 * Liste les enrollments actifs du stagiaire avec progression sommaire
 * et lien direct vers le module / la formation.
 */
export async function MyFormationsSection() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Client session : la RLS enrollments_self (auth.uid()=user_id)
  // suffit, le user ne lit que ses propres enrollments. Le bug de
  // récursion qui imposait le service_role est corrigé.
  const { data: enrollments } = await supabase
    .from("enrollments")
    .select(
      "id, formation_slug, session_label, status, start_date, end_date, total_amount_cents, paid_amount_cents, created_at"
    )
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });

  const list = enrollments ?? [];

  // Pas d'inscription : encart "Découvrir nos formations"
  if (list.length === 0) {
    return (
      <section>
        <Card>
          <CardBody className="text-center py-10 px-6">
            <div className="mx-auto h-12 w-12 rounded-2xl bg-gradient-to-br from-brand-600 to-brand-800 text-signal-400 flex items-center justify-center">
              <Sparkles className="h-6 w-6" />
            </div>
            <h3 className="mt-4 font-display text-xl font-semibold text-navy-900">
              Pas encore inscrit à une formation
            </h3>
            <p className="mt-2 text-sm text-slate-600 max-w-md mx-auto">
              Découvrez nos 8 formations transport et démarrez votre parcours
              en quelques clics.
            </p>
            <Link
              href="/formations"
              className="mt-5 inline-flex items-center gap-2 rounded-xl bg-signal-500 text-night px-5 py-2.5 text-sm font-semibold hover:bg-signal-400 transition shadow-glow-signal"
            >
              Voir nos formations
              <ArrowRight className="h-4 w-4" />
            </Link>
          </CardBody>
        </Card>
      </section>
    );
  }

  return (
    <section>
      <div className="flex items-end justify-between mb-4 flex-wrap gap-2">
        <div>
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-signal-700">
            Mes formations
          </span>
          <h2 className="mt-1 font-display text-2xl font-semibold text-navy-900">
            {list.length === 1
              ? "Ma formation en cours"
              : `${list.length} formations`}
          </h2>
        </div>
        <Link
          href="/inscription"
          className="text-sm font-medium text-brand-700 hover:text-brand-900 inline-flex items-center gap-1.5"
        >
          Mon dossier <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </div>

      <div
        className={
          "grid gap-4 " +
          (list.length === 1
            ? "grid-cols-1"
            : list.length === 2
            ? "md:grid-cols-2"
            : "md:grid-cols-2 lg:grid-cols-3")
        }
      >
        {list.map((e: any) => {
          const f = e.formation_slug ? findFormation(e.formation_slug) : null;
          const Icon = f ? ICONS[f.iconName] ?? Truck : Truck;
          const accent = f?.accent ?? "#9FE220";
          const total = e.total_amount_cents ?? 0;
          const paid = e.paid_amount_cents ?? 0;
          const paidPct = total ? Math.round((paid / total) * 100) : 0;

          return (
            <article
              key={e.id}
              className="relative overflow-hidden rounded-2xl border border-navy-100 bg-white p-6 hover:border-brand-300 hover:shadow-soft transition group"
            >
              <div
                aria-hidden="true"
                className="absolute -top-12 -right-12 h-40 w-40 rounded-full opacity-15 group-hover:opacity-25 transition-opacity blur-2xl"
                style={{ backgroundColor: accent }}
              />

              <div className="relative">
                <div className="flex items-start justify-between gap-3">
                  <div
                    className="h-11 w-11 rounded-xl flex items-center justify-center shrink-0"
                    style={{
                      backgroundColor: `${accent}22`,
                      border: `1px solid ${accent}55`,
                    }}
                  >
                    <Icon className="h-5 w-5" style={{ color: accent }} />
                  </div>
                  <Badge tone={STATUS_TONE[e.status] ?? "slate"} size="sm">
                    {STATUS_LABEL[e.status] ?? e.status}
                  </Badge>
                </div>

                <div className="mt-4 text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                  {f?.code ?? "Formation"}
                </div>
                <h3 className="mt-1 font-display text-lg font-semibold text-navy-900 leading-tight">
                  {f?.title ?? e.session_label ?? "Préparation au titre"}
                </h3>

                <div className="mt-4 grid grid-cols-2 gap-2 text-xs text-slate-600">
                  {e.start_date && (
                    <span className="inline-flex items-center gap-1.5">
                      <Calendar className="h-3.5 w-3.5 text-slate-400" />
                      Début{" "}
                      {new Date(e.start_date).toLocaleDateString("fr-FR", {
                        month: "short",
                        year: "2-digit",
                      })}
                    </span>
                  )}
                  {e.end_date && (
                    <span className="inline-flex items-center gap-1.5">
                      <Clock className="h-3.5 w-3.5 text-slate-400" />
                      Fin{" "}
                      {new Date(e.end_date).toLocaleDateString("fr-FR", {
                        month: "short",
                        year: "2-digit",
                      })}
                    </span>
                  )}
                </div>

                {total > 0 && (
                  <div className="mt-4">
                    <div className="flex items-center justify-between text-[11px] text-slate-500 mb-1">
                      <span>Paiement</span>
                      <span>
                        {paidPct}% ({(paid / 100).toLocaleString("fr-FR")} €)
                      </span>
                    </div>
                    <ProgressBar value={paidPct} />
                  </div>
                )}

                <div className="mt-5 flex items-center gap-2 flex-wrap">
                  <Link
                    href="/modules"
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-navy-900 text-white text-xs font-semibold transition-[transform,background-color] duration-200 ease-premium hover:bg-navy-800 active:scale-[0.98] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/40 motion-reduce:transition-none motion-reduce:active:scale-100"
                  >
                    Mes modules
                    <ArrowRight className="h-3 w-3" />
                  </Link>
                  {f && (
                    <Link
                      href={`/formations/${f.slug}`}
                      className="text-xs text-brand-700 hover:text-brand-900 underline"
                    >
                      Détails
                    </Link>
                  )}
                </div>
              </div>
            </article>
          );
        })}
      </div>
    </section>
  );
}
