import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { blocTone } from "@/lib/utils";
import { Clock, ArrowRight, Layers } from "lucide-react";

export default async function ModulesPage() {
  const supabase = createClient();
  const { data: blocs } = await supabase.from("blocs").select("*").order("order");
  const { data: modules } = await supabase.from("modules").select("*").order("order");

  return (
    <div className="space-y-12">
      <header>
        <span className="eyebrow text-gold-700">Parcours RNCP 40990</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Modules de formation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Une architecture pédagogique organisée par bloc de compétences, alignée
          sur le référentiel officiel du jury.
        </p>
      </header>

      {blocs?.map((bloc) => {
        const mods = modules?.filter((m) => m.bloc_id === bloc.id) || [];
        const tone = blocTone(bloc.code);
        return (
          <section key={bloc.id} className="space-y-5">
            <div className="flex items-start justify-between gap-4">
              <div className="max-w-2xl">
                <div className="flex items-center gap-2">
                  <Badge tone={tone} size="sm">
                    {bloc.code}
                  </Badge>
                  <span className="text-xs text-slate-500 inline-flex items-center gap-1">
                    <Layers className="h-3 w-3" /> {mods.length} modules
                  </span>
                </div>
                <h2 className="mt-2 font-display text-2xl font-semibold text-navy-900 tracking-tight">
                  {bloc.title}
                </h2>
                {bloc.description && (
                  <p className="mt-1.5 text-sm text-slate-600">{bloc.description}</p>
                )}
              </div>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
              {mods.map((m) => (
                <Link key={m.id} href={`/modules/${m.slug}`} className="group">
                  <Card className="h-full transition-all group-hover:-translate-y-0.5 group-hover:shadow-raised">
                    <CardBody className="flex flex-col h-full">
                      <div className="flex items-start justify-between gap-3">
                        <Badge tone={tone} size="sm">
                          {bloc.code}
                        </Badge>
                        <span className="inline-flex items-center gap-1 text-xs text-slate-500">
                          <Clock className="h-3 w-3" /> {m.duration_min} min
                        </span>
                      </div>
                      <h3 className="mt-4 font-display text-lg font-semibold text-navy-900 leading-snug">
                        {m.title}
                      </h3>
                      <p className="text-sm text-slate-600 mt-1.5 line-clamp-2">
                        {m.summary}
                      </p>
                      <div className="mt-auto pt-5 flex items-center justify-between">
                        <span className="text-[11px] uppercase tracking-wider text-slate-500">
                          {m.difficulty}
                        </span>
                        <span className="inline-flex items-center gap-1 text-sm font-medium text-navy-900 group-hover:text-gold-700 transition-colors">
                          Ouvrir
                          <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
                        </span>
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
