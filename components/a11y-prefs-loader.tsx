import { cookies } from "next/headers";
import { createClient } from "@/lib/supabase/server";

/**
 * Applique les préférences d'accessibilité de l'utilisateur connecté
 * (police dyslexie, contraste élevé, mouvement réduit, soulignement des
 * liens, échelle de police) en injectant un petit script qui pose les
 * classes correspondantes sur <html>.
 *
 * POURQUOI un composant séparé : la lecture de `cookies()` bascule une
 * route en rendu dynamique. En isolant cet appel ICI (rendu dans un
 * <Suspense> par le layout), le layout racine lui-même n'appelle plus
 * `cookies()` → les pages vitrine publiques redeviennent statiques /
 * cachables par le CDN (x-vercel-cache: HIT). Pour un visiteur non
 * connecté (aucun cookie sb-*), ce composant ne fait AUCUN appel réseau
 * et ne rend rien.
 *
 * NB : le thème (dark/light) est déjà géré sans cookies serveur par le
 * script inline <ThemeInit/> (anti-FOUC côté client) — rien à faire ici.
 */
export async function A11yPrefsLoader() {
  const jar = await cookies();
  const hasAuthCookie = jar.getAll().some((c) => c.name.startsWith("sb-"));
  if (!hasAuthCookie) return null;

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;

  const { data: prefs } = await supabase
    .from("profiles")
    .select(
      "a11y_font_scale, a11y_dyslexia_font, a11y_high_contrast, a11y_reduced_motion, a11y_underline_links"
    )
    .eq("id", user.id)
    .maybeSingle();
  if (!prefs) return null;

  const classes = [
    prefs.a11y_dyslexia_font && "a11y-dyslexia",
    prefs.a11y_high_contrast && "a11y-contrast",
    prefs.a11y_reduced_motion && "a11y-motion",
    prefs.a11y_underline_links && "a11y-underline",
  ]
    .filter(Boolean)
    .join(" ");
  const fontScale = prefs.a11y_font_scale ?? 1;

  if (!classes && fontScale === 1) return null;

  // Applique les préférences sur <html> après le rendu (les classes a11y
  // n'ont pas d'enjeu anti-FOUC critique : ce sont des ajustements de
  // confort pour un utilisateur connecté, appliqués dès le 1er paint utile).
  const js = [
    classes
      ? `document.documentElement.classList.add(${classes
          .split(" ")
          .map((c) => JSON.stringify(c))
          .join(",")});`
      : "",
    fontScale !== 1
      ? `document.documentElement.style.fontSize=${JSON.stringify(
          `${Math.round(fontScale * 100)}%`
        )};`
      : "",
  ].join("");

  return <script dangerouslySetInnerHTML={{ __html: `(function(){try{${js}}catch(e){}})();` }} />;
}
