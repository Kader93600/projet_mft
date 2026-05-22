import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { renderMarkdown } from "@/lib/markdown";
import {
  FileSignature,
  Gavel,
  BookOpen,
  CheckCircle2,
  Download,
  Target,
  ArrowRight,
} from "lucide-react";

export const dynamic = "force-dynamic";

const ICONS: any = { convention: FileSignature, reglement: Gavel, livret: BookOpen };
const LABELS: any = {
  convention: "Convention de formation",
  reglement: "Règlement intérieur",
  livret: "Livret d'accueil",
};

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

  const [{ data: rows }, { data: placement }] = await Promise.all([
    supabase
      .from("document_acceptances")
      .select(
        "id, accepted_at, document_version, document_type, onboarding_documents(id, title, content_md, type)"
      )
      .eq("user_id", user.id)
      .order("accepted_at", { ascending: false }),
    supabase
      .from("placement_results")
      .select("taken_at")
      .eq("user_id", user.id)
      .maybeSingle(),
  ]);

  const placementTakenAt = placement?.taken_at as string | undefined;

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
          {(rows ?? []).length > 0 && (
            <a
              href="/api/me/attestation-signatures"
              target="_blank"
              className="inline-flex items-center gap-1.5 rounded-lg border border-navy-200 bg-white px-3 py-1.5 text-sm font-medium text-navy-800 hover:bg-navy-50 transition-colors"
            >
              <Download className="h-4 w-4" /> Attestation d'acceptation (PDF)
            </a>
          )}
        </div>
        {(rows ?? []).length === 0 && (
          <Card>
            <CardBody className="text-center py-10 text-slate-500 text-sm">
              Aucun document signé pour le moment.
            </CardBody>
          </Card>
        )}
        {(rows ?? []).map((r: any) => {
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
