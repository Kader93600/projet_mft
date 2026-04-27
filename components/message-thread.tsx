"use client";
import { useState, useTransition, useRef, useEffect } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { sendMessage } from "@/app/messages/actions";
import { Send, Loader2 } from "lucide-react";

type Msg = {
  id: string;
  sender_id: string;
  sender_role: "student" | "admin";
  body: string;
  created_at: string;
  read_at: string | null;
};

export function MessageThread({
  conversationId,
  messages,
  viewerRole,
  viewerId,
}: {
  conversationId: string;
  messages: Msg[];
  viewerRole: "student" | "admin";
  viewerId: string;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [body, setBody] = useState("");
  const [err, setErr] = useState<string | null>(null);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length]);

  const submit = () => {
    const trimmed = body.trim();
    if (!trimmed) return;
    setErr(null);
    start(async () => {
      try {
        await sendMessage({ conversation_id: conversationId, body: trimmed });
        setBody("");
        router.refresh();
      } catch (e: any) {
        setErr(e.message);
      }
    });
  };

  return (
    <div className="flex flex-col h-[560px]">
      <div className="flex-1 overflow-y-auto px-4 py-4 bg-slate-50/50 space-y-3">
        {messages.length === 0 && (
          <div className="text-center text-slate-400 text-sm py-10">
            Aucun message. Démarrez la conversation.
          </div>
        )}
        {messages.map((m) => {
          const mine = m.sender_id === viewerId;
          return (
            <div
              key={m.id}
              className={"flex " + (mine ? "justify-end" : "justify-start")}
            >
              <div className="max-w-[75%]">
                <div
                  className={
                    "px-4 py-2.5 rounded-2xl text-sm leading-relaxed whitespace-pre-wrap " +
                    (mine
                      ? "bg-navy-900 text-white rounded-br-sm"
                      : m.sender_role === "admin"
                      ? "bg-gold-100 text-navy-900 rounded-bl-sm border border-gold-200"
                      : "bg-white text-navy-900 rounded-bl-sm border border-navy-100")
                  }
                >
                  {m.body}
                </div>
                <div
                  className={
                    "mt-1 text-[10px] text-slate-400 " +
                    (mine ? "text-right" : "text-left")
                  }
                >
                  {m.sender_role === "admin" && !mine && "Équipe pédagogique · "}
                  {new Date(m.created_at).toLocaleString("fr-FR", {
                    day: "2-digit",
                    month: "short",
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                  {mine && m.read_at && " · Lu"}
                </div>
              </div>
            </div>
          );
        })}
        <div ref={bottomRef} />
      </div>

      <div className="border-t border-navy-100 bg-white p-3">
        {err && <div className="text-xs text-rose-700 mb-2">{err}</div>}
        <div className="flex items-end gap-2">
          <textarea
            rows={2}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
                e.preventDefault();
                submit();
              }
            }}
            placeholder={
              viewerRole === "student"
                ? "Écrivez à l'équipe pédagogique…"
                : "Répondre au stagiaire…"
            }
            className="flex-1 resize-none rounded-xl border border-navy-100 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
          />
          <Button
            onClick={submit}
            disabled={pending || !body.trim()}
            variant="gold"
          >
            {pending ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Send className="h-4 w-4" />
            )}
          </Button>
        </div>
        <div className="mt-1 text-[10px] text-slate-400">
          Astuce : ⌘/Ctrl + Entrée pour envoyer
        </div>
      </div>
    </div>
  );
}
