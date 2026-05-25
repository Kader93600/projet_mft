"use client";
import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useTranslations } from "next-intl";
import { cn } from "@/lib/utils";
import { Menu, X } from "lucide-react";
import type { NavGroup } from "./nav-groups";

interface Props {
  groups: NavGroup[];
  labelKey?: string;
}

export function MobileNavSheet({ groups, labelKey = "navGroups.more" }: Props) {
  const t = useTranslations();
  const tA11y = useTranslations("a11y");
  const tCommon = useTranslations("common");
  const [open, setOpen] = React.useState(false);
  const pathname = usePathname();

  React.useEffect(() => {
    setOpen(false);
  }, [pathname]);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="flex flex-col items-center gap-1 min-w-[60px] px-2 py-1 text-[10px] font-semibold tracking-wide text-slate-500"
        aria-label={tA11y("openMenu")}
      >
        <Menu className="w-5 h-5" />
        {t(labelKey)}
      </button>

      {open && (
        <div className="fixed inset-0 z-50 md:hidden">
          <div
            className="absolute inset-0 bg-navy-950/50 backdrop-blur-sm"
            onClick={() => setOpen(false)}
          />
          <div className="absolute inset-x-0 bottom-0 max-h-[85vh] bg-white rounded-t-3xl shadow-float overflow-y-auto dark:bg-[hsl(var(--surface))]">
            <div className="sticky top-0 bg-white dark:bg-[hsl(var(--surface))] border-b border-navy-100 dark:border-[hsl(var(--border))] px-5 py-4 flex items-center justify-between">
              <div className="font-display text-lg font-semibold text-navy-950 dark:text-[hsl(var(--text))]">
                {t("navGroups.navigation")}
              </div>
              <button
                type="button"
                onClick={() => setOpen(false)}
                className="h-9 w-9 rounded-lg hover:bg-navy-50 dark:hover:bg-[hsl(var(--surface-2))] flex items-center justify-center"
                aria-label={tCommon("close")}
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="p-5 space-y-5">
              {groups.map((g) => (
                <div key={g.labelKey}>
                  <div className="text-[10px] font-semibold uppercase tracking-[0.14em] text-slate-400 dark:text-[hsl(var(--text-muted))] mb-2">
                    {t(g.labelKey)}
                  </div>
                  <div className="grid grid-cols-2 gap-2">
                    {g.items
                      .flatMap((it) =>
                        it.children ? [it, ...it.children] : [it]
                      )
                      .map((it) => {
                      const active =
                        pathname === it.href ||
                        pathname.startsWith(it.href + "/");
                      return (
                        <Link
                          key={it.href}
                          href={it.href}
                          className={cn(
                            "flex items-center gap-2 px-3 py-3 rounded-xl text-sm font-medium border transition",
                            active
                              ? "bg-navy-900 text-white border-navy-900"
                              : "bg-white dark:bg-[hsl(var(--surface-2))] text-navy-900 dark:text-[hsl(var(--text))] border-navy-100 dark:border-[hsl(var(--border))] hover:bg-navy-50 dark:hover:bg-[hsl(var(--surface))]"
                          )}
                        >
                          <it.icon className="w-4 h-4 shrink-0" />
                          <span className="truncate">{t(it.labelKey)}</span>
                        </Link>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
