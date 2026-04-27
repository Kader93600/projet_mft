"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  publishAnnouncement,
  deleteAnnouncement,
} from "./actions";
import { renderMarkdown } from "@/lib/markdown";
import { formatDate } from "@/lib/utils";
import {
  Send,
  Trash2,
  Users,
  UsersRound,
  Pin,
  Loader2,
  ChevronDown,
} from "lucide-react";

export function AnnouncementsList({
  announcements,
  groups,
}: {
  announcements: any[];
  groups: any[];
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [openId, setOpenId] = useState<string | null>(null);

  const publish = (id: string) =>
    start(async () => {
      try {
        const { notified } = await publishAnnouncement(id);
        alert(`Publiée — ${notified} stagiaire(s) notifié(s).`);
        router.refresh();
      } catch (e: any) {
        alert(e.message);
      }
    });

  const remove = (id: string) => {
    if (!confirm("Supprimer cette annonce ?")) return;
    start(async () => {
      try {
        await deleteAnnouncement(id);
        router.refresh();
      } catch (e: any) {
        alert(e.message);
      }
    });
  };

  return (
    <Card>
      <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between">
        <CardTitle className="text-base">
          Historique ({announcements.length})
        </CardTitle>
      </div>
      {announcements.length === 0 ? (
        <CardBody className="py-12 text-center text-sm text-slate-400">
          Aucune annonce pour le moment.
        </CardBody>
      ) : (
        <div className="divide-y divide-navy-50">
          {announcements.map((a) => (
            <div key={a.id} className="px-6 py-4">
              <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    {a.pinned && (
                      <Pin className="h-3.5 w-3.5 text-gold-600" />
                    )}
                    <span className="font-semibold text-navy-900">
                      {a.title}
                    </span>
                    {a.published_at ? (
                      <Badge tone="success" size="sm">
                        Publiée {formatDate(a.published_at)}
                      </Badge>
                    ) : (
                      <Badge tone="slate" size="sm">
                        Brouillon
                      </Badge>
                    )}
                    {a.audience === "all" ? (
                      <Badge tone="navy" size="sm">
                        <Users className="h-3 w-3" /> Tous
                      </Badge>
                    ) : (
                      <Badge tone="gold" size="sm">
                        <UsersRound className="h-3 w-3" />{" "}
                        {a.groups?.name ?? "Classe"}
                      </Badge>
                    )}
                  </div>
                  <button
                    onClick={() =>
                      setOpenId(openId === a.id ? null : a.id)
                    }
                    className="mt-1 inline-flex items-center gap-1 text-xs text-slate-500 hover:text-navy-900"
                  >
                    <ChevronDown
                      className={
                        "h-3 w-3 transition-transform " +
                        (openId === a.id ? "rotate-180" : "")
                      }
                    />
                    {openId === a.id ? "Masquer" : "Afficher"} le contenu
                  </button>
                </div>
                <div className="flex items-center gap-1.5 shrink-0">
                  {!a.published_at && (
                    <Button
                      size="sm"
                      variant="gold"
                      onClick={() => publish(a.id)}
                      disabled={pending}
                    >
                      {pending ? (
                        <Loader2 className="h-3.5 w-3.5 animate-spin" />
                      ) : (
                        <>
                          <Send className="h-3.5 w-3.5" /> Publier
                        </>
                      )}
                    </Button>
                  )}
                  <button
                    onClick={() => remove(a.id)}
                    disabled={pending}
                    className="p-2 rounded-lg text-rose-600 hover:bg-rose-50"
                    title="Supprimer"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>

              {openId === a.id && (
                <div
                  className="prose-lesson text-sm mt-3 max-h-[280px] overflow-y-auto bg-slate-50/60 p-4 rounded-xl"
                  dangerouslySetInnerHTML={{
                    __html: renderMarkdown(a.body_md || ""),
                  }}
                />
              )}
            </div>
          ))}
        </div>
      )}
    </Card>
  );
}
