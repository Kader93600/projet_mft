"use client";

import { useMemo, useState } from "react";
import {
  UploadCloud,
  ClipboardPaste,
  FileText,
  Loader2,
  AlertTriangle,
  CheckCircle2,
  ArrowRight,
  ArrowLeft,
  Trash2,
  Plus,
  RotateCcw,
  Paperclip,
} from "lucide-react";

interface FormationOpt {
  id: string;
  slug: string;
  code: string;
  title: string;
}

interface ModuleOpt {
  id: string;
  slug: string;
  title: string;
}

interface LessonOpt {
  id: string;
  slug: string;
  title: string;
}

interface DraftChoice {
  letter: string;
  label: string;
  isCorrect: boolean;
}

interface DraftQuestion {
  index: number;
  type: "qcm" | "qr";
  statement: string;
  choices?: DraftChoice[];
  expectedAnswer?: string;
  scoringGrid?: string;
  maxScore: number;
  difficulty: "facile" | "moyen" | "difficile";
  tags: string[];
  explanation?: string;
  warnings: string[];
  annexPages?: number[];
  annexLabels?: string[];
  /** Indique si l'admin l'a marquée pour suppression dans cette session. */
  _drop?: boolean;
}

interface AnnexEntry {
  pageNumber: number;
  label: string;
  ref: string;
}

interface Props {
  formations: FormationOpt[];
  modulesByFormation: Record<string, ModuleOpt[]>;
  lessonsByModule: Record<string, LessonOpt[]>;
}

type Step = "upload" | "review" | "saving" | "done";

const EXPECTED_TYPES: { value: string; label: string; desc: string }[] = [
  { value: "qcm", label: "QCM uniquement", desc: "Choix multiples" },
  { value: "qr", label: "QR uniquement", desc: "Questions rédigées" },
  { value: "mixed", label: "Mixte (auto)", desc: "QCM + QR mélangés" },
  { value: "exam", label: "Examen blanc", desc: "Sujet complet, sections" },
];

export function ImportFlow({
  formations,
  modulesByFormation,
  lessonsByModule,
}: Props) {
  const [step, setStep] = useState<Step>("upload");

  // Étape 1 — Upload
  const [file, setFile] = useState<File | null>(null);
  const [pastedText, setPastedText] = useState("");
  const [formationId, setFormationId] = useState<string>("");
  const [moduleId, setModuleId] = useState<string>("");
  const [lessonId, setLessonId] = useState<string>("");
  const [expectedType, setExpectedType] = useState<string>("mixed");
  const [notes, setNotes] = useState("");
  const [inputMode, setInputMode] = useState<"file" | "paste">("file");

  // Étape 2 — Review
  const [importId, setImportId] = useState<string | null>(null);
  const [rawText, setRawText] = useState("");
  const [questions, setQuestions] = useState<DraftQuestion[]>([]);
  const [showRawText, setShowRawText] = useState(false);
  const [detectedFormat, setDetectedFormat] = useState<string>("unknown");
  const [annexes, setAnnexes] = useState<AnnexEntry[]>([]);

  // Étape 3 — Result
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [insertedCount, setInsertedCount] = useState(0);

  // Loading
  const [isExtracting, setIsExtracting] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const modules = useMemo(
    () => (formationId ? modulesByFormation[formationId] ?? [] : []),
    [formationId, modulesByFormation],
  );

  const lessons = useMemo(
    () => (moduleId ? lessonsByModule[moduleId] ?? [] : []),
    [moduleId, lessonsByModule],
  );

  const visibleQuestions = useMemo(
    () => questions.filter((q) => !q._drop),
    [questions],
  );

  const summary = useMemo(() => {
    const qcm = visibleQuestions.filter((q) => q.type === "qcm").length;
    const qr = visibleQuestions.filter((q) => q.type === "qr").length;
    const warn = visibleQuestions.filter((q) => q.warnings.length > 0).length;
    return { qcm, qr, total: visibleQuestions.length, warn };
  }, [visibleQuestions]);

  // ─────────────────────────────────────────────────────────────────
  // Step 1 → Step 2 : extract
  // ─────────────────────────────────────────────────────────────────
  const onExtract = async () => {
    setErrorMsg(null);
    if (!formationId) {
      setErrorMsg("Sélectionnez une formation avant de continuer.");
      return;
    }
    if (inputMode === "file" && !file) {
      setErrorMsg("Sélectionnez un fichier.");
      return;
    }
    if (inputMode === "paste" && pastedText.trim().length < 30) {
      setErrorMsg("Texte trop court (minimum 30 caractères).");
      return;
    }

    const formation = formations.find((f) => f.id === formationId);

    setIsExtracting(true);
    try {
      const fd = new FormData();
      fd.append("formation_slug", formation?.slug ?? "");
      fd.append("expected_type", expectedType);
      if (moduleId) fd.append("module_id", moduleId);
      if (lessonId) fd.append("lesson_id", lessonId);
      if (notes) fd.append("notes", notes);
      if (inputMode === "file" && file) fd.append("file", file);
      if (inputMode === "paste") fd.append("pasted_text", pastedText);

      const res = await fetch("/api/admin/questions/import/extract", {
        method: "POST",
        body: fd,
      });
      const json = await res.json();
      if (!res.ok) {
        setErrorMsg(json.message ?? json.error ?? "Erreur d'extraction");
        return;
      }
      setImportId(json.import_id);
      setRawText(json.raw_text);
      setDetectedFormat(json.summary?.detectedFormat ?? "unknown");
      setAnnexes(json.annexes ?? []);
      // Mappe en interne (camelCase)
      setQuestions(
        (json.questions ?? []).map((q: any) => ({
          ...q,
          warnings: q.warnings ?? [],
          annexPages: q.annexPages ?? [],
          annexLabels: q.annexLabels ?? [],
          choices: q.choices?.map((c: any) => ({
            letter: c.letter,
            label: c.label,
            isCorrect: c.isCorrect,
          })),
        })),
      );
      setStep("review");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Erreur réseau");
    } finally {
      setIsExtracting(false);
    }
  };

  // Re-parse depuis le texte brut édité (sans re-uploader le fichier)
  const onReparse = async () => {
    setIsExtracting(true);
    setErrorMsg(null);
    try {
      const formation = formations.find((f) => f.id === formationId);
      const fd = new FormData();
      fd.append("formation_slug", formation?.slug ?? "");
      fd.append("expected_type", expectedType);
      if (moduleId) fd.append("module_id", moduleId);
      fd.append("pasted_text", rawText);

      const res = await fetch("/api/admin/questions/import/extract", {
        method: "POST",
        body: fd,
      });
      const json = await res.json();
      if (!res.ok) {
        setErrorMsg(json.message ?? json.error ?? "Erreur re-parsing");
        return;
      }
      setImportId(json.import_id);
      setQuestions(
        (json.questions ?? []).map((q: any) => ({
          ...q,
          warnings: q.warnings ?? [],
        })),
      );
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Erreur réseau");
    } finally {
      setIsExtracting(false);
    }
  };

  // ─────────────────────────────────────────────────────────────────
  // Step 2 → Step 3 : save
  // ─────────────────────────────────────────────────────────────────
  const onSave = async () => {
    setErrorMsg(null);
    if (!importId) return;
    if (visibleQuestions.length === 0) {
      setErrorMsg("Aucune question à insérer.");
      return;
    }

    setIsSaving(true);
    setStep("saving");
    try {
      const payload = {
        import_id: importId,
        formation_id: formationId,
        module_id: moduleId || null,
        lesson_id: lessonId || null,
        questions: visibleQuestions.map((q) => ({
          type: q.type,
          statement: q.statement,
          choices:
            q.type === "qcm"
              ? (q.choices ?? []).map((c) => ({
                  letter: c.letter,
                  label: c.label,
                  is_correct: c.isCorrect,
                }))
              : null,
          expected_answer: q.expectedAnswer || null,
          scoring_grid: q.scoringGrid || null,
          max_score: q.maxScore,
          difficulty: q.difficulty,
          tags: q.tags,
          explanation: q.explanation || null,
          annex_pages: q.annexPages ?? [],
          annex_labels: q.annexLabels ?? [],
        })),
      };
      const res = await fetch("/api/admin/questions/import/save", {
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
      setInsertedCount(json.inserted ?? 0);
      setStep("done");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Erreur réseau");
      setStep("review");
    } finally {
      setIsSaving(false);
    }
  };

  const reset = () => {
    setStep("upload");
    setFile(null);
    setPastedText("");
    setImportId(null);
    setRawText("");
    setQuestions([]);
    setErrorMsg(null);
    setInsertedCount(0);
  };

  // ─────────────────────────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────────────────────────
  return (
    <div className="mt-5 space-y-6">
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
          modules={modules}
          lessons={lessons}
          formationId={formationId}
          setFormationId={(id) => {
            setFormationId(id);
            setModuleId("");
            setLessonId("");
          }}
          moduleId={moduleId}
          setModuleId={(id) => {
            setModuleId(id);
            setLessonId("");
          }}
          lessonId={lessonId}
          setLessonId={setLessonId}
          expectedType={expectedType}
          setExpectedType={setExpectedType}
          notes={notes}
          setNotes={setNotes}
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
          summary={summary}
          detectedFormat={detectedFormat}
          annexes={annexes}
          rawText={rawText}
          setRawText={setRawText}
          showRawText={showRawText}
          setShowRawText={setShowRawText}
          questions={questions}
          setQuestions={setQuestions}
          isExtracting={isExtracting}
          onReparse={onReparse}
          onBack={() => setStep("upload")}
          onSave={onSave}
        />
      )}

      {step === "saving" && (
        <div className="rounded-2xl border border-navy-100 bg-ivory p-8 text-center">
          <Loader2 className="h-6 w-6 mx-auto animate-spin text-signal-600" />
          <p className="mt-3 text-sm text-slate-600">
            Insertion de {visibleQuestions.length} question(s) en cours…
          </p>
        </div>
      )}

      {step === "done" && (
        <div className="rounded-2xl border border-emerald-200 bg-emerald-50/70 p-6">
          <div className="flex items-start gap-3">
            <CheckCircle2 className="h-5 w-5 text-emerald-700 mt-0.5" />
            <div className="flex-1">
              <div className="font-display text-base font-semibold text-emerald-900">
                {insertedCount} question(s) ajoutée(s) à la banque
              </div>
              <p className="mt-1 text-[13px] text-emerald-800 leading-relaxed">
                Les questions sont insérées <strong>désactivées</strong> par
                défaut. Vérifiez-les dans{" "}
                <a
                  href="/admin/banque-questions/validation"
                  className="underline underline-offset-2 hover:text-emerald-950"
                >
                  Validation
                </a>{" "}
                avant de les activer pour les stagiaires.
              </p>
              <div className="mt-4 flex gap-2">
                <button
                  onClick={reset}
                  className="inline-flex items-center gap-1.5 text-sm font-semibold px-3.5 py-2 rounded-lg bg-navy-900 text-white hover:bg-navy-800 transition"
                >
                  <RotateCcw className="h-3.5 w-3.5" />
                  Nouvel import
                </button>
                <a
                  href="/admin/banque-questions/validation"
                  className="inline-flex items-center gap-1.5 text-sm font-semibold px-3.5 py-2 rounded-lg border border-emerald-300 bg-white text-emerald-900 hover:bg-emerald-50 transition"
                >
                  Aller à la validation
                  <ArrowRight className="h-3.5 w-3.5" />
                </a>
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
      {steps.map((s, i) => {
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
// Step 1 — Upload / Paste
// =====================================================================
function UploadStep(props: {
  formations: FormationOpt[];
  modules: ModuleOpt[];
  lessons: LessonOpt[];
  formationId: string;
  setFormationId: (s: string) => void;
  moduleId: string;
  setModuleId: (s: string) => void;
  lessonId: string;
  setLessonId: (s: string) => void;
  expectedType: string;
  setExpectedType: (s: string) => void;
  notes: string;
  setNotes: (s: string) => void;
  inputMode: "file" | "paste";
  setInputMode: (m: "file" | "paste") => void;
  file: File | null;
  setFile: (f: File | null) => void;
  pastedText: string;
  setPastedText: (s: string) => void;
  isExtracting: boolean;
  onExtract: () => void;
}) {
  return (
    <div className="space-y-5">
      <div className="grid md:grid-cols-3 gap-4">
        <div>
          <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block">
            Formation
          </label>
          <select
            value={props.formationId}
            onChange={(e) => props.setFormationId(e.target.value)}
            className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900"
          >
            <option value="">— Sélectionner —</option>
            {props.formations.map((f) => (
              <option key={f.id} value={f.id}>
                {f.code} — {f.title}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block">
            Module (optionnel)
          </label>
          <select
            value={props.moduleId}
            onChange={(e) => props.setModuleId(e.target.value)}
            disabled={props.modules.length === 0}
            className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 disabled:bg-slate-50 disabled:text-slate-400"
          >
            <option value="">— Aucun (formation entière) —</option>
            {props.modules.map((m) => (
              <option key={m.id} value={m.id}>
                {m.title}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block">
            Leçon (optionnel)
          </label>
          <select
            value={props.lessonId}
            onChange={(e) => props.setLessonId(e.target.value)}
            disabled={props.lessons.length === 0}
            className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 disabled:bg-slate-50 disabled:text-slate-400"
            title={
              props.lessons.length === 0
                ? "Sélectionnez d'abord un module"
                : undefined
            }
          >
            <option value="">— Aucune (module entier) —</option>
            {props.lessons.map((l) => (
              <option key={l.id} value={l.id}>
                {l.title}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-2 block">
          Type attendu
        </label>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
          {EXPECTED_TYPES.map((t) => {
            const active = props.expectedType === t.value;
            return (
              <button
                key={t.value}
                type="button"
                onClick={() => props.setExpectedType(t.value)}
                className={
                  "rounded-xl border p-3 text-left transition-all duration-200 " +
                  (active
                    ? "border-signal-500 bg-signal-50/60 shadow-soft"
                    : "border-navy-100 bg-white hover:border-navy-200 hover:-translate-y-0.5")
                }
              >
                <div className="text-[13px] font-semibold text-navy-900">
                  {t.label}
                </div>
                <div className="text-[11px] text-slate-500 mt-0.5">{t.desc}</div>
              </button>
            );
          })}
        </div>
      </div>

      {/* Toggle source */}
      <div className="border-t border-navy-100 pt-5">
        <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-2">
          Source
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
          <div className="mt-3 rounded-2xl border-2 border-dashed border-navy-200 bg-ivory hover:border-signal-500 transition p-6 text-center">
            <input
              type="file"
              accept="application/pdf,.pdf,.txt"
              onChange={(e) => props.setFile(e.target.files?.[0] ?? null)}
              className="hidden"
              id="file-upload"
            />
            <label
              htmlFor="file-upload"
              className="cursor-pointer inline-flex flex-col items-center gap-2"
            >
              <UploadCloud className="h-6 w-6 text-signal-700" />
              <div className="text-sm font-semibold text-navy-900">
                {props.file ? props.file.name : "Cliquer pour choisir un PDF"}
              </div>
              {props.file && (
                <div className="text-xs text-slate-500">
                  {(props.file.size / 1024).toFixed(0)} Ko
                </div>
              )}
              <div className="text-xs text-slate-500">
                PDF ou texte brut · 12 Mo max
              </div>
            </label>
          </div>
        ) : (
          <textarea
            value={props.pastedText}
            onChange={(e) => props.setPastedText(e.target.value)}
            placeholder="Coller ici le contenu d'un PDF scanné, d'une copie Word, etc. Le parser détectera Q1./Q2./a)/b)/Réponse:/Barème:…"
            className="mt-3 w-full min-h-[260px] rounded-xl border border-navy-200 bg-white px-3.5 py-2.5 text-[13.5px] font-mono leading-relaxed text-navy-900"
          />
        )}
      </div>

      <div>
        <label className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5 block">
          Notes internes (optionnel)
        </label>
        <input
          type="text"
          value={props.notes}
          onChange={(e) => props.setNotes(e.target.value)}
          placeholder="Ex. Examens blancs 2024 fournis par MFT le 12 mai"
          className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[14px] text-navy-900"
        />
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
// Step 2 — Review questions
// =====================================================================
const FORMAT_LABELS: Record<string, string> = {
  exercise: "Livret d'exercices (QR contextualisées)",
  qcm_qr: "Quiz / Examen blanc (QCM + QR)",
  numbered: "Liste numérotée simple",
  unknown: "Format non reconnu",
};

function ReviewStep(props: {
  summary: { total: number; qcm: number; qr: number; warn: number };
  detectedFormat: string;
  annexes: AnnexEntry[];
  rawText: string;
  setRawText: (s: string) => void;
  showRawText: boolean;
  setShowRawText: (b: boolean) => void;
  questions: DraftQuestion[];
  setQuestions: (q: DraftQuestion[]) => void;
  isExtracting: boolean;
  onReparse: () => void;
  onBack: () => void;
  onSave: () => void;
}) {
  const updateQ = (i: number, patch: Partial<DraftQuestion>) => {
    const next = [...props.questions];
    next[i] = { ...next[i], ...patch };
    props.setQuestions(next);
  };

  const toggleChoice = (qi: number, ci: number) => {
    const q = props.questions[qi];
    if (!q.choices) return;
    const choices = q.choices.map((c, idx) =>
      idx === ci ? { ...c, isCorrect: !c.isCorrect } : c,
    );
    updateQ(qi, { choices });
  };

  const updateChoiceLabel = (qi: number, ci: number, label: string) => {
    const q = props.questions[qi];
    if (!q.choices) return;
    const choices = q.choices.map((c, idx) =>
      idx === ci ? { ...c, label } : c,
    );
    updateQ(qi, { choices });
  };

  const addChoice = (qi: number) => {
    const q = props.questions[qi];
    const choices = [...(q.choices ?? [])];
    const nextLetter = String.fromCharCode(97 + choices.length); // a, b, c…
    choices.push({ letter: nextLetter, label: "", isCorrect: false });
    updateQ(qi, { choices });
  };

  const removeChoice = (qi: number, ci: number) => {
    const q = props.questions[qi];
    if (!q.choices) return;
    updateQ(qi, { choices: q.choices.filter((_, idx) => idx !== ci) });
  };

  const visible = props.questions.filter((q) => !q._drop);

  return (
    <div className="space-y-4">
      {/* Bandeau format détecté + annexes */}
      <div className="flex items-center gap-2 flex-wrap">
        <div className="rounded-xl bg-signal-50/40 border border-signal-200 px-3.5 py-2 text-[12px] text-signal-900 inline-flex items-center gap-2">
          <CheckCircle2 className="h-3.5 w-3.5 text-signal-700" />
          <span>
            Format&nbsp;:{" "}
            <strong>
              {FORMAT_LABELS[props.detectedFormat] ?? props.detectedFormat}
            </strong>
          </span>
        </div>
        {props.annexes.length > 0 && (
          <div className="rounded-xl bg-amber-50 border border-amber-200 px-3.5 py-2 text-[12px] text-amber-900 inline-flex items-center gap-2">
            <Paperclip className="h-3.5 w-3.5 text-amber-700" />
            <span>
              <strong>{props.annexes.length}</strong> annexe(s) détectée(s)
              dans le PDF
            </span>
          </div>
        )}
      </div>

      {/* Liste des annexes (collapsible si > 3) */}
      {props.annexes.length > 0 && (
        <details className="rounded-xl border border-amber-200 bg-amber-50/40 px-3.5 py-2">
          <summary className="text-[12px] font-semibold text-amber-900 cursor-pointer">
            Voir les {props.annexes.length} annexe(s) du PDF
          </summary>
          <ul className="mt-2 space-y-1 text-[12.5px] text-amber-900">
            {props.annexes.map((a) => (
              <li key={a.pageNumber} className="flex items-center gap-2">
                <span className="inline-flex items-center justify-center w-7 h-5 rounded bg-amber-200 text-amber-900 text-[10px] font-bold tabular-nums">
                  p.{a.pageNumber}
                </span>
                <span>{a.label}</span>
              </li>
            ))}
          </ul>
          <p className="mt-2 text-[11.5px] text-amber-800/80 leading-relaxed">
            Les questions qui mentionnent "Annexe N°…" sont automatiquement
            liées à la page correspondante. Au moment du quiz, le stagiaire
            verra l'annexe à côté de l'énoncé.
          </p>
        </details>
      )}

      {/* Bandeau résumé */}
      <div className="rounded-2xl bg-ivory border border-navy-100 px-4 py-3 flex items-center gap-4 flex-wrap">
        <SummaryChip label="Total" value={props.summary.total} tone="navy" />
        <SummaryChip label="QCM" value={props.summary.qcm} tone="signal" />
        <SummaryChip label="QR" value={props.summary.qr} tone="brand" />
        {props.summary.warn > 0 && (
          <SummaryChip
            label="À vérifier"
            value={props.summary.warn}
            tone="amber"
          />
        )}
        <div className="ml-auto flex items-center gap-2">
          <button
            type="button"
            onClick={() => props.setShowRawText(!props.showRawText)}
            className="inline-flex items-center gap-1 text-[12px] font-semibold text-navy-900 hover:text-navy-950"
          >
            <FileText className="h-3.5 w-3.5" />
            {props.showRawText ? "Masquer" : "Voir"} le texte brut
          </button>
          <button
            type="button"
            onClick={props.onReparse}
            disabled={props.isExtracting}
            className="inline-flex items-center gap-1 text-[12px] font-semibold text-amber-800 hover:text-amber-900 disabled:opacity-50"
          >
            {props.isExtracting ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <RotateCcw className="h-3.5 w-3.5" />
            )}
            Re-parser
          </button>
        </div>
      </div>

      {props.showRawText && (
        <div>
          <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-600 mb-1.5">
            Texte brut éditable — modifiez puis cliquez "Re-parser" pour
            recalculer le découpage.
          </div>
          <textarea
            value={props.rawText}
            onChange={(e) => props.setRawText(e.target.value)}
            className="w-full min-h-[200px] rounded-xl border border-navy-200 bg-white px-3.5 py-2.5 text-[12.5px] font-mono leading-relaxed text-navy-900"
          />
        </div>
      )}

      {/* Liste éditable */}
      <div className="space-y-3">
        {visible.length === 0 && (
          <div className="rounded-xl border border-dashed border-navy-200 bg-ivory px-4 py-8 text-center text-sm text-slate-500">
            Aucune question détectée. Éditez le texte brut ou recommencez.
          </div>
        )}

        {props.questions.map((q, qi) => {
          if (q._drop) return null;
          return (
            <QuestionCard
              key={qi}
              question={q}
              onUpdate={(patch) => updateQ(qi, patch)}
              onToggleChoice={(ci) => toggleChoice(qi, ci)}
              onUpdateChoiceLabel={(ci, label) =>
                updateChoiceLabel(qi, ci, label)
              }
              onAddChoice={() => addChoice(qi)}
              onRemoveChoice={(ci) => removeChoice(qi, ci)}
              onDrop={() => updateQ(qi, { _drop: true })}
            />
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
          disabled={visible.length === 0}
          className="inline-flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-gold-500 text-night-900 font-semibold text-sm hover:bg-gold-400 transition disabled:opacity-50"
        >
          Insérer {visible.length} question(s)
          <ArrowRight className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}

function SummaryChip({
  label,
  value,
  tone,
}: {
  label: string;
  value: number;
  tone: "navy" | "signal" | "brand" | "amber";
}) {
  const styles: Record<typeof tone, string> = {
    navy: "bg-navy-50 text-navy-900",
    signal: "bg-signal-100/60 text-signal-800",
    brand: "bg-brand-50 text-brand-700",
    amber: "bg-amber-50 text-amber-800",
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

// =====================================================================
// QuestionCard — édition inline d'une question
// =====================================================================
function QuestionCard({
  question: q,
  onUpdate,
  onToggleChoice,
  onUpdateChoiceLabel,
  onAddChoice,
  onRemoveChoice,
  onDrop,
}: {
  question: DraftQuestion;
  onUpdate: (patch: Partial<DraftQuestion>) => void;
  onToggleChoice: (ci: number) => void;
  onUpdateChoiceLabel: (ci: number, label: string) => void;
  onAddChoice: () => void;
  onRemoveChoice: (ci: number) => void;
  onDrop: () => void;
}) {
  const typeColor = q.type === "qcm" ? "signal" : "brand";
  return (
    <div className="rounded-2xl border border-navy-100 bg-white p-4 md:p-5">
      <div className="flex items-start gap-3">
        <div className="font-mono text-[11px] font-bold text-slate-400 tabular-nums mt-1">
          #{q.index}
        </div>
        <div className="flex-1 min-w-0">
          {/* Type + difficulté + max_score + suppression */}
          <div className="flex items-center gap-2 flex-wrap mb-2">
            <select
              value={q.type}
              onChange={(e) =>
                onUpdate({ type: e.target.value as "qcm" | "qr" })
              }
              className={
                "px-2 py-0.5 rounded-md text-[11px] font-bold uppercase tracking-[0.12em] border " +
                (typeColor === "signal"
                  ? "bg-signal-100/60 text-signal-800 border-signal-300"
                  : "bg-brand-50 text-brand-700 border-brand-200")
              }
            >
              <option value="qcm">QCM</option>
              <option value="qr">QR</option>
            </select>
            <select
              value={q.difficulty}
              onChange={(e) =>
                onUpdate({
                  difficulty: e.target.value as DraftQuestion["difficulty"],
                })
              }
              className="px-2 py-0.5 rounded-md text-[11px] font-semibold border border-navy-200 bg-white text-navy-700"
            >
              <option value="facile">Facile</option>
              <option value="moyen">Moyen</option>
              <option value="difficile">Difficile</option>
            </select>
            <div className="inline-flex items-center gap-1 text-[11px] text-slate-500">
              <span>Note max :</span>
              <input
                type="number"
                value={q.maxScore}
                onChange={(e) =>
                  onUpdate({ maxScore: parseFloat(e.target.value) || 1 })
                }
                step="0.5"
                min="0"
                className="w-14 px-1 py-0.5 rounded border border-navy-100 text-[11px] tabular-nums"
              />
            </div>
            <button
              type="button"
              onClick={onDrop}
              className="ml-auto inline-flex items-center gap-1 text-[12px] text-rose-700 hover:text-rose-900"
              title="Retirer cette question de l'import"
            >
              <Trash2 className="h-3 w-3" />
              Retirer
            </button>
          </div>

          {/* Warnings */}
          {q.warnings.length > 0 && (
            <div className="mb-2 rounded-lg border border-amber-200 bg-amber-50/60 px-2.5 py-1.5 text-[12px] text-amber-900 flex items-start gap-1.5">
              <AlertTriangle className="h-3 w-3 mt-0.5 shrink-0" />
              <div>
                {q.warnings.join(" · ")}
              </div>
            </div>
          )}

          {/* Annexes liées */}
          {q.annexPages && q.annexPages.length > 0 && (
            <div className="mb-2 flex items-center gap-1.5 flex-wrap">
              <Paperclip className="h-3 w-3 text-amber-700" />
              {q.annexPages.map((p, i) => (
                <span
                  key={i}
                  className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10.5px] font-semibold bg-amber-100 text-amber-900 border border-amber-200"
                  title={q.annexLabels?.[i] ?? `Page ${p}`}
                >
                  <span className="font-mono">p.{p}</span>
                  {q.annexLabels?.[i] && (
                    <span className="font-normal max-w-[200px] truncate">
                      {q.annexLabels[i]}
                    </span>
                  )}
                </span>
              ))}
            </div>
          )}

          {/* Énoncé */}
          <textarea
            value={q.statement}
            onChange={(e) => onUpdate({ statement: e.target.value })}
            className="w-full rounded-lg border border-navy-200 bg-white px-3 py-2 text-[14px] text-navy-900 leading-relaxed font-medium min-h-[60px]"
            placeholder="Énoncé de la question"
          />

          {/* QCM : choix */}
          {q.type === "qcm" && (
            <div className="mt-3 space-y-1.5">
              {(q.choices ?? []).map((c, ci) => (
                <div key={ci} className="flex items-start gap-2">
                  <button
                    type="button"
                    onClick={() => onToggleChoice(ci)}
                    className={
                      "shrink-0 mt-1 h-5 w-5 rounded-md inline-flex items-center justify-center border-2 transition " +
                      (c.isCorrect
                        ? "bg-emerald-500 border-emerald-500 text-white"
                        : "bg-white border-navy-200 hover:border-navy-300")
                    }
                    title={c.isCorrect ? "Bonne réponse" : "Cliquer pour marquer correcte"}
                  >
                    {c.isCorrect && <CheckCircle2 className="h-3 w-3" />}
                  </button>
                  <span className="font-mono text-[11px] font-bold text-slate-400 mt-1.5 w-3">
                    {c.letter}
                  </span>
                  <input
                    type="text"
                    value={c.label}
                    onChange={(e) => onUpdateChoiceLabel(ci, e.target.value)}
                    className="flex-1 rounded-lg border border-navy-100 bg-white px-2.5 py-1.5 text-[13px] text-navy-900"
                    placeholder="Texte de l'option"
                  />
                  <button
                    type="button"
                    onClick={() => onRemoveChoice(ci)}
                    className="shrink-0 text-rose-700 hover:text-rose-900 p-1"
                    title="Supprimer cette option"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              ))}
              <button
                type="button"
                onClick={onAddChoice}
                className="inline-flex items-center gap-1 text-[12px] font-semibold text-signal-700 hover:text-signal-800 mt-1"
              >
                <Plus className="h-3 w-3" />
                Ajouter une option
              </button>
            </div>
          )}

          {/* QR : réponse attendue + barème */}
          {q.type === "qr" && (
            <div className="mt-3 grid md:grid-cols-2 gap-2">
              <div>
                <label className="text-[11px] font-semibold text-slate-600 mb-1 block">
                  Réponse attendue / éléments
                </label>
                <textarea
                  value={q.expectedAnswer ?? ""}
                  onChange={(e) =>
                    onUpdate({ expectedAnswer: e.target.value })
                  }
                  className="w-full min-h-[80px] rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-[13px] text-navy-900"
                  placeholder="Ce que le stagiaire doit produire (visible formateur)"
                />
              </div>
              <div>
                <label className="text-[11px] font-semibold text-slate-600 mb-1 block">
                  Barème détaillé
                </label>
                <textarea
                  value={q.scoringGrid ?? ""}
                  onChange={(e) => onUpdate({ scoringGrid: e.target.value })}
                  className="w-full min-h-[80px] rounded-lg border border-navy-200 bg-white px-2.5 py-1.5 text-[13px] text-navy-900"
                  placeholder="Ex. Définition 2 pts + Exemple 1 pt + Conditions 2 pts"
                />
              </div>
            </div>
          )}

          {/* Explication */}
          <details className="mt-2">
            <summary className="text-[11px] font-semibold text-slate-500 cursor-pointer hover:text-navy-900">
              Explication / corrigé (optionnel)
            </summary>
            <textarea
              value={q.explanation ?? ""}
              onChange={(e) => onUpdate({ explanation: e.target.value })}
              className="mt-1 w-full min-h-[60px] rounded-lg border border-navy-100 bg-white px-2.5 py-1.5 text-[13px] text-slate-700"
              placeholder="Justification, source, point pédagogique"
            />
          </details>
        </div>
      </div>
    </div>
  );
}
