import { createClient } from "@supabase/supabase-js";

/**
 * Client Supabase utilisant la **service_role key** — bypass RLS.
 *
 * À utiliser UNIQUEMENT côté serveur (server actions, API routes) après
 * avoir vérifié les permissions via requireAdmin() ou équivalent.
 *
 * Ne jamais exposer ce client au navigateur.
 */
export function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !serviceKey) {
    throw new Error(
      "Configuration Supabase manquante (NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY)"
    );
  }
  return createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
