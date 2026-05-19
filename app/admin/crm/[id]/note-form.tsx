"use client";

import { useState, useTransition } from "react";
import { Loader2, AlertCircle, Phone, Mail, MessageSquare, Users, Pencil } from "lucide-react";
import { addNote } from "../actions";

type NoteKind = "call" | "email" | "sms" | "meeting" | "note";

const KIND_OPTIONS: Array<{ value: NoteKind; label: string; icon: any }> = [
  { value: "call", label: "Appel", icon: Phone },
  { value: "email", label: "Email", icon: Mail },
  { value: "sms", label: "SMS", icon: MessageSquare },
  { value: "meeting", label: "RDV", icon: Users },
  { value: "note", label: "Note", icon: Pencil },
];

export function NoteForm({ leadId }: { leadId: string }) {
  const [kind, setKind] = useState<NoteKind>("call");
  const [body, setBody] = useState("");
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  const submit = () => {
    if (!body.trim()) {
      setError("Note vide");
      return;
    }
    setError(null);
    startTransition(async () => {
      const res = await addNote(leadId, kind, body);
      if (!res.ok) {
        setError(res.error ?? "Erreur");
        return;
      }
      setBody("");
    });
  };

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        submit();
      }}
      className="space-y-3"
    >
      {/* Type */}
      <div className="flex items-center gap-1 flex-wrap">
        {KIND_OPTIONS.map(({ value, label, icon: Icon }) => (
          <button
            key={value}
            type="button"
            onClick={() => setKind(value)}
            className={
              kind === value
                ? "inline-flex items-center gap-1 rounded-md bg-navy-900 text-white px-2.5 py-1 text-xs font-medium"
                : "inline-flex items-center gap-1 rounded-md bg-white border border-navy-100 hover:bg-navy-50 text-navy-800 px-2.5 py-1 text-xs font-medium"
            }
          >
            <Icon className="h-3 w-3" />
            {label}
          </button>
        ))}
      </div>

      {/* Textarea */}
      <textarea
        value={body}
        onChange={(e) => setBody(e.target.value)}
        rows={3}
        disabled={pending}
        maxLength={5000}
        placeholder={
          kind === "call"
            ? "Compte-rendu de l'appel…"
            : kind === "meeting"
              ? "Notes du rendez-vous…"
              : "Décrivez l'échange ou la décision…"
        }
        className="w-full rounded-lg border border-navy-100 bg-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-gold-400"
      />

      {error && (
        <div className="flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs text-rose-800">
          <AlertCircle className="h-3.5 w-3.5 shrink-0 mt-0.5" />
          {error}
        </div>
      )}

      <div className="flex items-center justify-between">
        <span className="text-[11px] text-slate-500 tabular-nums">
          {body.length}/5000
        </span>
        <button
          type="submit"
          disabled={pending || !body.trim()}
          className="inline-flex items-center gap-1.5 rounded-lg bg-navy-900 hover:bg-navy-800 disabled:opacity-50 disabled:cursor-not-allowed text-white px-3 py-1.5 text-sm font-medium transition-colors"
        >
          {pending ? (
            <Loader2 className="h-3.5 w-3.5 animate-spin" />
          ) : (
            <Pencil className="h-3.5 w-3.5" />
          )}
          Enregistrer la note
        </button>
      </div>
    </form>
  );
}
