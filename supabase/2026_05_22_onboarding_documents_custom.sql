-- ============================================================
-- Documents d'accueil : autoriser des types personnalisés
--
-- À l'origine, onboarding_documents.type était contraint à
-- ('convention', 'reglement', 'livret'). Pour permettre à l'admin d'ajouter
-- des documents libres (CGV, consignes de sécurité, charte…), on relâche
-- cette contrainte. Le `type` reste un identifiant interne (l'affichage
-- s'appuie sur le titre) ; l'index unique « un document publié par type »
-- est conservé.
--
-- Sans coupure : aucune donnée existante n'est modifiée.
-- ============================================================

ALTER TABLE public.onboarding_documents
  DROP CONSTRAINT IF EXISTS onboarding_documents_type_check;

-- Garde-fou minimal : type non vide.
ALTER TABLE public.onboarding_documents
  DROP CONSTRAINT IF EXISTS onboarding_documents_type_nonempty;
ALTER TABLE public.onboarding_documents
  ADD CONSTRAINT onboarding_documents_type_nonempty
  CHECK (length(trim(type)) > 0);
