import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ShieldCheck, KeyRound, AlertTriangle } from "lucide-react";
import { RemoveFactorButton } from "./remove-factor";
import { MfaSetup } from "./mfa-setup";

export const dynamic = "force-dynamic";

export default async function AdminSecurityPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: factorsData } = await supabase.auth.mfa.listFactors();
  const totpFactors = factorsData?.totp ?? [];
  const hasVerified = totpFactors.some((f) => f.status === "verified");

  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">Sécurité</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Authentification à deux facteurs
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Pour les comptes administrateurs, la double authentification est
          obligatoire. Elle protège l'accès aux données personnelles et
          financières (RGPD, Qualiopi).
        </p>
      </header>

      {!hasVerified && (
        <div className="rounded-2xl border border-amber-200 bg-amber-50 p-4 flex items-start gap-3">
          <AlertTriangle className="h-5 w-5 text-amber-700 mt-0.5 shrink-0" />
          <div className="flex-1">
            <div className="font-semibold text-amber-900">
              Aucun facteur 2FA actif
            </div>
            <p className="text-sm text-amber-900/90">
              Pour les comptes administrateurs et super-administrateurs, la
              double authentification est <strong>fortement recommandée</strong>.
              Configurez une application d'authentification ci-dessous.
            </p>
          </div>
        </div>
      )}

      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Mes facteurs
        </h2>
        <Card>
          <CardBody className="p-0">
            {totpFactors.length === 0 ? (
              <div className="p-10 text-center text-sm text-slate-500">
                Aucune méthode 2FA enregistrée.
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {totpFactors.map((f) => (
                  <li key={f.id} className="px-6 py-4 flex items-center gap-4">
                    <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-900 flex items-center justify-center shrink-0">
                      <KeyRound className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-medium text-navy-900">
                        {f.friendly_name || "Application TOTP"}
                      </div>
                      <div className="text-xs text-slate-500">
                        Ajoutée le{" "}
                        {new Date(f.created_at).toLocaleDateString("fr-FR")}
                      </div>
                    </div>
                    <Badge
                      tone={f.status === "verified" ? "success" : "gold"}
                      size="sm"
                    >
                      {f.status === "verified" ? (
                        <>
                          <ShieldCheck className="h-3 w-3" /> Active
                        </>
                      ) : (
                        "En attente"
                      )}
                    </Badge>
                    <RemoveFactorButton factorId={f.id} />
                  </li>
                ))}
              </ul>
            )}
          </CardBody>
        </Card>
      </section>

      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          {hasVerified ? "Ajouter un facteur supplémentaire" : "Activer 2FA"}
        </h2>
        <Card>
          <CardBody>
            <CardTitle>Application d'authentification (TOTP)</CardTitle>
            <p className="text-sm text-slate-600 mt-1 mb-4">
              Scannez le QR code avec votre application (Google Authenticator,
              1Password, Authy, Bitwarden…) puis saisissez le code à 6 chiffres
              pour valider.
            </p>
            <MfaSetup />
          </CardBody>
        </Card>
      </section>
    </div>
  );
}
