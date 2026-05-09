"use client";
import { useEffect, useMemo, useState } from "react";
import { Search, X, Users, Shield, Loader2, ArrowRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { createClient } from "@/lib/supabase/client";
import { avatarTone, initials } from "@/lib/messaging-utils";
import {
  createOrGetDM,
  createOrGetAdminTeamConversation,
  createOrGetClassConversation,
} from "@/app/messages/actions";
import type { RecipientOption } from "@/lib/messaging-types";

interface Props {
  open: boolean;
  onClose: () => void;
  /** Appelé après création/récupération avec l'id de la conv. */
  onCreated: (conversationId: string) => void;
}

/**
 * Modal "Nouveau message" :
 *   - Charge la liste des destinataires possibles via list_recipients()
 *   - Recherche fuzzy par nom
 *   - Sélection → crée/récupère la conv + ferme + redirige
 *
 * Catégorise visuellement : Équipe admin · Classes · Personnes (par rôle).
 */
export function NewMessageModal({ open, onClose, onCreated }: Props) {
  const [recipients, setRecipients] = useState<RecipientOption[]>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Charge la liste à l'ouverture
  useEffect(() => {
    if (!open) return;
    setLoading(true);
    setError(null);
    setQuery("");
    const supabase = createClient();
    void (async () => {
      const { data, error: rpcErr } = await supabase.rpc("list_recipients");
      if (rpcErr) {
        setError(rpcErr.message);
      } else {
        setRecipients((data ?? []) as RecipientOption[]);
      }
      setLoading(false);
    })();
  }, [open]);

  // Click outside / Escape
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  const filtered = useMemo(() => {
    if (!query.trim()) return recipients;
    const q = query.trim().toLowerCase();
    return recipients.filter(
      (r) =>
        r.display_name.toLowerCase().includes(q) ||
        (r.subtitle ?? "").toLowerCase().includes(q)
    );
  }, [recipients, query]);

  // Catégorisation pour affichage en sections
  const sections = useMemo(() => {
    const adminTeam = filtered.filter((r) => r.kind === "admin_team");
    const classes = filtered.filter((r) => r.kind === "class");
    const trainers = filtered.filter(
      (r) => r.kind === "user" && r.user_role === "trainer"
    );
    const students = filtered.filter(
      (r) => r.kind === "user" && r.user_role === "student"
    );
    const admins = filtered.filter(
      (r) =>
        r.kind === "user" &&
        (r.user_role === "admin" || r.user_role === "super_admin")
    );
    return [
      { key: "admin_team", label: "Service support", items: adminTeam },
      { key: "classes", label: "Classes", items: classes },
      { key: "trainers", label: "Formateurs", items: trainers },
      { key: "admins", label: "Administration", items: admins },
      { key: "students", label: "Stagiaires", items: students },
    ].filter((s) => s.items.length > 0);
  }, [filtered]);

  const handleSelect = async (r: RecipientOption) => {
    if (creating) return;
    setError(null);
    setCreating(true);
    try {
      let convId: string;
      if (r.kind === "admin_team") {
        convId = await createOrGetAdminTeamConversation();
      } else if (r.kind === "class") {
        if (!r.group_id) throw new Error("Classe invalide");
        convId = await createOrGetClassConversation(r.group_id);
      } else {
        if (!r.user_id) throw new Error("Destinataire invalide");
        convId = await createOrGetDM(r.user_id);
      }
      onCreated(convId);
      onClose();
    } catch (err: any) {
      setError(err?.message ?? "Échec de création");
    } finally {
      setCreating(false);
    }
  };

  if (!open) return null;

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-navy-950/40 backdrop-blur-sm z-40 animate-notif-backdrop"
        onClick={onClose}
        aria-hidden
      />
      {/* Modal */}
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Nouveau message"
        className={cn(
          "fixed z-50 left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2",
          "w-[min(92vw,560px)] max-h-[80vh] flex flex-col",
          "bg-white rounded-2xl border border-navy-100 shadow-float",
          "animate-notif-pop"
        )}
      >
        {/* Header */}
        <div className="px-5 pt-5 pb-3 border-b border-navy-100">
          <div className="flex items-center justify-between gap-3">
            <h2 className="font-display text-lg font-semibold text-navy-950 tracking-tight">
              Nouveau message
            </h2>
            <button
              type="button"
              onClick={onClose}
              aria-label="Fermer"
              className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-500 hover:text-navy-900 hover:bg-navy-50 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
          <p className="mt-1 text-[12.5px] text-slate-500">
            Choisissez un destinataire pour démarrer la conversation.
          </p>

          {/* Recherche */}
          <div className="relative mt-3">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
            <input
              type="text"
              autoFocus
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Rechercher un nom, une classe…"
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

        {/* Erreur */}
        {error && (
          <div className="mx-5 mt-3 px-3 py-2 rounded-md text-[12px] bg-rose-50 text-rose-700 border border-rose-200">
            {error}
          </div>
        )}

        {/* Liste destinataires */}
        <div className="flex-1 overflow-y-auto overscroll-contain p-2">
          {loading ? (
            <div className="py-10 text-center text-[12px] text-slate-400 flex items-center justify-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" /> Chargement…
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-12 text-center">
              <Search className="h-7 w-7 text-slate-300 mx-auto" />
              <p className="mt-3 text-[12.5px] text-slate-500">
                Aucun destinataire trouvé.
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {sections.map((section) => (
                <section key={section.key}>
                  <div className="px-3 py-1.5 text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500">
                    {section.label}
                  </div>
                  <ul className="space-y-0.5">
                    {section.items.map((r) => (
                      <li key={`${r.kind}-${r.user_id ?? r.group_id ?? "team"}`}>
                        <RecipientRow
                          recipient={r}
                          onClick={() => handleSelect(r)}
                          disabled={creating}
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
    </>
  );
}

function RecipientRow({
  recipient,
  onClick,
  disabled,
}: {
  recipient: RecipientOption;
  onClick: () => void;
  disabled: boolean;
}) {
  const r = recipient;
  const seed = r.user_id ?? r.group_id ?? r.kind;
  const tone = avatarTone(seed);

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className={cn(
        "w-full text-left flex items-center gap-3 px-3 py-2.5 rounded-lg",
        "transition-colors duration-150 ease-out group/recipient",
        "hover:bg-navy-50/60",
        "focus-visible:bg-navy-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-navy-300",
        disabled && "opacity-50 cursor-wait"
      )}
    >
      {/* Avatar */}
      <span
        className={cn(
          "h-9 w-9 rounded-xl flex items-center justify-center shrink-0 font-semibold text-[12.5px]",
          tone
        )}
        aria-hidden
      >
        {r.kind === "admin_team" ? (
          <Shield className="h-4 w-4" />
        ) : r.kind === "class" ? (
          <Users className="h-4 w-4" />
        ) : (
          initials(r.display_name)
        )}
      </span>

      <div className="flex-1 min-w-0">
        <div className="text-[13.5px] font-semibold text-navy-950 truncate">
          {r.display_name}
        </div>
        {r.subtitle && (
          <div className="text-[11.5px] text-slate-500 truncate">
            {r.subtitle}
          </div>
        )}
      </div>

      <ArrowRight className="h-3.5 w-3.5 text-slate-300 group-hover/recipient:text-navy-700 group-hover/recipient:translate-x-0.5 transition-all duration-150" />
    </button>
  );
}
