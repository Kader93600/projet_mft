"use client";

// =====================================================================
// Bulle de message dans la conversation IA tuteur.
//
// Side user → bulle navy alignée à droite, texte blanc.
// Side assistant → bulle ivory avec markdown rendu + citations cliquables.
//
// Skeleton "..." pendant le streaming si pas encore de texte.
// =====================================================================

import { useState } from "react";
import Link from "next/link";
import { ChevronDown, ChevronUp, Sparkles, User } from "lucide-react";
import { renderMarkdown } from "@/lib/markdown";
import { cn } from "@/lib/utils";
import type { TutorCitation, TutorMessage as TMsg } from "@/hooks/use-tutor";

export function TutorMessage({ message }: { message: TMsg }) {
  const isUser = message.role === "user";
  const [showCitations, setShowCitations] = useState(false);

  if (isUser) {
    return (
      <div className="flex items-start gap-2 justify-end">
        <div className="max-w-[80%] rounded-2xl rounded-tr-md bg-navy-900 text-white px-3.5 py-2.5 text-sm leading-relaxed shadow-soft">
          {message.content}
        </div>
        <div className="h-7 w-7 rounded-full bg-navy-100 text-navy-700 flex items-center justify-center shrink-0 mt-0.5">
          <User className="h-3.5 w-3.5" />
        </div>
      </div>
    );
  }

  // Assistant
  const hasCitations =
    Array.isArray(message.citations) && message.citations.length > 0;

  return (
    <div className="flex items-start gap-2">
      <div className="h-7 w-7 rounded-full bg-gold-500 text-navy-900 flex items-center justify-center shrink-0 mt-0.5">
        <Sparkles className="h-3.5 w-3.5" />
      </div>

      <div className="max-w-[85%] flex-1 min-w-0">
        <div
          className={cn(
            "rounded-2xl rounded-tl-md bg-white border border-navy-100 px-3.5 py-2.5",
            "text-sm leading-relaxed text-navy-900 shadow-soft"
          )}
        >
          {message.content === "" && message.streaming ? (
            <span className="inline-flex items-center gap-0.5 text-slate-400">
              <span className="h-1.5 w-1.5 rounded-full bg-slate-400 animate-pulse" />
              <span
                className="h-1.5 w-1.5 rounded-full bg-slate-400 animate-pulse"
                style={{ animationDelay: "150ms" }}
              />
              <span
                className="h-1.5 w-1.5 rounded-full bg-slate-400 animate-pulse"
                style={{ animationDelay: "300ms" }}
              />
            </span>
          ) : (
            <div
              className="prose-tutor"
              dangerouslySetInnerHTML={{
                __html: renderMarkdown(message.content),
              }}
            />
          )}

          {message.streaming && message.content !== "" && (
            <span
              className="inline-block ml-0.5 h-3.5 w-1.5 bg-gold-500 animate-pulse align-middle"
              aria-hidden
            />
          )}
        </div>

        {hasCitations && !message.streaming && (
          <div className="mt-1.5">
            <button
              type="button"
              onClick={() => setShowCitations((v) => !v)}
              className="inline-flex items-center gap-1 text-[11px] font-medium text-slate-500 hover:text-navy-900 transition-colors"
            >
              {showCitations ? (
                <>
                  <ChevronUp className="h-3 w-3" />
                  Masquer les sources
                </>
              ) : (
                <>
                  <ChevronDown className="h-3 w-3" />
                  {message.citations!.length} source
                  {message.citations!.length > 1 ? "s" : ""}
                </>
              )}
            </button>
            {showCitations && (
              <ul className="mt-2 space-y-1.5">
                {message.citations!.map((c) => (
                  <CitationItem key={c.chunk_id} citation={c} />
                ))}
              </ul>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

function CitationItem({ citation }: { citation: TutorCitation }) {
  const pct = Math.round(citation.similarity * 100);
  return (
    <li className="rounded-lg bg-ivory border border-navy-50 px-2.5 py-2 text-[12px]">
      <div className="flex items-center justify-between gap-2 mb-1">
        <Link
          href={`/modules/${citation.module_slug}`}
          className="font-medium text-navy-900 hover:text-gold-700 transition-colors truncate"
        >
          {citation.lesson_title}
        </Link>
        <span className="shrink-0 text-[10px] text-gold-700 font-medium tabular-nums">
          {pct}%
        </span>
      </div>
      <p className="text-slate-600 line-clamp-2 leading-snug">
        {citation.snippet}…
      </p>
    </li>
  );
}
