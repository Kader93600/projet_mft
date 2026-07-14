import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { BookOpen, ClipboardCheck, FileText, Library, Search } from "lucide-react";

export const dynamic = "force-dynamic";

const ICONS = {
  module: BookOpen,
  lesson: FileText,
  quiz: ClipboardCheck,
  glossary: Library,
} as const;

const KIND_LABEL: Record<string, string> = {
  module: "Cours",
  lesson: "Leçons",
  quiz: "Exercices & examens",
  glossary: "Glossaire",
};

export default async function RecherchePage(
  props: {
    searchParams: Promise<{ q?: string }>;
  }
) {
  const searchParams = await props.searchParams;
  const q = (searchParams.q ?? "").trim();
  const supabase = await createClient();

  let results: any[] = [];
  if (q.length >= 2) {
    const { data } = await supabase.rpc("global_search", {
      q,
      max_per_kind: 15,
    });
    results = data ?? [];

    // Tracking : la recherche est explicite (page dédiée), on logue.
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (user) {
      await supabase.from("search_logs").insert({
        user_id: user.id,
        query: q,
        results_count: results.length,
      });
    }
  }

  const grouped = results.reduce<Record<string, any[]>>((acc, r) => {
    (acc[r.kind] ??= []).push(r);
    return acc;
  }, {});

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Recherche globale</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          {q ? `Résultats pour "${q}"` : "Rechercher"}
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Cherchez dans les modules, leçons, quiz et glossaire. Astuce :{" "}
          <kbd className="px-1.5 py-0.5 rounded bg-white border text-xs font-mono">⌘K</kbd>{" "}
          ouvre la palette de recherche depuis n'importe où.
        </p>
      </header>

      <form method="get" className="max-w-xl">
        <div className="relative">
          <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            name="q"
            defaultValue={q}
            placeholder="Un module, une leçon, un terme…"
            className="pl-9"
            autoFocus
          />
        </div>
      </form>

      {q.length < 2 && (
        <Card>
          <CardBody className="text-sm text-slate-500">
            Tapez au moins 2 caractères pour lancer la recherche.
          </CardBody>
        </Card>
      )}

      {q.length >= 2 && results.length === 0 && (
        <Card>
          <CardBody className="text-sm text-slate-500">
            Aucun résultat. Essayez avec un autre mot-clé ou vérifiez l'orthographe.
          </CardBody>
        </Card>
      )}

      {(["module", "lesson", "quiz", "glossary"] as const).map((kind) => {
        const items = grouped[kind];
        if (!items || items.length === 0) return null;
        const Icon = ICONS[kind];
        return (
          <section key={kind}>
            <div className="flex items-center gap-2 mb-4">
              <Icon className="h-4 w-4 text-gold-600" />
              <h2 className="font-display text-xl font-semibold text-navy-900">
                {KIND_LABEL[kind]}
              </h2>
              <span className="text-xs text-slate-500">({items.length})</span>
            </div>
            <div className="grid md:grid-cols-2 gap-3">
              {items.map((r: any) => (
                <Link key={`${r.kind}-${r.id}`} href={r.url} className="group">
                  <Card className="h-full group-hover:-translate-y-0.5 transition-transform">
                    <CardBody>
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            {r.bloc_code && r.bloc_code !== "—" && (
                              <Badge size="sm">{r.bloc_code}</Badge>
                            )}
                          </div>
                          <div className="font-semibold text-navy-900 truncate group-hover:text-gold-700">
                            {r.title}
                          </div>
                          <div className="text-sm text-slate-600 mt-1 line-clamp-2">
                            {r.subtitle}
                          </div>
                        </div>
                      </div>
                    </CardBody>
                  </Card>
                </Link>
              ))}
            </div>
          </section>
        );
      })}
    </div>
  );
}
