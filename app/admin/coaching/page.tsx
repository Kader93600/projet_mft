import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  CalendarDays,
  AlertTriangle,
  UserCheck,
  ArrowRight,
  Clock,
} from "lucide-react";

export const dynamic = "force-dynamic";

const RISK_LABEL: Record<string, { label: string; tone: "rose" | "gold" | "slate" }> = {
  jamais_actif: { label: "Jamais actif", tone: "rose" },
  inactif_14j: { label: "Inactif > 14 j", tone: "gold" },
  score_faible: { label: "Score < 50 %", tone: "gold" },
};

export default async function AdminCoachingPage() {
  const supabase = createClient();

  const [
    { data: upcoming },
    { data: atRisk },
    { data: trainers },
    { data: unassigned },
  ] = await Promise.all([
    supabase
      .from("coaching_sessions")
      .select(
        "id, scheduled_at, duration_min, mode, status, user:profiles!coaching_sessions_user_id_fkey(id, full_name, email), trainer:profiles!coaching_sessions_trainer_id_fkey(full_name, email)"
      )
      .gte("scheduled_at", new Date().toISOString())
      .eq("status", "prevue")
      .order("scheduled_at")
      .limit(20),
    supabase
      .from("at_risk_students")
      .select("*")
      .not("risk_flag", "is", null)
      .order("last_attempt_at", { ascending: true, nullsFirst: true })
      .limit(30),
    // Référents pédagogiques éligibles : admin + super_admin
    supabase
      .from("profiles")
      .select("id, full_name, email, role")
      .in("role", ["admin", "super_admin"])
      .eq("disabled", false)
      .order("full_name"),
    supabase
      .from("profiles")
      .select("id, full_name, email")
      .eq("role", "student")
      .eq("disabled", false)
      .is("referent_id", null)
      .order("full_name")
      .limit(30),
  ]);

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Suivi pédagogique</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Accompagnement des stagiaires
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Vue d'ensemble des rendez-vous à venir, des stagiaires à risque, et
          des attributions de référents.
        </p>
      </header>

      {/* Sessions à venir */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <CalendarDays className="h-4 w-4 text-navy-700" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Prochains rendez-vous
          </h2>
          <Badge tone="slate" size="sm">
            {upcoming?.length ?? 0}
          </Badge>
        </div>
        {(!upcoming || upcoming.length === 0) ? (
          <Card>
            <CardBody className="py-8 text-center text-sm text-slate-500">
              Aucun rendez-vous programmé.
            </CardBody>
          </Card>
        ) : (
          <div className="grid md:grid-cols-2 gap-3">
            {upcoming.map((s: any) => (
              <Card key={s.id}>
                <CardBody className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="text-xs text-slate-500 uppercase tracking-wider">
                      {new Date(s.scheduled_at).toLocaleDateString("fr-FR", {
                        weekday: "short",
                        day: "2-digit",
                        month: "short",
                      })}{" "}
                      · {new Date(s.scheduled_at).toLocaleTimeString("fr-FR", {
                        hour: "2-digit",
                        minute: "2-digit",
                      })}{" "}
                      · {s.duration_min} min
                    </div>
                    <div className="font-display font-semibold text-navy-900 mt-1">
                      {s.user?.full_name ?? s.user?.email}
                    </div>
                    <div className="text-xs text-slate-600 mt-0.5">
                      Avec {s.trainer?.full_name ?? s.trainer?.email}
                    </div>
                  </div>
                  <Badge
                    tone={s.mode === "visio" ? "navy" : "slate"}
                    size="sm"
                  >
                    {s.mode}
                  </Badge>
                </CardBody>
              </Card>
            ))}
          </div>
        )}
      </section>

      {/* Stagiaires à risque */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <AlertTriangle className="h-4 w-4 text-rose-600" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Stagiaires à risque
          </h2>
          <Badge tone="slate" size="sm">
            {atRisk?.length ?? 0}
          </Badge>
        </div>
        {(!atRisk || atRisk.length === 0) ? (
          <Card>
            <CardBody className="py-8 text-center text-sm text-slate-500">
              Aucun stagiaire en alerte.
            </CardBody>
          </Card>
        ) : (
          <Card>
            <CardBody className="p-0">
              <table className="w-full text-sm">
                <thead className="bg-navy-50/50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-4 py-2">Stagiaire</th>
                    <th className="text-left px-4 py-2">Alerte</th>
                    <th className="text-left px-4 py-2">Dernière activité</th>
                    <th className="text-left px-4 py-2">Score moyen</th>
                    <th className="px-4 py-2" />
                  </tr>
                </thead>
                <tbody>
                  {atRisk.map((r: any) => {
                    const risk = RISK_LABEL[r.risk_flag];
                    const last =
                      r.last_attempt_at || r.last_lesson_at
                        ? new Date(
                            Math.max(
                              r.last_attempt_at ? +new Date(r.last_attempt_at) : 0,
                              r.last_lesson_at ? +new Date(r.last_lesson_at) : 0
                            )
                          )
                        : null;
                    return (
                      <tr key={r.id} className="border-t border-navy-100">
                        <td className="px-4 py-2.5">
                          <div className="font-medium text-navy-900">
                            {r.full_name || r.email}
                          </div>
                          <div className="text-[11px] text-slate-500">
                            {r.email}
                          </div>
                        </td>
                        <td className="px-4 py-2.5">
                          {risk && (
                            <Badge tone={risk.tone} size="sm">
                              {risk.label}
                            </Badge>
                          )}
                        </td>
                        <td className="px-4 py-2.5 text-slate-700">
                          {last
                            ? last.toLocaleDateString("fr-FR", {
                                day: "2-digit",
                                month: "short",
                                year: "numeric",
                              })
                            : "—"}
                        </td>
                        <td className="px-4 py-2.5 text-slate-700">
                          {r.avg_score != null ? `${r.avg_score}%` : "—"}
                        </td>
                        <td className="px-4 py-2.5 text-right">
                          <Link
                            href={`/admin/users/${r.id}`}
                            className="text-xs font-medium text-navy-700 hover:text-gold-700 inline-flex items-center gap-1"
                          >
                            Fiche <ArrowRight className="h-3 w-3" />
                          </Link>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </CardBody>
          </Card>
        )}
      </section>

      {/* Sans référent */}
      {unassigned && unassigned.length > 0 && (
        <section>
          <div className="flex items-center gap-2 mb-4">
            <UserCheck className="h-4 w-4 text-gold-600" />
            <h2 className="font-display text-xl font-semibold text-navy-900">
              Stagiaires sans référent
            </h2>
            <Badge tone="slate" size="sm">
              {unassigned.length}
            </Badge>
          </div>
          <Card>
            <CardBody>
              <ul className="divide-y divide-navy-100">
                {unassigned.map((u: any) => (
                  <li key={u.id} className="py-2.5 flex items-center justify-between">
                    <div>
                      <div className="text-sm font-medium text-navy-900">
                        {u.full_name || u.email}
                      </div>
                      <div className="text-[11px] text-slate-500">{u.email}</div>
                    </div>
                    <Link
                      href={`/admin/users/${u.id}#coaching`}
                      className="text-xs font-medium text-navy-700 hover:text-gold-700 inline-flex items-center gap-1"
                    >
                      Assigner <ArrowRight className="h-3 w-3" />
                    </Link>
                  </li>
                ))}
              </ul>
            </CardBody>
          </Card>
        </section>
      )}

      {/* Équipe formateurs (info) */}
      <section>
        <div className="flex items-center gap-2 mb-4">
          <Clock className="h-4 w-4 text-slate-600" />
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Formateurs disponibles
          </h2>
        </div>
        <div className="flex flex-wrap gap-2">
          {(trainers || []).map((t: any) => (
            <div
              key={t.id}
              className="rounded-xl border border-navy-100 bg-white px-3 py-2 text-xs"
            >
              <div className="font-medium text-navy-900">
                {t.full_name || t.email}
              </div>
              <div className="text-slate-500">{t.email}</div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
