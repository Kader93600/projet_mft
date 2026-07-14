import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { ArrowLeft, Shuffle, ClipboardList } from "lucide-react";
import { FORMATIONS } from "@/lib/formations-config";
import { RandomQuizForm } from "./random-form";
import { StaticQuizForm } from "./static-form";

export const dynamic = "force-dynamic";

export default async function CreerQuizPage(
  props: {
    searchParams?: Promise<{ mode?: string; f?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const mode = searchParams?.mode === "static" ? "static" : "random";
  const supabase = await createClient();

  // Stats par formation pour aider au paramétrage
  const formationStats = await Promise.all(
    FORMATIONS.map(async (f) => {
      const { data: dbF } = await supabase
        .from("formations")
        .select("id")
        .eq("slug", f.slug)
        .single();
      if (!dbF) return { ...f, qcm: 0, qr: 0 };
      const [{ count: qcm }, { count: qr }] = await Promise.all([
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", dbF.id)
          .eq("type", "qcm")
          .eq("active", true),
        supabase
          .from("question_bank")
          .select("*", { count: "exact", head: true })
          .eq("formation_id", dbF.id)
          .eq("type", "qr")
          .eq("active", true),
      ]);
      return { ...f, qcm: qcm ?? 0, qr: qr ?? 0 };
    })
  );

  return (
    <div className="space-y-8">
      <Link
        href="/admin/banque-questions"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Banque de questions
      </Link>

      <header>
        <h1 className="font-display text-3xl font-semibold text-navy-950">
          Créer un quiz / examen
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Composez un quiz ou un examen blanc à partir de la banque de
          questions. Deux modes : tirage aléatoire (recommandé pour
          entraînement) ou sélection manuelle (recommandé pour examen blanc
          fixe).
        </p>
      </header>

      {/* Switcher de mode */}
      <div className="grid md:grid-cols-2 gap-4">
        <Link
          href="/admin/banque-questions/creer-quiz?mode=random"
          className={
            "rounded-2xl border p-5 transition " +
            (mode === "random"
              ? "border-signal-500 bg-signal-500/5 shadow-soft"
              : "border-navy-100 bg-white hover:border-navy-300")
          }
        >
          <div className="flex items-start gap-3">
            <div className="h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-700 flex items-center justify-center shrink-0">
              <Shuffle className="h-5 w-5" />
            </div>
            <div>
              <CardTitle>Mode aléatoire</CardTitle>
              <p className="text-sm text-slate-600 mt-1">
                Configure des filtres (formation, difficulté, modules) et
                fixe le nombre de QCM/QR. À chaque tentative, une sélection
                aléatoire est tirée. Idéal pour les <strong>entraînements
                illimités</strong>.
              </p>
            </div>
          </div>
        </Link>

        <Link
          href="/admin/banque-questions/creer-quiz?mode=static"
          className={
            "rounded-2xl border p-5 transition " +
            (mode === "static"
              ? "border-brand-500 bg-brand-50 shadow-soft"
              : "border-navy-100 bg-white hover:border-navy-300")
          }
        >
          <div className="flex items-start gap-3">
            <div className="h-10 w-10 rounded-xl bg-brand-50 border border-brand-200 text-brand-700 flex items-center justify-center shrink-0">
              <ClipboardList className="h-5 w-5" />
            </div>
            <div>
              <CardTitle>Mode sélection manuelle</CardTitle>
              <p className="text-sm text-slate-600 mt-1">
                Choisis précisément les questions à inclure dans le quiz.
                Idéal pour un <strong>examen blanc officiel</strong> à composition
                fixe et contrôlée.
              </p>
            </div>
          </div>
        </Link>
      </div>

      {/* Formulaire actif */}
      <Card>
        <CardBody>
          {mode === "random" ? (
            <RandomQuizForm formationStats={formationStats} initialFormation={searchParams?.f} />
          ) : (
            <StaticQuizForm initialFormation={searchParams?.f} />
          )}
        </CardBody>
      </Card>
    </div>
  );
}
