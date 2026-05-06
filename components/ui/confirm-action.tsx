"use client";

import { useState, useTransition, type ReactNode } from "react";
import { Dialog, DialogHeader, DialogBody, DialogFooter } from "./dialog";
import { useToast } from "./toast";
import { Loader2 } from "lucide-react";

/**
 * Bouton avec confirmation modale réutilisable.
 *
 * Remplace `confirm()` natif par un dialog brand-aligned (cohérent
 * avec la charte ivory/navy/rose).
 *
 * Utilisation typique pour une action destructive :
 *   <ConfirmAction
 *     action={deleteEnrollment.bind(null, e.id)}
 *     title="Supprimer le dossier ?"
 *     description={`Supprime définitivement le dossier de ${e.user?.full_name}.`}
 *     confirmLabel="Supprimer"
 *     successMsg="Dossier supprimé"
 *     icon={<Trash2 className="h-3.5 w-3.5" />}
 *     iconLabel="Supprimer définitivement"
 *     tone="rose"
 *     variant="solid"
 *   />
 *
 * Le bouton se rend lui-même (icône 28×28, classes harmonisées avec
 * les autres ActionBtn). Au clic → modal. Au "Confirmer" →
 * exécution dans une transition + toast succès/erreur + fermeture.
 */
export function ConfirmAction({
  action,
  title,
  description,
  confirmLabel = "Confirmer",
  successMsg,
  icon,
  iconLabel,
  tone = "rose",
  variant = "soft",
  disabled = false,
}: {
  action: () => Promise<unknown>;
  title: string;
  description: string;
  confirmLabel?: string;
  successMsg?: string;
  icon: ReactNode;
  iconLabel: string;
  tone?: "navy" | "gold" | "rose";
  variant?: "soft" | "solid";
  disabled?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [isPending, startTransition] = useTransition();
  const { toast } = useToast();

  const palette: Record<string, string> = {
    navy:
      variant === "solid"
        ? "bg-navy-900 text-white hover:bg-navy-800 border-transparent"
        : "border-navy-200 text-navy-800 hover:bg-navy-50",
    gold:
      variant === "solid"
        ? "bg-gold-600 text-white hover:bg-gold-700 border-transparent"
        : "border-gold-200 text-gold-800 hover:bg-gold-50",
    rose:
      variant === "solid"
        ? "bg-rose-600 text-white hover:bg-rose-700 border-transparent"
        : "border-rose-200 text-rose-700 hover:bg-rose-50",
  };

  const isDanger = tone === "rose";

  function handleConfirm() {
    startTransition(async () => {
      try {
        await action();
        if (successMsg) toast(successMsg, "success");
        setOpen(false);
      } catch (e: any) {
        toast(e?.message ?? "Erreur lors de l'opération", "error");
      }
    });
  }

  return (
    <>
      <button
        type="button"
        title={iconLabel}
        aria-label={iconLabel}
        onClick={() => setOpen(true)}
        disabled={disabled}
        className={`inline-flex h-7 w-7 items-center justify-center rounded-lg border transition disabled:opacity-50 ${palette[tone]}`}
      >
        {icon}
      </button>

      <Dialog open={open} onClose={() => !isPending && setOpen(false)} size="sm">
        <DialogHeader
          title={title}
          description={description}
          onClose={isPending ? undefined : () => setOpen(false)}
        />
        <DialogBody className="text-sm text-slate-600">
          {isDanger && (
            <p className="rounded-lg border border-rose-200 bg-rose-50/60 px-3 py-2 text-[13px] text-rose-800">
              Cette action est <strong>irréversible</strong>.
            </p>
          )}
        </DialogBody>
        <DialogFooter>
          <button
            type="button"
            onClick={() => setOpen(false)}
            disabled={isPending}
            className="h-9 px-4 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-100 transition disabled:opacity-50"
          >
            Annuler
          </button>
          <button
            type="button"
            onClick={handleConfirm}
            disabled={isPending}
            className={`h-9 px-4 rounded-lg text-sm font-semibold inline-flex items-center gap-2 transition disabled:opacity-50 ${
              isDanger
                ? "bg-rose-600 text-white hover:bg-rose-700"
                : "bg-navy-900 text-white hover:bg-navy-800"
            }`}
          >
            {isPending && <Loader2 className="h-3.5 w-3.5 animate-spin" />}
            {confirmLabel}
          </button>
        </DialogFooter>
      </Dialog>
    </>
  );
}
