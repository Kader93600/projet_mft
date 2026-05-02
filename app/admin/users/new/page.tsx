import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, UserPlus } from "lucide-react";
import { CreateStudentForm } from "./create-student-form";

export const dynamic = "force-dynamic";

export default async function NewStudentPage() {
  const supabase = createClient();

  const [{ data: formations }, { data: staff }, { data: trainers }, { data: funders }] =
    await Promise.all([
      supabase
        .from("formations")
        .select("slug, code, title")
        .eq("active", true)
        .order("code"),
      // Référents pédagogiques = admin / super_admin
      supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .in("role", ["admin", "super_admin"])
        .eq("disabled", false)
        .order("full_name"),
      // Formateurs = trainer
      supabase
        .from("profiles")
        .select("id, full_name, email, role")
        .eq("role", "trainer")
        .eq("disabled", false)
        .order("full_name"),
      supabase.from("funders").select("id, name, kind").order("name"),
    ]);

  return (
    <div className="space-y-6 max-w-5xl">
      <Link
        href="/admin/users"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900 transition"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux utilisateurs
      </Link>

      <header>
        <div className="flex items-center gap-2">
          <UserPlus className="h-4 w-4 text-signal-700" />
          <span className="eyebrow text-signal-700">Inscription stagiaire</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Nouveau stagiaire
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Création d'un compte stagiaire avec ses informations personnelles,
          pédagogiques et administratives. L'accès est créé immédiatement —
          choisissez l'envoi d'un email d'invitation ou un mot de passe initial.
        </p>
      </header>

      <Card>
        <CardBody>
          <CreateStudentForm
            formations={formations ?? []}
            staff={staff ?? []}
            trainers={trainers ?? []}
            funders={funders ?? []}
          />
        </CardBody>
      </Card>
    </div>
  );
}
