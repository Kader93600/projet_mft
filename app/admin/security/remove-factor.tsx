"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Trash2 } from "lucide-react";

export function RemoveFactorButton({ factorId }: { factorId: string }) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function remove() {
    if (
      !confirm(
        "Supprimer ce facteur ? Vous devrez en configurer un nouveau pour rester conforme."
      )
    )
      return;
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.mfa.unenroll({ factorId });
    setLoading(false);
    if (error) {
      alert(error.message);
      return;
    }
    router.refresh();
  }

  return (
    <button
      type="button"
      onClick={remove}
      disabled={loading}
      className="ml-2 h-9 w-9 rounded-lg hover:bg-rose-50 text-slate-500 hover:text-rose-700 flex items-center justify-center disabled:opacity-50"
      aria-label="Supprimer le facteur"
    >
      <Trash2 className="h-4 w-4" />
    </button>
  );
}
