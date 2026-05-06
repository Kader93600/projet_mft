import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { FormationBadge } from "@/components/formation/formation-badge";
import { renderMarkdown } from "@/lib/markdown";
import { BookOpen } from "lucide-react";
import { GlossaryFilters } from "./glossary-filters";

// Glossaire = filtré par formations du stagiaire connecté → dynamique
export const dynamic = "force-dynamic";

export default async function GlossairePage({
  searchParams,
}: {
  searchParams?: { q?: string; bloc?: string; formation?: string };
}) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const q = searchParams?.q?.trim() ?? "";
  const blocFilter = searchParams?.bloc ?? "";
  const formationFilter = searchParams?.formation ?? "";

  // Formations où le stagiaire est inscrit (ou liste vide pour invité)
  let enrolledFormationIds: string[] = [];
  let enrolledFormations: any[] = [];
  if (user) {
    const { data: enrollments } = await supabase
      .from("enrollments")
      .select("formation_id, formation:formations(slug, code, title, active)")
      .eq("user_id", user.id)
      .not("formation_id", "is", null)
      .not("status", "in", "(refuse,abandon)");
    enrolledFormationIds = (enrollments ?? [])
      .map((e: any) => e.formation_id as string)
      .filter(Boolean);
    // Dédup pour le dropdown
    const seen = new Set<string>();
    enrolledFormations = (enrollments ?? [])
      .map((e: any) => e.formation)
      .filter((f: any) => {
        if (!f?.slug || seen.has(f.slug)) return false;
        seen.add(f.slug);
        return true;
      })
      .sort((a: any, b: any) => (a.code || "").localeCompare(b.code || ""));
  }

  let query = supabase
    .from("glossary_terms")
    .select(
      "id, term, definition_md, bloc_id, formation_id, synonyms, source, blocs(code, title), formation:formations(slug, code, title)"
    )
    .order("term");

  // Périmètre de base : termes des formations du stagiaire OU transversaux
  // (formation_id IS NULL = applicable à toutes formations).
  // Pour un user sans inscription : seuls les termes transversaux.
  if (enrolledFormationIds.length > 0) {
    query = query.or(
      `formation_id.is.null,formation_id.in.(${enrolledFormationIds.join(",")})`
    );
  } else {
    query = query.is("formation_id", null);
  }

  if (blocFilter) {
    if (blocFilter === "none") query = query.is("bloc_id", null);
    else query = query.eq("bloc_id", Number(blocFilter));
  }
  if (formationFilter) {
    if (formationFilter === "none") {
      query = query.is("formation_id", null);
    } else {
      // On vérifie que la formation demandée fait bien partie des
      // inscriptions du stagiaire (sinon on l'ignore — pas de fuite par
      // bidouillage de l'URL).
      const target = enrolledFormations.find(
        (f: any) => f.slug === formationFilter
      );
      if (target) {
        const { data: f } = await supabase
          .from("formations")
          .select("id")
          .eq("slug", formationFilter)
          .maybeSingle();
        if (f?.id) query = query.eq("formation_id", f.id);
      }
    }
  }
  if (q) {
    // Recherche : ILIKE sur term + definition + synonyms (PostgreSQL accepte
    // l'opérateur cs.{value} pour les arrays). On échappe %_ pour ne pas
    // ouvrir un pattern injection.
    const safe = q.replace(/[%_]/g, "\\$&");
    // Pour chercher dans les synonymes (text[]) on utilise array_to_string
    // côté client n'est pas dispo — on reste sur term + definition (les
    // index trigram pg_trgm rendent la requête rapide même à grande échelle).
    query = query.or(
      `term.ilike.%${safe}%,definition_md.ilike.%${safe}%`
    );
  }

  // Pour les filtres : on liste UNIQUEMENT les blocs qui ont au moins
  // un terme accessible à l'utilisateur dans son périmètre. Sinon, le
  // dropdown propose des blocs vides (titres GOTRM affichés à un Capa
  // par exemple) qui renvoient toujours 0 résultat.
  let scopedTermsScopeQuery = supabase
    .from("glossary_terms")
    .select("bloc_id, blocs(id, code, title)");
  if (enrolledFormationIds.length > 0) {
    scopedTermsScopeQuery = scopedTermsScopeQuery.or(
      `formation_id.is.null,formation_id.in.(${enrolledFormationIds.join(",")})`
    );
  } else {
    scopedTermsScopeQuery = scopedTermsScopeQuery.is("formation_id", null);
  }

  const [{ data: terms }, { data: scopedTermsForBlocs }] = await Promise.all([
    query,
    scopedTermsScopeQuery,
  ]);

  // Dédup des blocs qui ont effectivement des termes pour cet user
  const blocSeen = new Set<number>();
  const blocs = (scopedTermsForBlocs ?? [])
    .filter((t: any) => {
      if (!t.bloc_id || blocSeen.has(t.bloc_id)) return false;
      blocSeen.add(t.bloc_id);
      return !!t.blocs;
    })
    .map((t: any) => t.blocs)
    .sort((a: any, b: any) => (a.code || "").localeCompare(b.code || ""));

  // Y a-t-il au moins un terme transversal (bloc_id NULL) accessible ?
  const hasTransversalBloc = (scopedTermsForBlocs ?? []).some(
    (t: any) => t.bloc_id === null
  );

  // Dropdown formation : uniquement les formations du stagiaire
  const formations = enrolledFormations;

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
          <span className="eyebrow text-gold-700">Référence pédagogique</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Glossaire
        </h1>
        <p className="mt-2 text-slate-600 text-sm">
          {enrolledFormations.length > 1
            ? "Définitions clés des formations auxquelles vous êtes inscrit."
            : enrolledFormations.length === 1
            ? `Définitions clés de la formation « ${enrolledFormations[0].title} ».`
            : "Définitions transversales aux métiers du transport."}
        </p>
      </header>

      <GlossaryFilters
        initialQ={q}
        initialFormation={formationFilter}
        initialBloc={blocFilter}
        formations={formations}
        blocs={blocs}
        hasTransversalBloc={hasTransversalBloc}
      />


      <div className="text-xs text-slate-500">
        {terms?.length ?? 0} terme{(terms?.length ?? 0) > 1 ? "s" : ""}
      </div>

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
                  <div className="flex items-center gap-2 flex-wrap">
                    {t.formation?.slug && (
                      <FormationBadge
                        slug={t.formation.slug}
                        size="xs"
                        icon
                        variant="soft"
                      />
                    )}
                    {t.blocs?.code && (
                      <Badge tone="navy" size="sm">
                        {t.blocs.code}
                      </Badge>
                    )}
                    {!t.bloc_id && !t.formation_id && (
                      <Badge tone="slate" size="sm">
                        Transversal
                      </Badge>
                    )}
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
