import Link from "next/link";
import { getTranslations } from "next-intl/server";
import { Logo } from "@/components/ui/logo";
import { ArrowLeft, Mail, ShieldCheck, ArrowRight } from "lucide-react";
import { LEGAL } from "@/lib/legal-config";

export const metadata = {
  title: "Inscription — contactez-nous",
  description:
    "Les comptes stagiaires sont créés par notre équipe pédagogique après confirmation de votre dossier d'inscription.",
  robots: { index: false, follow: false },
};

/**
 * /signup est désactivé : les inscriptions passent désormais par l'école
 * (création de compte par admin / super-admin uniquement). Cette page
 * informe les visiteurs et les redirige vers /contact.
 */
export default async function SignupClosedPage() {
  const t = await getTranslations("signup");
  const tCommon = await getTranslations("common");

  return (
    <div className="min-h-screen flex items-center justify-center bg-ivory dark:bg-[hsl(var(--bg))] px-6 py-16">
      <div className="max-w-xl w-full">
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-navy-900 dark:text-[hsl(var(--text-muted))] dark:hover:text-[hsl(var(--text))] transition mb-8"
        >
          <ArrowLeft className="h-4 w-4" /> {tCommon("backToSite")}
        </Link>

        <div
          className="rounded-3xl bg-white dark:bg-[hsl(var(--surface))] border border-navy-100 dark:border-[hsl(var(--border))] p-8 md:p-10 shadow-soft"
          style={{ animation: "fade-up 0.6s ease-out both" }}
        >
          <div className="flex items-center gap-3 mb-6">
            <Logo size="sm" />
          </div>

          <div
            className="h-12 w-12 rounded-2xl bg-brand-50 text-brand-700 dark:bg-brand-500/10 dark:text-signal-400 flex items-center justify-center"
            style={{
              animation:
                "fade-up 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) 0.1s both",
            }}
          >
            <ShieldCheck className="h-6 w-6" />
          </div>

          <h1
            className="mt-5 font-display text-2xl md:text-3xl font-semibold text-navy-950 dark:text-[hsl(var(--text))] tracking-tight"
            style={{ animation: "fade-up 0.5s ease-out 0.15s both" }}
          >
            {t("closedTitle")}
          </h1>

          <p
            className="mt-3 text-slate-600 dark:text-[hsl(var(--text-muted))] leading-relaxed"
            style={{ animation: "fade-up 0.5s ease-out 0.25s both" }}
          >
            {t("closedIntro")}{" "}
            <strong className="text-navy-900 dark:text-[hsl(var(--text))]">
              {t("closedIntroStrong")}
            </strong>
            .
          </p>

          <p
            className="mt-3 text-slate-600 dark:text-[hsl(var(--text-muted))] leading-relaxed"
            style={{ animation: "fade-up 0.5s ease-out 0.32s both" }}
          >
            {t("closedDelay")} <strong>{t("closedDelayStrong")}</strong>.
          </p>

          <div
            className="mt-8 grid sm:grid-cols-2 gap-3"
            style={{ animation: "fade-up 0.5s ease-out 0.4s both" }}
          >
            <Link
              href="/contact"
              className="group rounded-2xl bg-navy-900 text-white p-5 hover:bg-navy-800 transition flex items-start gap-3"
            >
              <Mail className="h-5 w-5 shrink-0 mt-0.5" />
              <div className="flex-1 min-w-0">
                <div className="font-semibold">{t("contactForm")}</div>
                <div className="text-xs text-white/60 mt-0.5">
                  {t("contactFormSubtitle")}
                </div>
              </div>
              <ArrowRight className="h-4 w-4 mt-0.5 shrink-0 transition-transform group-hover:translate-x-0.5" />
            </Link>
            <a
              href={`mailto:${LEGAL.email}`}
              className="group rounded-2xl bg-white dark:bg-[hsl(var(--surface-2))] border border-navy-100 dark:border-[hsl(var(--border))] p-5 hover:border-brand-300 hover:shadow-soft transition flex items-start gap-3"
            >
              <Mail className="h-5 w-5 text-brand-700 dark:text-signal-400 shrink-0 mt-0.5" />
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-navy-900 dark:text-[hsl(var(--text))]">
                  {t("emailDirect")}
                </div>
                <div className="text-xs text-slate-500 dark:text-[hsl(var(--text-muted))] mt-0.5 truncate">
                  {LEGAL.email}
                </div>
              </div>
            </a>
          </div>

          <div
            className="mt-8 pt-6 border-t border-navy-50 dark:border-[hsl(var(--border))] text-center text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]"
            style={{ animation: "fade-up 0.5s ease-out 0.5s both" }}
          >
            {t("alreadyAccount")}{" "}
            <Link
              href="/login"
              className="font-semibold text-brand-700 hover:text-brand-900 dark:text-signal-400 dark:hover:text-signal-300 underline-offset-4 hover:underline"
            >
              {t("loginLink")}
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
