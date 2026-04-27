import {
  Bookmark,
  AlertTriangle,
  Briefcase,
  Lightbulb,
  Target,
} from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Mémo — fiche-mémo récapitulative en fin de section.
 */
export function Memo({
  title,
  children,
}: {
  title?: string;
  children: React.ReactNode;
}) {
  return (
    <aside className="my-6 rounded-2xl border border-brand-200 bg-gradient-to-br from-brand-50 to-white p-5 md:p-6 relative overflow-hidden">
      <div
        aria-hidden="true"
        className="absolute -top-10 -right-10 h-32 w-32 rounded-full bg-brand-200/40 blur-2xl"
      />
      <div className="relative">
        <div className="flex items-center gap-2 mb-3">
          <div className="h-9 w-9 rounded-xl bg-brand-600 text-white flex items-center justify-center">
            <Bookmark className="h-4 w-4" />
          </div>
          <div>
            <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-brand-700">
              Fiche mémo
            </div>
            {title && (
              <div className="font-display font-semibold text-navy-900">
                {title}
              </div>
            )}
          </div>
        </div>
        <div className="text-sm text-navy-900 leading-relaxed">{children}</div>
      </div>
    </aside>
  );
}

/**
 * Piège examen — point de vigilance pour ne pas tomber dans une erreur fréquente.
 */
export function Piege({
  title = "Piège examen",
  children,
}: {
  title?: string;
  children: React.ReactNode;
}) {
  return (
    <aside className="my-6 rounded-2xl border-2 border-rose-200 bg-rose-50 p-5">
      <div className="flex items-start gap-3">
        <div className="h-9 w-9 rounded-xl bg-rose-600 text-white flex items-center justify-center shrink-0">
          <AlertTriangle className="h-4 w-4" />
        </div>
        <div className="flex-1">
          <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-rose-700">
            ⚠ {title}
          </div>
          <div className="mt-2 text-sm text-rose-950 leading-relaxed">
            {children}
          </div>
        </div>
      </div>
    </aside>
  );
}

/**
 * Cas pratique — exemple terrain concret pour ancrer la théorie.
 */
export function CasPratique({
  title,
  children,
}: {
  title?: string;
  children: React.ReactNode;
}) {
  return (
    <aside className="my-6 rounded-2xl border border-amber-200 bg-amber-50 p-5">
      <div className="flex items-start gap-3">
        <div className="h-9 w-9 rounded-xl bg-amber-500 text-white flex items-center justify-center shrink-0">
          <Briefcase className="h-4 w-4" />
        </div>
        <div className="flex-1">
          <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-amber-800">
            Cas terrain
          </div>
          {title && (
            <div className="mt-1 font-display font-semibold text-navy-900">
              {title}
            </div>
          )}
          <div className="mt-2 text-sm text-navy-900 leading-relaxed">
            {children}
          </div>
        </div>
      </div>
    </aside>
  );
}

/**
 * Conseil méthodologique — astuce pour bien aborder l'examen.
 */
export function Conseil({
  title = "Conseil méthodologique",
  children,
}: {
  title?: string;
  children: React.ReactNode;
}) {
  return (
    <aside className="my-6 rounded-2xl border border-signal-300 bg-signal-50 p-5">
      <div className="flex items-start gap-3">
        <div className="h-9 w-9 rounded-xl bg-signal-500 text-night flex items-center justify-center shrink-0">
          <Lightbulb className="h-4 w-4" />
        </div>
        <div className="flex-1">
          <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-signal-800">
            💡 {title}
          </div>
          <div className="mt-2 text-sm text-navy-900 leading-relaxed">
            {children}
          </div>
        </div>
      </div>
    </aside>
  );
}

/**
 * Objectifs pédagogiques — affichés en début de leçon.
 */
export function Objectifs({
  items,
}: {
  items: string[];
}) {
  return (
    <aside className="my-6 rounded-2xl border border-navy-100 bg-white p-5">
      <div className="flex items-center gap-2 mb-3">
        <Target className="h-4 w-4 text-brand-700" />
        <div className="text-[10px] font-semibold uppercase tracking-[0.18em] text-brand-700">
          Objectifs de cette leçon
        </div>
      </div>
      <ul className="space-y-1.5">
        {items.map((item, i) => (
          <li
            key={i}
            className="flex items-start gap-2 text-sm text-navy-900"
          >
            <span className="mt-1.5 h-1.5 w-1.5 rounded-full bg-signal-500 shrink-0" />
            <span>{item}</span>
          </li>
        ))}
      </ul>
    </aside>
  );
}
