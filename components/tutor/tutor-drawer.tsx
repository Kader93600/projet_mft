"use client";

// =====================================================================
// Drawer slide-in droite. Contient l'ensemble du chat tuteur :
//   • header (titre + reset + fermer)
//   • liste des messages (TutorMessage)
//   • input bottom (TutorInput)
//
// Le composant est self-contained : il s'auto-monte le hook useTutor
// et expose juste un état `open` contrôlé par le parent (FAB).
// =====================================================================

import { useEffect, useRef } from "react";
import { Sparkles, RefreshCw, X, AlertCircle } from "lucide-react";
import { useTutor } from "@/hooks/use-tutor";
import { TutorMessage } from "./tutor-message";
import { TutorInput } from "./tutor-input";
import { cn } from "@/lib/utils";

export function TutorDrawer({
  open,
  onClose,
  formationSlug,
}: {
  open: boolean;
  onClose: () => void;
  formationSlug?: string | null;
}) {
  const tutor = useTutor({ formationSlug });
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto-scroll en bas quand un nouveau message arrive ou que le
  // dernier message grossit pendant le streaming.
  const lastContent = tutor.messages[tutor.messages.length - 1]?.content;
  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollTop = el.scrollHeight;
  }, [tutor.messages.length, lastContent]);

  // Fermer avec Esc
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !tutor.streaming) onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose, tutor.streaming]);

  return (
    <>
      {/* Backdrop */}
      <div
        aria-hidden
        onClick={() => !tutor.streaming && onClose()}
        className={cn(
          "fixed inset-0 z-[110] bg-navy-950/40 transition-opacity duration-300",
          open ? "opacity-100" : "opacity-0 pointer-events-none"
        )}
      />

      {/* Drawer */}
      <aside
        role="dialog"
        aria-label="Tuteur IA"
        aria-modal="true"
        className={cn(
          "fixed top-0 right-0 bottom-0 z-[111]",
          "w-full sm:w-[420px] md:w-[460px] lg:w-[500px]",
          "bg-ivory border-l border-navy-100 shadow-raised",
          "flex flex-col",
          "transition-transform duration-400",
          open ? "translate-x-0" : "translate-x-full"
        )}
        style={{ transitionTimingFunction: "cubic-bezier(0.19, 1, 0.22, 1)" }}
      >
        {/* Header */}
        <header className="flex items-center justify-between gap-2 px-4 py-3 border-b border-navy-100 bg-white">
          <div className="flex items-center gap-2 min-w-0">
            <div className="h-8 w-8 rounded-xl bg-gold-500 text-navy-900 flex items-center justify-center shrink-0">
              <Sparkles className="h-4 w-4" />
            </div>
            <div className="min-w-0">
              <div className="font-display font-semibold text-navy-900 text-[15px] leading-tight truncate">
                Tuteur IA
              </div>
              <div className="text-[11px] text-slate-500">
                Claude Sonnet 4.6 · Premium
              </div>
            </div>
          </div>
          <div className="flex items-center gap-1 shrink-0">
            <button
              type="button"
              onClick={tutor.reset}
              disabled={tutor.streaming || tutor.messages.length === 0}
              aria-label="Nouvelle conversation"
              title="Nouvelle conversation"
              className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-500 hover:text-navy-900 hover:bg-navy-50 transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
            >
              <RefreshCw className="h-3.5 w-3.5" />
            </button>
            <button
              type="button"
              onClick={onClose}
              aria-label="Fermer"
              className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-500 hover:text-navy-900 hover:bg-navy-50 transition-colors"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          </div>
        </header>

        {/* Messages */}
        <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
          {tutor.messages.length === 0 ? (
            <EmptyState />
          ) : (
            tutor.messages.map((m) => <TutorMessage key={m.id} message={m} />)
          )}

          {tutor.error && (
            <div
              role="alert"
              className="flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2.5 text-xs text-rose-800"
            >
              <AlertCircle className="h-3.5 w-3.5 shrink-0 mt-0.5" />
              <div>
                <div className="font-medium">Erreur</div>
                <div className="mt-0.5">{tutor.error}</div>
              </div>
            </div>
          )}
        </div>

        {/* Footer / input */}
        <TutorInput
          onSend={tutor.send}
          onStop={tutor.stop}
          streaming={tutor.streaming}
        />

        <div className="border-t border-navy-100 px-4 py-2 text-[10px] text-slate-500 leading-snug bg-white">
          ⚠ Le tuteur peut se tromper. Pour les cas réglementaires précis,
          vérifiez avec votre formateur.
        </div>
      </aside>
    </>
  );
}

function EmptyState() {
  const samples = [
    "Quelle est la différence entre un transport public et un transport pour compte propre ?",
    "Comment calculer la masse maximale autorisée d'un véhicule ?",
    "Quels documents un chauffeur doit-il avoir à bord ?",
  ];

  return (
    <div className="text-center py-8 px-2">
      <div className="mx-auto h-12 w-12 rounded-2xl bg-gold-100 text-gold-700 flex items-center justify-center">
        <Sparkles className="h-6 w-6" />
      </div>
      <h3 className="mt-4 font-display text-lg font-semibold text-navy-900">
        Bonjour 👋
      </h3>
      <p className="mt-1 text-sm text-slate-600 max-w-xs mx-auto leading-relaxed">
        Posez-moi vos questions sur vos modules. Je m&apos;appuie sur vos
        leçons et je cite mes sources.
      </p>
      <div className="mt-5 space-y-1.5 text-left max-w-sm mx-auto">
        <div className="text-[11px] uppercase tracking-wider text-slate-500 text-center mb-2">
          Idées pour commencer
        </div>
        {samples.map((q) => (
          <div
            key={q}
            className="text-[12.5px] text-slate-700 bg-white rounded-lg border border-navy-100 px-3 py-2 leading-snug"
          >
            {q}
          </div>
        ))}
      </div>
    </div>
  );
}
