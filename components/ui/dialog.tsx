"use client";
import { cn } from "@/lib/utils";
import { X } from "lucide-react";
import * as React from "react";
import { createPortal } from "react-dom";

interface DialogProps {
  open: boolean;
  onClose: () => void;
  children: React.ReactNode;
  size?: "sm" | "md" | "lg" | "xl";
}

/** Sélecteur des éléments focusables pour le piège à focus. */
const FOCUSABLE =
  'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]):not([type="hidden"]), select:not([disabled]), [tabindex]:not([tabindex="-1"])';

export function Dialog({ open, onClose, children, size = "md" }: DialogProps) {
  const [mounted, setMounted] = React.useState(false);
  const panelRef = React.useRef<HTMLDivElement>(null);
  // Élément focusé avant l'ouverture : on lui rend le focus à la fermeture
  // (exigence WCAG 2.4.3 — parcours de focus cohérent).
  const previouslyFocused = React.useRef<HTMLElement | null>(null);
  React.useEffect(() => setMounted(true), []);

  React.useEffect(() => {
    if (!open) return;

    previouslyFocused.current =
      (document.activeElement as HTMLElement | null) ?? null;

    // Focus initial : 1er élément focusable du panneau, sinon le panneau.
    const raf = requestAnimationFrame(() => {
      const panel = panelRef.current;
      if (!panel) return;
      const focusables = panel.querySelectorAll<HTMLElement>(FOCUSABLE);
      (focusables[0] ?? panel).focus();
    });

    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") {
        onClose();
        return;
      }
      // Piège à focus : Tab / Shift+Tab bouclent dans le dialogue.
      if (e.key !== "Tab") return;
      const panel = panelRef.current;
      if (!panel) return;
      const els = Array.from(
        panel.querySelectorAll<HTMLElement>(FOCUSABLE),
      ).filter((el) => el.offsetParent !== null);
      if (els.length === 0) {
        e.preventDefault();
        panel.focus();
        return;
      }
      const first = els[0];
      const last = els[els.length - 1];
      const active = document.activeElement as HTMLElement | null;
      if (e.shiftKey) {
        if (active === first || !panel.contains(active)) {
          e.preventDefault();
          last.focus();
        }
      } else if (active === last || !panel.contains(active)) {
        e.preventDefault();
        first.focus();
      }
    }

    document.addEventListener("keydown", onKey);
    document.body.style.overflow = "hidden";
    return () => {
      cancelAnimationFrame(raf);
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = "";
      // Retour du focus au déclencheur d'origine.
      previouslyFocused.current?.focus?.();
    };
  }, [open, onClose]);

  if (!mounted || !open) return null;

  const sizes = {
    sm: "max-w-md",
    md: "max-w-lg",
    lg: "max-w-2xl",
    xl: "max-w-4xl",
  };

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-navy-950/50 backdrop-blur-sm animate-in fade-in"
        onClick={onClose}
        aria-hidden="true"
      />
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        tabIndex={-1}
        className={cn(
          "relative w-full bg-white rounded-2xl shadow-float border border-navy-100",
          "max-h-[90vh] overflow-hidden flex flex-col animate-in zoom-in-95",
          "focus:outline-none",
          sizes[size]
        )}
      >
        {children}
      </div>
    </div>,
    document.body
  );
}

export function DialogHeader({
  title,
  description,
  onClose,
}: {
  title: string;
  description?: string;
  onClose?: () => void;
}) {
  return (
    <div className="flex items-start justify-between px-6 pt-6 pb-4 border-b border-navy-50">
      <div>
        <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight">
          {title}
        </h2>
        {description && <p className="mt-1 text-sm text-slate-600">{description}</p>}
      </div>
      {onClose && (
        <button
          onClick={onClose}
          className="h-8 w-8 rounded-lg text-slate-400 hover:bg-navy-50 hover:text-navy-900 inline-flex items-center justify-center transition-colors"
          aria-label="Fermer"
        >
          <X className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}

export function DialogBody({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={cn("p-6 overflow-y-auto", className)}>{children}</div>;
}

export function DialogFooter({ children }: { children: React.ReactNode }) {
  return (
    <div className="px-6 py-4 border-t border-navy-50 flex items-center justify-end gap-2 bg-navy-50/30">
      {children}
    </div>
  );
}
