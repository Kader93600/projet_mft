"use client";
import {
  useState,
  useTransition,
  useCallback,
} from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import {
  ArrowLeft,
  BellRing,
  Sparkles,
  RotateCcw,
  Loader2,
  Check,
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  NOTIFICATION_STYLES,
  type NotificationType,
} from "@/lib/notifications-icons";
import {
  type PreferenceState,
  type NotificationChannel,
  TYPE_DESCRIPTIONS,
  PREFERENCE_DISPLAY_ORDER,
  isTypeEnabled,
} from "@/lib/notification-preferences";
import {
  setNotificationPreference,
  resetNotificationPreferences,
} from "./actions";
import { PushSection } from "./push-section";

interface Props {
  initial: PreferenceState;
}

/**
 * Page de préférences : 1 ligne par type, 2 toggles (in_app + push).
 * Push reste interactif même si la Phase C n'est pas encore branchée
 * (l'utilisateur configure à l'avance, ses préférences s'appliqueront
 * automatiquement quand le service push sera activé).
 */
export function PreferencesClient({ initial }: Props) {
  const [prefs, setPrefs] = useState<PreferenceState>(initial);
  const [pending, startTransition] = useTransition();
  const [resetting, setResetting] = useState(false);
  const router = useRouter();

  const handleToggle = useCallback(
    (type: NotificationType, channel: NotificationChannel) => {
      const wasEnabled = isTypeEnabled(prefs, type, channel);
      const willBeEnabled = !wasEnabled;

      // Optimistic update
      setPrefs((prev) => {
        const key = `${channel}_disabled` as const;
        const list = prev[key];
        const next = willBeEnabled
          ? list.filter((t) => t !== type)
          : Array.from(new Set([...list, type]));
        return { ...prev, [key]: next };
      });

      startTransition(async () => {
        const res = await setNotificationPreference(
          type,
          channel,
          willBeEnabled
        );
        if (!res.ok) {
          // Rollback si erreur
          setPrefs((prev) => {
            const key = `${channel}_disabled` as const;
            const list = prev[key];
            const next = wasEnabled
              ? list.filter((t) => t !== type)
              : Array.from(new Set([...list, type]));
            return { ...prev, [key]: next };
          });
        }
      });
    },
    [prefs]
  );

  const handleReset = useCallback(() => {
    if (
      typeof window !== "undefined" &&
      !window.confirm(
        "Réinitialiser toutes tes préférences de notifications ? Tous les types seront réactivés."
      )
    )
      return;
    setResetting(true);
    startTransition(async () => {
      await resetNotificationPreferences();
      setPrefs({
        in_app_disabled: [],
        push_disabled: [],
        email_disabled: [],
      });
      setResetting(false);
      router.refresh();
    });
  }, [router]);

  const totalDisabled =
    prefs.in_app_disabled.length + prefs.push_disabled.length;

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <header>
        <Link
          href="/notifications"
          className="inline-flex items-center gap-1.5 text-[12px] font-semibold text-slate-500 hover:text-navy-700 transition-colors"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Retour aux notifications
        </Link>
        <div className="mt-3 flex items-center gap-2">
          <BellRing className="h-4 w-4 text-gold-700" />
          <span className="eyebrow text-gold-700">Préférences</span>
        </div>
        <h1 className="mt-2 font-display text-3xl font-semibold text-navy-950 tracking-tight">
          Notifications
        </h1>
        <p className="mt-2 text-slate-600 text-sm leading-relaxed max-w-2xl">
          Choisis les types de notifications que tu souhaites recevoir, et
          sur quels canaux. Le canal{" "}
          <span className="font-semibold text-navy-800">Centre</span> gère
          ce qui apparaît dans ta cloche, le canal{" "}
          <span className="font-semibold text-navy-800">Push</span> gère
          les alertes navigateur.
        </p>
      </header>

      {/* Section Push (header card) */}
      <PushSection />

      {/* Carte récap */}
      <div className="bg-white border border-navy-100 rounded-2xl shadow-soft px-5 py-4 flex items-center gap-4">
        <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-navy-50 via-white to-gold-50 border border-navy-100 flex items-center justify-center shrink-0">
          <Sparkles className="h-4 w-4 text-gold-700" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-[13.5px] font-semibold text-navy-900">
            {totalDisabled === 0
              ? "Toutes les notifications sont activées"
              : `${totalDisabled} type${totalDisabled > 1 ? "s" : ""} désactivé${totalDisabled > 1 ? "s" : ""}`}
          </p>
          <p className="text-[12px] text-slate-500 mt-0.5">
            Modifie un toggle pour ajuster ce qui apparaît dans ton centre
            de notifications.
          </p>
        </div>
        {totalDisabled > 0 && (
          <button
            type="button"
            onClick={handleReset}
            disabled={pending}
            className={cn(
              "shrink-0 inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[12px] font-semibold",
              "text-navy-700 bg-white border border-navy-100 hover:bg-navy-50 hover:text-navy-900",
              "transition-colors duration-150 ease-out disabled:opacity-50"
            )}
          >
            {resetting ? (
              <Loader2 className="h-3.5 w-3.5 animate-spin" />
            ) : (
              <RotateCcw className="h-3.5 w-3.5" />
            )}
            Réinitialiser
          </button>
        )}
      </div>

      {/* Tableau des toggles */}
      <div className="bg-white border border-navy-100 rounded-2xl shadow-soft overflow-hidden">
        {/* En-tête colonnes (desktop only) */}
        <div className="hidden sm:grid grid-cols-[1fr_88px_88px] items-center gap-4 px-5 py-3 border-b border-navy-100 bg-navy-50/40">
          <div className="text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500">
            Type
          </div>
          <div className="text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500 text-center">
            Centre
          </div>
          <div className="text-[10.5px] font-bold uppercase tracking-[0.14em] text-slate-500 text-center">
            Push
          </div>
        </div>

        <ul className="divide-y divide-navy-50">
          {PREFERENCE_DISPLAY_ORDER.map((type) => {
            const style = NOTIFICATION_STYLES[type];
            const Icon = style.icon;
            const inAppOn = isTypeEnabled(prefs, type, "in_app");
            const pushOn = isTypeEnabled(prefs, type, "push");
            return (
              <li
                key={type}
                className="grid grid-cols-[1fr_auto] sm:grid-cols-[1fr_88px_88px] items-center gap-x-4 gap-y-3 px-5 py-4"
              >
                {/* Type */}
                <div className="flex items-start gap-3 min-w-0">
                  <span
                    className={cn(
                      "h-9 w-9 rounded-xl border flex items-center justify-center shrink-0",
                      style.tone
                    )}
                    aria-hidden
                  >
                    <Icon className="h-4 w-4" />
                  </span>
                  <div className="min-w-0">
                    <p className="text-[13.5px] font-semibold text-navy-950 leading-snug">
                      {style.label}
                    </p>
                    <p className="text-[12px] text-slate-500 mt-0.5 leading-relaxed">
                      {TYPE_DESCRIPTIONS[type]}
                    </p>
                  </div>
                </div>

                {/* Toggle Centre — mobile compact + desktop center */}
                <div className="sm:flex sm:justify-center col-start-1 sm:col-start-2 row-start-2 sm:row-start-auto flex items-center gap-3 sm:gap-0">
                  <span className="sm:hidden text-[11px] font-semibold text-slate-500 uppercase tracking-wide">
                    Centre
                  </span>
                  <Toggle
                    on={inAppOn}
                    onChange={() => handleToggle(type, "in_app")}
                    aria-label={`${style.label} — Centre de notifications`}
                  />
                </div>

                {/* Toggle Push */}
                <div className="sm:flex sm:justify-center col-start-2 sm:col-start-3 row-start-1 sm:row-start-auto flex items-center gap-3 sm:gap-0">
                  <span className="sm:hidden text-[11px] font-semibold text-slate-500 uppercase tracking-wide">
                    Push
                  </span>
                  <Toggle
                    on={pushOn}
                    onChange={() => handleToggle(type, "push")}
                    aria-label={`${style.label} — Notifications push`}
                  />
                </div>
              </li>
            );
          })}
        </ul>
      </div>

    </div>
  );
}

// ── Toggle ─────────────────────────────────────────────────────

function Toggle({
  on,
  onChange,
  ...rest
}: {
  on: boolean;
  onChange: () => void;
} & Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "onChange">) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      onClick={onChange}
      {...rest}
      className={cn(
        "relative inline-flex items-center h-6 w-11 rounded-full",
        "transition-colors duration-200 ease-out",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-navy-300",
        on
          ? "bg-gradient-to-r from-gold-500 to-gold-600"
          : "bg-navy-100 hover:bg-navy-200"
      )}
    >
      <span
        className={cn(
          "inline-block h-5 w-5 rounded-full bg-white shadow-soft",
          "transform transition-transform duration-200 ease-out",
          "flex items-center justify-center",
          on ? "translate-x-5" : "translate-x-0.5"
        )}
        aria-hidden
      >
        {on && <Check className="h-3 w-3 text-gold-700" strokeWidth={3} />}
      </span>
    </button>
  );
}
