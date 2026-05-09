"use client";
import { useMemo, useState } from "react";
import Link from "next/link";
import {
  Search,
  X,
  ArrowLeft,
  FileDown,
  Loader2,
  ShieldCheck,
  Users,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { avatarTone, initials } from "@/lib/messaging-utils";

interface Candidate {
  id: string;
  full_name: string | null;
  email: string;
  role: string;
}

interface Props {
  candidates: Candidate[];
}

const ROLES_TO_GROUP: { key: string; label: string; roles: string[] }[] = [
  { key: "students", label: "Stagiaires", roles: ["student"] },
  { key: "trainers", label: "Formateurs", roles: ["trainer"] },
  { key: "admins", label: "Administration", roles: ["admin", "super_admin"] },
];

/**
 * UI client : input recherche + sections par rôle + bouton d'export.
 * Quand un user est sélectionné, on affiche un récap + le bouton final.
 */
export function PreuvesClient({ candidates }: Props) {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Candidate | null>(null);
  const [exporting, setExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return candidates;
    return candidates.filter((c) => {
      const name = (c.full_name ?? "").toLowerCase();
      const email = c.email.toLowerCase();
      return name.includes(q) || email.includes(q);
    });
  }, [candidates, query]);

  const grouped = useMemo(() => {
    return ROLES_TO_GROUP.map((g) => ({
      ...g,
      items: filtered.filter((c) => g.roles.includes(c.role)),
    })).filter((g) => g.items.length > 0);
  }, [filtered]);

  const handleExport = async () => {
    if (!selected || exporting) return;
    setError(null);
    setExporting(true);
    try {
      const res = await fetch(
        `/api/admin/messages/export-by-user?userId=${encodeURIComponent(
          selected.id
        )}`,
        { credentials: "include" }
      );
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        if (body.error === "no_conversations_for_user") {
          throw new Error("Cet utilisateur n'a aucune conversation.");
        }
        throw new Error(body.error || `HTTP ${res.status}`);
      }
      const blob = await res.blob();
      const blobUrl = URL.createObjectURL(blob);
      const cd = res.headers.get("content-disposition") ?? "";
      const m = /filename="?([^"]+)"?/.exec(cd);
      const filename = m?.[1] ?? `preuves-${selected.id}.pdf`;
      const a = document.createElement("a");
      a.href = blobUrl;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(blobUrl);
    } catch (err: any) {
      setError(err?.message ?? "Échec de l'export");
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <header>
        <Link
          href="/admin/messages"
          className="inline-flex items-center gap-1.5 text-[12px] font-semibold text-slate-500 hover:text-navy-700 transition-colors"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Retour à la messagerie admin
        </Link>
        <div className="mt-3 flex items-center gap-2">
          <ShieldCheck className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Audit Qualiopi</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Preuves de communication
        </h1>
        <p className="mt-2 text-slate-600 text-sm leading-relaxed max-w-2xl">
          Sélectionne un stagiaire, un formateur ou un membre de
          l&apos;administration pour générer un PDF rassemblant{" "}
          <strong>toutes ses conversations</strong> (échanges directs et
          groupes), avec horodatage, pièces jointes, réactions et messages
          épinglés. Ce document constitue une preuve formelle de communication
          conforme aux exigences Qualiopi.
        </p>
      </header>

      {/* User picker */}
      <div className="bg-white border border-navy-100 rounded-2xl shadow-soft overflow-hidden">
        <div className="px-5 pt-4 pb-3 border-b border-navy-100">
          <h2 className="text-[14px] font-semibold text-navy-950">
            1. Choisir l&apos;utilisateur
          </h2>
          <div className="relative mt-3">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Rechercher par nom ou email…"
              className={cn(
                "w-full h-10 pl-10 pr-3 rounded-xl text-[13px]",
                "bg-navy-50/40 border border-navy-100",
                "placeholder:text-slate-400 text-navy-900",
                "outline-none transition-shadow duration-150",
                "focus:border-navy-300 focus:bg-white focus:shadow-ring-brand"
              )}
            />
          </div>
        </div>

        <div className="max-h-[420px] overflow-y-auto p-2">
          {filtered.length === 0 ? (
            <div className="px-4 py-12 text-center text-[12.5px] text-slate-500">
              Aucun utilisateur ne correspond.
            </div>
          ) : (
            <div className="space-y-3">
              {grouped.map((g) => (
                <section key={g.key}>
                  <div className="px-3 py-1.5 text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500 flex items-center gap-1.5">
                    <Users className="h-3 w-3" />
                    {g.label}{" "}
                    <span className="text-slate-400">({g.items.length})</span>
                  </div>
                  <ul className="space-y-0.5">
                    {g.items.map((c) => (
                      <li key={c.id}>
                        <CandidateRow
                          candidate={c}
                          selected={selected?.id === c.id}
                          onClick={() => setSelected(c)}
                        />
                      </li>
                    ))}
                  </ul>
                </section>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Étape 2 : récap + export */}
      {selected && (
        <div className="bg-white border border-navy-100 rounded-2xl shadow-soft p-5 animate-notif-pop">
          <h2 className="text-[14px] font-semibold text-navy-950 mb-3">
            2. Générer le PDF
          </h2>

          <div className="flex items-center gap-3 mb-4 px-4 py-3 rounded-xl bg-navy-50/40 border border-navy-100">
            <span
              className={cn(
                "h-12 w-12 rounded-xl flex items-center justify-center font-bold text-[14px]",
                avatarTone(selected.id)
              )}
              aria-hidden
            >
              {initials(selected.full_name ?? selected.email)}
            </span>
            <div className="min-w-0 flex-1">
              <div className="text-[14px] font-semibold text-navy-950 truncate">
                {selected.full_name ?? selected.email}
              </div>
              <div className="text-[11.5px] text-slate-500 truncate">
                {selected.email} · {roleLabel(selected.role)}
              </div>
            </div>
            <button
              type="button"
              onClick={() => setSelected(null)}
              aria-label="Désélectionner"
              className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-navy-700 hover:bg-navy-100 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>

          {error && (
            <div className="mb-3 px-3 py-2 rounded-md text-[12px] bg-rose-50 text-rose-700 border border-rose-200">
              {error}
            </div>
          )}

          <div className="flex items-center justify-between gap-3">
            <p className="text-[12px] text-slate-600 leading-relaxed">
              L&apos;export inclut toutes les conversations de cet utilisateur
              (jusqu&apos;à 50 conversations · 500 messages chacune). Le
              téléchargement démarre automatiquement.
            </p>
            <button
              type="button"
              onClick={handleExport}
              disabled={exporting}
              className={cn(
                "inline-flex items-center gap-2 px-4 py-2.5 rounded-lg text-[13px] font-semibold shrink-0",
                "bg-navy-900 text-white hover:bg-navy-950 shadow-sm",
                "transition-colors duration-150 ease-out",
                "disabled:opacity-50 disabled:cursor-wait"
              )}
            >
              {exporting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Génération…
                </>
              ) : (
                <>
                  <FileDown className="h-4 w-4" />
                  Exporter en PDF
                </>
              )}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Sub-components ─────────────────────────────────────────────

function CandidateRow({
  candidate,
  selected,
  onClick,
}: {
  candidate: Candidate;
  selected: boolean;
  onClick: () => void;
}) {
  const c = candidate;
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={selected}
      className={cn(
        "w-full text-left flex items-center gap-3 px-3 py-2.5 rounded-lg",
        "transition-colors duration-150 ease-out",
        selected
          ? "bg-gold-50 border border-gold-200"
          : "hover:bg-navy-50/60 border border-transparent",
        "focus-visible:bg-navy-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-navy-300"
      )}
    >
      <span
        className={cn(
          "h-9 w-9 rounded-xl flex items-center justify-center shrink-0 font-semibold text-[12px]",
          avatarTone(c.id)
        )}
        aria-hidden
      >
        {initials(c.full_name ?? c.email)}
      </span>
      <div className="flex-1 min-w-0">
        <div className="text-[13px] font-semibold text-navy-950 truncate">
          {c.full_name ?? c.email}
        </div>
        <div className="text-[11px] text-slate-500 truncate">{c.email}</div>
      </div>
      <span className="text-[10px] font-bold uppercase tracking-wide text-slate-500 shrink-0">
        {roleLabel(c.role)}
      </span>
    </button>
  );
}

function roleLabel(role: string): string {
  switch (role) {
    case "student":
      return "Stagiaire";
    case "trainer":
      return "Formateur";
    case "admin":
      return "Admin";
    case "super_admin":
      return "Super-admin";
    default:
      return role;
  }
}
