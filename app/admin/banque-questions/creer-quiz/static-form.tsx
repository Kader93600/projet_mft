"use client";
import { useEffect, useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Search,
  CheckCircle2,
  Loader2,
  ChevronDown,
  ChevronRight,
  ClipboardList,
  AlertTriangle,
} from "lucide-react";
import { FORMATIONS } from "@/lib/formations-config";
import { getQuestionFilterConfig } from "@/lib/question-filters";
import { createStaticQuiz } from "./actions";
import { stripHtml } from "@/lib/strip-html";

interface QuestionRow {
  id: string;
  type: "qcm" | "qr";
  statement: string;
  difficulty: string;
  tags: string[];
  source_ref: string | null;
}

// Labels Capa (par défaut). Pour GOTRM, la config bascule sur les
// chapitres automatiquement (Ch. 1, Ch. 2, …) via getQuestionFilterConfig.
const CAPA_MODULE_LABELS: Record<string, string> = {
  a: "A — Droit",
  b: "B — Commercial",
  c: "C — Réglementation",
  d: "D — Financier",
  e: "E — Salariés",
  f: "F — Sécurité",
};

export function StaticQuizForm({
  initialFormation,
}: {
  initialFormation?: string;
}) {
  const [formationSlug, setFormationSlug] = useState(initialFormation ?? "");
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState<string>("");
  const [moduleFilter, setModuleFilter] = useState<string>("");

  // Configuration des filtres selon la formation choisie
  const filterConfig = useMemo(
    () => getQuestionFilterConfig(formationSlug),
    [formationSlug],
  );
  const [questions, setQuestions] = useState<QuestionRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [selected, setSelected] = useState<Set<string>>(new Set());
  const [expanded, setExpanded] = useState<Set<string>>(new Set());

  // Charge les questions actives de la formation choisie
  useEffect(() => {
    if (!formationSlug) {
      setQuestions([]);
      return;
    }
    setLoading(true);
    const supabase = createClient();
    (async () => {
      const { data: f } = await supabase
        .from("formations")
        .select("id")
        .eq("slug", formationSlug)
        .single();
      if (!f) {
        setLoading(false);
        return;
      }
      const { data } = await supabase
        .from("question_bank")
        .select("id, type, statement, difficulty, tags, source_ref")
        .eq("formation_id", f.id)
        .eq("active", true)
        .order("source_ref")
        .limit(1000);
      setQuestions((data ?? []) as any);
      setLoading(false);
    })();
  }, [formationSlug]);

  // Index plain-text des énoncés (calculé 1× par changement de banque,
  // pas à chaque keystroke de recherche).
  const plainStatements = useMemo(() => {
    const m = new Map<string, string>();
    for (const q of questions) m.set(q.id, stripHtml(q.statement));
    return m;
  }, [questions]);

  // Filtres côté client (UX rapide)
  const filtered = useMemo(() => {
    const s = search.trim().toLowerCase();
    return questions.filter((q) => {
      if (typeFilter && q.type !== typeFilter) return false;
      if (moduleFilter) {
        const wantTag = `${filterConfig.tagPrefix}${moduleFilter}`;
        if (!q.tags?.includes(wantTag)) return false;
      }
      if (s) {
        const plain = plainStatements.get(q.id) ?? "";
        if (!plain.toLowerCase().includes(s)) return false;
      }
      return true;
    });
  }, [questions, search, typeFilter, moduleFilter, filterConfig, plainStatements]);

  // Sélection rapide
  function toggle(id: string) {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  function selectAllVisible() {
    setSelected((prev) => {
      const next = new Set(prev);
      filtered.forEach((q) => next.add(q.id));
      return next;
    });
  }

  function clearSelection() {
    setSelected(new Set());
  }

  function toggleExpand(id: string) {
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  const selectedList = useMemo(
    () => questions.filter((q) => selected.has(q.id)),
    [questions, selected]
  );
  const qcmCount = selectedList.filter((q) => q.type === "qcm").length;
  const qrCount = selectedList.filter((q) => q.type === "qr").length;

  return (
    <div className="space-y-6">
      {/* Sélection formation */}
      <div>
        <Label htmlFor="formation_slug_static">Formation</Label>
        <select
          id="formation_slug_static"
          value={formationSlug}
          onChange={(e) => {
            setFormationSlug(e.target.value);
            setSelected(new Set());
            // Reset le filtre de groupe : "a" Capacité ≠ "1" GOTRM, on
            // évite l'incohérence en cas de changement de formation.
            setModuleFilter("");
          }}
          className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5"
        >
          <option value="">— Choisir une formation —</option>
          {FORMATIONS.map((f) => (
            <option key={f.slug} value={f.slug}>
              {f.code}
            </option>
          ))}
        </select>
      </div>

      {!formationSlug && (
        <div className="rounded-xl border border-navy-100 bg-ivory p-6 text-sm text-slate-600 text-center">
          Choisissez d'abord une formation pour voir ses questions actives.
        </div>
      )}

      {formationSlug && (
        <>
          {/* Filtres */}
          <div className="flex gap-2 flex-wrap">
            <div className="relative flex-1 min-w-[240px]">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
              <input
                type="search"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Rechercher dans les énoncés…"
                className="w-full pl-10 pr-3 h-10 rounded-xl border border-navy-200 bg-white text-sm"
              />
            </div>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="h-10 rounded-xl border border-navy-200 bg-white px-3 text-sm"
            >
              <option value="">Tous types</option>
              <option value="qcm">QCM</option>
              <option value="qr">QR</option>
            </select>
            <select
              value={moduleFilter}
              onChange={(e) => setModuleFilter(e.target.value)}
              className="h-10 rounded-xl border border-navy-200 bg-white px-3 text-sm"
              title={`Filtrer par ${filterConfig.label.toLowerCase()}`}
            >
              <option value="">Tous {filterConfig.label.toLowerCase()}s</option>
              {filterConfig.keys.map((k) => {
                // Pour Capacité, on garde le label détaillé "A — Droit",
                // pour les autres (GOTRM…), on utilise le format long
                // de la config ("Chapitre 1").
                const label =
                  filterConfig.tagPrefix === "module-" && CAPA_MODULE_LABELS[k]
                    ? CAPA_MODULE_LABELS[k]
                    : filterConfig.formatLong
                      ? filterConfig.formatLong(k)
                      : filterConfig.formatPill(k);
                return (
                  <option key={k} value={k}>
                    {label}
                  </option>
                );
              })}
            </select>
          </div>

          {/* Compteur sélection */}
          <div className="flex items-center justify-between gap-2 rounded-xl border-2 border-signal-300 bg-signal-50 px-4 py-3">
            <div className="text-sm">
              <strong className="text-navy-900">{selected.size}</strong>{" "}
              question{selected.size > 1 ? "s" : ""} sélectionnée
              {selected.size > 1 ? "s" : ""} ·{" "}
              <span className="text-slate-600">
                {qcmCount} QCM, {qrCount} QR
              </span>
            </div>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={selectAllVisible}
                className="text-xs text-brand-700 hover:text-brand-900 font-medium"
              >
                Tout sélectionner ({filtered.length})
              </button>
              {selected.size > 0 && (
                <button
                  type="button"
                  onClick={clearSelection}
                  className="text-xs text-rose-700 hover:text-rose-900 font-medium"
                >
                  Vider
                </button>
              )}
            </div>
          </div>

          {/* Liste questions */}
          <div className="rounded-xl border border-navy-100 bg-white max-h-[500px] overflow-y-auto">
            {loading ? (
              <div className="p-10 text-center text-sm text-slate-500">
                <Loader2 className="h-5 w-5 animate-spin mx-auto" />
              </div>
            ) : filtered.length === 0 ? (
              <div className="p-10 text-center text-sm text-slate-500">
                Aucune question active pour ces filtres.
              </div>
            ) : (
              <ul className="divide-y divide-navy-50">
                {filtered.map((q) => {
                  const isSel = selected.has(q.id);
                  const isExp = expanded.has(q.id);
                  // Détecte le tag de groupe (chapitre-N ou module-X)
                  // selon la nomenclature de la formation choisie.
                  const groupTag = q.tags?.find((t) =>
                    t.startsWith(filterConfig.tagPrefix)
                  );
                  const groupKey = groupTag
                    ? groupTag.slice(filterConfig.tagPrefix.length)
                    : null;
                  const groupLabel = groupKey
                    ? filterConfig.formatPill(groupKey)
                    : "?";
                  return (
                    <li
                      key={q.id}
                      className={
                        "px-4 py-3 transition " +
                        (isSel ? "bg-signal-50" : "hover:bg-navy-50/50")
                      }
                    >
                      <div className="flex items-start gap-3">
                        <input
                          type="checkbox"
                          checked={isSel}
                          onChange={() => toggle(q.id)}
                          className="mt-1 h-4 w-4 rounded border-navy-300"
                        />
                        <button
                          type="button"
                          onClick={() => toggleExpand(q.id)}
                          className="text-slate-400 hover:text-slate-700 mt-0.5"
                          aria-label={isExp ? "Réduire" : "Détailler"}
                        >
                          {isExp ? (
                            <ChevronDown className="h-4 w-4" />
                          ) : (
                            <ChevronRight className="h-4 w-4" />
                          )}
                        </button>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1 text-[10px]">
                            <Badge
                              tone={q.type === "qr" ? "gold" : "navy"}
                              size="sm"
                            >
                              {q.type.toUpperCase()}
                            </Badge>
                            <span className="text-slate-500 font-semibold">
                              {groupLabel}
                            </span>
                            <span className="text-slate-500">
                              · {q.difficulty}
                            </span>
                            {q.source_ref && (
                              <code className="font-mono text-[10px] text-slate-400">
                                {q.source_ref}
                              </code>
                            )}
                          </div>
                          <p
                            className={
                              "text-sm text-navy-900 leading-relaxed " +
                              (isExp ? "" : "line-clamp-2")
                            }
                          >
                            {plainStatements.get(q.id) ?? stripHtml(q.statement)}
                          </p>
                        </div>
                      </div>
                    </li>
                  );
                })}
              </ul>
            )}
          </div>

          {/* Formulaire de création */}
          <form action={createStaticQuiz} className="space-y-5 pt-4 border-t border-navy-100">
            <h3 className="font-display text-lg font-semibold text-navy-900">
              Paramètres du quiz
            </h3>
            <input type="hidden" name="formation_slug" value={formationSlug} />
            {Array.from(selected).map((id) => (
              <input
                key={id}
                type="hidden"
                name="question_ids[]"
                value={id}
              />
            ))}

            <div>
              <Label htmlFor="title_static">Titre du quiz</Label>
              <Input
                id="title_static"
                name="title"
                required
                placeholder="Ex. Examen blanc capacité -3,5T n°1"
              />
            </div>
            <div>
              <Label htmlFor="description_static">
                Description (optionnel)
              </Label>
              <Textarea id="description_static" name="description" rows={2} />
            </div>
            <div className="grid sm:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="time_limit_min_static">
                  Durée (min, 0 = illimité)
                </Label>
                <Input
                  id="time_limit_min_static"
                  name="time_limit_min"
                  type="number"
                  min={0}
                  defaultValue={60}
                />
              </div>
              <div>
                <Label htmlFor="pass_threshold_static">
                  Seuil de réussite (%)
                </Label>
                <Input
                  id="pass_threshold_static"
                  name="pass_threshold"
                  type="number"
                  min={0}
                  max={100}
                  defaultValue={70}
                />
              </div>
            </div>

            <label className="flex items-center gap-2 px-3 py-2 rounded-xl border border-gold-200 bg-gold-50 cursor-pointer">
              <input
                type="checkbox"
                name="is_mock_exam"
                className="h-4 w-4 rounded border-navy-300"
              />
              <span className="text-sm text-navy-900">
                <strong>Examen blanc officiel</strong> (chrono visible,
                anti-copie, détection sortie d'onglet)
              </span>
            </label>

            {selected.size === 0 && (
              <div className="flex items-start gap-2 rounded-xl bg-amber-50 border border-amber-200 p-3 text-sm text-amber-900">
                <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
                Sélectionnez au moins 1 question dans la liste ci-dessus pour
                pouvoir créer le quiz.
              </div>
            )}

            <div className="flex justify-end pt-2">
              <Button
                type="submit"
                variant="gold"
                disabled={selected.size === 0}
              >
                <ClipboardList className="h-4 w-4" />
                Créer le quiz ({selected.size} question
                {selected.size > 1 ? "s" : ""})
              </Button>
            </div>
          </form>
        </>
      )}
    </div>
  );
}
