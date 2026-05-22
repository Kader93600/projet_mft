import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { OnboardingWizard } from "./onboarding-wizard";
import { FORMATIONS } from "@/lib/formations-config";

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

  const [{ data: docs }, { data: acceptances }, { data: enrollments }] =
    await Promise.all([
      supabase
        .from("onboarding_documents")
        .select("id, type, title, version, content_md")
        .eq("published", true)
        .order("type"),
      supabase
        .from("document_acceptances")
        .select("document_id, accepted_at")
        .eq("user_id", user.id),
      supabase
        .from("enrollments")
        .select("formation_slug")
        .eq("user_id", user.id),
    ]);

  const accepted = new Set((acceptances ?? []).map((a) => a.document_id));
  const steps = (docs ?? []).map((d) => ({
    ...d,
    accepted: accepted.has(d.id),
  }));

  // Sélection de formation déjà effectuée ?
  const selectedSlug =
    (enrollments ?? []).find((e: any) => e.formation_slug)?.formation_slug ??
    null;

  // Catalogue minimal pour le picker (slug, code, title, tagline, accent, icon)
  const catalog = FORMATIONS.map((f) => ({
    slug: f.slug,
    code: f.code,
    title: f.title,
    tagline: f.tagline,
    accent: f.accent ?? "#9FE220",
    iconName: f.iconName,
    category: f.category,
    duration: f.duration,
  }));

  return (
    <OnboardingWizard
      firstName={profile?.full_name?.split(" ")[0] ?? "stagiaire"}
      fullName={profile?.full_name ?? ""}
      steps={steps}
      catalog={catalog}
      selectedSlug={selectedSlug}
    />
  );
}
