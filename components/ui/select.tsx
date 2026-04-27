import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import * as React from "react";

export const Select = React.forwardRef<
  HTMLSelectElement,
  React.SelectHTMLAttributes<HTMLSelectElement>
>(({ className, children, ...props }, ref) => (
  <div className="relative">
    <select
      ref={ref}
      className={cn(
        "w-full h-11 appearance-none rounded-xl border border-navy-200 bg-white px-3.5 pr-10 text-[15px] text-navy-900 cursor-pointer",
        "transition-all duration-150",
        "focus:border-navy-600 focus:outline-none focus:ring-2 focus:ring-navy-600/15",
        "disabled:bg-navy-50 disabled:text-slate-400 disabled:cursor-not-allowed",
        className
      )}
      {...props}
    >
      {children}
    </select>
    <ChevronDown className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
  </div>
));
Select.displayName = "Select";
