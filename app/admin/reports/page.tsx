import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ReportsPanel } from "./reports-panel";
import { FileText, BookMarked, ClipboardCheck, Settings } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function ReportsPage() {
  const supabase = await createClient();
  const { data: users } = await supabase
    .from("user_training_summary")
    .select("*")
    .order("full_name", { nullsFirst: false });

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Qualiopi · Rapports</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Preuves de formation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Feuilles de présence et attestations de formation conformes aux
          obligations Qualiopi pour le distanciel.
        </p>
      </header>

      {/* Documents globaux + Accès rapides */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card>
          <CardBody>
            <div className="flex items-start gap-3 mb-3">
              <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
                <BookMarked className="h-4 w-4" />
              </div>
              <div>
                <CardTitle className="text-base mb-1">
                  Programme de formation
                </CardTitle>
                <p className="text-xs text-slate-600">
                  Document de référence : objectifs, public, prérequis,
                  méthodes, modalités d'évaluation.
                </p>
              </div>
            </div>
            <div className="flex gap-2">
              <a
                href="/admin/reports/export/programme"
                target="_blank"
                className="flex-1"
              >
                <Button variant="secondary" size="sm" className="w-full">
                  <FileText className="h-3.5 w-3.5" /> Télécharger PDF
                </Button>
              </a>
              <Link href="/admin/settings/formation">
                <Button variant="ghost" size="sm">
                  <Settings className="h-3.5 w-3.5" /> Éditer
                </Button>
              </Link>
            </div>
          </CardBody>
        </Card>

        <Card>
          <CardBody>
            <div className="flex items-start gap-3 mb-3">
              <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-800 flex items-center justify-center">
                <ClipboardCheck className="h-4 w-4" />
              </div>
              <div>
                <CardTitle className="text-base mb-1">
                  Enquêtes de satisfaction
                </CardTitle>
                <p className="text-xs text-slate-600">
                  Évaluations à chaud (fin de parcours) et à froid (plusieurs
                  mois après). Note moyenne, NPS, commentaires.
                </p>
              </div>
            </div>
            <Link href="/admin/reports/surveys">
              <Button variant="secondary" size="sm" className="w-full">
                Voir les évaluations
              </Button>
            </Link>
          </CardBody>
        </Card>

        <Card variant="gold">
          <CardBody>
            <div className="flex items-start gap-3 mb-3">
              <div className="h-10 w-10 rounded-xl bg-gold-100 text-gold-800 flex items-center justify-center">
                <FileText className="h-4 w-4" />
              </div>
              <div>
                <CardTitle className="text-base mb-1">
                  Documents stagiaire
                </CardTitle>
                <p className="text-xs text-slate-700">
                  Présence · Émargement détaillé · Attestation · Certificat de
                  réalisation — disponibles dans la liste ci-dessous.
                </p>
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50 flex items-center justify-between">
          <CardTitle className="text-base">Stagiaires ({users?.length ?? 0})</CardTitle>
          <Badge tone="navy" size="sm">Activité cumulée</Badge>
        </div>
        <ReportsPanel users={(users ?? []) as any[]} />
      </Card>
    </div>
  );
}
