-- =====================================================================
-- DURCISSEMENT SÉCURITÉ — search_path des fonctions (13/07/2026)
--
-- Source : advisor sécurité Supabase « function_search_path_mutable »
-- (86 fonctions applicatives sans search_path épinglé).
--
-- POURQUOI C'EST UN RISQUE
--   Une fonction sans `search_path` fixe résout ses noms non qualifiés
--   (tables, fonctions, opérateurs) selon le search_path de l'APPELANT.
--   Pour une fonction SECURITY DEFINER (qui s'exécute avec les droits du
--   propriétaire, souvent postgres), un appelant malveillant peut préparer
--   un objet leurre dans un schéma placé en tête de son search_path
--   (ex. un schéma temporaire) et détourner l'exécution → élévation de
--   privilèges. Épingler le search_path ferme ce vecteur.
--
-- CE QUE FAIT CE SCRIPT
--   Épingle `search_path = public, extensions, pg_temp` sur toutes les
--   fonctions du schéma `public` QUI SONT LES NÔTRES, en EXCLUANT les
--   fonctions appartenant à une extension (pg_trgm, pgvector : vector_*,
--   gtrgm_*, similarity()…) — on ne modifie jamais une extension, ce
--   serait écrasé au prochain upgrade et pourrait la casser.
--     - `public`     : nos tables/fonctions sont dans public (référencées
--                      sans préfixe dans les corps de fonctions existants).
--     - `extensions` : couvre un éventuel appel non qualifié vers une
--                      extension hébergée dans ce schéma (ignoré au runtime
--                      si le schéma n'existe pas — sans erreur).
--     - `pg_temp`    : placé EN DERNIER (jamais en tête) pour les rares
--                      fonctions qui manipulent des tables temporaires, tout
--                      en empêchant le détournement par schéma temporaire.
--   (`pg_catalog` est toujours cherché en premier, implicitement.)
--
-- IDEMPOTENT : ignore les fonctions déjà épinglées. Rejouable sans erreur.
-- Gère les surcharges (signatures complètes via regprocedure).
--
-- ⚠️ À TESTER D'ABORD SUR UNE BRANCHE Supabase (ou copie) : dans le cas très
--    rare où une fonction référencerait un objet d'un autre schéma SANS le
--    qualifier, le pin pourrait la faire échouer. Les corps actuels qualifient
--    `auth.uid()` etc., donc le risque est faible — mais on vérifie.
-- À exécuter par l'admin dans le SQL editor Supabase.
-- =====================================================================

DO $mft$
DECLARE
  fn record;
  n  int := 0;
BEGIN
  FOR fn IN
    SELECT p.oid::regprocedure AS sig
    FROM pg_proc p
    JOIN pg_namespace ns ON ns.oid = p.pronamespace
    WHERE ns.nspname = 'public'
      AND p.prokind = 'f'
      -- Exclut les fonctions appartenant à une extension (deptype 'e').
      AND NOT EXISTS (
        SELECT 1 FROM pg_depend d
        WHERE d.objid = p.oid AND d.deptype = 'e'
      )
      -- Idempotent : saute celles qui ont déjà un search_path épinglé.
      AND NOT EXISTS (
        SELECT 1 FROM unnest(coalesce(p.proconfig, '{}')) c
        WHERE c LIKE 'search_path=%'
      )
  LOOP
    EXECUTE format(
      'ALTER FUNCTION %s SET search_path = public, extensions, pg_temp',
      fn.sig
    );
    n := n + 1;
    RAISE NOTICE 'search_path épinglé : %', fn.sig;
  END LOOP;
  RAISE NOTICE '=== % fonction(s) durcie(s) ===', n;
END $mft$;

-- =====================================================================
-- CONTRÔLE POST-EXÉCUTION
-- =====================================================================
-- Doit renvoyer 0 : plus aucune fonction applicative sans search_path.
--   SELECT p.oid::regprocedure
--     FROM pg_proc p
--     JOIN pg_namespace ns ON ns.oid = p.pronamespace
--    WHERE ns.nspname = 'public' AND p.prokind = 'f'
--      AND NOT EXISTS (SELECT 1 FROM pg_depend d
--                        WHERE d.objid = p.oid AND d.deptype = 'e')
--      AND NOT EXISTS (SELECT 1 FROM unnest(coalesce(p.proconfig,'{}')) c
--                        WHERE c LIKE 'search_path=%');
--
-- Puis relancer l'advisor sécurité : l'alerte function_search_path_mutable
-- ne doit plus lister que d'éventuelles fonctions d'extension (non couvertes,
-- ce qui est normal et attendu).
