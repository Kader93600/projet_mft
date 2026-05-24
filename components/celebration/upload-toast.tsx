"use client";

import { useEffect, useState } from "react";
import { createPortal } from "react-dom";
import { CheckCircle2, AlertTriangle, Loader2, X } from "lucide-react";
import { cn } from "@/lib/utils";

export type ToastKind = "success" | "error" | "loading";
export interface UploadToastData {
  kind: ToastKind;
  title: string;
  message?: string;
}

/**
 * Notification premium d'upload (succès / erreur / en cours).
 * Entrée 3D : la carte se déplie depuis son bord bas (rotateX, origine bas,
 * ease-out ~260 ms). Auto-disparition pour succès/erreur ; persistante pendant
 * l'upload. Neutralisée sous prefers-reduced-motion.
 */
export function UploadToast({
  toast,
  onClose,
}: {
  toast: UploadToastData | null;
  onClose: () => void;
}) {
  const [shown, setShown] = useState(false);

  useEffect(() => {
    if (!toast) {
      setShown(false);
      return;
    }
    const r = requestAnimationFrame(() => setShown(true));
    let t: ReturnType<typeof setTimeout> | undefined;
    if (toast.kind !== "loading") {
      t = setTimeout(() => {
        setShown(false);
        setTimeout(onClose, 240);
      }, 4200);
    }
    return () => {
      cancelAnimationFrame(r);
      if (t) clearTimeout(t);
    };
  }, [toast, onClose]);

  if (!toast || typeof document === "undefined") return null;

  const cfg = {
    success: {
      Icon: CheckCircle2,
      iconWrap: "bg-emerald-100 text-emerald-600 dark:bg-emerald-500/15 dark:text-emerald-300",
      spin: false,
    },
    error: {
      Icon: AlertTriangle,
      iconWrap: "bg-rose-100 text-rose-600 dark:bg-rose-500/15 dark:text-rose-300",
      spin: false,
    },
    loading: {
      Icon: Loader2,
      iconWrap: "bg-brand-100 text-brand-700 dark:bg-brand-500/15 dark:text-brand-300",
      spin: true,
    },
  }[toast.kind];
  const Icon = cfg.Icon;

  return createPortal(
    <div className="pointer-events-none fixed inset-x-4 bottom-5 z-[120] flex justify-center [perspective:1100px] sm:inset-x-auto sm:right-5 sm:justify-end">
      <div
        role={toast.kind === "error" ? "alert" : "status"}
        aria-live={toast.kind === "error" ? "assertive" : "polite"}
        className={cn(
          "pointer-events-auto flex w-full max-w-sm origin-bottom items-start gap-3 rounded-2xl border border-navy-100 bg-white px-4 py-3.5 shadow-2xl",
          "dark:border-[hsl(var(--border))] dark:bg-[hsl(var(--surface))]",
          "transition-[transform,opacity] duration-[260ms] ease-premium motion-reduce:transition-opacity motion-reduce:transform-none",
          shown
            ? "opacity-100 [transform:rotateX(0deg)_translateY(0)]"
            : "opacity-0 [transform:rotateX(65deg)_translateY(10px)]"
        )}
      >
        <span
          className={cn(
            "mt-0.5 inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-xl",
            cfg.iconWrap
          )}
        >
          <Icon className={cn("h-5 w-5", cfg.spin && "animate-spin motion-reduce:animate-none")} />
        </span>
        <div className="min-w-0 flex-1">
          <p className="text-sm font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
            {toast.title}
          </p>
          {toast.message && (
            <p className="mt-0.5 text-[13px] text-slate-500 dark:text-[hsl(var(--text-muted))]">
              {toast.message}
            </p>
          )}
        </div>
        {toast.kind !== "loading" && (
          <button
            type="button"
            onClick={() => {
              setShown(false);
              setTimeout(onClose, 200);
            }}
            aria-label="Fermer"
            className="-mr-1 -mt-0.5 inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-lg text-slate-400 transition-colors hover:bg-navy-50 hover:text-navy-900 dark:hover:bg-white/10"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>
    </div>,
    document.body
  );
}
