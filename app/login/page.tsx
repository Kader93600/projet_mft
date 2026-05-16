import Link from "next/link";
import { getTranslations } from "next-intl/server";
import { LoginForm } from "./login-form";
import { Logo } from "@/components/ui/logo";
import {
  ShieldCheck,
  Award,
  Sparkles,
  ArrowLeft,
  Users2,
} from "lucide-react";
import { LEGAL } from "@/lib/legal-config";
import { FORMATIONS } from "@/lib/formations-config";

export default async function LoginPage() {
  const t = await getTranslations("auth");
  const tCommon = await getTranslations("common");
  const tFooter = await getTranslations("footer");
  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-night text-white">
      {/* Left — Visual panel (dark mode brand) */}
      <aside className="relative hidden lg:flex flex-col justify-between p-10 overflow-hidden">
        {/* Backgrounds */}
        <div className="absolute inset-0 bg-mesh-night opacity-90" />
        <div
          className="absolute inset-0 bg-grid-night opacity-30"
          style={{
            backgroundSize: "56px 56px",
            maskImage: "linear-gradient(to bottom, black 0%, black 60%, transparent 100%)",
          }}
        />
        <div
          aria-hidden="true"
          className="absolute -top-32 -right-32 h-96 w-96 rounded-full bg-signal-500/15 blur-3xl pointer-events-none"
        />
        <div
          aria-hidden="true"
          className="absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-brand-500/20 blur-3xl pointer-events-none"
        />

        <div className="relative">
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-sm text-white/70 hover:text-white transition"
          >
            <ArrowLeft className="h-4 w-4" />
            {tCommon("backToSite")}
          </Link>
        </div>

        <div className="relative space-y-8 max-w-md">
          <span className="inline-flex items-center gap-1.5 rounded-full border border-signal-500/30 bg-signal-500/10 px-3 py-1 text-xs font-medium text-signal-300">
            <Sparkles className="h-3 w-3" />
            {t("transportFormations", { count: FORMATIONS.length })}
          </span>
          <h2 className="font-display text-4xl leading-[1.05] tracking-tight">
            {t("schoolTaglinePart1")}{" "}
            <span className="italic text-signal-400">
              {t("schoolTaglineHighlight")}
            </span>
            .
          </h2>
          <p className="text-white/70 text-[15px] leading-relaxed">
            {t("schoolDescription")}
          </p>

          <ul className="space-y-3 text-sm">
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <ShieldCheck className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">{t("qualiopiCertified")}</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <Award className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">{t("officialDiplomas")}</span>
            </li>
            <li className="flex items-start gap-3">
              <span className="mt-0.5 inline-flex h-6 w-6 items-center justify-center rounded-md bg-signal-500/15 border border-signal-500/30 text-signal-400">
                <Users2 className="h-3.5 w-3.5" />
              </span>
              <span className="text-white/85">{t("coachAvailable")}</span>
            </li>
          </ul>

          {/* Logos formations */}
          <div className="pt-4 border-t border-white/10">
            <div className="text-[10px] uppercase tracking-[0.18em] text-white/45 mb-3">
              {t("preparationFor")}
            </div>
            <div className="flex flex-wrap gap-1.5">
              {FORMATIONS.slice(0, 6).map((f) => (
                <span
                  key={f.slug}
                  className="text-[10px] font-semibold uppercase tracking-wider px-2 py-1 rounded-md border border-white/10 bg-white/5 text-white/65"
                >
                  {f.code}
                </span>
              ))}
              <span className="text-[10px] font-semibold uppercase tracking-wider px-2 py-1 rounded-md border border-signal-500/30 bg-signal-500/10 text-signal-400">
                {t("otherFormations", { count: FORMATIONS.length - 6 })}
              </span>
            </div>
          </div>
        </div>

        <div className="relative text-xs text-white/45 tracking-wide uppercase">
          © {new Date().getFullYear()} {LEGAL.brand}
        </div>
      </aside>

      {/* Right — Form */}
      <main className="flex items-center justify-center p-6 sm:p-10 bg-ivory text-ink dark:bg-[hsl(var(--bg))] dark:text-[hsl(var(--text))]">
        <div className="w-full max-w-md">
          <div className="lg:hidden mb-8 flex justify-center">
            <Logo />
          </div>

          <div className="mb-8">
            <span className="text-[11px] font-semibold uppercase tracking-[0.18em] text-signal-700 dark:text-signal-400">
              {t("personalSpace")}
            </span>
            <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 dark:text-[hsl(var(--text))] tracking-tight">
              {t("loginTitle")}
            </h1>
            <p className="mt-2 text-[15px] text-slate-600 dark:text-[hsl(var(--text-muted))]">
              {t("loginSubtitle")}
            </p>
          </div>

          <div className="rounded-2xl border border-navy-100 bg-white p-8 shadow-soft dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))]">
            <LoginForm />
          </div>

          <p className="mt-6 text-center text-sm text-slate-600 dark:text-[hsl(var(--text-muted))]">
            {t("noAccount")}{" "}
            <Link
              href="/contact"
              className="font-semibold text-brand-700 hover:text-brand-900 dark:text-signal-400 dark:hover:text-signal-300 underline-offset-4 hover:underline"
            >
              {t("contactSchool")}
            </Link>
          </p>
          <p className="mt-2 text-center text-xs text-slate-400 dark:text-[hsl(var(--text-muted))]">
            {t("accountsCreatedBy")}
          </p>

          <div className="mt-10 pt-6 border-t border-navy-100 dark:border-[hsl(var(--border))] flex flex-wrap justify-center gap-x-4 gap-y-1 text-xs text-slate-500 dark:text-[hsl(var(--text-muted))]">
            <Link href="/mentions-legales" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              {tFooter("legal")}
            </Link>
            <Link href="/cgu" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              {tFooter("cgu")}
            </Link>
            <Link href="/cgv" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              {tFooter("cgv")}
            </Link>
            <Link href="/confidentialite" className="hover:text-navy-900 dark:hover:text-[hsl(var(--text))]">
              {tFooter("privacy")}
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
