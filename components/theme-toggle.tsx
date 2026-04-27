"use client";
import { useEffect, useState } from "react";
import { Moon, Sun, Monitor } from "lucide-react";
import { cn } from "@/lib/utils";

type Theme = "light" | "dark" | "system";

const COOKIE = "gotrm-theme";
function setCookie(value: Theme) {
  // 1 an, sameSite Lax, partagé sur tout le site
  document.cookie = `${COOKIE}=${value}; Path=/; Max-Age=${60 * 60 * 24 * 365}; SameSite=Lax`;
}

// Script inline injecté en <head> AVANT toute peinture.
// Lit le cookie ou localStorage, applique class="dark" + colorScheme.
export function ThemeInit() {
  return (
    <script
      // Important : utiliser dangerouslySetInnerHTML pour qu'il reste sync.
      dangerouslySetInnerHTML={{
        __html: `
(function(){
  try {
    var c = document.cookie.split('; ').find(function(r){return r.indexOf('${COOKIE}=')===0;});
    var t = c ? c.split('=')[1] : (localStorage.getItem('theme') || 'system');
    var m = window.matchMedia('(prefers-color-scheme: dark)').matches;
    var dark = t === 'dark' || (t === 'system' && m);
    var root = document.documentElement;
    if (dark) root.classList.add('dark');
    root.style.colorScheme = dark ? 'dark' : 'light';
  } catch(e){}
})();`,
      }}
    />
  );
}

export function ThemeToggle() {
  const [theme, setTheme] = useState<Theme>("system");

  useEffect(() => {
    const stored = (localStorage.getItem("theme") as Theme) || "system";
    setTheme(stored);
  }, []);

  function apply(t: Theme) {
    setTheme(t);
    localStorage.setItem("theme", t);
    setCookie(t);
    const mql = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const dark = t === "dark" || (t === "system" && mql);
    document.documentElement.classList.toggle("dark", dark);
    document.documentElement.style.colorScheme = dark ? "dark" : "light";
  }

  return (
    <div
      role="group"
      aria-label="Thème d'affichage"
      className="inline-flex items-center rounded-xl border border-navy-100 bg-ivory p-0.5"
    >
      {(
        [
          { v: "light", I: Sun, l: "Clair" },
          { v: "system", I: Monitor, l: "Système" },
          { v: "dark", I: Moon, l: "Sombre" },
        ] as { v: Theme; I: any; l: string }[]
      ).map(({ v, I, l }) => (
        <button
          key={v}
          type="button"
          onClick={() => apply(v)}
          aria-label={l}
          aria-pressed={theme === v}
          title={l}
          className={cn(
            "h-7 w-7 rounded-lg flex items-center justify-center transition-colors",
            theme === v
              ? "bg-white text-navy-900 shadow-soft"
              : "text-slate-500 hover:text-navy-900"
          )}
        >
          <I className="h-3.5 w-3.5" />
        </button>
      ))}
    </div>
  );
}
