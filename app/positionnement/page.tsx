import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ProgressBar } from "@/components/ui/progress";
import { PlacementWizard } from "./placement-wizard";
import { Target, Sparkles, ArrowRight, RefreshCw, Trophy } from "lucide-react";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

// ── Types des lignes lues (dérivés des `select` ci-dessous) ────────────
type PlacementResultRow = Tables<"placement_results">;
type BlocRow = Pick<Tables<"blocs">, "id" | "code" | "title" | "description">;
type EnrollmentRow = Pick<
  Tables<"enrollments">,
  "formation_id" | "formation_slug" | "status"
>;
type FormationRow = Pick<Tables<"formations">, "title" | "code">;
/**
 * `placement_questions.choices` est un `jsonb` (`Json`) en base, mais son
 * contenu est toujours un tableau de libellés — contrat attendu par
 * <PlacementWizard />.
 */
type PlacementQuestionRow = Pick<
  Tables<"placement_questions">,
  "id" | "bloc_id" | "prompt" | "order"
> & {
  choices: string[];
  blocs: Pick<Tables<"blocs">, "code" | "title"> | null;
};

function levelLabel(level?: string) {
  return level === "avance"
    ? "Avancé"
    : level === "intermediaire"
    ? "Intermédiaire"
    : "Débutant";
}
function levelTone(level?: string): "success" | "gold" | "navy" {
  return level === "avance" ? "success" : level === "intermediaire" ? "gold" : "navy";
}

export default async function PositionnementPage({
  searchParams,
}: {
  searchParams?: { retake?: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const retake = searchParams?.retake === "1";

  const [{ data: resultData }, { data: blocsData }] = await Promise.all([
    supabase.from("placement_results").select("*").eq("user_id", user.id).maybeSingle(),
    supabase.from("blocs").select("id, code, title, description").order("order"),
  ]);
  const result = resultData as PlacementResultRow | null;
  const blocs = blocsData as BlocRow[] | null;

  // Si déjà passé et pas en mode retake → page résultat
  if (result && !retake) {
    const recommended = blocs?.find((b) => b.id === result.recommended_bloc_id);
    return (
      <div className="max-w-4xl mx-auto space-y-8">
        <header>
          <div className="flex items-center gap-2">
            <Trophy className="h-4 w-4 text-gold-700" />
            <span className="eyebrow text-gold-700">Votre positionnement</span>
          </div>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Profil de compétences
          </h1>
          <p className="mt-2 text-slate-600 text-sm">
            Passé le {new Date(result.taken_at).toLocaleDateString("fr-FR")}
          </p>
        </header>

        <Card variant="gold">
          <CardBody>
            <div className="flex items-center gap-2">
              <Target className="h-4 w-4 text-gold-700" />
              <span className="eyebrow text-gold-800">Recommandation</span>
            </div>
            <h2 className="mt-2 font-display text-xl font-semibold text-navy-900">
              {recommended
                ? `Commencez par ${recommended.code} — ${recommended.title}`
                : "Aucune recommandation particulière"}
            </h2>
            {recommended?.description && (
              <p className="mt-2 text-sm text-slate-700">{recommended.description}</p>
            )}
            <div className="mt-4 flex flex-wrap gap-2">
              <Link href="/modules">
                <Button variant="gold" size="md">
                  Voir les modules <ArrowRight className="h-3.5 w-3.5" />
                </Button>
              </Link>
              <Link href="/positionnement?retake=1">
                <Button variant="secondary" size="md">
                  <RefreshCw className="h-3.5 w-3.5" /> Repasser le test
                </Button>
              </Link>
            </div>
          </CardBody>
        </Card>

        <section className="grid md:grid-cols-3 gap-4">
          {blocs?.map((b) => {
            // `scores` / `level_per_bloc` : jsonb indexés par code de bloc.
            const pct = (result.scores as Record<string, number> | null)?.[b.code] ?? 0;
            const lvl =
              (result.level_per_bloc as Record<string, string> | null)?.[b.code] ??
              "debutant";
            return (
              <Card key={b.id}>
                <CardBody>
                  <div className="flex items-center justify-between">
                    <Badge tone="navy" size="sm">{b.code}</Badge>
                    <Badge tone={levelTone(lvl)} size="sm">{levelLabel(lvl)}</Badge>
                  </div>
                  <h3 className="mt-3 font-display text-base font-semibold text-navy-900 leading-snug">
                    {b.title}
                  </h3>
                  <div className="mt-4">
                    <ProgressBar value={pct} variant="gradient" />
                    <div className="mt-1 text-xs text-slate-500 flex justify-between">
                      <span>{pct}%</span>
                      <span>bonnes réponses</span>
                    </div>
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </section>
      </div>
    );
  }

  // Sinon : wizard — on filtre les questions par la formation du stagiaire.
  // Source de vérité : son inscription (enrollments). On prend la plus
  // récente (active de préférence) pour gérer les multi-inscriptions.
  const { data: enrollmentData } = await supabase
    .from("enrollments")
    .select("formation_id, formation_slug, status")
    .eq("user_id", user.id)
    .not("formation_id", "is", null)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  const enrollment = enrollmentData as EnrollmentRow | null;

  // `.not("formation_id", "is", null)` garantit une valeur non nulle.
  const formationId = enrollment?.formation_id as string | undefined;

  let questions: PlacementQuestionRow[] | null = null;
  if (formationId) {
    const { data } = await supabase
      .from("placement_questions")
      .select("id, bloc_id, prompt, choices, order, blocs(code, title)")
      .eq("active", true)
      .eq("formation_id", formationId)
      .order("bloc_id")
      .order("order");
    questions = data as PlacementQuestionRow[] | null;
  }

  // Récupère le titre de la formation pour personnaliser le hero
  const { data: formationData } = formationId
    ? await supabase
        .from("formations")
        .select("title, code")
        .eq("id", formationId)
        .maybeSingle()
    : { data: null };
  const formation = formationData as FormationRow | null;

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <header>
        <div className="flex items-center gap-2">
          <Sparkles className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Avant de démarrer</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Test de positionnement
          {formation?.code && (
            <span className="ml-2 text-base font-normal text-slate-500">
              · {formation.code}
            </span>
          )}
        </h1>
        <p className="mt-2 text-slate-600 text-sm">
          Quelques questions
          {formation?.title ? ` sur « ${formation.title} »` : ""} pour adapter
          votre parcours. Aucun impact sur votre certification — c'est juste
          pour nous aider à vous orienter.
        </p>
      </header>

      {!formationId ? (
        <Card>
          <CardBody className="py-10 text-center space-y-3">
            <p className="text-slate-700 text-sm">
              Aucune formation active n'est associée à votre compte.
            </p>
            <p className="text-slate-500 text-xs">
              Contactez votre référent pédagogique pour finaliser votre
              inscription, puis revenez passer le test.
            </p>
            <Link href="/dashboard" className="inline-block mt-2">
              <Button size="md">Retour au tableau de bord</Button>
            </Link>
          </CardBody>
        </Card>
      ) : !questions || questions.length === 0 ? (
        <Card>
          <CardBody className="py-10 text-center">
            <p className="text-slate-600 text-sm">
              Aucune question de positionnement n'est configurée pour cette
              formation pour l'instant.
            </p>
            <Link href="/dashboard" className="inline-block mt-4">
              <Button size="md">Retour au tableau de bord</Button>
            </Link>
          </CardBody>
        </Card>
      ) : (
        <PlacementWizard questions={questions} />
      )}
    </div>
  );
}
