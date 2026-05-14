import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  CalendarClock,
  Video,
  MapPin,
  Sparkles,
  CheckCircle2,
  Clock3,
  ChevronRight,
  CalendarDays,
  Crown,
  ShieldCheck,
} from "lucide-react";
import { StudentSessionsList } from "./sessions-list";

export const dynamic = "force-dynamic";

export default async function StudentSessionsPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Sessions visibles par le RLS (formation × pack Premium)
  const { data: sessions } = await supabase
    .from("live_sessions")
    .select(
      `
        id, title, description, kind, status, start_at, end_at,
        location, meeting_provider, max_participants, formation_id,
        formations!inner(slug, title, code, accent_color),
        trainer:profiles!live_sessions_trainer_id_fkey(id, full_name),
        my_enrollment:session_enrollments!left(status),
        my_attendance:session_attendance!left(signed_at, validated_at)
      `
    )
    .order("start_at", { ascending: true });

  // Filtre côté JS pour `my_enrollment` et `my_attendance` (filter by user_id)
  // — on les recharge proprement
  const sessionIds = (sessions ?? []).map((s: any) => s.id);
  const [{ data: myEnrolls }, { data: myAtt }] = await Promise.all([
    supabase
      .from("session_enrollments")
      .select("session_id, status")
      .eq("user_id", user.id)
      .in("session_id", sessionIds.length ? sessionIds : ["__none__"]),
    supabase
      .from("session_attendance")
      .select("session_id, signed_at, validated_at, method")
      .eq("user_id", user.id)
      .in("session_id", sessionIds.length ? sessionIds : ["__none__"]),
  ]);

  const enrollMap = new Map(
    (myEnrolls ?? []).map((e) => [e.session_id, e.status])
  );
  const attMap = new Map(
    (myAtt ?? []).map((a) => [a.session_id, a])
  );

  // Récupère les formations Premium auxquelles je suis inscrit
  const { data: myPremium } = await supabase
    .from("enrollments")
    .select("formation_id, formations!inner(slug, title, code)")
    .eq("user_id", user.id)
    .eq("pack", "premium")
    .not("status", "in", '("refuse","abandon")');

  const hasPremium = (myPremium ?? []).length > 0;

  // Si pas Premium du tout, on montre l'écran d'upsell
  if (!hasPremium) {
    return <NoPremiumUpsell />;
  }

  const enriched = (sessions ?? []).map((s: any) => ({
    ...s,
    my_status: enrollMap.get(s.id) ?? null,
    my_attendance: attMap.get(s.id) ?? null,
  }));

  const now = Date.now();
  const upcoming = enriched.filter(
    (s: any) =>
      new Date(s.end_at).getTime() >= now && s.status !== "cancelled"
  );
  const past = enriched.filter(
    (s: any) =>
      new Date(s.end_at).getTime() < now || s.status === "completed"
  );

  return (
    <div className="space-y-10">
      <header className="rounded-2xl bg-gradient-to-br from-navy-950 to-navy-900 px-6 py-8 md:px-8 md:py-10 text-white relative overflow-hidden">
        <div
          aria-hidden="true"
          className="absolute -top-20 -right-20 h-72 w-72 rounded-full bg-signal-500/10 blur-3xl"
        />
        <div className="relative">
          <Badge tone="bc1" size="sm">
            <Crown className="h-3 w-3" />
            Premium
          </Badge>
          <h1 className="mt-3 font-display text-3xl md:text-4xl font-semibold tracking-tight">
            Mes sessions en direct
          </h1>
          <p className="mt-2 text-white/70 max-w-2xl">
            Webinaires, ateliers et examens blancs supervisés — en visio ou en
            présentiel. Émargement horodaté pour la conformité Qualiopi.
          </p>
        </div>
      </header>

      <StudentSessionsList
        upcoming={upcoming}
        past={past}
        userId={user.id}
      />
    </div>
  );
}

function NoPremiumUpsell() {
  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-signal-700">Sessions en direct</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Une fonctionnalité réservée au pack Premium
        </h1>
      </header>

      <div className="rounded-3xl border border-gold-200 bg-gradient-to-br from-gold-50/60 via-white to-white p-8 md:p-10 relative overflow-hidden">
        <div
          aria-hidden="true"
          className="absolute -top-12 -right-12 h-48 w-48 rounded-full bg-gold-500/15 blur-3xl"
        />
        <div className="relative max-w-2xl">
          <Badge tone="gold" size="sm">
            <Crown className="h-3 w-3" />
            Pack Premium
          </Badge>
          <h2 className="mt-3 font-display text-2xl md:text-3xl font-semibold text-navy-950">
            Webinaires en direct, classes virtuelles et présentiel
          </h2>
          <p className="mt-3 text-slate-600">
            Le pack Premium débloque l'accès aux sessions encadrées par nos
            formateurs : webinaires Zoom / Teams, ateliers en visio et
            séances présentielles dans nos centres partenaires. Émargement
            horodaté pour la conformité Qualiopi.
          </p>

          <ul className="mt-6 space-y-3">
            {[
              "Webinaires hebdomadaires animés par un formateur expert",
              "Examens blancs supervisés en conditions réelles",
              "Ateliers pratiques (étude de cas, jeux de rôle, simulations)",
              "Émargement horodaté + certificat d'assiduité Qualiopi",
              "Replays disponibles 7 jours après la session",
            ].map((f) => (
              <li
                key={f}
                className="flex items-start gap-2 text-sm text-navy-900"
              >
                <CheckCircle2 className="h-4 w-4 text-signal-700 mt-0.5 shrink-0" />
                {f}
              </li>
            ))}
          </ul>

          <div className="mt-7 flex flex-wrap items-center gap-3">
            <Link href="/tarifs">
              <Button variant="gold">
                <Sparkles className="h-4 w-4" />
                Voir les tarifs Premium
              </Button>
            </Link>
            <Link href="/accompagnement">
              <Button variant="secondary">Parler à un conseiller</Button>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
