import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { ArrowRight, Sparkles } from "lucide-react";

// Affiche une bannière incitant le stagiaire à remplir son enquête :
// - "chaud" quand progressPct >= 80% et pas encore rempli
// - "froid" quand enquête chaud faite depuis > 60j et pas encore de froid
export async function SurveyBanner({ progressPct }: { progressPct: number }) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: surveys } = await supabase
    .from("satisfaction_surveys")
    .select("type, submitted_at")
    .eq("user_id", user.id);

  const hot = surveys?.find((s) => s.type === "chaud");
  const cold = surveys?.find((s) => s.type === "froid");

  // À chaud : progression >= 80% et pas encore rempli
  if (!hot && progressPct >= 80) {
    return (
      <Link
        href="/evaluation/chaud"
        className="block rounded-2xl bg-gradient-to-r from-gold-500 to-gold-400 p-5 shadow-soft hover:shadow-raised transition-all group"
      >
        <div className="flex items-center gap-4">
          <div className="h-11 w-11 rounded-xl bg-white/20 backdrop-blur flex items-center justify-center">
            <Sparkles className="h-5 w-5 text-navy-900" />
          </div>
          <div className="flex-1">
            <div className="text-[11px] uppercase tracking-wider text-navy-900/70 font-semibold">
              Évaluation à chaud
            </div>
            <div className="font-display text-lg font-semibold text-navy-900 mt-0.5">
              Donnez-nous votre avis — 2 minutes suffisent
            </div>
            <div className="text-sm text-navy-900/80 mt-0.5">
              Votre retour améliore la formation pour les prochains stagiaires.
            </div>
          </div>
          <ArrowRight className="h-5 w-5 text-navy-900 transition-transform group-hover:translate-x-0.5" />
        </div>
      </Link>
    );
  }

  // À froid : enquête chaud soumise depuis plus de 60 jours, pas de froid encore
  if (hot && !cold) {
    const sixtyDays = 60 * 86400_000;
    const hotAge = Date.now() - new Date(hot.submitted_at).getTime();
    if (hotAge > sixtyDays) {
      return (
        <Link
          href="/evaluation/froid"
          className="block rounded-2xl bg-white border border-sky-200 p-5 shadow-soft hover:shadow-raised transition-all group"
        >
          <div className="flex items-center gap-4">
            <div className="h-11 w-11 rounded-xl bg-sky-50 text-sky-700 flex items-center justify-center">
              <Sparkles className="h-5 w-5" />
            </div>
            <div className="flex-1">
              <div className="text-[11px] uppercase tracking-wider text-sky-700 font-semibold">
                Évaluation à froid
              </div>
              <div className="font-display text-lg font-semibold text-navy-900 mt-0.5">
                Un bilan quelques mois après ?
              </div>
              <div className="text-sm text-slate-600 mt-0.5">
                Nous aimerions savoir comment la formation vous a servi.
              </div>
            </div>
            <ArrowRight className="h-5 w-5 text-navy-900 transition-transform group-hover:translate-x-0.5" />
          </div>
        </Link>
      );
    }
  }

  return null;
}
