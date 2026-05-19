import Link from "next/link";
import { createAdminClient } from "@/lib/supabase/admin";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, CheckSquare } from "lucide-react";
import { CreateQcmForm } from "./create-qcm-form";

export const dynamic = "force-dynamic";

export default async function NewQcmPage() {
  const sb = createAdminClient();
  const [{ data: formations }, { data: modules }] = await Promise.all([
    sb
      .from("formations")
      .select("slug, code, title")
      .eq("active", true)
      .order("code"),
    sb
      .from("modules")
      .select("id, title, slug, bloc_id, formation_modules(formation_id)")
      .order("title"),
  ]);

  return (
    <div className="space-y-6 max-w-4xl">
      <Link
        href="/admin/banque-questions"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900 transition"
      >
        <ArrowLeft className="h-4 w-4" /> Retour à la banque
      </Link>

      <header>
        <div className="flex items-center gap-2">
          <CheckSquare className="h-4 w-4 text-brand-700" />
          <span className="eyebrow text-brand-700">Création question</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Nouveau QCM
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Question à choix multiples avec correction automatique. Au moins
          1 bonne réponse doit être cochée pour que la question soit
          validée et utilisable dans les quiz / examens blancs.
        </p>
      </header>

      <Card>
        <CardBody>
          <CreateQcmForm
            formations={formations ?? []}
            modules={(modules ?? []) as any[]}
          />
        </CardBody>
      </Card>
    </div>
  );
}
