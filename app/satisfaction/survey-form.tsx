"use client";
import {
  SurveyForm as SharedSurveyForm,
  type SurveyValues,
} from "@/components/survey/survey-form";
import { submitSurvey } from "./actions";

export function SurveyForm({ type }: { type: "chaud" | "froid" }) {
  async function onSubmit(v: SurveyValues) {
    const fd = new FormData();
    // Une note non renseignée (0) doit rester vide → num() la traduit en null,
    // ce qui préserve la tolérance du hub (seules note_globale + NPS requises).
    fd.set("note_globale", v.note_globale ? String(v.note_globale) : "");
    fd.set("note_contenu", v.note_contenu ? String(v.note_contenu) : "");
    fd.set("note_pedagogie", v.note_pedagogie ? String(v.note_pedagogie) : "");
    fd.set("note_plateforme", v.note_plateforme ? String(v.note_plateforme) : "");
    fd.set(
      "note_accompagnement",
      v.note_accompagnement ? String(v.note_accompagnement) : "",
    );
    // NPS 0 est valide → tester le null, pas la falsy-ness.
    fd.set("recommandation", v.recommandation != null ? String(v.recommandation) : "");
    fd.set("points_forts", v.points_forts);
    fd.set("points_ameliorer", v.points_ameliorer);
    fd.set("situation_pro", v.situation_pro);
    fd.set("situation_detail", v.situation_detail);
    await submitSurvey(type, fd);
  }

  return <SharedSurveyForm type={type} variant="hub" onSubmit={onSubmit} />;
}
