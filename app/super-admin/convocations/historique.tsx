"use client";

// =====================================================================
// Historique des convocations : recherche, filtres, statuts, actions
// (voir, télécharger, modifier, dupliquer, régénérer, supprimer).
// =====================================================================

import * as React from "react";
import {
  Copy, Download, Eye, Pencil, Search, Trash2, Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { ConfirmAction } from "@/components/ui/confirm-action";
import { useToast } from "@/components/ui/toast";
import { cn } from "@/lib/utils";
import {
  STATUTS, formatDateFr,
  type ConvocationRow, type ConvocationStatus,
} from "@/lib/convocations";
import { deleteConvocation, listHistory, setStatus } from "./actions";

export function HistoriqueTab({
  initial,
  onEdit,
  onDuplicate,
  refreshKey,
}: {
  initial: ConvocationRow[];
  onEdit: (row: ConvocationRow) => void;
  onDuplicate: (row: ConvocationRow) => void;
  refreshKey: number;
}) {
  const { toast } = useToast();
  const [rows, setRows] = React.useState<ConvocationRow[]>(initial);
  const [kind, setKind] = React.useState("");
  const [status, setStatusFilter] = React.useState("");
  const [search, setSearch] = React.useState("");
  const [loading, setLoading] = React.useState(false);

  const reload = React.useCallback(async () => {
    setLoading(true);
    const r = await listHistory({
      kind: kind as "candidat" | "jury" | "",
      status: status as ConvocationStatus | "",
      search,
    });
    setRows(r);
    setLoading(false);
  }, [kind, status, search]);

  // Recharge sur filtre (léger debounce pour la recherche) et après
  // chaque génération ailleurs dans la page (refreshKey).
  React.useEffect(() => {
    const t = setTimeout(() => { void reload(); }, search ? 300 : 0);
    return () => clearTimeout(t);
  }, [reload, refreshKey, search]);

  async function changeStatus(id: string, s: ConvocationStatus) {
    const res = await setStatus(id, s);
    if (!res.ok) { toast(res.error ?? "Impossible.", "error"); return; }
    setRows((rs) => rs.map((r) => (r.id === id ? { ...r, status: s } : r)));
    toast(`Statut : ${STATUTS[s].label}.`, "success");
  }

  async function remove(id: string) {
    const res = await deleteConvocation(id);
    if (!res.ok) throw new Error(res.error ?? "Suppression impossible.");
    setRows((rs) => rs.filter((r) => r.id !== id));
  }

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center gap-2">
        <div className="relative min-w-56 flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Rechercher (nom de fichier, référence, session…)"
            className="pl-9"
          />
        </div>
        <Select value={kind} onChange={(e) => setKind(e.target.value)} className="w-44">
          <option value="">Candidats et jurys</option>
          <option value="candidat">Candidats</option>
          <option value="jury">Jurys</option>
        </Select>
        <Select value={status} onChange={(e) => setStatusFilter(e.target.value)} className="w-44">
          <option value="">Tous les statuts</option>
          {Object.entries(STATUTS).map(([k, s]) => <option key={k} value={k}>{s.label}</option>)}
        </Select>
      </div>

      <div className="overflow-x-auto rounded-2xl border border-navy-100 bg-white">
        <table className="w-full min-w-[760px] text-sm">
          <thead className="bg-navy-50/70 text-left text-[11px] uppercase tracking-wider text-slate-500">
            <tr>
              <th className="px-4 py-2.5 font-semibold">Destinataire</th>
              <th className="px-3 py-2.5 font-semibold">Type</th>
              <th className="px-3 py-2.5 font-semibold">Formation / session</th>
              <th className="px-3 py-2.5 font-semibold">Épreuve le</th>
              <th className="px-3 py-2.5 font-semibold">Créée le</th>
              <th className="px-3 py-2.5 font-semibold">Statut</th>
              <th className="px-3 py-2.5 text-right font-semibold">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading && rows.length === 0 ? (
              <tr>
                <td colSpan={7} className="px-4 py-10 text-center text-slate-500">
                  <Loader2 className="mx-auto h-5 w-5 animate-spin motion-reduce:animate-none" />
                </td>
              </tr>
            ) : rows.length === 0 ? (
              <tr>
                <td colSpan={7} className="px-4 py-10 text-center text-sm text-slate-500">
                  Aucune convocation pour ces critères. Générez-en une depuis les onglets Candidats ou Jurys.
                </td>
              </tr>
            ) : (
              rows.map((r) => {
                const d = r.payload.destinataire;
                return (
                  <tr key={r.id} className="border-t border-navy-50 transition-colors hover:bg-navy-50/40">
                    <td className="px-4 py-2.5">
                      <div className="font-medium text-navy-950">{d.prenom} {d.nom}</div>
                      <div className="text-xs text-slate-400">{r.reference}</div>
                    </td>
                    <td className="px-3 py-2.5 text-slate-600">
                      {r.kind === "jury" ? "Jury" : "Candidat"}
                    </td>
                    <td className="px-3 py-2.5">
                      <div className="max-w-52 truncate text-slate-700">{r.payload.formation.titre || "—"}</div>
                      {r.session_label && <div className="text-xs text-slate-400">{r.session_label}</div>}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2.5 text-slate-700">
                      {formatDateFr(r.exam_date) || "—"}
                    </td>
                    <td className="whitespace-nowrap px-3 py-2.5 text-slate-500">
                      {new Date(r.created_at).toLocaleDateString("fr-FR")}
                    </td>
                    <td className="px-3 py-2.5">
                      <select
                        value={r.status}
                        onChange={(e) => changeStatus(r.id, e.target.value as ConvocationStatus)}
                        aria-label={`Statut de ${r.reference}`}
                        className={cn(
                          "cursor-pointer rounded-full border px-2.5 py-1 text-[11px] font-semibold",
                          "focus:outline-none focus:ring-2 focus:ring-navy-600/20",
                          STATUTS[r.status]?.tone ?? "",
                        )}
                      >
                        {Object.entries(STATUTS).map(([k, s]) => (
                          <option key={k} value={k}>{s.label}</option>
                        ))}
                      </select>
                    </td>
                    <td className="px-3 py-2.5">
                      <div className="flex justify-end gap-0.5">
                        <IconBtn title="Voir / Régénérer"
                          onClick={() => window.open(`/super-admin/convocations/pdf?id=${r.id}`, "_blank", "noopener")}>
                          <Eye className="h-4 w-4" />
                        </IconBtn>
                        <IconBtn title="Télécharger"
                          onClick={() => window.open(`/super-admin/convocations/pdf?id=${r.id}&download=1`, "_blank", "noopener")}>
                          <Download className="h-4 w-4" />
                        </IconBtn>
                        <IconBtn title="Modifier" onClick={() => onEdit(r)}>
                          <Pencil className="h-4 w-4" />
                        </IconBtn>
                        <IconBtn title="Dupliquer" onClick={() => onDuplicate(r)}>
                          <Copy className="h-4 w-4" />
                        </IconBtn>
                        <ConfirmAction
                          action={() => remove(r.id)}
                          title="Supprimer la convocation ?"
                          description={`${r.file_name} sera définitivement supprimée de l'historique.`}
                          confirmLabel="Supprimer"
                          successMsg="Convocation supprimée"
                          icon={<Trash2 className="h-3.5 w-3.5" />}
                          iconLabel="Supprimer"
                        />
                      </div>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
      <p className="text-xs text-slate-400">
        {rows.length} convocation{rows.length > 1 ? "s" : ""} · les PDF sont régénérés à la demande depuis
        l'historique, à l'identique.
      </p>
    </div>
  );
}

const IconBtn = React.forwardRef<HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement> & { danger?: boolean }
>(function IconBtn({ danger, className, ...props }, ref) {
  return (
    <button
      ref={ref}
      type="button"
      className={cn(
        "inline-flex h-8 w-8 items-center justify-center rounded-lg text-slate-500",
        "transition-colors duration-150 hover:bg-navy-50 hover:text-navy-900",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-600/30",
        danger && "hover:bg-rose-50 hover:text-rose-700",
        className,
      )}
      {...props}
    />
  );
});
