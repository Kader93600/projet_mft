import { cn } from "@/lib/utils";
import * as React from "react";

export const Textarea = React.forwardRef<
  HTMLTextAreaElement,
  React.TextareaHTMLAttributes<HTMLTextAreaElement>
>(({ className, ...props }, ref) => (
  <textarea
    ref={ref}
    className={cn(
      "w-full min-h-[120px] rounded-xl border border-navy-200 bg-white px-3.5 py-3 text-[15px] text-navy-900",
      "placeholder:text-slate-400",
      "transition-all duration-150",
      "focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15",
      "disabled:bg-navy-50 disabled:text-slate-400",
      "resize-vertical",
      className
    )}
    {...props}
  />
));
Textarea.displayName = "Textarea";
