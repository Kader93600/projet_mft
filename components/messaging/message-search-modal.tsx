"use client";
import {
  useEffect,
  useMemo,
  useRef,
  useState,
  useCallback,
} from "react";
import { Search, X, Loader2, MessageCircle, Users, Shield } from "lucide-react";
import { cn } from "@/lib/utils";
import { sanitizeSearchTerm } from "@/lib/search";
import { createClient } from "@/lib/supabase/client";
import {
  avatarTone,
  initials,
  relativeTimeFr,
} from "@/lib/messaging-utils";
import type { MessageSearchResult } from "@/lib/messaging-types";

interface Props {
  open: boolean;
  onClose: () => void;
  /** Quand l'utilisateur clique sur un résultat → ouvre la conv */
  onPickConversation: (conversationId: string) => void;
  /** Pour mettre en surbrillance "moi" dans les résultats */
  viewerId: string;
}

const DEBOUNCE_MS = 280;
const MIN_QUERY_LENGTH = 2;
const RESULT_LIMIT = 50;

/**
 * Modal de recherche globale dans tous les messages des conversations
 * où l'utilisateur est participant. RLS gère automatiquement le filtre
 * par participation.
 *
 * - Cmd/Ctrl+K ouvre · Esc ferme
 * - Recherche debounced 280ms après ≥ 2 caractères
 * - Résultats : avatar sender + body avec match surligné + conv + date
 * - Click sur résultat → ouvre la conv (le shell scrollera au bas)
 */
export function MessageSearchModal({
  open,
  onClose,
  onPickConversation,
  viewerId,
}: Props) {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<MessageSearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const debounceRef = useRef<number | null>(null);

  // Reset quand ouverture/fermeture
  useEffect(() => {
    if (open) {
      setQuery("");
      setResults([]);
      setError(null);
      // Focus l'input après animation
      window.setTimeout(() => inputRef.current?.focus(), 60);
    }
  }, [open]);

  // Esc pour fermer
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  // Recherche debounced
  useEffect(() => {
    if (!open) return;
    if (debounceRef.current) {
      window.clearTimeout(debounceRef.current);
    }
    const trimmed = query.trim();
    if (trimmed.length < MIN_QUERY_LENGTH) {
      setResults([]);
      setLoading(false);
      return;
    }
    setLoading(true);
    debounceRef.current = window.setTimeout(async () => {
      const supabase = createClient();
      // Nettoie le terme (wildcards SQL + métacaractères de filtre PostgREST).
      const safe = sanitizeSearchTerm(trimmed);
      // 1) Récupère les messages matchants (RLS filtre déjà par participation)
      const { data: msgs, error: e1 } = await supabase
        .from("messages")
        .select(
          "id, conversation_id, sender_id, sender_role, body, created_at"
        )
        .ilike("body", `%${safe}%`)
        .is("deleted_at", null)
        .order("created_at", { ascending: false })
        .limit(RESULT_LIMIT);
      if (e1) {
        setError(e1.message);
        setLoading(false);
        return;
      }

      const rows = (msgs ?? []) as any[];
      if (rows.length === 0) {
        setResults([]);
        setLoading(false);
        return;
      }

      // 2) Charge les profils + les convs en parallèle
      const senderIds = Array.from(new Set(rows.map((r) => r.sender_id)));
      const convIds = Array.from(new Set(rows.map((r) => r.conversation_id)));

      const [profsRes, convsRes] = await Promise.all([
        supabase
          .from("profiles")
          .select("id, full_name, email")
          .in("id", senderIds),
        supabase.rpc("list_my_conversations"),
      ]);

      const profMap: Record<string, any> = {};
      for (const p of profsRes.data ?? []) profMap[(p as any).id] = p;
      const convMap: Record<string, any> = {};
      for (const c of (convsRes.data ?? []) as any[]) convMap[c.id] = c;

      const enriched: MessageSearchResult[] = rows.map((m) => {
        const conv = convMap[m.conversation_id];
        const prof = profMap[m.sender_id];
        return {
          id: m.id,
          conversation_id: m.conversation_id,
          conversation_title: conv?.title ?? "Conversation",
          conversation_kind: conv?.kind ?? "dm",
          conversation_scope: conv?.scope ?? null,
          sender_id: m.sender_id,
          sender_name: prof?.full_name ?? prof?.email ?? null,
          sender_role: m.sender_role,
          body: m.body,
          created_at: m.created_at,
        };
      });

      setResults(enriched);
      setLoading(false);
    }, DEBOUNCE_MS);

    return () => {
      if (debounceRef.current) window.clearTimeout(debounceRef.current);
    };
  }, [query, open]);

  // Group par conversation
  const grouped = useMemo(() => {
    const map = new Map<string, MessageSearchResult[]>();
    for (const r of results) {
      const arr = map.get(r.conversation_id);
      if (arr) arr.push(r);
      else map.set(r.conversation_id, [r]);
    }
    return Array.from(map.entries()).map(([convId, items]) => ({
      convId,
      title: items[0].conversation_title,
      kind: items[0].conversation_kind,
      scope: items[0].conversation_scope,
      items,
    }));
  }, [results]);

  const handlePick = useCallback(
    (convId: string) => {
      onPickConversation(convId);
      onClose();
    },
    [onPickConversation, onClose]
  );

  if (!open) return null;

  return (
    <>
      <div
        className="fixed inset-0 bg-navy-950/50 backdrop-blur-sm z-50 animate-notif-backdrop"
        onClick={onClose}
        aria-hidden
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Recherche dans les messages"
        className={cn(
          "fixed z-50 left-1/2 top-[8vh] -translate-x-1/2",
          "w-[min(92vw,640px)] max-h-[80vh] flex flex-col",
          "bg-white rounded-2xl border border-navy-100 shadow-float",
          "animate-notif-pop"
        )}
      >
        {/* Header avec input */}
        <div className="px-5 pt-4 pb-3 border-b border-navy-100">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400 pointer-events-none" />
            <input
              ref={inputRef}
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Rechercher dans tous les messages…"
              className={cn(
                "w-full h-11 pl-10 pr-10 rounded-xl text-[14px]",
                "bg-navy-50/40 border border-navy-100",
                "placeholder:text-slate-400 text-navy-950",
                "outline-none transition-shadow duration-150",
                "focus:border-navy-300 focus:bg-white focus:shadow-ring-brand"
              )}
            />
            {query && (
              <button
                type="button"
                onClick={() => setQuery("")}
                aria-label="Effacer"
                className="absolute right-2 top-1/2 -translate-y-1/2 h-7 w-7 rounded-md text-slate-400 hover:text-navy-700 hover:bg-navy-50 flex items-center justify-center transition-colors"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>
          <div className="mt-2 text-[10.5px] text-slate-400 px-1">
            Cherche dans toutes tes conversations · Min. 2 caractères ·{" "}
            <kbd className="px-1 py-0.5 rounded bg-navy-50 text-navy-700 font-mono text-[9.5px]">
              Esc
            </kbd>{" "}
            pour fermer
          </div>
        </div>

        {/* Résultats */}
        <div className="flex-1 overflow-y-auto overscroll-contain p-2">
          {loading ? (
            <div className="py-12 text-center text-[12px] text-slate-400 flex items-center justify-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" /> Recherche…
            </div>
          ) : error ? (
            <div className="m-3 px-3 py-2 rounded-md text-[12px] bg-rose-50 text-rose-700 border border-rose-200">
              {error}
            </div>
          ) : query.trim().length < MIN_QUERY_LENGTH ? (
            <div className="py-14 text-center">
              <Search className="h-8 w-8 text-slate-300 mx-auto" />
              <p className="mt-3 text-[12.5px] text-slate-500">
                Tape au moins 2 caractères pour lancer la recherche.
              </p>
            </div>
          ) : results.length === 0 ? (
            <div className="py-14 text-center">
              <Search className="h-8 w-8 text-slate-300 mx-auto" />
              <p className="mt-3 text-[12.5px] text-slate-500">
                Aucun message ne correspond à{" "}
                <span className="font-semibold text-navy-700">
                  « {query.trim()} »
                </span>
                .
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {grouped.map((g) => (
                <section key={g.convId}>
                  <header className="flex items-center gap-2 px-3 py-1.5 text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500">
                    {g.kind === "group" && g.scope === "admin_team" ? (
                      <Shield className="h-3 w-3" />
                    ) : g.kind === "group" ? (
                      <Users className="h-3 w-3" />
                    ) : (
                      <MessageCircle className="h-3 w-3" />
                    )}
                    <span className="truncate normal-case font-semibold text-navy-700 tracking-normal text-[12px]">
                      {g.title}
                    </span>
                    <span className="ml-auto text-slate-400">
                      {g.items.length}
                    </span>
                  </header>
                  <ul className="space-y-0.5">
                    {g.items.map((m) => (
                      <li key={m.id}>
                        <ResultRow
                          result={m}
                          query={query.trim()}
                          isMine={m.sender_id === viewerId}
                          onClick={() => handlePick(m.conversation_id)}
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

// ── Row ────────────────────────────────────────────────────────

function ResultRow({
  result,
  query,
  isMine,
  onClick,
}: {
  result: MessageSearchResult;
  query: string;
  isMine: boolean;
  onClick: () => void;
}) {
  const tone = avatarTone(result.sender_id);
  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "group/result w-full text-left flex items-start gap-3 px-3 py-2.5 rounded-lg",
        "transition-colors duration-150 ease-out",
        "hover:bg-navy-50/60",
        "focus-visible:bg-navy-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-navy-300"
      )}
    >
      <span
        className={cn(
          "h-8 w-8 rounded-lg flex items-center justify-center shrink-0 font-semibold text-[11px]",
          tone
        )}
        aria-hidden
      >
        {initials(result.sender_name ?? "?")}
      </span>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 text-[11px] mb-0.5">
          <span className="font-semibold text-navy-900">
            {isMine ? "Toi" : result.sender_name ?? "Utilisateur"}
          </span>
          <span className="text-slate-400">
            · {relativeTimeFr(result.created_at)}
          </span>
        </div>
        <p className="text-[12.5px] text-navy-800 leading-relaxed line-clamp-2">
          <Highlight body={result.body} query={query} />
        </p>
      </div>
    </button>
  );
}

function Highlight({ body, query }: { body: string; query: string }) {
  if (!query) return <>{body}</>;
  const lower = body.toLowerCase();
  const q = query.toLowerCase();
  const parts: { text: string; match: boolean }[] = [];
  let i = 0;
  while (i < body.length) {
    const idx = lower.indexOf(q, i);
    if (idx === -1) {
      parts.push({ text: body.slice(i), match: false });
      break;
    }
    if (idx > i) parts.push({ text: body.slice(i, idx), match: false });
    parts.push({ text: body.slice(idx, idx + q.length), match: true });
    i = idx + q.length;
  }
  return (
    <>
      {parts.map((p, k) =>
        p.match ? (
          <mark
            key={k}
            className="bg-gold-200 text-navy-950 rounded px-0.5"
          >
            {p.text}
          </mark>
        ) : (
          <span key={k}>{p.text}</span>
        )
      )}
    </>
  );
}
