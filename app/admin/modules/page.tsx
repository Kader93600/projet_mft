import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { FormationBadge } from "@/components/formation/formation-badge";
import { Button } from "@/components/ui/button";
import { blocTone } from "@/lib/utils";
import {
  Plus,
  ChevronRight,
  BookOpen,
  AlertCircle,
  GraduationCap,
} from "lucide-react";
import { getAuthorizedFormationSlugs } from "@/lib/admin-guard";

export const dynamic = "force-dynamic";

export default async function AdminModules() {
  const supabase = createClient();

  // Détermine le scope : admin → toutes formations, trainer → ses habilitations
  const { slugs, isTrainerOnly } = await getAuthorizedFormationSlugs();

  const [
    { data: modules },
    { data: lessonCounts },
    { data: formationModules },
  ] = await Promise.all([
    supabase
      .from("modules")
      .select("*, blocs(code, title)")
      .order("bloc_id")
      .order("order"),
    supabase.from("lessons").select("module_id"),
    supabase
      .from("formation_modules")
      .select("module_id, formation:formations(slug, code)"),
  ]);

  const counts = new Map<string, number>();
  (lessonCounts ?? []).forEach((l: any) => {
    counts.set(l.module_id, (counts.get(l.module_id) ?? 0) + 1);
  });

  const formationByModule = new Map<string, string>();
  (formationModules ?? []).forEach((fm: any) => {
    if (fm.formation?.slug && !formationByModule.has(fm.module_id)) {
      formationByModule.set(fm.module_id, fm.formation.slug);
    }
  });

  // Filtre trainer : ne garder que les modules liés à une formation autorisée
  const allowed = new Set(slugs);
  const visibleModules = (modules ?? []).filter((m: any) => {
    if (!isTrainerOnly) return true;
    const slug = formationByModule.get(m.id);
    return slug ? allowed.has(slug) : false;
  });

  // Modules orphelins (sans formation rattachée) — admins seulement
  const orphans = isTrainerOnly
    ? []
    : (modules ?? []).filter((m: any) => !formationByModule.has(m.id));

  return (
    <div className="space-y-8">
      <header className="flex items-end justify-between gap-4 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700">Administration</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Modules & leçons
          </h1>
          <p className="mt-2 text-slate-600">
            {visibleModules.length} module{visibleModules.length > 1 ? "s" : ""}
            {isTrainerOnly && (
              <>
                {" "}sur {slugs.length} formation
                {slugs.length > 1 ? "s" : ""} habilité
                {slugs.length > 1 ? "es" : "e"}
              </>
            )}
            {!isTrainerOnly && " · créez, éditez et organisez le contenu pédagogique."}
          </p>
        </div>
        <Link href="/admin/modules/new">
          <Button variant="gold">
            <Plus className="h-4 w-4" /> Nouveau module
          </Button>
        </Link>
      </header>

      {/* Bandeau formateur : rappel du scope */}
      {isTrainerOnly && (
        <div className="rounded-2xl bg-emerald-50 border border-emerald-200 p-4 flex items-start gap-3">
          <GraduationCap className="h-5 w-5 text-emerald-700 shrink-0 mt-0.5" />
          <div className="text-sm text-emerald-900 flex-1">
            <strong>Espace formateur</strong> — vous voyez et modifiez
            uniquement les modules des formations sur lesquelles vous êtes
            habilité ({slugs.join(", ") || "aucune"}). Pour étendre votre
            périmètre, contactez votre administrateur.
          </div>
        </div>
      )}

      {orphans.length > 0 && (
        <div className="rounded-2xl bg-amber-50 border border-amber-200 p-4 flex items-start gap-3">
          <AlertCircle className="h-5 w-5 text-amber-700 shrink-0 mt-0.5" />
          <div className="text-sm text-amber-900 flex-1">
            <strong>
              {orphans.length} module{orphans.length > 1 ? "s" : ""} sans
              formation associée
            </strong>{" "}
            — chaque module doit être rattaché à une formation pour apparaître
            dans le parcours pédagogique des stagiaires. Cliquez sur le module
            concerné pour l'affecter.
          </div>
        </div>
      )}

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Formation</th>
                <th className="text-left px-5 py-3 font-semibold">Bloc</th>
                <th className="text-left px-5 py-3 font-semibold">Module</th>
                <th className="text-left px-5 py-3 font-semibold">Leçons</th>
                <th className="text-left px-5 py-3 font-semibold">Durée</th>
                <th className="text-left px-5 py-3 font-semibold">Niveau</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {visibleModules.map((m: any) => (
                <tr
                  key={m.id}
                  className="border-t border-navy-50 hover:bg-navy-50/30 group"
                >
                  <td className="px-5 py-3.5">
                    {formationByModule.has(m.id) ? (
                      <FormationBadge
                        slug={formationByModule.get(m.id)}
                        size="sm"
                        icon
                      />
                    ) : (
                      <span className="text-xs text-slate-400">— Aucune —</span>
                    )}
                  </td>
                  <td className="px-5 py-3.5">
                    <Badge tone={blocTone(m.blocs?.code)} size="sm">
                      {m.blocs?.code}
                    </Badge>
                  </td>
                  <td className="px-5 py-3.5">
                    <Link
                      href={`/admin/modules/${m.id}`}
                      className="font-medium text-navy-900 group-hover:text-gold-700"
                    >
                      {m.title}
                    </Link>
                    {m.slug && (
                      <div className="text-[11px] text-slate-400 mt-0.5 truncate max-w-xs">
                        /{m.slug}
                      </div>
                    )}
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="inline-flex items-center gap-1 text-slate-600 text-xs">
                      <BookOpen className="h-3.5 w-3.5" />
                      {counts.get(m.id) ?? 0}
                    </span>
                  </td>
                  <td className="px-5 py-3.5 text-slate-600">{m.duration_min} min</td>
                  <td className="px-5 py-3.5 text-slate-600 capitalize">{m.difficulty}</td>
                  <td className="px-5 py-3.5 text-right">
                    <Link
                      href={`/admin/modules/${m.id}`}
                      className="inline-flex items-center gap-1 text-xs text-navy-700 group-hover:text-gold-700"
                    >
                      Éditer <ChevronRight className="h-3.5 w-3.5" />
                    </Link>
                  </td>
                </tr>
              ))}
              {visibleModules.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-5 py-16 text-center text-slate-400">
                    {isTrainerOnly
                      ? "Aucun module sur vos formations habilitées."
                      : "Aucun module. Créez-en un pour démarrer."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
