"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { MarkdownEditor } from "@/components/markdown-editor";
import { createAnnouncement, publishAnnouncement } from "./actions";
import { Send, Save, Loader2, Users, UsersRound } from "lucide-react";

export function AnnouncementComposer({ groups }: { groups: any[] }) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [audience, setAudience] = useState<"all" | "group">("all");
  const [groupId, setGroupId] = useState<string>(groups[0]?.id ?? "");
  const [pinned, setPinned] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  const save = (publish: boolean) => () => {
    setErr(null);
    setOk(null);
    start(async () => {
      try {
        const { id } = await createAnnouncement({
          title,
          body_md: body,
          audience,
          group_id: audience === "group" ? groupId : null,
          pinned,
        });
        if (publish) {
          const { notified } = await publishAnnouncement(id);
          setOk(`Publiée — ${notified} stagiaire${notified > 1 ? "s" : ""} notifié${notified > 1 ? "s" : ""}`);
        } else {
          setOk("Enregistrée en brouillon.");
        }
        setTitle("");
        setBody("");
        setPinned(false);
        router.refresh();
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  return (
    <div className="space-y-4">
      <label className="block">
        <span className="block text-sm font-medium text-navy-900 mb-1">
          Titre
        </span>
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Ex : Session de révision le 20 mars"
        />
      </label>

      <div>
        <div className="block text-sm font-medium text-navy-900 mb-1">
          Contenu (Markdown)
        </div>
        <MarkdownEditor value={body} onChange={setBody} rows={8} />
      </div>

      <div>
        <div className="block text-sm font-medium text-navy-900 mb-2">
          Destinataires
        </div>
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setAudience("all")}
            className={
              "inline-flex items-center gap-2 px-4 py-2 rounded-xl border text-sm font-medium transition " +
              (audience === "all"
                ? "bg-navy-900 text-white border-navy-900"
                : "bg-white text-slate-700 border-navy-100 hover:border-navy-300")
            }
          >
            <Users className="h-4 w-4" /> Tous les stagiaires
          </button>
          <button
            type="button"
            onClick={() => setAudience("group")}
            className={
              "inline-flex items-center gap-2 px-4 py-2 rounded-xl border text-sm font-medium transition " +
              (audience === "group"
                ? "bg-navy-900 text-white border-navy-900"
                : "bg-white text-slate-700 border-navy-100 hover:border-navy-300")
            }
          >
            <UsersRound className="h-4 w-4" /> Une classe
          </button>
          {audience === "group" && (
            <select
              value={groupId}
              onChange={(e) => setGroupId(e.target.value)}
              className="rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm"
            >
              {groups.map((g: any) => (
                <option key={g.id} value={g.id}>
                  {g.name}
                </option>
              ))}
            </select>
          )}
        </div>
      </div>

      <label className="inline-flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          checked={pinned}
          onChange={(e) => setPinned(e.target.checked)}
          className="accent-gold-500"
        />
        <span className="text-sm text-navy-900">
          Épingler en haut du dashboard des stagiaires
        </span>
      </label>

      {err && <div className="text-sm text-rose-700">{err}</div>}
      {ok && <div className="text-sm text-emerald-700">{ok}</div>}

      <div className="flex items-center justify-end gap-2 pt-4 border-t border-navy-50">
        <Button
          onClick={save(false)}
          disabled={pending || !title.trim()}
          variant="secondary"
        >
          <Save className="h-4 w-4" /> Brouillon
        </Button>
        <Button
          onClick={save(true)}
          disabled={pending || !title.trim()}
          variant="gold"
        >
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" /> Envoi…
            </>
          ) : (
            <>
              <Send className="h-4 w-4" /> Publier & notifier
            </>
          )}
        </Button>
      </div>
    </div>
  );
}
