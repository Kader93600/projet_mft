import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { FormationForm } from "./formation-form";
import { Settings } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function FormationSettingsPage() {
  const supabase = createClient();
  const { data: settings } = await supabase
    .from("formation_settings")
    .select("*")
    .eq("id", true)
    .single();

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Qualiopi · Paramètres</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Programme de formation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Informations de référence utilisées pour générer les documents
          officiels (programme, attestations, certificats, feuilles de présence).
        </p>
      </header>

      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center gap-2">
          <Settings className="h-4 w-4 text-slate-500" />
          <CardTitle className="text-base">Paramètres</CardTitle>
        </div>
        <CardBody>
          <FormationForm initial={settings} />
        </CardBody>
      </Card>
    </div>
  );
}
