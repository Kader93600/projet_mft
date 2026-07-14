import { createClient } from "@/lib/supabase/server";

export interface PendingDoc {
  id: string;
  type: string;
  title: string;
  version: number;
  content_md: string;
}

/**
 * Documents d'accueil PUBLIÉS que l'utilisateur n'a pas encore acceptés.
 * Permet de présenter les documents à signer hors onboarding (stagiaires déjà
 * inscrits, ou document publié après leur entrée en formation).
 */
export async function getPendingDocuments(
  supabase: Awaited<ReturnType<typeof createClient>>,
  userId: string
): Promise<PendingDoc[]> {
  const [{ data: docs }, { data: acc }] = await Promise.all([
    supabase
      .from("onboarding_documents")
      .select("id, type, title, version, content_md")
      .eq("published", true)
      .order("type"),
    supabase
      .from("document_acceptances")
      .select("document_id")
      .eq("user_id", userId),
  ]);
  const accepted = new Set((acc ?? []).map((a: any) => a.document_id));
  return ((docs ?? []) as any[]).filter((d) => !accepted.has(d.id));
}
