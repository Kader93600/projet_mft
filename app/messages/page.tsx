import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import { MessageThread } from "@/components/message-thread";
import { MessageCircle } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function MessagesPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  // Créer la conversation si elle n'existe pas
  const { data: convId } = await supabase.rpc("get_or_create_my_conversation");

  const { data: messages } = await supabase
    .from("messages")
    .select("*")
    .eq("conversation_id", convId)
    .order("created_at");

  // Marquer les messages admin comme lus
  if (convId) {
    await supabase.rpc("mark_conversation_read", { p_conversation_id: convId });
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <header>
        <div className="flex items-center gap-2">
          <MessageCircle className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Support & accompagnement</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Messagerie
        </h1>
        <p className="mt-2 text-slate-600">
          Échangez directement avec l'équipe pédagogique. Nous vous répondons en
          général sous 24h ouvrés.
        </p>
      </header>

      <Card className="overflow-hidden">
        <MessageThread
          conversationId={convId as string}
          messages={(messages ?? []) as any[]}
          viewerRole="student"
          viewerId={user.id}
        />
      </Card>
    </div>
  );
}
