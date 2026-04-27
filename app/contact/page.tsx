import { SiteShell, PageHero } from "@/components/site/site-shell";
import { LEGAL } from "@/lib/legal-config";
import { Mail, Phone, MapPin, Clock, MessageCircle } from "lucide-react";
import { ContactForm } from "./contact-form";

export const metadata = {
  title: `Contact — ${LEGAL.brand}`,
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
        <aside className="space-y-6">
          <div className="rounded-2xl border border-white/10 bg-night-100 p-6">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-signal-500/15 border border-signal-500/30 text-signal-400 flex items-center justify-center">
                <MapPin className="h-5 w-5" />
              </div>
              <div className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/45">
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
              <div className="flex items-center gap-2 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/45 mb-1.5">
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

          {/* Carte (placeholder OSM/iframe) */}
          <div className="rounded-2xl border border-white/10 bg-night-100 overflow-hidden">
            <iframe
              src={`https://www.openstreetmap.org/export/embed.html?bbox=2.85%2C48.93%2C2.92%2C48.97&layer=mapnik&marker=48.9528%2C2.8839`}
              width="100%"
              height="220"
              style={{ border: 0 }}
              loading="lazy"
              title="Carte du centre"
            />
            <div className="px-4 py-3 text-xs text-white/55">
              Centre de {LEGAL.brand} — {LEGAL.address.city}
            </div>
          </div>
        </aside>

        {/* Formulaire */}
        <section className="lg:col-span-2">
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
    <a href={href} className="flex items-start gap-3 group">
      <div className="h-9 w-9 rounded-lg bg-white/5 border border-white/10 text-signal-400 flex items-center justify-center shrink-0">
        <Icon className="h-4 w-4" />
      </div>
      <div>
        <div className="text-[10px] font-semibold uppercase tracking-[0.16em] text-white/45">
          {label}
        </div>
        <div className="text-white/90 group-hover:text-signal-400 transition mt-0.5">
          {value}
        </div>
      </div>
    </a>
  );
}
