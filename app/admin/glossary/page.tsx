import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { GlossaryEditor } from "./glossary-editor";
import { BookOpen } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AdminGlossaryPage() {
  const supabase = createClient();
  const [{ data: terms }, { data: blocs }] = await Promise.all([
    supabase
      .from("glossary_terms")
      .select("id, term, definition_md, bloc_id, synonyms, source, blocs(code)")
      .order("term"),
    supabase.from("blocs").select("id, code, title").order("order"),
  ]);

  return (
    <div className="space-y-8">
      <header>
        <div className="flex items-center gap-2">
          <BookOpen className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Référentiel</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Glossaire
        </h1>
        <p className="mt-2 text-slate-600 text-sm">
          Gérez les définitions affichées aux stagiaires via `/glossaire`.
        </p>
      </header>

      <Card>
        <CardBody>
          <h2 className="font-display text-lg font-semibold text-navy-900 mb-4">
            Nouveau terme
          </h2>
          <GlossaryEditor blocs={blocs ?? []} mode="create" />
        </CardBody>
      </Card>

      <section className="space-y-4">
        <h2 className="font-display text-lg font-semibold text-navy-900">
          Termes ({terms?.length ?? 0})
        </h2>
        {(!terms || terms.length === 0) && (
          <Card>
            <CardBody className="py-10 text-center text-slate-500 text-sm">
              Aucun terme pour l'instant.
            </CardBody>
          </Card>
        )}
        {terms?.map((t: any) => (
          <Card key={t.id}>
            <CardBody>
              <div className="flex items-center gap-2 mb-3 flex-wrap">
                {t.blocs?.code ? (
                  <Badge tone="navy" size="sm">{t.blocs.code}</Badge>
                ) : (
                  <Badge tone="slate" size="sm">Transversal</Badge>
                )}
              </div>
              <GlossaryEditor blocs={blocs ?? []} mode="edit" term={t} />
            </CardBody>
          </Card>
        ))}
      </section>
    </div>
  );
}
