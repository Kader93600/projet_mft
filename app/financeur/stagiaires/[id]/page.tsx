import Link from "next/link";
import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Award,
  BookOpen,
  Calendar,
  CheckCircle2,
  ClipboardCheck,
  Clock,
  GraduationCap,
  Mail,
  Phone,
  Wallet,
  AlertCircle,
  type LucideIcon,
} from "lucide-react";
import { getFunderAccess } from "@/lib/funder/access";
import type { Tables, Views } from "@/lib/database.types";

export const dynamic = "force-dynamic";

type ScheduleRow = Pick<
  Tables<"payment_schedule">,
  | "id"
  | "due_date"
  | "amount_cents"
  | "paid_at"
  | "paid_amount_cents"
  | "method"
  | "reference"
>;

/** Tentative + embed `quizzes(title, is_mock_exam)` (cf. select). */
type AttemptRow = Pick<
  Tables<"quiz_attempts">,
  "id" | "percentage" | "passed" | "finished_at" | "status"
> & {
  quizzes: Pick<Tables<"quizzes">, "title" | "is_mock_exam"> | null;
};

type CertificateRow = Pick<
  Tables<"certificates">,
  "id" | "type" | "issued_at" | "serial"
>;

const fmtEuros = (cents: number) =>
  (cents / 100).toLocaleString("fr-FR", {
    style: "currency",
    currency: "EUR",
  });

export default async function FinanceurStagiaireDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const access = await getFunderAccess();
  if (!access.allowed) {
    if (access.reason === "unauthenticated") redirect("/login");
    redirect("/financeur");
  }

  const supabase = createClient();

  let detailsQuery = supabase
    .from("funder_student_details")
    .select("*")
    .eq("user_id", params.id);
  if (access.funder_id) detailsQuery = detailsQuery.eq("funder_id", access.funder_id);

  const { data: student } = await detailsQuery.maybeSingle();
  if (!student) notFound();

  const s = student as Views<"funder_student_details">;
  const lessonsTotal = s.lessons_total ?? 0;
  const lessonsDone = s.lessons_done ?? 0;
  const progressPct =
    lessonsTotal > 0 ? Math.round((lessonsDone / lessonsTotal) * 100) : 0;
  const isAtRisk =
    s.status === "en_cours" &&
    (s.days_since_last_activity == null || s.days_since_last_activity > 14);

  // Échéances
  const { data: scheduleRows } = await supabase
    .from("payment_schedule")
    .select("id, due_date, amount_cents, paid_at, paid_amount_cents, method, reference")
    .eq("enrollment_id", s.enrollment_id)
    .order("due_date");
  const schedule = (scheduleRows ?? []) as ScheduleRow[];

  // Tentatives quiz (limité aux essentiels — pas de détails de réponses)
  // `overrideTypes` (API supabase-js) : client non paramétré par `Database`
  // → l'embed to-one `quizzes` est inféré en tableau alors que PostgREST
  // renvoie un objet.
  const { data: attemptRows } = await supabase
    .from("quiz_attempts")
    .select(`
      id, percentage, passed, finished_at, status,
      quizzes ( title, is_mock_exam )
    `)
    .eq("user_id", params.id)
    .not("finished_at", "is", null)
    .order("finished_at", { ascending: false })
    .limit(10)
    .overrideTypes<AttemptRow[], { merge: false }>();
  const attempts = attemptRows ?? [];

  // Certificats
  const { data: certificateRows } = await supabase
    .from("certificates")
    .select("id, type, issued_at, serial")
    .eq("user_id", params.id)
    .is("revoked_at", null)
    .order("issued_at", { ascending: false });
  const certificates = (certificateRows ?? []) as CertificateRow[];

  return (
    <div className="space-y-8">
      <div>
        <Link
          href="/financeur/stagiaires"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Tous les stagiaires
        </Link>
      </div>

      {/* Header */}
      <header className="flex items-start gap-4 flex-wrap">
        <div className="h-14 w-14 rounded-full bg-gradient-to-br from-brand-500 to-brand-700 text-white flex items-center justify-center font-display text-lg font-bold shrink-0">
          {(s.full_name ?? s.email ?? "?").slice(0, 2).toUpperCase()}
        </div>
        <div className="flex-1 min-w-0">
          <h1 className="font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
            {s.full_name ?? s.email ?? "—"}
          </h1>
          <div className="mt-2 flex items-center gap-3 flex-wrap text-sm text-slate-600">
            {s.email && (
              <span className="inline-flex items-center gap-1">
                <Mail className="h-3.5 w-3.5" /> {s.email}
              </span>
            )}
            {s.phone && (
              <span className="inline-flex items-center gap-1">
                <Phone className="h-3.5 w-3.5" /> {s.phone}
              </span>
            )}
          </div>
          <div className="mt-3 flex items-center gap-2 flex-wrap">
            <Badge tone="navy" size="sm">
              <GraduationCap className="h-3 w-3" /> {s.formation_title}
            </Badge>
            <Badge tone="gold" size="sm">
              {s.pack}
            </Badge>
            {s.certified && (
              <Badge tone="success" size="sm">
                <Award className="h-3 w-3" /> Certifié
              </Badge>
            )}
            {isAtRisk && (
              <Badge tone="rose" size="sm">
                <AlertCircle className="h-3 w-3" /> Inactif{" "}
                {s.days_since_last_activity
                  ? `${s.days_since_last_activity}j`
                  : ""}
              </Badge>
            )}
          </div>
        </div>
      </header>

      {/* KPIs */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4">
        <Kpi
          icon={BookOpen}
          label="Progression"
          value={`${progressPct}%`}
          hint={`${s.lessons_done}/${s.lessons_total} leçons`}
        />
        <Kpi
          icon={ClipboardCheck}
          label="Score moyen"
          value={s.avg_score != null ? `${s.avg_score}%` : "—"}
          hint="Sur les quiz QCM"
        />
        <Kpi
          icon={Award}
          label="Examen blanc"
          value={s.mock_exam_attempted ? "Oui" : "—"}
          hint={s.mock_exam_attempted ? "Au moins 1 tenté" : "Pas encore tenté"}
        />
        <Kpi
          icon={Wallet}
          label="Payé"
          value={fmtEuros(s.paid_amount_cents ?? 0)}
          hint={`sur ${fmtEuros(s.total_amount_cents ?? 0)}`}
        />
      </div>

      {/* Échéances */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Calendar className="h-5 w-5 text-gold-700" />
          Échéances de paiement
        </h2>
        <Card>
          <CardBody className="p-0">
            {schedule.length === 0 ? (
              <p className="text-sm text-slate-500 px-5 py-6">
                Aucune échéance enregistrée. La facturation est gérée hors
                échéancier (paiement direct).
              </p>
            ) : (
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-3 font-semibold">Échéance</th>
                    <th className="text-right px-4 py-3 font-semibold">Montant</th>
                    <th className="text-left px-4 py-3 font-semibold">Méthode</th>
                    <th className="text-left px-4 py-3 font-semibold">Référence</th>
                    <th className="text-right px-4 py-3 font-semibold">Statut</th>
                  </tr>
                </thead>
                <tbody>
                  {schedule.map((p) => {
                    const isPaid = !!p.paid_at;
                    return (
                      <tr key={p.id} className="border-t border-navy-50">
                        <td className="px-4 py-3 text-navy-900">{p.due_date}</td>
                        <td className="px-4 py-3 text-right font-medium tabular-nums">
                          {fmtEuros(p.amount_cents)}
                        </td>
                        <td className="px-4 py-3 text-slate-600">
                          {p.method ?? "—"}
                        </td>
                        <td className="px-4 py-3 text-slate-600 text-xs">
                          {p.reference ?? "—"}
                        </td>
                        <td className="px-4 py-3 text-right">
                          {isPaid ? (
                            <Badge tone="success" size="sm">
                              <CheckCircle2 className="h-3 w-3" /> Payé
                            </Badge>
                          ) : (
                            <Badge tone="slate" size="sm">
                              <Clock className="h-3 w-3" /> Dû
                            </Badge>
                          )}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </CardBody>
        </Card>
      </section>

      {/* Tentatives quiz */}
      {attempts.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <ClipboardCheck className="h-5 w-5 text-gold-700" />
            Derniers résultats
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {attempts.map((a) => (
                  <li
                    key={a.id}
                    className="px-5 py-3 flex items-center justify-between gap-3"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2 flex-wrap">
                        <span className="font-medium text-navy-900">
                          {a.quizzes?.title ?? "Quiz"}
                        </span>
                        {a.quizzes?.is_mock_exam && (
                          <Badge tone="gold" size="sm">
                            <Award className="h-3 w-3" /> Examen blanc
                          </Badge>
                        )}
                      </div>
                      <div className="text-xs text-slate-500">
                        {a.finished_at
                          ? new Date(a.finished_at).toLocaleDateString("fr-FR", {
                              day: "2-digit",
                              month: "short",
                              year: "numeric",
                            })
                          : "—"}
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      <Badge
                        tone={a.passed ? "success" : "slate"}
                        size="sm"
                      >
                        {a.passed ? "Réussi" : "À reprendre"}
                      </Badge>
                      <span
                        className={
                          a.percentage != null
                            ? "font-display font-semibold text-base tabular-nums text-navy-900"
                            : "text-slate-400 text-sm"
                        }
                      >
                        {a.percentage != null ? `${a.percentage}%` : "En cours"}
                      </span>
                    </div>
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Certificats */}
      {certificates.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <Award className="h-5 w-5 text-emerald-700" />
            Certifications
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {certificates.map((c) => (
                  <li
                    key={c.id}
                    className="px-5 py-3 flex items-center justify-between"
                  >
                    <div>
                      <div className="font-medium text-navy-900">
                        {c.type === "final"
                          ? "Certificat de fin de formation"
                          : "Attestation de bloc"}
                      </div>
                      <div className="text-xs text-slate-500">
                        N° {c.serial} · délivré le{" "}
                        {new Date(c.issued_at).toLocaleDateString("fr-FR", {
                          day: "2-digit",
                          month: "short",
                          year: "numeric",
                        })}
                      </div>
                    </div>
                    <Badge tone="success" size="sm">
                      <Award className="h-3 w-3" /> Délivré
                    </Badge>
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      <p className="text-[11px] text-slate-500">
        Note RGPD : votre accès se limite aux indicateurs pédagogiques et
        financiers. Les messages stagiaire ↔ formateur ne sont pas accessibles.
      </p>
    </div>
  );
}

function Kpi({
  icon: Icon,
  label,
  value,
  hint,
}: {
  icon: LucideIcon;
  label: string;
  value: string;
  hint?: string;
}) {
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div className="h-10 w-10 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0">
            <Icon className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
              {label}
            </div>
            <div className="font-display text-xl sm:text-2xl font-semibold text-navy-900 mt-0.5 tabular-nums leading-none">
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
