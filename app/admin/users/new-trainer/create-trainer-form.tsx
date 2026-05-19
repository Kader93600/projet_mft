"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { createTrainer } from "../actions";
import {
  GraduationCap,
  Save,
  Loader2,
  CheckCircle2,
  Mail,
  Lock,
} from "lucide-react";

interface Formation {
  slug: string;
  code: string;
  title: string;
}

export function CreateTrainerForm({ formations }: { formations: Formation[] }) {
  const router = useRouter();
  const { toast } = useToast();
  const [pending, start] = useTransition();
  const [success, setSuccess] = useState<{
    email: string;
    accessMode: string;
  } | null>(null);

  const [f, setF] = useState({
    full_name: "",
    email: "",
    phone: "",
    formation_slugs: [] as string[],
    can_grade: true,
    can_edit_content: false,
    access_mode: "invite" as "invite" | "password",
    initial_password: "",
  });
  const up =
    <K extends keyof typeof f>(k: K) =>
    (e: any) => {
      const v =
        e?.target?.type === "checkbox" ? e.target.checked : e?.target?.value;
      setF((p) => ({ ...p, [k]: v }));
    };

  function toggleFormation(slug: string) {
    setF((p) => ({
      ...p,
      formation_slugs: p.formation_slugs.includes(slug)
        ? p.formation_slugs.filter((s) => s !== slug)
        : [...p.formation_slugs, slug],
    }));
  }

  function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!f.full_name.trim() || !f.email.trim()) {
      toast("Nom complet et email requis", "error");
      return;
    }
    if (f.access_mode === "password" && f.initial_password.length < 8) {
      toast("Mot de passe initial trop court (min 8)", "error");
      return;
    }
    start(async () => {
      const res = await createTrainer({
        full_name: f.full_name.trim(),
        email: f.email.trim(),
        phone: f.phone.trim() || null,
        formation_slugs: f.formation_slugs,
        can_grade: f.can_grade,
        can_edit_content: f.can_edit_content,
        access_mode: f.access_mode,
        initial_password:
          f.access_mode === "password" ? f.initial_password : null,
      });
      if (!res.ok) {
        toast(res.error, "error");
        return;
      }
      setSuccess({ email: res.email, accessMode: res.accessMode });
      toast("Formateur créé avec succès", "success");
    });
  }

  if (success) {
    return (
      <div className="space-y-4 text-center py-6">
        <div className="mx-auto h-14 w-14 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 flex items-center justify-center">
          <CheckCircle2 className="h-7 w-7" />
        </div>
        <h2 className="font-display text-xl font-semibold text-navy-900">
          Formateur créé
        </h2>
        <p className="text-sm text-slate-600 max-w-md mx-auto">
          {success.accessMode === "invite"
            ? `Un email d'invitation a été envoyé à ${success.email}. Il devra définir son mot de passe avant la première connexion.`
            : `Le compte ${success.email} est actif. Transmettez-lui son mot de passe initial pour qu'il se connecte.`}
        </p>
        <div className="flex items-center justify-center gap-2 pt-2">
          <Link href="/admin/users">
            <Button variant="secondary">Retour à la liste</Button>
          </Link>
          <Button onClick={() => window.location.reload()}>
            Créer un autre formateur
          </Button>
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} className="space-y-6">
      <div className="grid md:grid-cols-2 gap-4">
        <div>
          <Label htmlFor="full_name">
            Nom complet <span className="text-rose-600">*</span>
          </Label>
          <Input
            id="full_name"
            value={f.full_name}
            onChange={up("full_name")}
            placeholder="Prénom Nom"
            autoFocus
          />
        </div>
        <div>
          <Label htmlFor="email">
            Email <span className="text-rose-600">*</span>
          </Label>
          <Input
            id="email"
            type="email"
            value={f.email}
            onChange={up("email")}
            placeholder="formateur@exemple.fr"
          />
        </div>
        <div className="md:col-span-2">
          <Label htmlFor="phone">Téléphone</Label>
          <Input
            id="phone"
            type="tel"
            value={f.phone}
            onChange={up("phone")}
            placeholder="06 XX XX XX XX"
          />
        </div>
      </div>

      <div>
        <Label>Formations habilitées</Label>
        <div className="mt-2 grid sm:grid-cols-2 gap-2">
          {formations.map((fo) => {
            const active = f.formation_slugs.includes(fo.slug);
            return (
              <label
                key={fo.slug}
                className={
                  "flex items-start gap-3 rounded-xl border px-3 py-2.5 cursor-pointer transition " +
                  (active
                    ? "border-brand-500 bg-brand-50/60"
                    : "border-navy-100 bg-white hover:border-navy-300")
                }
              >
                <input
                  type="checkbox"
                  checked={active}
                  onChange={() => toggleFormation(fo.slug)}
                  className="mt-1 h-4 w-4 rounded border-navy-300"
                />
                <div className="min-w-0">
                  <div className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">
                    {fo.code}
                  </div>
                  <div className="text-sm text-navy-900 leading-tight">
                    {fo.title}
                  </div>
                </div>
              </label>
            );
          })}
        </div>
        <p className="mt-1.5 text-xs text-slate-500">
          Le formateur ne pourra corriger / éditer que les formations
          sélectionnées. Vous pourrez modifier ces habilitations plus tard.
        </p>
      </div>

      <div className="grid sm:grid-cols-2 gap-3">
        <label className="flex items-center gap-3 rounded-xl border border-navy-100 bg-white px-3 py-2.5 cursor-pointer">
          <input
            type="checkbox"
            checked={f.can_grade}
            onChange={up("can_grade")}
            className="h-4 w-4 rounded border-navy-300"
          />
          <div>
            <div className="text-sm font-medium text-navy-900">
              Peut corriger les copies QR
            </div>
            <div className="text-xs text-slate-500">
              Validation des examens blancs avec questions ouvertes
            </div>
          </div>
        </label>
        <label className="flex items-center gap-3 rounded-xl border border-navy-100 bg-white px-3 py-2.5 cursor-pointer">
          <input
            type="checkbox"
            checked={f.can_edit_content}
            onChange={up("can_edit_content")}
            className="h-4 w-4 rounded border-navy-300"
          />
          <div>
            <div className="text-sm font-medium text-navy-900">
              Peut éditer le contenu
            </div>
            <div className="text-xs text-slate-500">
              Modifier modules, leçons, quiz de ses formations
            </div>
          </div>
        </label>
      </div>

      <div>
        <Label>Création de l'accès</Label>
        <div className="mt-2 grid sm:grid-cols-2 gap-3">
          <button
            type="button"
            onClick={() => setF((p) => ({ ...p, access_mode: "invite" }))}
            className={
              "rounded-xl border px-4 py-3 text-left transition " +
              (f.access_mode === "invite"
                ? "border-brand-500 bg-brand-50/60"
                : "border-navy-100 bg-white hover:border-navy-300")
            }
          >
            <div className="flex items-center gap-2">
              <Mail className="h-4 w-4 text-brand-700" />
              <div className="font-semibold text-navy-900">
                Email d'invitation
              </div>
            </div>
            <div className="text-xs text-slate-600 mt-1">
              Le formateur reçoit un lien pour définir son mot de passe.
            </div>
          </button>
          <button
            type="button"
            onClick={() => setF((p) => ({ ...p, access_mode: "password" }))}
            className={
              "rounded-xl border px-4 py-3 text-left transition " +
              (f.access_mode === "password"
                ? "border-brand-500 bg-brand-50/60"
                : "border-navy-100 bg-white hover:border-navy-300")
            }
          >
            <div className="flex items-center gap-2">
              <Lock className="h-4 w-4 text-brand-700" />
              <div className="font-semibold text-navy-900">
                Mot de passe initial
              </div>
            </div>
            <div className="text-xs text-slate-600 mt-1">
              Vous transmettez le mot de passe vous-même.
            </div>
          </button>
        </div>
      </div>

      {f.access_mode === "password" && (
        <div>
          <Label htmlFor="initial_password">Mot de passe initial</Label>
          <Input
            id="initial_password"
            type="text"
            value={f.initial_password}
            onChange={up("initial_password")}
            placeholder="Min 8 caractères"
          />
        </div>
      )}

      <div className="flex items-center justify-end gap-2 pt-4 border-t border-navy-50">
        <Link href="/admin/users">
          <Button variant="secondary" type="button" disabled={pending}>
            Annuler
          </Button>
        </Link>
        <Button type="submit" variant="gold" disabled={pending}>
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Création…
            </>
          ) : (
            <>
              <Save className="h-4 w-4" />
              Créer le formateur
            </>
          )}
        </Button>
      </div>
    </form>
  );
}
