import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { SurveyForm } from "./survey-form";
import { ClipboardCheck, Thermometer, Snowflake } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function EvaluationPage({
  params,
}: {
  params: { type: string };
}) {
  if (params.type !== "chaud" && params.type !== "froid") notFound();
  const type = params.type as "chaud" | "froid";

  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: existing } = await supabase
    .from("satisfaction_surveys")
    .select("submitted_at")
    .eq("user_id", user.id)
    .eq("type", type)
    .maybeSingle();

  const isChaud = type === "chaud";
  const Icon = isChaud ? Thermometer : Snowflake;

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <header>
        <div className="flex items-center gap-2">
          <Icon className={isChaud ? "h-4 w-4 text-rose-500" : "h-4 w-4 text-sky-500"} />
          <span className="eyebrow text-gold-700">
            Évaluation à {isChaud ? "chaud" : "froid"}
          </span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          {isChaud
            ? "Votre ressenti en fin de formation"
            : "Votre retour quelques mois après"}
        </h1>
        <p className="mt-2 text-slate-600">
          {isChaud
            ? "Votre avis nous permet d'améliorer la formation. Vous restez anonyme dans les statistiques partagées."
            : "Nous aimerions savoir ce que la formation vous a apporté après quelques mois. Vos réponses aident d'autres stagiaires."}
        </p>
      </header>

      {existing ? (
        <Card>
          <CardBody className="text-center py-12">
            <div className="mx-auto h-12 w-12 rounded-xl bg-emerald-50 text-emerald-700 flex items-center justify-center">
              <ClipboardCheck className="h-5 w-5" />
            </div>
            <p className="mt-4 font-medium text-navy-900">
              Merci, votre évaluation a déjà été enregistrée.
            </p>
            <p className="text-sm text-slate-500 mt-1">
              Soumise le{" "}
              {new Date(existing.submitted_at).toLocaleDateString("fr-FR", {
                day: "2-digit",
                month: "long",
                year: "numeric",
              })}
            </p>
          </CardBody>
        </Card>
      ) : (
        <Card>
          <CardBody>
            <SurveyForm type={type} />
          </CardBody>
        </Card>
      )}
    </div>
  );
}
