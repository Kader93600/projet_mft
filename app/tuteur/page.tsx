import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getTutorAccess } from "@/lib/tutor/access";
import { TutorPageClient } from "./page-client";

export const dynamic = "force-dynamic";

// =====================================================================
// /tuteur — version plein écran du chat IA.
//
// Le drawer (FAB) reste accessible partout, mais la page dédiée est
// utile pour :
//   • Une expérience mobile plus confortable (plein écran)
//   • Une page partageable / bookmarkable
//   • Une preview pour les utilisateurs non-Premium (upsell)
// =====================================================================

export default async function TuteurPage() {
  const tutorEnabled = process.env.FEATURE_AI_TUTOR === "true";
  if (!tutorEnabled) {
    return (
      <div className="max-w-xl mx-auto py-12 text-center space-y-3">
        <h1 className="font-display text-2xl font-semibold text-navy-900">
          Tuteur IA
        </h1>
        <p className="text-slate-600">
          Cette fonctionnalité est en cours de préparation. Revenez bientôt !
        </p>
      </div>
    );
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("current_formation_slug")
    .eq("id", user.id)
    .maybeSingle();
  const formationSlug = profile?.current_formation_slug ?? null;

  const access = await getTutorAccess(formationSlug);

  if (!access.allowed) {
    return (
      <div className="max-w-xl mx-auto py-12 space-y-6 text-center">
        <div className="mx-auto h-16 w-16 rounded-2xl bg-gold-100 text-gold-700 flex items-center justify-center">
          <SparklesIcon />
        </div>
        <div>
          <h1 className="font-display text-2xl md:text-3xl font-semibold text-navy-900">
            Le tuteur IA est réservé au pack Premium
          </h1>
          <p className="mt-3 text-slate-600 leading-relaxed">
            {access.reason ??
              "Mettez à niveau votre formule Premium pour discuter 24/7 avec un tuteur entraîné sur vos modules."}
          </p>
        </div>
        <a
          href="/inscription"
          className="inline-flex items-center gap-2 rounded-xl bg-navy-900 hover:bg-navy-800 text-white px-5 py-2.5 text-sm font-medium transition-colors"
        >
          Voir les packs
        </a>
      </div>
    );
  }

  return <TutorPageClient formationSlug={formationSlug} />;
}

function SparklesIcon() {
  return (
    <svg
      width="28"
      height="28"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden
    >
      <path d="M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z" />
      <path d="M20 3v4" />
      <path d="M22 5h-4" />
      <path d="M4 17v2" />
      <path d="M5 18H3" />
    </svg>
  );
}
