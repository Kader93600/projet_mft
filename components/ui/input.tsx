import { cn } from "@/lib/utils";
import * as React from "react";

export const Input = React.forwardRef<
  HTMLInputElement,
  React.InputHTMLAttributes<HTMLInputElement>
>(({ className, ...props }, ref) => (
  <input
    ref={ref}
    className={cn(
      "w-full h-11 rounded-xl border border-navy-200 bg-white px-3.5 text-[15px] text-navy-900",
      "placeholder:text-slate-400",
      "transition-all duration-150",
      "focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15",
      "disabled:bg-navy-50 disabled:text-slate-400",
      className
    )}
    {...props}
  />
));
Input.displayName = "Input";

export function Label({
  className,
  ...props
}: React.LabelHTMLAttributes<HTMLLabelElement>) {
  return (
    <label
      className={cn(
        "block text-sm font-medium text-navy-900 mb-2",
        className
      )}
      {...props}
    />
  );
}
