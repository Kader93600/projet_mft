"use client";
import Link from "next/link";
import { Lightbulb, ArrowRight } from "lucide-react";

export function StaticQuizForm({
  initialFormation,
}: {
  initialFormation?: string;
}) {
  return (
    <div className="space-y-5">
      <div className="rounded-2xl border border-amber-200 bg-amber-50 p-5">
        <div className="flex items-start gap-3">
          <Lightbulb className="h-5 w-5 text-amber-700 mt-0.5 shrink-0" />
          <div className="flex-1">
            <h3 className="font-display font-semibold text-navy-900">
              Mode sélection manuelle — bientôt disponible
            </h3>
            <p className="mt-1 text-sm text-slate-700">
              Pour composer manuellement un examen blanc fixe (cocher les
              questions une à une dans la liste), une interface dédiée est en
              cours de finalisation.
            </p>
            <p className="mt-2 text-sm text-slate-700">
              <strong>En attendant</strong>, vous pouvez :
            </p>
            <ul className="mt-2 space-y-1 text-sm text-slate-700">
              <li>• Utiliser le <strong>mode aléatoire</strong> pour générer des entraînements</li>
              <li>
                • Composer manuellement via SQL en insérant directement dans{" "}
                <code className="text-xs bg-white px-1 py-0.5 rounded">
                  quiz_question_bank
                </code>
              </li>
            </ul>
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-3">
        <Link
          href={`/admin/banque-questions/creer-quiz?mode=random${
            initialFormation ? `&f=${initialFormation}` : ""
          }`}
          className="inline-flex items-center gap-1.5 rounded-xl bg-signal-500 text-night px-4 py-2.5 text-sm font-semibold hover:bg-signal-400"
        >
          Passer en mode aléatoire
          <ArrowRight className="h-4 w-4" />
        </Link>
        <Link
          href="/admin/banque-questions/liste"
          className="inline-flex items-center gap-1.5 rounded-xl border border-navy-200 px-4 py-2.5 text-sm font-medium text-navy-900 hover:bg-navy-50"
        >
          Parcourir la banque
        </Link>
      </div>
    </div>
  );
}
