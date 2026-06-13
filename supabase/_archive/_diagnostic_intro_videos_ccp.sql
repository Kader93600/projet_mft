-- Version courte : pour chaque CCP GOTRM, combien de modules ont
-- une vidéo, et quel est le 1er module (par order) qui en a une ?

SELECT
  b.code AS ccp_code,
  count(*) FILTER (WHERE m.intro_video_path IS NOT NULL) AS nb_videos,
  count(*) AS total_modules,
  (
    SELECT m2.slug
      FROM public.modules m2
      JOIN public.formation_modules fm2 ON fm2.module_id = m2.id
      JOIN public.formations f2 ON f2.id = fm2.formation_id
     WHERE f2.slug = 'gotrm'
       AND m2.bloc_id = b.id
       AND m2.intro_video_path IS NOT NULL
     ORDER BY m2."order" ASC
     LIMIT 1
  ) AS premier_module_avec_video
FROM public.blocs b
JOIN public.modules m ON m.bloc_id = b.id
JOIN public.formation_modules fm ON fm.module_id = m.id
JOIN public.formations f ON f.id = fm.formation_id
WHERE f.slug = 'gotrm'
GROUP BY b.id, b.code, b."order"
ORDER BY b."order";
