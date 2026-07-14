import { redirect } from "next/navigation";

/**
 * Compat URL legacy : les anciennes notifications pointent vers
 * /formateur/messages/[conversationId]. On les redirige vers la
 * nouvelle structure /formateur/messages?c=...
 */
export default async function LegacyTrainerThreadPage(
  props: {
    params: Promise<{ conversationId: string }>;
  }
) {
  const params = await props.params;
  redirect(`/formateur/messages?c=${params.conversationId}`);
}
