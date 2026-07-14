import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import {
  Download,
  Trash2,
  ShieldCheck,
  Cookie,
  Mail,
  BarChart3,
} from "lucide-react";
import Link from "next/link";
import { AnalyticsOptOutToggle } from "@/components/analytics-opt-out-toggle";
import {
  requestDeletion,
  cancelDeletion,
  toggleConsent,
} from "./actions";

export const dynamic = "force-dynamic";

const CONSENT_LABEL: Record<string, { label: string; desc: string; icon: any }> = {
  essential: {
    label: "Cookies essentiels",
    desc: "Indispensables au fonctionnement (session, sécurité). Toujours actifs.",
    icon: ShieldCheck,
  },
  analytics: {
    label: "Mesure d'audience",
    desc: "Statistiques anonymisées pour améliorer la plateforme.",
    icon: BarChart3,
  },
  communications: {
    label: "Communications pédagogiques",
    desc: "Rappels de session, échéances, notifications de progression.",
    icon: Mail,
  },
  newsletter: {
    label: "Lettre d'information",
    desc: "Actualités GOTRM, mises à jour réglementaires, événements.",
    icon: Cookie,
  },
};

export default async function MesDonneesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: consents }, { data: requests }, { data: log }] =
    await Promise.all([
      supabase.from("user_consents").select("*").eq("user_id", user.id),
      supabase
        .from("deletion_requests")
        .select("*")
        .eq("user_id", user.id)
        .order("requested_at", { ascending: false }),
      supabase
        .from("data_access_log")
        .select("*")
        .eq("user_id", user.id)
        .order("created_at", { ascending: false })
        .limit(10),
    ]);

  const consentMap = new Map(
    (consents ?? []).map((c: any) => [c.kind, c.granted])
  );
  const pendingDeletion = (requests ?? []).find((r: any) =>
    ["pending", "approved"].includes(r.status)
  );
  return (
    <div className="space-y-10">
      <header>
        <span className="eyebrow text-gold-700">RGPD</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Mes données personnelles
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Conformément au Règlement général sur la protection des données (RGPD),
          vous disposez d'un droit d'accès, de rectification, d'effacement et de
          portabilité de vos données.
        </p>
      </header>

      <AnalyticsOptOutToggle />

      <div className="grid lg:grid-cols-2 gap-6">
        {/* Export */}
        <Card>
          <CardBody>
            <div className="flex items-start gap-3">
              <div className="h-10 w-10 rounded-xl bg-navy-50 text-navy-900 flex items-center justify-center shrink-0">
                <Download className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <CardTitle>Exporter mes données</CardTitle>
                <p className="text-sm text-slate-600 mt-1">
                  Téléchargement complet au format JSON (profil, progression,
                  quiz, badges, certificats, consentements). Article 15 du RGPD.
                </p>
                <a
                  href="/api/me/export"
                  className="mt-4 inline-flex items-center gap-2 rounded-xl bg-navy-900 text-white px-4 py-2 text-sm font-medium hover:bg-navy-800"
                >
                  <Download className="h-4 w-4" /> Télécharger (.json)
                </a>
              </div>
            </div>
          </CardBody>
        </Card>

        {/* Suppression */}
        <Card>
          <CardBody>
            <div className="flex items-start gap-3">
              <div className="h-10 w-10 rounded-xl bg-rose-50 text-rose-700 flex items-center justify-center shrink-0">
                <Trash2 className="h-5 w-5" />
              </div>
              <div className="flex-1">
                <CardTitle>Demander la suppression</CardTitle>
                <p className="text-sm text-slate-600 mt-1">
                  Article 17 — droit à l'effacement. Votre demande sera étudiée
                  par notre équipe sous 30 jours. Certaines données légales
                  (facturation, Qualiopi) sont conservées selon les durées
                  réglementaires.
                </p>

                {pendingDeletion ? (
                  <div className="mt-4 rounded-xl border border-gold-200 bg-gold-50 p-4">
                    <div className="flex items-center justify-between gap-2">
                      <div>
                        <Badge tone="gold" size="sm">
                          {pendingDeletion.status}
                        </Badge>
                        <p className="text-sm text-slate-700 mt-2">
                          Demande envoyée le{" "}
                          {new Date(
                            pendingDeletion.requested_at
                          ).toLocaleDateString("fr-FR")}
                        </p>
                      </div>
                      {pendingDeletion.status === "pending" && (
                        <form
                          action={async () => {
                            "use server";
                            await cancelDeletion(pendingDeletion.id);
                          }}
                        >
                          <Button type="submit" variant="ghost" size="sm">
                            Annuler
                          </Button>
                        </form>
                      )}
                    </div>
                  </div>
                ) : (
                  <form action={requestDeletion} className="mt-4 space-y-3">
                    <Textarea
                      name="reason"
                      rows={3}
                      placeholder="Motif (optionnel)"
                    />
                    <Button type="submit" variant="ghost" className="text-rose-700">
                      <Trash2 className="h-4 w-4" /> Envoyer la demande
                    </Button>
                  </form>
                )}
              </div>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Consentements */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
          Mes consentements
        </h2>
        <div className="space-y-3">
          {Object.entries(CONSENT_LABEL).map(([kind, meta]) => {
            const granted =
              kind === "essential" ? true : consentMap.get(kind) ?? false;
            const Icon = meta.icon;
            return (
              <Card key={kind}>
                <CardBody>
                  <div className="flex items-center justify-between gap-4">
                    <div className="flex items-start gap-3">
                      <div className="h-9 w-9 rounded-lg bg-navy-50 text-navy-700 flex items-center justify-center shrink-0">
                        <Icon className="h-4 w-4" />
                      </div>
                      <div>
                        <div className="font-medium text-navy-900">
                          {meta.label}
                        </div>
                        <p className="text-sm text-slate-600">{meta.desc}</p>
                      </div>
                    </div>
                    <form action={toggleConsent}>
                      <input type="hidden" name="kind" value={kind} />
                      <input
                        type="hidden"
                        name="granted"
                        value={String(!granted)}
                      />
                      <button
                        type="submit"
                        disabled={kind === "essential"}
                        className={
                          "relative inline-flex h-6 w-11 items-center rounded-full transition-colors " +
                          (granted ? "bg-navy-900" : "bg-slate-300") +
                          (kind === "essential" ? " opacity-60 cursor-not-allowed" : "")
                        }
                        aria-label={meta.label}
                      >
                        <span
                          className={
                            "inline-block h-5 w-5 transform rounded-full bg-white shadow transition " +
                            (granted ? "translate-x-5" : "translate-x-0.5")
                          }
                        />
                      </button>
                    </form>
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </div>
      </section>

      {/* Journal */}
      {log && log.length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4">
            Journal d'accès récent
          </h2>
          <Card>
            <CardBody className="p-0">
              <table className="w-full text-sm">
                <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                  <tr>
                    <th className="text-left px-6 py-3">Date</th>
                    <th className="text-left px-6 py-3">Action</th>
                    <th className="text-left px-6 py-3">Périmètre</th>
                  </tr>
                </thead>
                <tbody>
                  {log.map((l: any) => (
                    <tr key={l.id} className="border-t border-navy-50">
                      <td className="px-6 py-3 text-slate-600">
                        {new Date(l.created_at).toLocaleString("fr-FR")}
                      </td>
                      <td className="px-6 py-3 font-medium text-navy-900">
                        {l.action}
                      </td>
                      <td className="px-6 py-3 text-slate-600">
                        {l.scope ?? "—"}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </CardBody>
          </Card>
        </section>
      )}

      <div className="text-sm text-slate-500">
        Pour toute question relative à vos données, consultez notre{" "}
        <Link href="/confidentialite" className="text-navy-900 underline">
          politique de confidentialité
        </Link>
        .
      </div>
    </div>
  );
}
