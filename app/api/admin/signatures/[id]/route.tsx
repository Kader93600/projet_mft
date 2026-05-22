// Téléchargement (admin) de l'attestation d'acceptation d'un stagiaire.
import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { renderAttestationPdf, type AttestationRow } from "@/lib/attestation-pdf";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function GET(
  _req: Request,
  { params }: { params: { id: string } }
) {
  const supabase = createClient();
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

  const [{ data: target }, { data: acceptances }, { data: sig }] =
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

  if (!target) return NextResponse.json({ error: "not_found" }, { status: 404 });

  const rows: AttestationRow[] = (acceptances ?? []).map((a: any) => ({
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
    signatureImage: (sig as any)?.signature_data ?? null,
  });

  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="attestation-${refLabel}.pdf"`,
      "Cache-Control": "private, no-store",
    },
  });
}
