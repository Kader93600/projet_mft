import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { NextRequest, NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { PdfLogoMark } from "@/lib/pdf-logo";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const styles = StyleSheet.create({
  page: { padding: 50, fontSize: 11, fontFamily: "Helvetica", color: "#0f172a" },
  topBar: { height: 8, backgroundColor: "#9FE220", marginBottom: 30 },
  brand: { fontSize: 28, fontWeight: "bold", color: "#0E1240", textAlign: "center" },
  sub: {
    fontSize: 10,
    color: "#64748b",
    textAlign: "center",
    marginTop: 4,
    marginBottom: 30,
  },
  title: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
    marginTop: 30,
    marginBottom: 6,
    textTransform: "uppercase",
    letterSpacing: 2,
  },
  titleUnderline: {
    width: 80,
    height: 2,
    backgroundColor: "#9FE220",
    alignSelf: "center",
    marginBottom: 24,
  },
  intro: {
    fontSize: 11,
    lineHeight: 1.6,
    color: "#334155",
    textAlign: "center",
    marginBottom: 14,
  },
  nameBlock: {
    padding: 10,
    marginVertical: 16,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: "#9FE220",
  },
  nameText: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
  },
  nameSub: { fontSize: 9, color: "#64748b", textAlign: "center", marginTop: 2 },
  body: {
    fontSize: 11,
    lineHeight: 1.7,
    color: "#334155",
    textAlign: "justify",
    marginBottom: 20,
  },
  statsRow: { flexDirection: "row", marginTop: 10, marginBottom: 20, gap: 8 },
  stat: {
    flex: 1,
    padding: 10,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    borderRadius: 4,
    backgroundColor: "#f8fafc",
    alignItems: "center",
  },
  statLabel: { fontSize: 8, color: "#64748b", textTransform: "uppercase", marginBottom: 3 },
  statValue: { fontSize: 16, fontWeight: "bold", color: "#0E1240" },
  signature: {
    marginTop: 30,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
  },
  signatureBlock: { width: "45%" },
  signatureDate: { fontSize: 10, color: "#334155", marginBottom: 30 },
  signatureLine: {
    borderTopWidth: 1,
    borderTopColor: "#0E1240",
    paddingTop: 3,
    fontSize: 9,
    color: "#64748b",
  },
  footer: {
    position: "absolute",
    bottom: 30,
    left: 50,
    right: 50,
    fontSize: 7,
    color: "#94a3b8",
    textAlign: "center",
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    paddingTop: 6,
  },
});

function fmtDate(d: string | Date | null) {
  if (!d) return "—";
  const date = typeof d === "string" ? new Date(d) : d;
  return date.toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

function fmtHours(s: number) {
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  return `${h}h${String(m).padStart(2, "0")}`;
}

function Attestation({
  user,
  summary,
  generatedAt,
}: {
  user: any;
  summary: any;
  generatedAt: string;
}) {
  const C = React.createElement;
  const totalTime = (summary?.total_session_s ?? 0) + (summary?.lesson_time_s ?? 0);

  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", style: styles.page },
      C(View, { style: styles.topBar }),
      C(
        View,
        { style: { alignItems: "center", marginBottom: 6 } },
        C(PdfLogoMark, { size: 48 })
      ),
      C(Text, { style: styles.brand }, "MA FORMATION TRANSPORT"),
      C(
        Text,
        { style: styles.sub },
        "Organisme de formation certifié · Titre pro GOTRM (RNCP 40990)"
      ),

      C(Text, { style: styles.title }, "Attestation de formation"),
      C(View, { style: styles.titleUnderline }),

      C(Text, { style: styles.intro }, "Je soussigné(e), responsable pédagogique de l'organisme MA FORMATION TRANSPORT, atteste que"),

      C(
        View,
        { style: styles.nameBlock },
        C(Text, { style: styles.nameText }, user?.full_name || user?.email || "—"),
        user?.email
          ? C(Text, { style: styles.nameSub }, user.email)
          : null
      ),

      C(
        Text,
        { style: styles.body },
        `a suivi la formation préparatoire au titre professionnel "Gestionnaire des Opérations de Transport Routier de Marchandises" (RNCP 40990) dispensée en distanciel sur la plateforme MA FORMATION TRANSPORT, du ${fmtDate(
          summary?.first_session
        )} au ${fmtDate(summary?.last_session)}.`
      ),

      // Stats
      C(
        View,
        { style: styles.statsRow },
        C(
          View,
          { style: styles.stat },
          C(Text, { style: styles.statLabel }, "Temps connecté"),
          C(Text, { style: styles.statValue }, fmtHours(totalTime))
        ),
        C(
          View,
          { style: styles.stat },
          C(Text, { style: styles.statLabel }, "Leçons suivies"),
          C(Text, { style: styles.statValue }, String(summary?.lessons_viewed ?? 0))
        ),
        C(
          View,
          { style: styles.stat },
          C(Text, { style: styles.statLabel }, "Quiz réussis"),
          C(
            Text,
            { style: styles.statValue },
            `${summary?.quiz_passed ?? 0}/${summary?.quiz_attempts ?? 0}`
          )
        ),
        C(
          View,
          { style: styles.stat },
          C(Text, { style: styles.statLabel }, "Score moyen"),
          C(Text, { style: styles.statValue }, `${summary?.avg_score ?? 0}%`)
        )
      ),

      C(
        Text,
        { style: styles.body },
        "La présente attestation est délivrée à l'intéressé(e) pour servir et valoir ce que de droit."
      ),

      // Signature
      C(
        View,
        { style: styles.signature },
        C(
          View,
          { style: styles.signatureBlock },
          C(Text, { style: styles.signatureDate }, `Fait le ${generatedAt}`),
          C(Text, { style: styles.signatureLine }, "Date et lieu")
        ),
        C(
          View,
          { style: styles.signatureBlock },
          C(Text, { style: styles.signatureDate }, " "),
          C(Text, { style: styles.signatureLine }, "Signature et cachet du responsable")
        )
      ),

      C(
        Text,
        { style: styles.footer },
        "MA FORMATION TRANSPORT — SIRET à compléter — Organisme de formation enregistré sous le n° [à compléter]"
      )
    )
  );
}

export async function GET(req: NextRequest) {
  const supabase = await createClient();
  const {
    data: { user: authUser },
  } = await supabase.auth.getUser();
  if (!authUser) return NextResponse.json({ error: "unauth" }, { status: 401 });
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", authUser.id)
    .single();
  if (!isStaff(me?.role))
    return NextResponse.json({ error: "forbidden" }, { status: 403 });

  const userId = req.nextUrl.searchParams.get("user");
  if (!userId) return NextResponse.json({ error: "user requis" }, { status: 400 });

  const [{ data: user }, { data: summary }] = await Promise.all([
    supabase.from("profiles").select("*").eq("id", userId).single(),
    supabase
      .from("user_training_summary")
      .select("*")
      .eq("id", userId)
      .single(),
  ]);

  const generatedAt = new Date().toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const buffer = await renderToBuffer(Attestation({ user, summary, generatedAt }));
  const safe = (user?.full_name || user?.email || "stagiaire")
    .replace(/[^a-z0-9]+/gi, "-")
    .toLowerCase();
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="attestation-${safe}.pdf"`,
      "Cache-Control": "no-store",
    },
  });
}
