import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { isStaff } from "@/lib/permissions";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { PenLine, Download, CheckCircle2, Clock } from "lucide-react";
import { RelanceButton } from "./relance-button";

export const dynamic = "force-dynamic";

function fmt(d?: string | null) {
  if (!d) return "—";
  return new Date(d).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default async function AdminSignaturesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!me?.role || !isStaff(me.role)) redirect("/dashboard");

  const [{ data: students }, { data: sigs }] = await Promise.all([
    supabase
      .from("profiles")
      .select("id, full_name, email, mandatory_signature_at")
      .eq("role", "student")
      .order("full_name"),
    supabase
      .from("user_signatures")
      .select("user_id, signed_at, signature_data, ip_address"),
  ]);

  const sigMap = new Map((sigs ?? []).map((s: any) => [s.user_id, s]));
  const list = (students ?? []) as any[];
  const signed = list.filter((s) => s.mandatory_signature_at).length;
  const pending = list.length - signed;

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700 inline-flex items-center gap-1.5">
          <PenLine className="h-3.5 w-3.5" />
          Qualiopi · Signatures
        </span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Signatures des stagiaires
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Suivi des signatures des documents obligatoires : statut, horodatage,
          signature manuscrite et attestation téléchargeable. Les acceptations
          sont immuables.
        </p>
      </header>

      <section className="grid grid-cols-3 gap-3 sm:gap-4">
        <Stat label="Stagiaires" value={String(list.length)} />
        <Stat label="Signés" value={String(signed)} tone="success" />
        <Stat label="En attente" value={String(pending)} tone="warning" />
      </section>

      <Card>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
                <th className="text-left px-5 py-3 font-semibold">Stagiaire</th>
                <th className="text-left px-5 py-3 font-semibold">Statut</th>
                <th className="text-left px-5 py-3 font-semibold">Signé le</th>
                <th className="text-left px-5 py-3 font-semibold">Signature</th>
                <th className="text-right px-5 py-3 font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody>
              {list.map((s) => {
                const sig = sigMap.get(s.id);
                const isSigned = !!s.mandatory_signature_at;
                return (
                  <tr key={s.id} className="border-t border-navy-50">
                    <td className="px-5 py-3">
                      <div className="font-medium text-navy-900">
                        {s.full_name ?? "—"}
                      </div>
                      <div className="text-xs text-slate-500">{s.email}</div>
                    </td>
                    <td className="px-5 py-3">
                      {isSigned ? (
                        <Badge tone="success" size="sm">
                          <CheckCircle2 className="h-3 w-3" /> Signé
                        </Badge>
                      ) : (
                        <Badge tone="gold" size="sm">
                          <Clock className="h-3 w-3" /> En attente
                        </Badge>
                      )}
                    </td>
                    <td className="px-5 py-3 text-xs text-slate-500 whitespace-nowrap">
                      {fmt(s.mandatory_signature_at ?? sig?.signed_at)}
                    </td>
                    <td className="px-5 py-3">
                      {sig?.signature_data ? (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img
                          src={sig.signature_data}
                          alt="Signature"
                          className="h-9 w-auto max-w-[120px] rounded border border-navy-100 bg-white"
                        />
                      ) : (
                        <span className="text-slate-300 text-xs">—</span>
                      )}
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex items-center justify-end gap-2">
                        {isSigned ? (
                          <a
                            href={`/api/admin/signatures/${s.id}`}
                            target="_blank"
                            className="inline-flex items-center gap-1.5 rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-xs font-medium text-navy-800 hover:bg-navy-50 transition-colors"
                          >
                            <Download className="h-3.5 w-3.5" /> Attestation
                          </a>
                        ) : (
                          <RelanceButton studentId={s.id} />
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
              {list.length === 0 && (
                <tr>
                  <td
                    colSpan={5}
                    className="px-5 py-16 text-center text-slate-400"
                  >
                    <PenLine className="h-8 w-8 mx-auto mb-2 text-slate-300" />
                    Aucun stagiaire pour le moment.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}

function Stat({
  label,
  value,
  tone = "default",
}: {
  label: string;
  value: string;
  tone?: "default" | "success" | "warning";
}) {
  const ring =
    tone === "success"
      ? "text-emerald-700"
      : tone === "warning"
        ? "text-gold-700"
        : "text-navy-900";
  return (
    <Card>
      <CardBody className="p-4 sm:p-5">
        <div className="text-[11px] uppercase tracking-wider text-slate-500 font-medium">
          {label}
        </div>
        <div
          className={`font-display text-2xl font-semibold mt-1 tabular-nums ${ring}`}
        >
          {value}
        </div>
      </CardBody>
    </Card>
  );
}
