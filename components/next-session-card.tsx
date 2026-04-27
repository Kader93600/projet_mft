import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { HeartHandshake, Video, Phone, MapPin, ArrowRight } from "lucide-react";

export async function NextSessionCard() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: next } = await supabase
    .from("coaching_sessions")
    .select(
      "id, scheduled_at, duration_min, mode, meeting_url, trainer:profiles!coaching_sessions_trainer_id_fkey(full_name, email)"
    )
    .eq("user_id", user.id)
    .eq("status", "prevue")
    .gte("scheduled_at", new Date().toISOString())
    .order("scheduled_at")
    .limit(1)
    .maybeSingle();

  if (!next) return null;

  const Icon =
    next.mode === "visio" ? Video : next.mode === "tel" ? Phone : MapPin;
  const when = new Date(next.scheduled_at);
  const trainer = (next as any).trainer;

  return (
    <Card variant="gold">
      <CardBody className="flex items-center gap-4">
        <div className="h-12 w-12 rounded-xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
          <HeartHandshake className="h-6 w-6" />
        </div>
        <div className="flex-1 min-w-0">
          <div className="text-[11px] uppercase tracking-wider text-gold-800">
            Prochain rendez-vous
          </div>
          <div className="font-display font-semibold text-navy-900">
            {when.toLocaleDateString("fr-FR", {
              weekday: "short",
              day: "2-digit",
              month: "short",
            })}{" "}
            ·{" "}
            {when.toLocaleTimeString("fr-FR", {
              hour: "2-digit",
              minute: "2-digit",
            })}
          </div>
          <div className="text-xs text-slate-700 mt-0.5 flex items-center gap-1.5">
            <Icon className="h-3.5 w-3.5" />
            <span className="capitalize">{next.mode}</span>
            <span className="text-slate-400">·</span>
            <span>
              Avec {trainer?.full_name || trainer?.email || "votre référent"}
            </span>
          </div>
        </div>
        <Link
          href="/accompagnement"
          className="shrink-0 text-sm font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1"
        >
          Détails <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </CardBody>
    </Card>
  );
}
