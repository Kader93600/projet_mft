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
 * Saisie hybride :
 *  - au clavier  : on tape directement `jj/mm/aaaa` dans le champ (les `/`
 *    s'insèrent tout seuls, seuls les chiffres sont acceptés) ;
 *  - au calendrier : on clique l'icône pour ouvrir le popover.
 *
 * Deux modes de valeur :
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

/** Insère les `/` au fil de la frappe (jjmmaaaa → jj/mm/aaaa). */
function formatTyping(raw: string): string {
  const d = raw.replace(/\D/g, "").slice(0, 8);
  if (d.length <= 2) return d;
  if (d.length <= 4) return `${d.slice(0, 2)}/${d.slice(2)}`;
  return `${d.slice(0, 2)}/${d.slice(2, 4)}/${d.slice(4)}`;
}

/** Convertit une saisie "jj/mm/aaaa" complète et cohérente en ISO. */
function parseFrToIso(text: string): string | null {
  const m = /^(\d{2})\/(\d{2})\/(\d{4})$/.exec(text);
  if (!m) return null;
  const d = +m[1];
  const mo = +m[2];
  const y = +m[3];
  if (mo < 1 || mo > 12) return null;
  const daysInMonth = new Date(y, mo, 0).getDate();
  if (d < 1 || d > daysInMonth) return null;
  return `${y}-${pad(mo)}-${pad(d)}`;
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

  // Texte affiché dans l'input (peut différer de `val` pendant la frappe).
  const [text, setText] = useState(() => formatFr(val));

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
  const inputRef = useRef<HTMLInputElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const valRef = useRef(val);
  valRef.current = val;
  // Vrai tant que l'utilisateur est en train de taper dans le champ : évite
  // de réécraser sa saisie quand `val` change.
  const editingRef = useRef(false);

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

  // Synchronise le texte affiché quand la valeur change de l'extérieur
  // (calendrier, « Aujourd'hui », « Effacer », prop `value`) — mais pas
  // pendant la frappe, pour ne pas faire sauter le curseur.
  useEffect(() => {
    if (!editingRef.current) setText(formatFr(val));
  }, [val]);

  function openCal() {
    if (disabled) return;
    setView(initView());
    const rect = rootRef.current?.getBoundingClientRect();
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
        inputRef.current?.focus();
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
        inputRef.current?.focus();
      }
    };
    form.addEventListener("submit", onSubmit, true);
    return () => form.removeEventListener("submit", onSubmit, true);
  }, [required, name]);

  // ── Saisie clavier ───────────────────────────────────────────────────
  function onType(e: React.ChangeEvent<HTMLInputElement>) {
    const formatted = formatTyping(e.target.value);
    setText(formatted);
    if (formatted === "") {
      setVal("");
      return;
    }
    const iso = parseFrToIso(formatted);
    if (iso && !outOfRange(iso)) {
      setVal(iso);
      const p = parseIso(iso)!;
      setView({ y: p.y, m: p.m - 1 }); // aligne le calendrier sur la saisie
    }
  }
  function onInputFocus() {
    editingRef.current = true;
  }
  function onInputBlur() {
    editingRef.current = false;
    if (text === "") {
      setVal("");
      return;
    }
    const iso = parseFrToIso(text);
    if (iso && !outOfRange(iso)) {
      setVal(iso);
      setText(formatFr(iso)); // normalise (zéros de tête)
    } else {
      setText(formatFr(val)); // saisie invalide/incomplète → on restaure
    }
  }
  function onInputKeyDown(e: React.KeyboardEvent) {
    if (e.key === "ArrowDown" && !open) {
      e.preventDefault();
      openCal();
    } else if (e.key === "Enter" && open) {
      e.preventDefault();
      closeCal();
    }
  }

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
  function outOfRange(iso: string) {
    return (!!min && iso < min) || (!!max && iso > max);
  }

  function selectDay(iso: string) {
    if (outOfRange(iso)) return;
    setVal(iso);
    setText(formatFr(iso));
    closeCal();
    inputRef.current?.focus();
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

      <div
        className={cn(
          "group flex w-full h-11 items-center gap-2 rounded-xl border bg-white px-3.5 text-[15px]",
          "dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))]",
          "transition-[border-color,box-shadow] duration-150 ease-premium",
          "focus-within:outline-none focus-within:ring-2 focus-within:ring-navy-600/15 focus-within:border-navy-600",
          "dark:focus-within:border-signal-500 dark:focus-within:ring-signal-500/20",
          disabled &&
            "bg-navy-50 text-slate-400 cursor-not-allowed dark:bg-[hsl(var(--surface-2))]",
          open &&
            "border-navy-600 ring-2 ring-navy-600/15 dark:border-signal-500 dark:ring-signal-500/20",
          !open && invalid && "border-rose-400 ring-2 ring-rose-500/15",
          !open && !invalid && "border-navy-200"
        )}
      >
        <input
          ref={inputRef}
          id={fieldId}
          type="text"
          inputMode="numeric"
          autoComplete="off"
          disabled={disabled}
          value={text}
          onChange={onType}
          onFocus={onInputFocus}
          onBlur={onInputBlur}
          onKeyDown={onInputKeyDown}
          placeholder={placeholder}
          maxLength={10}
          aria-label={ariaLabel}
          aria-invalid={invalid || undefined}
          className={cn(
            "min-w-0 flex-1 bg-transparent tabular-nums outline-none",
            "text-navy-900 dark:text-[hsl(var(--text))]",
            "placeholder:text-slate-400 dark:placeholder:text-[hsl(var(--text-muted))]",
            "disabled:cursor-not-allowed"
          )}
        />
        <button
          ref={triggerRef}
          type="button"
          disabled={disabled}
          onClick={() => (open ? closeCal() : openCal())}
          tabIndex={-1}
          aria-haspopup="dialog"
          aria-expanded={open}
          aria-label="Ouvrir le calendrier"
          className={cn(
            "shrink-0 -mr-1 inline-flex h-7 w-7 items-center justify-center rounded-lg transition-colors",
            "active:scale-90 motion-reduce:active:scale-100",
            "focus:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/30",
            "disabled:cursor-not-allowed",
            open
              ? "text-navy-700 dark:text-signal-400"
              : "text-slate-400 hover:text-navy-600 hover:bg-navy-50 dark:hover:bg-white/10"
          )}
        >
          <Calendar className="h-4 w-4" />
        </button>
      </div>

      {invalid && (
        <p className="mt-1.5 text-xs font-medium text-rose-600">
          Veuillez saisir ou sélectionner une date.
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
                setText("");
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
