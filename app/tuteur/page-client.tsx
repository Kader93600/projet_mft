"use client";

// Version plein écran du chat tuteur. Utilise les mêmes briques
// (useTutor + TutorMessage + TutorInput) que le drawer, dans un
// layout vertical maximisé.

import { useEffect, useRef } from "react";
import { useTutor } from "@/hooks/use-tutor";
import { TutorMessage } from "@/components/tutor/tutor-message";
import { TutorInput } from "@/components/tutor/tutor-input";
import { Card, CardBody } from "@/components/ui/card";
import { Sparkles, RefreshCw, AlertCircle } from "lucide-react";

export function TutorPageClient({
  formationSlug,
}: {
  formationSlug: string | null;
}) {
  const tutor = useTutor({ formationSlug });
  const scrollRef = useRef<HTMLDivElement>(null);

  const lastContent = tutor.messages[tutor.messages.length - 1]?.content;
  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollTop = el.scrollHeight;
  }, [tutor.messages.length, lastContent]);

  return (
    <div className="max-w-3xl mx-auto h-[calc(100vh-9rem)] flex flex-col">
      <header className="mb-4">
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Sparkles className="h-3.5 w-3.5" />
          Tuteur IA
        </span>
        <h1 className="mt-2 font-display text-2xl md:text-3xl font-semibold text-navy-950 tracking-tight">
          Posez-moi vos questions
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Claude Sonnet 4, entraîné sur vos modules. Citations garanties.
        </p>
      </header>

      <Card className="flex-1 flex flex-col overflow-hidden">
        <div className="flex items-center justify-between px-4 py-2.5 border-b border-navy-100 bg-white">
          <div className="text-xs text-slate-500">
            {tutor.messages.length === 0
              ? "Nouvelle conversation"
              : `${tutor.messages.filter((m) => m.role === "user").length} question${
                  tutor.messages.filter((m) => m.role === "user").length > 1
                    ? "s"
                    : ""
                }`}
          </div>
          <button
            type="button"
            onClick={tutor.reset}
            disabled={tutor.streaming || tutor.messages.length === 0}
            className="inline-flex items-center gap-1.5 text-xs font-medium text-slate-500 hover:text-navy-900 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <RefreshCw className="h-3 w-3" />
            Nouvelle conversation
          </button>
        </div>

        <div
          ref={scrollRef}
          className="flex-1 overflow-y-auto px-4 py-4 space-y-4 bg-ivory"
        >
          {tutor.messages.length === 0 ? (
            <div className="text-center py-10">
              <div className="mx-auto h-14 w-14 rounded-2xl bg-gold-100 text-gold-700 flex items-center justify-center">
                <Sparkles className="h-7 w-7" />
              </div>
              <h3 className="mt-4 font-display text-xl font-semibold text-navy-900">
                Quelque chose à éclaircir dans votre formation ?
              </h3>
              <p className="mt-1 text-sm text-slate-600 max-w-md mx-auto">
                Je m&apos;appuie sur vos leçons et je cite mes sources. Posez
                une question concrète pour commencer.
              </p>
            </div>
          ) : (
            tutor.messages.map((m) => <TutorMessage key={m.id} message={m} />)
          )}

          {tutor.error && (
            <CardBody className="border border-rose-200 bg-rose-50 rounded-lg">
              <div className="flex items-start gap-2 text-xs text-rose-800">
                <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
                <div>
                  <div className="font-medium">Erreur</div>
                  <div className="mt-0.5">{tutor.error}</div>
                </div>
              </div>
            </CardBody>
          )}
        </div>

        <TutorInput
          onSend={tutor.send}
          onStop={tutor.stop}
          streaming={tutor.streaming}
        />
      </Card>

      <p className="text-[10px] text-slate-500 mt-2 text-center">
        ⚠ Le tuteur peut se tromper. Pour les cas réglementaires précis,
        consultez votre formateur.
      </p>
    </div>
  );
}
