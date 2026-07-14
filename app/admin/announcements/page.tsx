import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { AnnouncementComposer } from "./announcement-composer";
import { AnnouncementsList } from "./announcements-list";
import { Megaphone } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AnnouncementsPage() {
  const supabase = await createClient();
  const [{ data: announcements }, { data: groups }] = await Promise.all([
    supabase
      .from("announcements")
      .select("*, groups(name, color)")
      .order("created_at", { ascending: false })
      .limit(50),
    supabase.from("groups").select("id, name"),
  ]);

  const published = (announcements ?? []).filter((a) => a.published_at).length;
  const drafts = (announcements ?? []).length - published;

  return (
    <div className="space-y-8">
      <header className="flex items-start justify-between gap-4">
        <div>
          <span className="eyebrow text-gold-700">Communication</span>
          <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
            Annonces
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Diffusez des messages à tous les stagiaires ou à une classe
            spécifique. Chaque publication déclenche une notification dans leur
            espace.
          </p>
        </div>
        <div className="flex gap-2">
          <Badge tone="success" size="sm">
            {published} publiée{published > 1 ? "s" : ""}
          </Badge>
          <Badge tone="slate" size="sm">
            {drafts} brouillon{drafts > 1 ? "s" : ""}
          </Badge>
        </div>
      </header>

      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center gap-2">
          <Megaphone className="h-4 w-4 text-slate-500" />
          <CardTitle className="text-base">Nouvelle annonce</CardTitle>
        </div>
        <CardBody>
          <AnnouncementComposer groups={groups ?? []} />
        </CardBody>
      </Card>

      <AnnouncementsList
        announcements={(announcements ?? []) as any[]}
        groups={groups ?? []}
      />
    </div>
  );
}
