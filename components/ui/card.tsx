import { cn } from "@/lib/utils";

export function Card({
  className,
  variant = "default",
  ...props
}: React.HTMLAttributes<HTMLDivElement> & { variant?: "default" | "outline" | "solid-navy" | "gold" }) {
  const variants = {
    default:
      "bg-white border border-navy-100 shadow-soft hover:shadow-raised transition-shadow duration-200",
    outline: "bg-transparent border border-navy-200",
    "solid-navy":
      "bg-navy-900 text-white border border-navy-800 shadow-raised",
    gold:
      "bg-gradient-to-br from-gold-50 to-white border border-gold-200 shadow-soft",
  } as const;
  return (
    <div
      className={cn("rounded-2xl", variants[variant], className)}
      {...props}
    />
  );
}

export function CardHeader({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("px-6 pt-6 pb-4", className)} {...props} />;
}

export function CardBody({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("p-6", className)} {...props} />;
}

export function CardTitle({ className, ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return (
    <h3
      className={cn(
        "font-display text-xl font-semibold text-navy-900 tracking-tight",
        className
      )}
      {...props}
    />
  );
}

export function CardDescription({
  className,
  ...props
}: React.HTMLAttributes<HTMLParagraphElement>) {
  return (
    <p className={cn("text-sm text-slate-600 mt-1", className)} {...props} />
  );
}
