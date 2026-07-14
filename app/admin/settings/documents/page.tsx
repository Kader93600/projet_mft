import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { DocumentEditor } from "./document-editor";
import { AddDocument } from "./add-document";
import { FileSignature, Gavel, BookOpen } from "lucide-react";

export const dynamic = "force-dynamic";

const ICONS: any = {
  convention: FileSignature,
  reglement: Gavel,
  livret: BookOpen,
};
const LABELS: any = {
  convention: "Convention de formation",
  reglement: "Règlement intérieur",
  livret: "Livret d'accueil",
};

export default async function DocumentsPage() {
  const supabase = await createClient();
  const { data: docs } = await supabase
    .from("onboarding_documents")
    .select("*")
    .order("type");

  const stats: Record<string, { accepted: number }> = {};
  if (docs) {
    for (const d of docs) {
      const { count } = await supabase
        .from("document_acceptances")
        .select("*", { count: "exact", head: true })
        .eq("document_id", d.id);
      stats[d.id] = { accepted: count ?? 0 };
    }
  }

  return (
    <div className="space-y-8">
      <header className="flex items-start justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Qualiopi · Entrée en formation</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Documents d'accueil stagiaire
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Documents présentés au stagiaire lors de son entrée en formation
            (convention, règlement intérieur, livret d'accueil, et tout document
            que vous ajoutez). Chaque document doit être publié pour être
            opposable ; les acceptations sont horodatées et immuables.
          </p>
        </div>
        <div className="shrink-0 pt-1">
          <AddDocument />
        </div>
      </header>

      <div className="space-y-6">
        {(docs ?? []).map((d: any) => {
          const Icon = ICONS[d.type] ?? FileSignature;
          return (
            <Card key={d.id}>
              <div className="px-6 pt-5 pb-4 border-b border-navy-50 flex items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
                    <Icon className="h-4 w-4" />
                  </div>
                  <div>
                    <CardTitle className="text-base">
                      {LABELS[d.type] || d.title}
                    </CardTitle>
                    <div className="text-xs text-slate-500 mt-0.5">
                      Version {d.version} · {stats[d.id]?.accepted ?? 0} acceptation
                      {(stats[d.id]?.accepted ?? 0) > 1 ? "s" : ""}
                    </div>
                  </div>
                </div>
                <Badge tone={d.published ? "success" : "slate"} size="sm">
                  {d.published ? "Publié" : "Brouillon"}
                </Badge>
              </div>
              <CardBody>
                <DocumentEditor doc={d} />
              </CardBody>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
