import { createClient } from "@/lib/supabase/server";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { ModuleForm } from "../module-form";

export const dynamic = "force-dynamic";

export default async function NewModulePage() {
  const supabase = createClient();
  const { data: blocs } = await supabase.from("blocs").select("*").order("id");

  return (
    <div className="space-y-6 max-w-3xl">
      <Link
        href="/admin/modules"
        className="inline-flex items-center gap-1.5 text-sm text-slate-600 hover:text-navy-900"
      >
        <ArrowLeft className="h-4 w-4" /> Retour aux modules
      </Link>
      <Card>
        <div className="px-6 pt-5 pb-3 border-b border-navy-50">
          <CardTitle>Nouveau module</CardTitle>
        </div>
        <CardBody>
          <ModuleForm blocs={blocs ?? []} />
        </CardBody>
      </Card>
    </div>
  );
}
