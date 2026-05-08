"use client";
import { useState, useTransition } from "react";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { Save } from "lucide-react";
import { useRouter } from "next/navigation";
import { createModule, updateModule } from "./actions";
import { ImageUploader } from "@/components/admin/image-uploader";

interface Bloc {
  id: number;
  code: string;
  title: string;
}

interface FormationOpt {
  slug: string;
  code: string;
  title: string;
}

export function ModuleForm({
  blocs,
  formations,
  module,
  initialFormationSlug,
}: {
  blocs: Bloc[];
  formations: FormationOpt[];
  module?: any;
  initialFormationSlug?: string | null;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [title, setTitle] = useState(module?.title ?? "");
  const [slug, setSlug] = useState(module?.slug ?? "");
  const [blocId, setBlocId] = useState<number>(module?.bloc_id ?? blocs[0]?.id ?? 1);
  const [summary, setSummary] = useState(module?.summary ?? "");
  const [difficulty, setDifficulty] = useState<
    "debutant" | "intermediaire" | "avance"
  >(module?.difficulty ?? "debutant");
  const [duration, setDuration] = useState<number>(module?.duration_min ?? 30);
  const [order, setOrder] = useState<number>(module?.order ?? 0);
  const [coverUrl, setCoverUrl] = useState(module?.cover_url ?? "");
  const [formationSlug, setFormationSlug] = useState<string>(
    initialFormationSlug ?? formations[0]?.slug ?? ""
  );

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formationSlug) {
      toast("Sélectionnez la formation associée", "error");
      return;
    }
    startTransition(async () => {
      try {
        if (module?.id) {
          await updateModule(module.id, {
            title,
            slug: slug || undefined,
            bloc_id: blocId,
            formation_slug: formationSlug,
            summary: summary || null,
            difficulty,
            duration_min: duration,
            order,
            cover_url: coverUrl || null,
          });
          toast("Cours mis à jour", "success");
          router.refresh();
        } else {
          await createModule({
            title,
            slug: slug || undefined,
            bloc_id: blocId,
            formation_slug: formationSlug,
            summary: summary || undefined,
            difficulty,
            duration_min: duration,
            order,
            cover_url: coverUrl || null,
          });
        }
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">
          Formation associée <span className="text-rose-600">*</span>
        </span>
        <Select
          value={formationSlug}
          onChange={(e) => setFormationSlug(e.target.value)}
          required
        >
          <option value="">— Sélectionner une formation —</option>
          {formations.map((f) => (
            <option key={f.slug} value={f.slug}>
              {f.code} — {f.title}
            </option>
          ))}
        </Select>
        <span className="mt-1 block text-[11px] text-slate-500">
          Le module sera rattaché à cette formation et apparaîtra dans son
          parcours pédagogique.
        </span>
      </label>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">Titre</span>
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          required
          placeholder="Ex. Législation du transport routier"
        />
      </label>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Slug <span className="text-slate-400">(auto si vide)</span>
          </span>
          <Input
            value={slug}
            onChange={(e) => setSlug(e.target.value)}
            placeholder="legislation-transport"
          />
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">Bloc RNCP</span>
          <Select value={blocId} onChange={(e) => setBlocId(Number(e.target.value))}>
            {blocs.map((b) => (
              <option key={b.id} value={b.id}>
                {b.code} — {b.title}
              </option>
            ))}
          </Select>
        </label>
      </div>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">Résumé</span>
        <Textarea
          rows={3}
          value={summary}
          onChange={(e) => setSummary(e.target.value)}
          placeholder="Présentation courte du module…"
        />
      </label>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">Niveau</span>
          <Select
            value={difficulty}
            onChange={(e) => setDifficulty(e.target.value as any)}
          >
            <option value="debutant">Débutant</option>
            <option value="intermediaire">Intermédiaire</option>
            <option value="avance">Avancé</option>
          </Select>
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">Durée (min)</span>
          <Input
            type="number"
            value={duration}
            onChange={(e) => setDuration(Number(e.target.value))}
            min={5}
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
      <ImageUploader
        value={coverUrl}
        onChange={(url) => setCoverUrl(url ?? "")}
        prefix={`modules/${module?.id ?? "new"}/cover`}
        label="Image de couverture"
        ratio="wide"
        hint="PNG, JPG, WebP — 5 Mo max. Glisser-déposer ou cliquer pour parcourir."
      />
      <div className="pt-2 flex justify-end">
        <Button type="submit" disabled={isPending || !title}>
          <Save className="h-4 w-4" />
          {isPending ? "Enregistrement…" : module?.id ? "Enregistrer" : "Créer"}
        </Button>
      </div>
    </form>
  );
}
