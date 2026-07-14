import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { renderMarkdown } from "@/lib/markdown";
import { getPendingDocuments } from "@/lib/onboarding-docs";
import { PendingDocs } from "./pending-docs";
import { DocumentUploader } from "./document-uploader";
import { DeleteDocButton } from "./delete-doc-button";
import {
  reasonLabel,
  fileKind,
  formatBytes,
  DOC_STATUS,
  type FileKind,
} from "@/lib/student-documents";
import {
  FileSignature,
  Gavel,
  BookOpen,
  CheckCircle2,
  Download,
  Target,
  ArrowRight,
  FileText,
  FileSpreadsheet,
  Image as ImageIcon,
  File as FileIcon,
  Eye,
  type LucideIcon,
} from "lucide-react";
import type { Tables } from "@/lib/database.types";

const KIND_ICON: Record<FileKind, { Icon: LucideIcon; cls: string }> = {
  pdf: { Icon: FileText, cls: "bg-rose-100 text-rose-600" },
  word: { Icon: FileText, cls: "bg-sky-100 text-sky-700" },
  excel: { Icon: FileSpreadsheet, cls: "bg-emerald-100 text-emerald-700" },
  image: { Icon: ImageIcon, cls: "bg-violet-100 text-violet-700" },
  other: { Icon: FileIcon, cls: "bg-slate-100 text-slate-600" },
};

export const dynamic = "force-dynamic";

const ICONS: Record<string, LucideIcon> = {
  convention: FileSignature,
  reglement: Gavel,
  livret: BookOpen,
};
const LABELS: Record<string, string> = {
  convention: "Convention de formation",
  reglement: "Règlement intérieur",
  livret: "Livret d'accueil",
};

/** Ligne `document_acceptances` + document d'onboarding embarqué (cf. select). */
type AcceptanceRow = Pick<
  Tables<"document_acceptances">,
  "id" | "accepted_at" | "document_version" | "document_type"
> & {
  onboarding_documents: Pick<
    Tables<"onboarding_documents">,
    "id" | "title" | "content_md" | "type"
  > | null;
};

/** Ligne `student_documents` (cf. select). */
type StudentDocRow = Pick<
  Tables<"student_documents">,
  | "id"
  | "title"
  | "reason"
  | "custom_reason"
  | "storage_path"
  | "file_name"
  | "mime_type"
  | "size_bytes"
  | "status"
  | "created_at"
>;

function fmt(d: string) {
  return new Date(d).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default async function MesDocumentsPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: rows }, { data: placement }, { data: myDocs }] =
    await Promise.all([
      supabase
        .from("document_acceptances")
        .select(
          "id, accepted_at, document_version, document_type, onboarding_documents(id, title, content_md, type)"
        )
        .eq("user_id", user.id)
        .order("accepted_at", { ascending: false })
        // Client non typé globalement : supabase-js infère l'embed to-one
        // comme un tableau. On rétablit la vraie forme (objet | null).
        .overrideTypes<AcceptanceRow[], { merge: false }>(),
      supabase
        .from("placement_results")
        .select("taken_at")
        .eq("user_id", user.id)
        .maybeSingle(),
      supabase
        .from("student_documents")
        .select(
          "id, title, reason, custom_reason, storage_path, file_name, mime_type, size_bytes, status, created_at"
        )
        .eq("user_id", user.id)
        .order("created_at", { ascending: false }),
    ]);

  // URLs signées (1 h) pour consulter / télécharger les documents importés.
  const docs = (myDocs ?? []) as StudentDocRow[];
  const acceptances = rows ?? [];
  const signedMap: Record<string, string> = {};
  if (docs.length) {
    const admin = createAdminClient();
    const { data: signed } = await admin.storage
      .from("student-documents")
      .createSignedUrls(
        docs.map((d) => d.storage_path),
        60 * 60
      );
    (signed ?? []).forEach((s, i) => {
      if (s?.signedUrl) signedMap[docs[i].storage_path] = s.signedUrl;
    });
  }

  const placementTakenAt = (
    placement as Pick<Tables<"placement_results">, "taken_at"> | null
  )?.taken_at;

  // Documents publiés non encore signés (présentés hors onboarding).
  const pending = await getPendingDocuments(supabase, user.id);
  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name")
    .eq("id", user.id)
    .maybeSingle();

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Espace personnel</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Mes documents de formation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Retrouvez les documents que vous avez acceptés lors de votre entrée
          en formation, avec la date et l'heure de signature électronique.
        </p>
      </header>

      {pending.length > 0 && (
        <PendingDocs docs={pending} fullName={profile?.full_name ?? ""} />
      )}

      {/* ─── Documents importés par le stagiaire ─────────────────────── */}
      <section className="space-y-4">
        <div>
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Mes documents importés
          </h2>
          <p className="mt-1 text-sm text-slate-600">
            Ajoutez vos justificatifs, attestations, rapports… Ils sont
            transmis automatiquement à l'administration.
          </p>
        </div>

        <DocumentUploader />

        {docs.length > 0 ? (
          <div className="grid gap-4 sm:grid-cols-2">
            {docs.map((d) => {
              const k = fileKind(d.file_name);
              const KI = KIND_ICON[k];
              const st =
                DOC_STATUS[d.status as keyof typeof DOC_STATUS] ??
                DOC_STATUS.recu;
              const url = signedMap[d.storage_path];
              return (
                <Card
                  key={d.id}
                  className="transition-[transform,box-shadow] duration-200 ease-premium hover:-translate-y-0.5 hover:shadow-raised motion-reduce:hover:translate-y-0"
                >
                  <CardBody className="space-y-3">
                    <div className="flex items-start gap-3">
                      <span
                        className={`inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${KI.cls}`}
                      >
                        <KI.Icon className="h-5 w-5" />
                      </span>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-start justify-between gap-2">
                          <h3 className="truncate font-semibold text-navy-900">
                            {d.title}
                          </h3>
                          <Badge tone={st.tone} size="sm">
                            {st.label}
                          </Badge>
                        </div>
                        <p className="mt-0.5 text-xs text-slate-500">
                          {reasonLabel(d.reason, d.custom_reason)} ·{" "}
                          {k.toUpperCase()} · {formatBytes(d.size_bytes ?? 0)}
                        </p>
                        <p className="mt-0.5 text-xs text-slate-400">
                          Importé le {fmt(d.created_at)}
                        </p>
                      </div>
                    </div>
                    <div className="flex flex-wrap items-center gap-2">
                      {url && (
                        <a
                          href={url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center gap-1 rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-xs font-medium text-navy-800 transition-colors hover:bg-navy-50"
                        >
                          <Eye className="h-3.5 w-3.5" /> Voir
                        </a>
                      )}
                      {url && (
                        <a
                          href={`${url}&download=${encodeURIComponent(d.file_name)}`}
                          className="inline-flex items-center gap-1 rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-xs font-medium text-navy-800 transition-colors hover:bg-navy-50"
                        >
                          <Download className="h-3.5 w-3.5" /> Télécharger
                        </a>
                      )}
                      <DeleteDocButton id={d.id} />
                    </div>
                  </CardBody>
                </Card>
              );
            })}
          </div>
        ) : (
          <Card>
            <CardBody className="py-8 text-center text-sm text-slate-500">
              Aucun document importé pour le moment.
            </CardBody>
          </Card>
        )}
      </section>

      <div className="grid md:grid-cols-2 gap-4">
        <a
          href="/admin/reports/export/programme"
          target="_blank"
          className="group"
        >
          <Card className="transition-all group-hover:shadow-raised">
            <CardBody className="flex items-start gap-4">
              <div className="h-11 w-11 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
                <BookOpen className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <CardTitle className="text-base mb-1">
                  Programme de formation
                </CardTitle>
                <p className="text-sm text-slate-600">
                  Contenu officiel de la formation (objectifs, méthodes,
                  évaluation).
                </p>
              </div>
              <Download className="h-4 w-4 text-slate-400 mt-1" />
            </CardBody>
          </Card>
        </a>

        <a href="/positionnement" className="group">
          <Card className="transition-all group-hover:shadow-raised">
            <CardBody className="flex items-start gap-4">
              <div className="h-11 w-11 rounded-xl bg-gold-50 text-gold-800 flex items-center justify-center">
                <Target className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <CardTitle className="text-base">
                    Test de positionnement
                  </CardTitle>
                  {placementTakenAt && (
                    <Badge tone="success" size="sm">
                      <CheckCircle2 className="h-3 w-3" /> Passé
                    </Badge>
                  )}
                </div>
                <p className="text-sm text-slate-600">
                  {placementTakenAt
                    ? `Passé le ${fmt(placementTakenAt)} — consultez votre profil et votre recommandation.`
                    : "Évaluation initiale pour adapter votre parcours aux blocs où vous avez le plus à apprendre."}
                </p>
              </div>
              <ArrowRight className="h-4 w-4 text-slate-400 mt-1 transition-transform group-hover:translate-x-0.5" />
            </CardBody>
          </Card>
        </a>
      </div>

      <div className="space-y-4">
        <div className="flex items-center justify-between gap-4 flex-wrap">
          <h2 className="font-display text-xl font-semibold text-navy-900">
            Documents signés
          </h2>
          {acceptances.length > 0 && (
            <a
              href="/api/me/attestation-signatures"
              target="_blank"
              className="inline-flex items-center gap-1.5 rounded-lg border border-navy-200 bg-white px-3 py-1.5 text-sm font-medium text-navy-800 hover:bg-navy-50 transition-colors"
            >
              <Download className="h-4 w-4" /> Attestation d'acceptation (PDF)
            </a>
          )}
        </div>
        {acceptances.length === 0 && (
          <Card>
            <CardBody className="text-center py-10 text-slate-500 text-sm">
              Aucun document signé pour le moment.
            </CardBody>
          </Card>
        )}
        {acceptances.map((r) => {
          const Icon = ICONS[r.document_type] ?? FileSignature;
          return (
            <Card key={r.id}>
              <div className="px-6 pt-5 pb-4 border-b border-navy-50 flex items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
                    <Icon className="h-4 w-4" />
                  </div>
                  <div>
                    <CardTitle className="text-base">
                      {LABELS[r.document_type] || r.onboarding_documents?.title}
                    </CardTitle>
                    <div className="text-xs text-slate-500 mt-0.5">
                      Version {r.document_version} · Signé le {fmt(r.accepted_at)}
                    </div>
                  </div>
                </div>
                <Badge tone="success" size="sm">
                  <CheckCircle2 className="h-3 w-3" /> Signé
                </Badge>
              </div>
              <CardBody>
                <details className="group">
                  <summary className="cursor-pointer text-sm text-navy-900 font-medium hover:text-gold-700 list-none">
                    <span className="group-open:hidden">
                      Afficher le contenu du document
                    </span>
                    <span className="hidden group-open:inline">
                      Masquer le contenu
                    </span>
                  </summary>
                  <div
                    className="prose-lesson text-sm mt-4 max-h-[420px] overflow-y-auto bg-slate-50/60 p-4 rounded-xl"
                    dangerouslySetInnerHTML={{
                      __html: renderMarkdown(
                        r.onboarding_documents?.content_md ?? ""
                      ),
                    }}
                  />
                </details>
              </CardBody>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
