"use client";
import { useState, useTransition } from "react";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { Save } from "lucide-react";
import { useRouter } from "next/navigation";
import { createQuiz, updateQuiz } from "./actions";
import type { Tables } from "@/lib/database.types";

interface Module {
  id: string;
  title: string;
}

interface FormationOpt {
  slug: string;
  code: string;
  title: string;
}

/** Valeurs métier des colonnes `text` correspondantes de `quizzes`. */
export type QuizType = "entrainement" | "examen";
export type ShowExplanationsMode = "always" | "after_pass" | "never";

/** Quiz existant en cours d'édition (sous-ensemble utilisé par ce formulaire). */
export type QuizSettings = Pick<
  Tables<"quizzes">,
  | "id"
  | "title"
  | "description"
  | "module_id"
  | "timer_enabled"
  | "time_limit_s"
  | "pass_threshold"
  | "is_mock_exam"
  | "max_attempts"
  | "retake_delay_hours"
  | "shuffle_questions"
  | "shuffle_choices"
  | "require_fullscreen"
> & {
  type: QuizType;
  show_explanations_mode: ShowExplanationsMode;
};

export function QuizSettingsForm({
  modules,
  formations,
  quiz,
  initialFormationSlug,
}: {
  modules: Module[];
  formations: FormationOpt[];
  quiz?: QuizSettings;
  initialFormationSlug?: string | null;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  const [title, setTitle] = useState(quiz?.title ?? "");
  const [description, setDescription] = useState(quiz?.description ?? "");
  const [type, setType] = useState<QuizType>(quiz?.type ?? "entrainement");
  const [moduleId, setModuleId] = useState<string>(quiz?.module_id ?? "");
  const [timerEnabled, setTimerEnabled] = useState<boolean>(
    quiz?.timer_enabled ?? true
  );
  const [minutes, setMinutes] = useState<number>(
    quiz?.time_limit_s ? Math.round(quiz.time_limit_s / 60) : 15
  );
  const [threshold, setThreshold] = useState<number>(quiz?.pass_threshold ?? 70);

  // Examen blanc officiel (Point #8)
  const [isMock, setIsMock] = useState<boolean>(quiz?.is_mock_exam ?? false);
  const [maxAttempts, setMaxAttempts] = useState<number | "">(
    quiz?.max_attempts ?? ""
  );
  const [retakeDelay, setRetakeDelay] = useState<number>(
    quiz?.retake_delay_hours ?? 0
  );
  const [shuffleQ, setShuffleQ] = useState<boolean>(quiz?.shuffle_questions ?? false);
  const [shuffleC, setShuffleC] = useState<boolean>(quiz?.shuffle_choices ?? false);
  const [requireFs, setRequireFs] = useState<boolean>(quiz?.require_fullscreen ?? false);
  const [showExp, setShowExp] = useState<ShowExplanationsMode>(
    quiz?.show_explanations_mode ?? "always"
  );
  const [formationSlug, setFormationSlug] = useState<string>(
    initialFormationSlug ?? formations[0]?.slug ?? ""
  );

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formationSlug) {
      toast("Sélectionnez la formation associée", "error");
      return;
    }
    startTransition(async () => {
      try {
        const payload = {
          title,
          description: description || undefined,
          type,
          module_id: moduleId || null,
          formation_slug: formationSlug,
          timer_enabled: timerEnabled,
          time_limit_s: timerEnabled ? minutes * 60 : null,
          pass_threshold: threshold,
          is_mock_exam: isMock,
          max_attempts: maxAttempts === "" ? null : Number(maxAttempts),
          retake_delay_hours: retakeDelay,
          shuffle_questions: shuffleQ,
          shuffle_choices: shuffleC,
          require_fullscreen: requireFs,
          show_explanations_mode: showExp,
        };
        if (quiz?.id) {
          await updateQuiz(quiz.id, payload);
          toast("Quiz mis à jour", "success");
          router.refresh();
        } else {
          await createQuiz(payload);
        }
      } catch (e) {
        toast(e instanceof Error ? e.message : String(e), "error");
      }
    });
  }

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">
          Formation associée <span className="text-rose-600">*</span>
        </span>
        <Select
          value={formationSlug}
          onChange={(e) => setFormationSlug(e.target.value)}
          required
        >
          <option value="">— Sélectionner une formation —</option>
          {formations.map((f) => (
            <option key={f.slug} value={f.slug}>
              {f.code} — {f.title}
            </option>
          ))}
        </Select>
        <span className="mt-1 block text-[11px] text-slate-500">
          Le quiz sera rattaché à cette formation et apparaîtra dans son
          parcours d'évaluation.
        </span>
      </label>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">Titre</span>
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          required
          placeholder="Ex. Quiz réglementation sociale"
        />
      </label>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">Description</span>
        <Textarea
          rows={2}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </label>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">Type</span>
          <Select
            value={type}
            onChange={(e) => setType(e.target.value as QuizType)}
          >
            <option value="entrainement">Entraînement</option>
            <option value="examen">Examen blanc</option>
          </Select>
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Module associé
          </span>
          <Select value={moduleId} onChange={(e) => setModuleId(e.target.value)}>
            <option value="">Aucun</option>
            {modules.map((m) => (
              <option key={m.id} value={m.id}>
                {m.title}
              </option>
            ))}
          </Select>
        </label>
      </div>

      <div className="rounded-xl border border-navy-100 bg-navy-50/30 p-4 space-y-3">
        <label className="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            checked={timerEnabled}
            onChange={(e) => setTimerEnabled(e.target.checked)}
            className="h-4 w-4 rounded border-navy-200 text-navy-900"
          />
          <span className="text-sm font-medium text-navy-900">
            Activer le chronomètre
          </span>
        </label>
        {timerEnabled && (
          <label className="block">
            <span className="block text-xs font-medium text-slate-600 mb-1.5">
              Durée (minutes)
            </span>
            <Input
              type="number"
              value={minutes}
              onChange={(e) => setMinutes(Number(e.target.value))}
              min={1}
              max={240}
            />
          </label>
        )}
      </div>

      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">
          Seuil de réussite (%)
        </span>
        <Input
          type="number"
          value={threshold}
          onChange={(e) => setThreshold(Number(e.target.value))}
          min={0}
          max={100}
        />
      </label>

      {/* ---------- Examen blanc officiel ---------- */}
      <div className="rounded-xl border border-gold-200 bg-gold-50/40 p-4 space-y-3">
        <label className="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            checked={isMock}
            onChange={(e) => setIsMock(e.target.checked)}
            className="h-4 w-4 rounded border-navy-200 text-gold-700"
          />
          <span className="text-sm font-semibold text-navy-900">
            Examen blanc officiel
          </span>
        </label>
        {isMock && (
          <div className="space-y-3 pt-2 pl-6 border-l-2 border-gold-300">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <label className="block">
                <span className="block text-xs font-medium text-slate-600 mb-1.5">
                  Nombre max de tentatives (vide = illimité)
                </span>
                <Input
                  type="number"
                  value={maxAttempts}
                  onChange={(e) =>
                    setMaxAttempts(e.target.value === "" ? "" : Number(e.target.value))
                  }
                  min={1}
                  max={50}
                />
              </label>
              <label className="block">
                <span className="block text-xs font-medium text-slate-600 mb-1.5">
                  Délai entre tentatives (heures)
                </span>
                <Input
                  type="number"
                  value={retakeDelay}
                  onChange={(e) => setRetakeDelay(Number(e.target.value))}
                  min={0}
                  max={720}
                />
              </label>
            </div>

            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={shuffleQ}
                onChange={(e) => setShuffleQ(e.target.checked)}
                className="h-4 w-4 rounded border-navy-200"
              />
              <span className="text-sm text-navy-900">Mélanger les questions</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={shuffleC}
                onChange={(e) => setShuffleC(e.target.checked)}
                className="h-4 w-4 rounded border-navy-200"
              />
              <span className="text-sm text-navy-900">Mélanger les réponses</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={requireFs}
                onChange={(e) => setRequireFs(e.target.checked)}
                className="h-4 w-4 rounded border-navy-200"
              />
              <span className="text-sm text-navy-900">Plein écran obligatoire</span>
            </label>

            <label className="block">
              <span className="block text-xs font-medium text-slate-600 mb-1.5">
                Affichage de la correction
              </span>
              <Select
                value={showExp}
                onChange={(e) =>
                  setShowExp(e.target.value as ShowExplanationsMode)
                }
              >
                <option value="always">Toujours visible</option>
                <option value="after_pass">Seulement si seuil atteint</option>
                <option value="never">Jamais (copie opaque)</option>
              </Select>
            </label>
          </div>
        )}
      </div>

      <div className="pt-2 flex justify-end">
        <Button type="submit" disabled={isPending || !title}>
          <Save className="h-4 w-4" />
          {isPending ? "Enregistrement…" : quiz?.id ? "Enregistrer" : "Créer"}
        </Button>
      </div>
    </form>
  );
}
