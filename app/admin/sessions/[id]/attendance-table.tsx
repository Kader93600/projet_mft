"use client";

import { useState, useTransition } from "react";
import {
  CheckCircle2,
  XCircle,
  Clock,
  ShieldCheck,
  AlertCircle,
  Loader2,
  UserMinus,
  PenLine,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  markPresent,
  markAbsent,
  removeEnrollment,
  validateAttendance,
} from "../actions";

type Enrollment = {
  user_id: string;
  status: "invited" | "confirmed" | "cancelled" | "no_show";
  registered_at: string;
  cancelled_at: string | null;
  cancellation_reason: string | null;
};

type AttendanceRow = {
  user_id: string;
  signed_at: string;
  method: string;
  ip_address: string | null;
  validated_at: string | null;
  notes: string | null;
};

type Profile = { id: string; full_name: string | null; email: string };

const METHOD_LABEL: Record<string, string> = {
  online_click: "Clic en ligne",
  qr_code: "QR code",
  manual: "Manuel",
  signature_pad: "Signature",
};

function fmt(iso: string): string {
  return new Date(iso).toLocaleTimeString("fr-FR", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function fmtFull(iso: string): string {
  return new Date(iso).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function AttendanceTable({
  sessionId,
  enrollments,
  attendance,
  profiles,
  sessionStatus,
}: {
  sessionId: string;
  enrollments: Enrollment[];
  attendance: AttendanceRow[];
  profiles: Profile[];
  sessionStatus: string;
}) {
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  const attendanceMap = new Map(attendance.map((a) => [a.user_id, a]));
  const profileMap = new Map(profiles.map((p) => [p.id, p]));

  const active = enrollments.filter(
    (e) => e.status === "confirmed" || e.status === "invited"
  );
  const cancelled = enrollments.filter((e) => e.status === "cancelled");
  const noShow = enrollments.filter((e) => e.status === "no_show");

  if (enrollments.length === 0) {
    return (
      <div className="rounded-2xl border border-dashed border-navy-200 bg-white px-6 py-12 text-center">
        <UserMinus className="h-10 w-10 text-slate-300 mx-auto mb-3" />
        <p className="text-sm text-slate-600">
          Aucun stagiaire inscrit pour le moment.
        </p>
        <p className="text-xs text-slate-500 mt-1">
          Invitez les stagiaires Premium ci-dessous, ou laissez-les
          s'auto-inscrire.
        </p>
      </div>
    );
  }

  function action(userId: string, fn: () => Promise<void>) {
    setError(null);
    setPendingId(userId);
    startTransition(async () => {
      try {
        await fn();
      } catch (e: any) {
        setError(e.message ?? "Erreur");
      } finally {
        setPendingId(null);
      }
    });
  }

  return (
    <div className="space-y-4">
      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-rose-50 border border-rose-200 px-3 py-2 text-sm text-rose-800">
          <AlertCircle className="h-4 w-4" />
          {error}
        </div>
      )}
      <div className="rounded-2xl border border-navy-100 bg-white overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-ivory border-b border-navy-100">
              <tr className="text-left">
                <th className="px-4 py-3 font-semibold text-navy-900">
                  Stagiaire
                </th>
                <th className="px-4 py-3 font-semibold text-navy-900">
                  Inscription
                </th>
                <th className="px-4 py-3 font-semibold text-navy-900">
                  Émargement
                </th>
                <th className="px-4 py-3 font-semibold text-navy-900 text-right">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-navy-100">
              {active.map((e) => {
                const p = profileMap.get(e.user_id);
                const a = attendanceMap.get(e.user_id);
                const isPending = pendingId === e.user_id;
                return (
                  <tr key={e.user_id} className="hover:bg-ivory/40">
                    <td className="px-4 py-3">
                      <div className="font-semibold text-navy-950">
                        {p?.full_name ?? "Anonyme"}
                      </div>
                      <div className="text-xs text-slate-500">
                        {p?.email}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <Badge
                        tone={e.status === "confirmed" ? "navy" : "gold"}
                        size="sm"
                      >
                        {e.status === "confirmed" ? "Confirmé" : "Invité"}
                      </Badge>
                      <div className="text-[11px] text-slate-500 mt-1">
                        {fmtFull(e.registered_at)}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      {a ? (
                        <div>
                          <Badge tone="success" size="sm">
                            <CheckCircle2 className="h-3 w-3" />
                            Présent · {fmt(a.signed_at)}
                          </Badge>
                          <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-2 flex-wrap">
                            <span>{METHOD_LABEL[a.method] ?? a.method}</span>
                            {a.validated_at && (
                              <span className="inline-flex items-center gap-0.5 text-emerald-700">
                                <ShieldCheck className="h-3 w-3" />
                                Validé
                              </span>
                            )}
                          </div>
                        </div>
                      ) : (
                        <span className="inline-flex items-center gap-1.5 text-xs text-slate-500">
                          <Clock className="h-3 w-3" />
                          En attente
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right">
                      <div className="inline-flex items-center gap-1.5">
                        {!a && (
                          <Button
                            variant="secondary"
                            size="sm"
                            disabled={isPending}
                            onClick={() =>
                              action(e.user_id, () =>
                                markPresent(sessionId, e.user_id)
                              )
                            }
                          >
                            {isPending ? (
                              <Loader2 className="h-3.5 w-3.5 animate-spin" />
                            ) : (
                              <PenLine className="h-3.5 w-3.5" />
                            )}
                            Émarger
                          </Button>
                        )}
                        {a && !a.validated_at && (
                          <Button
                            variant="gold"
                            size="sm"
                            disabled={isPending}
                            onClick={() =>
                              action(e.user_id, () =>
                                validateAttendance(sessionId, e.user_id)
                              )
                            }
                          >
                            <ShieldCheck className="h-3.5 w-3.5" />
                            Valider
                          </Button>
                        )}
                        {sessionStatus !== "scheduled" && (
                          <Button
                            variant="ghost"
                            size="sm"
                            disabled={isPending}
                            onClick={() =>
                              action(e.user_id, () =>
                                markAbsent(sessionId, e.user_id)
                              )
                            }
                          >
                            <XCircle className="h-3.5 w-3.5" />
                            Absent
                          </Button>
                        )}
                        {sessionStatus === "scheduled" && (
                          <Button
                            variant="ghost"
                            size="sm"
                            disabled={isPending}
                            onClick={() => {
                              if (
                                !confirm(
                                  "Retirer ce stagiaire de la session ?"
                                )
                              )
                                return;
                              action(e.user_id, () =>
                                removeEnrollment(sessionId, e.user_id)
                              );
                            }}
                          >
                            <UserMinus className="h-3.5 w-3.5" />
                          </Button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}

              {noShow.map((e) => {
                const p = profileMap.get(e.user_id);
                return (
                  <tr key={e.user_id} className="bg-rose-50/30">
                    <td className="px-4 py-3">
                      <div className="font-semibold text-navy-950">
                        {p?.full_name ?? "Anonyme"}
                      </div>
                      <div className="text-xs text-slate-500">{p?.email}</div>
                    </td>
                    <td className="px-4 py-3" colSpan={2}>
                      <Badge tone="rose" size="sm">
                        <XCircle className="h-3 w-3" />
                        Absent (non émargé)
                      </Badge>
                    </td>
                    <td className="px-4 py-3 text-right">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() =>
                          action(e.user_id, () =>
                            markPresent(sessionId, e.user_id)
                          )
                        }
                      >
                        Rétablir
                      </Button>
                    </td>
                  </tr>
                );
              })}

              {cancelled.map((e) => {
                const p = profileMap.get(e.user_id);
                return (
                  <tr key={e.user_id} className="opacity-60">
                    <td className="px-4 py-3">
                      <div className="font-medium text-slate-700 line-through">
                        {p?.full_name ?? "Anonyme"}
                      </div>
                      <div className="text-xs text-slate-500">{p?.email}</div>
                    </td>
                    <td className="px-4 py-3" colSpan={2}>
                      <Badge tone="slate" size="sm">
                        Désinscrit
                      </Badge>
                      {e.cancellation_reason && (
                        <div className="text-[11px] text-slate-500 mt-1">
                          {e.cancellation_reason}
                        </div>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right" />
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
