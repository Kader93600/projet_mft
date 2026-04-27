"use client";
import { Card, CardBody, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogBody,
  DialogFooter,
  DialogHeader,
} from "@/components/ui/dialog";
import { useToast } from "@/components/ui/toast";
import { initials } from "@/lib/utils";
import {
  Plus,
  Pencil,
  Trash2,
  Users,
  UserPlus,
  UserMinus,
  Palette,
} from "lucide-react";
import { useState, useTransition } from "react";
import {
  assignUserToGroup,
  createGroup,
  deleteGroup,
  updateGroup,
} from "./actions";

interface Group {
  id: string;
  name: string;
  description: string | null;
  academic_year: string | null;
  color: string;
  students_count: number;
}
interface Student {
  id: string;
  full_name: string | null;
  email: string;
  group_id: string | null;
}

const COLORS = [
  { key: "navy", label: "Bleu marine", bg: "bg-navy-100", text: "text-navy-800", dot: "bg-navy-600" },
  { key: "gold", label: "Or", bg: "bg-gold-100", text: "text-gold-800", dot: "bg-gold-500" },
  { key: "emerald", label: "Vert", bg: "bg-emerald-100", text: "text-emerald-800", dot: "bg-emerald-500" },
  { key: "rose", label: "Rose", bg: "bg-rose-100", text: "text-rose-800", dot: "bg-rose-500" },
  { key: "violet", label: "Violet", bg: "bg-violet-100", text: "text-violet-800", dot: "bg-violet-500" },
];

function colorStyle(key: string) {
  return COLORS.find((c) => c.key === key) ?? COLORS[0];
}

export function GroupsManager({
  groups,
  students,
}: {
  groups: Group[];
  students: Student[];
}) {
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Group | null>(null);
  const [managingGroup, setManagingGroup] = useState<Group | null>(null);

  return (
    <div className="space-y-6">
      {/* Actions top */}
      <div className="flex justify-between items-center">
        <p className="text-sm text-slate-600">
          <strong className="text-navy-900">{groups.length}</strong> classes ·{" "}
          <strong className="text-navy-900">{students.length}</strong> étudiants
        </p>
        <Button
          variant="gold"
          onClick={() => {
            setEditing(null);
            setFormOpen(true);
          }}
        >
          <Plus className="h-4 w-4" /> Créer une classe
        </Button>
      </div>

      {/* Liste groupes */}
      {groups.length === 0 ? (
        <Card>
          <CardBody className="py-14 text-center">
            <div className="h-12 w-12 mx-auto rounded-2xl bg-navy-50 flex items-center justify-center">
              <Users className="h-5 w-5 text-navy-700" />
            </div>
            <p className="mt-3 text-navy-900 font-medium">Aucune classe encore</p>
            <p className="text-sm text-slate-500 mt-1">
              Créez votre première classe pour organiser vos étudiants.
            </p>
          </CardBody>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {groups.map((g) => {
            const c = colorStyle(g.color);
            return (
              <Card key={g.id} className="group">
                <CardBody>
                  <div className="flex items-start justify-between">
                    <div className={`h-2.5 w-2.5 rounded-full ${c.dot}`} />
                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => {
                          setEditing(g);
                          setFormOpen(true);
                        }}
                        className="h-7 w-7 rounded-lg hover:bg-navy-50 text-slate-500 hover:text-navy-900 flex items-center justify-center"
                        aria-label="Modifier"
                      >
                        <Pencil className="h-3.5 w-3.5" />
                      </button>
                      <button
                        onClick={() => {
                          if (confirm(`Supprimer la classe "${g.name}" ? Les étudiants seront détachés.`)) {
                            startTransition(async () => {
                              try {
                                await deleteGroup(g.id);
                                toast("Classe supprimée", "success");
                              } catch (e: any) {
                                toast(e.message, "error");
                              }
                            });
                          }
                        }}
                        className="h-7 w-7 rounded-lg hover:bg-rose-50 text-slate-500 hover:text-rose-700 flex items-center justify-center"
                        aria-label="Supprimer"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  </div>
                  <CardTitle className="mt-3 text-base">{g.name}</CardTitle>
                  {g.description && (
                    <p className="mt-1 text-sm text-slate-600 line-clamp-2">
                      {g.description}
                    </p>
                  )}
                  <div className="mt-4 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      {g.academic_year && (
                        <span className={`text-[10px] uppercase tracking-wider font-semibold px-2 py-1 rounded ${c.bg} ${c.text}`}>
                          {g.academic_year}
                        </span>
                      )}
                    </div>
                    <div className="text-xs text-slate-500">
                      <strong className="text-navy-900">{g.students_count}</strong>{" "}
                      étudiant{g.students_count > 1 ? "s" : ""}
                    </div>
                  </div>
                  <Button
                    size="sm"
                    variant="secondary"
                    className="mt-4 w-full"
                    onClick={() => setManagingGroup(g)}
                  >
                    <Users className="h-3.5 w-3.5" /> Gérer les étudiants
                  </Button>
                </CardBody>
              </Card>
            );
          })}
        </div>
      )}

      {/* Dialog création/édition */}
      <GroupFormDialog
        open={formOpen}
        onClose={() => setFormOpen(false)}
        editing={editing}
      />

      {/* Dialog gestion étudiants */}
      {managingGroup && (
        <ManageStudentsDialog
          group={managingGroup}
          students={students}
          onClose={() => setManagingGroup(null)}
        />
      )}
    </div>
  );
}

function GroupFormDialog({
  open,
  onClose,
  editing,
}: {
  open: boolean;
  onClose: () => void;
  editing: Group | null;
}) {
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [form, setForm] = useState({
    name: editing?.name ?? "",
    description: editing?.description ?? "",
    academic_year: editing?.academic_year ?? "",
    color: editing?.color ?? "navy",
  });

  // Reset form when opening a different editing target
  if (
    editing &&
    form.name !== editing.name &&
    (!form.name || form.name === "") &&
    open
  ) {
    setForm({
      name: editing.name,
      description: editing.description ?? "",
      academic_year: editing.academic_year ?? "",
      color: editing.color,
    });
  }

  function submit(e: React.FormEvent) {
    e.preventDefault();
    startTransition(async () => {
      try {
        if (editing) {
          await updateGroup(editing.id, form);
          toast("Classe mise à jour", "success");
        } else {
          await createGroup(form);
          toast("Classe créée", "success");
        }
        setForm({ name: "", description: "", academic_year: "", color: "navy" });
        onClose();
      } catch (err: any) {
        toast(err.message, "error");
      }
    });
  }

  return (
    <Dialog open={open} onClose={onClose}>
      <DialogHeader
        title={editing ? "Modifier la classe" : "Nouvelle classe"}
        description="Définissez le nom, l'année et l'identifiant visuel."
        onClose={onClose}
      />
      <form onSubmit={submit}>
        <DialogBody className="space-y-4">
          <div>
            <Label htmlFor="g-name">Nom de la classe</Label>
            <Input
              id="g-name"
              required
              placeholder="Ex : GOTRM 2026 A"
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
            />
          </div>
          <div>
            <Label htmlFor="g-year">Année académique</Label>
            <Input
              id="g-year"
              placeholder="2025-2026"
              value={form.academic_year}
              onChange={(e) => setForm({ ...form, academic_year: e.target.value })}
            />
          </div>
          <div>
            <Label htmlFor="g-desc">Description</Label>
            <Textarea
              id="g-desc"
              placeholder="Promotion…"
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
            />
          </div>
          <div>
            <Label>
              <span className="inline-flex items-center gap-1">
                <Palette className="h-3.5 w-3.5" /> Couleur
              </span>
            </Label>
            <div className="flex gap-2">
              {COLORS.map((c) => (
                <button
                  key={c.key}
                  type="button"
                  onClick={() => setForm({ ...form, color: c.key })}
                  className={`h-9 w-9 rounded-lg ${c.dot} ring-offset-2 transition-all ${
                    form.color === c.key ? "ring-2 ring-navy-900" : ""
                  }`}
                  aria-label={c.label}
                />
              ))}
            </div>
          </div>
        </DialogBody>
        <DialogFooter>
          <Button type="button" variant="secondary" onClick={onClose}>
            Annuler
          </Button>
          <Button type="submit" variant="primary" disabled={isPending}>
            {editing ? "Enregistrer" : "Créer"}
          </Button>
        </DialogFooter>
      </form>
    </Dialog>
  );
}

function ManageStudentsDialog({
  group,
  students,
  onClose,
}: {
  group: Group;
  students: Student[];
  onClose: () => void;
}) {
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();
  const [filter, setFilter] = useState("");

  const inGroup = students.filter((s) => s.group_id === group.id);
  const others = students.filter(
    (s) =>
      s.group_id !== group.id &&
      (s.email.toLowerCase().includes(filter.toLowerCase()) ||
        s.full_name?.toLowerCase().includes(filter.toLowerCase()))
  );

  function move(userId: string, target: string | null) {
    startTransition(async () => {
      try {
        await assignUserToGroup(userId, target);
        toast(target ? "Étudiant ajouté" : "Étudiant retiré", "success");
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <Dialog open={true} onClose={onClose} size="lg">
      <DialogHeader
        title={`Étudiants · ${group.name}`}
        description={`${inGroup.length} étudiant${inGroup.length > 1 ? "s" : ""} dans la classe`}
        onClose={onClose}
      />
      <DialogBody className="grid grid-cols-1 md:grid-cols-2 gap-5">
        {/* Dans la classe */}
        <div>
          <div className="eyebrow text-slate-500 mb-2">Dans la classe</div>
          <div className="space-y-1.5 max-h-[50vh] overflow-y-auto pr-1">
            {inGroup.length === 0 && (
              <div className="text-sm text-slate-400 py-6 text-center border border-dashed border-navy-100 rounded-xl">
                Aucun étudiant
              </div>
            )}
            {inGroup.map((s) => (
              <div
                key={s.id}
                className="flex items-center gap-3 p-2 rounded-lg bg-emerald-50/50 border border-emerald-100"
              >
                <div className="h-8 w-8 rounded-full bg-navy-900 text-gold-400 flex items-center justify-center text-[11px] font-semibold">
                  {initials(s.full_name || s.email)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-sm text-navy-900 truncate">
                    {s.full_name || s.email}
                  </div>
                  <div className="text-xs text-slate-500 truncate">{s.email}</div>
                </div>
                <button
                  onClick={() => move(s.id, null)}
                  disabled={isPending}
                  className="h-7 w-7 rounded-lg hover:bg-rose-50 text-rose-700 flex items-center justify-center"
                  title="Retirer"
                >
                  <UserMinus className="h-4 w-4" />
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* À ajouter */}
        <div>
          <div className="eyebrow text-slate-500 mb-2">Ajouter un étudiant</div>
          <Input
            placeholder="Rechercher par nom ou email…"
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            className="mb-2 h-9"
          />
          <div className="space-y-1.5 max-h-[45vh] overflow-y-auto pr-1">
            {others.slice(0, 50).map((s) => (
              <div
                key={s.id}
                className="flex items-center gap-3 p-2 rounded-lg hover:bg-navy-50 transition-colors"
              >
                <div className="h-8 w-8 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center text-[11px] font-semibold">
                  {initials(s.full_name || s.email)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-medium text-sm text-navy-900 truncate">
                    {s.full_name || s.email}
                  </div>
                  <div className="text-xs text-slate-500 truncate">{s.email}</div>
                </div>
                <button
                  onClick={() => move(s.id, group.id)}
                  disabled={isPending}
                  className="h-7 w-7 rounded-lg hover:bg-emerald-50 text-emerald-700 flex items-center justify-center"
                  title="Ajouter"
                >
                  <UserPlus className="h-4 w-4" />
                </button>
              </div>
            ))}
          </div>
        </div>
      </DialogBody>
      <DialogFooter>
        <Button variant="primary" onClick={onClose}>
          Terminé
        </Button>
      </DialogFooter>
    </Dialog>
  );
}
