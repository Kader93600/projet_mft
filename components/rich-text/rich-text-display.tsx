"use client";

import { useMemo } from "react";
import { isRichTextHtml } from "@/lib/rich-text";
import { sanitizeRichTextClient } from "@/lib/rich-text-client";

/**
 * Affiche un contenu rich-text de manière sécurisée.
 *
 * - Si le contenu est du HTML (produit par TipTap) → sanitize + render
 * - Si c'est du texte brut → render avec sauts de ligne préservés
 *
 * Compatible Server Component : le sanitize est isomorphic et la
 * sanitization est aussi faite côté server avant persist en DB
 * (defense in depth).
 */
export function RichTextDisplay({
  content,
  className,
  /** Si true, force le rendu HTML même sans tags structurels. */
  forceHtml = false,
}: {
  content: string | null | undefined;
  className?: string;
  forceHtml?: boolean;
}) {
  const { isHtml, html, plain } = useMemo(() => {
    if (!content) return { isHtml: false, html: "", plain: "" };
    const detected = forceHtml || isRichTextHtml(content);
    if (detected) {
      return {
        isHtml: true,
        html: sanitizeRichTextClient(content),
        plain: "",
      };
    }
    return { isHtml: false, html: "", plain: content };
  }, [content, forceHtml]);

  if (!content) return null;

  if (isHtml) {
    return (
      <div
        className={"rich-text-prose " + (className ?? "")}
        dangerouslySetInnerHTML={{ __html: html }}
      />
    );
  }

  return (
    <div
      className={
        "whitespace-pre-wrap break-words " + (className ?? "")
      }
    >
      {plain}
    </div>
  );
}
