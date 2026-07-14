import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ScrollText, Download, Award } from "lucide-react";

export default async function CertificatesPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return null;

  const [{ data: certs }, { data: blocs }] = await Promise.all([
    supabase
      .from("certificates")
      .select("*")
      .eq("user_id", user.id)
      .is("revoked_at", null)
      .order("issued_at", { ascending: false }),
    supabase.from("blocs").select("id, code, title").order("order"),
  ]);

  const blocMap = new Map((blocs || []).map((b: any) => [b.id, b]));

  return (
    <div className="space-y-8">
      <header>
        <span className="eyebrow text-gold-700">Validations officielles</span>
        <h1 className="mt-2 font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight">
          Vos certificats
        </h1>
        <p className="mt-2 text-slate-600 max-w-2xl">
          Chaque bloc de compétence validé donne lieu à une attestation
          nominative. Le certificat final est délivré lorsque tous les blocs
          sont acquis.
        </p>
      </header>

      {(!certs || certs.length === 0) ? (
        <Card>
          <CardBody className="py-10 text-center space-y-3">
            <div className="mx-auto h-14 w-14 rounded-xl bg-ivory border border-navy-100 flex items-center justify-center">
              <ScrollText className="h-7 w-7 text-slate-400" />
            </div>
            <p className="text-sm text-slate-600 max-w-md mx-auto">
              Aucun certificat pour l'instant. Validez l'ensemble des leçons
              d'un bloc et réussissez au moins un quiz associé pour débloquer
              votre première attestation.
            </p>
          </CardBody>
        </Card>
      ) : (
        <div className="grid md:grid-cols-2 gap-4">
          {certs.map((c: any) => {
            const isFinal = c.type === "final";
            const bloc = c.bloc_id ? blocMap.get(c.bloc_id) : null;
            return (
              <Card key={c.id} variant={isFinal ? "gold" : "default"}>
                <CardBody className="flex flex-col gap-3">
                  <div className="flex items-center justify-between">
                    <Badge tone={isFinal ? "gold" : "navy"} size="sm">
                      {isFinal ? (
                        <>
                          <Award className="h-3 w-3" /> Certificat final
                        </>
                      ) : (
                        <>
                          <ScrollText className="h-3 w-3" /> Attestation de bloc
                        </>
                      )}
                    </Badge>
                    <span className="text-[11px] text-slate-500">
                      {new Date(c.issued_at).toLocaleDateString("fr-FR", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                    </span>
                  </div>
                  <div>
                    <div className="font-display text-lg font-semibold text-navy-900 leading-tight">
                      {isFinal
                        ? "Titre professionnel GOTRM (RNCP 40990)"
                        : `${bloc?.code ?? ""} — ${bloc?.title ?? "Bloc"}`}
                    </div>
                    <div className="mt-1 text-[11px] font-mono text-slate-500">
                      {c.serial}
                    </div>
                  </div>
                  <div className="pt-2">
                    <a
                      href={`/api/certificate/${c.id}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 text-sm font-medium text-navy-900 hover:text-gold-700 transition-colors"
                    >
                      <Download className="h-4 w-4" />
                      Télécharger le PDF
                    </a>
                  </div>
                </CardBody>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
