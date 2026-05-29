"use client";

import { useEffect, useMemo, useRef, useState, useTransition } from "react";
import Link from "next/link";
import {
  Search,
  X,
  Tag,
  UserPlus,
  ChevronDown,
  Check,
  Mail,
  ArrowDownLeft,
  ArrowUpRight,
  CheckCircle2,
  AlertCircle,
} from "lucide-react";
import { EMAIL_LABELS, findLabel, LABEL_TONE_CLASSES } from "@/lib/email-labels";
import { assignEmail, markEmailRead, setEmailLabels } from "./actions";

type EmailRow = {
  id: string;
  direction: "inbound" | "outbound";
  sender_id: string | null;
  sender_email: string | null;
  from_name: string | null;
  recipients: string[] | null;
  cc?: string[] | null;
  bcc?: string[] | null;
  subject: string;
  body_html: string;
  status: string;
  labels: string[] | null;
  assigned_to: string | null;
  read_at: string | null;
  created_at: string;
  context?: string | null;
  error?: string | null;
};
type Admin = {
  id: string;
  full_name: string | null;
  email: string;
  role: string;
};
type Tab = "inbox" | "sent" | "all";

// ──────────────────────────────────────────────────────────────────────
const fmtDate = (iso: string) => {
  const d = new Date(iso);
  const now = new Date();
  const sameDay = d.toDateString() === now.toDateString();
  if (sameDay)
    return d.toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" });
  const sameYear = d.getFullYear() === now.getFullYear();
  return d.toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "short",
    year: sameYear ? undefined : "2-digit",
  });
};

const fmtFull = (iso: string) =>
  new Date(iso).toLocaleString("fr-FR", {
    dateStyle: "medium",
    timeStyle: "short",
  });

const previewText = (html: string, max = 120) => {
  const t = (html || "")
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  return t.length > max ? t.slice(0, max).trim() + "…" : t;
};

const initials = (name: string | null | undefined, email?: string | null) => {
  const s = (name || "").trim() || (email || "").split("@")[0] || "";
  const parts = s.split(/[\s._-]+/).filter(Boolean).slice(0, 2);
  return parts.map((p) => p[0]?.toUpperCase() ?? "").join("") || "?";
};

const adminColor = (id: string) => {
  const tones = [
    "bg-brand-700",
    "bg-gold-700",
    "bg-signal-700",
    "bg-violet-600",
    "bg-teal-600",
    "bg-rose-600",
    "bg-navy-700",
  ];
  let h = 0;
  for (let i = 0; i < id.length; i++) h = (h * 31 + id.charCodeAt(i)) >>> 0;
  return tones[h % tones.length];
};

// ──────────────────────────────────────────────────────────────────────
function LabelChip({
  id,
  onRemove,
}: {
  id: string;
  onRemove?: () => void;
}) {
  const meta = findLabel(id);
  const cls = meta
    ? LABEL_TONE_CLASSES[meta.tone]
    : "bg-slate-100 text-slate-700 border-slate-200";
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full border px-2 py-[2px] text-[11px] font-medium ${cls}`}
    >
      {meta ? <span aria-hidden>{meta.emoji}</span> : null}
      <span>{meta ? meta.name : id}</span>
      {onRemove ? (
        <button
          type="button"
          aria-label={`Retirer ${meta?.name ?? id}`}
          onClick={(e) => {
            e.stopPropagation();
            onRemove();
          }}
          className="ml-0.5 inline-flex h-3.5 w-3.5 items-center justify-center rounded-full transition-colors hover:bg-black/10"
        >
          <X className="h-2.5 w-2.5" />
        </button>
      ) : null}
    </span>
  );
}

function Popover({
  open,
  onClose,
  anchorRef,
  children,
  align = "right",
}: {
  open: boolean;
  onClose: () => void;
  anchorRef: React.RefObject<HTMLElement>;
  children: React.ReactNode;
  align?: "left" | "right";
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const onClick = (e: MouseEvent) => {
      if (!ref.current || !anchorRef.current) return;
      if (
        !ref.current.contains(e.target as Node) &&
        !anchorRef.current.contains(e.target as Node)
      ) {
        onClose();
      }
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("mousedown", onClick);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onClick);
      document.removeEventListener("keydown", onKey);
    };
  }, [open, onClose, anchorRef]);
  if (!open) return null;
  return (
    <div
      ref={ref}
      className={
        "absolute top-full z-30 mt-2 w-72 rounded-xl border border-navy-100 bg-white shadow-[0_10px_30px_-12px_rgba(14,18,64,0.18)] " +
        (align === "right" ? "right-0" : "left-0") +
        " origin-top motion-safe:animate-[fade-in_120ms_ease-out]"
      }
      style={{ transformOrigin: align === "right" ? "top right" : "top left" }}
    >
      {children}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────
function LabelPicker({
  rowId,
  current,
  onChange,
  pending,
}: {
  rowId: string;
  current: string[];
  onChange: (next: string[]) => void;
  pending: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const anchorRef = useRef<HTMLButtonElement>(null);
  const set = new Set(current);
  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    if (!needle) return EMAIL_LABELS;
    return EMAIL_LABELS.filter(
      (l) =>
        l.name.toLowerCase().includes(needle) || l.id.includes(needle)
    );
  }, [q]);

  const toggle = (id: string) => {
    const next = new Set(current);
    if (next.has(id)) next.delete(id);
    else next.add(id);
    onChange(Array.from(next));
  };

  return (
    <div className="relative inline-block">
      <button
        ref={anchorRef}
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          setOpen((v) => !v);
        }}
        disabled={pending}
        className="inline-flex items-center gap-1.5 rounded-md border border-navy-100 bg-white px-2 py-1 text-[11px] font-medium text-slate-600 transition-colors hover:border-navy-200 hover:text-navy-900 active:scale-[0.98]"
        aria-label="Ajouter un libellé"
      >
        <Tag className="h-3 w-3" />
        Libellé
      </button>
      <Popover
        open={open}
        onClose={() => setOpen(false)}
        anchorRef={anchorRef}
      >
        <div className="p-2">
          <div className="relative mb-1">
            <Search className="pointer-events-none absolute left-2 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-slate-400" />
            <input
              autoFocus
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Filtrer…"
              className="w-full rounded-md border border-navy-100 bg-white py-1.5 pl-7 pr-2 text-xs text-navy-950 placeholder:text-slate-400 outline-none focus:border-navy-300"
            />
          </div>
          <div className="max-h-64 overflow-y-auto py-1">
            {filtered.length === 0 ? (
              <div className="px-2 py-3 text-center text-[11px] text-slate-400">
                Aucun libellé
              </div>
            ) : null}
            {filtered.map((l) => {
              const active = set.has(l.id);
              return (
                <button
                  key={l.id}
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    toggle(l.id);
                  }}
                  className={
                    "flex w-full items-center justify-between gap-2 rounded-md px-2 py-1.5 text-left text-xs transition-colors " +
                    (active
                      ? "bg-signal-50 text-navy-900"
                      : "hover:bg-slate-50 text-slate-700")
                  }
                >
                  <span className="flex items-center gap-2">
                    <span
                      aria-hidden
                      className={`inline-flex h-5 w-5 items-center justify-center rounded-full border text-[10px] ${LABEL_TONE_CLASSES[l.tone]}`}
                    >
                      {l.emoji}
                    </span>
                    <span className="font-medium">{l.name}</span>
                  </span>
                  {active ? (
                    <Check className="h-3.5 w-3.5 text-signal-700" />
                  ) : null}
                </button>
              );
            })}
          </div>
        </div>
      </Popover>
    </div>
  );
}

function AssigneePicker({
  current,
  admins,
  onChange,
  pending,
}: {
  current: string | null;
  admins: Admin[];
  onChange: (id: string | null) => void;
  pending: boolean;
}) {
  const [open, setOpen] = useState(false);
  const anchorRef = useRef<HTMLButtonElement>(null);
  const assigned = current ? admins.find((a) => a.id === current) ?? null : null;

  return (
    <div className="relative inline-block">
      <button
        ref={anchorRef}
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          setOpen((v) => !v);
        }}
        disabled={pending}
        className={
          "inline-flex items-center gap-2 rounded-md border px-2 py-1 text-[11px] font-medium transition-colors active:scale-[0.98] " +
          (assigned
            ? "border-navy-100 bg-white text-navy-900 hover:border-navy-200"
            : "border-navy-100 bg-white text-slate-500 hover:text-navy-900 hover:border-navy-200")
        }
        aria-label="Attribuer"
      >
        {assigned ? (
          <>
            <span
              aria-hidden
              className={`inline-flex h-5 w-5 items-center justify-center rounded-full text-[10px] font-bold text-white ${adminColor(assigned.id)}`}
            >
              {initials(assigned.full_name, assigned.email)}
            </span>
            <span className="max-w-[120px] truncate">
              {assigned.full_name || assigned.email.split("@")[0]}
            </span>
            <ChevronDown className="h-3 w-3 opacity-60" />
          </>
        ) : (
          <>
            <UserPlus className="h-3 w-3" />
            Attribuer
          </>
        )}
      </button>
      <Popover
        open={open}
        onClose={() => setOpen(false)}
        anchorRef={anchorRef}
      >
        <div className="p-2">
          <div className="px-1 pb-1 pt-0.5 text-[10px] uppercase tracking-wider text-slate-400">
            Attribuer à
          </div>
          <div className="max-h-64 overflow-y-auto">
            {admins.length === 0 ? (
              <div className="px-2 py-3 text-center text-[11px] text-slate-400">
                Aucun admin disponible
              </div>
            ) : null}
            {admins.map((a) => {
              const active = a.id === current;
              return (
                <button
                  key={a.id}
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    onChange(a.id);
                    setOpen(false);
                  }}
                  className={
                    "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-xs transition-colors " +
                    (active ? "bg-slate-50" : "hover:bg-slate-50")
                  }
                >
                  <span
                    aria-hidden
                    className={`inline-flex h-6 w-6 items-center justify-center rounded-full text-[10px] font-bold text-white ${adminColor(a.id)}`}
                  >
                    {initials(a.full_name, a.email)}
                  </span>
                  <span className="flex min-w-0 flex-1 flex-col leading-tight">
                    <span className="truncate font-medium text-navy-900">
                      {a.full_name || a.email}
                    </span>
                    <span className="truncate text-[10px] text-slate-500">
                      {a.role === "super_admin" ? "Super-admin" : "Admin"}
                    </span>
                  </span>
                  {active ? (
                    <Check className="h-3.5 w-3.5 text-signal-700" />
                  ) : null}
                </button>
              );
            })}
            {current ? (
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  onChange(null);
                  setOpen(false);
                }}
                className="mt-1 flex w-full items-center gap-2 rounded-md border-t border-navy-50 px-2 py-1.5 text-left text-xs text-rose-600 transition-colors hover:bg-rose-50"
              >
                <X className="h-3.5 w-3.5" />
                Retirer l'attribution
              </button>
            ) : null}
          </div>
        </div>
      </Popover>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────────
function StatusBadge({ row }: { row: EmailRow }) {
  if (row.direction === "inbound") {
    return (
      <span className="inline-flex items-center gap-1 rounded-full bg-blue-50 px-2 py-[2px] text-[10px] font-semibold uppercase tracking-wider text-blue-700">
        <ArrowDownLeft className="h-2.5 w-2.5" />
        Reçu
      </span>
    );
  }
  if (row.status === "error") {
    return (
      <span className="inline-flex items-center gap-1 rounded-full bg-rose-50 px-2 py-[2px] text-[10px] font-semibold uppercase tracking-wider text-rose-700">
        <AlertCircle className="h-2.5 w-2.5" />
        Erreur
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-signal-50 px-2 py-[2px] text-[10px] font-semibold uppercase tracking-wider text-signal-800">
      <CheckCircle2 className="h-2.5 w-2.5" />
      Envoyé
    </span>
  );
}

// ──────────────────────────────────────────────────────────────────────
export function InboxTable({
  rows: rowsProp,
  admins,
  tab,
}: {
  rows: EmailRow[];
  admins: Admin[];
  tab: Tab;
}) {
  const [rows, setRows] = useState<EmailRow[]>(rowsProp);
  useEffect(() => setRows(rowsProp), [rowsProp]);

  const [expanded, setExpanded] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [pendingId, setPendingId] = useState<string | null>(null);
  const [, startTransition] = useTransition();

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return rows;
    return rows.filter((r) => {
      const hay = [
        r.subject,
        r.sender_email,
        r.from_name,
        ...(r.recipients ?? []),
        previewText(r.body_html, 220),
        ...(r.labels ?? []).map((id) => findLabel(id)?.name ?? id),
      ]
        .join(" ")
        .toLowerCase();
      return hay.includes(q);
    });
  }, [rows, search]);

  const onOpenRow = (id: string) => {
    setExpanded((cur) => (cur === id ? null : id));
    const row = rows.find((r) => r.id === id);
    if (row && row.direction === "inbound" && !row.read_at) {
      // optimistique
      setRows((cur) =>
        cur.map((r) =>
          r.id === id ? { ...r, read_at: new Date().toISOString() } : r
        )
      );
      startTransition(async () => {
        await markEmailRead(id, true);
      });
    }
  };

  const onChangeLabels = (id: string, labels: string[]) => {
    setPendingId(id);
    setRows((cur) =>
      cur.map((r) => (r.id === id ? { ...r, labels } : r))
    );
    startTransition(async () => {
      await setEmailLabels(id, labels);
      setPendingId(null);
    });
  };

  const onChangeAssignee = (id: string, userId: string | null) => {
    setPendingId(id);
    setRows((cur) =>
      cur.map((r) => (r.id === id ? { ...r, assigned_to: userId } : r))
    );
    startTransition(async () => {
      await assignEmail(id, userId);
      setPendingId(null);
    });
  };

  return (
    <section className="space-y-3">
      {/* Barre d'outils */}
      <div className="flex flex-wrap items-center gap-2">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Rechercher un objet, un expéditeur, un libellé…"
            className="w-full rounded-lg border border-navy-100 bg-white py-2 pl-9 pr-3 text-sm text-navy-950 placeholder:text-slate-400 outline-none transition-colors focus:border-navy-300"
          />
        </div>
        <div className="text-xs text-slate-500 tabular-nums">
          {filtered.length} message{filtered.length > 1 ? "s" : ""}
        </div>
      </div>

      {/* Liste */}
      {filtered.length === 0 ? (
        <div className="rounded-xl border border-dashed border-navy-100 bg-white py-16 text-center">
          <Mail className="mx-auto h-8 w-8 text-slate-300" />
          <p className="mt-3 text-sm text-slate-500">
            {tab === "inbox"
              ? "Aucun email reçu pour le moment."
              : tab === "sent"
                ? "Aucun email envoyé pour le moment."
                : "Aucun email."}
          </p>
          {tab === "inbox" ? (
            <p className="mt-1 text-[11px] text-slate-400">
              Configurez le webhook entrant de votre provider sur{" "}
              <code className="font-mono">/api/email/inbound</code> pour
              recevoir les emails ici.
            </p>
          ) : null}
        </div>
      ) : (
        <div className="overflow-hidden rounded-xl border border-navy-100 bg-white">
          <ul className="divide-y divide-navy-50">
            {filtered.map((row) => {
              const isOpen = expanded === row.id;
              const isUnread =
                row.direction === "inbound" && !row.read_at;
              const partyEmail =
                row.direction === "inbound"
                  ? row.sender_email ?? "?"
                  : (row.recipients ?? [])[0] ?? "?";
              const partyName =
                row.direction === "inbound"
                  ? row.from_name || row.sender_email || "?"
                  : (row.recipients ?? [])[0] ?? "?";
              const labels = row.labels ?? [];
              const recipientCount =
                row.direction === "outbound"
                  ? (row.recipients?.length ?? 0) +
                    (row.cc?.length ?? 0) +
                    (row.bcc?.length ?? 0)
                  : 1;
              return (
                <li
                  key={row.id}
                  className={
                    "transition-colors " +
                    (isOpen
                      ? "bg-slate-50/60"
                      : isUnread
                        ? "bg-white"
                        : "bg-white hover:bg-slate-50/40")
                  }
                >
                  <button
                    type="button"
                    onClick={() => onOpenRow(row.id)}
                    className="flex w-full items-start gap-3 px-4 py-3 text-left"
                    aria-expanded={isOpen}
                  >
                    {/* Pastille non-lu */}
                    <span
                      aria-hidden
                      className={
                        "mt-1.5 inline-block h-2 w-2 flex-none rounded-full " +
                        (isUnread
                          ? "bg-signal-500 shadow-[0_0_0_3px_rgba(159,226,32,0.18)]"
                          : "bg-transparent")
                      }
                    />

                    {/* Direction + partie */}
                    <div className="flex w-[220px] min-w-[180px] flex-none items-center gap-2">
                      <span
                        aria-hidden
                        className={
                          "inline-flex h-5 w-5 items-center justify-center rounded-full text-[10px] " +
                          (row.direction === "inbound"
                            ? "bg-blue-50 text-blue-700"
                            : "bg-navy-50 text-navy-700")
                        }
                      >
                        {row.direction === "inbound" ? (
                          <ArrowDownLeft className="h-3 w-3" />
                        ) : (
                          <ArrowUpRight className="h-3 w-3" />
                        )}
                      </span>
                      <span
                        className={
                          "truncate text-sm " +
                          (isUnread
                            ? "font-semibold text-navy-950"
                            : "text-navy-800")
                        }
                        title={partyEmail}
                      >
                        {partyName}
                        {recipientCount > 1 ? (
                          <span className="ml-1 text-[11px] font-normal text-slate-400">
                            +{recipientCount - 1}
                          </span>
                        ) : null}
                      </span>
                    </div>

                    {/* Objet + aperçu */}
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
                        <span
                          className={
                            "truncate text-sm " +
                            (isUnread
                              ? "font-semibold text-navy-950"
                              : "text-navy-900")
                          }
                        >
                          {row.subject || "(sans objet)"}
                        </span>
                        {labels.slice(0, 3).map((id) => (
                          <LabelChip key={id} id={id} />
                        ))}
                        {labels.length > 3 ? (
                          <span className="rounded-full bg-slate-100 px-1.5 py-[1px] text-[10px] font-medium text-slate-500">
                            +{labels.length - 3}
                          </span>
                        ) : null}
                      </div>
                      <p className="mt-0.5 truncate text-xs text-slate-500">
                        {previewText(row.body_html, 140) || "—"}
                      </p>
                    </div>

                    {/* Statut + date */}
                    <div className="flex w-[140px] flex-none flex-col items-end gap-1">
                      <StatusBadge row={row} />
                      <span
                        className="text-[11px] text-slate-500 tabular-nums"
                        title={fmtFull(row.created_at)}
                      >
                        {fmtDate(row.created_at)}
                      </span>
                    </div>
                  </button>

                  {/* Détail */}
                  {isOpen ? (
                    <div className="border-t border-navy-50 bg-white px-4 pb-5 pt-4 motion-safe:animate-[fade-in_140ms_ease-out]">
                      <div className="flex flex-wrap items-start justify-between gap-3 pb-3">
                        <div className="space-y-1">
                          <div className="text-[10px] uppercase tracking-wider text-slate-400">
                            {row.direction === "inbound" ? "De" : "À"}
                          </div>
                          <div className="text-sm text-navy-900">
                            {row.direction === "inbound" ? (
                              <>
                                {row.from_name ? (
                                  <span className="font-medium">
                                    {row.from_name}{" "}
                                  </span>
                                ) : null}
                                <span className="text-slate-600">
                                  &lt;{row.sender_email}&gt;
                                </span>
                              </>
                            ) : (
                              <span className="text-slate-700">
                                {(row.recipients ?? []).join(", ")}
                              </span>
                            )}
                          </div>
                          {row.direction === "outbound" &&
                          (row.cc?.length ?? 0) > 0 ? (
                            <div className="text-xs text-slate-500">
                              Cc&nbsp;: {(row.cc ?? []).join(", ")}
                            </div>
                          ) : null}
                        </div>
                        <div className="flex items-center gap-2">
                          <AssigneePicker
                            current={row.assigned_to}
                            admins={admins}
                            onChange={(uid) =>
                              onChangeAssignee(row.id, uid)
                            }
                            pending={pendingId === row.id}
                          />
                          <LabelPicker
                            rowId={row.id}
                            current={row.labels ?? []}
                            onChange={(next) =>
                              onChangeLabels(row.id, next)
                            }
                            pending={pendingId === row.id}
                          />
                        </div>
                      </div>

                      {(row.labels ?? []).length > 0 ? (
                        <div className="mb-3 flex flex-wrap gap-1.5">
                          {(row.labels ?? []).map((id) => (
                            <LabelChip
                              key={id}
                              id={id}
                              onRemove={() =>
                                onChangeLabels(
                                  row.id,
                                  (row.labels ?? []).filter((x) => x !== id)
                                )
                              }
                            />
                          ))}
                        </div>
                      ) : null}

                      <div
                        className="email-html rounded-lg border border-navy-50 bg-slate-50/40 p-4 text-sm leading-relaxed text-navy-900"
                        // body_html déjà sanitisé côté serveur (sendPlatformEmail / route inbound)
                        dangerouslySetInnerHTML={{ __html: row.body_html }}
                      />

                      <div className="mt-3 flex flex-wrap items-center justify-between gap-2 text-[11px] text-slate-500">
                        <span title={fmtFull(row.created_at)}>
                          {fmtFull(row.created_at)}
                        </span>
                        {row.direction === "inbound" ? (
                          <Link
                            href={`/admin/emails?reply=${row.id}`}
                            className="inline-flex items-center gap-1 rounded-md border border-navy-100 bg-white px-2 py-1 text-xs font-medium text-navy-900 transition-colors hover:border-navy-200 active:scale-[0.98]"
                          >
                            Répondre
                          </Link>
                        ) : row.error ? (
                          <span className="text-rose-600">
                            Erreur&nbsp;: {row.error}
                          </span>
                        ) : null}
                      </div>
                    </div>
                  ) : null}
                </li>
              );
            })}
          </ul>
        </div>
      )}
    </section>
  );
}
