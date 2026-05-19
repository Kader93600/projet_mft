import Link from "next/link";
import { createAdminClient } from "@/lib/supabase/admin";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, GraduationCap } from "lucide-react";
import { CreateTrainerForm } from "./create-trainer-form";

export const dynamic = "force-dynamic";

export default async function NewTrainerPage() {
  const supabase = createAdminClient();
  const { data: formations } = await supabase
    .from("formations")
    .select("slug, code, title")
    .eq("active", true)
    .order("code");

  return (
    <div className="space-y-6 max-w-3xl">
      <Link
        href="/admin/users"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900 transition"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux utilisateurs
      </Link>

      <header>
        <div className="flex items-center gap-2">
          <GraduationCap className="h-4 w-4 text-brand-700" />
          <span className="eyebrow text-brand-700">Inscription formateur</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Nouveau formateur
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Création d'un compte formateur. Sélectionnez les formations sur
          lesquelles il est habilité (correction des copies, édition du
          contenu). Le formateur reçoit son accès immédiatement.
        </p>
      </header>

      <Card>
        <CardBody>
          <CreateTrainerForm formations={formations ?? []} />
        </CardBody>
      </Card>
    </div>
  );
}
