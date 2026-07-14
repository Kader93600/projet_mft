import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Database,
  CheckCircle2,
  AlertTriangle,
  Filter,
  ArrowRight,
  FileText,
  Sparkles,
} from "lucide-react";
import { FORMATIONS } from "@/lib/formations-config";
import { accentVars } from "@/lib/formation-accent";

export const dynamic = "force-dynamic";

export default async function BanqueQuestionsPage(
  props: {
    searchParams?: Promise<{ f?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const supabase = await createClient();
  const filter = searchParams?.f ?? "";

  // Stats par formation
  const stats = await Promise.all(
    FORMATIONS.map(async (f) => {
      const { data: formation } = await supabase
        .from("formations")
        .select("id")
        .eq("slug", f.slug)
        .single();
      if (!formation) {
        return {
          ...f,
          total: 0,
          qcm: 0,
          qr: 0,
          active: 0,
          pending: 0,
          pendingQr: 0,
        };
      }
      const [
        { count: total },
        { count: qcm },
        { count: qr },
        { count: active },
        { count: pending },
        { count: pendingQr },
      ] = await Promise.all([
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", formation.id),
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", formation.id)
          .eq("type", "qcm"),
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", formation.id)
          .eq("type", "qr"),
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", formation.id)
          .eq("active", true),
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", formation.id)
          .eq("active", false)
          .eq("type", "qcm"),
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", formation.id)
          .eq("active", false)
          .eq("type", "qr"),
      ]);
      return {
        ...f,
        total: total ?? 0,
        qcm: qcm ?? 0,
        qr: qr ?? 0,
        active: active ?? 0,
        pending: pending ?? 0,
        pendingQr: pendingQr ?? 0,
      };
    })
  );

  const totalQuestions = stats.reduce((s, f) => s + f.total, 0);
  const totalActive = stats.reduce((s, f) => s + f.active, 0);
  const totalPending = stats.reduce((s, f) => s + f.pending, 0);
  const totalPendingQr = stats.reduce((s, f) => s + f.pendingQr, 0);
  const focused = filter ? stats.find((f) => f.slug === filter) : null;

  return (
    <div className="space-y-10">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-signal-700">Pédagogie</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Banque de questions
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Gestion centralisée des QCM et questions rédigées par formation.
            Les questions importées doivent être <strong>validées</strong> (bonne
            réponse cochée) avant d'être actives en circulation.
          </p>
        </div>
        <div className="flex items-center gap-2 flex-wrap justify-end">
          <Link
            href="/admin/banque-questions/new-qr"
            className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl border border-navy-200 bg-white text-navy-900 font-semibold text-sm hover:bg-navy-50 transition whitespace-nowrap"
            title="Question rédigée avec correction manuelle"
          >
            <FileText className="h-3.5 w-3.5" />
            Nouvelle QR
          </Link>
          <Link
            href="/admin/banque-questions/new-qcm"
            className="inline-flex items-center gap-1.5 px-3 py-2 rounded-xl border border-navy-200 bg-white text-navy-900 font-semibold text-sm hover:bg-navy-50 transition whitespace-nowrap"
            title="Question à choix multiples (correction auto)"
          >
            <CheckCircle2 className="h-3.5 w-3.5" />
            Nouveau QCM
          </Link>
          <Link
            href="/admin/banque-questions/import"
            className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-gold-500 text-night-900 font-semibold text-sm hover:bg-gold-400 transition shadow-soft whitespace-nowrap"
          >
            <FileText className="h-4 w-4" />
            Importer un PDF
          </Link>
        </div>
      </header>

      {/* KPIs globaux */}
      <section className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Kpi
          icon={Database}
          label="Total questions"
          value={totalQuestions}
          tone="brand"
        />
        <Kpi
          icon={CheckCircle2}
          label="Actives"
          value={totalActive}
          tone="success"
        />
        <Kpi
          icon={AlertTriangle}
          label="QCM à valider"
          value={totalPending}
          tone={totalPending > 0 ? "rose" : "brand"}
        />
        <Kpi
          icon={AlertTriangle}
          label="QR à valider"
          value={totalPendingQr}
          tone={totalPendingQr > 0 ? "rose" : "brand"}
        />
      </section>

      {/* Filtre par formation */}
      <section>
        <div className="flex items-center gap-2 mb-3">
          <Filter className="h-4 w-4 text-slate-500" />
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-slate-500">
            Filtrer par formation
          </span>
        </div>
        <div className="flex flex-wrap gap-2">
          <Link
            href="/admin/banque-questions"
            className={
              "px-3 py-1.5 rounded-full text-xs font-medium border transition " +
              (!filter
                ? "bg-navy-900 text-white border-navy-900"
                : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
            }
          >
            Toutes
          </Link>
          {stats
            .filter((s) => s.total > 0)
            .map((s) => (
              <Link
                key={s.slug}
                href={`/admin/banque-questions?f=${s.slug}`}
                className={
                  "inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition " +
                  (filter === s.slug
                    ? "text-white border-transparent"
                    : "bg-white text-slate-600 border-navy-100 hover:border-navy-300")
                }
                style={
                  filter === s.slug
                    ? { backgroundColor: s.accent, borderColor: s.accent }
                    : undefined
                }
              >
                {s.code}
                <span
                  className={
                    "ml-1 px-1.5 py-0.5 rounded-md text-[10px] font-bold " +
                    (filter === s.slug
                      ? "bg-white/20 text-white"
                      : "bg-navy-50 text-navy-700")
                  }
                >
                  {s.total}
                </span>
              </Link>
            ))}
        </div>
      </section>

      {/* Détail formation focus */}
      {focused && (
        <section
          className="rounded-2xl border-2 p-6 relative overflow-hidden"
          style={{ borderColor: `${focused.accent}55` }}
        >
          <div
            aria-hidden="true"
            className="absolute -top-12 -right-12 h-40 w-40 rounded-full opacity-15 blur-2xl"
            style={{ backgroundColor: focused.accent }}
          />
          <div className="relative grid md:grid-cols-2 gap-6">
            <div>
              <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-slate-500">
                {focused.code}
              </div>
              <h2 className="mt-1 font-display text-xl font-semibold text-navy-900">
                {focused.title}
              </h2>
              <div className="mt-4 grid grid-cols-2 gap-3">
                <DetailStat
                  label="QCM"
                  value={focused.qcm}
                  hint={`dont ${focused.pending} à valider`}
                />
                <DetailStat label="QR rédigées" value={focused.qr} />
                <DetailStat
                  label="Actives"
                  value={focused.active}
                  highlight={focused.active > 0}
                />
                <DetailStat
                  label="Inactives"
                  value={focused.total - focused.active}
                  highlight={focused.pending > 0}
                  tone="rose"
                />
              </div>
            </div>
            <div className="flex flex-col gap-2 justify-center">
              <Link
                href={`/admin/banque-questions/validation?f=${focused.slug}`}
                className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 transition p-4 group"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-[10px] font-semibold uppercase tracking-wider text-rose-700">
                      À valider
                    </div>
                    <div className="font-display text-2xl font-semibold text-rose-900 mt-0.5">
                      {focused.pending} QCM
                    </div>
                    <div className="text-xs text-rose-700/80 mt-1">
                      Cocher la bonne réponse → activer la question
                    </div>
                  </div>
                  <ArrowRight className="h-5 w-5 text-rose-700 group-hover:translate-x-1 transition-transform" />
                </div>
              </Link>
              <Link
                href={`/admin/banque-questions/liste?f=${focused.slug}`}
                className="rounded-xl border border-navy-100 bg-white hover:border-brand-300 hover:shadow-soft transition p-4 group"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-[10px] font-semibold uppercase tracking-wider text-slate-500">
                      Liste complète
                    </div>
                    <div className="font-display text-2xl font-semibold text-navy-900 mt-0.5">
                      {focused.total} questions
                    </div>
                    <div className="text-xs text-slate-500 mt-1">
                      Recherche, édition, désactivation
                    </div>
                  </div>
                  <ArrowRight className="h-5 w-5 text-brand-700 group-hover:translate-x-1 transition-transform" />
                </div>
              </Link>
              <Link
                href={`/admin/banque-questions/creer-quiz?f=${focused.slug}`}
                className="rounded-xl border border-signal-300 bg-signal-50 hover:bg-signal-100 transition p-4 group"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <div className="text-[10px] font-semibold uppercase tracking-wider text-signal-700">
                      Créer un quiz
                    </div>
                    <div className="font-display text-2xl font-semibold text-navy-900 mt-0.5">
                      Nouveau examen
                    </div>
                    <div className="text-xs text-signal-700/80 mt-1">
                      Tirage aléatoire ou sélection manuelle
                    </div>
                  </div>
                  <ArrowRight className="h-5 w-5 text-signal-700 group-hover:translate-x-1 transition-transform" />
                </div>
              </Link>
              {focused.qr > 0 && (
                <Link
                  href={`/admin/banque-questions/validation-qr?f=${focused.slug}`}
                  className="rounded-xl border border-amber-200 bg-amber-50 hover:bg-amber-100 transition p-4 group"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <div className="text-[10px] font-semibold uppercase tracking-wider text-amber-700">
                        Questions rédigées
                      </div>
                      <div className="font-display text-2xl font-semibold text-navy-900 mt-0.5">
                        {focused.qr} QR
                      </div>
                      <div className="text-xs text-amber-700/80 mt-1">
                        Réponses-modèles + barème + activation
                      </div>
                    </div>
                    <ArrowRight className="h-5 w-5 text-amber-700 group-hover:translate-x-1 transition-transform" />
                  </div>
                </Link>
              )}
            </div>
          </div>
        </section>
      )}

      {/* Tableau global */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Toutes les formations
        </h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-6 py-3">Formation</th>
                  <th className="text-right px-3 py-3">QCM</th>
                  <th className="text-right px-3 py-3">QR</th>
                  <th className="text-right px-3 py-3">Actives</th>
                  <th className="text-right px-3 py-3">À valider</th>
                  <th className="text-right px-6 py-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {stats
                  .sort((a, b) => b.total - a.total)
                  .map((s) => (
                    <tr key={s.slug} className="border-t border-navy-50">
                      <td className="px-6 py-3">
                        <span
                          className="formation-accent inline-flex items-center gap-1.5 px-2 py-0.5 rounded-md text-xs font-semibold border"
                          style={accentVars(s.accent)}
                        >
                          {s.code}
                        </span>
                      </td>
                      <td className="px-3 py-3 text-right">{s.qcm}</td>
                      <td className="px-3 py-3 text-right">{s.qr}</td>
                      <td className="px-3 py-3 text-right">
                        {s.active > 0 ? (
                          <Badge tone="success" size="sm">
                            {s.active}
                          </Badge>
                        ) : (
                          <span className="text-slate-400">0</span>
                        )}
                      </td>
                      <td className="px-3 py-3 text-right">
                        {s.pending + s.pendingQr > 0 ? (
                          <div className="inline-flex items-center gap-1">
                            <Badge tone="rose" size="sm">
                              {s.pending + s.pendingQr}
                            </Badge>
                            {(s.pending > 0 || s.pendingQr > 0) && (
                              <span className="text-[10px] text-slate-500">
                                {s.pending > 0 && `${s.pending} QCM`}
                                {s.pending > 0 && s.pendingQr > 0 && " · "}
                                {s.pendingQr > 0 && `${s.pendingQr} QR`}
                              </span>
                            )}
                          </div>
                        ) : (
                          <span className="text-slate-400">0</span>
                        )}
                      </td>
                      <td className="px-6 py-3 text-right">
                        {s.pending > 0 || s.pendingQr > 0 ? (
                          <div className="inline-flex items-center gap-2 flex-wrap justify-end">
                            {s.pending > 0 && (
                              <Link
                                href={`/admin/banque-questions/validation?f=${s.slug}`}
                                className="inline-flex items-center gap-1 text-rose-700 hover:text-rose-900 text-xs font-semibold"
                              >
                                Valider QCM
                                <ArrowRight className="h-3 w-3" />
                              </Link>
                            )}
                            {s.pendingQr > 0 && (
                              <Link
                                href={`/admin/banque-questions/validation-qr?f=${s.slug}`}
                                className="inline-flex items-center gap-1 text-rose-700 hover:text-rose-900 text-xs font-semibold"
                              >
                                Valider QR
                                <ArrowRight className="h-3 w-3" />
                              </Link>
                            )}
                          </div>
                        ) : s.total > 0 ? (
                          <Link
                            href={`/admin/banque-questions?f=${s.slug}`}
                            className="text-slate-500 hover:text-navy-900 text-xs"
                          >
                            Détails
                          </Link>
                        ) : (
                          <span className="text-slate-400 text-xs">—</span>
                        )}
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>

      {/* Note pédagogique */}
      <Card>
        <CardBody className="flex items-start gap-3">
          <div className="h-10 w-10 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center shrink-0">
            <Sparkles className="h-5 w-5" />
          </div>
          <div className="text-sm text-slate-700 leading-relaxed">
            <CardTitle className="text-base">Workflow d'import</CardTitle>
            <ol className="mt-2 list-decimal pl-5 space-y-1">
              <li>
                Parser les PDFs avec{" "}
                <code className="text-xs">scripts/parse_capa_pdf.py</code>
              </li>
              <li>
                Jouer{" "}
                <code className="text-xs">supabase/capa_questions_import.sql</code>{" "}
                dans le SQL Editor → questions importées avec{" "}
                <code className="text-xs">active=false</code>
              </li>
              <li>
                Page <strong>Validation</strong> : un formateur lead coche la
                bonne réponse de chaque QCM, puis active
              </li>
              <li>
                Une fois validées, les questions deviennent disponibles pour
                les quiz et examens blancs
              </li>
            </ol>
          </div>
        </CardBody>
      </Card>
    </div>
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
  value: number;
  tone: "brand" | "success" | "rose";
}) {
  const toneClass =
    tone === "success"
      ? "bg-emerald-50 text-emerald-800 border-emerald-200"
      : tone === "rose"
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
            <div className="mt-1 font-display text-3xl font-semibold text-navy-900">
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

function DetailStat({
  label,
  value,
  hint,
  highlight,
  tone,
}: {
  label: string;
  value: number;
  hint?: string;
  highlight?: boolean;
  tone?: "rose";
}) {
  const color =
    tone === "rose"
      ? "text-rose-700"
      : highlight
      ? "text-signal-700"
      : "text-navy-900";
  return (
    <div>
      <div className="text-[10px] uppercase tracking-wider text-slate-500">
        {label}
      </div>
      <div className={"font-display text-xl font-semibold mt-0.5 " + color}>
        {value}
      </div>
      {hint && <div className="text-xs text-slate-500 mt-0.5">{hint}</div>}
    </div>
  );
}
