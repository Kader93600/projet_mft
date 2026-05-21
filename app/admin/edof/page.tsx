import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { isEdofConfigured, isEdofFeatureEnabled } from "@/lib/edof/config";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CheckCircle2, Circle, Landmark, Clock } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function AdminEdofPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile?.role || !isStaff(profile.role)) redirect("/dashboard");

  const configured = isEdofConfigured();
  const featureOn = isEdofFeatureEnabled();

  // Dossiers CPF existants (candidats à la synchro), depuis enrollments.
  const { count: cpfCount } = await supabase
    .from("enrollments")
    .select("id", { count: "exact", head: true })
    .eq("funding_kind", "cpf");

  // Dossiers déjà synchronisés (best-effort : la table peut ne pas encore
  // exister si la migration n'a pas été jouée).
  let syncedCount: number | null = null;
  const { count, error } = await supabase
    .from("cpf_edof_dossiers")
    .select("id", { count: "exact", head: true });
  if (!error) syncedCount = count ?? 0;

  // Étapes : prêtes côté code vs en attente d'action externe.
  const ready = [
    "Modèle de données (tables de suivi + curseur de synchro)",
    "Machine à états du cycle de vie dossier (reçu → service fait → soldé)",
    "Mapping EDOF ↔ statuts d'inscription MFT",
    "Interface client EDOF + fabrique (point de branchement)",
    "Squelette de synchro incrémentale (cron, idempotent, paginé)",
    "Garde-fous : inerte tant que non configuré",
  ];
  const pending = [
    "Réponse de la Caisse des Dépôts sur l'accès EDOF (côté client)",
    "Credentials API + specs/sandbox CDC",
    "Implémentation de l'adapter HTTP (lib/edof/client.ts → HttpEdofClient)",
    "Renseigner EDOF_* + FEATURE_EDOF, jouer la migration, activer le cron",
  ];

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <Landmark className="h-3.5 w-3.5" />
          Intégration CPF / Mon Compte Formation
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          EDOF — état de préparation
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Les fondations de l&apos;automatisation EDOF sont en place. Il reste
          l&apos;accès API de la Caisse des Dépôts (en attente côté client) pour
          brancher la synchronisation réelle.
        </p>
      </header>

      <section className="grid sm:grid-cols-3 gap-4">
        <StatusTile
          label="Accès API configuré"
          ok={configured}
          okText="Configuré"
          koText="En attente CDC"
        />
        <StatusTile
          label="Synchro activée"
          ok={featureOn && configured}
          okText="Active"
          koText="Inactive"
        />
        <Card>
          <CardBody>
            <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
              Dossiers CPF
            </div>
            <div className="mt-1 font-display text-2xl font-semibold text-navy-900 tabular-nums">
              {cpfCount ?? 0}
            </div>
            <div className="text-xs text-slate-500 mt-0.5">
              {syncedCount === null
                ? "Table de suivi à créer (migration)"
                : `${syncedCount} synchronisé${syncedCount > 1 ? "s" : ""} depuis EDOF`}
            </div>
          </CardBody>
        </Card>
      </section>

      <section className="grid md:grid-cols-2 gap-4">
        <Card>
          <CardBody>
            <h2 className="font-display font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-emerald-600" />
              Prêt côté plateforme
            </h2>
            <ul className="space-y-2">
              {ready.map((r) => (
                <li
                  key={r}
                  className="flex items-start gap-2 text-sm text-navy-900"
                >
                  <CheckCircle2 className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                  {r}
                </li>
              ))}
            </ul>
          </CardBody>
        </Card>

        <Card>
          <CardBody>
            <h2 className="font-display font-semibold text-navy-900 mb-3 inline-flex items-center gap-2">
              <Clock className="h-4 w-4 text-gold-700" />
              En attente
            </h2>
            <ul className="space-y-2">
              {pending.map((p) => (
                <li
                  key={p}
                  className="flex items-start gap-2 text-sm text-slate-700"
                >
                  <Circle className="h-4 w-4 text-slate-300 shrink-0 mt-0.5" />
                  {p}
                </li>
              ))}
            </ul>
          </CardBody>
        </Card>
      </section>

      <div className="text-xs text-slate-500">
        Architecture technique détaillée : <code>lib/edof/README.md</code>.
      </div>
    </div>
  );
}

function StatusTile({
  label,
  ok,
  okText,
  koText,
}: {
  label: string;
  ok: boolean;
  okText: string;
  koText: string;
}) {
  return (
    <Card>
      <CardBody>
        <div className="text-[10px] uppercase tracking-wider text-slate-500 font-semibold">
          {label}
        </div>
        <Badge tone={ok ? "success" : "gold"} size="sm" className="mt-2">
          {ok ? okText : koText}
        </Badge>
      </CardBody>
    </Card>
  );
}
