"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Check, Loader2 } from "lucide-react";

const ROLES = [
  { value: "student", label: "Stagiaire" },
  { value: "trainer", label: "Formateur" },
  { value: "admin", label: "Admin" },
  { value: "super_admin", label: "Super-admin" },
];

export function RoleSelect({
  userId,
  currentRole,
}: {
  userId: string;
  currentRole: string;
}) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<"idle" | "ok" | "error">("idle");

  function onChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const newRole = e.target.value;
    if (newRole === currentRole) return;
    if (
      !confirm(
        `Confirmer le changement de rôle vers "${newRole}" ? Cette action est journalisée.`
      )
    ) {
      e.target.value = currentRole;
      return;
    }
    startTransition(async () => {
      const supabase = createClient();
      const { error } = await supabase.rpc("update_user_role", {
        p_user: userId,
        p_role: newRole,
      });
      if (error) {
        alert("Erreur : " + error.message);
        setFeedback("error");
        e.target.value = currentRole;
        setTimeout(() => setFeedback("idle"), 2500);
        return;
      }
      setFeedback("ok");
      router.refresh();
      setTimeout(() => setFeedback("idle"), 2000);
    });
  }

  return (
    <div className="inline-flex items-center gap-2">
      <select
        defaultValue={currentRole}
        disabled={pending}
        onChange={onChange}
        className="rounded-lg border border-navy-200 bg-white px-2.5 py-1 text-xs font-medium text-navy-900 disabled:opacity-50"
      >
        {ROLES.map((r) => (
          <option key={r.value} value={r.value}>
            {r.label}
          </option>
        ))}
      </select>
      {pending && <Loader2 className="h-3.5 w-3.5 animate-spin text-slate-400" />}
      {feedback === "ok" && <Check className="h-3.5 w-3.5 text-emerald-600" />}
    </div>
  );
}
