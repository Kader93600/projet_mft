import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CheckCircle2, MessageSquareHeart, ThermometerSnowflake } from "lucide-react";
import { SurveyForm } from "./survey-form";

export const dynamic = "force-dynamic";

export default async function SatisfactionPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: existing } = await supabase
    .from("satisfaction_surveys")
    .select("type, submitted_at, note_globale, recommandation")
    .eq("user_id", user.id);

  const chaud = (existing ?? []).find((s: any) => s.type === "chaud");
  const froid = (existing ?? []).find((s: any) => s.type === "froid");

  // Éligibilité enquête à froid : 90 jours après la 1ère ?
  const { data: enrollment } = await supabase
    .from("enrollments")
    .select("end_date, status")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const now = Date.now();
  const finished =
    enrollment?.end_date && new Date(enrollment.end_date).getTime() < now;
  const eligibleFroid =
    finished && enrollment?.end_date
      ? Date.now() - new Date(enrollment.end_date).getTime() >=
        90 * 24 * 3600_000
      : false;

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Qualité</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Évaluations de satisfaction
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Vos retours nous permettent d'améliorer en continu nos formations et
          sont une preuve essentielle dans le cadre de la certification
          Qualiopi (indicateur 30).
        </p>
      </header>

      <section>
        <SurveyTile
          icon={MessageSquareHeart}
          type="chaud"
          title="Évaluation à chaud"
          desc="À remplir à la fin de votre formation. Aide-nous à améliorer immédiatement la pédagogie pour les promotions suivantes."
          submitted={chaud}
          eligible={!!finished}
          notEligibleMsg="Disponible dès la fin de votre formation."
        />
      </section>

      <section>
        <SurveyTile
          icon={ThermometerSnowflake}
          type="froid"
          title="Évaluation à froid (90 jours après)"
          desc="3 mois après votre formation, on vous demande votre situation pro et votre recul sur ce que vous avez appris."
          submitted={froid}
          eligible={eligibleFroid}
          notEligibleMsg="Disponible 3 mois après la fin de votre formation."
        />
      </section>
    </div>
  );
}

function SurveyTile({
  icon: Icon,
  type,
  title,
  desc,
  submitted,
  eligible,
  notEligibleMsg,
}: {
  icon: any;
  type: "chaud" | "froid";
  title: string;
  desc: string;
  submitted: any;
  eligible: boolean;
  notEligibleMsg: string;
}) {
  return (
    <Card>
      <CardBody>
        <div className="flex items-start gap-3">
          <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-900 flex items-center justify-center shrink-0">
            <Icon className="h-5 w-5" />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between flex-wrap gap-2">
              <CardTitle>{title}</CardTitle>
              {submitted ? (
                <Badge tone="success" size="sm">
                  <CheckCircle2 className="h-3 w-3" /> Soumise
                </Badge>
              ) : eligible ? (
                <Badge tone="gold" size="sm">À remplir</Badge>
              ) : (
                <Badge tone="slate" size="sm">Pas encore disponible</Badge>
              )}
            </div>
            <p className="text-sm text-slate-600 mt-1.5">{desc}</p>

            {submitted && (
              <div className="mt-4 rounded-xl bg-emerald-50 border border-emerald-200 px-4 py-3 text-sm text-emerald-900">
                Merci ! Réponse soumise le{" "}
                {new Date(submitted.submitted_at).toLocaleDateString("fr-FR")}.
                Note globale : <strong>{submitted.note_globale}/5</strong> ·
                Recommandation : <strong>{submitted.recommandation}/10</strong>.
              </div>
            )}

            {!submitted && !eligible && (
              <div className="mt-4 text-sm text-slate-500">
                {notEligibleMsg}
              </div>
            )}

            {!submitted && eligible && (
              <div className="mt-5 border-t border-navy-50 pt-5">
                <SurveyForm type={type} />
              </div>
            )}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}
