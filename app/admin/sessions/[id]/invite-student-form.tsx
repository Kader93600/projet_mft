"use client";

import { useState, useTransition } from "react";
import { Button } from "@/components/ui/button";
import {
  AlertCircle,
  CheckCircle2,
  Loader2,
  Mail,
  Search,
} from "lucide-react";
import { inviteStudent } from "../actions";

type Candidate = { id: string; full_name: string | null; email: string };

export function InviteStudentForm({
  sessionId,
  candidates,
}: {
  sessionId: string;
  candidates: Candidate[];
}) {
  const [pending, startTransition] = useTransition();
  const [query, setQuery] = useState("");
  const [feedback, setFeedback] = useState<"idle" | "ok" | "err">("idle");
  const [error, setError] = useState<string | null>(null);
  const [selectedId, setSelectedId] = useState<string>("");

  const filtered = candidates.filter((c) => {
    if (!query.trim()) return true;
    const q = query.toLowerCase();
    return (
      c.email.toLowerCase().includes(q) ||
      (c.full_name ?? "").toLowerCase().includes(q)
    );
  });

  function onInvite(userId: string) {
    setError(null);
    setFeedback("idle");
    startTransition(async () => {
      try {
        await inviteStudent(sessionId, userId);
        setFeedback("ok");
        setSelectedId("");
        setTimeout(() => setFeedback("idle"), 2000);
      } catch (e: any) {
        setFeedback("err");
        setError(e.message ?? "Erreur");
      }
    });
  }

  if (candidates.length === 0) {
    return (
      <div className="rounded-xl bg-white border border-dashed border-navy-200 px-4 py-6 text-center text-sm text-slate-600">
        Tous les stagiaires Premium de cette formation sont déjà inscrits à
        cette session, ou aucun n'est éligible.
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
        <input
          type="text"
          placeholder="Rechercher un stagiaire Premium par nom ou email…"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="w-full h-11 rounded-xl border border-navy-200 bg-white pl-10 pr-3.5 text-[15px] text-navy-900 placeholder:text-slate-400 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15"
        />
      </div>
      <div className="max-h-72 overflow-y-auto rounded-xl border border-navy-100 bg-white divide-y divide-navy-100">
        {filtered.length === 0 ? (
          <div className="px-4 py-6 text-center text-sm text-slate-500">
            Aucun stagiaire correspondant.
          </div>
        ) : (
          filtered.slice(0, 25).map((c) => (
            <div
              key={c.id}
              className="flex items-center justify-between gap-3 px-4 py-2.5 hover:bg-ivory transition"
            >
              <div className="min-w-0">
                <div className="font-semibold text-navy-950 text-sm truncate">
                  {c.full_name ?? "Anonyme"}
                </div>
                <div className="text-xs text-slate-500 truncate">
                  {c.email}
                </div>
              </div>
              <Button
                variant="secondary"
                size="sm"
                disabled={pending && selectedId === c.id}
                onClick={() => {
                  setSelectedId(c.id);
                  onInvite(c.id);
                }}
              >
                {pending && selectedId === c.id ? (
                  <>
                    <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    Invitation…
                  </>
                ) : (
                  <>
                    <Mail className="h-3.5 w-3.5" />
                    Inviter
                  </>
                )}
              </Button>
            </div>
          ))
        )}
      </div>
      {feedback === "ok" && (
        <div className="flex items-center gap-2 text-sm text-emerald-700">
          <CheckCircle2 className="h-4 w-4" />
          Stagiaire invité avec succès
        </div>
      )}
      {feedback === "err" && error && (
        <div className="flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
          <AlertCircle className="h-4 w-4" />
          {error}
        </div>
      )}
    </div>
  );
}
