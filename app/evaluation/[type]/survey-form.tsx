"use client";
import {
  SurveyForm as SharedSurveyForm,
  type SurveyValues,
} from "@/components/survey/survey-form";
import { submitSurvey } from "./actions";

export function SurveyForm({ type }: { type: "chaud" | "froid" }) {
  async function onSubmit(v: SurveyValues) {
    const payload: Record<string, unknown> = {
      type,
      note_globale: v.note_globale,
      note_contenu: v.note_contenu,
      note_pedagogie: v.note_pedagogie,
      note_plateforme: v.note_plateforme,
      note_accompagnement: v.note_accompagnement,
      recommandation: v.recommandation,
      points_forts: v.points_forts || undefined,
      points_ameliorer: v.points_ameliorer || undefined,
    };
    if (type === "froid") {
      payload.situation_pro = v.situation_pro;
      payload.situation_detail = v.situation_detail || undefined;
    }
    await submitSurvey(payload);
  }

  return (
    <SharedSurveyForm
      type={type}
      variant="page"
      onSubmit={onSubmit}
      redirectTo="/dashboard"
    />
  );
}
