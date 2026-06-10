import { SiteShell, PageHero } from "@/components/site/site-shell";
import { LEGAL } from "@/lib/legal-config";
import { Mail, Phone, MapPin, Clock, MessageCircle } from "lucide-react";
import { ContactForm } from "./contact-form";

export const metadata = {
  title: "Contact",
  alternates: { canonical: "/contact" },
  description: `Contactez ${LEGAL.brand} : ${LEGAL.address.city}, ${LEGAL.email}, ${LEGAL.phone}.`,
};

export const revalidate = 3600;

export default function ContactPage() {
  return (
    <SiteShell>
      <PageHero
        eyebrow="Contact"
        title={
          <>
            Parlons de votre{" "}
            <span className="italic text-signal-400">projet</span>.
          </>
        }
        description={
          <>
            Notre équipe vous répond sous 4 h ouvrées. Que vous soyez stagiaire,
            employeur ou financeur, nous étudions votre demande gratuitement.
          </>
        }
      />

      <main className="max-w-7xl mx-auto px-6 py-16 md:py-20 grid lg:grid-cols-3 gap-10">
        {/* Coordonnées */}
        <aside className="space-y-6 min-w-0">
          <div className="rounded-2xl border border-white/10 bg-night-100 p-6">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-400 flex items-center justify-center">
                <MapPin className="h-5 w-5" />
              </div>
              <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60">
                Adresse
              </div>
            </div>
            <div className="mt-4 text-white/85 leading-relaxed">
              {LEGAL.legalName}
              <br />
              {LEGAL.address.street}
              <br />
              {LEGAL.address.postalCode} {LEGAL.address.city}
              <br />
              {LEGAL.address.country}
            </div>
          </div>

          <div className="rounded-2xl border border-white/10 bg-night-100 p-6 space-y-5">
            <ContactRow
              icon={Mail}
              label="Email"
              value={LEGAL.email}
              href={`mailto:${LEGAL.email}`}
            />
            <ContactRow
              icon={Phone}
              label="Téléphone"
              value={LEGAL.phone}
              href={`tel:${LEGAL.phone.replace(/\s/g, "")}`}
            />
            <ContactRow
              icon={MessageCircle}
              label="Support stagiaires"
              value={LEGAL.supportEmail}
              href={`mailto:${LEGAL.supportEmail}`}
            />
            <div className="pt-5 border-t border-white/10">
              <div className="flex items-center gap-2 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/60 mb-1.5">
                <Clock className="h-3.5 w-3.5" />
                Horaires
              </div>
              <div className="text-sm text-white/80 leading-relaxed">
                Lundi – Vendredi, 9 h – 18 h
                <br />
                <span className="text-white/55">
                  Plateforme stagiaire : 24 h / 24
                </span>
              </div>
            </div>
          </div>

          {/* Carte d'adresse — sans iframe (compatible adblockers / corp networks) */}
          <div className="rounded-2xl border border-white/10 bg-night-100 overflow-hidden">
            {/* Visuel : gradient + grid + pin animé */}
            <div className="relative h-48 sm:h-52 overflow-hidden bg-gradient-to-br from-brand-900/40 via-night-100 to-signal-500/15">
              <div
                aria-hidden
                className="absolute inset-0 bg-grid-night opacity-40"
                style={{ backgroundSize: "28px 28px" }}
              />
              {/* Halo radial signal */}
              <div
                aria-hidden
                className="absolute inset-0 pointer-events-none"
                style={{
                  background:
                    "radial-gradient(ellipse 50% 60% at 50% 55%, rgba(159,226,32,0.18) 0%, transparent 70%)",
                }}
              />
              {/* Pin animé */}
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="relative">
                  <span
                    aria-hidden
                    className="absolute inset-0 -m-3 rounded-full bg-signal-500/25 motion-reduce:hidden"
                    style={{
                      animation: "glow-pulse 2.4s ease-in-out infinite",
                    }}
                  />
                  <span
                    aria-hidden
                    className="absolute inset-0 -m-1.5 rounded-full bg-signal-500/40"
                  />
                  <div className="relative h-12 w-12 rounded-full bg-signal-500 text-night-900 flex items-center justify-center shadow-glow-signal">
                    <MapPin className="h-6 w-6" strokeWidth={2.4} />
                  </div>
                </div>
              </div>
            </div>

            {/* Adresse + CTAs */}
            <div className="p-5 space-y-4">
              <div>
                <div className="text-[10px] uppercase tracking-[0.18em] font-semibold text-signal-400">
                  Centre de formation
                </div>
                <div className="mt-1.5 font-semibold text-white text-[15px]">
                  {LEGAL.brand}
                </div>
                <div className="mt-1 text-white/80 text-sm leading-relaxed">
                  {LEGAL.address.street}
                  <br />
                  {LEGAL.address.postalCode} {LEGAL.address.city},{" "}
                  {LEGAL.address.country}
                </div>
              </div>

              <div className="flex flex-wrap gap-2">
                <a
                  href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(
                    `${LEGAL.address.street}, ${LEGAL.address.postalCode} ${LEGAL.address.city}`
                  )}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-[12px] font-semibold bg-white/[0.06] border border-white/10 text-white hover:bg-white/[0.10] hover:border-white/20 transition-colors"
                >
                  <MapPin className="h-3.5 w-3.5" />
                  Voir sur Google Maps
                </a>
                <a
                  href={`https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(
                    `${LEGAL.address.street}, ${LEGAL.address.postalCode} ${LEGAL.address.city}`
                  )}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-[12px] font-semibold bg-signal-500 text-night-900 hover:bg-signal-400 transition-colors shadow-sm"
                >
                  Itinéraire
                  <span aria-hidden>→</span>
                </a>
              </div>
            </div>
          </div>
        </aside>

        {/* Formulaire */}
        <section className="lg:col-span-2 min-w-0">
          <div className="rounded-3xl border border-white/10 bg-night-100 p-8 md:p-10">
            <h2 className="font-display text-2xl md:text-3xl font-semibold">
              Demander un rappel
            </h2>
            <p className="mt-2 text-white/65">
              Renseignez votre demande, nous vous recontactons sous 24 h ouvrées.
            </p>
            <div className="mt-8">
              <ContactForm />
            </div>
          </div>
        </section>
      </main>
    </SiteShell>
  );
}

function ContactRow({
  icon: Icon,
  label,
  value,
  href,
}: {
  icon: any;
  label: string;
  value: string;
  href: string;
}) {
  return (
    <a href={href} className="flex items-start gap-3 group min-w-0">
      <div className="h-9 w-9 rounded-lg bg-white/5 border border-white/10 text-signal-400 flex items-center justify-center shrink-0">
        <Icon className="h-4 w-4" />
      </div>
      <div className="min-w-0">
        <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-white/60">
          {label}
        </div>
        {/* break-words : l'email (insécable) forçait un débordement
            horizontal de la grille sur mobile 375px. */}
        <div className="text-white/90 group-hover:text-signal-400 transition mt-0.5 break-words">
          {value}
        </div>
      </div>
    </a>
  );
}
