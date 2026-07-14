// Téléchargement (admin) de l'attestation d'acceptation d'un stagiaire.
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { renderAttestationPdf, type AttestationRow } from "@/lib/attestation-pdf";
import type { Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// ── Types des lignes lues (dérivés des `select` ci-dessous) ────────────
type TargetRow = Pick<Tables<"profiles">, "full_name" | "email">;
type AcceptanceRow = Pick<
  Tables<"document_acceptances">,
  "accepted_at" | "document_version" | "ip_address"
> & {
  onboarding_documents: Pick<Tables<"onboarding_documents">, "title"> | null;
};
type SignatureRow = Pick<Tables<"user_signatures">, "signature_data">;

export async function GET(_req: Request, props: { params: Promise<{ id: string }> }) {
  const params = await props.params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!me?.role || !isStaff(me.role)) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const [{ data: targetData }, { data: acceptancesData }, { data: sigData }] =
    await Promise.all([
      supabase
        .from("profiles")
        .select("full_name, email")
        .eq("id", params.id)
        .maybeSingle(),
      supabase
        .from("document_acceptances")
        .select(
          "accepted_at, document_version, ip_address, onboarding_documents(title)"
        )
        .eq("user_id", params.id)
        .order("accepted_at", { ascending: true }),
      supabase
        .from("user_signatures")
        .select("signature_data")
        .eq("user_id", params.id)
        .maybeSingle(),
    ]);

  const target = targetData as TargetRow | null;
  const acceptances = acceptancesData as AcceptanceRow[] | null;
  const sig = sigData as SignatureRow | null;

  if (!target) return NextResponse.json({ error: "not_found" }, { status: 404 });

  const rows: AttestationRow[] = (acceptances ?? []).map((a) => ({
    title: a.onboarding_documents?.title ?? "Document",
    version: a.document_version,
    acceptedAt: a.accepted_at,
    ip: a.ip_address ?? null,
  }));
  if (rows.length === 0) {
    return NextResponse.json({ error: "no_documents" }, { status: 404 });
  }

  const refLabel = `ATT-${String(params.id).replace(/-/g, "").slice(0, 8).toUpperCase()}`;
  const buffer = await renderAttestationPdf({
    refLabel,
    name: target.full_name ?? target.email ?? "Stagiaire",
    email: target.email ?? "",
    rows,
    signatureImage: sig?.signature_data ?? null,
  });

  // `renderAttestationPdf` renvoie un `Buffer` Node (Uint8Array<ArrayBufferLike>),
  // que les types DOM de `BodyInit` n'acceptent pas tels quels — cast de type
  // uniquement, la valeur transmise est bien le buffer d'origine.
  return new NextResponse(buffer as BodyInit, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="attestation-${refLabel}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
