import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Users, Award, ArrowRight, Sparkles } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AffectationsIndexPage() {
  const supabase = createClient();

  const [
    { count: totalEnrollments },
    { count: totalHabilitations },
    { count: totalStudents },
    { count: totalTrainers },
  ] = await Promise.all([
    supabase
      .from("enrollments")
      .select("*", { count: "exact", head: true })
      .not("formation_slug", "is", null),
    supabase
      .from("trainer_formations")
      .select("*", { count: "exact", head: true }),
    supabase
      .from("profiles")
      .select("*", { count: "exact", head: true })
      .eq("role", "student"),
    supabase
      .from("profiles")
      .select("*", { count: "exact", head: true })
      .eq("role", "trainer"),
  ]);

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-signal-700">Affectations</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Affectations & habilitations
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Inscrire les stagiaires aux formations, habiliter les formateurs sur
          les formations qu'ils peuvent encadrer.
        </p>
      </header>

      <div className="grid md:grid-cols-2 gap-6">
        <Link
          href="/admin/affectations/stagiaires"
          className="group relative overflow-hidden rounded-2xl border border-navy-100 bg-white p-8 hover:border-signal-500/40 hover:shadow-soft transition"
        >
          <div
            aria-hidden="true"
            className="absolute -top-12 -right-12 h-40 w-40 rounded-full bg-signal-500/10 blur-3xl group-hover:bg-signal-500/20 transition"
          />
          <div className="relative">
            <div className="h-12 w-12 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-700 flex items-center justify-center">
              <Users className="h-6 w-6" />
            </div>
            <CardTitle className="mt-4 text-xl">
              Affecter les stagiaires
            </CardTitle>
            <p className="mt-2 text-sm text-slate-600">
              Inscrire un stagiaire à une formation, suivre les inscriptions
              actives, gérer le pipeline.
            </p>
            <div className="mt-5 flex items-center gap-4 text-xs text-slate-500">
              <span>
                <strong className="text-navy-900 text-lg block">
                  {totalEnrollments ?? 0}
                </strong>
                inscriptions actives
              </span>
              <span>
                <strong className="text-navy-900 text-lg block">
                  {totalStudents ?? 0}
                </strong>
                stagiaires
              </span>
            </div>
            <span className="mt-5 inline-flex items-center gap-1.5 text-sm font-medium text-signal-700 group-hover:gap-3 transition-all">
              Ouvrir <ArrowRight className="h-3.5 w-3.5" />
            </span>
          </div>
        </Link>

        <Link
          href="/admin/affectations/formateurs"
          className="group relative overflow-hidden rounded-2xl border border-navy-100 bg-white p-8 hover:border-brand-300 hover:shadow-soft transition"
        >
          <div
            aria-hidden="true"
            className="absolute -top-12 -right-12 h-40 w-40 rounded-full bg-brand-500/10 blur-3xl group-hover:bg-brand-500/20 transition"
          />
          <div className="relative">
            <div className="h-12 w-12 rounded-xl bg-brand-50 border border-brand-200 text-brand-700 flex items-center justify-center">
              <Award className="h-6 w-6" />
            </div>
            <CardTitle className="mt-4 text-xl">
              Habiliter les formateurs
            </CardTitle>
            <p className="mt-2 text-sm text-slate-600">
              Affecter un formateur à une formation, gérer ses capacités
              (notation, édition, lead).
            </p>
            <div className="mt-5 flex items-center gap-4 text-xs text-slate-500">
              <span>
                <strong className="text-navy-900 text-lg block">
                  {totalHabilitations ?? 0}
                </strong>
                habilitations
              </span>
              <span>
                <strong className="text-navy-900 text-lg block">
                  {totalTrainers ?? 0}
                </strong>
                formateurs
              </span>
            </div>
            <span className="mt-5 inline-flex items-center gap-1.5 text-sm font-medium text-brand-700 group-hover:gap-3 transition-all">
              Ouvrir <ArrowRight className="h-3.5 w-3.5" />
            </span>
          </div>
        </Link>
      </div>

      <Card>
        <CardBody className="flex items-start gap-3">
          <div className="h-10 w-10 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center shrink-0">
            <Sparkles className="h-5 w-5" />
          </div>
          <div className="text-sm text-slate-700 leading-relaxed">
            <CardTitle className="text-base">
              Différence entre affectation et habilitation
            </CardTitle>
            <p className="mt-1">
              <strong>Stagiaire → formation</strong> : le stagiaire est
              inscrit (ligne dans <code className="text-xs">enrollments</code>).
              C'est ce qui débloque l'accès aux modules et quiz de la formation.
            </p>
            <p className="mt-1">
              <strong>Formateur → formation</strong> : le formateur est
              habilité à enseigner cette formation (ligne dans{" "}
              <code className="text-xs">trainer_formations</code>). C'est ce qui
              lui donne accès au pilotage de la cohorte.
            </p>
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
