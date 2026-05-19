import Link from "next/link";
import { createAdminClient } from "@/lib/supabase/admin";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, FileText } from "lucide-react";
import { CreateQrForm } from "./create-qr-form";

export const dynamic = "force-dynamic";

export default async function NewQrPage() {
  const sb = createAdminClient();
  const [{ data: formations }, { data: modules }] = await Promise.all([
    sb
      .from("formations")
      .select("slug, code, title")
      .eq("active", true)
      .order("code"),
    sb.from("modules").select("id, title, slug").order("title"),
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
          <FileText className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Création question</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Nouvelle question rédigée (QR)
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Question ouverte avec rédaction libre du stagiaire et correction
          manuelle par un formateur. La réponse-modèle + le barème
          servent de référence à la correction.
        </p>
      </header>

      <Card>
        <CardBody>
          <CreateQrForm
            formations={formations ?? []}
            modules={(modules ?? []) as any[]}
          />
        </CardBody>
      </Card>
    </div>
  );
}
