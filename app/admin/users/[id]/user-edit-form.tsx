"use client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/components/ui/toast";
import { Save } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { updateUserProfile } from "../actions";

interface Group {
  id: string;
  name: string;
  color: string;
}

export function UserEditForm({
  user,
  groups,
}: {
  user: any;
  groups: Group[];
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [isPending, startTransition] = useTransition();

  const [fullName, setFullName] = useState(user.full_name ?? "");
  const [email, setEmail] = useState(user.email ?? "");
  const [phone, setPhone] = useState(user.phone ?? "");
  const [level, setLevel] = useState(user.level ?? "debutant");
  const [role, setRole] = useState<
    "student" | "trainer" | "admin" | "super_admin"
  >(user.role ?? "student");
  const [groupId, setGroupId] = useState<string>(user.group_id ?? "");
  const [notes, setNotes] = useState(user.notes ?? "");

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    startTransition(async () => {
      try {
        await updateUserProfile(user.id, {
          full_name: fullName || null,
          email: email || null,
          phone: phone || null,
          notes: notes || null,
          level,
          role,
          group_id: groupId || null,
        });
        toast("Profil mis à jour", "success");
        router.refresh();
      } catch (e: any) {
        toast(e.message, "error");
      }
    });
  }

  return (
    <form onSubmit={onSubmit} className="space-y-4">
      <Field label="Nom complet">
        <Input value={fullName} onChange={(e) => setFullName(e.target.value)} />
      </Field>
      <Field label="Email">
        <Input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </Field>
      <Field label="Téléphone">
        <Input value={phone} onChange={(e) => setPhone(e.target.value)} />
      </Field>
      <div className="grid grid-cols-2 gap-3">
        <Field label="Rôle">
          <Select value={role} onChange={(e) => setRole(e.target.value as any)}>
            <option value="student">Stagiaire</option>
            <option value="trainer">Formateur</option>
            <option value="admin">Administrateur</option>
            <option value="super_admin">Super administrateur</option>
          </Select>
        </Field>
        <Field label="Niveau">
          <Select value={level} onChange={(e) => setLevel(e.target.value)}>
            <option value="debutant">Débutant</option>
            <option value="intermediaire">Intermédiaire</option>
            <option value="avance">Avancé</option>
          </Select>
        </Field>
      </div>
      <Field label="Classe">
        <Select value={groupId} onChange={(e) => setGroupId(e.target.value)}>
          <option value="">Aucune classe</option>
          {groups.map((g) => (
            <option key={g.id} value={g.id}>
              {g.name}
            </option>
          ))}
        </Select>
      </Field>
      <Field label="Notes internes">
        <Textarea
          rows={3}
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          placeholder="Notes visibles uniquement par les administrateurs…"
        />
      </Field>
      <div className="pt-2">
        <Button type="submit" disabled={isPending} className="w-full">
          <Save className="h-4 w-4" />
          {isPending ? "Enregistrement…" : "Enregistrer"}
        </Button>
      </div>
    </form>
  );
}

function Field({
  label,
  children,
}: {
  label: string;
  children: React.ReactNode;
}) {
  return (
    <label className="block">
      <span className="block text-xs font-medium text-slate-600 mb-1.5">
        {label}
      </span>
      {children}
    </label>
  );
}
