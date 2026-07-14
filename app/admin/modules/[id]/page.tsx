import { createClient } from "@/lib/supabase/server";
import { notFound } from "next/navigation";
import Link from "next/link";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ArrowLeft, Plus, ChevronRight, BookOpen } from "lucide-react";
import { ModuleForm } from "../module-form";
import { ModuleDangerZone } from "./module-danger-zone";
import type { Tables } from "@/lib/database.types";

export const dynamic = "force-dynamic";

// ── Formes exactes des lignes lues (miroir des `.select(...)` ci-dessous) ──
type ModuleRow = Tables<"modules"> & {
  blocs: Pick<Tables<"blocs">, "code" | "title"> | null;
};
type LessonRow = Tables<"lessons">;
type FormationOptionRow = Pick<Tables<"formations">, "slug" | "code" | "title">;
type FormationLinkRow = {
  formation: Pick<Tables<"formations">, "slug"> | null;
};

export default async function EditModulePage({
  params,
}: {
  params: { id: string };
}) {
  const supabase = createClient();
  const [
    { data: rawModule },
    { data: rawBlocs },
    { data: rawLessons },
    { data: rawFormations },
    { data: rawCurrentLink },
  ] = await Promise.all([
    supabase.from("modules").select("*, blocs(code, title)").eq("id", params.id).single(),
    supabase.from("blocs").select("*").order("id"),
    supabase.from("lessons").select("*").eq("module_id", params.id).order("order"),
    supabase
      .from("formations")
      .select("slug, code, title")
      .eq("active", true)
      .order("code"),
    supabase
      .from("formation_modules")
      .select("formation:formations(slug)")
      .eq("module_id", params.id)
      .limit(1)
      .maybeSingle(),
  ]);
  const module = rawModule as ModuleRow | null;
  if (!module) notFound();

  const blocs = rawBlocs as Tables<"blocs">[] | null;
  const lessons = rawLessons as LessonRow[] | null;
  const currentLink = rawCurrentLink as FormationLinkRow | null;

  const initialFormationSlug = currentLink?.formation?.slug ?? null;
  const formations = (rawFormations ?? []) as FormationOptionRow[];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Link
          href="/admin/modules"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Retour aux modules
        </Link>
        <Badge tone="navy">{module.blocs?.code}</Badge>
      </div>

      <div>
        <h1 className="font-display text-2xl font-semibold text-navy-950">
          {module.title}
        </h1>
        <p className="text-sm text-slate-500 font-mono mt-1">{module.slug}</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
        {/* Form */}
        <div className="lg:col-span-2">
          <Card>
            <div className="px-6 pt-5 pb-3 border-b border-navy-50">
              <CardTitle className="text-base">Informations du module</CardTitle>
            </div>
            <CardBody>
              <ModuleForm
                blocs={blocs ?? []}
                formations={formations}
                module={module}
                initialFormationSlug={initialFormationSlug}
              />
            </CardBody>
          </Card>

          <Card className="mt-5">
            <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between">
              <CardTitle className="text-base">
                Leçons ({lessons?.length ?? 0})
              </CardTitle>
              <Link href={`/admin/modules/${module.id}/lessons/new`}>
                <Button variant="gold" size="sm">
                  <Plus className="h-4 w-4" /> Nouvelle leçon
                </Button>
              </Link>
            </div>
            {(lessons ?? []).length === 0 ? (
              <CardBody className="py-10 text-center text-sm text-slate-400">
                Aucune leçon. Ajoutez-en une pour démarrer.
              </CardBody>
            ) : (
              <div className="divide-y divide-navy-50">
                {lessons!.map((l, i) => (
                  <Link
                    key={l.id}
                    href={`/admin/modules/${module.id}/lessons/${l.id}`}
                    className="flex items-center gap-3 px-6 py-3.5 hover:bg-navy-50/30 group"
                  >
                    <div className="h-8 w-8 rounded-lg bg-navy-50 text-navy-700 flex items-center justify-center text-xs font-semibold">
                      {i + 1}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-medium text-sm text-navy-900 group-hover:text-gold-700 truncate">
                        {l.title}
                      </div>
                      <div className="text-xs text-slate-500 font-mono truncate">
                        {l.slug}
                      </div>
                    </div>
                    <ChevronRight className="h-4 w-4 text-slate-400 group-hover:text-gold-700" />
                  </Link>
                ))}
              </div>
            )}
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-5">
          <Card>
            <CardBody>
              <div className="flex items-center gap-3">
                <div className="h-10 w-10 rounded-xl bg-navy-50 flex items-center justify-center">
                  <BookOpen className="h-5 w-5 text-navy-700" />
                </div>
                <div>
                  <div className="text-xs text-slate-500">Leçons</div>
                  <div className="font-display text-xl font-semibold text-navy-900">
                    {lessons?.length ?? 0}
                  </div>
                </div>
              </div>
            </CardBody>
          </Card>
          <ModuleDangerZone moduleId={module.id} />
        </div>
      </div>
    </div>
  );
}
