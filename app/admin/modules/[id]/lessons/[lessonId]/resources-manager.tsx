"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Plus, Save, Trash2, Loader2, GripVertical } from "lucide-react";
import {
  createLessonResource,
  updateLessonResource,
  deleteLessonResource,
} from "../../../actions";

import type { Tables } from "@/lib/database.types";

/** Sous-ensemble éditable d'une ligne `lesson_resources`. */
type Resource = Pick<
  Tables<"lesson_resources">,
  | "id"
  | "lesson_id"
  | "kind"
  | "title"
  | "url"
  | "description"
  | "size_kb"
  | "order"
>;

/** Message d'erreur lisible depuis une exception d'action serveur. */
function errorMessage(e: unknown): string {
  return e instanceof Error ? e.message : String(e);
}

export function ResourcesManager({
  lessonId,
  initial,
}: {
  lessonId: string;
  initial: Resource[];
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [items, setItems] = useState<Resource[]>(initial);
  const [error, setError] = useState<string | null>(null);

  // New form
  const [nKind, setNKind] = useState("pdf");
  const [nTitle, setNTitle] = useState("");
  const [nUrl, setNUrl] = useState("");
  const [nDesc, setNDesc] = useState("");
  const [nSize, setNSize] = useState<number | "">("");

  function add() {
    setError(null);
    start(async () => {
      try {
        const payload: Omit<Resource, "id"> = {
          lesson_id: lessonId,
          kind: nKind,
          title: nTitle,
          url: nUrl,
          description: nDesc || null,
          size_kb: nSize === "" ? null : Number(nSize),
          order: items.length,
        };
        const { id } = await createLessonResource(payload);
        setItems([
          ...items,
          { id, ...payload, description: payload.description, size_kb: payload.size_kb },
        ]);
        setNTitle("");
        setNUrl("");
        setNDesc("");
        setNSize("");
        router.refresh();
      } catch (e) {
        setError(errorMessage(e));
      }
    });
  }

  function save(r: Resource) {
    setError(null);
    start(async () => {
      try {
        await updateLessonResource({
          id: r.id,
          lesson_id: r.lesson_id,
          kind: r.kind,
          title: r.title,
          url: r.url,
          description: r.description,
          size_kb: r.size_kb,
          order: r.order,
        });
        router.refresh();
      } catch (e) {
        setError(errorMessage(e));
      }
    });
  }

  function remove(id: string) {
    if (!confirm("Supprimer cette ressource ?")) return;
    start(async () => {
      try {
        await deleteLessonResource(id);
        setItems(items.filter((x) => x.id !== id));
        router.refresh();
      } catch (e) {
        setError(errorMessage(e));
      }
    });
  }

  function update(id: string, patch: Partial<Resource>) {
    setItems(items.map((x) => (x.id === id ? { ...x, ...patch } : x)));
  }

  return (
    <div className="space-y-4">
      {error && (
        <p className="text-sm text-rose-700 bg-rose-50 border border-rose-200 px-3 py-2 rounded-lg">
          {error}
        </p>
      )}

      {items.length > 0 && (
        <div className="space-y-3">
          {items.map((r) => (
            <div
              key={r.id}
              className="rounded-xl border border-navy-100 p-3 bg-white space-y-2"
            >
              <div className="flex items-start gap-2">
                <GripVertical className="h-4 w-4 text-slate-300 mt-3" />
                <div className="flex-1 grid md:grid-cols-4 gap-2">
                  <Select
                    value={r.kind}
                    onChange={(e) => update(r.id, { kind: e.target.value })}
                  >
                    <option value="pdf">PDF</option>
                    <option value="doc">Document</option>
                    <option value="video">Vidéo</option>
                    <option value="link">Lien</option>
                    <option value="image">Image</option>
                  </Select>
                  <Input
                    className="md:col-span-3"
                    value={r.title}
                    onChange={(e) => update(r.id, { title: e.target.value })}
                    placeholder="Titre affiché"
                  />
                  <Input
                    className="md:col-span-3"
                    value={r.url}
                    onChange={(e) => update(r.id, { url: e.target.value })}
                    placeholder="https://…"
                  />
                  <Input
                    type="number"
                    value={r.size_kb ?? ""}
                    onChange={(e) =>
                      update(r.id, {
                        size_kb: e.target.value === "" ? null : Number(e.target.value),
                      })
                    }
                    placeholder="Ko"
                  />
                  <Input
                    className="md:col-span-4"
                    value={r.description ?? ""}
                    onChange={(e) => update(r.id, { description: e.target.value })}
                    placeholder="Description (optionnel)"
                  />
                </div>
              </div>
              <div className="flex items-center justify-end gap-2">
                <Button
                  type="button"
                  variant="secondary"
                  size="sm"
                  onClick={() => save(r)}
                  disabled={pending}
                >
                  {pending ? (
                    <Loader2 className="h-3.5 w-3.5 animate-spin" />
                  ) : (
                    <Save className="h-3.5 w-3.5" />
                  )}
                  Enregistrer
                </Button>
                <Button
                  type="button"
                  variant="secondary"
                  size="sm"
                  onClick={() => remove(r.id)}
                  disabled={pending}
                  className="text-rose-700 hover:bg-rose-50"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Nouvelle ressource */}
      <div className="rounded-xl border border-dashed border-navy-200 p-3 space-y-2 bg-ivory/40">
        <div className="eyebrow text-gold-700">Ajouter une ressource</div>
        <div className="grid md:grid-cols-4 gap-2">
          <Select value={nKind} onChange={(e) => setNKind(e.target.value)}>
            <option value="pdf">PDF</option>
            <option value="doc">Document</option>
            <option value="video">Vidéo</option>
            <option value="link">Lien</option>
            <option value="image">Image</option>
          </Select>
          <Input
            className="md:col-span-3"
            value={nTitle}
            onChange={(e) => setNTitle(e.target.value)}
            placeholder="Titre affiché"
          />
          <Input
            className="md:col-span-3"
            value={nUrl}
            onChange={(e) => setNUrl(e.target.value)}
            placeholder="https://…"
          />
          <Input
            type="number"
            value={nSize}
            onChange={(e) => setNSize(e.target.value === "" ? "" : Number(e.target.value))}
            placeholder="Ko"
          />
          <Textarea
            className="md:col-span-4 min-h-[60px]"
            rows={2}
            value={nDesc}
            onChange={(e) => setNDesc(e.target.value)}
            placeholder="Description (optionnel)"
          />
        </div>
        <div className="flex justify-end">
          <Button
            type="button"
            variant="gold"
            size="sm"
            onClick={add}
            disabled={pending || !nTitle || !nUrl}
          >
            {pending ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <Plus className="h-3.5 w-3.5" />
            )}
            Ajouter
          </Button>
        </div>
      </div>
    </div>
  );
}
