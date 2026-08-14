// =====================================================================
// /super-admin/convocations — Génération de convocations PDF
// (candidats et jurys) : formulaires préremplis depuis les données de
// l'application, aperçu temps réel, 3 modèles, génération en masse
// avec planning automatique, historique avec statuts.
// L'accès super-admin est garanti par app/super-admin/layout.tsx.
// =====================================================================

import { createAdminClient } from "@/lib/supabase/admin";
import type { ConvocationRow } from "@/lib/convocations";
import type { Tables } from "@/lib/database.types";
import { ConvocationsClient } from "./convocations-client";
import type { LieuRow } from "./actions";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "Convocations PDF — Super admin",
  robots: { index: false, follow: false },
};

export default async function ConvocationsPage() {
  const service = createAdminClient();
  const [{ data: formations }, { data: lieux }, { data: history }] = await Promise.all([
    service.from("formations").select("id, title").order("title"),
    service
      .from("convocation_locations")
      .select("id, name, address, postal_code, city, room, floor, access_info")
      .order("created_at"),
    service
      .from("convocations")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(200),
  ]);

  const formationRows = (formations ?? []) as Pick<Tables<"formations">, "id" | "title">[];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Convocations PDF
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Préparez une convocation d'examen en quelques clics : les informations des candidats,
          jurys, formations et lieux sont préremplies depuis l'application.
        </p>
      </div>
      <ConvocationsClient
        formations={formationRows}
        lieux={(lieux ?? []) as LieuRow[]}
        history={(history ?? []) as unknown as ConvocationRow[]}
      />
    </div>
  );
}
