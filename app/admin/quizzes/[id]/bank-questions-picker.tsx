"use client";

import { useMemo, useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import {
  Filter,
  CheckSquare,
  Square,
  Search,
  Loader2,
  Trash2,
  AlertCircle,
  ListChecks,
} from "lucide-react";
import {
  attachBankQuestion,
  detachBankQuestion,
  setBankQuestionsForQuiz,
} from "../actions";
import { useToast } from "@/components/ui/toast";

interface BankQuestion {
  id: string;
  type: "qcm" | "qr";
  statement: string;
  choices: any[] | null;
  difficulty: string;
  tags: string[];
  max_score: number;
  active: boolean;
}

/**
 * Version sérialisable de QuestionFilterConfig — passée du server au
 * client. On ne peut PAS transmettre les fonctions formatPill/formatLong
 * à travers la boundary RSC, donc on les pré-calcule côté serveur
 * (entry = label affiché).
 */
export interface SerializableFilterConfig {
  tagPrefix: string;
  label: string;
  /** [{ key, pill, long }] précalculé côté server */
  entries: Array<{ key: string; pill: string; long: string }>;
}

/**
 * Permet de piocher des questions de la banque (table question_bank)
 * pour les attacher au quiz courant (via quiz_question_bank).
 *
 * - Une checkbox par question, action immédiate (single-attach/detach)
 * - Filtre par chapitre/module, type, statut actif
 * - Recherche textuelle
 * - Bouton "Tout cocher (filtré)" / "Tout décocher" en bulk
 */
export function BankQuestionsPicker({
  quizId,
  questions,
  initialLinkedIds,
  filterConfig,
  hasFormation,
  hasModule,
}: {
  quizId: string;
  questions: BankQuestion[];
  initialLinkedIds: string[];
  filterConfig: SerializableFilterConfig;
  hasFormation: boolean;
  hasModule: boolean;
}) {
  // Lookups O(1) pour formater une clé en pill ou label long
  const pillByKey = useMemo(() => {
    const m = new Map<string, string>();
    for (const e of filterConfig.entries) m.set(e.key, e.pill);
    return m;
  }, [filterConfig.entries]);
  const longByKey = useMemo(() => {
    const m = new Map<string, string>();
    for (const e of filterConfig.entries) m.set(e.key, e.long);
    return m;
  }, [filterConfig.entries]);
  const formatPill = (k: string) => pillByKey.get(k) ?? k;
  const formatLong = (k: string) => longByKey.get(k) ?? k;
  const router = useRouter();
  const { toast } = useToast();
  const [pending, startTransition] = useTransition();
  const [linkedIds, setLinkedIds] = useState<Set<string>>(
    () => new Set(initialLinkedIds),
  );
  const [groupFilter, setGroupFilter] = useState<string>("");
  const [typeFilter, setTypeFilter] = useState<string>("");
  const [statusFilter, setStatusFilter] = useState<"all" | "active" | "inactive">(
    "active",
  );
  const [search, setSearch] = useState("");

  // Compte par groupe (chapitre/module)
  const groupCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    for (const e of filterConfig.entries) counts[e.key] = 0;
    for (const q of questions) {
      for (const t of q.tags ?? []) {
        if (!t.startsWith(filterConfig.tagPrefix)) continue;
        const k = t.slice(filterConfig.tagPrefix.length);
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    return counts;
  }, [questions, filterConfig]);

  // Questions filtrées (recherche + type + groupe + statut)
  const filtered = useMemo(() => {
    const s = search.trim().toLowerCase();
    return questions.filter((q) => {
      if (typeFilter && q.type !== typeFilter) return false;
      if (statusFilter === "active" && !q.active) return false;
      if (statusFilter === "inactive" && q.active) return false;
      if (groupFilter) {
        const wantTag = `${filterConfig.tagPrefix}${groupFilter}`;
        if (!q.tags?.includes(wantTag)) return false;
      }
      if (s && !q.statement.toLowerCase().includes(s)) return false;
      return true;
    });
  }, [questions, search, typeFilter, groupFilter, statusFilter, filterConfig]);

  function toggle(q: BankQuestion) {
    const wasLinked = linkedIds.has(q.id);
    // Optimistic update
    const next = new Set(linkedIds);
    if (wasLinked) next.delete(q.id);
    else next.add(q.id);
    setLinkedIds(next);

    startTransition(async () => {
      try {
        if (wasLinked) {
          await detachBankQuestion(quizId, q.id);
        } else {
          await attachBankQuestion(quizId, q.id);
        }
        router.refresh();
      } catch (e: any) {
        // Rollback en cas d'erreur
        setLinkedIds(linkedIds);
        toast(e.message ?? "Erreur", "error");
      }
    });
  }

  function selectAllFiltered() {
    const allIds = [...linkedIds];
    for (const q of filtered) {
      if (!linkedIds.has(q.id)) allIds.push(q.id);
    }
    bulkSet(allIds, `${allIds.length - linkedIds.size} question(s) ajoutée(s)`);
  }

  function clearFilteredFromSelection() {
    const filteredIds = new Set(filtered.map((q) => q.id));
    const next = [...linkedIds].filter((id) => !filteredIds.has(id));
    bulkSet(next, `${linkedIds.size - next.length} question(s) retirée(s)`);
  }

  function clearAll() {
    if (
      !confirm(
        `Retirer toutes les ${linkedIds.size} question(s) de ce quiz ?`,
      )
    )
      return;
    bulkSet([], "Toutes les questions retirées");
  }

  function bulkSet(ids: string[], successMsg: string) {
    const prev = new Set(linkedIds);
    setLinkedIds(new Set(ids));
    startTransition(async () => {
      try {
        await setBankQuestionsForQuiz(quizId, ids);
        toast(successMsg, "success");
        router.refresh();
      } catch (e: any) {
        setLinkedIds(prev);
        toast(e.message ?? "Erreur", "error");
      }
    });
  }

  // Pas de formation rattachée au quiz → pas de banque utilisable
  if (!hasFormation) {
    return (
      <div className="rounded-xl border border-amber-200 bg-amber-50/60 px-4 py-3 text-sm text-amber-900 flex items-start gap-2">
        <AlertCircle className="h-4 w-4 mt-0.5 shrink-0" />
        <div>
          <strong>Aucune formation associée à ce quiz.</strong> Sélectionnez
          une formation dans le panneau "Paramètres" pour activer la banque
          de questions.
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* En-tête avec compteurs + bulk */}
      <div className="flex items-center justify-between flex-wrap gap-2">
        <div className="text-[12.5px] text-slate-700">
          <strong className="text-navy-900">{linkedIds.size}</strong>{" "}
          sélectionnée(s) sur{" "}
          <strong className="text-navy-900">{questions.length}</strong>{" "}
          disponible(s)
          {hasModule && (
            <span className="text-slate-500">
              {" "}
              · scope module rattaché
            </span>
          )}
        </div>
        <div className="flex items-center gap-1.5">
          <button
            type="button"
            onClick={selectAllFiltered}
            disabled={pending || filtered.every((q) => linkedIds.has(q.id))}
            className="inline-flex items-center gap-1 px-2.5 py-1 rounded-md text-[11.5px] font-semibold border border-signal-300 bg-signal-50 text-signal-800 hover:bg-signal-100 disabled:opacity-50"
            title="Ajouter toutes les questions filtrées au quiz"
          >
            <CheckSquare className="h-3 w-3" />
            Tout cocher ({filtered.length})
          </button>
          {linkedIds.size > 0 && (
            <button
              type="button"
              onClick={clearAll}
              disabled={pending}
              className="inline-flex items-center gap-1 px-2.5 py-1 rounded-md text-[11.5px] font-semibold border border-rose-200 bg-rose-50 text-rose-800 hover:bg-rose-100 disabled:opacity-50"
            >
              <Trash2 className="h-3 w-3" />
              Vider
            </button>
          )}
        </div>
      </div>

      {/* Filtres */}
      <div className="rounded-xl border border-navy-100 bg-ivory p-3 space-y-2">
        {/* Recherche */}
        <div className="relative">
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Rechercher dans les énoncés…"
            className="w-full pl-8 pr-2.5 h-8 rounded-lg border border-navy-200 bg-white text-[12.5px]"
          />
        </div>

        {/* Filtres par groupe */}
        <div className="flex flex-wrap items-center gap-1.5">
          <span className="inline-flex items-center gap-1 text-[10px] font-bold uppercase tracking-[0.14em] text-slate-500">
            <Filter className="h-3 w-3" />
            {filterConfig.label}
          </span>
          <FilterPill
            label={`Tous (${questions.length})`}
            active={!groupFilter}
            onClick={() => setGroupFilter("")}
          />
          {filterConfig.entries.map((e) => (
            <FilterPill
              key={e.key}
              label={`${e.pill} (${groupCounts[e.key] ?? 0})`}
              active={groupFilter === e.key}
              dim={(groupCounts[e.key] ?? 0) === 0}
              onClick={() => setGroupFilter(e.key)}
            />
          ))}
        </div>

        {/* Filtres type + statut */}
        <div className="flex items-center gap-3 flex-wrap">
          <div className="flex items-center gap-1">
            <span className="text-[10px] uppercase tracking-wider text-slate-500">
              Type
            </span>
            {[
              { v: "", l: "Tous" },
              { v: "qcm", l: "QCM" },
              { v: "qr", l: "QR" },
            ].map((opt) => (
              <FilterPill
                key={opt.v}
                label={opt.l}
                active={typeFilter === opt.v}
                onClick={() => setTypeFilter(opt.v)}
                size="sm"
              />
            ))}
          </div>
          <div className="flex items-center gap-1">
            <span className="text-[10px] uppercase tracking-wider text-slate-500">
              Statut
            </span>
            {[
              { v: "active", l: "Actives" },
              { v: "inactive", l: "Brouillon" },
              { v: "all", l: "Toutes" },
            ].map((opt) => (
              <FilterPill
                key={opt.v}
                label={opt.l}
                active={statusFilter === opt.v}
                onClick={() => setStatusFilter(opt.v as any)}
                size="sm"
              />
            ))}
          </div>
        </div>
      </div>

      {/* Liste */}
      {filtered.length === 0 ? (
        <div className="rounded-xl border border-dashed border-navy-200 bg-white p-6 text-center text-sm text-slate-500">
          {questions.length === 0
            ? "Aucune question dans la banque pour cette formation. Importez un PDF ou créez-les manuellement."
            : "Aucune question ne correspond aux filtres actuels."}
        </div>
      ) : (
        <ul className="space-y-1.5 max-h-[600px] overflow-y-auto pr-1">
          {filtered.map((q) => {
            const isLinked = linkedIds.has(q.id);
            const groupTag = q.tags?.find((t) =>
              t.startsWith(filterConfig.tagPrefix),
            );
            const groupKey = groupTag
              ? groupTag.slice(filterConfig.tagPrefix.length)
              : null;
            return (
              <li
                key={q.id}
                className={
                  "rounded-lg border px-3 py-2 transition cursor-pointer flex items-start gap-2.5 " +
                  (isLinked
                    ? "bg-signal-50/60 border-signal-300"
                    : "bg-white border-navy-100 hover:border-navy-200 hover:bg-ivory")
                }
                onClick={() => toggle(q)}
              >
                <button
                  type="button"
                  className={
                    "shrink-0 mt-0.5 h-4 w-4 rounded inline-flex items-center justify-center transition " +
                    (isLinked
                      ? "bg-signal-500 text-night-900"
                      : "bg-white border-2 border-navy-200")
                  }
                  aria-checked={isLinked}
                  role="checkbox"
                  tabIndex={-1}
                >
                  {isLinked && <CheckSquare className="h-3 w-3" />}
                </button>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-1.5 flex-wrap mb-0.5">
                    <span
                      className={
                        "px-1.5 py-0.5 rounded text-[9px] font-bold uppercase tracking-[0.1em] " +
                        (q.type === "qcm"
                          ? "bg-navy-900 text-white"
                          : "bg-amber-100 text-amber-800 border border-amber-200")
                      }
                    >
                      {q.type}
                    </span>
                    {groupKey && (
                      <span className="text-[9px] font-semibold text-slate-500 uppercase tracking-wider">
                        {formatPill(groupKey)}
                      </span>
                    )}
                    <span className="text-[9px] text-slate-400">
                      {q.difficulty} · {q.max_score} pt
                      {q.max_score > 1 ? "s" : ""}
                    </span>
                    {!q.active && (
                      <span className="text-[9px] font-semibold text-amber-700 bg-amber-50 border border-amber-200 px-1 py-0.5 rounded">
                        BROUILLON
                      </span>
                    )}
                  </div>
                  <p className="text-[12.5px] text-navy-900 leading-snug line-clamp-2">
                    {q.statement}
                  </p>
                </div>
              </li>
            );
          })}
        </ul>
      )}

      {pending && (
        <div className="flex items-center gap-2 text-[12px] text-slate-600">
          <Loader2 className="h-3 w-3 animate-spin" />
          Enregistrement…
        </div>
      )}
    </div>
  );
}

function FilterPill({
  label,
  active,
  dim,
  onClick,
  size = "md",
}: {
  label: string;
  active: boolean;
  dim?: boolean;
  onClick: () => void;
  size?: "sm" | "md";
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={
        "rounded-full border font-medium transition " +
        (size === "sm" ? "px-2 py-0.5 text-[10px]" : "px-2.5 py-1 text-[11px]") +
        " " +
        (active
          ? "bg-navy-900 text-white border-navy-900"
          : dim
            ? "bg-white text-slate-400 border-navy-100"
            : "bg-white text-slate-700 border-navy-100 hover:border-navy-300")
      }
    >
      {label}
    </button>
  );
}
