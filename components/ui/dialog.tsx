"use client";
import { cn } from "@/lib/utils";
import { X } from "lucide-react";
import * as React from "react";
import { createPortal } from "react-dom";

interface DialogProps {
  open: boolean;
  onClose: () => void;
  children: React.ReactNode;
  size?: "sm" | "md" | "lg" | "xl";
}

export function Dialog({ open, onClose, children, size = "md" }: DialogProps) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => setMounted(true), []);

  React.useEffect(() => {
    function onEsc(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    if (open) {
      document.addEventListener("keydown", onEsc);
      document.body.style.overflow = "hidden";
      return () => {
        document.removeEventListener("keydown", onEsc);
        document.body.style.overflow = "";
      };
    }
  }, [open, onClose]);

  if (!mounted || !open) return null;

  const sizes = {
    sm: "max-w-md",
    md: "max-w-lg",
    lg: "max-w-2xl",
    xl: "max-w-4xl",
  };

  return createPortal(
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div
        className="absolute inset-0 bg-navy-950/50 backdrop-blur-sm animate-in fade-in"
        onClick={onClose}
      />
      <div
        className={cn(
          "relative w-full bg-white rounded-2xl shadow-float border border-navy-100",
          "max-h-[90vh] overflow-hidden flex flex-col animate-in zoom-in-95",
          sizes[size]
        )}
      >
        {children}
      </div>
    </div>,
    document.body
  );
}

export function DialogHeader({
  title,
  description,
  onClose,
}: {
  title: string;
  description?: string;
  onClose?: () => void;
}) {
  return (
    <div className="flex items-start justify-between px-6 pt-6 pb-4 border-b border-navy-50">
      <div>
        <h2 className="font-display text-xl font-semibold text-navy-900 tracking-tight">
          {title}
        </h2>
        {description && <p className="mt-1 text-sm text-slate-600">{description}</p>}
      </div>
      {onClose && (
        <button
          onClick={onClose}
          className="h-8 w-8 rounded-lg text-slate-400 hover:bg-navy-50 hover:text-navy-900 inline-flex items-center justify-center transition-colors"
          aria-label="Fermer"
        >
          <X className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}

export function DialogBody({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <div className={cn("p-6 overflow-y-auto", className)}>{children}</div>;
}

export function DialogFooter({ children }: { children: React.ReactNode }) {
  return (
    <div className="px-6 py-4 border-t border-navy-50 flex items-center justify-end gap-2 bg-navy-50/30">
      {children}
    </div>
  );
}
