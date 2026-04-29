"use client";
import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Loader2, Power } from "lucide-react";
import { activateAllQrsForFormation } from "./actions";

export function ActivateAllButton({
  formationSlug,
  count,
}: {
  formationSlug: string;
  count: number;
}) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();

  function onClick() {
    if (
      !confirm(
        `Activer en lot les ${count} QR inactives ? Les questions deviendront immédiatement disponibles pour les quiz.`
      )
    )
      return;
    startTransition(async () => {
      try {
        const n = await activateAllQrsForFormation(formationSlug);
        alert(`✅ ${n} QR activées.`);
        router.refresh();
      } catch (e: any) {
        alert(e.message);
      }
    });
  }

  return (
    <Button onClick={onClick} disabled={pending} variant="gold">
      {pending ? (
        <>
          <Loader2 className="h-4 w-4 animate-spin" /> Activation…
        </>
      ) : (
        <>
          <Power className="h-4 w-4" /> Tout activer ({count})
        </>
      )}
    </Button>
  );
}
