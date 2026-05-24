import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { isStaff } from "@/lib/permissions";
import { redirect } from "next/navigation";
import { FolderOpen, Download } from "lucide-react";
import {
  reasonLabel,
  fileKind,
  formatBytes,
  DOC_STATUS,
} from "@/lib/student-documents";
import { DocumentsFilters } from "./documents-filters";
import { DocumentRow } from "./document-row";

export const dynamic = "force-dynamic";

function fmt(d: string) {
  return new Date(d).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default async function AdminDocumentsPage({
  searchParams,
}: {
  searchParams?: {
    q?: string;
    formation?: string;
    motif?: string;
    statut?: string;
  };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  const role = (me as any)?.role;
  if (!isStaff(role) && role !== "trainer") redirect("/dashboard");

  // Lecture via service role (page déjà gated staff) → joins fiables.
  const admin = createAdminClient();
  let query = admin
    .from("student_documents")
    .select(
      "id, title, reason, custom_reason, status, admin_note, file_name, size_bytes, storage_path, created_at, formation_id, profiles(full_name, email), formations(title)"
    )
    .order("created_at", { ascending: false })
    .limit(500);
  if (searchParams?.formation) query = query.eq("formation_id", searchParams.formation);
  if (searchParams?.motif) query = query.eq("reason", searchParams.motif);
  if (searchParams?.statut) query = query.eq("status", searchParams.statut);

  const [{ data: rawDocs }, { data: formations }] = await Promise.all([
    query,
    admin.from("formations").select("id, title").order("title"),
  ]);

  let docs = (rawDocs ?? []) as any[];
  const q = searchParams?.q?.trim().toLowerCase();
  if (q) {
    docs = docs.filter((d) =>
      (d.profiles?.full_name || d.profiles?.email || "")
        .toLowerCase()
        .includes(q)
    );
  }

  // URLs signées (1 h).
  const signedMap: Record<string, string> = {};
  if (docs.length) {
    const { data: signed } = await admin.storage
      .from("student-documents")
      .createSignedUrls(
        docs.map((d) => d.storage_path),
        60 * 60
      );
    (signed ?? []).forEach((s: any, i: number) => {
      if (s?.signedUrl) signedMap[docs[i].storage_path] = s.signedUrl;
    });
  }

  // Compteurs par statut (sur le jeu filtré).
  const counts = docs.reduce(
    (acc: Record<string, number>, d) => {
      acc[d.status] = (acc[d.status] ?? 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );

  // Lien d'export CSV honorant les filtres courants.
  const exportQs = new URLSearchParams(
    Object.entries(searchParams ?? {}).filter(
      ([, v]) => typeof v === "string" && v
    ) as [string, string][]
  ).toString();
  const exportHref = `/admin/documents/export/csv${exportQs ? `?${exportQs}` : ""}`;

  return (
    <div className="space-y-6">
      <header className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight inline-flex items-center gap-2.5">
            <FolderOpen className="h-7 w-7 text-brand-700" />
            Documents des stagiaires
          </h1>
          <p className="mt-2 max-w-2xl text-slate-600">
            Documents importés par les stagiaires. Filtrez, consultez, changez
            le statut et ajoutez une remarque interne.
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          {Object.entries(DOC_STATUS).map(([k, v]) => (
            <div
              key={k}
              className="rounded-xl border border-navy-100 bg-white px-3 py-2 text-center"
            >
              <div className="font-display text-lg font-semibold text-navy-950 tabular-nums">
                {counts[k] ?? 0}
              </div>
              <div className="text-[10px] uppercase tracking-wider text-slate-500">
                {v.label}
              </div>
            </div>
          ))}
        </div>
      </header>

      <DocumentsFilters formations={(formations ?? []) as any[]} />

      <div className="flex items-center justify-between gap-3">
        <div className="text-sm text-slate-500">
          {docs.length} document{docs.length > 1 ? "s" : ""}
        </div>
        {docs.length > 0 && (
          <a
            href={exportHref}
            className="inline-flex items-center gap-1.5 rounded-lg border border-navy-200 bg-white px-3 py-1.5 text-xs font-semibold text-navy-800 transition-colors hover:bg-navy-50"
          >
            <Download className="h-3.5 w-3.5" /> Export CSV
          </a>
        )}
      </div>

      {docs.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-navy-200 bg-white px-4 py-16 text-center text-sm text-slate-500">
          Aucun document ne correspond à ces filtres.
        </div>
      ) : (
        <div className="space-y-3">
          {docs.map((d) => {
            const k = fileKind(d.file_name);
            return (
              <DocumentRow
                key={d.id}
                id={d.id}
                title={d.title}
                studentName={d.profiles?.full_name || d.profiles?.email || "—"}
                formation={d.formations?.title ?? ""}
                motif={reasonLabel(d.reason, d.custom_reason)}
                kind={k}
                meta={`${k.toUpperCase()} · ${formatBytes(d.size_bytes ?? 0)} · ${fmt(d.created_at)}`}
                status={d.status}
                adminNote={d.admin_note ?? null}
                url={signedMap[d.storage_path]}
                fileName={d.file_name}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}
