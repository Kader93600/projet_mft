import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { SignatureFlow } from "./signature-flow";

export const dynamic = "force-dynamic";

export default async function SignatureObligatoirePage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, role, mandatory_signature_at")
    .eq("id", user.id)
    .maybeSingle();

  // Déjà signé → accès normal.
  if (profile?.mandatory_signature_at) redirect("/dashboard");
  // Le personnel n'est pas concerné par la signature stagiaire.
  if (profile?.role && profile.role !== "student") redirect("/dashboard");

  const { data: docs } = await supabase
    .from("onboarding_documents")
    .select("id, type, title, version, content_md")
    .eq("published", true)
    .order("type");

  // Aucun document publié → on n'impose pas l'étape.
  if (!docs || docs.length === 0) redirect("/dashboard");

  return (
    <SignatureFlow docs={docs as any} fullName={profile?.full_name ?? ""} />
  );
}
