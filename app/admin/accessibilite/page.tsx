import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Accessibility, UserRound, ShieldCheck } from "lucide-react";
import { updateA11yRequest } from "./actions";

export const dynamic = "force-dynamic";

const STATUS_TONE: Record<string, "navy" | "gold" | "success" | "slate" | "rose"> = {
  nouveau: "gold",
  en_cours: "navy",
  valide: "success",
  refuse: "rose",
  clos: "slate",
};

export default async function AdminA11yPage() {
  const supabase = createClient();
  const [{ data: requests }, { data: overview }] = await Promise.all([
    supabase
      .from("accessibility_requests")
      .select("*, user:profiles!accessibility_requests_user_id_fkey(full_name, email)")
      .order("created_at", { ascending: false })
      .limit(200),
    supabase
      .from("accessibility_overview")
      .select("*")
      .or("a11y_rqth.eq.true,a11y_dyslexia_font.eq.true,a11y_high_contrast.eq.true,open_requests.gt.0")
      .order("open_requests", { ascending: false })
      .limit(100),
  ]);

  const open = (requests ?? []).filter((r: any) =>
    ["nouveau", "en_cours"].includes(r.status)
  );
  const closed = (requests ?? []).filter(
    (r: any) => !["nouveau", "en_cours"].includes(r.status)
  );

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Référent handicap</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Accessibilité & adaptations
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Suivi des demandes d'adaptation et des stagiaires ayant activé des préférences
          d'accessibilité.
        </p>
      </header>

      <section className="grid md:grid-cols-3 gap-4">
        <Kpi label="Demandes ouvertes" value={open.length} tone="gold" />
        <Kpi label="Stagiaires RQTH" value={(overview ?? []).filter((o: any) => o.a11y_rqth).length} tone="navy" />
        <Kpi label="Préférences actives" value={overview?.length ?? 0} tone="slate" />
      </section>

      {/* Demandes ouvertes */}
      <section>
        <h2 className="eyebrow text-gold-700 mb-3">Demandes à traiter</h2>
        {open.length === 0 ? (
          <Card>
            <CardBody className="text-sm text-slate-500">
              Aucune demande en attente.
            </CardBody>
          </Card>
        ) : (
          <div className="space-y-3">
            {open.map((r: any) => (
              <RequestCard key={r.id} r={r} />
            ))}
          </div>
        )}
      </section>

      {/* Stagiaires avec préfs */}
      <section>
        <h2 className="eyebrow text-gold-700 mb-3">Stagiaires & préférences</h2>
        <Card>
          <CardBody className="p-0 overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
                <tr>
                  <th className="text-left px-4 py-3">Stagiaire</th>
                  <th className="text-left px-4 py-3">RQTH</th>
                  <th className="text-left px-4 py-3">Taille</th>
                  <th className="text-left px-4 py-3">Options</th>
                  <th className="text-left px-4 py-3">Demandes ouvertes</th>
                </tr>
              </thead>
              <tbody>
                {(overview ?? []).map((o: any) => (
                  <tr key={o.user_id} className="border-t border-navy-50">
                    <td className="px-4 py-3">
                      <div className="font-medium text-navy-900">{o.full_name ?? "—"}</div>
                      <div className="text-xs text-slate-500">{o.email}</div>
                    </td>
                    <td className="px-4 py-3">
                      {o.a11y_rqth ? (
                        <Badge tone="gold" size="sm">RQTH</Badge>
                      ) : (
                        <span className="text-slate-400">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-slate-700">
                      {Math.round((o.a11y_font_scale ?? 1) * 100)} %
                    </td>
                    <td className="px-4 py-3 text-xs text-slate-600">
                      {[
                        o.a11y_dyslexia_font && "DYS",
                        o.a11y_high_contrast && "Contraste",
                        o.a11y_reduced_motion && "No-motion",
                        o.a11y_underline_links && "Liens soulignés",
                      ]
                        .filter(Boolean)
                        .join(" · ") || "—"}
                    </td>
                    <td className="px-4 py-3">
                      {o.open_requests > 0 ? (
                        <Badge tone="gold" size="sm">{o.open_requests}</Badge>
                      ) : (
                        <span className="text-slate-400">0</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>

      {/* Demandes archivées */}
      {closed.length > 0 && (
        <section>
          <h2 className="eyebrow text-gold-700 mb-3">Historique</h2>
          <div className="space-y-3">
            {closed.slice(0, 20).map((r: any) => (
              <RequestCard key={r.id} r={r} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}

function Kpi({
  label,
  value,
  tone,
}: {
  label: string;
  value: number;
  tone: "gold" | "navy" | "slate";
}) {
  const tones = {
    gold: "bg-gold-50 text-gold-900 border-gold-200",
    navy: "bg-navy-50 text-navy-900 border-navy-100",
    slate: "bg-white text-navy-900 border-navy-100",
  };
  return (
    <div className={`rounded-2xl border p-5 ${tones[tone]}`}>
      <div className="text-xs uppercase tracking-wider text-slate-500">{label}</div>
      <div className="mt-1 font-display text-3xl font-semibold">{value}</div>
    </div>
  );
}

function RequestCard({ r }: { r: any }) {
  return (
    <Card>
      <CardBody>
        <div className="flex items-start justify-between gap-3">
          <div>
            <div className="flex items-center gap-2">
              <Accessibility className="h-4 w-4 text-gold-600" />
              <span className="font-semibold text-navy-900">
                {r.user?.full_name ?? r.user?.email}
              </span>
              <Badge tone={STATUS_TONE[r.status] ?? "slate"} size="sm">
                {r.status}
              </Badge>
              <Badge size="sm">{r.category}</Badge>
            </div>
            <p className="text-sm text-slate-700 mt-2 whitespace-pre-wrap">{r.description}</p>
            {r.adaptations_requested && (
              <p className="text-sm text-slate-600 mt-2">
                <em>Adaptation souhaitée :</em> {r.adaptations_requested}
              </p>
            )}
            <div className="text-xs text-slate-500 mt-2">
              Reçue le {new Date(r.created_at).toLocaleDateString("fr-FR")}
            </div>
          </div>
        </div>
        <form action={updateA11yRequest.bind(null, r.id)} className="mt-4 grid md:grid-cols-[1fr_auto] gap-3 items-end">
          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1">
              Réponse au stagiaire
            </label>
            <Textarea
              name="admin_response"
              rows={2}
              defaultValue={r.admin_response ?? ""}
              placeholder="Expliquer les adaptations accordées / refusées"
            />
          </div>
          <div className="flex flex-col gap-2">
            <select
              name="status"
              defaultValue={r.status}
              className="h-11 rounded-xl border border-navy-200 bg-white px-3 text-sm text-navy-900"
            >
              <option value="nouveau">Nouveau</option>
              <option value="en_cours">En cours</option>
              <option value="valide">Validé</option>
              <option value="refuse">Refusé</option>
              <option value="clos">Clos</option>
            </select>
            <Button type="submit" size="sm">
              <ShieldCheck className="h-4 w-4" /> Mettre à jour
            </Button>
          </div>
        </form>
      </CardBody>
    </Card>
  );
}
