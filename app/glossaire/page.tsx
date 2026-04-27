import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { renderMarkdown } from "@/lib/markdown";
import { BookOpen, Search } from "lucide-react";

// Glossaire = lecture publique → ISR 5 min suffit (les recherches q= restent dynamiques côté Next)
export const revalidate = 300;

export default async function GlossairePage({
  searchParams,
}: {
  searchParams?: { q?: string; bloc?: string };
}) {
  const supabase = createClient();
  const q = searchParams?.q?.trim() ?? "";
  const blocFilter = searchParams?.bloc ?? "";

  let query = supabase
    .from("glossary_terms")
    .select("id, term, definition_md, bloc_id, synonyms, source, blocs(code, title)")
    .order("term");

  if (blocFilter) {
    if (blocFilter === "none") query = query.is("bloc_id", null);
    else query = query.eq("bloc_id", Number(blocFilter));
  }
  if (q) {
    // Recherche simple : ILIKE sur term + synonyms via OR ; FTS pourrait remplacer
    query = query.or(
      `term.ilike.%${q}%,definition_md.ilike.%${q}%`
    );
  }

  const [{ data: terms }, { data: blocs }] = await Promise.all([
    query,
    supabase.from("blocs").select("id, code, title").order("order"),
  ]);

  // Regroupement alphabétique
  const grouped: Record<string, any[]> = {};
  (terms ?? []).forEach((t: any) => {
    const letter = (t.term?.[0] ?? "?").toUpperCase();
    if (!grouped[letter]) grouped[letter] = [];
    grouped[letter].push(t);
  });
  const letters = Object.keys(grouped).sort();

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <header>
        <div className="flex items-center gap-2">
          <BookOpen className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Référence RNCP 40990</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Glossaire
        </h1>
        <p className="mt-2 text-slate-600 text-sm">
          Définitions clés du métier de gestionnaire des opérations de transport.
        </p>
      </header>

      <form className="flex flex-wrap gap-2 items-center">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <input
            name="q"
            defaultValue={q}
            placeholder="Rechercher un terme, une définition…"
            className="h-10 w-full rounded-xl border border-navy-200 bg-white pl-9 pr-3 text-sm text-navy-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-navy-600/15 focus:border-navy-600"
          />
        </div>
        <select
          name="bloc"
          defaultValue={blocFilter}
          className="h-10 rounded-xl border border-navy-200 bg-white px-3 text-sm text-navy-900"
        >
          <option value="">Tous les blocs</option>
          {blocs?.map((b: any) => (
            <option key={b.id} value={b.id}>
              {b.code} — {b.title}
            </option>
          ))}
          <option value="none">Transversal</option>
        </select>
        <button
          type="submit"
          className="h-10 px-4 rounded-xl bg-navy-900 text-white text-sm font-medium hover:bg-navy-800"
        >
          Filtrer
        </button>
        {(q || blocFilter) && (
          <Link
            href="/glossaire"
            className="h-10 inline-flex items-center px-3 rounded-xl text-sm text-slate-600 hover:text-navy-900"
          >
            Réinitialiser
          </Link>
        )}
      </form>

      {(!terms || terms.length === 0) && (
        <Card>
          <CardBody className="py-10 text-center">
            <p className="text-sm text-slate-500">
              {q || blocFilter
                ? "Aucun terme ne correspond à votre recherche."
                : "Le glossaire est vide pour le moment."}
            </p>
          </CardBody>
        </Card>
      )}

      {letters.length > 0 && (
        <nav className="flex flex-wrap gap-1.5 text-xs">
          {letters.map((l) => (
            <a
              key={l}
              href={`#letter-${l}`}
              className="h-7 w-7 inline-flex items-center justify-center rounded-lg border border-navy-100 text-navy-700 hover:bg-navy-50 font-semibold"
            >
              {l}
            </a>
          ))}
        </nav>
      )}

      {letters.map((l) => (
        <section key={l} id={`letter-${l}`} className="space-y-3">
          <h2 className="font-display text-xl font-semibold text-navy-900">{l}</h2>
          {grouped[l].map((t: any) => (
            <Card key={t.id}>
              <CardBody>
                <div className="flex items-start justify-between gap-3 flex-wrap">
                  <h3 className="font-display text-lg font-semibold text-navy-900">
                    {t.term}
                  </h3>
                  <div className="flex items-center gap-2">
                    {t.blocs?.code && <Badge tone="navy" size="sm">{t.blocs.code}</Badge>}
                    {!t.bloc_id && <Badge tone="slate" size="sm">Transversal</Badge>}
                  </div>
                </div>
                {t.synonyms?.length > 0 && (
                  <p className="mt-1 text-xs text-slate-500 italic">
                    aussi : {t.synonyms.join(", ")}
                  </p>
                )}
                <div
                  className="prose-lesson text-sm mt-3"
                  dangerouslySetInnerHTML={{ __html: renderMarkdown(t.definition_md) }}
                />
                {t.source && (
                  <p className="mt-3 text-[11px] text-slate-400">Source : {t.source}</p>
                )}
              </CardBody>
            </Card>
          ))}
        </section>
      ))}
    </div>
  );
}
