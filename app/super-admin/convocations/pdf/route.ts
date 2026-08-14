// =====================================================================
// GET /super-admin/convocations/pdf
//   ?id=<uuid>                        → PDF d'une convocation
//   ?ids=<uuid,uuid,...>&mode=merged  → PDF unique (une page par convocation)
//   ?ids=<uuid,uuid,...>&mode=zip     → archive ZIP (un PDF par destinataire)
//   &download=1                       → force le téléchargement (sinon inline)
// Staff uniquement. Le PDF est régénéré depuis le snapshot `payload`
// stocké en base : une convocation reste reproductible à l'identique.
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import JSZip from "jszip";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isStaff } from "@/lib/permissions";
import { captureException } from "@/lib/observability";
import { renderConvocationPdf, renderConvocationsPdf } from "@/lib/convocation-pdf";
import type { ConvocationPayload, ConvocationTemplate } from "@/lib/convocations";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

interface Row {
  id: string;
  payload: ConvocationPayload;
  template: ConvocationTemplate;
  file_name: string;
}

export async function GET(req: NextRequest) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });
  const { data: me } = await supabase
    .from("profiles").select("role, disabled").eq("id", user.id).maybeSingle();
  if (!me || me.disabled || !isStaff(me.role)) {
    return NextResponse.json({ error: "forbidden" }, { status: 403 });
  }

  const sp = req.nextUrl.searchParams;
  const download = sp.get("download") === "1";
  const ids = sp.get("id")
    ? [sp.get("id") as string]
    : (sp.get("ids") ?? "").split(",").map((s) => s.trim()).filter(Boolean);
  if (ids.length === 0 || ids.length > 200) {
    return NextResponse.json({ error: "invalid_ids" }, { status: 400 });
  }

  const admin = createAdminClient();
  const { data, error } = await admin
    .from("convocations")
    .select("id, payload, template, file_name")
    .in("id", ids);
  if (error || !data || data.length === 0) {
    return NextResponse.json({ error: "not_found" }, { status: 404 });
  }
  // Restitue l'ordre demandé (le planning en masse est ordonné)
  const byId = new Map((data as unknown as Row[]).map((r) => [r.id, r]));
  const rows = ids.map((i) => byId.get(i)).filter((r): r is Row => !!r);

  const disposition = (name: string) =>
    `${download ? "attachment" : "inline"}; filename="${name.replace(/[^\w.\-]/g, "_")}"`;

  try {
    const mode = sp.get("mode");

    if (rows.length === 1 && mode !== "zip") {
      const pdf = await renderConvocationPdf(rows[0].payload, rows[0].template);
      return new NextResponse(new Uint8Array(pdf), {
        headers: {
          "Content-Type": "application/pdf",
          "Content-Disposition": disposition(rows[0].file_name),
          "Cache-Control": "no-store",
        },
      });
    }

    if (mode === "zip") {
      const zip = new JSZip();
      const seen = new Set<string>();
      for (const r of rows) {
        const pdf = await renderConvocationPdf(r.payload, r.template);
        let name = r.file_name;
        // Deux homonymes le même jour → suffixe pour ne rien écraser
        for (let n = 2; seen.has(name); n++) name = r.file_name.replace(/\.pdf$/, `_${n}.pdf`);
        seen.add(name);
        zip.file(name, pdf);
      }
      const archive = await zip.generateAsync({ type: "nodebuffer", compression: "DEFLATE" });
      const stamp = new Date().toISOString().slice(0, 10);
      return new NextResponse(new Uint8Array(archive), {
        headers: {
          "Content-Type": "application/zip",
          "Content-Disposition": `attachment; filename="Convocations_${stamp}.zip"`,
          "Cache-Control": "no-store",
        },
      });
    }

    // PDF unique multi-convocations
    const pdf = await renderConvocationsPdf(
      rows.map((r) => ({ payload: r.payload, template: r.template })),
    );
    const stamp = new Date().toISOString().slice(0, 10);
    return new NextResponse(new Uint8Array(pdf), {
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": disposition(`Convocations_${stamp}.pdf`),
        "Cache-Control": "no-store",
      },
    });
  } catch (e) {
    await captureException(e, { tags: { route: "convocations/pdf" } });
    return NextResponse.json({ error: "render_failed" }, { status: 500 });
  }
}
