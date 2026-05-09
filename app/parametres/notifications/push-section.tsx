"use client";
import { useEffect, useState, useTransition, useCallback } from "react";
import {
  BellRing,
  BellOff,
  Loader2,
  Check,
  AlertTriangle,
  Send,
  ShieldOff,
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  getPushStatus,
  subscribeToPush,
  unsubscribeFromPush,
  sendTestPush,
  type PushStatus,
} from "@/lib/push";

/**
 * Carte Push : header de la page Préférences. Gère la permission
 * navigateur, l'enregistrement de l'abonnement, le test et le
 * désabonnement.
 *
 * États visibles :
 *   - unsupported : navigateur incompatible
 *   - default     : permission jamais demandée → CTA "Activer"
 *   - granted     : abonné, push actif → CTA "Test" + "Désactiver"
 *   - granted_unsubscribed : permission OK mais pas abonné → CTA "Activer"
 *   - denied      : permission bloquée → message d'aide
 */
export function PushSection() {
  const [status, setStatus] = useState<PushStatus>("unsupported");
  const [loading, setLoading] = useState(true);
  const [pending, startTransition] = useTransition();
  const [feedback, setFeedback] = useState<{
    kind: "success" | "error";
    msg: string;
  } | null>(null);

  const refreshStatus = useCallback(async () => {
    const s = await getPushStatus();
    setStatus(s);
    setLoading(false);
  }, []);

  useEffect(() => {
    void refreshStatus();
  }, [refreshStatus]);

  // Auto-clear du feedback au bout de 4s
  useEffect(() => {
    if (!feedback) return;
    const id = window.setTimeout(() => setFeedback(null), 4000);
    return () => window.clearTimeout(id);
  }, [feedback]);

  const handleEnable = () => {
    startTransition(async () => {
      try {
        await subscribeToPush();
        setFeedback({
          kind: "success",
          msg: "Notifications push activées sur cet appareil.",
        });
        await refreshStatus();
      } catch (err: any) {
        setFeedback({
          kind: "error",
          msg: err?.message ?? "Échec de l'activation.",
        });
        await refreshStatus();
      }
    });
  };

  const handleDisable = () => {
    startTransition(async () => {
      try {
        await unsubscribeFromPush();
        setFeedback({
          kind: "success",
          msg: "Notifications push désactivées sur cet appareil.",
        });
      } catch (err: any) {
        setFeedback({
          kind: "error",
          msg: err?.message ?? "Échec de la désactivation.",
        });
      }
      await refreshStatus();
    });
  };

  const handleTest = () => {
    startTransition(async () => {
      const res = await sendTestPush();
      if (res.ok) {
        setFeedback({
          kind: "success",
          msg:
            res.sent && res.sent > 0
              ? `Push de test envoyé à ${res.sent} appareil${res.sent > 1 ? "s" : ""}.`
              : "Test envoyé.",
        });
      } else {
        setFeedback({
          kind: "error",
          msg:
            res.error === "no_subscriptions"
              ? "Aucun abonnement actif. Active d'abord les notifications."
              : res.error === "vapid_not_configured"
                ? "Configuration serveur incomplète (clés VAPID manquantes)."
                : res.error ?? "Échec d'envoi du test.",
        });
      }
    });
  };

  // ── Rendu par état ───────────────────────────────────────────
  return (
    <div className="bg-white border border-navy-100 rounded-2xl shadow-soft p-5">
      <div className="flex items-start gap-4">
        <div
          className={cn(
            "h-11 w-11 rounded-xl border flex items-center justify-center shrink-0",
            status === "granted"
              ? "bg-gradient-to-br from-gold-50 to-gold-100 border-gold-200 text-gold-800"
              : status === "denied"
                ? "bg-rose-50 border-rose-200 text-rose-700"
                : "bg-navy-50 border-navy-100 text-navy-700"
          )}
        >
          {status === "granted" ? (
            <BellRing className="h-5 w-5" />
          ) : status === "denied" ? (
            <ShieldOff className="h-5 w-5" />
          ) : (
            <BellOff className="h-5 w-5" />
          )}
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <h2 className="font-display text-[15px] font-semibold text-navy-950 tracking-tight">
              Notifications push (navigateur)
            </h2>
            <StatusPill status={status} loading={loading} />
          </div>
          <p className="mt-1 text-[12.5px] text-slate-600 leading-relaxed">
            {messageForStatus(status)}
          </p>

          {/* Actions */}
          <div className="mt-4 flex items-center gap-2 flex-wrap">
            {(status === "default" || status === "granted_unsubscribed") && (
              <button
                type="button"
                onClick={handleEnable}
                disabled={pending || loading}
                className={cn(
                  "inline-flex items-center gap-1.5 px-3.5 py-2 rounded-lg text-[12.5px] font-semibold",
                  "bg-navy-900 text-white hover:bg-navy-950",
                  "transition-colors duration-150 ease-out",
                  "disabled:opacity-50 disabled:cursor-not-allowed"
                )}
              >
                {pending ? (
                  <Loader2 className="h-3.5 w-3.5 animate-spin" />
                ) : (
                  <BellRing className="h-3.5 w-3.5" />
                )}
                Activer les notifications
              </button>
            )}
            {status === "granted" && (
              <>
                <button
                  type="button"
                  onClick={handleTest}
                  disabled={pending}
                  className={cn(
                    "inline-flex items-center gap-1.5 px-3.5 py-2 rounded-lg text-[12.5px] font-semibold",
                    "text-navy-700 bg-white border border-navy-100 hover:bg-navy-50 hover:text-navy-900",
                    "transition-colors duration-150 ease-out disabled:opacity-50"
                  )}
                >
                  {pending ? (
                    <Loader2 className="h-3.5 w-3.5 animate-spin" />
                  ) : (
                    <Send className="h-3.5 w-3.5" />
                  )}
                  Envoyer un test
                </button>
                <button
                  type="button"
                  onClick={handleDisable}
                  disabled={pending}
                  className={cn(
                    "inline-flex items-center gap-1.5 px-3 py-2 rounded-lg text-[12.5px] font-semibold",
                    "text-slate-500 hover:text-rose-600 bg-white border border-navy-100 hover:bg-rose-50 hover:border-rose-200",
                    "transition-colors duration-150 ease-out disabled:opacity-50"
                  )}
                >
                  <BellOff className="h-3.5 w-3.5" />
                  Désactiver
                </button>
              </>
            )}
            {status === "denied" && (
              <p className="text-[11.5px] text-slate-500 leading-relaxed">
                Pour réautoriser : ouvre les réglages du site dans ton
                navigateur (icône cadenas dans la barre d&apos;adresse) →
                Notifications → Autoriser, puis recharge la page.
              </p>
            )}
            {status === "unsupported" && (
              <p className="text-[11.5px] text-slate-500 leading-relaxed">
                Ce navigateur ne supporte pas les notifications push.
                Essaie Chrome, Firefox, Edge ou Safari récent.
              </p>
            )}
          </div>

          {/* Feedback inline */}
          {feedback && (
            <div
              role="status"
              className={cn(
                "mt-3 flex items-start gap-2 px-3 py-2 rounded-lg text-[11.5px] font-medium",
                "animate-notif-pop",
                feedback.kind === "success"
                  ? "bg-gold-50 text-gold-900 border border-gold-200"
                  : "bg-rose-50 text-rose-800 border border-rose-200"
              )}
            >
              {feedback.kind === "success" ? (
                <Check className="h-3.5 w-3.5 mt-0.5 shrink-0" />
              ) : (
                <AlertTriangle className="h-3.5 w-3.5 mt-0.5 shrink-0" />
              )}
              <span className="leading-relaxed">{feedback.msg}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Pieces ─────────────────────────────────────────────────────

function StatusPill({
  status,
  loading,
}: {
  status: PushStatus;
  loading: boolean;
}) {
  if (loading) {
    return (
      <span className="inline-flex items-center gap-1 rounded-full bg-navy-50 text-navy-700 text-[10px] font-bold px-2 py-0.5 tracking-wide uppercase">
        <Loader2 className="h-2.5 w-2.5 animate-spin" />
        Chargement
      </span>
    );
  }
  const conf = (() => {
    switch (status) {
      case "granted":
        return { label: "Actif", cls: "bg-gold-100 text-gold-800" };
      case "default":
      case "granted_unsubscribed":
        return { label: "Inactif", cls: "bg-navy-100 text-navy-700" };
      case "denied":
        return { label: "Bloqué", cls: "bg-rose-100 text-rose-700" };
      case "unsupported":
        return { label: "Non supporté", cls: "bg-slate-100 text-slate-600" };
    }
  })();
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full text-[10px] font-bold px-2 py-0.5 tracking-wide uppercase",
        conf.cls
      )}
    >
      {conf.label}
    </span>
  );
}

function messageForStatus(status: PushStatus): string {
  switch (status) {
    case "granted":
      return "Tu reçois les alertes du navigateur même quand l'application est fermée. Modifie les types ci-dessous pour ajuster ce qui déclenche un push.";
    case "default":
      return "Active les notifications push pour être prévenu en temps réel des messages, examens et résultats — même quand l'onglet est fermé.";
    case "granted_unsubscribed":
      return "Permission accordée mais aucun appareil n'est abonné. Active pour t'inscrire sur ce navigateur.";
    case "denied":
      return "Les notifications sont actuellement bloquées par ton navigateur.";
    case "unsupported":
      return "Les notifications push ne sont pas disponibles sur ce navigateur.";
  }
}
