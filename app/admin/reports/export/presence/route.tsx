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

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const styles = StyleSheet.create({
  page: { padding: 40, fontSize: 10, fontFamily: "Helvetica", color: "#0f172a" },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    marginBottom: 14,
    paddingBottom: 8,
    borderBottomWidth: 2,
    borderBottomColor: "#9FE220",
  },
  brand: { fontSize: 16, fontWeight: "bold", color: "#0E1240" },
  sub: { fontSize: 9, color: "#64748b", marginTop: 2 },
  meta: { fontSize: 8, color: "#64748b" },
  h1: { fontSize: 13, fontWeight: "bold", color: "#0E1240", marginTop: 12, marginBottom: 6 },
  info: {
    marginTop: 4,
    marginBottom: 10,
    padding: 8,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    backgroundColor: "#f8fafc",
    borderRadius: 4,
  },
  infoRow: { flexDirection: "row", fontSize: 9, marginBottom: 2 },
  infoLabel: { width: 100, color: "#64748b" },
  infoVal: { flex: 1, color: "#0f172a", fontWeight: "bold" },
  table: { borderWidth: 1, borderColor: "#e2e8f0", borderRadius: 3, marginTop: 4 },
  tr: { flexDirection: "row", borderBottomWidth: 1, borderBottomColor: "#e2e8f0" },
  trLast: { flexDirection: "row" },
  th: {
    padding: 6,
    fontWeight: "bold",
    fontSize: 8,
    color: "#475569",
    backgroundColor: "#f1f5f9",
    textTransform: "uppercase",
  },
  td: { padding: 6, fontSize: 9 },
  totalRow: {
    flexDirection: "row",
    marginTop: 6,
    padding: 6,
    backgroundColor: "#0E1240",
    borderRadius: 3,
  },
  totalLabel: { flex: 1, color: "#fff", fontWeight: "bold", fontSize: 10 },
  totalVal: { color: "#9FE220", fontWeight: "bold", fontSize: 10 },
  signBox: {
    marginTop: 24,
    flexDirection: "row",
    gap: 20,
  },
  sign: {
    flex: 1,
    borderTopWidth: 1,
    borderTopColor: "#94a3b8",
    paddingTop: 4,
    fontSize: 8,
    color: "#64748b",
    minHeight: 60,
  },
  footer: {
    position: "absolute",
    bottom: 24,
    left: 40,
    right: 40,
    fontSize: 7,
    color: "#94a3b8",
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    paddingTop: 6,
    flexDirection: "row",
    justifyContent: "space-between",
  },
});

function fmtDate(d: string | Date) {
  const date = typeof d === "string" ? new Date(d) : d;
  return date.toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}
function fmtTime(d: string | Date) {
  const date = typeof d === "string" ? new Date(d) : d;
  return date.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" });
}
function fmtDuration(s: number) {
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}`;
  return `${m} min`;
}

function PresenceReport({
  user,
  days,
  from,
  to,
  totalS,
  generatedAt,
}: {
  user: any;
  days: any[];
  from: string;
  to: string;
  totalS: number;
  generatedAt: string;
}) {
  const C = React.createElement;
  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", style: styles.page },
      // Header
      C(
        View,
        { style: styles.header },
        C(
          View,
          {},
          C(Text, { style: styles.brand }, "GOTRM Academy"),
          C(Text, { style: styles.sub }, "Feuille de présence — Formation à distance")
        ),
        C(Text, { style: styles.meta }, `Édité le ${generatedAt}`)
      ),

      // Bloc info stagiaire
      C(
        View,
        { style: styles.info },
        C(
          View,
          { style: styles.infoRow },
          C(Text, { style: styles.infoLabel }, "Stagiaire :"),
          C(Text, { style: styles.infoVal }, user?.full_name || user?.email || "—")
        ),
        C(
          View,
          { style: styles.infoRow },
          C(Text, { style: styles.infoLabel }, "Email :"),
          C(Text, { style: styles.infoVal }, user?.email || "—")
        ),
        C(
          View,
          { style: styles.infoRow },
          C(Text, { style: styles.infoLabel }, "Formation :"),
          C(Text, { style: styles.infoVal }, "Titre pro GOTRM (RNCP 40990)")
        ),
        C(
          View,
          { style: styles.infoRow },
          C(Text, { style: styles.infoLabel }, "Période :"),
          C(Text, { style: styles.infoVal }, `Du ${fmtDate(from)} au ${fmtDate(to)}`)
        )
      ),

      C(Text, { style: styles.h1 }, "Détail des connexions"),

      C(
        View,
        { style: styles.table },
        // Header
        C(
          View,
          { style: styles.tr },
          C(Text, { style: [styles.th, { width: "28%" }] }, "Date"),
          C(Text, { style: [styles.th, { width: "17%" }] }, "1ère connexion"),
          C(Text, { style: [styles.th, { width: "17%" }] }, "Dernière activité"),
          C(Text, { style: [styles.th, { width: "13%" }] }, "Sessions"),
          C(Text, { style: [styles.th, { width: "25%" }] }, "Temps connecté")
        ),
        ...(days.length === 0
          ? [
              C(
                View,
                { style: styles.trLast, key: "empty" },
                C(
                  Text,
                  {
                    style: [styles.td, { width: "100%", color: "#94a3b8", textAlign: "center" }],
                  },
                  "Aucune connexion sur la période."
                )
              ),
            ]
          : days.map((d: any, i: number) =>
              C(
                View,
                {
                  key: d.day,
                  style: i === days.length - 1 ? styles.trLast : styles.tr,
                },
                C(Text, { style: [styles.td, { width: "28%" }] }, fmtDate(d.day)),
                C(Text, { style: [styles.td, { width: "17%" }] }, fmtTime(d.first_connection)),
                C(Text, { style: [styles.td, { width: "17%" }] }, fmtTime(d.last_activity)),
                C(Text, { style: [styles.td, { width: "13%" }] }, String(d.sessions)),
                C(
                  Text,
                  { style: [styles.td, { width: "25%", fontWeight: "bold" }] },
                  fmtDuration(d.total_seconds ?? 0)
                )
              )
            ))
      ),

      // Total
      C(
        View,
        { style: styles.totalRow },
        C(Text, { style: styles.totalLabel }, "TOTAL DE LA PÉRIODE"),
        C(Text, { style: styles.totalVal }, fmtDuration(totalS))
      ),

      // Signatures
      C(
        View,
        { style: styles.signBox },
        C(
          Text,
          { style: styles.sign },
          "Signature du stagiaire\n(précédée de la mention « Lu et approuvé »)"
        ),
        C(Text, { style: styles.sign }, "Signature et cachet du responsable pédagogique")
      ),

      // Footer
      C(
        View,
        { style: styles.footer, fixed: true },
        C(
          Text,
          {},
          "GOTRM Academy — Document officiel conformément aux obligations Qualiopi (formation à distance)"
        ),
        C(Text, {
          render: ({ pageNumber, totalPages }: any) => `${pageNumber} / ${totalPages}`,
        })
      )
    )
  );
}

export async function GET(req: NextRequest) {
  const supabase = createClient();
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

  const now = new Date();
  const defaultFrom = new Date(now.getTime() - 30 * 86400_000);
  const from = req.nextUrl.searchParams.get("from") ?? defaultFrom.toISOString().slice(0, 10);
  const to = req.nextUrl.searchParams.get("to") ?? now.toISOString().slice(0, 10);

  const [{ data: user }, { data: days }] = await Promise.all([
    supabase.from("profiles").select("*").eq("id", userId).single(),
    supabase
      .from("user_daily_activity")
      .select("*")
      .eq("user_id", userId)
      .gte("day", from)
      .lte("day", to)
      .order("day"),
  ]);

  const list = (days ?? []) as any[];
  const total = list.reduce((s, d) => s + (d.total_seconds || 0), 0);
  const generatedAt = now.toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const buffer = await renderToBuffer(
    PresenceReport({ user, days: list, from, to, totalS: total, generatedAt })
  );
  const safe = (user?.full_name || user?.email || "stagiaire")
    .replace(/[^a-z0-9]+/gi, "-")
    .toLowerCase();
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="presence-${safe}-${from}-${to}.pdf"`,
      "Cache-Control": "no-store",
    },
  });
}
