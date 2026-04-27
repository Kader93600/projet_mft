"use client";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Trash2 } from "lucide-react";
import { useTransition } from "react";
import { useRouter } from "next/navigation";
import { useToast } from "@/components/ui/toast";
import { deleteModule } from "../actions";

export function ModuleDangerZone({ moduleId }: { moduleId: string }) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  function onDelete() {
    if (!confirm("Supprimer ce module et toutes ses leçons ? Action irréversible.")) return;
    startTransition(async () => {
      try {
        await deleteModule(moduleId);
        toast("Module supprimé", "success");
        router.push("/admin/modules");
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <Card className="border-rose-100">
      <div className="px-6 pt-5 pb-2 border-b border-rose-100">
        <CardTitle className="text-base text-rose-700">Zone sensible</CardTitle>
      </div>
      <CardBody>
        <p className="text-xs text-slate-600 mb-3">
          La suppression est définitive et entraîne la perte de toutes les leçons et quiz associés.
        </p>
        <Button variant="danger" size="sm" onClick={onDelete} disabled={isPending}>
          <Trash2 className="h-4 w-4" /> Supprimer le module
        </Button>
      </CardBody>
    </Card>
  );
}
