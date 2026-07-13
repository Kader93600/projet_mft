"use client";
import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Loader2, Power, PowerOff } from "lucide-react";
import { bulkSetActive } from "./actions";

/**
 * Barre d'action en masse sur le périmètre FILTRÉ courant (formation +
 * type + module). Permet d'activer / désactiver toutes les questions
 * concernées d'un coup — indispensable pour valider les centaines de QCM
 * sans les basculer une par une.
 */
export function BulkActiveBar({
  filter,
  scopeLabel,
}: {
  filter: { f: string; type?: string; module?: string };
  scopeLabel: string;
}) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();

  function run(active: boolean) {
    const verb = active ? "Activer" : "Désactiver";
    const cible = active ? "inactives" : "actives";
    if (
      !confirm(
        `${verb} en masse toutes les questions ${cible} du périmètre « ${scopeLabel} » ?\n\n` +
          `Elles deviendront ${active ? "immédiatement disponibles" : "indisponibles"} pour les quiz.`
      )
    )
      return;
    startTransition(async () => {
      try {
        const n = await bulkSetActive(filter, active);
        alert(`✅ ${n} question(s) ${active ? "activée(s)" : "désactivée(s)"}.`);
        router.refresh();
      } catch (e: any) {
        alert(e?.message ?? "Échec de l'opération.");
      }
    });
  }

  return (
    <div className="flex flex-wrap items-center gap-2 rounded-xl border border-navy-100 bg-navy-50/60 px-4 py-3">
      <span className="text-sm text-slate-600">
        Action en masse sur{" "}
        <strong className="text-navy-900">{scopeLabel}</strong> :
      </span>
      <Button
        size="sm"
        variant="gold"
        disabled={pending}
        onClick={() => run(true)}
      >
        {pending ? (
          <Loader2 className="h-4 w-4 animate-spin" />
        ) : (
          <Power className="h-4 w-4" />
        )}
        Activer le lot
      </Button>
      <Button
        size="sm"
        variant="secondary"
        disabled={pending}
        onClick={() => run(false)}
      >
        <PowerOff className="h-4 w-4" /> Désactiver le lot
      </Button>
    </div>
  );
}
