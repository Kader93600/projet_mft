import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { OnboardingWizard } from "./onboarding-wizard";

export const dynamic = "force-dynamic";

export default async function OnboardingPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, email, onboarding_completed_at")
    .eq("id", user.id)
    .single();

  if (profile?.onboarding_completed_at) {
    redirect("/dashboard");
  }

  const [{ data: docs }, { data: acceptances }] = await Promise.all([
    supabase
      .from("onboarding_documents")
      .select("id, type, title, version, content_md")
      .eq("published", true)
      .order("type"),
    supabase
      .from("document_acceptances")
      .select("document_id, accepted_at")
      .eq("user_id", user.id),
  ]);

  const accepted = new Set((acceptances ?? []).map((a) => a.document_id));
  const steps = (docs ?? []).map((d) => ({
    ...d,
    accepted: accepted.has(d.id),
  }));

  // Aucun document publié : débloquer l'accès directement
  if (steps.length === 0) {
    return (
      <div className="max-w-lg mx-auto pt-12 text-center space-y-4">
        <h1 className="font-display text-2xl font-semibold text-navy-900">
          Aucun document d'accueil à valider
        </h1>
        <p className="text-slate-600 text-sm">
          L'administrateur n'a pas encore publié les documents d'entrée en
          formation. Vous pouvez accéder directement à votre espace.
        </p>
        <a href="/dashboard" className="inline-block">
          <span className="px-5 py-2.5 rounded-xl bg-navy-900 text-white font-medium inline-block">
            Accéder au dashboard
          </span>
        </a>
      </div>
    );
  }

  return (
    <OnboardingWizard
      firstName={profile?.full_name?.split(" ")[0] ?? "stagiaire"}
      steps={steps}
    />
  );
}
