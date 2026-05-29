"use client";

import { Mail } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useEmailComposer } from "@/components/email/email-composer-provider";

export function ContactButton({
  email,
  fullName,
  userId,
  formation,
}: {
  email: string;
  fullName?: string | null;
  userId: string;
  formation?: string | null;
}) {
  const composer = useEmailComposer();
  const fn = fullName ?? "";
  const [firstName, ...rest] = fn.split(" ");
  return (
    <Button
      variant="secondary"
      size="sm"
      onClick={() =>
        composer.open({
          to: email,
          relatedUserId: userId,
          variables: {
            prenom: firstName || fn,
            nom: rest.join(" "),
            formation: formation ?? "",
          },
        })
      }
    >
      <Mail className="h-4 w-4" /> Contacter
    </Button>
  );
}
