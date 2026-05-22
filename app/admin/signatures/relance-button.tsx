"use client";

import { useState, useTransition } from "react";
import { Send, Loader2, Check } from "lucide-react";
import { relanceSignature } from "./actions";

export function RelanceButton({ studentId }: { studentId: string }) {
  const [pending, start] = useTransition();
  const [done, setDone] = useState(false);

  function relance() {
    start(async () => {
      const res = await relanceSignature(studentId);
      if (res.ok) {
        setDone(true);
        setTimeout(() => setDone(false), 4000);
      }
    });
  }

  return (
    <button
      type="button"
      onClick={relance}
      disabled={pending || done}
      className="inline-flex items-center gap-1.5 rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-xs font-medium text-navy-800 hover:bg-navy-50 transition-colors disabled:opacity-60"
    >
      {pending ? (
        <Loader2 className="h-3.5 w-3.5 animate-spin" />
      ) : done ? (
        <Check className="h-3.5 w-3.5 text-emerald-600" />
      ) : (
        <Send className="h-3.5 w-3.5" />
      )}
      {done ? "Relancé" : "Relancer"}
    </button>
  );
}
