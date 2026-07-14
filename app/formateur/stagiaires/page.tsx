import Link from "next/link";
import { ArrowRight, ArrowLeft } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { findFormation } from "@/lib/formations-config";

export const dynamic = "force-dynamic";

export default async function StagiairesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: students } = await supabase
    .from("trainer_my_students")
    .select("*")
    .eq("trainer_id", user.id);

  return (
    <div className="space-y-8">
      <Link
        href="/formateur"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Tableau de bord
      </Link>

      <header>
        <span className="eyebrow text-signal-600">Suivi pédagogique</span>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950">
          Mes stagiaires
        </h1>
      </header>

      <Card>
        <CardBody className="p-0">
          <table className="w-full text-sm">
            <thead className="bg-navy-50 text-[11px] uppercase tracking-wider text-slate-600">
              <tr>
                <th className="text-left px-6 py-3">Stagiaire</th>
                <th className="text-left px-3 py-3">Formation</th>
                <th className="text-right px-3 py-3">Leçons</th>
                <th className="text-right px-3 py-3">Quiz réussis</th>
                <th className="text-right px-6 py-3">Action</th>
              </tr>
            </thead>
            <tbody>
              {(students ?? []).map((s: any) => {
                const f = s.formation_slug ? findFormation(s.formation_slug) : null;
                return (
                  <tr key={s.student_id} className="border-t border-navy-50">
                    <td className="px-6 py-3 font-medium text-navy-900">
                      {s.full_name ?? s.email}
                    </td>
                    <td className="px-3 py-3 text-slate-600">
                      {f ? f.code : "—"}
                    </td>
                    <td className="px-3 py-3 text-right">{s.lessons_done ?? 0}</td>
                    <td className="px-3 py-3 text-right">
                      {s.quizzes_passed ?? 0}
                    </td>
                    <td className="px-6 py-3 text-right">
                      <Link
                        href={`/formateur/stagiaires/${s.student_id}`}
                        className="text-signal-700 hover:text-signal-800 inline-flex items-center gap-1"
                      >
                        Voir <ArrowRight className="h-3 w-3" />
                      </Link>
                    </td>
                  </tr>
                );
              })}
              {(!students || students.length === 0) && (
                <tr>
                  <td colSpan={5} className="p-10 text-center text-sm text-slate-500">
                    Aucun stagiaire affecté.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </CardBody>
      </Card>
    </div>
  );
}
