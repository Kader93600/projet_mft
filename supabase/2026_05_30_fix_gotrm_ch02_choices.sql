-- =====================================================================
-- Correctif ciblé — GOTRM Chapitre 2 : restaure la BONNE RÉPONSE des 12 QCM.
--
-- Contexte : les 12 QCM existent et leurs 4 options ont bien leur texte,
-- mais le drapeau "correct" était retombé à false sur toutes les options
-- (→ l'admin affichait « aucune bonne réponse »). Ce script réécrit
-- uniquement la colonne `choices` (texte + bonne réponse) à partir du
-- livret. Il NE supprime NI ne recrée le module, la leçon, le quiz ou les
-- questions : les ID, liens de quiz, tentatives et progressions sont
-- conservés.
--
-- Idempotent : peut être relancé sans effet de bord.
-- À exécuter dans l'éditeur SQL Supabase.
-- =====================================================================

with data(source_ref, choices) as (
  values
    ('mft-2026-gotrm-livret:ch02:qcm:1',
     '[{"key":"a","text":"12 m","correct":false},{"key":"b","text":"16,50 m","correct":true},{"key":"c","text":"18,75 m","correct":false},{"key":"d","text":"25,25 m","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:2',
     '[{"key":"a","text":"Poids Total à Charger","correct":false},{"key":"b","text":"Poids Total Autorisé en Charge","correct":true},{"key":"c","text":"Poids Total Admissible Camion","correct":false},{"key":"d","text":"Poids Tracteur Autorisé Conducteur","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:3',
     '[{"key":"a","text":"Tautliner","correct":false},{"key":"b","text":"Plateau","correct":false},{"key":"c","text":"Frigorifique certifié ATP","correct":true},{"key":"d","text":"Fourgon rigide","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:4',
     '[{"key":"a","text":"27","correct":false},{"key":"b","text":"30","correct":false},{"key":"c","text":"33","correct":false},{"key":"d","text":"34","correct":true}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:5',
     '[{"key":"a","text":"CU = PTAC + Tare","correct":false},{"key":"b","text":"CU = PMA – Tare TRR – Tare SREM","correct":true},{"key":"c","text":"CU = PTRA + Tare semi","correct":false},{"key":"d","text":"CU = PMA + ensemble des tares","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:6',
     '[{"key":"a","text":"La somme du poids réel et du poids volumétrique","correct":false},{"key":"b","text":"La moyenne des trois poids (réel, volumétrique, métrique)","correct":false},{"key":"c","text":"Le maximum des trois poids (réel, volumétrique, métrique)","correct":true},{"key":"d","text":"Le minimum des trois poids (réel, volumétrique, métrique)","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:7',
     '[{"key":"a","text":"19 000 kg","correct":false},{"key":"b","text":"26 000 kg","correct":true},{"key":"c","text":"32 000 kg","correct":false},{"key":"d","text":"44 000 kg","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:8',
     '[{"key":"a","text":"NF G 36-034","correct":true},{"key":"b","text":"ISO 9001","correct":false},{"key":"c","text":"NF EN 12195","correct":false},{"key":"d","text":"ADR 2023","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:9',
     '[{"key":"a","text":"150 kg/m³","correct":false},{"key":"b","text":"250 kg/m³","correct":true},{"key":"c","text":"330 kg/m³","correct":false},{"key":"d","text":"1 790 kg/m³","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:10',
     '[{"key":"a","text":"15 000 kg","correct":false},{"key":"b","text":"22 000 kg","correct":false},{"key":"c","text":"29 000 kg","correct":true},{"key":"d","text":"35 800 kg","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:11',
     '[{"key":"a","text":"Uniquement à l''arrivée","correct":false},{"key":"b","text":"Après les 50 premiers kilomètres et après tout choc","correct":true},{"key":"c","text":"Toutes les 4 heures de conduite","correct":false},{"key":"d","text":"Une fois par jour","correct":false}]'::jsonb),
    ('mft-2026-gotrm-livret:ch02:qcm:12',
     '[{"key":"a","text":"FRA","correct":true},{"key":"b","text":"FRB","correct":false},{"key":"c","text":"FRC","correct":false},{"key":"d","text":"FRD","correct":false}]'::jsonb)
)
update public.question_bank q
   set choices    = d.choices,
       updated_at = now()
  from data d
 where q.source_ref = d.source_ref
   and q.type = 'qcm';

-- Vérification : doit renvoyer 12 lignes, toutes avec ok = true.
select q.source_ref,
       (select c->>'text'
          from jsonb_array_elements(q.choices) c
         where (c->>'correct')::boolean) as bonne_reponse,
       exists (
         select 1 from jsonb_array_elements(q.choices) c
          where (c->>'correct')::boolean
       ) as ok
  from public.question_bank q
 where q.source_ref like 'mft-2026-gotrm-livret:ch02:qcm:%'
 order by q.source_ref;
