"use client";
import { cn } from "@/lib/utils";
import { AlertCircle, CheckCircle2, Info, X } from "lucide-react";
import * as React from "react";

type ToastType = "success" | "error" | "info";
interface Toast {
  id: number;
  type: ToastType;
  message: string;
}

interface Ctx {
  toast: (message: string, type?: ToastType) => void;
}
const ToastCtx = React.createContext<Ctx | null>(null);

export function useToast() {
  const ctx = React.useContext(ToastCtx);
  if (!ctx) throw new Error("useToast hors ToastProvider");
  return ctx;
}

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = React.useState<Toast[]>([]);

  const toast = React.useCallback((message: string, type: ToastType = "info") => {
    const id = Date.now() + Math.random();
    setToasts((t) => [...t, { id, type, message }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 4000);
  }, []);

  const icons = {
    success: <CheckCircle2 className="h-4 w-4 text-emerald-600" />,
    error: <AlertCircle className="h-4 w-4 text-rose-600" />,
    info: <Info className="h-4 w-4 text-navy-600" />,
  };

  const borders = {
    success: "border-emerald-200 bg-emerald-50",
    error: "border-rose-200 bg-rose-50",
    info: "border-navy-100 bg-white",
  };

  return (
    <ToastCtx.Provider value={{ toast }}>
      {children}
      {/* aria-live : les nouveaux toasts sont annoncés par les lecteurs
          d'écran (polite) ; les erreurs passent en role=alert (assertive). */}
      <div
        aria-live="polite"
        className="fixed bottom-6 right-6 z-[100] flex flex-col gap-2 items-end"
      >
        {toasts.map((t) => (
          <div
            key={t.id}
            role={t.type === "error" ? "alert" : "status"}
            className={cn(
              // `relative` : ancre le bouton Fermer (absolute) sur CE toast
              // et non sur le conteneur fixe (bug visuel avec 2+ toasts).
              "relative flex items-start gap-2.5 rounded-xl border shadow-raised px-4 py-3 pr-10 min-w-[280px] max-w-sm",
              "animate-in slide-in-from-bottom-2",
              borders[t.type]
            )}
          >
            {icons[t.type]}
            <span className="text-sm text-navy-900 flex-1">{t.message}</span>
            <button
              onClick={() => setToasts((ts) => ts.filter((x) => x.id !== t.id))}
              className="absolute right-2 top-2 text-slate-400 hover:text-navy-900"
              aria-label="Fermer la notification"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          </div>
        ))}
      </div>
    </ToastCtx.Provider>
  );
}
