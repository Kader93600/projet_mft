"use client";

import {
  useCallback,
  useEffect,
  useId,
  useRef,
  useState,
  type ReactNode,
} from "react";
import {
  Calendar,
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Sélecteur de date maison — remplace `<input type="date">` natif (calendrier
 * et bulle de validation moches, incohérents d'un navigateur à l'autre).
 *
 * Deux modes :
 *  - contrôlé   : `value` (ISO "YYYY-MM-DD") + `onChange(iso)`
 *  - formulaire : `name` (+ `defaultValue`, `required`) → input caché soumis
 *    avec le `<form action={...}>`. La validation `required` est gérée par le
 *    composant (message inline soigné, pas la bulle native).
 *
 * Popover : ouverture animée depuis le déclencheur (origin-aware, ease-out
 * ~170 ms), feedback `:active` sur les jours, respect de prefers-reduced-motion.
 */

const MONTHS = [
  "janvier", "février", "mars", "avril", "mai", "juin",
  "juillet", "août", "septembre", "octobre", "novembre", "décembre",
];
const WEEKDAYS = ["L", "M", "M", "J", "V", "S", "D"]; // lundi d'abord

const pad = (n: number) => String(n).padStart(2, "0");

function todayIso(): string {
  const d = new Date();
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}
function parseIso(iso: string): { y: number; m: number; d: number } | null {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso ?? "");
  return m ? { y: +m[1], m: +m[2], d: +m[3] } : null;
}
function formatFr(iso: string): string {
  const p = parseIso(iso);
  return p ? `${pad(p.d)}/${pad(p.m)}/${p.y}` : "";
}

export interface DateFieldProps {
  id?: string;
  name?: string;
  value?: string;
  defaultValue?: string;
  onChange?: (iso: string) => void;
  required?: boolean;
  disabled?: boolean;
  min?: string;
  max?: string;
  placeholder?: string;
  className?: string;
  "aria-label"?: string;
}

export function DateField({
  id,
  name,
  value,
  defaultValue,
  onChange,
  required,
  disabled,
  min,
  max,
  placeholder = "jj/mm/aaaa",
  className,
  "aria-label": ariaLabel,
}: DateFieldProps) {
  const isControlled = value !== undefined;
  const [internal, setInternal] = useState(defaultValue ?? "");
  const val = isControlled ? value ?? "" : internal;

  const [open, setOpen] = useState(false);
  const [shown, setShown] = useState(false);
  const [placement, setPlacement] = useState<"bottom" | "top">("bottom");
  const [invalid, setInvalid] = useState(false);

  const initView = useCallback(() => {
    const base = parseIso(val) ?? parseIso(todayIso())!;
    return { y: base.y, m: base.m - 1 };
  }, [val]);
  const [view, setView] = useState(initView);

  const rootRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const valRef = useRef(val);
  valRef.current = val;

  const autoId = useId();
  const fieldId = id ?? `date-${autoId}`;

  const setVal = useCallback(
    (next: string) => {
      if (!isControlled) setInternal(next);
      onChange?.(next);
      setInvalid(false);
    },
    [isControlled, onChange]
  );

  function openCal() {
    if (disabled) return;
    setView(initView());
    const rect = triggerRef.current?.getBoundingClientRect();
    if (rect) {
      const below = window.innerHeight - rect.bottom;
      setPlacement(below < 360 && rect.top > below ? "top" : "bottom");
    }
    setOpen(true);
  }
  const closeCal = useCallback(() => setOpen(false), []);

  // Animation d'entrée (data-mounted pattern → transition transform/opacity).
  useEffect(() => {
    if (!open) {
      setShown(false);
      return;
    }
    const r = requestAnimationFrame(() => setShown(true));
    return () => cancelAnimationFrame(r);
  }, [open]);

  // Fermeture : clic extérieur + Échap.
  useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      if (rootRef.current && !rootRef.current.contains(e.target as Node)) closeCal();
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        closeCal();
        triggerRef.current?.focus();
      }
    };
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open, closeCal]);

  // Garde `required` côté composant : bloque la soumission du form si vide
  // (capture-phase → stoppe l'action serveur), affiche un message inline.
  useEffect(() => {
    if (!required || !name) return;
    const form = rootRef.current?.closest("form");
    if (!form) return;
    const onSubmit = (e: Event) => {
      if (!valRef.current) {
        e.preventDefault();
        e.stopPropagation();
        setInvalid(true);
        triggerRef.current?.focus();
      }
    };
    form.addEventListener("submit", onSubmit, true);
    return () => form.removeEventListener("submit", onSubmit, true);
  }, [required, name]);

  // Grille de 42 cellules (6 semaines), lundi d'abord.
  const monthStart = new Date(view.y, view.m, 1);
  const startWeekday = (monthStart.getDay() + 6) % 7;
  const firstCell = new Date(view.y, view.m, 1 - startWeekday);
  const cells: { iso: string; day: number; inMonth: boolean }[] = [];
  for (let i = 0; i < 42; i++) {
    const d = new Date(firstCell.getFullYear(), firstCell.getMonth(), firstCell.getDate() + i);
    cells.push({
      iso: `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`,
      day: d.getDate(),
      inMonth: d.getMonth() === view.m,
    });
  }

  const today = todayIso();
  const outOfRange = (iso: string) =>
    (!!min && iso < min) || (!!max && iso > max);

  function selectDay(iso: string) {
    if (outOfRange(iso)) return;
    setVal(iso);
    closeCal();
    triggerRef.current?.focus();
  }
  function shiftMonth(delta: number) {
    setView((v) => {
      const d = new Date(v.y, v.m + delta, 1);
      return { y: d.getFullYear(), m: d.getMonth() };
    });
  }
  function shiftYear(delta: number) {
    setView((v) => ({ y: v.y + delta, m: v.m }));
  }

  return (
    <div ref={rootRef} className={cn("relative", className)}>
      {name && <input type="hidden" name={name} value={val} readOnly />}

      <button
        ref={triggerRef}
        type="button"
        id={fieldId}
        disabled={disabled}
        onClick={() => (open ? closeCal() : openCal())}
        aria-haspopup="dialog"
        aria-expanded={open}
        aria-label={ariaLabel}
        className={cn(
          "group flex w-full h-11 items-center justify-between gap-2 rounded-xl border bg-white px-3.5 text-[15px]",
          "dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))]",
          "transition-[border-color,box-shadow,transform] duration-150 ease-premium",
          "focus:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/15 focus-visible:border-navy-600",
          "active:scale-[0.99] motion-reduce:active:scale-100",
          "disabled:bg-navy-50 disabled:text-slate-400 disabled:cursor-not-allowed dark:disabled:bg-[hsl(var(--surface-2))]",
          open && "border-navy-600 ring-2 ring-navy-600/15 dark:border-signal-500 dark:ring-signal-500/20",
          !open && invalid && "border-rose-400 ring-2 ring-rose-500/15",
          !open && !invalid && "border-navy-200"
        )}
      >
        <span
          className={cn(
            "truncate tabular-nums",
            val
              ? "text-navy-900 dark:text-[hsl(var(--text))]"
              : "text-slate-400 dark:text-[hsl(var(--text-muted))]"
          )}
        >
          {val ? formatFr(val) : placeholder}
        </span>
        <Calendar
          className={cn(
            "h-4 w-4 shrink-0 transition-colors",
            open ? "text-navy-700 dark:text-signal-400" : "text-slate-400 group-hover:text-navy-600"
          )}
        />
      </button>

      {invalid && (
        <p className="mt-1.5 text-xs font-medium text-rose-600">
          Veuillez sélectionner une date.
        </p>
      )}

      {open && (
        <div
          role="dialog"
          aria-label="Choisir une date"
          className={cn(
            "absolute z-50 w-[18rem] rounded-2xl border border-navy-100 bg-white p-3 shadow-raised",
            "dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]",
            "transition-[opacity,transform] duration-[170ms] ease-premium motion-reduce:transition-opacity motion-reduce:transform-none",
            placement === "bottom" ? "top-full mt-2 origin-top" : "bottom-full mb-2 origin-bottom",
            shown ? "opacity-100 scale-100" : "opacity-0 scale-95"
          )}
        >
          {/* En-tête de navigation */}
          <div className="mb-2 flex items-center justify-between gap-1">
            <div className="flex items-center gap-0.5">
              <NavBtn onClick={() => shiftYear(-1)} label="Année précédente">
                <ChevronsLeft className="h-4 w-4" />
              </NavBtn>
              <NavBtn onClick={() => shiftMonth(-1)} label="Mois précédent">
                <ChevronLeft className="h-4 w-4" />
              </NavBtn>
            </div>
            <div className="flex-1 select-none text-center text-sm font-semibold capitalize tabular-nums text-navy-900 dark:text-[hsl(var(--text))]">
              {MONTHS[view.m]} {view.y}
            </div>
            <div className="flex items-center gap-0.5">
              <NavBtn onClick={() => shiftMonth(1)} label="Mois suivant">
                <ChevronRight className="h-4 w-4" />
              </NavBtn>
              <NavBtn onClick={() => shiftYear(1)} label="Année suivante">
                <ChevronsRight className="h-4 w-4" />
              </NavBtn>
            </div>
          </div>

          {/* Jours de la semaine */}
          <div className="grid grid-cols-7">
            {WEEKDAYS.map((w, i) => (
              <div
                key={i}
                className="py-1 text-center text-[11px] font-semibold uppercase text-slate-400 dark:text-[hsl(var(--text-muted))]"
              >
                {w}
              </div>
            ))}
          </div>

          {/* Grille des jours */}
          <div className="grid grid-cols-7 gap-0.5">
            {cells.map((c) => {
              const selected = c.iso === val;
              const isToday = c.iso === today;
              const disabledDay = outOfRange(c.iso);
              return (
                <button
                  key={c.iso}
                  type="button"
                  disabled={disabledDay}
                  onClick={() => selectDay(c.iso)}
                  aria-label={formatFr(c.iso) + (selected ? " (sélectionné)" : "")}
                  aria-current={isToday ? "date" : undefined}
                  className={cn(
                    "relative h-9 rounded-lg text-sm tabular-nums transition-colors duration-100",
                    "active:scale-90 motion-reduce:active:scale-100",
                    "focus:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/30",
                    !c.inMonth && "text-slate-300 dark:text-white/25",
                    c.inMonth &&
                      !selected &&
                      "text-navy-800 dark:text-[hsl(var(--text))] hover:bg-navy-50 dark:hover:bg-white/10",
                    selected &&
                      "bg-navy-900 font-semibold text-white hover:bg-navy-800 dark:bg-signal-500 dark:text-night-900",
                    disabledDay && "cursor-not-allowed opacity-30 hover:bg-transparent"
                  )}
                >
                  {c.day}
                  {isToday && !selected && (
                    <span className="absolute bottom-1 left-1/2 h-1 w-1 -translate-x-1/2 rounded-full bg-signal-500" />
                  )}
                </button>
              );
            })}
          </div>

          {/* Actions */}
          <div className="mt-2 flex items-center justify-between border-t border-navy-50 pt-2 dark:border-white/10">
            <button
              type="button"
              onClick={() => {
                setVal("");
                closeCal();
              }}
              className="rounded-md px-1.5 py-1 text-xs font-medium text-slate-500 transition-colors hover:text-rose-600"
            >
              Effacer
            </button>
            <button
              type="button"
              onClick={() => {
                if (outOfRange(today)) return;
                setView({ y: +today.slice(0, 4), m: +today.slice(5, 7) - 1 });
                selectDay(today);
              }}
              className="rounded-md px-1.5 py-1 text-xs font-semibold text-navy-700 transition-colors hover:text-navy-900 dark:text-signal-400 dark:hover:text-signal-300"
            >
              Aujourd'hui
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

function NavBtn({
  onClick,
  label,
  children,
}: {
  onClick: () => void;
  label: string;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={label}
      className="inline-flex h-7 w-7 items-center justify-center rounded-lg text-slate-500 transition-colors hover:bg-navy-50 hover:text-navy-900 active:scale-90 motion-reduce:active:scale-100 focus:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/30 dark:text-[hsl(var(--text-muted))] dark:hover:bg-white/10 dark:hover:text-white"
    >
      {children}
    </button>
  );
}
