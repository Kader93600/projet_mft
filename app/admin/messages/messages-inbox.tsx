"use client";
import { MessageThread } from "@/components/message-thread";

export function MessagesInbox({
  conversationId,
  messages,
  adminId,
}: {
  conversationId: string;
  messages: any[];
  adminId: string;
}) {
  return (
    <MessageThread
      conversationId={conversationId}
      messages={messages}
      viewerRole="admin"
      viewerId={adminId}
    />
  );
}
