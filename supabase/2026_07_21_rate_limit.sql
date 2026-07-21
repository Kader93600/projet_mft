-- =====================================================================
-- 2026-07-21 — SEC-RL : rate limiting partagé (backend Postgres)
-- =====================================================================
-- Peut être appliqué AVANT ou APRÈS le déploiement du code : tant que la
-- fonction n'existe pas, lib/rate-limit.ts bascule en mode mémoire
-- (comportement actuel) et loggue l'incident une fois par process.
--
-- Contexte : le limiteur mémoire (Map locale) était inopérant en
-- serverless (chaque instance a son propre compteur). Ce backend
-- Postgres donne un compteur PARTAGÉ, en fenêtre fixe, sans nouveau
-- service à opérer. Volume attendu faible (contact, recherche, tracking).
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.rate_limit_hits (
  key          text NOT NULL,
  window_start timestamptz NOT NULL,
  count        integer NOT NULL DEFAULT 1,
  PRIMARY KEY (key, window_start)
);

-- Service-role uniquement (RLS sans policy + revoke).
ALTER TABLE public.rate_limit_hits ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.rate_limit_hits FROM anon, authenticated;

-- Incrémente et renvoie le compteur de la fenêtre courante pour p_key.
-- Fenêtre fixe : window_start = epoch arrondi au multiple de
-- p_window_seconds. Purge opportuniste (~1 appel sur 100) des fenêtres
-- de plus de 24 h pour garder la table minuscule.
CREATE OR REPLACE FUNCTION public.rate_limit_hit(p_key text, p_window_seconds integer)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_window timestamptz;
  v_count  integer;
BEGIN
  IF p_key IS NULL OR length(p_key) = 0 OR length(p_key) > 256 THEN
    RAISE EXCEPTION 'invalid key';
  END IF;
  IF p_window_seconds IS NULL OR p_window_seconds <= 0 OR p_window_seconds > 86400 THEN
    RAISE EXCEPTION 'invalid window';
  END IF;

  v_window := to_timestamp(
    floor(extract(epoch FROM now()) / p_window_seconds) * p_window_seconds
  );

  INSERT INTO public.rate_limit_hits AS r (key, window_start, count)
  VALUES (p_key, v_window, 1)
  ON CONFLICT (key, window_start)
  DO UPDATE SET count = r.count + 1
  RETURNING r.count INTO v_count;

  IF random() < 0.01 THEN
    DELETE FROM public.rate_limit_hits
    WHERE window_start < now() - interval '24 hours';
  END IF;

  RETURN v_count;
END;
$function$;

-- Appelée uniquement par le serveur (client service_role).
REVOKE EXECUTE ON FUNCTION public.rate_limit_hit(text, integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.rate_limit_hit(text, integer) TO service_role;

-- ── Vérifications post-application ───────────────────────────────────
-- SELECT public.rate_limit_hit('test:manual', 60);  → 1 puis 2, 3…
-- SELECT * FROM public.rate_limit_hits WHERE key = 'test:manual';
-- DELETE FROM public.rate_limit_hits WHERE key = 'test:manual';
-- Depuis l'app : 6 envois rapides du formulaire de contact → le 6e doit
-- renvoyer 429 même après un redéploiement (compteur partagé).
