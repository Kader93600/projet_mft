import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { LeaderboardOptOutToggle } from "./toggle-client";
import { ShieldCheck } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function ConfidentialitePage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("leaderboard_opt_out")
    .eq("id", user.id)
    .maybeSingle();

  const optOut = Boolean(profile?.leaderboard_opt_out);

  return (
    <div className="space-y-8 max-w-3xl">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-2">
          <ShieldCheck className="h-3.5 w-3.5" />
          Confidentialité
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Mes préférences de confidentialité
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Contrôlez la visibilité de votre activité auprès des autres
          stagiaires. Ces réglages n'affectent pas le tracking pédagogique
          interne ni les rapports Qualiopi.
        </p>
      </header>

      <Card>
        <CardBody>
          <h2 className="font-display text-lg font-semibold text-navy-900">
            Classement public
          </h2>
          <p className="text-sm text-slate-600 mt-1 mb-2">
            Le classement (
            <a href="/classement" className="text-gold-700 hover:underline">
              /classement
            </a>
            ) affiche les stagiaires les plus actifs sous forme anonymisée
            (initiales). Vous pouvez désactiver votre apparition à tout moment.
          </p>
          <div className="border-t border-navy-50 mt-2">
            <LeaderboardOptOutToggle initialOptOut={optOut} />
          </div>
        </CardBody>
      </Card>
    </div>
  );
}
