import { createClient } from "@/lib/supabase/server";
import { Card, CardBody } from "@/components/ui/card";
import {
  Download,
  ExternalLink,
  FileText,
  Film,
  ImageIcon,
  Link as LinkIcon,
  Paperclip,
} from "lucide-react";

const ICONS: Record<string, any> = {
  pdf: FileText,
  video: Film,
  link: LinkIcon,
  doc: FileText,
  image: ImageIcon,
};

const LABELS: Record<string, string> = {
  pdf: "PDF",
  video: "Vidéo",
  link: "Lien",
  doc: "Document",
  image: "Image",
};

function formatSize(kb?: number | null) {
  if (!kb) return null;
  if (kb < 1024) return `${kb} Ko`;
  return `${(kb / 1024).toFixed(1)} Mo`;
}

export async function LessonResources({ lessonId }: { lessonId: string }) {
  const supabase = await createClient();
  const { data } = await supabase
    .from("lesson_resources")
    .select("*")
    .eq("lesson_id", lessonId)
    .order("order");

  if (!data || data.length === 0) return null;

  return (
    <Card>
      <CardBody>
        <div className="flex items-center gap-2 mb-4">
          <Paperclip className="h-4 w-4 text-navy-700" />
          <span className="eyebrow text-navy-700">Ressources</span>
        </div>
        <ul className="space-y-2">
          {data.map((r: any) => {
            const Icon = ICONS[r.kind] ?? LinkIcon;
            const size = formatSize(r.size_kb);
            const external = r.kind === "link" || r.kind === "video";
            return (
              <li key={r.id}>
                <a
                  href={r.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="group flex items-start gap-3 p-3 rounded-xl border border-navy-100 hover:bg-navy-50 transition"
                >
                  <div className="h-9 w-9 rounded-lg bg-gold-50 text-gold-800 flex items-center justify-center shrink-0">
                    <Icon className="h-4 w-4" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-medium text-navy-900 text-sm">
                        {r.title}
                      </span>
                      <span className="text-[10px] uppercase tracking-wider font-semibold text-slate-500">
                        {LABELS[r.kind] ?? r.kind}
                      </span>
                      {size && (
                        <span className="text-[10px] text-slate-400">· {size}</span>
                      )}
                    </div>
                    {r.description && (
                      <p className="text-xs text-slate-600 mt-0.5 line-clamp-2">
                        {r.description}
                      </p>
                    )}
                  </div>
                  {external ? (
                    <ExternalLink className="h-4 w-4 text-slate-400 group-hover:text-navy-700 mt-1" />
                  ) : (
                    <Download className="h-4 w-4 text-slate-400 group-hover:text-navy-700 mt-1" />
                  )}
                </a>
              </li>
            );
          })}
        </ul>
      </CardBody>
    </Card>
  );
}
