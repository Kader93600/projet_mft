"use client";
import { useState, useTransition } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input, Label } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { useToast } from "@/components/ui/toast";
import { createStudent } from "../actions";
import {
  User,
  GraduationCap,
  Wallet,
  Lock,
  Save,
  Loader2,
  CheckCircle2,
  Copy,
  Eye,
  EyeOff,
  Sparkles,
  Mail,
  RefreshCw,
} from "lucide-react";

interface Formation {
  slug: string;
  code: string;
  title: string;
}
interface StaffOpt {
  id: string;
  full_name: string | null;
  email: string;
  role: string;
}
interface FunderOpt {
  id: string;
  name: string;
  kind: string;
}

/**
 * Génère un mot de passe lisible mais sécurisé : 14 caractères, mix
 * majuscules / minuscules / chiffres / signes faciles à transmettre.
 */
function generatePassword(): string {
  const upper = "ABCDEFGHJKMNPQRSTUVWXYZ";
  const lower = "abcdefghjkmnpqrstuvwxyz";
  const digits = "23456789";
  const symbols = "@#%*+-";
  const all = upper + lower + digits + symbols;
  const pick = (s: string) => s[Math.floor(Math.random() * s.length)];
  let pw =
    pick(upper) + pick(lower) + pick(digits) + pick(symbols);
  for (let i = 0; i < 10; i++) pw += pick(all);
  return pw
    .split("")
    .sort(() => Math.random() - 0.5)
    .join("");
}

export function CreateStudentForm({
  formations,
  staff,
  trainers,
  funders,
}: {
  formations: Formation[];
  staff: StaffOpt[];
  trainers: StaffOpt[];
  funders: FunderOpt[];
}) {
  const router = useRouter();
  const { toast } = useToast();
  const [pending, start] = useTransition();
  const [success, setSuccess] = useState<{
    email: string;
    accessMode: string;
    password?: string;
  } | null>(null);
  const [showPw, setShowPw] = useState(false);

  // Form state
  const [f, setF] = useState({
    // Personnel
    full_name: "",
    email: "",
    phone: "",
    date_naissance: "",
    adresse: "",
    code_postal: "",
    ville: "",

    // Pédagogique
    formation_slug: formations[0]?.slug ?? "",
    session_label: "",
    entry_date: new Date().toISOString().slice(0, 10),
    referent_id: "",
    trainer_id: "",

    // Administratif
    funder_id: "",
    funding_kind: "auto" as
      | "opco"
      | "cpf"
      | "employeur"
      | "pole_emploi"
      | "auto"
      | "autre",
    enrollment_status: "en_cours" as
      | "prospect"
      | "devis"
      | "accord_financeur"
      | "a_payer"
      | "en_cours"
      | "termine",
    total_amount_eur: "",

    // Accès
    access_mode: "invite" as "invite" | "password",
    initial_password: "",
  });

  const up = (k: keyof typeof f) => (e: any) =>
    setF((s) => ({ ...s, [k]: e.target.value }));

  const submit = () => {
    if (!f.full_name.trim() || !f.email.trim() || !f.formation_slug) {
      toast("Nom, email et formation sont obligatoires", "error");
      return;
    }
    start(async () => {
      try {
        const payload: any = {
          full_name: f.full_name.trim(),
          email: f.email.trim().toLowerCase(),
          phone: f.phone.trim() || null,
          date_naissance: f.date_naissance || null,
          adresse: f.adresse.trim() || null,
          code_postal: f.code_postal.trim() || null,
          ville: f.ville.trim() || null,
          formation_slug: f.formation_slug,
          session_label: f.session_label.trim() || null,
          entry_date: f.entry_date || null,
          referent_id: f.referent_id || null,
          trainer_id: f.trainer_id || null,
          funder_id: f.funder_id || null,
          funding_kind: f.funding_kind,
          enrollment_status: f.enrollment_status,
          total_amount_cents: f.total_amount_eur
            ? Math.round(Number(f.total_amount_eur) * 100)
            : 0,
          access_mode: f.access_mode,
          initial_password:
            f.access_mode === "password" ? f.initial_password : null,
        };
        const res = await createStudent(payload);
        if (!res.ok) {
          // Le server action retourne {ok:false, error, step?} pour
          // contourner la sanitisation Next.js prod des throw().
          toast(res.error, "error");
          return;
        }
        setSuccess({
          email: res.email,
          accessMode: res.accessMode,
          password:
            f.access_mode === "password" ? f.initial_password : undefined,
        });
        toast("Stagiaire créé avec succès", "success");
      } catch (e: any) {
        // Filet de sécurité : devrait être rare puisque l'action ne
        // throw plus, mais on garde au cas où (network error, etc.)
        toast(e?.message ?? "Erreur de création", "error");
      }
    });
  };

  // ─── Écran succès ──────────────────────────────────────────────────
  if (success) {
    return (
      <div
        className="text-center py-6 space-y-5 max-w-md mx-auto"
        style={{ animation: "fade-up 0.5s ease-out both" }}
      >
        <div
          className="mx-auto h-16 w-16 rounded-3xl bg-gradient-to-br from-signal-300 to-signal-500 flex items-center justify-center shadow-glow-signal"
          style={{
            animation:
              "fade-up 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) 0.1s both",
          }}
        >
          <CheckCircle2 className="h-8 w-8 text-night-900" />
        </div>
        <div>
          <h3 className="font-display text-2xl font-semibold text-navy-950">
            Compte créé.
          </h3>
          <p className="mt-2 text-sm text-slate-600">
            Stagiaire <strong className="text-navy-900">{success.email}</strong>{" "}
            a été ajouté à la plateforme.
          </p>
        </div>

        {success.accessMode === "invite" ? (
          <div className="rounded-2xl bg-emerald-50 border border-emerald-200 p-4 text-left">
            <div className="flex items-start gap-3">
              <Mail className="h-5 w-5 text-emerald-600 shrink-0 mt-0.5" />
              <div className="text-sm text-emerald-900">
                <strong>Email d'invitation envoyé</strong> — le stagiaire
                recevra un lien pour définir son mot de passe et activer son
                compte.
              </div>
            </div>
          </div>
        ) : (
          <div className="rounded-2xl bg-amber-50 border border-amber-200 p-4 text-left">
            <div className="text-xs font-semibold uppercase tracking-wider text-amber-700 mb-2">
              Mot de passe initial à transmettre
            </div>
            <div className="flex items-center gap-2">
              <code className="flex-1 px-3 py-2 rounded-lg bg-white border border-amber-200 font-mono text-sm text-navy-900 select-all">
                {showPw ? success.password : "••••••••••••"}
              </code>
              <button
                type="button"
                onClick={() => setShowPw((v) => !v)}
                className="h-9 w-9 rounded-lg border border-amber-200 bg-white flex items-center justify-center hover:bg-amber-50"
                aria-label={showPw ? "Masquer" : "Afficher"}
              >
                {showPw ? (
                  <EyeOff className="h-4 w-4 text-amber-700" />
                ) : (
                  <Eye className="h-4 w-4 text-amber-700" />
                )}
              </button>
              <button
                type="button"
                onClick={() => {
                  if (success.password) {
                    navigator.clipboard.writeText(success.password);
                    toast("Mot de passe copié", "success");
                  }
                }}
                className="h-9 w-9 rounded-lg border border-amber-200 bg-white flex items-center justify-center hover:bg-amber-50"
                aria-label="Copier"
              >
                <Copy className="h-4 w-4 text-amber-700" />
              </button>
            </div>
            <p className="mt-3 text-xs text-amber-800">
              ⚠️ À transmettre au stagiaire par un canal sûr. Ce mot de passe ne
              sera plus visible après cet écran.
            </p>
          </div>
        )}

        <div className="flex flex-wrap gap-3 justify-center pt-2">
          <Link href={`/admin/users`} className="contents">
            <Button variant="secondary">Retour à la liste</Button>
          </Link>
          <Button
            onClick={() => {
              setSuccess(null);
              setF({
                full_name: "",
                email: "",
                phone: "",
                date_naissance: "",
                adresse: "",
                code_postal: "",
                ville: "",
                formation_slug: formations[0]?.slug ?? "",
                session_label: "",
                entry_date: new Date().toISOString().slice(0, 10),
                referent_id: "",
                trainer_id: "",
                funder_id: "",
                funding_kind: "auto",
                enrollment_status: "en_cours",
                total_amount_eur: "",
                access_mode: "invite",
                initial_password: "",
              });
              router.refresh();
            }}
            variant="gold"
          >
            <UserPlusIcon /> Créer un autre stagiaire
          </Button>
        </div>
      </div>
    );
  }

  // ─── Formulaire ─────────────────────────────────────────────────────
  const stagger = (i: number) => ({
    animation: `fade-up 0.4s cubic-bezier(0.22, 1, 0.36, 1) ${i * 60}ms both`,
  });

  return (
    <div className="space-y-8">
      {/* Section 1 — Informations personnelles */}
      <Section
        icon={User}
        title="Informations personnelles"
        index={0}
        stagger={stagger}
      >
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Nom complet" required>
            <Input
              value={f.full_name}
              onChange={up("full_name")}
              placeholder="Prénom Nom"
              autoFocus
            />
          </Field>
          <Field label="Email" required>
            <Input
              type="email"
              value={f.email}
              onChange={up("email")}
              placeholder="prenom.nom@exemple.fr"
            />
          </Field>
          <Field label="Téléphone">
            <Input
              type="tel"
              value={f.phone}
              onChange={up("phone")}
              placeholder="06 XX XX XX XX"
            />
          </Field>
          <Field label="Date de naissance">
            <Input
              type="date"
              value={f.date_naissance}
              onChange={up("date_naissance")}
            />
          </Field>
          <Field label="Adresse" className="md:col-span-2">
            <Input
              value={f.adresse}
              onChange={up("adresse")}
              placeholder="N° et nom de la voie"
            />
          </Field>
          <Field label="Code postal">
            <Input
              value={f.code_postal}
              onChange={up("code_postal")}
              placeholder="75001"
              maxLength={10}
            />
          </Field>
          <Field label="Ville">
            <Input
              value={f.ville}
              onChange={up("ville")}
              placeholder="Paris"
            />
          </Field>
        </div>
      </Section>

      {/* Section 2 — Pédagogique */}
      <Section
        icon={GraduationCap}
        title="Informations pédagogiques"
        index={1}
        stagger={stagger}
      >
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Formation" required className="md:col-span-2">
            <Select
              value={f.formation_slug}
              onChange={up("formation_slug")}
              required
            >
              <option value="">— Sélectionner —</option>
              {formations.map((fo) => (
                <option key={fo.slug} value={fo.slug}>
                  {fo.code} — {fo.title}
                </option>
              ))}
            </Select>
          </Field>
          <Field label="Session / Promotion">
            <Input
              value={f.session_label}
              onChange={up("session_label")}
              placeholder="Ex. Session-2026-Q1"
            />
          </Field>
          <Field label="Date d'entrée">
            <Input
              type="date"
              value={f.entry_date}
              onChange={up("entry_date")}
            />
          </Field>
          <Field label="Référent pédagogique" hint="Admin chargé du suivi">
            <Select value={f.referent_id} onChange={up("referent_id")}>
              <option value="">— Aucun pour le moment —</option>
              {staff.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.full_name || s.email}
                  {s.role === "super_admin" ? " (Super-admin)" : ""}
                </option>
              ))}
            </Select>
          </Field>
          <Field label="Formateur assigné" hint="Encadrement direct">
            <Select value={f.trainer_id} onChange={up("trainer_id")}>
              <option value="">— Aucun pour le moment —</option>
              {trainers.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.full_name || t.email}
                </option>
              ))}
            </Select>
          </Field>
        </div>
      </Section>

      {/* Section 3 — Administratif & financement */}
      <Section
        icon={Wallet}
        title="Administratif & financement"
        index={2}
        stagger={stagger}
      >
        <div className="grid md:grid-cols-2 gap-4">
          <Field label="Type de financement">
            <Select value={f.funding_kind} onChange={up("funding_kind")}>
              <option value="auto">Auto-financement</option>
              <option value="cpf">CPF / Mon Compte Formation</option>
              <option value="opco">OPCO</option>
              <option value="employeur">Employeur</option>
              <option value="pole_emploi">France Travail</option>
              <option value="autre">Autre</option>
            </Select>
          </Field>
          <Field label="Financeur (si rattaché)">
            <Select value={f.funder_id} onChange={up("funder_id")}>
              <option value="">— Aucun pour le moment —</option>
              {funders.map((fu) => (
                <option key={fu.id} value={fu.id}>
                  {fu.name} ({fu.kind})
                </option>
              ))}
            </Select>
          </Field>
          <Field label="Statut du dossier">
            <Select value={f.enrollment_status} onChange={up("enrollment_status")}>
              <option value="prospect">Demande reçue</option>
              <option value="devis">Devis envoyé</option>
              <option value="accord_financeur">Accord financeur reçu</option>
              <option value="a_payer">Paiement à effectuer</option>
              <option value="en_cours">Formation en cours</option>
              <option value="termine">Formation terminée</option>
            </Select>
          </Field>
          <Field label="Montant total (€)" hint="Optionnel">
            <Input
              type="number"
              min="0"
              step="0.01"
              value={f.total_amount_eur}
              onChange={up("total_amount_eur")}
              placeholder="2400"
            />
          </Field>
        </div>
      </Section>

      {/* Section 4 — Accès au compte */}
      <Section
        icon={Lock}
        title="Création de l'accès"
        index={3}
        stagger={stagger}
      >
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <button
              type="button"
              onClick={() => setF((s) => ({ ...s, access_mode: "invite" }))}
              className={
                "text-left rounded-xl border-2 p-4 transition " +
                (f.access_mode === "invite"
                  ? "border-brand-600 bg-brand-50/40 shadow-soft"
                  : "border-navy-100 bg-white hover:border-brand-300")
              }
            >
              <div className="flex items-start gap-3">
                <div className="h-9 w-9 rounded-xl bg-brand-50 text-brand-700 flex items-center justify-center shrink-0">
                  <Mail className="h-4 w-4" />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-navy-900">
                    Email d'invitation
                  </div>
                  <p className="mt-1 text-xs text-slate-600">
                    Le stagiaire reçoit un lien pour définir son mot de passe
                    lui-même. Recommandé.
                  </p>
                </div>
              </div>
            </button>
            <button
              type="button"
              onClick={() => setF((s) => ({ ...s, access_mode: "password" }))}
              className={
                "text-left rounded-xl border-2 p-4 transition " +
                (f.access_mode === "password"
                  ? "border-amber-600 bg-amber-50/40 shadow-soft"
                  : "border-navy-100 bg-white hover:border-amber-300")
              }
            >
              <div className="flex items-start gap-3">
                <div className="h-9 w-9 rounded-xl bg-amber-50 text-amber-700 flex items-center justify-center shrink-0">
                  <Lock className="h-4 w-4" />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-navy-900">
                    Mot de passe initial
                  </div>
                  <p className="mt-1 text-xs text-slate-600">
                    Vous générez un mot de passe à transmettre. Compte actif
                    immédiatement.
                  </p>
                </div>
              </div>
            </button>
          </div>

          {f.access_mode === "password" && (
            <div className="rounded-xl border border-navy-100 bg-navy-50/30 p-4">
              <div className="flex items-end gap-2">
                <Field label="Mot de passe" hint="8 caractères minimum">
                  <div className="relative">
                    <Input
                      type={showPw ? "text" : "password"}
                      value={f.initial_password}
                      onChange={up("initial_password")}
                      placeholder="Saisir ou générer"
                      minLength={8}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPw((v) => !v)}
                      className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 hover:text-navy-900"
                      aria-label={showPw ? "Masquer" : "Afficher"}
                    >
                      {showPw ? (
                        <EyeOff className="h-4 w-4" />
                      ) : (
                        <Eye className="h-4 w-4" />
                      )}
                    </button>
                  </div>
                </Field>
                <Button
                  type="button"
                  variant="secondary"
                  onClick={() =>
                    setF((s) => ({ ...s, initial_password: generatePassword() }))
                  }
                >
                  <RefreshCw className="h-3.5 w-3.5" />
                  Générer
                </Button>
              </div>
            </div>
          )}
        </div>
      </Section>

      {/* CTA submit */}
      <div className="flex flex-wrap items-center justify-end gap-3 pt-2">
        <Link href="/admin/users" className="contents">
          <Button variant="secondary">Annuler</Button>
        </Link>
        <Button
          onClick={submit}
          disabled={pending}
          variant="gold"
          size="lg"
          className="hover:-translate-y-0.5 transition motion-reduce:hover:translate-y-0"
        >
          {pending ? (
            <>
              <Loader2 className="h-4 w-4 animate-spin" />
              Création…
            </>
          ) : (
            <>
              <Save className="h-4 w-4" />
              Créer le stagiaire
            </>
          )}
        </Button>
      </div>
    </div>
  );
}

// ─── Helpers ──────────────────────────────────────────────────────────

function Section({
  icon: Icon,
  title,
  children,
  index,
  stagger,
}: {
  icon: any;
  title: string;
  children: React.ReactNode;
  index: number;
  stagger: (i: number) => any;
}) {
  return (
    <section style={stagger(index)}>
      <div className="flex items-center gap-2 mb-4">
        <div className="h-8 w-8 rounded-lg bg-brand-50 text-brand-700 flex items-center justify-center">
          <Icon className="h-4 w-4" />
        </div>
        <h3 className="font-display text-base font-semibold text-navy-900">
          {title}
        </h3>
      </div>
      {children}
    </section>
  );
}

function Field({
  label,
  hint,
  required,
  children,
  className,
}: {
  label: string;
  hint?: string;
  required?: boolean;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={className}>
      <Label>
        {label}
        {required && <span className="text-rose-600 ml-0.5">*</span>}
      </Label>
      {children}
      {hint && <p className="mt-1 text-xs text-slate-500">{hint}</p>}
    </div>
  );
}

function UserPlusIcon() {
  return <Sparkles className="h-4 w-4" />;
}
