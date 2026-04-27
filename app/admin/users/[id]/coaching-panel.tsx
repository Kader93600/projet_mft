"use client";
import { useState, useTransition } from "react";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/components/ui/toast";
import { useRouter } from "next/navigation";
import {
  UserCheck,
  CalendarPlus,
  NotebookPen,
  Eye,
  EyeOff,
  Pin,
  Trash2,
  Save,
} from "lucide-react";
import {
  assignReferent,
  createCoachingSession,
  updateCoachingSession,
  deleteCoachingSession,
  createCoachingNote,
  updateCoachingNote,
  deleteCoachingNote,
} from "@/app/admin/coaching/actions";

export function CoachingPanel({
  user,
  trainers,
  sessions,
  notes,
  currentAdminId,
}: {
  user: any;
  trainers: any[];
  sessions: any[];
  notes: any[];
  currentAdminId: string;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  const [referent, setReferent] = useState<string>(user.referent_id ?? "");

  function saveReferent() {
    startTransition(async () => {
      try {
        await assignReferent(user.id, referent || null);
        toast("Référent mis à jour", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <div id="coaching" className="space-y-5">
      {/* Référent */}
      <Card>
        <CardBody>
          <CardTitle className="flex items-center gap-2">
            <UserCheck className="h-4 w-4 text-gold-600" />
            Référent pédagogique
          </CardTitle>
          <div className="mt-4 flex flex-col md:flex-row md:items-center gap-3">
            <Select
              value={referent}
              onChange={(e) => setReferent(e.target.value)}
              className="md:flex-1"
            >
              <option value="">Aucun référent assigné</option>
              {trainers.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.full_name || t.email}
                </option>
              ))}
            </Select>
            <Button onClick={saveReferent} disabled={isPending}>
              <Save className="h-4 w-4" /> Enregistrer
            </Button>
          </div>
        </CardBody>
      </Card>

      {/* Sessions */}
      <SessionsBlock
        userId={user.id}
        sessions={sessions}
        trainers={trainers}
        defaultTrainerId={user.referent_id ?? currentAdminId}
      />

      {/* Notes */}
      <NotesBlock
        userId={user.id}
        notes={notes}
        trainerId={user.referent_id ?? currentAdminId}
      />
    </div>
  );
}

// ---------- Sessions ----------
function SessionsBlock({
  userId,
  sessions,
  trainers,
  defaultTrainerId,
}: {
  userId: string;
  sessions: any[];
  trainers: any[];
  defaultTrainerId: string;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [open, setOpen] = useState(false);

  const [form, setForm] = useState<any>({
    scheduled_at: "",
    duration_min: 30,
    mode: "visio",
    meeting_url: "",
    location: "",
    agenda: "",
    trainer_id: defaultTrainerId,
  });

  function submit() {
    if (!form.scheduled_at || !form.trainer_id) {
      toast("Date et formateur requis", "error");
      return;
    }
    startTransition(async () => {
      try {
        await createCoachingSession({
          user_id: userId,
          trainer_id: form.trainer_id,
          scheduled_at: new Date(form.scheduled_at).toISOString(),
          duration_min: Number(form.duration_min),
          mode: form.mode,
          meeting_url: form.meeting_url || null,
          location: form.location || null,
          agenda: form.agenda || null,
          status: "prevue",
        });
        toast("Rendez-vous programmé", "success");
        setOpen(false);
        setForm({
          scheduled_at: "",
          duration_min: 30,
          mode: "visio",
          meeting_url: "",
          location: "",
          agenda: "",
          trainer_id: defaultTrainerId,
        });
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function changeStatus(id: string, status: string) {
    startTransition(async () => {
      try {
        await updateCoachingSession({ id, status });
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onDelete(id: string) {
    if (!confirm("Supprimer ce rendez-vous ?")) return;
    startTransition(async () => {
      try {
        await deleteCoachingSession(id);
        toast("Supprimé", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <Card>
      <CardBody>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <CalendarPlus className="h-4 w-4 text-gold-600" />
            Rendez-vous d'accompagnement
          </CardTitle>
          <Button size="sm" onClick={() => setOpen(!open)}>
            {open ? "Annuler" : "+ Nouveau"}
          </Button>
        </div>

        {open && (
          <div className="mt-4 space-y-3 p-4 rounded-xl bg-navy-50/40 border border-navy-100">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              <label className="block">
                <span className="block text-xs font-medium text-slate-600 mb-1.5">
                  Date & heure
                </span>
                <Input
                  type="datetime-local"
                  value={form.scheduled_at}
                  onChange={(e) =>
                    setForm({ ...form, scheduled_at: e.target.value })
                  }
                />
              </label>
              <label className="block">
                <span className="block text-xs font-medium text-slate-600 mb-1.5">
                  Durée (min)
                </span>
                <Input
                  type="number"
                  value={form.duration_min}
                  onChange={(e) =>
                    setForm({ ...form, duration_min: e.target.value })
                  }
                  min={5}
                  max={480}
                />
              </label>
              <label className="block">
                <span className="block text-xs font-medium text-slate-600 mb-1.5">
                  Mode
                </span>
                <Select
                  value={form.mode}
                  onChange={(e) => setForm({ ...form, mode: e.target.value })}
                >
                  <option value="visio">Visio</option>
                  <option value="presentiel">Présentiel</option>
                  <option value="tel">Téléphone</option>
                </Select>
              </label>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <label className="block">
                <span className="block text-xs font-medium text-slate-600 mb-1.5">
                  Formateur
                </span>
                <Select
                  value={form.trainer_id}
                  onChange={(e) =>
                    setForm({ ...form, trainer_id: e.target.value })
                  }
                >
                  {trainers.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.full_name || t.email}
                    </option>
                  ))}
                </Select>
              </label>
              {form.mode === "visio" ? (
                <label className="block">
                  <span className="block text-xs font-medium text-slate-600 mb-1.5">
                    Lien visio
                  </span>
                  <Input
                    value={form.meeting_url}
                    onChange={(e) =>
                      setForm({ ...form, meeting_url: e.target.value })
                    }
                    placeholder="https://…"
                  />
                </label>
              ) : (
                <label className="block">
                  <span className="block text-xs font-medium text-slate-600 mb-1.5">
                    Lieu / numéro
                  </span>
                  <Input
                    value={form.location}
                    onChange={(e) =>
                      setForm({ ...form, location: e.target.value })
                    }
                  />
                </label>
              )}
            </div>
            <label className="block">
              <span className="block text-xs font-medium text-slate-600 mb-1.5">
                Ordre du jour
              </span>
              <Textarea
                rows={2}
                value={form.agenda}
                onChange={(e) => setForm({ ...form, agenda: e.target.value })}
              />
            </label>
            <div className="flex justify-end">
              <Button onClick={submit} disabled={isPending}>
                <Save className="h-4 w-4" /> Programmer
              </Button>
            </div>
          </div>
        )}

        {sessions.length === 0 ? (
          <p className="mt-4 text-sm text-slate-500">
            Aucun rendez-vous enregistré.
          </p>
        ) : (
          <ul className="mt-4 divide-y divide-navy-100">
            {sessions.map((s) => (
              <li key={s.id} className="py-3 flex items-start gap-3">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className="text-sm font-medium text-navy-900">
                      {new Date(s.scheduled_at).toLocaleDateString("fr-FR", {
                        weekday: "short",
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}{" "}
                      ·{" "}
                      {new Date(s.scheduled_at).toLocaleTimeString("fr-FR", {
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </span>
                    <Badge tone="slate" size="sm">
                      {s.mode}
                    </Badge>
                    <Badge
                      tone={
                        s.status === "tenue"
                          ? "success"
                          : s.status === "annulee"
                          ? "rose"
                          : s.status === "no_show"
                          ? "gold"
                          : "navy"
                      }
                      size="sm"
                    >
                      {s.status}
                    </Badge>
                  </div>
                  {s.agenda && (
                    <div className="text-xs text-slate-600 mt-1 line-clamp-2">
                      {s.agenda}
                    </div>
                  )}
                </div>
                <div className="flex flex-col gap-1 shrink-0">
                  <Select
                    value={s.status}
                    onChange={(e) => changeStatus(s.id, e.target.value)}
                    className="text-xs"
                  >
                    <option value="prevue">Prévue</option>
                    <option value="tenue">Tenue</option>
                    <option value="annulee">Annulée</option>
                    <option value="no_show">No-show</option>
                  </Select>
                  <button
                    className="text-xs text-rose-600 hover:bg-rose-50 rounded-md p-1 self-end"
                    onClick={() => onDelete(s.id)}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </CardBody>
    </Card>
  );
}

// ---------- Notes ----------
function NotesBlock({
  userId,
  notes,
  trainerId,
}: {
  userId: string;
  notes: any[];
  trainerId: string;
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [body, setBody] = useState("");
  const [visible, setVisible] = useState(false);

  function submit() {
    if (!body.trim()) return;
    startTransition(async () => {
      try {
        await createCoachingNote({
          user_id: userId,
          trainer_id: trainerId,
          body_md: body,
          visible_to_student: visible,
          pinned: false,
        });
        toast("Note ajoutée", "success");
        setBody("");
        setVisible(false);
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function toggleVisible(n: any) {
    startTransition(async () => {
      try {
        await updateCoachingNote({
          id: n.id,
          visible_to_student: !n.visible_to_student,
        });
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function togglePin(n: any) {
    startTransition(async () => {
      try {
        await updateCoachingNote({ id: n.id, pinned: !n.pinned });
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  function onDelete(id: string) {
    if (!confirm("Supprimer cette note ?")) return;
    startTransition(async () => {
      try {
        await deleteCoachingNote(id);
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <Card>
      <CardBody>
        <CardTitle className="flex items-center gap-2">
          <NotebookPen className="h-4 w-4 text-gold-600" />
          Notes pédagogiques
        </CardTitle>

        <div className="mt-4 space-y-2">
          <Textarea
            rows={3}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            placeholder="Observation, recommandation, plan d'action…"
          />
          <div className="flex items-center justify-between">
            <label className="flex items-center gap-2 text-xs text-slate-700">
              <input
                type="checkbox"
                checked={visible}
                onChange={(e) => setVisible(e.target.checked)}
              />
              Partager avec le stagiaire
            </label>
            <Button size="sm" onClick={submit} disabled={isPending || !body.trim()}>
              <Save className="h-4 w-4" /> Ajouter
            </Button>
          </div>
        </div>

        {notes.length === 0 ? (
          <p className="mt-4 text-sm text-slate-500">Aucune note pour l'instant.</p>
        ) : (
          <ul className="mt-4 space-y-2">
            {notes.map((n) => (
              <li
                key={n.id}
                className={`rounded-xl border p-3 text-sm ${
                  n.pinned
                    ? "bg-gold-50 border-gold-200"
                    : "bg-white border-navy-100"
                }`}
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0 flex-1">
                    <div className="whitespace-pre-wrap text-navy-900">
                      {n.body_md}
                    </div>
                    <div className="mt-1 text-[11px] text-slate-500 flex items-center gap-2">
                      {new Date(n.created_at).toLocaleDateString("fr-FR", {
                        day: "2-digit",
                        month: "short",
                        year: "numeric",
                      })}
                      {n.visible_to_student ? (
                        <span className="inline-flex items-center gap-1 text-emerald-700">
                          <Eye className="h-3 w-3" /> visible stagiaire
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-slate-500">
                          <EyeOff className="h-3 w-3" /> privée
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="flex gap-1 shrink-0">
                    <button
                      onClick={() => togglePin(n)}
                      className={`p-1 rounded-md hover:bg-white ${
                        n.pinned ? "text-gold-700" : "text-slate-400"
                      }`}
                      title="Épingler"
                    >
                      <Pin className="h-3.5 w-3.5" />
                    </button>
                    <button
                      onClick={() => toggleVisible(n)}
                      className="p-1 rounded-md hover:bg-white text-slate-500"
                      title="Partage"
                    >
                      {n.visible_to_student ? (
                        <EyeOff className="h-3.5 w-3.5" />
                      ) : (
                        <Eye className="h-3.5 w-3.5" />
                      )}
                    </button>
                    <button
                      onClick={() => onDelete(n.id)}
                      className="p-1 rounded-md hover:bg-rose-50 text-rose-600"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </CardBody>
    </Card>
  );
}
