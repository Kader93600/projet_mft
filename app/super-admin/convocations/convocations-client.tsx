"use client";

// =====================================================================
// Shell du module Convocations : quatre onglets (Candidats, Jurys,
// Génération en masse, Historique). L'édition ou la duplication depuis
// l'historique recharge le formulaire correspondant.
// =====================================================================

import * as React from "react";
import { GraduationCap, Users2, Layers, History } from "lucide-react";
import { cn } from "@/lib/utils";
import type { ConvocationPayload, ConvocationRow } from "@/lib/convocations";
import type { LieuRow } from "./actions";
import { ConvocationForm, type FormationOption } from "./convocation-form";
import { MasseTab } from "./masse";
import { HistoriqueTab } from "./historique";

type Tab = "candidat" | "jury" | "masse" | "historique";

const TABS: Array<{ id: Tab; label: string; icon: React.ComponentType<{ className?: string }> }> = [
  { id: "candidat", label: "Convocations candidats", icon: GraduationCap },
  { id: "jury", label: "Convocations jurys", icon: Users2 },
  { id: "masse", label: "Génération en masse", icon: Layers },
  { id: "historique", label: "Historique", icon: History },
];

export function ConvocationsClient({
  formations,
  lieux,
  history,
}: {
  formations: FormationOption[];
  lieux: LieuRow[];
  history: ConvocationRow[];
}) {
  const [tab, setTab] = React.useState<Tab>("candidat");
  const [refreshKey, setRefreshKey] = React.useState(0);
  // Pré-chargement du formulaire depuis l'historique (Modifier / Dupliquer)
  const [loaded, setLoaded] = React.useState<{
    payload: ConvocationPayload; editId?: string; key: number;
  } | null>(null);

  const bump = React.useCallback(() => setRefreshKey((k) => k + 1), []);

  function openInForm(row: ConvocationRow, edit: boolean) {
    setLoaded({
      payload: edit ? row.payload : { ...row.payload, reference: "" },
      editId: edit ? row.id : undefined,
      key: Date.now(),
    });
    setTab(row.kind);
  }

  return (
    <div className="space-y-5">
      <div role="tablist" aria-label="Sections des convocations"
        className="flex flex-wrap gap-1 rounded-2xl border border-navy-100 bg-white p-1 shadow-sm">
        {TABS.map(({ id, label, icon: Icon }) => (
          <button
            key={id}
            role="tab"
            aria-selected={tab === id}
            onClick={() => setTab(id)}
            className={cn(
              "inline-flex items-center gap-2 rounded-xl px-3.5 py-2 text-[13px] font-semibold",
              "transition-colors duration-150 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/30",
              tab === id
                ? "bg-navy-950 text-white shadow-sm"
                : "text-slate-600 hover:bg-navy-50 hover:text-navy-900",
            )}
          >
            <Icon className="h-4 w-4" />
            {label}
          </button>
        ))}
      </div>

      {tab === "candidat" && (
        <ConvocationForm
          key={loaded && loaded.payload.kind === "candidat" ? loaded.key : "candidat"}
          kind="candidat"
          formations={formations}
          lieux={lieux}
          initial={loaded?.payload.kind === "candidat" ? loaded.payload : undefined}
          editId={loaded?.payload.kind === "candidat" ? loaded.editId : undefined}
          onSaved={bump}
        />
      )}
      {tab === "jury" && (
        <ConvocationForm
          key={loaded && loaded.payload.kind === "jury" ? loaded.key : "jury"}
          kind="jury"
          formations={formations}
          lieux={lieux}
          initial={loaded?.payload.kind === "jury" ? loaded.payload : undefined}
          editId={loaded?.payload.kind === "jury" ? loaded.editId : undefined}
          onSaved={bump}
        />
      )}
      {tab === "masse" && (
        <MasseTab formations={formations} lieux={lieux} onSaved={bump} />
      )}
      {tab === "historique" && (
        <HistoriqueTab
          initial={history}
          refreshKey={refreshKey}
          onEdit={(r) => openInForm(r, true)}
          onDuplicate={(r) => openInForm(r, false)}
        />
      )}
    </div>
  );
}
