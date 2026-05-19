"use client";

import {
  Inbox,
  ArrowRight,
  UserPlus,
  UserMinus,
  Pencil,
  Calendar,
  Clock,
  Mail,
  CheckCircle2,
} from "lucide-react";

const KIND_META: Record<
  string,
  { label: (d: any) => string; icon: any; color: string }
> = {
  created: {
    label: () => "Lead créé via le formulaire",
    icon: Inbox,
    color: "text-gold-700 bg-gold-50 border-gold-200",
  },
  status_changed: {
    label: (d) => `Statut changé : ${d.from} → ${d.to}`,
    icon: ArrowRight,
    color: "text-navy-700 bg-navy-50 border-navy-200",
  },
  assigned: {
    label: () => "Lead assigné",
    icon: UserPlus,
    color: "text-emerald-700 bg-emerald-50 border-emerald-200",
  },
  unassigned: {
    label: () => "Lead libéré",
    icon: UserMinus,
    color: "text-slate-700 bg-slate-50 border-slate-200",
  },
  note_added: {
    label: (d) => `Note ajoutée (${d.note_kind})`,
    icon: Pencil,
    color: "text-navy-700 bg-navy-50 border-navy-200",
  },
  followup_scheduled: {
    label: (d) =>
      `Relance planifiée le ${new Date(d.next_at).toLocaleDateString("fr-FR")}`,
    icon: Calendar,
    color: "text-amber-700 bg-amber-50 border-amber-200",
  },
  snoozed: {
    label: (d) =>
      `Mis en pause jusqu'au ${new Date(d.until).toLocaleDateString("fr-FR")}`,
    icon: Clock,
    color: "text-slate-700 bg-slate-50 border-slate-200",
  },
  unsnoozed: {
    label: () => "Sorti de pause",
    icon: Clock,
    color: "text-emerald-700 bg-emerald-50 border-emerald-200",
  },
  email_sent: {
    label: () => "Email envoyé",
    icon: Mail,
    color: "text-navy-700 bg-navy-50 border-navy-200",
  },
  converted: {
    label: () => "Lead converti en stagiaire",
    icon: CheckCircle2,
    color: "text-emerald-700 bg-emerald-50 border-emerald-200",
  },
};

export function LeadTimeline({ activities }: { activities: any[] }) {
  if (!activities || activities.length === 0) {
    return (
      <p className="text-xs text-slate-500 italic">
        Aucune activité enregistrée.
      </p>
    );
  }

  return (
    <ol className="space-y-2.5">
      {activities.map((a) => {
        const meta = KIND_META[a.kind] ?? {
          label: () => a.kind,
          icon: Pencil,
          color: "text-slate-700 bg-slate-50 border-slate-200",
        };
        const Icon = meta.icon;
        return (
          <li key={a.id} className="flex items-start gap-2.5">
            <div
              className={`h-6 w-6 rounded-md border flex items-center justify-center shrink-0 ${meta.color}`}
            >
              <Icon className="h-3 w-3" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-xs text-navy-900 leading-snug">
                {meta.label(a.details ?? {})}
              </p>
              <p className="text-[10px] text-slate-500">
                {a.author?.full_name ?? "—"} ·{" "}
                {new Date(a.created_at).toLocaleDateString("fr-FR", {
                  day: "2-digit",
                  month: "short",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </p>
            </div>
          </li>
        );
      })}
    </ol>
  );
}
