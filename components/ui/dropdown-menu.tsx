"use client";
import { cn } from "@/lib/utils";
import * as React from "react";

interface Ctx {
  open: boolean;
  setOpen: (v: boolean) => void;
}
const DDCtx = React.createContext<Ctx | null>(null);

export function DropdownMenu({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = React.useState(false);
  const ref = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    function onClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    if (open) document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, [open]);

  return (
    <DDCtx.Provider value={{ open, setOpen }}>
      <div ref={ref} className="relative inline-block">
        {children}
      </div>
    </DDCtx.Provider>
  );
}

export function DropdownMenuTrigger({ children }: { children: React.ReactElement }) {
  const ctx = React.useContext(DDCtx)!;
  return React.cloneElement(children, {
    onClick: (e: React.MouseEvent) => {
      e.preventDefault();
      ctx.setOpen(!ctx.open);
    },
  });
}

export function DropdownMenuContent({
  children,
  align = "right",
  className,
}: {
  children: React.ReactNode;
  align?: "left" | "right";
  className?: string;
}) {
  const ctx = React.useContext(DDCtx)!;
  if (!ctx.open) return null;
  return (
    <div
      className={cn(
        "absolute z-40 mt-1 min-w-[180px] bg-white border border-navy-100 rounded-xl shadow-float p-1 animate-in fade-in slide-in-from-top-1",
        align === "right" ? "right-0" : "left-0",
        className
      )}
    >
      {children}
    </div>
  );
}

export function DropdownMenuItem({
  children,
  onClick,
  destructive,
  className,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  destructive?: boolean;
  className?: string;
}) {
  const ctx = React.useContext(DDCtx)!;
  return (
    <button
      type="button"
      onClick={() => {
        onClick?.();
        ctx.setOpen(false);
      }}
      className={cn(
        "w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-left transition-colors",
        destructive
          ? "text-rose-700 hover:bg-rose-50"
          : "text-navy-800 hover:bg-navy-50",
        className
      )}
    >
      {children}
    </button>
  );
}

export function DropdownMenuSeparator() {
  return <div className="my-1 h-px bg-navy-50" />;
}
