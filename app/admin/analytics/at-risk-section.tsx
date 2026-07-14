"use client";

import { useState, useTransition } from "react";
import Link from "next/link";
import {
  AlertTriangle,
  Mail,
  CheckCircle2,
  Loader2,
  AlertCircle,
  ChevronRight,
} from "lucide-react";
import { sendInactivityReminder } from "./actions";
import { accentVars } from "@/lib/formation-accent";

interface AtRiskRow {
  user_id: string;
  email: string;
  full_name: string | null;
  formation_slug: string;
  formation_title: string;
  formation_code: string;
  accent_color: string | null;
  pack: string;
  enrolled_at: string;
  last_active_at: string | null;
  days_inactive: number;
}

export function AtRiskSection({ rows }: { rows: AtRiskRow[] }) {
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [sent, setSent] = useState<Set<string>>(new Set());
  const [errors, setErrors] = useState<Map<string, string>>(new Map());
  const [, startTransition] = useTransition();
  const [showAll, setShowAll] = useState(false);

  if (rows.length === 0) {
    return (
      <div className="rounded-2xl border border-emerald-200 bg-emerald-50/40 p-6 text-center">
        <CheckCircle2 className="h-8 w-8 text-emerald-600 mx-auto mb-2" />
        <p className="text-sm font-semibold text-emerald-900">
          Aucun stagiaire à risque
        </p>
        <p className="text-xs text-emerald-700 mt-1">
          Tous vos stagiaires inscrits ont une activité dans les 14 derniers jours.
        </p>
      </div>
    );
  }

  const visible = showAll ? rows : rows.slice(0, 5);

  function sendReminder(row: AtRiskRow) {
    setPendingId(row.user_id);
    setErrors((m) => {
      const next = new Map(m);
      next.delete(row.user_id);
      return next;
    });
    startTransition(async () => {
      try {
        const result = await sendInactivityReminder(
          row.email,
          row.full_name,
          row.days_inactive,
          row.formation_title
        );
        if (result.ok) {
          setSent((s) => new Set(s).add(row.user_id));
        } else {
          setErrors((m) => new Map(m).set(row.user_id, "Échec d'envoi"));
        }
      } catch (e: any) {
        setErrors((m) => new Map(m).set(row.user_id, e.message ?? "Erreur"));
      } finally {
        setPendingId(null);
      }
    });
  }

  return (
    <div className="rounded-2xl border border-rose-200 bg-white overflow-hidden">
      <div className="px-5 py-3 bg-rose-50/50 border-b border-rose-200 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center gap-2">
          <AlertTriangle className="h-4 w-4 text-rose-700" />
          <h3 className="font-display font-semibold text-rose-900">
            Stagiaires à risque
          </h3>
          <span className="text-xs text-rose-700 bg-rose-100 border border-rose-200 rounded-md px-1.5 py-0.5 font-semibold">
            {rows.length}
          </span>
        </div>
        <span className="text-[11px] text-slate-500">
          Inactifs &gt; 14 jours · inscription en cours
        </span>
      </div>
      <ul className="divide-y divide-navy-50">
        {visible.map((r) => {
          const isSent = sent.has(r.user_id);
          const isPending = pendingId === r.user_id;
          const error = errors.get(r.user_id);
          return (
            <li key={r.user_id} className="px-5 py-3 hover:bg-ivory/40">
              <div className="flex items-center gap-3 flex-wrap">
                <Link
                  href={`/admin/users/${r.user_id}`}
                  className="flex-1 min-w-0 group"
                >
                  <div className="font-medium text-navy-900 truncate group-hover:text-rose-700">
                    {r.full_name || r.email}
                  </div>
                  <div className="text-xs text-slate-500 truncate inline-flex items-center gap-2">
                    <span>{r.email}</span>
                    <span>·</span>
                    <span
                      className="formation-accent inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold"
                      style={accentVars(r.accent_color ?? "#0E1240")}
                    >
                      {r.formation_code}
                    </span>
                    <span>· pack {r.pack}</span>
                  </div>
                </Link>
                <div className="text-xs text-rose-700 font-semibold whitespace-nowrap">
                  {r.days_inactive}j inactif
                </div>
                {isSent ? (
                  <span className="inline-flex items-center gap-1 text-xs text-emerald-700 font-medium">
                    <CheckCircle2 className="h-3.5 w-3.5" />
                    Relance envoyée
                  </span>
                ) : (
                  <button
                    type="button"
                    onClick={() => sendReminder(r)}
                    disabled={isPending}
                    className="inline-flex items-center gap-1.5 px-3 h-8 rounded-lg text-xs font-semibold bg-rose-100 text-rose-900 border border-rose-200 hover:bg-rose-200 transition disabled:opacity-50"
                  >
                    {isPending ? (
                      <Loader2 className="h-3.5 w-3.5 animate-spin" />
                    ) : (
                      <Mail className="h-3.5 w-3.5" />
                    )}
                    Relancer
                  </button>
                )}
              </div>
              {error && (
                <div className="mt-1 inline-flex items-center gap-1 text-[11px] text-rose-700">
                  <AlertCircle className="h-3 w-3" />
                  {error}
                </div>
              )}
            </li>
          );
        })}
      </ul>
      {rows.length > 5 && (
        <div className="px-5 py-2 border-t border-navy-100 bg-ivory text-center">
          <button
            type="button"
            onClick={() => setShowAll(!showAll)}
            className="text-[12px] font-semibold text-rose-700 hover:text-rose-900 inline-flex items-center gap-1"
          >
            {showAll ? "Réduire" : `Voir les ${rows.length - 5} autres`}
            <ChevronRight
              className={"h-3 w-3 transition " + (showAll ? "rotate-90" : "")}
            />
          </button>
        </div>
      )}
    </div>
  );
}
