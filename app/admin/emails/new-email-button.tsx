"use client";

import { Mail } from "lucide-react";
import { useEmailComposer } from "@/components/email/email-composer-provider";

export function NewEmailButton() {
  const composer = useEmailComposer();
  return (
    <button
      type="button"
      onClick={() => composer.open()}
      className="inline-flex items-center gap-2 rounded-xl bg-navy-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-navy-800 active:scale-[0.98] motion-reduce:active:scale-100"
    >
      <Mail className="h-4 w-4 text-signal-400" />
      Nouvel email
    </button>
  );
}
