"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

/**
 * Mini-dropdown réutilisable pour affecter une question (QCM ou QR) à
 * un chapitre / module en 1 clic. Met à jour `question_bank.tags` :
 * retire l'ancien tag de groupe (basé sur filterConfig.tagPrefix), ajoute
 * le nouveau.
 *
 * S'utilise dans :
 *   - /admin/banque-questions/liste (liste compacte)
 *   - /admin/banque-questions/liste/[id]/edit-form (page d'édition)
 *
 * Le filterConfig doit être pré-sérialisé côté server (entries).
 */
export function GroupAssignSelect({
  questionId,
  currentTags,
  filterConfig,
  size = "sm",
}: {
  questionId: string;
  currentTags: string[];
  filterConfig: {
    tagPrefix: string;
    label: string;
    entries: Array<{ key: string; pill: string; long: string }>;
  };
  size?: "sm" | "md";
}) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();
  const currentTag = currentTags.find((t) => t.startsWith(filterConfig.tagPrefix));
  const currentKey = currentTag
    ? currentTag.slice(filterConfig.tagPrefix.length)
    : "";
  const [groupKey, setGroupKey] = useState(currentKey);

  function onChange(newKey: string) {
    setGroupKey(newKey);
    startTransition(async () => {
      const supabase = createClient();
      const baseTags = currentTags.filter(
        (t) => !t.startsWith(filterConfig.tagPrefix),
      );
      const nextTags = newKey
        ? [...baseTags, `${filterConfig.tagPrefix}${newKey}`]
        : baseTags;
      const { error } = await supabase
        .from("question_bank")
        .update({ tags: nextTags })
        .eq("id", questionId);
      if (error) {
        alert(error.message);
        setGroupKey(currentKey); // rollback
        return;
      }
      router.refresh();
    });
  }

  // Détecte un tag legacy hors config (ex. "ch01" historique) pour ne
  // pas le perdre dans la liste d'options.
  const hasExtra =
    !!currentKey &&
    !filterConfig.entries.some((e) => e.key === currentKey);

  const classBase =
    size === "sm"
      ? "h-6 px-1.5 rounded text-[10.5px] font-bold border"
      : "h-8 px-2 rounded-md text-[12px] font-semibold border";

  return (
    <select
      value={groupKey}
      onChange={(e) => onChange(e.target.value)}
      disabled={pending}
      className={
        classBase +
        " transition focus:outline-none focus:ring-2 focus:ring-navy-300 disabled:opacity-50 " +
        (groupKey
          ? "bg-navy-900 text-white border-navy-900"
          : "bg-amber-50 text-amber-800 border-amber-300 hover:border-amber-400")
      }
      title={
        groupKey
          ? `Affectée à : ${filterConfig.entries.find((e) => e.key === groupKey)?.long ?? groupKey}`
          : `Non affectée — cliquer pour choisir un ${filterConfig.label.toLowerCase()}`
      }
    >
      <option value="">— affecter —</option>
      {filterConfig.entries.map((e) => (
        <option key={e.key} value={e.key}>
          {e.pill}
        </option>
      ))}
      {hasExtra && (
        <option value={currentKey}>{currentKey} (legacy)</option>
      )}
    </select>
  );
}
