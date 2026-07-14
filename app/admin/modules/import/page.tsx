// =====================================================================
// /admin/modules/import
//
// Workflow d'import d'un livret de cours PDF → chapitres + leçons.
// Strictement aligné sur le pattern de /admin/banque-questions/import
// pour la cohérence UX (3 étapes : Source → Relecture → Inséré).
// =====================================================================

import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { ArrowLeft, BookOpen } from "lucide-react";
import { CourseImportFlow } from "./import-flow";

export const dynamic = "force-dynamic";

export default async function CourseImportPage() {
  const supabase = await createClient();

  const [{ data: formations }, { data: blocs }] = await Promise.all([
    supabase
      .from("formations")
      .select("id, slug, code, title")
      .eq("active", true)
      .order("code"),
    supabase
      .from("blocs")
      .select("id, code, title")
      .order("order"),
  ]);

  const formationsOpts = (formations ?? []).map((f: any) => ({
    slug: f.slug,
    code: f.code,
    title: f.title,
  }));
  const blocsOpts = (blocs ?? []).map((b: any) => ({
    code: b.code,
    title: b.title,
  }));

  return (
    <div className="space-y-8">
      <header>
        <Link
          href="/admin/modules"
          className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-navy-900"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Retour aux modules
        </Link>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Importer un livret de cours
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Uploadez un PDF de cours (livret de formation MFT) pour le
          transformer en chapitres et leçons éditables. Le parser détecte
          automatiquement la structure <code>CHAPITRE N — Titre</code> puis
          les sous-sections <code>N.M — …</code>.
        </p>
      </header>

      <Card>
        <CardBody>
          <div className="flex items-start gap-3 mb-4">
            <div className="h-9 w-9 rounded-xl bg-signal-100 inline-flex items-center justify-center shrink-0">
              <BookOpen className="h-4 w-4 text-signal-700" />
            </div>
            <div>
              <CardTitle>Nouvel import</CardTitle>
              <p className="text-[12.5px] text-slate-500 mt-0.5">
                Chaque chapitre devient un module rattaché au bloc choisi.
                Chaque sous-section devient une leçon avec contenu HTML
                éditable dans l'éditeur riche.
              </p>
            </div>
          </div>
          <CourseImportFlow formations={formationsOpts} blocs={blocsOpts} />
        </CardBody>
      </Card>
    </div>
  );
}
