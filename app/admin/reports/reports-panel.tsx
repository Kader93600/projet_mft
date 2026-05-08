"use client";
import { useState, useMemo } from "react";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { initials } from "@/lib/utils";
import { FileText, Award, Search, ClipboardCheck, BadgeCheck } from "lucide-react";

interface User {
  id: string;
  email: string;
  full_name: string | null;
  total_session_s: number;
  session_count: number;
  lessons_viewed: number;
  lesson_time_s: number;
  quiz_attempts: number;
  quiz_passed: number;
  avg_score: number;
  first_session: string | null;
  last_session: string | null;
}

function fmtHours(s: number) {
  if (!s) return "—";
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}`;
  return `${m}min`;
}

export function ReportsPanel({ users }: { users: User[] }) {
  const [search, setSearch] = useState("");
  const now = new Date().toISOString().slice(0, 10);
  const from30 = new Date(Date.now() - 30 * 86400_000).toISOString().slice(0, 10);
  const [from, setFrom] = useState(from30);
  const [to, setTo] = useState(now);

  const filtered = useMemo(() => {
    const s = search.toLowerCase().trim();
    if (!s) return users;
    return users.filter(
      (u) =>
        u.email.toLowerCase().includes(s) ||
        (u.full_name ?? "").toLowerCase().includes(s)
    );
  }, [users, search]);

  return (
    <div>
      <div className="px-6 py-4 border-b border-navy-50 grid grid-cols-1 md:grid-cols-4 gap-3 bg-navy-50/30">
        <div className="relative md:col-span-2">
          <Search className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Rechercher un stagiaire…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="pl-10"
          />
        </div>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1">Du</span>
          <Input
            type="date"
            value={from}
            onChange={(e) => setFrom(e.target.value)}
          />
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1">Au</span>
          <Input
            type="date"
            value={to}
            onChange={(e) => setTo(e.target.value)}
          />
        </label>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="bg-navy-50/60 text-[11px] uppercase tracking-wider text-slate-600">
              <th className="text-left px-5 py-3 font-semibold">Stagiaire</th>
              <th className="text-left px-5 py-3 font-semibold">Temps connecté</th>
              <th className="text-left px-5 py-3 font-semibold">Leçons</th>
              <th className="text-left px-5 py-3 font-semibold">Exercice</th>
              <th className="text-left px-5 py-3 font-semibold">Score</th>
              <th className="text-right px-5 py-3 font-semibold">Rapports</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((u) => (
              <tr key={u.id} className="border-t border-navy-50 hover:bg-navy-50/30">
                <td className="px-5 py-3.5">
                  <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center font-semibold text-[10px]">
                      {initials(u.full_name || u.email)}
                    </div>
                    <div>
                      <div className="font-medium text-navy-900">
                        {u.full_name || "—"}
                      </div>
                      <div className="text-xs text-slate-500">{u.email}</div>
                    </div>
                  </div>
                </td>
                <td className="px-5 py-3.5 text-sm">
                  <div className="font-semibold text-navy-900">
                    {fmtHours(u.total_session_s)}
                  </div>
                  <div className="text-xs text-slate-500">
                    {u.session_count} session{u.session_count > 1 ? "s" : ""}
                  </div>
                </td>
                <td className="px-5 py-3.5 text-sm">
                  <div>{u.lessons_viewed}</div>
                  <div className="text-xs text-slate-500">
                    {fmtHours(u.lesson_time_s)}
                  </div>
                </td>
                <td className="px-5 py-3.5 text-sm">
                  {u.quiz_passed}/{u.quiz_attempts}
                </td>
                <td className="px-5 py-3.5">
                  {u.quiz_attempts > 0 ? (
                    <Badge
                      tone={
                        u.avg_score >= 70
                          ? "success"
                          : u.avg_score >= 50
                          ? "gold"
                          : "slate"
                      }
                      size="sm"
                    >
                      {u.avg_score}%
                    </Badge>
                  ) : (
                    <span className="text-xs text-slate-400">—</span>
                  )}
                </td>
                <td className="px-5 py-3.5 text-right">
                  <div className="inline-flex flex-wrap items-center justify-end gap-1.5">
                    <a
                      href={`/admin/reports/export/presence?user=${u.id}&from=${from}&to=${to}`}
                      target="_blank"
                      title="Feuille de présence (journalière)"
                    >
                      <Button variant="secondary" size="sm">
                        <FileText className="h-3.5 w-3.5" /> Présence
                      </Button>
                    </a>
                    <a
                      href={`/admin/reports/export/emargement?user=${u.id}&from=${from}&to=${to}`}
                      target="_blank"
                      title="Émargement détaillé par leçon"
                    >
                      <Button variant="secondary" size="sm">
                        <ClipboardCheck className="h-3.5 w-3.5" /> Émargement
                      </Button>
                    </a>
                    <a
                      href={`/admin/reports/export/attestation?user=${u.id}`}
                      target="_blank"
                      title="Attestation de formation"
                    >
                      <Button variant="gold" size="sm">
                        <Award className="h-3.5 w-3.5" /> Attestation
                      </Button>
                    </a>
                    <a
                      href={`/admin/reports/export/certificat?user=${u.id}`}
                      target="_blank"
                      title="Certificat de réalisation"
                    >
                      <Button variant="gold" size="sm">
                        <BadgeCheck className="h-3.5 w-3.5" /> Certificat
                      </Button>
                    </a>
                  </div>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={6} className="px-5 py-16 text-center text-slate-400">
                  Aucun stagiaire.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
