import { cn } from "@/lib/utils";
import * as React from "react";

type Variant = "primary" | "secondary" | "ghost" | "gold" | "danger" | "outline";
type Size = "sm" | "md" | "lg";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
}

const variants: Record<Variant, string> = {
  primary:
    "bg-navy-900 text-white hover:bg-navy-800 active:bg-navy-950 shadow-soft hover:shadow-raised dark:bg-signal-500 dark:text-navy-950 dark:hover:bg-signal-400 dark:active:bg-signal-600",
  secondary:
    "bg-white text-navy-900 border border-navy-200 hover:bg-navy-50 hover:border-navy-300 dark:bg-[hsl(var(--surface))] dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))] dark:hover:bg-[hsl(var(--surface-2))]",
  outline:
    "bg-transparent text-navy-900 border border-navy-900/20 hover:border-navy-900/40 hover:bg-navy-900/5 dark:text-[hsl(var(--text))] dark:border-[hsl(var(--border))] dark:hover:border-signal-500/40 dark:hover:bg-white/5",
  ghost:
    "bg-transparent text-navy-700 hover:bg-navy-50 hover:text-navy-900 dark:text-[hsl(var(--text-muted))] dark:hover:bg-white/5 dark:hover:text-[hsl(var(--text))]",
  gold: "bg-gold-500 text-navy-900 hover:bg-gold-600 hover:text-white shadow-soft dark:bg-gold-600 dark:text-white dark:hover:bg-gold-500",
  danger:
    "bg-rose-600 text-white hover:bg-rose-700 dark:bg-rose-700 dark:hover:bg-rose-600",
};

const sizes: Record<Size, string> = {
  sm: "h-8 px-3 text-xs gap-1.5 rounded-lg",
  md: "h-10 px-4 text-sm gap-2 rounded-xl",
  lg: "h-12 px-6 text-[15px] gap-2 rounded-xl",
};

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", ...props }, ref) => (
    <button
      ref={ref}
      className={cn(
        "inline-flex items-center justify-center font-medium cursor-pointer whitespace-nowrap",
        // Motion : propriétés explicites + courbe premium ; press feedback
        // (scale) site-wide. Neutralisés sous prefers-reduced-motion.
        "transition-[transform,background-color,border-color,box-shadow,color] duration-200 ease-premium",
        "active:scale-[0.97] motion-reduce:transition-none motion-reduce:active:scale-100",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-navy-600 focus-visible:ring-offset-2 focus-visible:ring-offset-ivory dark:focus-visible:ring-signal-500 dark:focus-visible:ring-offset-[hsl(var(--bg))]",
        "disabled:opacity-40 disabled:pointer-events-none disabled:cursor-not-allowed",
        variants[variant],
        sizes[size],
        className
      )}
      {...props}
    />
  )
);
Button.displayName = "Button";
