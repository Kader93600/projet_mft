-- =====================================================================
-- Active la publication Realtime sur les notifications
-- (À jouer une seule fois.)
-- =====================================================================

-- Si la publication par défaut existe (Supabase l'ajoute), on ajoute la table.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    EXCEPTION WHEN duplicate_object THEN
      -- déjà ajoutée, on ignore
      NULL;
    END;
  END IF;
END $$;

-- Pour que les UPDATE soient diffusés avec les anciennes valeurs (lu/non-lu)
ALTER TABLE public.notifications REPLICA IDENTITY FULL;
