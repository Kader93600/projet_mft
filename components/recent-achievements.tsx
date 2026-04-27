import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Award, ScrollText, ArrowRight } from "lucide-react";
import * as Lucide from "lucide-react";

function Icon({ name, className }: { name: string; className?: string }) {
  const C = (Lucide as any)[name];
  if (C && typeof C === "function") return <C className={className} />;
  return <Award className={className} />;
}

const TIER_STYLES: Record<string, string> = {
  bronze: "bg-amber-50 text-amber-700 border-amber-200",
  silver: "bg-slate-50 text-slate-700 border-slate-200",
  gold: "bg-gold-50 text-gold-800 border-gold-200",
};

export async function RecentAchievements() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: badges }, { data: certs }] = await Promise.all([
    supabase
      .from("user_badges")
      .select("earned_at, badges(name, icon, tier, points)")
      .eq("user_id", user.id)
      .order("earned_at", { ascending: false })
      .limit(3),
    supabase
      .from("certificates")
      .select("id, type, issued_at, bloc_id, blocs(code, title)")
      .eq("user_id", user.id)
      .is("revoked_at", null)
      .order("issued_at", { ascending: false })
      .limit(3),
  ]);

  const hasBadges = (badges?.length ?? 0) > 0;
  const hasCerts = (certs?.length ?? 0) > 0;

  if (!hasBadges && !hasCerts) return null;

  return (
    <section className="grid md:grid-cols-2 gap-4">
      {hasBadges && (
        <Card>
          <CardBody>
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Award className="h-4 w-4 text-gold-600" />
                <h3 className="font-display font-semibold text-navy-900">
                  Derniers badges
                </h3>
              </div>
              <Link
                href="/reussites"
                className="text-xs font-medium text-navy-700 hover:text-gold-700 inline-flex items-center gap-1"
              >
                Tout voir <ArrowRight className="h-3 w-3" />
              </Link>
            </div>
            <div className="space-y-2.5">
              {badges!.map((b: any, i) => {
                const bd = b.badges;
                if (!bd) return null;
                return (
                  <div key={i} className="flex items-center gap-3">
                    <div
                      className={`h-9 w-9 rounded-lg border flex items-center justify-center shrink-0 ${
                        TIER_STYLES[bd.tier] ?? TIER_STYLES.bronze
                      }`}
                    >
                      <Icon name={bd.icon} className="h-4 w-4" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="text-sm font-medium text-navy-900 truncate">
                        {bd.name}
                      </div>
                      <div className="text-[11px] text-slate-500">
                        +{bd.points} pts ·{" "}
                        {new Date(b.earned_at).toLocaleDateString("fr-FR", {
                          day: "2-digit",
                          month: "short",
                        })}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </CardBody>
        </Card>
      )}

      {hasCerts && (
        <Card variant="gold">
          <CardBody>
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <ScrollText className="h-4 w-4 text-gold-700" />
                <h3 className="font-display font-semibold text-navy-900">
                  Mes certificats
                </h3>
              </div>
              <Link
                href="/certificats"
                className="text-xs font-medium text-navy-700 hover:text-gold-800 inline-flex items-center gap-1"
              >
                Tout voir <ArrowRight className="h-3 w-3" />
              </Link>
            </div>
            <div className="space-y-2.5">
              {certs!.map((c: any) => (
                <div key={c.id} className="flex items-center gap-3">
                  <Badge tone={c.type === "final" ? "gold" : "navy"} size="sm">
                    {c.type === "final" ? "Final" : c.blocs?.code ?? "Bloc"}
                  </Badge>
                  <div className="min-w-0 flex-1">
                    <div className="text-sm text-navy-900 truncate">
                      {c.type === "final"
                        ? "Titre pro GOTRM"
                        : c.blocs?.title ?? "Bloc"}
                    </div>
                    <div className="text-[11px] text-slate-500">
                      {new Date(c.issued_at).toLocaleDateString("fr-FR", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                    </div>
                  </div>
                  <a
                    href={`/api/certificate/${c.id}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-xs font-medium text-navy-700 hover:text-gold-700"
                  >
                    PDF
                  </a>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>
      )}
    </section>
  );
}
