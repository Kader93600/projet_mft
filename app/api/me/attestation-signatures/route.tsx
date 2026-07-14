// Attestation d'acceptation des documents administratifs signés par le stagiaire.
// Preuve récapitulative (PDF) : documents, versions, horodatage, signature.
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import type { Tables } from "@/lib/database.types";
import { renderAttestationPdf, type AttestationRow } from "@/lib/attestation-pdf";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/** Ligne d'acceptation + embed `onboarding_documents(title)` (cf. select). */
type AcceptanceRow = Pick<
  Tables<"document_acceptances">,
  "accepted_at" | "document_version" | "ip_address"
> & {
  onboarding_documents: Pick<Tables<"onboarding_documents">, "title"> | null;
};

export async function GET() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauth" }, { status: 401 });
  }

  const [{ data: profileRow }, { data: acceptanceRows }, { data: sigRow }] =
    await Promise.all([
      supabase
        .from("profiles")
        .select("full_name, email")
        .eq("id", user.id)
        .maybeSingle(),
      // `overrideTypes` (API supabase-js) : client non paramétré par
      // `Database` → l'embed to-one `onboarding_documents` est inféré en
      // tableau alors que PostgREST renvoie un objet.
      supabase
        .from("document_acceptances")
        .select(
          "accepted_at, document_version, ip_address, onboarding_documents(title)"
        )
        .eq("user_id", user.id)
        .order("accepted_at", { ascending: true })
        .overrideTypes<AcceptanceRow[], { merge: false }>(),
      supabase
        .from("user_signatures")
        .select("signature_data")
        .eq("user_id", user.id)
        .maybeSingle(),
    ]);

  const profile = (profileRow ?? null) as Pick<
    Tables<"profiles">,
    "full_name" | "email"
  > | null;
  const acceptances = acceptanceRows ?? [];
  const sig = (sigRow ?? null) as Pick<
    Tables<"user_signatures">,
    "signature_data"
  > | null;

  const rows: AttestationRow[] = acceptances.map((a) => ({
    title: a.onboarding_documents?.title ?? "Document",
    version: a.document_version,
    acceptedAt: a.accepted_at,
    ip: a.ip_address ?? null,
  }));

  if (rows.length === 0) {
    return NextResponse.json({ error: "no_documents" }, { status: 404 });
  }

  const refLabel = `ATT-${String(user.id).replace(/-/g, "").slice(0, 8).toUpperCase()}`;
  const buffer = await renderAttestationPdf({
    refLabel,
    name: profile?.full_name ?? profile?.email ?? "Stagiaire",
    email: profile?.email ?? "",
    rows,
    signatureImage: sig?.signature_data ?? null,
  });

  // `renderAttestationPdf` renvoie un `Buffer<ArrayBufferLike>` ; `BodyInit`
  // n'accepte que les vues adossées à un `ArrayBuffer` (pas `SharedArrayBuffer`).
  // Un Buffer Node est toujours adossé à un ArrayBuffer → resserrement du
  // paramètre de type, sans conversion ni copie au runtime.
  return new NextResponse(buffer as Buffer<ArrayBuffer>, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="attestation-acceptation-${refLabel}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
