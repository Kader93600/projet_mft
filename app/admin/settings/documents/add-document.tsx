"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Plus, Loader2, X } from "lucide-react";
import { createDocument } from "./actions";

/**
 * Bouton "Ajouter un document" + mini-formulaire inline.
 * Crée un document d'accueil en brouillon (contenu vide) que l'admin édite
 * et publie ensuite via l'éditeur de la liste.
 */
export function AddDocument() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState("");
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);

  function submit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);
    if (title.trim().length < 1) {
      setErr("Indiquez un titre.");
      return;
    }
    start(async () => {
      try {
        await createDocument({ title: title.trim() });
        setTitle("");
        setOpen(false);
        router.refresh();
      } catch (e: any) {
        setErr(e?.message ?? "Une erreur est survenue.");
      }
    });
  }

  if (!open) {
    return (
      <button
        type="button"
        onClick={() => {
          setErr(null);
          setOpen(true);
        }}
        className="inline-flex items-center gap-1.5 rounded-lg bg-navy-900 hover:bg-navy-800 text-white px-3.5 py-2 text-sm font-semibold transition-[transform,background-color] duration-200 ease-premium active:scale-[0.97] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-600 focus-visible:ring-offset-2 motion-reduce:transition-none motion-reduce:active:scale-100"
      >
        <Plus className="h-4 w-4" /> Ajouter un document
      </button>
    );
  }

  return (
    <form
      onSubmit={submit}
      className="flex items-center gap-2 rounded-xl border border-navy-200 bg-white p-2 shadow-soft"
    >
      <input
        autoFocus
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Titre (ex. CGV, Consignes de sécurité, Charte informatique…)"
        disabled={pending}
        className="w-72 max-w-[60vw] rounded-lg border border-navy-200 bg-white px-3 py-1.5 text-sm text-navy-900 outline-none transition-colors focus:border-gold-400 focus:ring-2 focus:ring-gold-100 disabled:opacity-60"
      />
      <button
        type="submit"
        disabled={pending}
        className="inline-flex items-center gap-1.5 rounded-lg bg-gold-500 hover:bg-gold-600 text-night-900 px-3 py-1.5 text-sm font-semibold transition-colors disabled:opacity-60"
      >
        {pending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Plus className="h-4 w-4" />}
        Créer
      </button>
      <button
        type="button"
        onClick={() => {
          setOpen(false);
          setErr(null);
          setTitle("");
        }}
        disabled={pending}
        aria-label="Annuler"
        className="inline-flex h-8 w-8 items-center justify-center rounded-lg text-slate-500 hover:bg-navy-50 hover:text-navy-900 transition-colors"
      >
        <X className="h-4 w-4" />
      </button>
      {err && <span className="text-xs text-rose-700">{err}</span>}
    </form>
  );
}
