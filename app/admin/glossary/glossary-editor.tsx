"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Save, Trash2, Loader2 } from "lucide-react";
import {
  createGlossaryTerm,
  updateGlossaryTerm,
  deleteGlossaryTerm,
} from "./actions";

type Bloc = { id: number; code: string; title: string };
type Term = {
  id: string;
  term: string;
  definition_md: string;
  bloc_id: number | null;
  synonyms: string[] | null;
  source: string | null;
};

export function GlossaryEditor({
  blocs,
  mode,
  term,
}: {
  blocs: Bloc[];
  mode: "create" | "edit";
  term?: Term;
}) {
  const router = useRouter();
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);
  const [t, setT] = useState(term?.term ?? "");
  const [def, setDef] = useState(term?.definition_md ?? "");
  const [blocId, setBlocId] = useState<string>(
    term?.bloc_id ? String(term.bloc_id) : ""
  );
  const [syn, setSyn] = useState((term?.synonyms ?? []).join(", "));
  const [source, setSource] = useState(term?.source ?? "");

  function save() {
    setError(null);
    start(async () => {
      try {
        const payload = {
          term: t,
          definition_md: def,
          bloc_id: blocId ? Number(blocId) : null,
          synonyms: syn.split(",").map((s) => s.trim()).filter(Boolean),
          source: source || null,
        };
        if (mode === "create") {
          await createGlossaryTerm(payload);
          setT("");
          setDef("");
          setBlocId("");
          setSyn("");
          setSource("");
        } else if (term) {
          await updateGlossaryTerm({ id: term.id, ...payload });
        }
        router.refresh();
      } catch (e: any) {
        setError(e.message);
      }
    });
  }

  function remove() {
    if (!term) return;
    if (!confirm("Supprimer ce terme ?")) return;
    start(async () => {
      try {
        await deleteGlossaryTerm(term.id);
        router.refresh();
      } catch (e: any) {
        setError(e.message);
      }
    });
  }

  return (
    <div className="space-y-3">
      <div className="grid md:grid-cols-2 gap-3">
        <Input
          value={t}
          onChange={(e) => setT(e.target.value)}
          placeholder="Terme (ex. Cabotage)"
        />
        <Select value={blocId} onChange={(e) => setBlocId(e.target.value)}>
          <option value="">Transversal (aucun bloc)</option>
          {blocs.map((b) => (
            <option key={b.id} value={b.id}>
              {b.code} — {b.title}
            </option>
          ))}
        </Select>
      </div>
      <Textarea
        value={def}
        onChange={(e) => setDef(e.target.value)}
        placeholder="Définition (markdown supporté)…"
        rows={4}
      />
      <div className="grid md:grid-cols-2 gap-3">
        <Input
          value={syn}
          onChange={(e) => setSyn(e.target.value)}
          placeholder="Synonymes, séparés par des virgules"
        />
        <Input
          value={source}
          onChange={(e) => setSource(e.target.value)}
          placeholder="Source (ex. Code des transports, art. L.3211-1)"
        />
      </div>
      {error && (
        <p className="text-sm text-rose-700 bg-rose-50 border border-rose-200 px-3 py-2 rounded-lg">
          {error}
        </p>
      )}
      <div className="flex items-center justify-between pt-1">
        <Button
          type="button"
          variant="gold"
          size="sm"
          onClick={save}
          disabled={pending || !t || !def}
        >
          {pending ? (
            <Loader2 className="h-3.5 w-3.5 animate-spin" />
          ) : (
            <Save className="h-3.5 w-3.5" />
          )}
          {mode === "create" ? "Créer" : "Enregistrer"}
        </Button>
        {mode === "edit" && term && (
          <Button
            type="button"
            variant="secondary"
            size="sm"
            onClick={remove}
            disabled={pending}
            className="text-rose-700 hover:bg-rose-50"
          >
            <Trash2 className="h-3.5 w-3.5" /> Supprimer
          </Button>
        )}
      </div>
    </div>
  );
}
