"use client";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { UserCheck, UserX, RotateCcw, Trash2, Send } from "lucide-react";
import { useRouter } from "next/navigation";
import { useTransition } from "react";
import {
  deleteUser,
  resetUserResults,
  toggleUserDisabled,
  resendUserInvitation,
} from "../actions";

export function UserProfileActions({
  userId,
  disabled,
  email,
  neverSignedIn = false,
}: {
  userId: string;
  disabled: boolean;
  email: string;
  neverSignedIn?: boolean;
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
      {neverSignedIn && !disabled && (
        <Button
          variant="secondary"
          size="sm"
          onClick={() =>
            run(
              () => resendUserInvitation(userId),
              "Invitation renvoyée"
            )
          }
          disabled={isPending}
          className="bg-brand-50 text-brand-700 border-brand-200 hover:bg-brand-100 hover:border-brand-300 hover:text-brand-800"
        >
          <Send className="h-4 w-4" /> Renvoyer l'invitation
        </Button>
      )}
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
            run(
              async () => {
                const res = await deleteUser(userId);
                if (!res.ok) throw new Error(res.error);
              },
              "Compte supprimé",
              true
            );
        }}
        disabled={isPending}
      >
        <Trash2 className="h-4 w-4" /> Supprimer
      </Button>
    </div>
  );
}
