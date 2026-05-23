"use client";

import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { AlertCircle } from "lucide-react";

/**
 * Remplace la bulle de validation native HTML5 (« Veuillez renseigner ce
 * champ. ») par une infobulle maison, pour TOUS les formulaires du site.
 *
 * Monté une seule fois (layout racine). Écoute l'événement `invalid` en
 * capture (il ne bulle pas), supprime la bulle native via preventDefault,
 * puis affiche un message soigné ancré sous le premier champ invalide —
 * sans rien changer dans les formulaires existants.
 *
 * Animation (philosophie Emil) : feedback ponctuel sur action volontaire →
 * entrée ease-out ~150 ms (opacity + léger translate + scale, origine haut),
 * sortie plus rapide, neutralisée sous prefers-reduced-motion.
 */
export function FormValidationTooltip() {
  const [tip, setTip] = useState<{ x: number; y: number; msg: string } | null>(
    null
  );
  const [shown, setShown] = useState(false);

  const pending = useRef<HTMLElement[]>([]);
  const raf = useRef<number | undefined>(undefined);
  const cleanup = useRef<(() => void) | undefined>(undefined);
  const hideTimer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  useEffect(() => {
    function onInvalid(e: Event) {
      const el = e.target;
      if (!(el instanceof HTMLElement)) return;
      // Supprime la bulle native (la soumission reste bloquée, c'est voulu).
      e.preventDefault();
      pending.current.push(el);
      if (raf.current) cancelAnimationFrame(raf.current);
      raf.current = requestAnimationFrame(() => {
        const els = pending.current;
        pending.current = [];
        if (!els.length) return;
        // Premier champ invalide dans l'ordre du document.
        els.sort((a, b) =>
          a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING
            ? -1
            : 1
        );
        show(els[0]);
      });
    }
    document.addEventListener("invalid", onInvalid, true);
    return () => {
      document.removeEventListener("invalid", onInvalid, true);
      cleanup.current?.();
      if (hideTimer.current) clearTimeout(hideTimer.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  function hide() {
    cleanup.current?.();
    cleanup.current = undefined;
    if (hideTimer.current) clearTimeout(hideTimer.current);
    setShown(false);
    hideTimer.current = setTimeout(() => setTip(null), 150);
  }

  function show(el: HTMLElement) {
    cleanup.current?.();
    if (hideTimer.current) clearTimeout(hideTimer.current);

    const msg =
      (el as HTMLInputElement).validationMessage ||
      "Veuillez renseigner ce champ.";

    // Centre le champ dans le viewport → toujours de la place en dessous.
    (el as HTMLElement & { focus: (o?: FocusOptions) => void }).focus?.({
      preventScroll: true,
    });
    el.scrollIntoView({ block: "center", inline: "nearest" });

    requestAnimationFrame(() => {
      const rect = el.getBoundingClientRect();
      const W = 264;
      const x = Math.max(8, Math.min(rect.left, window.innerWidth - W - 8));
      const y = rect.bottom + 8;
      setTip({ x, y, msg });
      requestAnimationFrame(() => setShown(true));
    });

    // Disparition : correction du champ, perte de focus, scroll, resize, Échap.
    const onResolve = () => hide();
    const onKey = (ev: KeyboardEvent) => {
      if (ev.key === "Escape") hide();
    };
    el.addEventListener("input", onResolve);
    el.addEventListener("change", onResolve);
    el.addEventListener("blur", onResolve);
    window.addEventListener("scroll", onResolve, true);
    window.addEventListener("resize", onResolve);
    document.addEventListener("keydown", onKey);
    hideTimer.current = setTimeout(hide, 6000);

    cleanup.current = () => {
      el.removeEventListener("input", onResolve);
      el.removeEventListener("change", onResolve);
      el.removeEventListener("blur", onResolve);
      window.removeEventListener("scroll", onResolve, true);
      window.removeEventListener("resize", onResolve);
      document.removeEventListener("keydown", onKey);
    };
  }

  if (!tip || typeof document === "undefined") return null;

  return createPortal(
    <div
      role="alert"
      aria-live="assertive"
      style={{ position: "fixed", left: tip.x, top: tip.y, width: 264 }}
      className={[
        "z-[200] pointer-events-none origin-top",
        "transition-[opacity,transform] duration-150 ease-premium",
        "motion-reduce:transition-opacity motion-reduce:transform-none",
        shown ? "opacity-100 translate-y-0 scale-100" : "opacity-0 -translate-y-1.5 scale-[0.97]",
      ].join(" ")}
    >
      {/* Flèche pointant vers le champ */}
      <div className="absolute -top-1 left-4 h-2.5 w-2.5 rotate-45 rounded-[2px] border-l border-t border-rose-200 bg-white dark:border-rose-500/40 dark:bg-[hsl(var(--surface))]" />
      <div className="flex items-start gap-2 rounded-xl border border-rose-200 bg-white px-3 py-2.5 shadow-raised dark:border-rose-500/40 dark:bg-[hsl(var(--surface))]">
        <AlertCircle className="mt-0.5 h-4 w-4 shrink-0 text-rose-500" />
        <span className="text-[13px] font-medium leading-snug text-navy-900 dark:text-[hsl(var(--text))]">
          {tip.msg}
        </span>
      </div>
    </div>,
    document.body
  );
}
