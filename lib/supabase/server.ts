import { cache } from "react";
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { Tables } from "@/lib/database.types";

/**
 * Client Supabase côté serveur (session utilisateur via cookies).
 *
 * ⚠️ ASYNC depuis Next 15/16 : `cookies()` renvoie désormais une Promise.
 * Tout appelant doit donc faire `const supabase = await createClient();`.
 *
 * L'API cookies de @supabase/ssr (>= 0.6) est `getAll`/`setAll`.
 * Le `setAll` peut échouer quand il est invoqué depuis un Server Component
 * (les cookies n'y sont pas modifiables) : c'est sans conséquence, le
 * middleware se charge du rafraîchissement de session.
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            for (const { name, value, options } of cookiesToSet) {
              cookieStore.set(name, value, options);
            }
          } catch {
            /* appelé depuis un Server Component — ignoré (cf. middleware) */
          }
        },
      },
    }
  );
}

/**
 * Utilisateur courant, mémoïsé PAR REQUÊTE via React cache().
 *
 * `auth.getUser()` est un round-trip réseau vers Supabase Auth : sans
 * mémoïsation, layout + page + helpers le répètent 3 à 10 fois par
 * rendu. Ce helper garantit UN SEUL appel par requête serveur, quel que
 * soit le nombre d'appelants (Server Components uniquement — les server
 * actions et route handlers ont chacun leur propre portée de cache).
 */
export const getRequestUser = cache(async () => {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user;
});

/** Ligne profiles avec : role précisé (la colonne est l'enum Postgres
 *  user_role, que l'introspection génère en `string`) et colonne legacy
 *  `current_formation_slug` référencée par le code mais absente du schéma
 *  (toujours undefined à l'exécution, conservée pour compat). */
export type RequestProfile = Omit<Tables<"profiles">, "role"> & {
  role: "student" | "trainer" | "admin" | "super_admin";
  current_formation_slug?: string | null;
};

/**
 * Profil complet de l'utilisateur courant, mémoïsé PAR REQUÊTE.
 * Une seule lecture `profiles` partagée entre AuthLayout, pages et
 * helpers (le row complet couvre tous les sous-ensembles de colonnes).
 */
export const getRequestProfile = cache(
  async (): Promise<RequestProfile | null> => {
    const user = await getRequestUser();
    if (!user) return null;
    const supabase = await createClient();
    const { data } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .single();
    return (data as RequestProfile | null) ?? null;
  }
);

export async function getCurrentUser() {
  const user = await getRequestUser();
  if (!user) return null;
  const profile = await getRequestProfile();
  return profile ? { ...user, profile } : user;
}
