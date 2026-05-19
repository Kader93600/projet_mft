import { createClient } from "@/lib/supabase/server";
import { CoachingPanel } from "./coaching-panel";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { formatDate, initials, scoreColor } from "@/lib/utils";
import {
  ArrowLeft,
  Mail,
  Phone,
  Calendar,
  Clock,
  TrendingUp,
  Award,
  BookOpen,
  Activity,
  UserX,
  UserCheck,
  Download,
  FileSignature,
  CheckCircle2,
  AlertCircle,
} from "lucide-react";
import Link from "next/link";
import { notFound } from "next/navigation";
import { UserProfileActions } from "./user-profile-actions";
import { UserEditForm } from "./user-edit-form";

export const dynamic = "force-dynamic";

export default async function UserProfilePage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();

  const [{ data: user }, { data: groups }] = await Promise.all([
    supabase.from("profiles").select("*").eq("id", params.id).single(),
    supabase.from("groups").select("id, name, color"),
  ]);

  if (!user) notFound();

  const [
    { data: attempts },
    { data: progress },
    { data: group },
    { data: publishedDocs },
    { data: acceptances },
    { data: placement },
    { data: blocsForPlacement },
  ] = await Promise.all([
    supabase
      .from("quiz_attempts")
      .select("*, quizzes(title, type)")
      .eq("user_id", params.id)
      .order("started_at", { ascending: false })
      .limit(25),
    supabase
      .from("lesson_progress")
      .select("*, lessons(title, modules(title))")
      .eq("user_id", params.id)
      .eq("completed", true),
    user.group_id
      ? supabase.from("groups").select("*").eq("id", user.group_id).single()
      : Promise.resolve({ data: null }),
    supabase
      .from("onboarding_documents")
      .select("id, type, title, version")
      .eq("published", true)
      .order("type"),
    supabase
      .from("document_acceptances")
      .select(
        "document_id, document_type, document_version, accepted_at, ip_address, user_agent"
      )
      .eq("user_id", params.id),
    supabase
      .from("placement_results")
      .select("scores, level_per_bloc, recommended_bloc_id, taken_at, duration_s")
      .eq("user_id", params.id)
      .maybeSingle(),
    supabase.from("blocs").select("id, code, title").order("order"),
  ]);

  // Coaching (Point #10)
  const [
    { data: trainers },
    { data: coachingSessions },
    { data: coachingNotes },
    { data: { user: authMe } },
  ] = await Promise.all([
    // Référents pédagogiques éligibles : admin + super_admin
    // (les trainers ont leur propre tag "Formateur assigné" plus bas,
    // ce champ-ci est réservé au suivi RH par un admin).
    supabase
      .from("profiles")
      .select("id, full_name, email, role")
      .in("role", ["admin", "super_admin"])
      .eq("disabled", false)
      .order("full_name"),
    supabase
      .from("coaching_sessions")
      .select("*")
      .eq("user_id", params.id)
      .order("scheduled_at", { ascending: false })
      .limit(30),
    supabase
      .from("coaching_notes")
      .select("*")
      .eq("user_id", params.id)
      .order("pinned", { ascending: false })
      .order("created_at", { ascending: false })
      .limit(50),
    supabase.auth.getUser(),
  ]);

  const acceptedMap = new Map(
    (acceptances ?? []).map((a: any) => [a.document_id, a])
  );
  const docLabels: Record<string, string> = {
    convention: "Convention de formation",
    reglement: "Règlement intérieur",
    livret: "Livret d'accueil",
  };

  const attemptsList = (attempts ?? []) as any[];
  const total = attemptsList.length;
  const avg =
    total > 0
      ? Math.round(
          attemptsList.reduce((s, a) => s + (a.percentage || 0), 0) / total
        )
      : 0;
  const passed = attemptsList.filter((a) => a.passed).length;
  const successRate = total > 0 ? Math.round((passed / total) * 100) : 0;

  return (
    <div className="space-y-6">
      {/* Top bar */}
      <div className="flex items-center justify-between">
        <Link
          href="/admin/users"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Retour aux utilisateurs
        </Link>
        <div className="flex items-center gap-2">
          <a href={`mailto:${user.email}`}>
            <Button variant="secondary" size="sm">
              <Mail className="h-4 w-4" /> Contacter
            </Button>
          </a>
          <a href={`/admin/analytics/export/pdf?user=${user.id}`} target="_blank">
            <Button variant="gold" size="sm">
              <Download className="h-4 w-4" /> Rapport PDF
            </Button>
          </a>
        </div>
      </div>

      {/* Hero card */}
      <Card variant="solid-navy" className="overflow-hidden relative">
        <div className="absolute inset-0 bg-mesh-navy opacity-60 pointer-events-none" />
        <CardBody className="relative flex flex-col md:flex-row items-start md:items-center gap-5">
          <div className="h-20 w-20 rounded-2xl bg-gold-500 text-navy-900 flex items-center justify-center font-display text-2xl font-semibold">
            {initials(user.full_name || user.email)}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <h2 className="font-display text-2xl font-semibold tracking-tight">
                {user.full_name || "Sans nom"}
              </h2>
              {user.role === "admin" && <Badge tone="gold">Admin</Badge>}
              {user.disabled && <Badge tone="slate">Désactivé</Badge>}
              {group && <Badge tone="navy">{group.name}</Badge>}
            </div>
            <p className="mt-1 text-white/70 text-sm">{user.email}</p>
            <div className="mt-3 flex items-center gap-5 text-xs text-white/60">
              <span className="inline-flex items-center gap-1.5">
                <Calendar className="h-3.5 w-3.5" /> Inscrit le {formatDate(user.created_at)}
              </span>
              {user.last_sign_in_at && (
                <span className="inline-flex items-center gap-1.5">
                  <Clock className="h-3.5 w-3.5" /> Vue le {formatDate(user.last_sign_in_at)}
                </span>
              )}
              {user.phone && (
                <span className="inline-flex items-center gap-1.5">
                  <Phone className="h-3.5 w-3.5" /> {user.phone}
                </span>
              )}
            </div>
          </div>
          <UserProfileActions
            userId={user.id}
            disabled={user.disabled}
            email={user.email}
          />
        </CardBody>
      </Card>

      {/* Onboarding & documents */}
      {user.role === "student" && (
        <Card>
          <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <FileSignature className="h-4 w-4 text-slate-500" />
              <CardTitle className="text-base">
                Onboarding & documents d'entrée
              </CardTitle>
            </div>
            {user.onboarding_completed_at ? (
              <Badge tone="success" size="sm">
                <CheckCircle2 className="h-3 w-3" /> Complété le{" "}
                {formatDate(user.onboarding_completed_at)}
              </Badge>
            ) : (
              <Badge tone="slate" size="sm">
                <AlertCircle className="h-3 w-3" /> En attente
              </Badge>
            )}
          </div>
          <CardBody>
            {(publishedDocs ?? []).length === 0 ? (
              <p className="text-sm text-slate-500 py-3">
                Aucun document publié pour le moment.{" "}
                <Link
                  href="/admin/settings/documents"
                  className="text-navy-900 underline hover:text-gold-700"
                >
                  Configurer les documents
                </Link>
                .
              </p>
            ) : (
              <div className="grid sm:grid-cols-3 gap-3">
                {(publishedDocs ?? []).map((d: any) => {
                  const a = acceptedMap.get(d.id) as any;
                  return (
                    <div
                      key={d.id}
                      className={
                        "rounded-xl border p-3 " +
                        (a
                          ? "bg-emerald-50/40 border-emerald-200"
                          : "bg-slate-50 border-navy-100")
                      }
                    >
                      <div className="flex items-start justify-between gap-2">
                        <div className="text-sm font-semibold text-navy-900">
                          {docLabels[d.type] ?? d.title}
                        </div>
                        {a ? (
                          <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
                        ) : (
                          <AlertCircle className="h-4 w-4 text-slate-400 shrink-0" />
                        )}
                      </div>
                      <div className="text-[11px] text-slate-500 mt-1">
                        Publié en version {d.version}
                      </div>
                      {a ? (
                        <div className="mt-2 text-xs text-emerald-800">
                          Signé le{" "}
                          <span className="font-semibold">
                            {new Date(a.accepted_at).toLocaleString("fr-FR", {
                              day: "2-digit",
                              month: "short",
                              year: "numeric",
                              hour: "2-digit",
                              minute: "2-digit",
                            })}
                          </span>
                          {a.document_version !== d.version && (
                            <span className="ml-1 text-amber-700 font-medium">
                              (v{a.document_version})
                            </span>
                          )}
                        </div>
                      ) : (
                        <div className="mt-2 text-xs text-slate-500">
                          Non signé
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </CardBody>
        </Card>
      )}

      {/* Positionnement initial */}
      {user.role === "student" && (
        <Card>
          <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Award className="h-4 w-4 text-slate-500" />
              <CardTitle className="text-base">Positionnement initial</CardTitle>
            </div>
            {placement ? (
              <Badge tone="success" size="sm">
                <CheckCircle2 className="h-3 w-3" /> Passé le {formatDate(placement.taken_at)}
              </Badge>
            ) : (
              <Badge tone="slate" size="sm">
                <AlertCircle className="h-3 w-3" /> Non passé
              </Badge>
            )}
          </div>
          <CardBody>
            {placement ? (
              <div className="grid sm:grid-cols-3 gap-3">
                {(blocsForPlacement ?? []).map((b: any) => {
                  const pct = (placement.scores as any)?.[b.code] ?? 0;
                  const lvl = (placement.level_per_bloc as any)?.[b.code] ?? "debutant";
                  const recommended = placement.recommended_bloc_id === b.id;
                  return (
                    <div
                      key={b.id}
                      className={
                        "rounded-xl border p-3 " +
                        (recommended
                          ? "bg-gold-50 border-gold-200"
                          : "bg-white border-navy-100")
                      }
                    >
                      <div className="flex items-center justify-between">
                        <Badge tone="navy" size="sm">{b.code}</Badge>
                        <span className={`font-display font-semibold ${scoreColor(pct)}`}>
                          {pct}%
                        </span>
                      </div>
                      <div className="mt-1 text-xs text-slate-600">{b.title}</div>
                      <div className="mt-1 text-[10px] font-medium text-slate-500 uppercase tracking-wide">
                        {lvl === "avance" ? "Avancé" : lvl === "intermediaire" ? "Intermédiaire" : "Débutant"}
                        {recommended && " · recommandé en priorité"}
                      </div>
                    </div>
                  );
                })}
              </div>
            ) : (
              <p className="text-sm text-slate-500 py-3">
                Le stagiaire n'a pas encore passé le test de positionnement.
              </p>
            )}
          </CardBody>
        </Card>
      )}

      {/* KPIs */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-navy-50 flex items-center justify-center">
                <Award className="h-5 w-5 text-navy-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Tentatives</div>
                <div className="font-display text-xl font-semibold text-navy-900">
                  {total}
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-emerald-50 flex items-center justify-center">
                <TrendingUp className="h-5 w-5 text-emerald-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Score moyen</div>
                <div
                  className={`font-display text-xl font-semibold ${scoreColor(avg)}`}
                >
                  {avg}%
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-gold-50 flex items-center justify-center">
                <Activity className="h-5 w-5 text-gold-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Taux de réussite</div>
                <div className="font-display text-xl font-semibold text-navy-900">
                  {successRate}%
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody>
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-violet-50 flex items-center justify-center">
                <BookOpen className="h-5 w-5 text-violet-700" />
              </div>
              <div>
                <div className="text-xs text-slate-500">Leçons terminées</div>
                <div className="font-display text-xl font-semibold text-navy-900">
                  {progress?.length ?? 0}
                </div>
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Deux colonnes */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Informations */}
        <div className="lg:col-span-1">
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <CardTitle className="text-base">Informations</CardTitle>
            </div>
            <CardBody>
              <UserEditForm user={user} groups={groups ?? []} />
            </CardBody>
          </Card>
        </div>

        {/* Tentatives récentes */}
        <div className="lg:col-span-2">
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <CardTitle className="text-base">
                Résultats de quiz ({total})
              </CardTitle>
            </div>
            {total === 0 ? (
              <CardBody className="py-12 text-center text-sm text-slate-400">
                Ce stagiaire n'a effectué aucun quiz.
              </CardBody>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                      <th className="text-left px-5 py-3 font-semibold">Exercice</th>
                      <th className="text-left px-5 py-3 font-semibold">Type</th>
                      <th className="text-left px-5 py-3 font-semibold">Score</th>
                      <th className="text-left px-5 py-3 font-semibold">Résultat</th>
                      <th className="text-left px-5 py-3 font-semibold">Date</th>
                      <th className="px-5 py-3" />
                    </tr>
                  </thead>
                  <tbody>
                    {attemptsList.map((a: any) => (
                      <tr key={a.id} className="border-t border-navy-50">
                        <td className="px-5 py-3 font-medium text-navy-900">
                          {a.quizzes?.title ?? "—"}
                        </td>
                        <td className="px-5 py-3">
                          <Badge tone={a.quizzes?.type === "examen" ? "gold" : "navy"}>
                            {a.quizzes?.type ?? "—"}
                          </Badge>
                        </td>
                        <td className="px-5 py-3">
                          <span
                            className={`font-semibold ${scoreColor(a.percentage)}`}
                          >
                            {a.percentage}%
                          </span>
                          <span className="text-xs text-slate-500 ml-1">
                            ({a.score}/{a.total})
                          </span>
                        </td>
                        <td className="px-5 py-3">
                          <Badge tone={a.passed ? "success" : "slate"}>
                            {a.passed ? "Réussi" : "Échoué"}
                          </Badge>
                        </td>
                        <td className="px-5 py-3 text-slate-500 text-xs">
                          {formatDate(a.started_at)}
                        </td>
                        <td className="px-5 py-3 text-right">
                          <a
                            href={`/admin/analytics/export/pdf?attempt=${a.id}`}
                            target="_blank"
                            title="Télécharger la copie corrigée"
                            className="inline-flex items-center gap-1 text-xs text-navy-700 hover:text-gold-700"
                          >
                            <Download className="h-3.5 w-3.5" /> Copie
                          </a>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>

          {/* Progression */}
          {progress && progress.length > 0 && (
            <Card className="mt-5">
              <div className="px-6 pt-5 pb-3 border-b border-navy-50">
                <CardTitle className="text-base">Leçons terminées</CardTitle>
              </div>
              <div className="divide-y divide-navy-50">
                {progress.slice(0, 10).map((p: any) => (
                  <div key={p.id} className="px-6 py-3 flex items-center gap-3">
                    <div className="h-8 w-8 rounded-lg bg-emerald-50 flex items-center justify-center">
                      <BookOpen className="h-4 w-4 text-emerald-700" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-medium text-sm text-navy-900 truncate">
                        {p.lessons?.title ?? "—"}
                      </div>
                      <div className="text-xs text-slate-500 truncate">
                        {p.lessons?.modules?.title ?? ""}
                      </div>
                    </div>
                    <span className="text-xs text-slate-500">
                      {p.completed_at ? formatDate(p.completed_at) : ""}
                    </span>
                  </div>
                ))}
              </div>
            </Card>
          )}
        </div>
      </div>

      {/* Accompagnement pédagogique */}
      <CoachingPanel
        user={user}
        trainers={trainers ?? []}
        sessions={coachingSessions ?? []}
        notes={coachingNotes ?? []}
        currentAdminId={authMe?.id ?? ""}
      />
    </div>
  );
}
