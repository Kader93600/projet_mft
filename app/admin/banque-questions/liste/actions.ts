"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { isStaff } from "@/lib/permissions";
import { findFormation } from "@/lib/formations-config";
import { getQuestionFilterConfig } from "@/lib/question-filters";

async function ensureStaff() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role, disabled")
    .eq("id", user.id)
    .single();
  if (profile?.disabled) throw new Error("Compte désactivé");
  if (!isStaff(profile?.role)) throw new Error("Réservé au personnel");
  return { supabase };
}

/**
 * Active / désactive EN MASSE toutes les questions correspondant au filtre
 * courant de la liste (formation + type + module). Ne bascule QUE celles qui
 * en ont besoin (`eq active = !target`) → le compteur renvoyé reflète le vrai
 * nombre de lignes modifiées.
 *
 * Garde-fou : une formation DOIT être sélectionnée pour éviter d'activer/
 * désactiver l'ensemble de la banque par accident.
 */
export async function bulkSetActive(
  filter: { f: string; type?: string; module?: string },
  active: boolean
): Promise<number> {
  const { supabase } = await ensureStaff();
  if (!filter.f) {
    throw new Error("Sélectionnez d'abord une formation.");
  }
  const conf = findFormation(filter.f);
  if (!conf) throw new Error("Formation inconnue.");

  const { data: dbF } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", filter.f)
    .single();
  if (!dbF) throw new Error("Formation introuvable en base.");

  let q = supabase
    .from("question_bank")
    .update({ active }, { count: "exact" })
    .eq("formation_id", dbF.id)
    .eq("active", !active);

  if (filter.type === "qcm" || filter.type === "qr") {
    q = q.eq("type", filter.type);
  }
  if (filter.module) {
    const cfg = getQuestionFilterConfig(filter.f);
    q = q.contains("tags", [`${cfg.tagPrefix}${filter.module}`]);
  }

  const { error, count } = await q;
  if (error) throw new Error(error.message);

  revalidatePath("/admin/banque-questions/liste");
  revalidatePath("/admin/banque-questions");
  return count ?? 0;
}
