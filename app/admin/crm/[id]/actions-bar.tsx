"use client";

import { useState, useTransition } from "react";
import {
  UserPlus,
  UserMinus,
  Calendar,
  Clock,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Loader2,
  Send,
  Mail,
} from "lucide-react";
import {
  selfAssignLead,
  unassignLead,
  scheduleFollowup,
  snoozeLead,
  unsnoozeLead,
  updateStatus,
} from "../actions";
import { QuoteDialog, type QuoteDefaults } from "./quote-dialog";

export function LeadActionsBar({
  leadId,
  currentStatus,
  isMine,
  isAssigned,
  isSnoozed,
  hasFollowup,
  quoteDefaults,
}: {
  leadId: string;
  currentStatus: string;
  isMine: boolean;
  isAssigned: boolean;
  isSnoozed: boolean;
  hasFollowup: boolean;
  quoteDefaults: QuoteDefaults;
}) {
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [showFollowup, setShowFollowup] = useState(false);
  const [showSnooze, setShowSnooze] = useState(false);

  const run = (action: () => Promise<{ ok: boolean; error?: string }>) => {
    setError(null);
    startTransition(async () => {
      const res = await action();
      if (!res.ok) setError(res.error ?? "Erreur");
    });
  };

  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-4 space-y-3">
      {/* Ligne 1 : assignation + statut */}
      <div className="flex items-center gap-2 flex-wrap">
        {!isAssigned && (
          <button
            type="button"
            onClick={() => run(() => selfAssignLead(leadId))}
            disabled={pending}
            className="inline-flex items-center gap-1.5 rounded-lg bg-navy-900 hover:bg-navy-800 text-white px-3 py-1.5 text-sm font-medium transition-colors disabled:opacity-60"
          >
            {pending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <UserPlus className="h-3.5 w-3.5" />
            )}
            Je prends ce lead
          </button>
        )}
        {isMine && (
          <button
            type="button"
            onClick={() => run(() => unassignLead(leadId))}
            disabled={pending}
            className="inline-flex items-center gap-1.5 rounded-lg bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-3 py-1.5 text-sm font-medium transition-colors disabled:opacity-60"
          >
            <UserMinus className="h-3.5 w-3.5" />
            Libérer
          </button>
        )}

        {isMine && (
          <div className="flex items-center gap-1.5 ml-auto flex-wrap justify-end">
            <QuoteDialog leadId={leadId} defaults={quoteDefaults} />
            <span className="hidden sm:block w-px h-5 bg-navy-100 mx-1" />
            <span className="text-xs text-slate-500 mr-1">Statut :</span>
            <StatusButton
              currentStatus={currentStatus}
              status="contacte"
              label="Contacté"
              icon={Mail}
              onClick={() =>
                run(() => updateStatus(leadId, "contacte"))
              }
              disabled={pending}
            />
            <StatusButton
              currentStatus={currentStatus}
              status="devis_envoye"
              label="Devis envoyé"
              icon={Send}
              onClick={() =>
                run(() => updateStatus(leadId, "devis_envoye"))
              }
              disabled={pending}
            />
            <StatusButton
              currentStatus={currentStatus}
              status="inscrit"
              label="Inscrit"
              icon={CheckCircle2}
              onClick={() => run(() => updateStatus(leadId, "inscrit"))}
              disabled={pending}
              tone="success"
            />
            <StatusButton
              currentStatus={currentStatus}
              status="refuse"
              label="Refusé"
              icon={XCircle}
              onClick={() => run(() => updateStatus(leadId, "refuse"))}
              disabled={pending}
              tone="rose"
            />
          </div>
        )}
      </div>

      {/* Ligne 2 : relance + snooze */}
      {isMine && (
        <div className="flex items-center gap-2 flex-wrap pt-3 border-t border-navy-50">
          {/* Schedule followup */}
          {showFollowup ? (
            <FollowupQuickPicker
              onPick={(days) => {
                run(() => scheduleFollowup(leadId, days));
                setShowFollowup(false);
              }}
              onCancel={() => setShowFollowup(false)}
              pending={pending}
            />
          ) : (
            <button
              type="button"
              onClick={() => setShowFollowup(true)}
              disabled={pending}
              className="inline-flex items-center gap-1.5 rounded-lg bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-3 py-1.5 text-sm font-medium transition-colors"
            >
              <Calendar className="h-3.5 w-3.5" />
              {hasFollowup ? "Replanifier la relance" : "Planifier une relance"}
            </button>
          )}

          {/* Snooze */}
          {showSnooze ? (
            <SnoozeQuickPicker
              onPick={(days) => {
                run(() => snoozeLead(leadId, days));
                setShowSnooze(false);
              }}
              onCancel={() => setShowSnooze(false)}
              pending={pending}
            />
          ) : isSnoozed ? (
            <button
              type="button"
              onClick={() => run(() => unsnoozeLead(leadId))}
              disabled={pending}
              className="inline-flex items-center gap-1.5 rounded-lg bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-3 py-1.5 text-sm font-medium transition-colors"
            >
              <Clock className="h-3.5 w-3.5" />
              Sortir de pause
            </button>
          ) : (
            <button
              type="button"
              onClick={() => setShowSnooze(true)}
              disabled={pending}
              className="inline-flex items-center gap-1.5 rounded-lg bg-white border border-navy-200 hover:bg-navy-50 text-navy-900 px-3 py-1.5 text-sm font-medium transition-colors"
            >
              <Clock className="h-3.5 w-3.5" />
              Mettre en pause
            </button>
          )}
        </div>
      )}

      {!isMine && isAssigned && (
        <div className="text-xs text-slate-500 italic">
          Ce lead est déjà pris par un autre administrateur. Vous voyez les
          informations en lecture seule.
        </div>
      )}

      {error && (
        <div className="flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2 text-xs text-rose-800">
          <AlertCircle className="h-3.5 w-3.5 shrink-0 mt-0.5" />
          {error}
        </div>
      )}
    </div>
  );
}

function StatusButton({
  currentStatus,
  status,
  label,
  icon: Icon,
  onClick,
  disabled,
  tone = "navy",
}: {
  currentStatus: string;
  status: string;
  label: string;
  icon: any;
  onClick: () => void;
  disabled?: boolean;
  tone?: "navy" | "success" | "rose";
}) {
  const isCurrent = currentStatus === status;
  const colors =
    tone === "success"
      ? "bg-emerald-50 border-emerald-200 hover:bg-emerald-100 text-emerald-800"
      : tone === "rose"
        ? "bg-rose-50 border-rose-200 hover:bg-rose-100 text-rose-800"
        : "bg-white border-navy-200 hover:bg-navy-50 text-navy-900";
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled || isCurrent}
      title={isCurrent ? "Statut actuel" : `Passer en : ${label}`}
      className={`inline-flex items-center gap-1 rounded-md border px-2 py-1 text-xs font-medium transition-colors ${colors} ${
        isCurrent ? "opacity-50 cursor-default" : ""
      }`}
    >
      <Icon className="h-3 w-3" />
      {label}
    </button>
  );
}

function FollowupQuickPicker({
  onPick,
  onCancel,
  pending,
}: {
  onPick: (days: number) => void;
  onCancel: () => void;
  pending: boolean;
}) {
  return (
    <div className="inline-flex items-center gap-1 bg-navy-50 rounded-lg p-1">
      <span className="text-[11px] text-slate-600 px-2">Dans :</span>
      {[1, 3, 7, 14, 30].map((d) => (
        <button
          key={d}
          type="button"
          onClick={() => onPick(d)}
          disabled={pending}
          className="rounded-md bg-white hover:bg-gold-50 border border-navy-100 text-xs font-medium px-2 py-1 transition-colors"
        >
          {d}j
        </button>
      ))}
      <button
        type="button"
        onClick={onCancel}
        className="text-[11px] text-slate-500 hover:text-navy-900 px-1"
      >
        ✕
      </button>
    </div>
  );
}

function SnoozeQuickPicker({
  onPick,
  onCancel,
  pending,
}: {
  onPick: (days: number) => void;
  onCancel: () => void;
  pending: boolean;
}) {
  return (
    <div className="inline-flex items-center gap-1 bg-navy-50 rounded-lg p-1">
      <span className="text-[11px] text-slate-600 px-2">Pause :</span>
      {[7, 14, 30, 60].map((d) => (
        <button
          key={d}
          type="button"
          onClick={() => onPick(d)}
          disabled={pending}
          className="rounded-md bg-white hover:bg-slate-100 border border-navy-100 text-xs font-medium px-2 py-1 transition-colors"
        >
          {d}j
        </button>
      ))}
      <button
        type="button"
        onClick={onCancel}
        className="text-[11px] text-slate-500 hover:text-navy-900 px-1"
      >
        ✕
      </button>
    </div>
  );
}
