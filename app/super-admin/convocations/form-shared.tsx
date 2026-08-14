"use client";

// =====================================================================
// Briques de formulaire du module Convocations : sections repliables,
// champs libellés, lignes à bascule (toggle), saisie d'heure.
// Cohérentes avec le design system admin (navy/lime, rayons doux).
// =====================================================================

import * as React from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";

/** Carte-section repliable : garde le formulaire léger à l'écran. */
export function Section({
  title,
  hint,
  defaultOpen = true,
  children,
}: {
  title: string;
  hint?: string;
  defaultOpen?: boolean;
  children: React.ReactNode;
}) {
  const [open, setOpen] = React.useState(defaultOpen);
  return (
    <section className="overflow-hidden rounded-2xl border border-navy-100 bg-white shadow-sm">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        aria-expanded={open}
        className={cn(
          "flex w-full items-center justify-between gap-3 px-4 py-3 text-left",
          "transition-colors duration-150 hover:bg-navy-50/50",
        )}
      >
        <span>
          <span className="font-display text-[15px] font-semibold text-navy-950">{title}</span>
          {hint && <span className="ml-2 text-xs text-slate-500">{hint}</span>}
        </span>
        <ChevronDown
          className={cn(
            "h-4 w-4 flex-none text-slate-400 transition-transform duration-200 ease-out",
            open && "rotate-180",
          )}
        />
      </button>
      {open && <div className="border-t border-navy-50 px-4 py-4">{children}</div>}
    </section>
  );
}

/** Libellé + champ, avec astérisque des champs obligatoires. */
export function Field({
  label,
  required,
  className,
  children,
}: {
  label: string;
  required?: boolean;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <label className={cn("block", className)}>
      <span className="mb-1.5 block text-xs font-semibold text-navy-900">
        {label}
        {required && <span className="text-rose-600"> *</span>}
      </span>
      {children}
    </label>
  );
}

export function Grid2({ children }: { children: React.ReactNode }) {
  return <div className="grid gap-3 sm:grid-cols-2">{children}</div>;
}

/** Ligne à bascule (consignes activables). */
export function ToggleRow({
  label,
  checked,
  onChange,
  children,
}: {
  label: string;
  checked: boolean;
  onChange: (v: boolean) => void;
  children?: React.ReactNode;
}) {
  return (
    <div className={cn("rounded-xl border px-3 py-2 transition-colors duration-150",
      checked ? "border-navy-200 bg-navy-50/40" : "border-navy-100 bg-white")}>
      <label className="flex cursor-pointer items-center gap-2.5">
        <button
          type="button"
          role="switch"
          aria-checked={checked}
          onClick={() => onChange(!checked)}
          className={cn(
            "relative h-5 w-9 flex-none rounded-full transition-colors duration-200",
            checked ? "bg-navy-900" : "bg-slate-200",
          )}
        >
          <span
            className={cn(
              "absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-transform duration-200 ease-out",
              checked ? "translate-x-[18px]" : "translate-x-0.5",
            )}
          />
        </button>
        <span className="text-[13px] text-navy-900">{label}</span>
      </label>
      {checked && children ? <div className="mt-2 pl-[46px]">{children}</div> : null}
    </div>
  );
}

/** Saisie d'heure native stylée (TimePicker). */
export function TimeInput({
  value,
  onChange,
  className,
  ...props
}: Omit<React.InputHTMLAttributes<HTMLInputElement>, "onChange"> & {
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <input
      type="time"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className={cn(
        "h-11 w-full rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 tabular-nums",
        "transition-all duration-150 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15",
        className,
      )}
      {...props}
    />
  );
}
