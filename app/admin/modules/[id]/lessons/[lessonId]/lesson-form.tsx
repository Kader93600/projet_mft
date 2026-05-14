"use client";
import { useState, useTransition } from "react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { Save, Trash2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { MarkdownEditor } from "@/components/markdown-editor";
import { RichTextEditor } from "@/components/rich-text/rich-text-editor";
import { isRichTextHtml } from "@/lib/rich-text";
import { ImageUploader } from "@/components/admin/image-uploader";
import {
  createLesson,
  updateLesson,
  deleteLesson,
} from "../../../actions";

export function LessonForm({
  moduleId,
  lesson,
}: {
  moduleId: string;
  lesson?: any;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  const [title, setTitle] = useState(lesson?.title ?? "");
  const [slug, setSlug] = useState(lesson?.slug ?? "");
  const [order, setOrder] = useState<number>(lesson?.order ?? 0);
  const [content, setContent] = useState(lesson?.content_md ?? "");
  const [summary, setSummary] = useState(lesson?.summary_md ?? "");
  // Choix d'éditeur fixé au mount pour ne pas switch quand l'utilisateur
  // efface tout : si la leçon EST en HTML rich (ou nouvelle), on utilise
  // RichTextEditor partout ; si c'est markdown legacy, on garde
  // MarkdownEditor (rétrocompat avec lib/markdown.ts côté stagiaire).
  const [useRichEditor] = useState<boolean>(
    () => !lesson?.content_md || isRichTextHtml(lesson.content_md),
  );
  const [useRichSummary] = useState<boolean>(
    () => !lesson?.summary_md || isRichTextHtml(lesson.summary_md),
  );
  const [coverUrl, setCoverUrl] = useState(lesson?.cover_url ?? "");
  const [videoUrl, setVideoUrl] = useState(lesson?.video_url ?? "");

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    startTransition(async () => {
      try {
        if (lesson?.id) {
          await updateLesson(lesson.id, moduleId, {
            title,
            slug: slug || undefined,
            content_md: content,
            summary_md: summary || null,
            order,
            cover_url: coverUrl || null,
            video_url: videoUrl || null,
          });
          toast("Leçon enregistrée", "success");
          router.refresh();
        } else {
          await createLesson({
            module_id: moduleId,
            title,
            slug: slug || undefined,
            content_md: content,
            summary_md: summary || undefined,
            order,
            cover_url: coverUrl || null,
            video_url: videoUrl || null,
          });
        }
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onDelete() {
    if (!lesson?.id) return;
    if (!confirm("Supprimer cette leçon ?")) return;
    startTransition(async () => {
      try {
        await deleteLesson(lesson.id, moduleId);
        toast("Leçon supprimée", "success");
        router.push(`/admin/modules/${moduleId}`);
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <form onSubmit={onSubmit} className="space-y-5">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <label className="block md:col-span-2">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">Titre</span>
          <Input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            placeholder="Ex. Les temps de conduite"
          />
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">Ordre</span>
          <Input
            type="number"
            value={order}
            onChange={(e) => setOrder(Number(e.target.value))}
          />
        </label>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Slug <span className="text-slate-400">(auto si vide)</span>
          </span>
          <Input
            value={slug}
            onChange={(e) => setSlug(e.target.value)}
            placeholder="temps-de-conduite"
          />
        </label>
        <div className="md:col-span-2">
          <ImageUploader
            value={coverUrl}
            onChange={(url) => setCoverUrl(url ?? "")}
            prefix={`lessons/${lesson?.id ?? "new"}/cover`}
            label="Image de couverture (optionnel)"
            ratio="wide"
            hint="PNG, JPG, WebP — 5 Mo max."
          />
        </div>
      </div>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">
          Vidéo d'introduction <span className="text-slate-400">(YouTube, Vimeo, MP4 direct)</span>
        </span>
        <Input
          value={videoUrl}
          onChange={(e) => setVideoUrl(e.target.value)}
          placeholder="https://www.youtube.com/watch?v=…"
        />
      </label>

      <div>
        <div className="text-xs font-medium text-slate-600 mb-1.5 flex items-center justify-between gap-2 flex-wrap">
          <span>Contenu détaillé</span>
          <span className="text-[11px] text-slate-400 font-normal">
            Éditeur riche WYSIWYG · le contenu HTML est rendu directement
          </span>
        </div>
        {useRichEditor ? (
          <RichTextEditor
            value={content}
            onChange={setContent}
            placeholder="Rédigez le cours — titres, listes, tableaux, images, encadrés…"
            minHeight={400}
          />
        ) : (
          // Contenu legacy en markdown pur (cours du seed initial) :
          // on garde l'éditeur markdown existant pour ne pas casser
          // le rendu côté stagiaire qui utilise lib/markdown.ts.
          <MarkdownEditor
            value={content}
            onChange={setContent}
            rows={22}
            placeholder="# Titre&#10;&#10;Rédigez le cours en markdown…"
          />
        )}
      </div>

      <div>
        <div className="text-xs font-medium text-slate-600 mb-1.5">
          Fiche de synthèse <span className="text-slate-400">(optionnel)</span>
        </div>
        {useRichSummary ? (
          <RichTextEditor
            value={summary}
            onChange={setSummary}
            placeholder="Résumé, points clés, à retenir…"
            minHeight={180}
          />
        ) : (
          <MarkdownEditor
            value={summary}
            onChange={setSummary}
            rows={10}
            placeholder="Résumé, points clés, à retenir…"
          />
        )}
      </div>

      <div className="pt-2 flex items-center justify-between">
        {lesson?.id ? (
          <Button
            type="button"
            variant="danger"
            size="sm"
            onClick={onDelete}
            disabled={isPending}
          >
            <Trash2 className="h-4 w-4" /> Supprimer la leçon
          </Button>
        ) : (
          <span />
        )}
        <Button type="submit" disabled={isPending || !title}>
          <Save className="h-4 w-4" />
          {isPending ? "Enregistrement…" : lesson?.id ? "Enregistrer" : "Créer"}
        </Button>
      </div>
    </form>
  );
}
