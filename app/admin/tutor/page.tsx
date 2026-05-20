import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Sparkles,
  MessageSquare,
  ClipboardCheck,
  TrendingUp,
  AlertTriangle,
  Calendar,
  Users,
  ArrowUpRight,
} from "lucide-react";
import { isStaff } from "@/lib/permissions";

export const dynamic = "force-dynamic";

const fmtEuros = (cents: number) =>
  new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(cents / 100);

// Vu nos budgets mensuels (Anthropic 50 USD ≈ 46 €, OpenAI 5 USD ≈ 4,60 €),
// on alerte si on dépasse 30 € de chat ou 3 € d'embeddings sur le mois.
const ALERT_THRESHOLD_CHAT_CENTS = 3000; // 30 € chat (Claude)

export default async function AdminTutorPage() {
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

  // ─── Plage temporelle (30 derniers jours et mois courant) ────────────
  const now = new Date();
  const firstOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const thirtyDaysAgo = new Date(now);
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  // ─── Requêtes parallèles ─────────────────────────────────────────────
  const [
    { data: messagesMonth },
    { data: messagesPrevMonth },
    { data: qrAi },
    { data: topConsumers },
    { data: dailyCost },
    { data: recentModerated },
  ] = await Promise.all([
    // Tous les messages assistant du mois en cours (pour total)
    supabase
      .from("tutor_messages")
      .select("cost_cents, tokens_in, tokens_out, moderation_passed, created_at")
      .eq("role", "assistant")
      .gte("created_at", firstOfMonth.toISOString()),

    // Mois précédent — pour comparaison
    supabase
      .from("tutor_messages")
      .select("cost_cents")
      .eq("role", "assistant")
      .gte(
        "created_at",
        new Date(now.getFullYear(), now.getMonth() - 1, 1).toISOString()
      )
      .lt("created_at", firstOfMonth.toISOString()),

    // Corrections QR par IA du mois en cours
    supabase
      .from("qr_responses")
      .select("ai_cost_cents, ai_tokens_in, ai_tokens_out, ai_graded_at")
      .not("ai_graded_at", "is", null)
      .gte("ai_graded_at", firstOfMonth.toISOString()),

    // Top 10 consommateurs sur 30 derniers jours
    supabase.rpc("admin_tutor_top_consumers", { p_days: 30, p_limit: 10 }),

    // Coût journalier sur 30 derniers jours
    supabase.rpc("admin_tutor_daily_cost", { p_days: 30 }),

    // Derniers messages modérés (refus) sur 30 jours pour audit
    supabase
      .from("tutor_messages")
      .select(`
        id, content, created_at,
        tutor_conversations!inner ( user_id, profiles!inner ( full_name, email ) )
      `)
      .eq("role", "assistant")
      .eq("moderation_passed", false)
      .gte("created_at", thirtyDaysAgo.toISOString())
      .order("created_at", { ascending: false })
      .limit(10),
  ]);

  const monthMessages = messagesMonth ?? [];
  const monthQr = qrAi ?? [];

  // ─── Agrégations ─────────────────────────────────────────────────────
  const chatCostMonth = monthMessages.reduce(
    (s, m: any) => s + (m.cost_cents ?? 0),
    0
  );
  const qrCostMonth = monthQr.reduce(
    (s, q: any) => s + (q.ai_cost_cents ?? 0),
    0
  );
  const totalCostMonth = chatCostMonth + qrCostMonth;

  const prevMonthCost = (messagesPrevMonth ?? []).reduce(
    (s, m: any) => s + (m.cost_cents ?? 0),
    0
  );

  const chatMsgCount = monthMessages.length;
  const qrCount = monthQr.length;
  const moderatedCount = monthMessages.filter(
    (m: any) => m.moderation_passed === false
  ).length;

  // Variation vs mois précédent
  const variation =
    prevMonthCost > 0
      ? Math.round(((chatCostMonth - prevMonthCost) / prevMonthCost) * 100)
      : null;

  // Tokens
  const totalTokensIn = monthMessages.reduce(
    (s, m: any) => s + (m.tokens_in ?? 0),
    0
  );
  const totalTokensOut = monthMessages.reduce(
    (s, m: any) => s + (m.tokens_out ?? 0),
    0
  );

  // ─── Alertes ─────────────────────────────────────────────────────────
  const isOverThreshold = chatCostMonth >= ALERT_THRESHOLD_CHAT_CENTS;
  const monthLabel = now.toLocaleDateString("fr-FR", {
    month: "long",
    year: "numeric",
  });

  return (
    <div className="space-y-8">
      <header className="flex items-start justify-between gap-3 flex-wrap">
        <div>
          <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
            <Sparkles className="h-3.5 w-3.5" />
            Tuteur IA — Monitoring
          </span>
          <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
            Consommation & coûts
          </h1>
          <p className="mt-2 text-slate-600 max-w-2xl">
            Suivi en temps réel de l'usage Claude Sonnet 4.6 (chat tuteur) et
            des corrections QR automatisées. Données du mois en cours (
            {monthLabel}).
          </p>
        </div>
      </header>

      {/* Alerte si seuil dépassé */}
      {isOverThreshold && (
        <Card className="border-amber-300 bg-amber-50">
          <CardBody className="flex items-start gap-3">
            <AlertTriangle className="h-5 w-5 text-amber-700 shrink-0 mt-0.5" />
            <div>
              <div className="font-medium text-amber-900">
                Seuil de coût mensuel approché
              </div>
              <p className="text-sm text-amber-800 mt-1">
                La consommation chat du mois dépasse{" "}
                {fmtEuros(ALERT_THRESHOLD_CHAT_CENTS)}. Vérifier qu'il n'y a
                pas un stagiaire qui spam ou un bug. Le plafond Anthropic
                (configuré à 50 USD) coupera automatiquement si on atteint
                la limite.
              </p>
            </div>
          </CardBody>
        </Card>
      )}

      {/* Stats top : 4 cartes */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        <KpiCard
          icon={TrendingUp}
          label="Coût total ce mois"
          value={fmtEuros(totalCostMonth)}
          hint={
            variation !== null
              ? `${variation >= 0 ? "+" : ""}${variation}% vs mois précédent`
              : "Pas de comparaison"
          }
          tone={isOverThreshold ? "warning" : "default"}
        />
        <KpiCard
          icon={MessageSquare}
          label="Messages chat"
          value={String(chatMsgCount)}
          hint={`Coût : ${fmtEuros(chatCostMonth)}`}
        />
        <KpiCard
          icon={ClipboardCheck}
          label="Corrections QR IA"
          value={String(qrCount)}
          hint={`Coût : ${fmtEuros(qrCostMonth)}`}
        />
        <KpiCard
          icon={AlertTriangle}
          label="Modérations bloquées"
          value={String(moderatedCount)}
          hint={
            moderatedCount === 0
              ? "RAS ce mois"
              : "Voir audit ci-dessous"
          }
          tone={moderatedCount > 0 ? "warning" : "default"}
        />
      </div>

      {/* Tokens consommés (info technique) */}
      <Card>
        <CardBody className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
          <Stat
            label="Tokens entrée"
            value={totalTokensIn.toLocaleString("fr-FR")}
          />
          <Stat
            label="Tokens sortie"
            value={totalTokensOut.toLocaleString("fr-FR")}
          />
          <Stat
            label="Ratio in/out"
            value={
              totalTokensOut > 0
                ? `${(totalTokensIn / totalTokensOut).toFixed(1)}×`
                : "—"
            }
          />
        </CardBody>
      </Card>

      {/* Courbe coût journalier */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Calendar className="h-5 w-5 text-gold-700" />
          Coût journalier (30 derniers jours)
        </h2>
        <Card>
          <CardBody>
            <DailyCostChart rows={(dailyCost ?? []) as DailyCostRow[]} />
          </CardBody>
        </Card>
      </section>

      {/* Top consommateurs */}
      <section>
        <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
          <Users className="h-5 w-5 text-gold-700" />
          Top consommateurs (30 derniers jours)
        </h2>
        <Card>
          <CardBody className="p-0">
            <table className="w-full">
              <thead className="border-b border-navy-50 text-[10px] uppercase tracking-wider text-slate-500">
                <tr>
                  <th className="text-left px-5 py-3 font-semibold">
                    Stagiaire
                  </th>
                  <th className="text-right px-5 py-3 font-semibold">
                    Messages
                  </th>
                  <th className="text-right px-5 py-3 font-semibold">
                    Coût
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-navy-50 text-sm">
                {(topConsumers ?? []).length === 0 && (
                  <tr>
                    <td
                      colSpan={3}
                      className="px-5 py-8 text-center text-sm text-slate-500"
                    >
                      Aucune activité sur 30 jours
                    </td>
                  </tr>
                )}
                {(topConsumers ?? []).map((row: any) => (
                  <tr key={row.user_id} className="hover:bg-ivory">
                    <td className="px-5 py-3">
                      <Link
                        href={`/admin/users/${row.user_id}`}
                        className="font-medium text-navy-900 hover:text-gold-700 inline-flex items-center gap-1.5"
                      >
                        {row.full_name ?? row.email ?? "—"}
                        <ArrowUpRight className="h-3 w-3 text-slate-400" />
                      </Link>
                    </td>
                    <td className="px-5 py-3 text-right tabular-nums">
                      {row.messages_count}
                    </td>
                    <td className="px-5 py-3 text-right tabular-nums font-medium text-gold-700">
                      {fmtEuros(row.cost_cents ?? 0)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </CardBody>
        </Card>
      </section>

      {/* Audit modération (refus IA) */}
      {(recentModerated ?? []).length > 0 && (
        <section>
          <h2 className="font-display text-xl font-semibold text-navy-900 mb-4 inline-flex items-center gap-2">
            <AlertTriangle className="h-5 w-5 text-amber-700" />
            Modérations récentes (refus IA)
          </h2>
          <Card>
            <CardBody className="p-0">
              <ul className="divide-y divide-navy-50">
                {(recentModerated as any[]).map((m) => {
                  const owner = m.tutor_conversations?.profiles;
                  return (
                    <li key={m.id} className="px-5 py-3">
                      <div className="flex items-center justify-between gap-3">
                        <div className="text-sm font-medium text-navy-900">
                          {owner?.full_name ?? owner?.email ?? "—"}
                        </div>
                        <div className="text-xs text-slate-500">
                          {new Date(m.created_at).toLocaleDateString("fr-FR", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric",
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </div>
                      </div>
                      <p className="text-xs text-slate-600 mt-1 line-clamp-2">
                        Message IA de refus : {(m.content ?? "").slice(0, 200)}
                        …
                      </p>
                    </li>
                  );
                })}
              </ul>
            </CardBody>
          </Card>
          <p className="text-[11px] text-slate-500 mt-2">
            Si tu vois plusieurs refus pour un même stagiaire, vérifie qu'il
            n'y a pas un soucis (compréhension du périmètre, problème
            personnel). Pour les cas self-harm, contacter le formateur référent.
          </p>
        </section>
      )}
    </div>
  );
}

// ─── Composants internes ─────────────────────────────────────────────

function KpiCard({
  icon: Icon,
  label,
  value,
  hint,
  tone = "default",
}: {
  icon: any;
  label: string;
  value: string;
  hint?: string;
  tone?: "default" | "warning";
}) {
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="flex items-start gap-3">
          <div
            className={
              tone === "warning"
                ? "h-10 w-10 rounded-xl bg-amber-50 border border-amber-200 text-amber-700 flex items-center justify-center shrink-0"
                : "h-10 w-10 rounded-xl bg-gold-50 border border-gold-200 text-gold-700 flex items-center justify-center shrink-0"
            }
          >
            <Icon className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium leading-tight">
              {label}
            </div>
            <div className="font-display text-2xl sm:text-[28px] font-semibold text-navy-900 mt-0.5 tabular-nums leading-none">
              {value}
            </div>
            {hint && (
              <div className="text-[11px] text-slate-500 mt-1.5">{hint}</div>
            )}
          </div>
        </div>
      </CardBody>
    </Card>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="text-[10px] uppercase tracking-wider text-slate-500 font-medium">
        {label}
      </div>
      <div className="font-display text-xl font-semibold text-navy-900 mt-1 tabular-nums">
        {value}
      </div>
    </div>
  );
}

type DailyCostRow = {
  day: string;
  messages_count: number;
  chat_cost_cents: number;
  qr_cost_cents: number;
};

function DailyCostChart({ rows }: { rows: DailyCostRow[] }) {
  if (rows.length === 0) {
    return (
      <p className="text-sm text-slate-500 text-center py-6">
        Aucune donnée sur 30 jours.
      </p>
    );
  }

  const max = Math.max(
    ...rows.map((r) => (r.chat_cost_cents ?? 0) + (r.qr_cost_cents ?? 0)),
    1
  );

  return (
    <div className="space-y-1.5">
      {rows.map((r) => {
        const total = (r.chat_cost_cents ?? 0) + (r.qr_cost_cents ?? 0);
        const widthPct = Math.round((total / max) * 100);
        const chatPct =
          total > 0 ? Math.round(((r.chat_cost_cents ?? 0) / total) * 100) : 0;
        const label = new Date(r.day).toLocaleDateString("fr-FR", {
          day: "2-digit",
          month: "short",
        });
        return (
          <div key={r.day} className="grid grid-cols-[60px_1fr_80px] gap-3 items-center">
            <div className="text-[11px] text-slate-500 tabular-nums">
              {label}
            </div>
            <div className="h-3 rounded bg-slate-100 overflow-hidden relative">
              {widthPct > 0 && (
                <div
                  className="absolute inset-y-0 left-0 flex"
                  style={{ width: `${widthPct}%` }}
                >
                  <div
                    className="bg-gold-500 h-full"
                    style={{ width: `${chatPct}%` }}
                    title="Chat"
                  />
                  <div
                    className="bg-amber-500 h-full"
                    style={{ width: `${100 - chatPct}%` }}
                    title="Correction QR"
                  />
                </div>
              )}
            </div>
            <div className="text-right text-[11px] tabular-nums">
              {fmtEuros(total)}
            </div>
          </div>
        );
      })}
      <div className="pt-2 mt-2 border-t border-navy-50 flex items-center gap-3 text-[10px] text-slate-500">
        <span className="inline-flex items-center gap-1">
          <span className="h-2 w-2 rounded-sm bg-gold-500" /> Chat
        </span>
        <span className="inline-flex items-center gap-1">
          <span className="h-2 w-2 rounded-sm bg-amber-500" /> Correction QR
        </span>
      </div>
    </div>
  );
}
