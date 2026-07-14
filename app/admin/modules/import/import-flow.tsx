"use client";

import Link from "next/link";
import { useMemo, useRef, useState } from "react";
import {
  UploadCloud,
  ClipboardPaste,
  Loader2,
  AlertTriangle,
  CheckCircle2,
  ArrowRight,
  ArrowLeft,
  Trash2,
  Plus,
  RotateCcw,
  BookOpen,
  Pencil,
  Eye,
  ChevronRight,
  ChevronDown,
} from "lucide-react";
import { RichTextEditor } from "@/components/rich-text/rich-text-editor";
import { RichTextDisplay } from "@/components/rich-text/rich-text-display";

interface FormationOpt {
  slug: string;
  code: string;
  title: string;
}
interface BlocOpt {
  code: string;
  title: string;
}

interface DraftLesson {
  ref: string;
  title: string;
  contentHtml: string;
  sourcePage?: number | null;
  warnings?: string[];
  _drop?: boolean;
}

interface DraftChapter {
  number: number;
  title: string;
  slug: string;
  lessons: DraftLesson[];
  sourcePage?: number | null;
  _drop?: boolean;
  _summary?: string;
  _duration?: number;
}

type Step = "upload" | "review" | "saving" | "done";

export function CourseImportFlow({
  formations,
  blocs,
}: {
  formations: FormationOpt[];
  blocs: BlocOpt[];
}) {
  const [step, setStep] = useState<Step>("upload");

  // Étape 1 — upload
  const [file, setFile] = useState<File | null>(null);
  const [pastedText, setPastedText] = useState("");
  const [formationSlug, setFormationSlug] = useState(
    formations.find((f) => f.slug === "gotrm")?.slug ?? formations[0]?.slug ?? "",
  );
  const [blocCode, setBlocCode] = useState(
    blocs.find((b) => b.code === "BC2")?.code ?? blocs[0]?.code ?? "",
  );
  const [inputMode, setInputMode] = useState<"file" | "paste">("file");

  // Étape 2 — review
  const [chapters, setChapters] = useState<DraftChapter[]>([]);
  const [expanded, setExpanded] = useState<Set<number>>(new Set());

  // Étape 3 — result
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [insertedCount, setInsertedCount] = useState({
    chapters: 0,
    lessons: 0,
  });
  const [isExtracting, setIsExtracting] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const visibleChapters = useMemo(
    () => chapters.filter((c) => !c._drop),
    [chapters],
  );
  const visibleLessonsCount = visibleChapters.reduce(
    (s, c) => s + c.lessons.filter((l) => !l._drop).length,
    0,
  );

  const onExtract = async () => {
    setErrorMsg(null);
    if (!formationSlug || !blocCode) {
      setErrorMsg("Sélectionnez une formation et un bloc.");
      return;
    }
    if (inputMode === "file" && !file) {
      setErrorMsg("Sélectionnez un fichier PDF.");
      return;
    }
    if (inputMode === "paste" && pastedText.trim().length < 60) {
      setErrorMsg("Texte trop court (minimum 60 caractères).");
      return;
    }
    setIsExtracting(true);
    try {
      const fd = new FormData();
      fd.append("formation_slug", formationSlug);
      fd.append("bloc_code", blocCode);
      if (file && inputMode === "file") fd.append("file", file);
      if (inputMode === "paste") fd.append("pasted_text", pastedText);

      const res = await fetch("/api/admin/modules/import/extract", {
        method: "POST",
        body: fd,
      });
      const json = await res.json();
      if (!res.ok) {
        setErrorMsg(json.message ?? json.error ?? "Échec de l'extraction.");
        return;
      }
      setChapters(
        (json.chapters ?? []).map((c: any) => ({
          ...c,
          _duration: 60,
          _summary: "",
        })),
      );
      // Ouvre le premier chapitre par défaut
      setExpanded(new Set([json.chapters?.[0]?.number]));
      setStep("review");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Erreur réseau");
    } finally {
      setIsExtracting(false);
    }
  };

  const onSave = async () => {
    setErrorMsg(null);
    if (visibleChapters.length === 0) {
      setErrorMsg("Aucun chapitre à insérer.");
      return;
    }
    setIsSaving(true);
    setStep("saving");
    try {
      const payload = {
        formation_slug: formationSlug,
        bloc_code: blocCode,
        chapters: visibleChapters.map((c) => ({
          number: c.number,
          title: c.title,
          slug: c.slug,
          summary: c._summary || null,
          duration_min: c._duration ?? 60,
          lessons: c.lessons
            .filter((l) => !l._drop)
            .map((l) => ({
              ref: l.ref,
              title: l.title,
              content_html: l.contentHtml,
            })),
        })),
      };
      const res = await fetch("/api/admin/modules/import/save", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(payload),
      });
      const json = await res.json();
      if (!res.ok) {
        setErrorMsg(json.error ?? "Erreur d'enregistrement");
        setStep("review");
        return;
      }
      setInsertedCount({
        chapters: json.chapters?.length ?? 0,
        lessons: json.total_lessons ?? 0,
      });
      setStep("done");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Erreur réseau");
      setStep("review");
    } finally {
      setIsSaving(false);
    }
  };

  const toggleExpanded = (n: number) => {
    const next = new Set(expanded);
    if (next.has(n)) next.delete(n);
    else next.add(n);
    setExpanded(next);
  };

  const reset = () => {
    setStep("upload");
    setFile(null);
    setPastedText("");
    setChapters([]);
    setExpanded(new Set());
    setErrorMsg(null);
    setInsertedCount({ chapters: 0, lessons: 0 });
  };

  return (
    <div className="space-y-6">
      <Stepper step={step} />

      {errorMsg && (
        <div className="rounded-xl border border-rose-200 bg-rose-50/60 px-4 py-3 text-sm text-rose-800 flex items-start gap-2">
          <AlertTriangle className="h-4 w-4 mt-0.5 shrink-0" />
          <span>{errorMsg}</span>
        </div>
      )}

      {step === "upload" && (
        <UploadStep
          formations={formations}
          blocs={blocs}
          formationSlug={formationSlug}
          setFormationSlug={setFormationSlug}
          blocCode={blocCode}
          setBlocCode={setBlocCode}
          inputMode={inputMode}
          setInputMode={setInputMode}
          file={file}
          setFile={setFile}
          pastedText={pastedText}
          setPastedText={setPastedText}
          isExtracting={isExtracting}
          onExtract={onExtract}
        />
      )}

      {step === "review" && (
        <ReviewStep
          chapters={chapters}
          setChapters={setChapters}
          expanded={expanded}
          toggleExpanded={toggleExpanded}
          visibleChaptersCount={visibleChapters.length}
          visibleLessonsCount={visibleLessonsCount}
          onBack={() => setStep("upload")}
          onSave={onSave}
        />
      )}

      {step === "saving" && (
        <div className="rounded-2xl border border-navy-100 bg-ivory p-8 text-center">
          <Loader2 className="h-6 w-6 mx-auto animate-spin text-signal-600" />
          <p className="mt-3 text-sm text-slate-600">
            Insertion de {visibleChapters.length} chapitre(s) et{" "}
            {visibleLessonsCount} leçon(s) en cours…
          </p>
        </div>
      )}

      {step === "done" && (
        <div className="rounded-2xl border border-emerald-200 bg-emerald-50/70 p-6">
          <div className="flex items-start gap-3">
            <CheckCircle2 className="h-5 w-5 text-emerald-700 mt-0.5" />
            <div className="flex-1">
              <div className="font-display text-base font-semibold text-emerald-900">
                {insertedCount.chapters} chapitre(s) et{" "}
                {insertedCount.lessons} leçon(s) créé(s)
              </div>
              <p className="mt-1 text-[13px] text-emerald-800 leading-relaxed">
                Le contenu est désormais accessible côté stagiaire dans la
                section Cours de la formation{" "}
                <strong>{formationSlug.toUpperCase()}</strong>.
              </p>
              <div className="mt-4 flex gap-2 flex-wrap">
                <button
                  onClick={reset}
                  className="inline-flex items-center gap-1.5 text-sm font-semibold px-3.5 py-2 rounded-lg bg-navy-900 text-white hover:bg-navy-800 transition"
                >
                  <RotateCcw className="h-3.5 w-3.5" />
                  Nouvel import
                </button>
                <Link
                  href="/admin/modules"
                  className="inline-flex items-center gap-1.5 text-sm font-semibold px-3.5 py-2 rounded-lg border border-emerald-300 bg-white text-emerald-900 hover:bg-emerald-50 transition"
                >
                  Voir les modules
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// =====================================================================
// Stepper
// =====================================================================
function Stepper({ step }: { step: Step }) {
  const steps = [
    { key: "upload", label: "1. Source" },
    { key: "review", label: "2. Relecture" },
    { key: "done", label: "3. Inséré" },
  ];
  const current = step === "saving" ? "review" : step;
  return (
    <div className="flex items-center gap-1.5">
      {steps.map((s) => {
        const isActive = s.key === current;
        const isPast =
          (current === "review" && s.key === "upload") ||
          (current === "done" && s.key !== "done");
        return (
          <div
            key={s.key}
            className={
              "flex-1 text-[11px] font-bold uppercase tracking-[0.14em] py-1.5 text-center rounded-md " +
              (isActive
                ? "bg-navy-900 text-white"
                : isPast
                  ? "bg-signal-100 text-signal-800"
                  : "bg-navy-50 text-slate-400")
            }
          >
            {s.label}
          </div>
        );
      })}
    </div>
  );
}

// =====================================================================
// Étape 1 — Source
// =====================================================================
function UploadStep(props: {
  formations: FormationOpt[];
  blocs: BlocOpt[];
  formationSlug: string;
  setFormationSlug: (s: string) => void;
  blocCode: string;
  setBlocCode: (s: string) => void;
  inputMode: "file" | "paste";
  setInputMode: (m: "file" | "paste") => void;
  file: File | null;
  setFile: (f: File | null) => void;
  pastedText: string;
  setPastedText: (s: string) => void;
  isExtracting: boolean;
  onExtract: () => void;
}) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  return (
    <div className="space-y-5">
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block">
            Formation
          </label>
          <select
            value={props.formationSlug}
            onChange={(e) => props.setFormationSlug(e.target.value)}
            className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
          >
            <option value="">— Sélectionner —</option>
            {props.formations.map((f) => (
              <option key={f.slug} value={f.slug}>
                {f.code} — {f.title}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block">
            Bloc de rattachement
          </label>
          <select
            value={props.blocCode}
            onChange={(e) => props.setBlocCode(e.target.value)}
            className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
          >
            <option value="">— Sélectionner —</option>
            {props.blocs.map((b) => (
              <option key={b.code} value={b.code}>
                {b.code} — {b.title}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="border-t border-navy-100 pt-5">
        <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-2">
          Source du contenu
        </div>
        <div className="inline-flex rounded-lg border border-navy-200 p-0.5 bg-white">
          <button
            type="button"
            onClick={() => props.setInputMode("file")}
            className={
              "px-3.5 py-1.5 text-[13px] font-semibold rounded-md transition " +
              (props.inputMode === "file"
                ? "bg-navy-900 text-white"
                : "text-slate-600 hover:text-navy-900")
            }
          >
            <UploadCloud className="h-3.5 w-3.5 inline mr-1.5" />
            Fichier PDF
          </button>
          <button
            type="button"
            onClick={() => props.setInputMode("paste")}
            className={
              "px-3.5 py-1.5 text-[13px] font-semibold rounded-md transition " +
              (props.inputMode === "paste"
                ? "bg-navy-900 text-white"
                : "text-slate-600 hover:text-navy-900")
            }
          >
            <ClipboardPaste className="h-3.5 w-3.5 inline mr-1.5" />
            Coller du texte
          </button>
        </div>

        {props.inputMode === "file" ? (
          <div
            onClick={() => fileInputRef.current?.click()}
            className="mt-3 rounded-2xl border-2 border-dashed border-navy-200 bg-ivory hover:border-signal-500 transition p-6 text-center cursor-pointer"
          >
            <input
              ref={fileInputRef}
              type="file"
              accept="application/pdf,.pdf,.txt"
              onChange={(e) => props.setFile(e.target.files?.[0] ?? null)}
              className="hidden"
            />
            <UploadCloud className="h-6 w-6 text-signal-700 mx-auto" />
            <div className="mt-2 text-sm font-semibold text-navy-900">
              {props.file ? props.file.name : "Cliquer pour choisir un PDF"}
            </div>
            {props.file && (
              <div className="text-xs text-slate-500 mt-0.5">
                {(props.file.size / 1024).toFixed(0)} Ko
              </div>
            )}
            <div className="text-xs text-slate-500 mt-1">
              PDF de livret de cours · 15 Mo max
            </div>
          </div>
        ) : (
          <textarea
            value={props.pastedText}
            onChange={(e) => props.setPastedText(e.target.value)}
            placeholder="Coller ici le texte d'un livret de cours. Le parser détectera CHAPITRE N — Titre et les sous-sections N.M — …"
            className="mt-3 w-full min-h-[280px] rounded-xl border border-navy-200 bg-white px-3.5 py-2.5 text-[13.5px] font-mono leading-relaxed text-navy-900"
          />
        )}
      </div>

      <div className="flex justify-end pt-2 border-t border-navy-50">
        <button
          type="button"
          onClick={props.onExtract}
          disabled={props.isExtracting}
          className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-gold-500 text-night-900 font-semibold text-sm hover:bg-gold-400 transition disabled:opacity-50"
        >
          {props.isExtracting ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Extraction…
            </>
          ) : (
            <>
              Extraire et parser
              <ArrowRight className="h-4 w-4" />
            </>
          )}
        </button>
      </div>
    </div>
  );
}

// =====================================================================
// Étape 2 — Relecture
// =====================================================================
function ReviewStep(props: {
  chapters: DraftChapter[];
  setChapters: (c: DraftChapter[]) => void;
  expanded: Set<number>;
  toggleExpanded: (n: number) => void;
  visibleChaptersCount: number;
  visibleLessonsCount: number;
  onBack: () => void;
  onSave: () => void;
}) {
  const updateChapter = (n: number, patch: Partial<DraftChapter>) => {
    props.setChapters(
      props.chapters.map((c) =>
        c.number === n ? { ...c, ...patch } : c,
      ),
    );
  };

  const updateLesson = (
    chapterNum: number,
    lessonIdx: number,
    patch: Partial<DraftLesson>,
  ) => {
    props.setChapters(
      props.chapters.map((c) => {
        if (c.number !== chapterNum) return c;
        return {
          ...c,
          lessons: c.lessons.map((l, i) =>
            i === lessonIdx ? { ...l, ...patch } : l,
          ),
        };
      }),
    );
  };

  const visibleChapters = props.chapters.filter((c) => !c._drop);

  return (
    <div className="space-y-4">
      <div className="rounded-2xl bg-ivory border border-navy-100 px-4 py-3 flex items-center gap-4 flex-wrap">
        <SummaryChip label="Chapitres" value={props.visibleChaptersCount} tone="navy" />
        <SummaryChip label="Leçons" value={props.visibleLessonsCount} tone="signal" />
        <div className="ml-auto text-[12px] text-slate-500">
          Les chapitres deviendront des modules. Chaque leçon utilise le HTML
          de l'éditeur riche.
        </div>
      </div>

      {visibleChapters.length === 0 && (
        <div className="rounded-xl border border-dashed border-navy-200 bg-ivory px-4 py-8 text-center text-sm text-slate-500">
          Aucun chapitre. Retour à l'étape Source.
        </div>
      )}

      <div className="space-y-3">
        {props.chapters.map((c) => {
          if (c._drop) return null;
          const isOpen = props.expanded.has(c.number);
          const lessonCount = c.lessons.filter((l) => !l._drop).length;
          return (
            <div
              key={c.number}
              className="rounded-2xl border border-navy-100 bg-white overflow-hidden"
            >
              {/* Header chapitre */}
              <div className="flex items-center gap-3 px-4 py-3 bg-ivory border-b border-navy-100">
                <button
                  type="button"
                  onClick={() => props.toggleExpanded(c.number)}
                  className="h-7 w-7 inline-flex items-center justify-center rounded-md border border-navy-100 hover:bg-navy-50"
                  aria-label={isOpen ? "Réduire" : "Développer"}
                >
                  {isOpen ? (
                    <ChevronDown className="h-3.5 w-3.5" />
                  ) : (
                    <ChevronRight className="h-3.5 w-3.5" />
                  )}
                </button>
                <div className="font-mono text-[11px] font-bold text-slate-500 w-12 shrink-0">
                  CH. {c.number}
                </div>
                <input
                  type="text"
                  value={c.title}
                  onChange={(e) =>
                    updateChapter(c.number, { title: e.target.value })
                  }
                  className="flex-1 bg-white border border-navy-100 rounded-md px-2 py-1 text-[14px] font-semibold text-navy-900"
                  placeholder="Titre du chapitre"
                />
                <span className="text-[11px] text-slate-500 font-semibold">
                  {lessonCount} leçon{lessonCount > 1 ? "s" : ""}
                </span>
                <button
                  type="button"
                  onClick={() => updateChapter(c.number, { _drop: true })}
                  className="text-rose-700 hover:text-rose-900 inline-flex items-center gap-1 text-[11.5px] font-semibold"
                  title="Retirer ce chapitre de l'import"
                >
                  <Trash2 className="h-3 w-3" />
                  Retirer
                </button>
              </div>

              {/* Body */}
              {isOpen && (
                <div className="p-4 space-y-3">
                  {/* Méta chapitre */}
                  <div className="grid md:grid-cols-[1fr_140px] gap-2">
                    <div>
                      <label className="text-[10.5px] font-bold uppercase tracking-wider text-slate-500 mb-1 block">
                        Résumé court (optionnel)
                      </label>
                      <input
                        type="text"
                        value={c._summary ?? ""}
                        onChange={(e) =>
                          updateChapter(c.number, { _summary: e.target.value })
                        }
                        placeholder="Une phrase d'introduction visible dans la liste des modules"
                        className="w-full h-9 rounded-lg border border-navy-100 bg-white px-3 text-[13px] text-navy-900"
                      />
                    </div>
                    <div>
                      <label className="text-[10.5px] font-bold uppercase tracking-wider text-slate-500 mb-1 block">
                        Durée (min)
                      </label>
                      <input
                        type="number"
                        min="5"
                        max="600"
                        value={c._duration ?? 60}
                        onChange={(e) =>
                          updateChapter(c.number, {
                            _duration:
                              parseInt(e.target.value, 10) || 60,
                          })
                        }
                        className="w-full h-9 rounded-lg border border-navy-100 bg-white px-3 text-[13px] text-navy-900 tabular-nums"
                      />
                    </div>
                  </div>

                  {/* Leçons */}
                  <div className="space-y-2.5">
                    {c.lessons.map((l, i) => {
                      if (l._drop) return null;
                      return (
                        <LessonCard
                          key={i}
                          lesson={l}
                          onUpdate={(patch) =>
                            updateLesson(c.number, i, patch)
                          }
                          onDrop={() =>
                            updateLesson(c.number, i, { _drop: true })
                          }
                        />
                      );
                    })}
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>

      <div className="flex items-center justify-between border-t border-navy-50 pt-4">
        <button
          type="button"
          onClick={props.onBack}
          className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" />
          Retour
        </button>
        <button
          type="button"
          onClick={props.onSave}
          disabled={props.visibleChaptersCount === 0}
          className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-gold-500 text-night-900 font-semibold text-sm hover:bg-gold-400 transition disabled:opacity-50"
        >
          Insérer {props.visibleChaptersCount} chapitre(s) ·{" "}
          {props.visibleLessonsCount} leçon(s)
          <ArrowRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}

// =====================================================================
// LessonCard — édition d'une leçon avec toggle Aperçu/Édition
// =====================================================================
function LessonCard({
  lesson,
  onUpdate,
  onDrop,
}: {
  lesson: DraftLesson;
  onUpdate: (patch: Partial<DraftLesson>) => void;
  onDrop: () => void;
}) {
  const [editing, setEditing] = useState(false);
  return (
    <div className="rounded-xl border border-navy-100 bg-white p-3">
      <div className="flex items-center gap-2 flex-wrap mb-2">
        <span className="font-mono text-[10px] font-bold text-slate-400 tabular-nums">
          {lesson.ref}
        </span>
        <input
          type="text"
          value={lesson.title}
          onChange={(e) => onUpdate({ title: e.target.value })}
          className="flex-1 bg-white border border-navy-100 rounded-md px-2 py-1 text-[13.5px] font-semibold text-navy-900"
          placeholder="Titre de la leçon"
        />
        {lesson.sourcePage && (
          <span
            className="text-[10px] font-semibold bg-amber-50 text-amber-800 border border-amber-200 px-1.5 py-0.5 rounded"
            title="Page du PDF source"
          >
            p.{lesson.sourcePage}
          </span>
        )}
        <button
          type="button"
          onClick={() => setEditing(!editing)}
          className={
            "inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10.5px] font-semibold border transition " +
            (editing
              ? "bg-navy-900 text-white border-navy-900"
              : "bg-white text-navy-700 border-navy-100 hover:bg-navy-50")
          }
        >
          {editing ? (
            <>
              <Eye className="h-3 w-3" />
              Aperçu
            </>
          ) : (
            <>
              <Pencil className="h-3 w-3" />
              Éditer
            </>
          )}
        </button>
        <button
          type="button"
          onClick={onDrop}
          className="text-rose-700 hover:text-rose-900 inline-flex items-center gap-0.5 text-[11px] font-semibold"
          title="Retirer cette leçon"
        >
          <Trash2 className="h-3 w-3" />
        </button>
      </div>

      {lesson.warnings && lesson.warnings.length > 0 && (
        <div className="mb-2 rounded-lg border border-amber-200 bg-amber-50/60 px-2.5 py-1.5 text-[12px] text-amber-900 flex items-start gap-1.5">
          <AlertTriangle className="h-3 w-3 mt-0.5 shrink-0" />
          <div>{lesson.warnings.join(" · ")}</div>
        </div>
      )}

      {editing ? (
        <RichTextEditor
          value={lesson.contentHtml}
          onChange={(html) => onUpdate({ contentHtml: html })}
          placeholder="Contenu de la leçon (HTML rich)"
          minHeight={220}
        />
      ) : (
        <div
          className="rounded-lg border border-navy-100 bg-ivory px-3 py-2.5 text-[13.5px] text-navy-900 leading-relaxed cursor-text hover:border-navy-200 transition"
          style={{ minHeight: 80 }}
          onClick={() => setEditing(true)}
        >
          {lesson.contentHtml ? (
            <RichTextDisplay content={lesson.contentHtml} />
          ) : (
            <span className="text-slate-400 italic">
              Contenu vide — cliquer pour éditer
            </span>
          )}
        </div>
      )}
    </div>
  );
}

// =====================================================================
// Helpers
// =====================================================================
function SummaryChip({
  label,
  value,
  tone,
}: {
  label: string;
  value: number;
  tone: "navy" | "signal" | "brand";
}) {
  const styles: Record<typeof tone, string> = {
    navy: "bg-navy-50 text-navy-900",
    signal: "bg-signal-100/60 text-signal-800",
    brand: "bg-brand-50 text-brand-700",
  };
  return (
    <div className={`px-2.5 py-1.5 rounded-lg ${styles[tone]}`}>
      <div className="text-[10px] font-bold uppercase tracking-[0.12em]">
        {label}
      </div>
      <div className="font-display text-base font-semibold tabular-nums">
        {value}
      </div>
    </div>
  );
}
