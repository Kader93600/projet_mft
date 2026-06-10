import { SiteShell, PageHero } from "@/components/site/site-shell";
import { LEGAL } from "@/lib/legal-config";
import { FORMATIONS } from "@/lib/formations-config";
import {
  ShieldCheck,
  Award,
  HeartHandshake,
  Sparkles,
  Building2,
  GraduationCap,
  Users2,
} from "lucide-react";

export const metadata = {
  title: "L'école",
  alternates: { canonical: "/ecole" },
  description: `Découvrez ${LEGAL.brand}, organisme de formation spécialisé dans les métiers du transport, situé à Meaux.`,
};

export const revalidate = 3600;

export default function EcolePage() {
  return (
    <SiteShell>
      <PageHero
        eyebrow="Notre école"
        title={
          <>
            Au service des{" "}
            <span className="italic text-signal-400">métiers du transport</span>.
          </>
        }
        description={
          <>
            {LEGAL.brand} est un centre de formation spécialisé dans les
            professions réglementées du transport routier de marchandises et de
            voyageurs.
          </>
        }
      />

      <main className="max-w-5xl mx-auto px-6 py-16 md:py-20 space-y-16">
        {/* Notre mission */}
        <section>
          <h2 className="font-display text-2xl md:text-3xl font-semibold mb-5">
            Notre mission
          </h2>
          <p className="text-white/80 text-lg leading-relaxed">
            Former les professionnels qui font tourner la France. Conducteurs,
            exploitants, gestionnaires, formateurs : nous proposons{" "}
            {FORMATIONS.length} parcours certifiants ou réglementaires pour
            entrer, évoluer ou créer dans le secteur transport.
          </p>
          <p className="mt-4 text-white/70 leading-relaxed">
            Notre approche conjugue rigueur académique et pédagogie de terrain,
            avec une plateforme numérique moderne qui s'adapte aux contraintes
            de nos stagiaires (horaires décalés, mobilité, reconversion).
          </p>
        </section>

        {/* Valeurs */}
        <section>
          <h2 className="font-display text-2xl md:text-3xl font-semibold mb-8">
            Nos valeurs
          </h2>
          <div className="grid sm:grid-cols-2 gap-4">
            {[
              {
                icon: ShieldCheck,
                title: "Conformité",
                desc: "Certifié Qualiopi, organisme de formation déclaré, contenus mis à jour selon les évolutions réglementaires.",
              },
              {
                icon: Sparkles,
                title: "Excellence",
                desc: "Formateurs issus du terrain, taux de réussite élevés, accompagnement individualisé.",
              },
              {
                icon: HeartHandshake,
                title: "Humain",
                desc: "Un coach pédagogique dédié, des sessions live, une hotline qui répond sous 24 h ouvrées.",
              },
              {
                icon: Award,
                title: "Reconnaissance",
                desc: "Titres et attestations délivrés conformément aux référentiels officiels (RNCP, France Compétences).",
              },
            ].map(({ icon: Icon, title, desc }) => (
              <div
                key={title}
                className="rounded-2xl border border-white/10 bg-night-100 p-6"
              >
                <div className="h-11 w-11 rounded-xl bg-brand-600/20 border border-brand-500/30 text-signal-400 flex items-center justify-center">
                  <Icon className="h-5 w-5" />
                </div>
                <h3 className="mt-4 font-display text-lg font-semibold">
                  {title}
                </h3>
                <p className="mt-2 text-sm text-white/65 leading-relaxed">
                  {desc}
                </p>
              </div>
            ))}
          </div>
        </section>

        {/* Carte d'identité */}
        <section>
          <h2 className="font-display text-2xl md:text-3xl font-semibold mb-6">
            Carte d'identité
          </h2>
          <div className="rounded-2xl border border-white/10 bg-night-100 p-6 grid sm:grid-cols-2 gap-6">
            <Identity
              icon={Building2}
              label="Raison sociale"
              value={LEGAL.legalName}
            />
            <Identity icon={ShieldCheck} label="SIREN" value={LEGAL.siren} />
            <Identity
              icon={GraduationCap}
              label="Code APE"
              value={`${LEGAL.apeCode} — ${LEGAL.apeLabel}`}
            />
            <Identity
              icon={Award}
              label="Activité"
              value="Formation et enseignement"
            />
            <div className="sm:col-span-2 pt-4 border-t border-white/10">
              <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mb-1.5">
                Adresse du centre
              </div>
              <div className="text-white/85">
                {LEGAL.address.street}
                <br />
                {LEGAL.address.postalCode} {LEGAL.address.city},{" "}
                {LEGAL.address.country}
              </div>
            </div>
          </div>
        </section>

        {/* Équipe */}
        <section>
          <div className="flex items-center gap-2 mb-2">
            <Users2 className="h-5 w-5 text-signal-400" />
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-400">
              Notre équipe
            </span>
          </div>
          <h2 className="font-display text-2xl md:text-3xl font-semibold mb-2">
            Des formateurs <span className="italic text-signal-400">issus du terrain</span>.
          </h2>
          <p className="text-white/65 leading-relaxed mb-8 max-w-2xl">
            Une équipe passionnée, qui connaît le métier de l'intérieur. Plus
            de 15 ans d'expérience dans leurs domaines respectifs : exploitation,
            réglementation, sécurité routière, transport de voyageurs. Chaque
            formateur a exercé sur le terrain avant de transmettre, et c'est ce
            qui fait la différence : des cours ancrés dans la réalité, des
            réponses concrètes à vos questions, et un accompagnement humain à
            chaque étape de votre parcours.
          </p>
        </section>

        {/* Engagement Qualiopi */}
        <section className="rounded-3xl bg-gradient-to-br from-brand-700 to-brand-900 p-8 md:p-12 relative overflow-hidden">
          <div
            aria-hidden="true"
            className="absolute -top-16 -right-16 h-60 w-60 rounded-full bg-signal-500/20 blur-3xl"
          />
          <div className="relative">
            <div className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-300">
              Engagement Qualiopi
            </div>
            <h2 className="mt-3 font-display text-2xl md:text-3xl font-semibold">
              Qualité reconnue par l'État
            </h2>
            <p className="mt-4 text-white/80 max-w-2xl leading-relaxed">
              {LEGAL.brand} est certifié Qualiopi pour la catégorie « Actions
              de formation ». Cette certification atteste de la qualité du
              processus mis en œuvre par notre organisme et conditionne l'accès
              aux financements publics et mutualisés.
            </p>
            <div className="mt-6 grid sm:grid-cols-2 gap-3">
              <Bullet>
                Process pédagogique audité indépendamment selon le RNQ
              </Bullet>
              <Bullet>Suivi des indicateurs de satisfaction et réussite</Bullet>
              <Bullet>
                Mises à jour annuelles des contenus selon la réglementation
              </Bullet>
              <Bullet>Référent handicap dédié</Bullet>
            </div>
          </div>
        </section>
      </main>
    </SiteShell>
  );
}

function Identity({
  icon: Icon,
  label,
  value,
}: {
  icon: any;
  label: string;
  value: string;
}) {
  return (
    <div>
      <div className="flex items-center gap-2 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mb-1">
        <Icon className="h-3.5 w-3.5" />
        {label}
      </div>
      <div className="text-white/90 font-medium">{value}</div>
    </div>
  );
}

function Bullet({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-start gap-2">
      <div className="h-5 w-5 rounded-full bg-signal-500/20 border border-signal-500/40 flex items-center justify-center shrink-0 mt-0.5">
        <svg viewBox="0 0 14 14" className="h-2.5 w-2.5 text-signal-400">
          <path
            d="M2 7l3 3 7-7"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
      <span className="text-white/85 text-sm">{children}</span>
    </div>
  );
}
