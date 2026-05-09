import { redirect } from "next/navigation";

/**
 * Compat URL legacy : les anciennes notifications pointent vers
 * /formateur/messages/[conversationId]. On les redirige vers la
 * nouvelle structure /formateur/messages?c=...
 */
export default function LegacyTrainerThreadPage({
  params,
}: {
  params: { conversationId: string };
}) {
  redirect(`/formateur/messages?c=${params.conversationId}`);
}
