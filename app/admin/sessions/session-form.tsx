"use client";

import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Video,
  MapPin,
  CalendarDays,
  Loader2,
  Save,
  AlertCircle,
  Link2,
  KeyRound,
  Users,
  StickyNote,
} from "lucide-react";
import { createSession, updateSession } from "./actions";

type Formation = {
  id: string;
  slug: string;
  title: string;
  code: string;
  category: string;
};

type Trainer = {
  id: string;
  full_name: string | null;
  email: string;
};

type Initial = {
  id?: string;
  title?: string;
  description?: string | null;
  formation_id?: string;
  kind?: "presentiel" | "distanciel" | "hybride";
  start_at?: string;
  end_at?: string;
  location?: string | null;
  meeting_provider?: "zoom" | "teams" | "meet" | "other" | null;
  meeting_url?: string | null;
  meeting_password?: string | null;
  max_participants?: number | null;
  trainer_id?: string | null;
  notes_internal?: string | null;
};

const KINDS: Array<{
  value: Initial["kind"];
  label: string;
  desc: string;
  icon: any;
}> = [
  {
    value: "distanciel",
    label: "Distanciel",
    desc: "Zoom · Teams · Meet",
    icon: Video,
  },
  {
    value: "presentiel",
    label: "Présentiel",
    desc: "Sur site / classe",
    icon: MapPin,
  },
  {
    value: "hybride",
    label: "Hybride",
    desc: "Présentiel + visio",
    icon: CalendarDays,
  },
];

const PROVIDERS = [
  { value: "zoom", label: "Zoom" },
  { value: "teams", label: "Microsoft Teams" },
  { value: "meet", label: "Google Meet" },
  { value: "other", label: "Autre" },
];

function toDateTimeLocal(iso?: string): string {
  if (!iso) return "";
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function SessionForm({
  formations,
  trainers,
  initial,
  sessionId,
  basePath = "/admin/sessions",
}: {
  formations: Formation[];
  trainers: Trainer[];
  initial?: Initial;
  sessionId?: string;
  /** Préfixe URL pour les redirections (ex. "/formateur/sessions") */
  basePath?: string;
}) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  const [kind, setKind] = useState<Initial["kind"]>(
    initial?.kind ?? "distanciel"
  );
  const [provider, setProvider] = useState<string>(
    initial?.meeting_provider ?? "zoom"
  );

  const needsLocation = kind === "presentiel" || kind === "hybride";
  const needsMeeting = kind === "distanciel" || kind === "hybride";

  function onSubmit(formData: FormData) {
    setError(null);
    formData.set("kind", kind || "distanciel");
    if (needsMeeting) formData.set("meeting_provider", provider);
    // Permet à l'action serveur de rediriger vers le bon namespace
    formData.set("__redirect_base", basePath);
    startTransition(async () => {
      try {
        if (sessionId) {
          await updateSession(sessionId, formData);
          router.push(`${basePath}/${sessionId}`);
        } else {
          await createSession(formData);
        }
      } catch (e: any) {
        setError(e.message ?? "Erreur lors de l'enregistrement");
      }
    });
  }

  return (
    <form action={onSubmit} className="space-y-8">
      {/* Type */}
      <section>
        <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold mb-3">
          Type de session
        </div>
        <div className="grid sm:grid-cols-3 gap-3">
          {KINDS.map((k) => {
            const Icon = k.icon;
            const active = kind === k.value;
            return (
              <button
                key={k.value}
                type="button"
                onClick={() => setKind(k.value)}
                className={
                  "relative text-left rounded-2xl border-2 px-4 py-4 transition " +
                  (active
                    ? "border-signal-500 bg-signal-50/40 ring-2 ring-signal-500/15"
                    : "border-navy-100 bg-white hover:border-navy-200")
                }
              >
                <Icon
                  className={
                    "h-5 w-5 mb-2 " +
                    (active ? "text-signal-700" : "text-slate-500")
                  }
                />
                <div className="font-display font-semibold text-navy-950 text-[15px]">
                  {k.label}
                </div>
                <div className="text-[12px] text-slate-500 mt-0.5">
                  {k.desc}
                </div>
              </button>
            );
          })}
        </div>
      </section>

      {/* Métadonnées */}
      <section className="space-y-4">
        <div>
          <Label htmlFor="title">Titre de la session *</Label>
          <Input
            id="title"
            name="title"
            required
            defaultValue={initial?.title}
            placeholder="Ex. Webinaire ADR — Chapitre 3 (Marchandises dangereuses)"
            disabled={pending}
          />
        </div>

        <div>
          <Label htmlFor="description">Description (optionnel)</Label>
          <Textarea
            id="description"
            name="description"
            rows={3}
            defaultValue={initial?.description ?? ""}
            placeholder="Objectifs pédagogiques, programme, prérequis…"
            disabled={pending}
          />
        </div>

        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <Label htmlFor="formation_id">Formation *</Label>
            <select
              id="formation_id"
              name="formation_id"
              required
              defaultValue={initial?.formation_id}
              disabled={pending || !!sessionId}
              className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15"
            >
              <option value="">— Sélectionner —</option>
              {formations.map((f) => (
                <option key={f.id} value={f.id}>
                  {f.code} · {f.title}
                </option>
              ))}
            </select>
          </div>
          <div>
            <Label htmlFor="trainer_id">Formateur référent</Label>
            <select
              id="trainer_id"
              name="trainer_id"
              defaultValue={initial?.trainer_id ?? ""}
              disabled={pending}
              className="w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900 focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15"
            >
              <option value="">— Moi-même —</option>
              {trainers.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.full_name ?? t.email}
                </option>
              ))}
            </select>
          </div>
        </div>
      </section>

      {/* Date & heure */}
      <section className="space-y-4">
        <div className="text-[11px] uppercase tracking-wider text-slate-500 font-semibold">
          Date &amp; horaires
        </div>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <Label htmlFor="start_at">Début *</Label>
            <Input
              id="start_at"
              name="start_at"
              type="datetime-local"
              required
              defaultValue={toDateTimeLocal(initial?.start_at)}
              disabled={pending}
            />
          </div>
          <div>
            <Label htmlFor="end_at">Fin *</Label>
            <Input
              id="end_at"
              name="end_at"
              type="datetime-local"
              required
              defaultValue={toDateTimeLocal(initial?.end_at)}
              disabled={pending}
            />
          </div>
        </div>
        <div>
          <Label htmlFor="max_participants">
            <Users className="inline h-3.5 w-3.5 mr-1 text-slate-400" />
            Capacité maximale (optionnel)
          </Label>
          <Input
            id="max_participants"
            name="max_participants"
            type="number"
            min={1}
            defaultValue={initial?.max_participants ?? ""}
            placeholder="Ex. 25"
            disabled={pending}
            className="max-w-[180px]"
          />
        </div>
      </section>

      {/* Lieu (présentiel/hybride) */}
      {needsLocation && (
        <section className="space-y-4 rounded-2xl border border-navy-100 bg-ivory/40 p-5">
          <div className="flex items-center gap-2 text-[11px] uppercase tracking-wider text-slate-500 font-semibold">
            <MapPin className="h-3.5 w-3.5" />
            Lieu de la session
          </div>
          <div>
            <Label htmlFor="location">Adresse / salle *</Label>
            <Input
              id="location"
              name="location"
              required
              defaultValue={initial?.location ?? ""}
              placeholder="Ex. MFT · 12 rue de Lyon, 75012 Paris — Salle Atlas"
              disabled={pending}
            />
          </div>
        </section>
      )}

      {/* Visioconférence (distanciel/hybride) */}
      {needsMeeting && (
        <section className="space-y-4 rounded-2xl border border-navy-100 bg-ivory/40 p-5">
          <div className="flex items-center gap-2 text-[11px] uppercase tracking-wider text-slate-500 font-semibold">
            <Video className="h-3.5 w-3.5" />
            Visioconférence
          </div>
          <div className="grid sm:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="meeting_provider">Service</Label>
              <div className="flex flex-wrap gap-2">
                {PROVIDERS.map((p) => (
                  <button
                    key={p.value}
                    type="button"
                    onClick={() => setProvider(p.value)}
                    className={
                      "px-3 h-9 rounded-lg text-[13px] font-medium border transition " +
                      (provider === p.value
                        ? "bg-navy-900 text-white border-navy-900"
                        : "bg-white text-navy-700 border-navy-200 hover:border-navy-300")
                    }
                  >
                    {p.label}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <Label htmlFor="meeting_password">
                <KeyRound className="inline h-3.5 w-3.5 mr-1 text-slate-400" />
                Code d'accès (optionnel)
              </Label>
              <Input
                id="meeting_password"
                name="meeting_password"
                defaultValue={initial?.meeting_password ?? ""}
                placeholder="Ex. MFT2026"
                disabled={pending}
              />
            </div>
          </div>
          <div>
            <Label htmlFor="meeting_url">
              <Link2 className="inline h-3.5 w-3.5 mr-1 text-slate-400" />
              Lien de la réunion *
            </Label>
            <Input
              id="meeting_url"
              name="meeting_url"
              type="url"
              required={needsMeeting}
              defaultValue={initial?.meeting_url ?? ""}
              placeholder="https://us02web.zoom.us/j/123456789"
              disabled={pending}
            />
            <p className="mt-1.5 text-[11.5px] text-slate-500">
              Le lien ne sera révélé aux stagiaires Premium qu'à 30 min avant
              le début pour limiter le partage.
            </p>
          </div>
        </section>
      )}

      {/* Notes internes */}
      <section>
        <Label htmlFor="notes_internal">
          <StickyNote className="inline h-3.5 w-3.5 mr-1 text-slate-400" />
          Notes internes (non visibles par les stagiaires)
        </Label>
        <Textarea
          id="notes_internal"
          name="notes_internal"
          rows={2}
          defaultValue={initial?.notes_internal ?? ""}
          placeholder="Consignes pour le formateur, matériel, contacts…"
          disabled={pending}
        />
      </section>

      {error && (
        <div className="flex items-start gap-2 rounded-xl bg-rose-50 border border-rose-200 px-4 py-3 text-sm text-rose-800">
          <AlertCircle className="h-4 w-4 mt-0.5 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      <div className="flex items-center justify-end gap-3 pt-2 border-t border-navy-100">
        <Button
          type="button"
          variant="ghost"
          onClick={() => router.back()}
          disabled={pending}
        >
          Annuler
        </Button>
        <Button type="submit" variant="gold" disabled={pending}>
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Enregistrement…
            </>
          ) : (
            <>
              <Save className="h-4 w-4" />
              {sessionId ? "Mettre à jour" : "Planifier la session"}
            </>
          )}
        </Button>
      </div>
    </form>
  );
}
