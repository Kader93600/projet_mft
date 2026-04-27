"use client";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { UserCheck, UserX, RotateCcw, Trash2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { useTransition } from "react";
import { deleteUser, resetUserResults, toggleUserDisabled } from "../actions";

export function UserProfileActions({
  userId,
  disabled,
  email,
}: {
  userId: string;
  disabled: boolean;
  email: string;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  function run(fn: () => Promise<any>, ok: string, afterDelete = false) {
    startTransition(async () => {
      try {
        await fn();
        toast(ok, "success");
        if (afterDelete) router.push("/admin/users");
        else router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div className="flex flex-col gap-2 shrink-0">
      <Button
        variant={disabled ? "primary" : "secondary"}
        size="sm"
        onClick={() =>
          run(
            () => toggleUserDisabled(userId, !disabled),
            disabled ? "Compte réactivé" : "Compte désactivé"
          )
        }
        disabled={isPending}
      >
        {disabled ? (
          <>
            <UserCheck className="h-4 w-4" /> Réactiver
          </>
        ) : (
          <>
            <UserX className="h-4 w-4" /> Désactiver
          </>
        )}
      </Button>
      <Button
        variant="secondary"
        size="sm"
        onClick={() => {
          if (confirm("Réinitialiser tous les résultats de quiz et progression ?"))
            run(() => resetUserResults(userId), "Résultats réinitialisés");
        }}
        disabled={isPending}
      >
        <RotateCcw className="h-4 w-4" /> Réinitialiser
      </Button>
      <Button
        variant="danger"
        size="sm"
        onClick={() => {
          if (
            confirm(
              `Supprimer définitivement le compte "${email}" ? Cette action est irréversible.`
            )
          )
            run(() => deleteUser(userId), "Compte supprimé", true);
        }}
        disabled={isPending}
      >
        <Trash2 className="h-4 w-4" /> Supprimer
      </Button>
    </div>
  );
}
