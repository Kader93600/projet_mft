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

  // Prénom/Nom : on part des colonnes dédiées si présentes, sinon on
  // dérive un fallback depuis full_name (1er mot = prénom, reste = nom)
  // pour pré-remplir proprement avant la première sauvegarde.
  const derived = deriveNames(user);
  const [firstName, setFirstName] = useState(user.first_name ?? derived.first);
  const [lastName, setLastName] = useState(user.last_name ?? derived.last);
  const [email, setEmail] = useState(user.email ?? "");
  const [phone, setPhone] = useState(user.phone ?? "");
  const [dateNaissance, setDateNaissance] = useState(
    (user.date_naissance ?? "").slice(0, 10)
  );
  const [adresse, setAdresse] = useState(user.adresse ?? "");
  const [codePostal, setCodePostal] = useState(user.code_postal ?? "");
  const [ville, setVille] = useState(user.ville ?? "");
  const [pays, setPays] = useState(user.pays ?? "France");
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
          first_name: firstName || null,
          last_name: lastName || null,
          email: email || null,
          phone: phone || null,
          date_naissance: dateNaissance || null,
          adresse: adresse || null,
          code_postal: codePostal || null,
          ville: ville || null,
          pays: pays || null,
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
      <div className="grid grid-cols-2 gap-3">
        <Field label="Prénom">
          <Input
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
            placeholder="Prénom"
          />
        </Field>
        <Field label="Nom">
          <Input
            value={lastName}
            onChange={(e) => setLastName(e.target.value)}
            placeholder="Nom de famille"
          />
        </Field>
      </div>
      <Field label="Email">
        <Input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </Field>
      <div className="grid grid-cols-2 gap-3">
        <Field label="Téléphone">
          <Input value={phone} onChange={(e) => setPhone(e.target.value)} />
        </Field>
        <Field label="Date de naissance">
          <Input
            type="date"
            value={dateNaissance}
            onChange={(e) => setDateNaissance(e.target.value)}
          />
        </Field>
      </div>
      <Field label="Adresse">
        <Input
          value={adresse}
          onChange={(e) => setAdresse(e.target.value)}
          placeholder="N° et rue"
        />
      </Field>
      <div className="grid grid-cols-3 gap-3">
        <Field label="Code postal">
          <Input
            value={codePostal}
            onChange={(e) => setCodePostal(e.target.value)}
            placeholder="75001"
          />
        </Field>
        <Field label="Ville" className="col-span-2">
          <Input value={ville} onChange={(e) => setVille(e.target.value)} />
        </Field>
      </div>
      <Field label="Pays">
        <Input value={pays} onChange={(e) => setPays(e.target.value)} />
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
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <label className={"block" + (className ? " " + className : "")}>
      <span className="block text-xs font-medium text-slate-600 mb-1.5">
        {label}
      </span>
      {children}
    </label>
  );
}

/**
 * Fallback prénom/nom depuis full_name tant que les colonnes dédiées ne
 * sont pas renseignées : 1er mot = prénom, le reste = nom. Heuristique
 * imparfaite sur les noms composés, corrigeable à la main ensuite.
 */
function deriveNames(user: any): { first: string; last: string } {
  if (user.first_name || user.last_name) {
    return { first: user.first_name ?? "", last: user.last_name ?? "" };
  }
  const full = (user.full_name ?? "").replace(/\s+/g, " ").trim();
  if (!full) return { first: "", last: "" };
  const parts = full.split(" ");
  if (parts.length === 1) return { first: parts[0], last: "" };
  return { first: parts[0], last: parts.slice(1).join(" ") };
}
