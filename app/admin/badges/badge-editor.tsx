"use client";
import { useState, useTransition } from "react";
import { Card, CardBody } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { useToast } from "@/components/ui/toast";
import { Save, Plus, Trash2, RefreshCw } from "lucide-react";
import { useRouter } from "next/navigation";
import {
  createBadge,
  updateBadge,
  deleteBadge,
  recomputeForAll,
} from "./actions";

const EMPTY = {
  code: "",
  name: "",
  description: "",
  icon: "Award",
  category: "progression",
  tier: "bronze",
  criteria: '{"type":"first_quiz_passed"}',
  points: 10,
  active: true,
  order: 0,
};

export function BadgeEditor({ badges }: { badges: any[] }) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [creating, setCreating] = useState(false);
  const [draft, setDraft] = useState<any>(EMPTY);

  function submitDraft(existing?: any) {
    let criteria: any;
    try {
      criteria =
        typeof draft.criteria === "string"
          ? JSON.parse(draft.criteria)
          : draft.criteria;
    } catch {
      toast("Critères : JSON invalide", "error");
      return;
    }
    const payload = {
      ...draft,
      points: Number(draft.points),
      order: Number(draft.order),
      criteria,
    };
    startTransition(async () => {
      try {
        if (existing?.id) {
          await updateBadge({ ...payload, id: existing.id });
          toast("Badge mis à jour", "success");
        } else {
          await createBadge(payload);
          toast("Badge créé", "success");
          setCreating(false);
          setDraft(EMPTY);
        }
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onDelete(id: string) {
    if (!confirm("Supprimer ce badge ? Les attributions existantes seront effacées.")) return;
    startTransition(async () => {
      try {
        await deleteBadge(id);
        toast("Badge supprimé", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onRecompute() {
    startTransition(async () => {
      try {
        const r = await recomputeForAll();
        toast(`Recalculé pour ${r.count} stagiaire(s)`, "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex gap-2">
          <Button
            onClick={() => {
              setDraft(EMPTY);
              setCreating(!creating);
            }}
            variant={creating ? "secondary" : "gold"}
          >
            <Plus className="h-4 w-4" />
            {creating ? "Annuler" : "Nouveau badge"}
          </Button>
          <Button variant="secondary" onClick={onRecompute} disabled={isPending}>
            <RefreshCw className="h-4 w-4" />
            Recalculer tous les stagiaires
          </Button>
        </div>
      </div>

      {creating && (
        <Card variant="gold">
          <CardBody>
            <BadgeForm draft={draft} setDraft={setDraft} />
            <div className="flex justify-end pt-3">
              <Button onClick={() => submitDraft()} disabled={isPending}>
                <Save className="h-4 w-4" /> Créer
              </Button>
            </div>
          </CardBody>
        </Card>
      )}

      <div className="grid md:grid-cols-2 gap-3">
        {badges.map((b) => (
          <BadgeRow
            key={b.id}
            badge={b}
            onDelete={() => onDelete(b.id)}
            onSubmitDraft={(d) => {
              setDraft(d);
              submitDraft(b);
            }}
            isPending={isPending}
          />
        ))}
      </div>
    </div>
  );
}

function BadgeRow({
  badge,
  onDelete,
  onSubmitDraft,
  isPending,
}: {
  badge: any;
  onDelete: () => void;
  onSubmitDraft: (d: any) => void;
  isPending: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [draft, setDraft] = useState<any>({
    ...badge,
    criteria: JSON.stringify(badge.criteria ?? {}),
  });

  return (
    <Card>
      <CardBody>
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="font-display font-semibold text-navy-900">
                {badge.name}
              </span>
              <span className="text-[10px] font-mono text-slate-500">
                {badge.code}
              </span>
              {!badge.active && (
                <span className="text-[10px] uppercase tracking-wider text-rose-600">
                  inactif
                </span>
              )}
            </div>
            <div className="text-xs text-slate-500 mt-0.5">
              {badge.tier} · {badge.category} · {badge.points} pts
            </div>
          </div>
          <div className="flex gap-1 shrink-0">
            <button
              className="text-xs px-2 py-1 rounded-md border border-navy-100 hover:bg-navy-50"
              onClick={() => setOpen(!open)}
            >
              {open ? "Fermer" : "Éditer"}
            </button>
            <button
              className="p-1 text-rose-600 hover:bg-rose-50 rounded-md"
              onClick={onDelete}
              disabled={isPending}
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        </div>
        {open && (
          <div className="mt-4 pt-4 border-t border-navy-100">
            <BadgeForm draft={draft} setDraft={setDraft} />
            <div className="flex justify-end pt-3">
              <Button onClick={() => onSubmitDraft(draft)} disabled={isPending}>
                <Save className="h-4 w-4" /> Enregistrer
              </Button>
            </div>
          </div>
        )}
      </CardBody>
    </Card>
  );
}

function BadgeForm({
  draft,
  setDraft,
}: {
  draft: any;
  setDraft: (d: any) => void;
}) {
  function set(k: string, v: any) {
    setDraft({ ...draft, [k]: v });
  }
  return (
    <div className="space-y-3">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Code (a-z_0-9)
          </span>
          <Input
            value={draft.code}
            onChange={(e) => set("code", e.target.value)}
          />
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Nom
          </span>
          <Input value={draft.name} onChange={(e) => set("name", e.target.value)} />
        </label>
      </div>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">
          Description
        </span>
        <Textarea
          rows={2}
          value={draft.description ?? ""}
          onChange={(e) => set("description", e.target.value)}
        />
      </label>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Icône Lucide
          </span>
          <Input value={draft.icon} onChange={(e) => set("icon", e.target.value)} />
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Catégorie
          </span>
          <Select
            value={draft.category}
            onChange={(e) => set("category", e.target.value)}
          >
            <option value="progression">Progression</option>
            <option value="regularite">Régularité</option>
            <option value="excellence">Excellence</option>
            <option value="maitrise">Maîtrise</option>
          </Select>
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Niveau
          </span>
          <Select value={draft.tier} onChange={(e) => set("tier", e.target.value)}>
            <option value="bronze">Bronze</option>
            <option value="silver">Argent</option>
            <option value="gold">Or</option>
          </Select>
        </label>
        <label className="block">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Points
          </span>
          <Input
            type="number"
            value={draft.points}
            onChange={(e) => set("points", e.target.value)}
          />
        </label>
      </div>
      <label className="block">
        <span className="block text-xs font-medium text-slate-600 mb-1.5">
          Critères (JSON)
        </span>
        <Textarea
          rows={3}
          value={
            typeof draft.criteria === "string"
              ? draft.criteria
              : JSON.stringify(draft.criteria, null, 2)
          }
          onChange={(e) => set("criteria", e.target.value)}
        />
        <span className="text-[10px] text-slate-500 mt-1 block">
          Types supportés : <code>first_quiz_passed</code>,{" "}
          <code>quiz_passed_count</code> (min), <code>perfect_score</code> (min),{" "}
          <code>mock_exam_passed</code> (min), <code>lessons_completed</code>{" "}
          (min), <code>bloc_mastered</code> (bloc_id).
        </span>
      </label>
      <div className="flex items-center gap-4">
        <label className="flex items-center gap-2">
          <input
            type="checkbox"
            checked={draft.active}
            onChange={(e) => set("active", e.target.checked)}
          />
          <span className="text-sm">Actif</span>
        </label>
        <label className="block flex-1">
          <span className="block text-xs font-medium text-slate-600 mb-1.5">
            Ordre
          </span>
          <Input
            type="number"
            value={draft.order}
            onChange={(e) => set("order", e.target.value)}
          />
        </label>
      </div>
    </div>
  );
}
