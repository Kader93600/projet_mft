import { redirect } from "next/navigation";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft } from "lucide-react";
import { isStaff } from "@/lib/permissions";
import { CreateOrgForm } from "./create-form";

export const dynamic = "force-dynamic";

export default async function NewOrgPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (!profile?.role || !isStaff(profile.role)) redirect("/dashboard");

  return (
    <div className="space-y-8 max-w-2xl">
      <div>
        <Link
          href="/admin/organizations"
          className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
        >
          <ArrowLeft className="h-4 w-4" /> Toutes les organisations
        </Link>
      </div>

      <header>
        <span className="eyebrow text-gold-700">Admin entreprises</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Nouvelle organisation
        </h1>
        <p className="mt-2 text-slate-600">
          Crée une entreprise cliente B2B. Le contact principal devient
          automatiquement org_admin et pourra ensuite ajouter des stagiaires.
        </p>
      </header>

      <Card>
        <CardBody>
          <CreateOrgForm />
        </CardBody>
      </Card>
    </div>
  );
}
