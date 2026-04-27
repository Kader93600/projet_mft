import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import * as Lucide from "lucide-react";
import { Award } from "lucide-react";

function Icon({ name, className }: { name: string; className?: string }) {
  const C = (Lucide as any)[name] as any;
  if (C && typeof C === "function") return <C className={className} />;
  return <Award className={className} />;
}

const TIER_STYLES: Record<string, string> = {
  bronze: "bg-amber-50 text-amber-700 border-amber-200",
  silver: "bg-slate-50 text-slate-700 border-slate-200",
  gold: "bg-gold-50 text-gold-800 border-gold-200",
};

const TIER_LABEL: Record<string, string> = {
  bronze: "Bronze",
  silver: "Argent",
  gold: "Or",
};

export function BadgeCard({
  badge,
  earned,
  earnedAt,
}: {
  badge: {
    name: string;
    description: string | null;
    icon: string;
    tier: string;
    points: number;
    category: string;
  };
  earned: boolean;
  earnedAt?: string | null;
}) {
  return (
    <Card
      className={cn(
        "h-full transition-all",
        earned ? "" : "opacity-60 grayscale"
      )}
    >
      <CardBody className="flex flex-col items-start gap-3">
        <div
          className={cn(
            "h-12 w-12 rounded-xl flex items-center justify-center border",
            TIER_STYLES[badge.tier] ?? TIER_STYLES.bronze
          )}
        >
          <Icon name={badge.icon} className="h-6 w-6" />
        </div>
        <div className="flex items-center gap-2">
          <Badge
            tone={badge.tier === "gold" ? "gold" : "slate"}
            size="sm"
          >
            {TIER_LABEL[badge.tier] ?? badge.tier}
          </Badge>
          <span className="text-xs text-slate-500">+{badge.points} pts</span>
        </div>
        <div>
          <div className="font-display font-semibold text-navy-900 leading-tight">
            {badge.name}
          </div>
          {badge.description && (
            <p className="text-sm text-slate-600 mt-1 line-clamp-2">
              {badge.description}
            </p>
          )}
        </div>
        {earned && earnedAt && (
          <div className="text-[11px] text-slate-500 mt-auto">
            Obtenu le{" "}
            {new Date(earnedAt).toLocaleDateString("fr-FR", {
              day: "2-digit",
              month: "short",
              year: "numeric",
            })}
          </div>
        )}
      </CardBody>
    </Card>
  );
}
