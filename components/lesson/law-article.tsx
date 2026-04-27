import { Scale, ExternalLink } from "lucide-react";

interface Props {
  code: string; // ex : "Code des transports"
  article: string; // ex : "L. 3261-1"
  href?: string; // lien Légifrance
  children: React.ReactNode; // citation
  date?: string; // version applicable
}

export function LawArticle({ code, article, href, children, date }: Props) {
  return (
    <figure className="my-6 rounded-2xl border border-slate-300 bg-slate-50 p-5">
      <figcaption className="flex items-center justify-between gap-3 mb-3">
        <div className="flex items-center gap-2 text-slate-700">
          <Scale className="h-4 w-4" />
          <div>
            <div className="text-[11px] uppercase tracking-wider font-semibold">
              {code}
            </div>
            <div className="font-display font-semibold text-navy-900">
              Article {article}
              {date && (
                <span className="ml-2 text-xs font-normal text-slate-500">
                  (en vigueur au {date})
                </span>
              )}
            </div>
          </div>
        </div>
        {href && (
          <a
            href={href}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 text-xs text-navy-900 hover:text-gold-700 font-medium"
          >
            Légifrance <ExternalLink className="h-3 w-3" />
          </a>
        )}
      </figcaption>
      <blockquote className="text-sm text-slate-800 italic leading-relaxed border-l-2 border-slate-400 pl-4">
        {children}
      </blockquote>
    </figure>
  );
}
