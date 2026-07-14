import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

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

export async function getCurrentUser() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return null;
  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();
  return profile ? { ...user, profile } : user;
}
