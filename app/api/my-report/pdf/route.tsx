import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";
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
import type { Tables } from "@/lib/database.types";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// ── Types de lecture (les select() ci-dessous sont la source de vérité) ──
type ProfileRow = Pick<Tables<"profiles">, "full_name" | "email">;
type SummaryRow = Tables<"user_training_summary">;
type BlocRow = Pick<Tables<"blocs">, "id" | "code" | "title">;
type ModuleRow = Pick<Tables<"modules">, "id" | "bloc_id">;
type LessonRow = Pick<Tables<"lessons">, "id" | "module_id">;
type ProgressRow = Pick<Tables<"lesson_progress">, "lesson_id" | "completed">;
type AttemptRow = Pick<
  Tables<"quiz_attempts">,
  "percentage" | "passed" | "finished_at"
> & {
  quizzes: Pick<Tables<"quizzes">, "title" | "type" | "module_id"> | null;
};

/** Ligne agrégée « progression par bloc » calculée dans le GET. */
type BlocProgress = {
  code: string;
  title: string;
  lessonsDone: number;
  lessonsTotal: number;
  avgScore: number | null;
};

const S = StyleSheet.create({
  page: { padding: 44, fontSize: 10, fontFamily: "Helvetica", color: "#0f172a" },
  topBar: { height: 6, backgroundColor: "#9FE220", marginBottom: 18 },
  brand: { fontSize: 20, fontWeight: "bold", color: "#0E1240" },
  sub: { fontSize: 9, color: "#64748b", marginBottom: 18 },
  h1: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 12,
    marginBottom: 2,
  },
  h2: {
    fontSize: 11,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 12,
    marginBottom: 6,
    textTransform: "uppercase",
    letterSpacing: 1,
  },
  meta: { fontSize: 9, color: "#64748b", marginBottom: 12 },
  kpiRow: { flexDirection: "row", gap: 8, marginBottom: 14 },
  kpi: {
    flex: 1,
    padding: 8,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    borderRadius: 4,
    backgroundColor: "#f8fafc",
  },
  kpiLabel: {
    fontSize: 8,
    color: "#64748b",
    textTransform: "uppercase",
    marginBottom: 3,
  },
  kpiValue: { fontSize: 14, fontWeight: "bold", color: "#0E1240" },
  blocRow: {
    flexDirection: "row",
    paddingVertical: 5,
    borderBottomWidth: 0.5,
    borderBottomColor: "#e2e8f0",
  },
  blocCode: { width: 40, fontWeight: "bold", color: "#0E1240" },
  blocTitle: { flex: 1, color: "#334155" },
  blocPct: { width: 55, textAlign: "right", fontWeight: "bold" },
  blocDetail: { width: 75, textAlign: "right", color: "#64748b", fontSize: 9 },
  tbl: { marginTop: 6 },
  th: {
    flexDirection: "row",
    backgroundColor: "#f1f5f9",
    paddingVertical: 4,
    paddingHorizontal: 6,
    fontWeight: "bold",
    fontSize: 8,
    textTransform: "uppercase",
    color: "#475569",
  },
  tr: {
    flexDirection: "row",
    paddingVertical: 3.5,
    paddingHorizontal: 6,
    borderBottomWidth: 0.5,
    borderBottomColor: "#e2e8f0",
  },
  td: { flex: 1 },
  footer: {
    position: "absolute",
    bottom: 24,
    left: 44,
    right: 44,
    fontSize: 7,
    color: "#94a3b8",
    textAlign: "center",
    borderTopWidth: 0.5,
    borderTopColor: "#e2e8f0",
    paddingTop: 4,
  },
});

function fmtHours(s: number) {
  if (!s) return "0 h";
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  return h ? `${h}h${String(m).padStart(2, "0")}` : `${m} min`;
}

function fmtDate(d: string | null | undefined) {
  if (!d) return "—";
  return new Date(d).toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

function scoreColor(pct: number) {
  if (pct >= 75) return "#047857";
  if (pct >= 50) return "#b45309";
  return "#b91c1c";
}

function Report({
  user,
  summary,
  byBloc,
  recent,
  generatedAt,
}: {
  user: ProfileRow | null;
  summary: Partial<SummaryRow>;
  byBloc: BlocProgress[];
  recent: AttemptRow[];
  generatedAt: string;
}) {
  const C = React.createElement;
  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", style: S.page },
      C(View, { style: S.topBar }),
      C(
        View,
        { style: { flexDirection: "row", alignItems: "center", gap: 10, marginBottom: 2 } },
        C(PdfLogoMark, { size: 36 }),
        C(Text, { style: S.brand }, "MA FORMATION TRANSPORT")
      ),
      C(
        Text,
        { style: S.sub },
        "Bilan personnel de formation — " + generatedAt
      ),

      C(
        Text,
        { style: S.h1 },
        user?.full_name || user?.email || "Stagiaire"
      ),
      C(
        Text,
        { style: S.meta },
        (user?.email ?? "") +
          "  ·  Inscrit le " +
          fmtDate(summary?.enrolled_at)
      ),

      C(Text, { style: S.h2 }, "Indicateurs globaux"),
      C(
        View,
        { style: S.kpiRow },
        C(
          View,
          { style: S.kpi },
          C(Text, { style: S.kpiLabel }, "Temps connecté"),
          C(Text, { style: S.kpiValue }, fmtHours(summary?.total_session_s ?? 0))
        ),
        C(
          View,
          { style: S.kpi },
          C(Text, { style: S.kpiLabel }, "Leçons complétées"),
          C(Text, { style: S.kpiValue }, String(summary?.lessons_completed ?? 0))
        ),
        C(
          View,
          { style: S.kpi },
          C(Text, { style: S.kpiLabel }, "Quiz tentés"),
          C(
            Text,
            { style: S.kpiValue },
            (summary?.quiz_passed ?? 0) +
              " / " +
              (summary?.quiz_attempts ?? 0)
          )
        ),
        C(
          View,
          { style: S.kpi },
          C(Text, { style: S.kpiLabel }, "Score moyen"),
          C(
            Text,
            { style: [S.kpiValue, { color: scoreColor(summary?.avg_score ?? 0) }] },
            (summary?.avg_score ?? 0) + " %"
          )
        )
      ),

      C(Text, { style: S.h2 }, "Progression par bloc de compétence"),
      ...byBloc.map((b: BlocProgress, i: number) =>
        C(
          View,
          { key: i, style: S.blocRow },
          C(Text, { style: S.blocCode }, b.code),
          C(Text, { style: S.blocTitle }, b.title),
          C(
            Text,
            { style: [S.blocDetail] },
            b.lessonsDone + "/" + b.lessonsTotal + " leçons"
          ),
          C(
            Text,
            {
              style: [
                S.blocPct,
                { color: b.avgScore != null ? scoreColor(b.avgScore) : "#94a3b8" },
              ],
            },
            b.avgScore != null ? b.avgScore + " %" : "—"
          )
        )
      ),

      C(Text, { style: S.h2 }, "20 dernières tentatives"),
      C(
        View,
        { style: S.th },
        C(Text, { style: [S.td, { flex: 3 }] }, "Quiz"),
        C(Text, { style: S.td }, "Type"),
        C(Text, { style: [S.td, { textAlign: "right" }] }, "Score"),
        C(Text, { style: [S.td, { textAlign: "right" }] }, "Date")
      ),
      ...recent.map((a: AttemptRow, i: number) =>
        C(
          View,
          { key: i, style: S.tr },
          C(Text, { style: [S.td, { flex: 3 }] }, a.quizzes?.title ?? "—"),
          C(Text, { style: S.td }, a.quizzes?.type ?? "—"),
          C(
            Text,
            {
              style: [
                S.td,
                // `?? 0` : scoreColor(null) et scoreColor(0) renvoient la même
                // couleur (tous les seuils sont faux) → rendu inchangé.
                { textAlign: "right", color: scoreColor(a.percentage ?? 0) },
              ],
            },
            // String(x) reproduit exactement l'ancienne concaténation implicite.
            String(a.percentage) + " %"
          ),
          C(
            Text,
            { style: [S.td, { textAlign: "right" }] },
            a.finished_at
              ? new Date(a.finished_at).toLocaleDateString("fr-FR")
              : "—"
          )
        )
      ),

      C(
        Text,
        { style: S.footer },
        "Document personnel généré par la plateforme MA FORMATION TRANSPORT — RNCP 40990"
      )
    )
  );
}

export async function GET() {
  const supabase = await createClient();
  const {
    data: { user: authUser },
  } = await supabase.auth.getUser();
  if (!authUser) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const [
    { data: profile },
    { data: summary },
    { data: blocs },
    { data: modules },
    { data: lessons },
    { data: progress },
    { data: attempts },
  ] = await Promise.all([
    supabase
      .from("profiles")
      .select("full_name, email")
      .eq("id", authUser.id)
      .single(),
    supabase
      .from("user_training_summary")
      .select("*")
      .eq("id", authUser.id)
      .maybeSingle(),
    supabase.from("blocs").select("id, code, title").order("order"),
    supabase.from("modules").select("id, bloc_id"),
    supabase.from("lessons").select("id, module_id"),
    supabase
      .from("lesson_progress")
      .select("lesson_id, completed")
      .eq("user_id", authUser.id),
    supabase
      .from("quiz_attempts")
      // `select<Query, Result>` : sans client générique <Database>,
      // postgrest-js infère l'embed `quizzes` en tableau ; on donne le type réel.
      .select<string, AttemptRow>(
        "percentage, passed, finished_at, quizzes(title, type, module_id)"
      )
      .eq("user_id", authUser.id)
      .order("finished_at", { ascending: false })
      .limit(50),
  ]);

  const lessonRows = (lessons ?? []) as LessonRow[];
  const progressRows = (progress ?? []) as ProgressRow[];
  const blocRows = (blocs ?? []) as BlocRow[];
  const moduleRows = (modules ?? []) as ModuleRow[];
  const attemptRows = attempts ?? [];

  const lessonsByModule = new Map<string, string[]>();
  lessonRows.forEach((l) => {
    const arr = lessonsByModule.get(l.module_id) ?? [];
    arr.push(l.id);
    lessonsByModule.set(l.module_id, arr);
  });
  const completed = new Set(
    progressRows.filter((p) => p.completed).map((p) => p.lesson_id)
  );

  const byBloc: BlocProgress[] = blocRows.map((b) => {
    const modsOfBloc = moduleRows.filter((m) => m.bloc_id === b.id);
    const modIds = new Set(modsOfBloc.map((m) => m.id));
    const lessonsOfBloc = modsOfBloc.flatMap(
      (m) => lessonsByModule.get(m.id) ?? []
    );
    const done = lessonsOfBloc.filter((id) => completed.has(id)).length;
    const atts = attemptRows.filter((a) =>
      a.quizzes?.module_id ? modIds.has(a.quizzes.module_id) : false
    );
    const avg =
      atts.length > 0
        ? Math.round(
            // `?? 0` : strictement équivalent à l'ancien `s + a.percentage`
            // (JS coerce `null` en 0 dans une addition numérique).
            atts.reduce((s: number, a) => s + (a.percentage ?? 0), 0) /
              atts.length
          )
        : null;
    return {
      code: b.code,
      title: b.title,
      lessonsDone: done,
      lessonsTotal: lessonsOfBloc.length,
      avgScore: avg,
    };
  });

  const recent = attemptRows.slice(0, 20);
  const generatedAt = new Date().toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const buffer = await renderToBuffer(
    // JSX plutôt que React.createElement : l'élément obtenu est un
    // JSX.Element (ReactElement<any>), directement accepté par la signature
    // `renderToBuffer(document: ReactElement<DocumentProps>)` de @react-pdf.
    <Report
      user={(profile ?? null) as ProfileRow | null}
      summary={(summary ?? {}) as Partial<SummaryRow>}
      byBloc={byBloc}
      recent={recent}
      generatedAt={generatedAt}
    />
  );

  // `as any` conservé : quirk de typage tiers. `renderToBuffer` renvoie un
  // `Buffer<ArrayBufferLike>` (Node) que lib.dom refuse comme `BodyInit`
  // (qui attend un `ArrayBufferView<ArrayBuffer>`). Toute alternative typée
  // (copie en Uint8Array) modifierait le runtime.
  return new NextResponse(buffer as any, {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="bilan-gotrm-${authUser.id.slice(0, 8)}.pdf"`,
      "Cache-Control": "private, max-age=60",
    },
  });
}
