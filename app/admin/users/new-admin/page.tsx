import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { ArrowLeft, Crown } from "lucide-react";
import { CreateAdminForm } from "./create-admin-form";

export const dynamic = "force-dynamic";

export default async function NewAdminPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Détecte si le user courant est super_admin (pour autoriser la
  // création d'autres super_admin — privilège régalien)
  let currentIsSuperAdmin = false;
  if (user) {
    const { data: me } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    currentIsSuperAdmin = me?.role === "super_admin";
  }

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
          <Crown className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Création administrateur</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Nouvel administrateur
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl leading-relaxed">
          Compte avec accès complet à l'interface admin (utilisateurs,
          inscriptions, formations, CRM, analytics). N'incluez que les
          personnes de confiance — l'audit log trace toutes les actions.
        </p>
      </header>

      <Card>
        <CardBody>
          <CreateAdminForm allowSuperAdmin={currentIsSuperAdmin} />
        </CardBody>
      </Card>
    </div>
  );
}
