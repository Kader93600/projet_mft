import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { formatDate } from "@/lib/utils";
import { Megaphone, Pin, ArrowRight } from "lucide-react";

// Dernières annonces publiées destinées au stagiaire (épinglées d'abord)
export async function AnnouncementBanner() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: anns } = await supabase
    .from("announcements")
    .select("id, title, body_md, published_at, pinned")
    .not("published_at", "is", null)
    .order("pinned", { ascending: false })
    .order("published_at", { ascending: false })
    .limit(3);

  if (!anns || anns.length === 0) return null;

  return (
    <div className="space-y-3">
      {anns.map((a: any, i: number) => {
        const isPinned = a.pinned;
        return (
          <Link
            key={a.id}
            href="/notifications"
            className={
              "block rounded-2xl p-4 shadow-soft hover:shadow-raised transition group border " +
              (isPinned
                ? "bg-gradient-to-r from-gold-50 to-ivory border-gold-200"
                : "bg-white border-navy-100")
            }
          >
            <div className="flex items-start gap-3">
              <div
                className={
                  "h-10 w-10 rounded-xl flex items-center justify-center shrink-0 " +
                  (isPinned
                    ? "bg-gold-100 text-gold-800"
                    : "bg-navy-50 text-navy-700")
                }
              >
                {isPinned ? (
                  <Pin className="h-4 w-4" />
                ) : (
                  <Megaphone className="h-4 w-4" />
                )}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap">
                  {isPinned && (
                    <span className="text-[10px] uppercase tracking-wider font-bold text-gold-700">
                      Épinglée
                    </span>
                  )}
                  <span className="font-display font-semibold text-navy-900 truncate">
                    {a.title}
                  </span>
                </div>
                {a.body_md && (
                  <p className="text-sm text-slate-600 mt-0.5 line-clamp-2">
                    {a.body_md.replace(/[#*`_>-]/g, "").slice(0, 180)}
                  </p>
                )}
                <div className="text-[11px] text-slate-400 mt-1">
                  Publiée {formatDate(a.published_at)}
                </div>
              </div>
              <ArrowRight className="h-4 w-4 text-slate-400 transition-transform group-hover:translate-x-0.5 mt-2" />
            </div>
          </Link>
        );
      })}
    </div>
  );
}
