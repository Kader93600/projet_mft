-- =====================================================================
-- COURS GOTRM CCP1 — Questions Rédigées (QR) v2 [BACKUP SQL]
--
-- Ce fichier est généré par scripts/import-ccp1-qr.ts et fourni en backup
-- pour traçabilité git. L'import a déjà été exécuté via le SDK Supabase
-- lors de la dernière exécution du script.
--
-- Pour rejouer entièrement (par ex. sur une nouvelle base) :
--   npx tsx scripts/import-ccp1-qr.ts
--
-- Statistiques :
--   66 QR
--   23 annexes liées
--   Bucket Storage : question-attachments (préfixe ccp1-v2/)
--   source_ref pattern : mft-2026-gotrm-ccp1-qr-v2:chNN:exX.Y
-- =====================================================================

DO $ccp1_qr_v2$
DECLARE
  v_formation uuid;
  v_module uuid;
  v_question uuid;
  v_count_questions int := 0;
  v_count_attachments int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable'; END IF;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND type = 'qr'
     AND (source_ref LIKE 'mft-2026-gotrm-livret:%:qr:%'
          OR source_ref LIKE 'mft-2026-gotrm-ccp1-qr-v2:%');
  RAISE NOTICE 'Anciens QR CCP1 supprimés';


  -- Ch01 Ex 1.1 : Identifier les acteurs d''une opération de transport
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch01-environnement-trm';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 1 &middot; Exercice 1.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Identifier les acteurs d''une opération de transport</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>L''entreprise MD France (Clermont-Fd) fabrique des pièces mécaniques. Elle passe commande à TRANSGO pour livrer 18 palettes EUR à son client RENAULT (Montpellier). TRANSGO n''ayant pas de véhicule disponible, elle confie l''opération à ZALTO, sous-traitant référencé. Le transport est facturé à MECA-CONCEPT.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Identifiez le rôle de chacun des acteurs mentionnés.</li><li>Cette opération est-elle réalisée en port payé ou en port dû ? Justifiez.</li><li>Quel document ZALTO doit-elle présenter au gestionnaire avant toute affectation ?</li></ol>
<p>Acteur Rôle MD France</p>
<p>RENAULT</p>
<p>TRANSGO</p>
<p>ZALTO</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch01','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch01 Ex 1.2 : Identifier le type de transport et la réglementation applica
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch01-environnement-trm';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 1 &middot; Exercice 1.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Identifier le type de transport et la réglementation applicable</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Opération Type de transport Réglementation principale applicable 18 palettes de Clermont-Fd → Montpellier, véhicule complet</p>
<p>5 colis de Paris → Toulouse, livraison J+1 via plateforme de tri</p>
<p>8 palettes de Lyon → Barcelone (Espagne)</p>
<p>Transport de produits laitiers à +4 °C, Paris → Bordeaux</p>
<p>Produits chimiques corrosifs, camion homologué, Strasbourg → Hambourg</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch01','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch01 Ex 1.3 : Le rôle du gestionnaire de transport
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch01-environnement-trm';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 1 &middot; Exercice 1.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Le rôle du gestionnaire de transport</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport chez CLARA Clermont-Fd. Ce matin, vous avez reçu les informations suivantes : - Un conducteur signale une panne sur l''A71 (mission en cours). - Un client appelle pour demander un tarif pour 22 palettes de Clermont-Fd → Paris. - La direction vous demande le taux de km à vide de la semaine. - Un conducteur vous signale qu''il ne comprend pas l''ordre de mission reçu hier.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Pour chacune des 4 situations, précisez à quelle phase (avant / pendant / après le transport) elle appartient et quelle action le gestionnaire doit prioriser en premier.</p>
<p>Situation Phase Action prioritaire</p>
<p>1 — Panne sur l''A71</p>
<p>2 — Demande de tarif</p>
<p>3 — Taux km à vide</p>
<p>4 — Ordre de mission incompris</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch01','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch01 Ex 1.4 : Le rôle du gestionnaire de transport
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch01-environnement-trm';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 1 &middot; Exercice 1.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Le rôle du gestionnaire de transport</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Une entreprise reçoit une commande de transport pour le lendemain. Le gestionnaire doit : • préparer la tournée ; • choisir le véhicule ; • suivre le conducteur pendant la livraison ; • vérifier les documents au retour ; • préparer la facturation.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Classez ces missions dans les trois phases : • Avant le transport • Pendant le transport • Après le transport</p>
<p>Phase Situation</p>
<p>Avant le transport</p>
<p>Pendant le transport</p>
<p>Après le transport</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch01','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch01:ex1.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.1 : Calculer la charge utile d''un ensemble articulé
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer la charge utile d''un ensemble articulé</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>TRANSGO dispose des véhicules suivants dans son parc :</p>
<p>Code parc Type PTRA</p>
<p>PTAC PV TR/PORT PV SR/RE Type carrosserie TR12 + SR 27 Ensemble articulé 44 000 kg 35 000 kg 8 200 kg 6 800 kg Fourgon TR 18 + SR 31 Ensemble articulé 40 000 kg 38 000 kg 7 400 kg 7 200 kg Plateau PORT-11 Porteur solo 26 000 kg 8 150 kg — PLSC PORT-12 Porteur solo 19 000 kg 7 500 kg — Frigorifique</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Calculez la charge utile (CU) de chacun des 4 véhicules.</li><li>Un client envoie 22 t de marchandises. Quel(s) véhicule(s) peut-on utiliser ?</li><li>Pour un envoi de 8,5 t de produits surgelés (−18 °C), quel véhicule est obligatoire ?</li></ol></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.2 : Calculer la charge utile d''un ensemble articulé
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer la charge utile d''un ensemble articulé</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>RAPID ROUTE dispose des véhicules suivants dans son parc :</p>
<p>Tracteurs routiers</p>
<p>Code véhicule Plaque d’immatriculation Nombre d’essieux PTAC PTRA PV</p>
<p>TR15 FR-458-LM 2 essieux 19 000 kg 40 000 kg 7 800 kg</p>
<p>TR17 GH-214-RT 3 essieux 26 000 kg 44 000 kg 8 400 kg</p>
<p>TR18 ZX-963-KP 3 essieux 26 000 kg 44 000 kg 8 900 kg</p>
<p>Semi-remorques</p>
<p>Code semi- remorque Plaque Nombre d’essieux Type PV</p>
<p>SR45 AB-741-DF 3 essieux Tautliner 6 500 kg</p>
<p>SR47 KL-852-TY 3 essieux Frigorifique ATP 7 400 kg</p>
<p>SR49 MN-159-XC 2 essieux Plateau 5 900 kg</p>
<p>Porteurs</p>
<p>Code porteur Plaque Nombre d’essieux Type PTAC PV</p>
<p>PO22 ER-741-JH 2 essieux Fourgon 19 000 kg 7 200 kg</p>
<p>PO24 TY-852-QW 3 essieux Plateau ridelles 26 000 kg 10 300 kg</p>
<p>Remorques</p>
<p>Code remorque Plaque Nombre d’essieux Type PTAC PV</p>
<p>RE87 CV-456-BN 2 essieux Remorque fourgon 18 000 kg 4 800 kg</p>
<p>RE89 PL-963-WX 3 essieux Remorque plateau 18 000 kg 5 400 kg</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À partir des caractéristiques techniques fournies, calculez la CU de chaque véhicule 1- TR15+SR45 2- PO24+RE87 3- TR17+SR49 4- PO22</p>
<p>5- TR18+SR47+SR47 (PV Dolly = 1000 kg) 6- TR18+SR49 7- PO22+RE89</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.3 : Calculer le poids taxable
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer le poids taxable</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l’entreprise TRANSGO. Votre client, GH LOGISTIQUE, doit expédier deux groupes électrogènes de Moulins vers Bari, en Italie. Caractéristiques de chaque unité : • Dimensions : 460 × 220 × 185 cm • Poids total de l’expédition : 6 500 kg (2 unités, non gerbable) Coefficients appliqués par TRANSGO : • Coefficient volumétrique : 330 kg/m³ • Coefficient métrique : 1 790 kg/ml Le chargement s’effectue par grutage sur un véhicule plateau : les palettes ne sont donc pas utilisées.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez le volume total (m³). 2. Calculez le poids volumétrique. 3. Calculez les mètres linéaires occupés. 4. Calculez le poids métrique. 5. Déterminez le poids taxable. Calcul Détail du calcul Résultat Volume total (m³)</p>
<p>Poids volumétrique (kg)</p>
<p>Mètres linéaires</p>
<p>Poids métrique (kg)</p>
<p>Poids taxable (kg)</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.4 : Calculer le poids taxable
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer le poids taxable</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l''entreprise NORD FRET. Votre client, TISSEX EUROPE, doit expédier des rouleaux de tissu industriel de Lille vers Varsovie, en Pologne. Caractéristiques de l''expédition : • 12 rouleaux de tissu industriel, posés à plat (sur leur flanc) • Dimensions par rouleau : 150 cm de longueur × 120 cm de diamètre • Poids total de l''expédition : 2 400 kg • Rouleaux gerbables sur 2 niveaux maximum Coefficients appliqués par NORD FRET : • Coefficient volumétrique : 330 kg/m³ • Coefficient métrique : 1 790 kg/ml</p>
<p>Le chargement s''effectue sur un véhicule standard (largeur utile : 2,40 m). La largeur d''un rouleau (120 cm) n''autorise qu''un rouleau par voie dans la semi-remorque.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez le volume total (m³) (basé sur l''encombrement réel de chaque rouleau : L × Ø × Ø). 2. Calculez le poids volumétrique. 3. Calculez les mètres linéaires occupés (rappel : gerbables sur 2 niveaux → seule la moitié des rouleaux occupe le sol ; 1 rouleau par voie). 4. Calculez le poids métrique. 5. Déterminez le poids taxable. Calcul Détail du calcul Résultat Volume total (m³)</p>
<p>Poids volumétrique (kg)</p>
<p>Mètres linéaires</p>
<p>Poids métrique (kg)</p>
<p>Poids taxable (kg)</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.4bis : Exercice 2.4bis
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.4bis</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Exercice 2.4bis</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANSGO. Votre client, LES SUCRERIES D''AUVERGNE, vous confie une opération de transport au départ de Clermont-Ferrand à destination de plusieurs sites industriels en région Rhône-Alpes. La commande concerne : • 22 palettes EUR ; • des big-bags de sucre en poudre ; • marchandise non dangereuse mais sensible à l’humidité ; • chargement effectué au quai par chariot élévateur.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez les mètres linéaires occupés par cette commande. 2. La semi-remorque disponible fait 13,60 m de longueur utile. Y a-t-il de la place pour charger d''autres marchandises ? Si oui, combien de palettes EUR supplémentaires peut-on charger ? 3. Quel type de carrosserie faut-il utiliser pour des big-bags (déchargement latéral) ?</p>
<p>Exercice 2.4 — Choisir le bon véhicule</p>
<p>Commande Nature Contrainte spéciale Véhicule adapté Justification A 15 palettes de pièces mécaniques, 14 t Déchargement latéral chariot</p>
<p>B Viandes fraîches, 8 t, 0 °C à +4 °C ATP FRC obligatoire</p>
<p>C Béton en vrac, 22 t Déchargement par bascule</p>
<p>D Machines industrielles hors gabarit, 35 t Largeur 3,20 m</p>
<p>E Cartons de cosmétiques fragiles, 3 t Livraison urbaine, rues étroites</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.4bis', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.5 : Calculer le poids taxable
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.5</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer le poids taxable</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l''entreprise TRANSALPEX. Votre client, SODIBRICO, doit expédier une commande de carrelage sur palettes de Marseille vers Milan, en Italie.</p>
<p>Caractéristiques de l''expédition : • 18 palettes EUR de carrelage • Dimensions par palette : 120 × 80 × 160 cm • Poids total de l''expédition : 10 800 kg • Palettes non gerbables (hauteur et fragilité interdisent l''empilement)</p>
<p>Coefficients appliqués par TRANSALPEX : • Coefficient volumétrique : 330 kg/m³ • Coefficient métrique : 1 790 kg/ml</p>
<p>Le chargement s''effectue sur un véhicule standard (largeur utile : 2,40 m). Les palettes EUR (80 cm de large) sont chargées par paires côte à côte dans le sens de la largeur.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez le volume total (m³). 2. Calculez le poids volumétrique. 3. Calculez les mètres linéaires occupés (rappel : 2 palettes EUR côte à côte par rangée ; non gerbables → toutes les palettes au sol). 4. Calculez le poids métrique. 5. Déterminez le poids taxable. Calcul Détail du calcul Résultat Volume total (m³)</p>
<p>Poids volumétrique (kg)</p>
<p>Mètres linéaires</p>
<p>Poids métrique (kg)</p>
<p>Poids taxable (kg)</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.5', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch02 Ex 2.6 : Calculer les mètres linéaires et capacité de chargement
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch02-vehicules-marchandises';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 2 &middot; Exercice 2.6</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer les mètres linéaires et capacité de chargement</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANSGO. Votre client, LES SUCRERIES D''AUVERGNE, vous confie une opération de transport au départ de Clermont-Ferrand à destination de plusieurs sites industriels en région Rhône-Alpes. La commande concerne : • 22 palettes EUR ; • des big-bags de sucre en poudre ; • marchandise non dangereuse mais sensible à l’humidité ; • chargement effectué au quai par chariot élévateur.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez les mètres linéaires occupés par cette commande. 2. La semi-remorque disponible fait 13,60 m de longueur utile. Y a-t-il de la place pour charger d''autres marchandises ? Si oui, combien de palettes EUR supplémentaires peut-on charger ? 3. Quel type de carrosserie faut-il utiliser pour des big-bags (déchargement latéral) ?</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch02','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch02:ex2.6', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch03 Ex 3.1 : Identifier les informations manquantes dans une demande
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch03-analyser-demande';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 3 &middot; Exercice 3.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Identifier les informations manquantes dans une demande</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous recevez l''email suivant :</p>
<p>''Bonjour, je souhaite faire transporter des palettes de Clermont-Fd vers Paris la semaine prochaine. Pouvez-vous me donner un prix ? Merci, M. Dupont.''</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Listez toutes les informations manquantes que vous devez demander à M. Dupont avant de pouvoir établir une offre. 2. Rédigez un email professionnel de demande d''informations complémentaires (5 à 8 lignes). De A Objet</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch03','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch03 Ex 3.2 : Vérifier la faisabilité réglementaire
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch03-analyser-demande';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 3 &middot; Exercice 3.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Vérifier la faisabilité réglementaire</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Le lundi 18 mars à 9h00, la société HANSA-FLEX transmet à TRANSGO une demande de transport international. La mission consiste à effectuer : ❖ une collecte de marchandises sur 4 sites situés aux Pays-Bas autour d’Amsterdam ; ❖ puis un acheminement final vers Échirolles, en France. Distances prévisionnelles : ❖ 272 km entre Cologne et Amsterdam ; ❖ 1 054 km entre Amsterdam et Échirolles. Contraintes demandées par le client : • chargement prévu le lundi 18/03 à 14h ; • livraison impérative le mardi 19/03 à 8h.</p>
<p>Consignes d’exploitation TRANSGO : • vitesse commerciale retenue : 68 km/h ; • temps de service maximal : 10 heures par jour ; • pause repas obligatoire : 1 heure.</p>
<p>Conducteur affectable à la mission : • Martin LACHAUD ; • permis CE valide ; • FIMO/FCO à jour.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Déterminez le temps de conduite nécessaire pour effectuer le trajet Amsterdam → Échirolles (distance : 1 054 km). 2. Calculez le temps de service global de la mission en intégrant : • le temps de chargement (1 h 30) ; • le temps de déchargement (1 h 30) ; • la pause repas obligatoire (1 h). 3. Analysez si le conducteur peut assurer cette opération sur une seule journée tout en respectant la Réglementation Sociale Européenne (RSE). Justifiez votre réponse par des calculs précis. 4. Si la mission n’est pas réalisable dans les conditions prévues, indiquez la solution d’exploitation que vous mettriez en place.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch03','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch03 Ex 3.3 : Choisir la solution de transport adaptée
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch03-analyser-demande';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 3 &middot; Exercice 3.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Choisir la solution de transport adaptée</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes exploitant transport au sein de l’entreprise TRANSGO. Au cours de la même journée, plusieurs clients transmettent des demandes de transport avec des contraintes techniques, réglementaires et organisationnelles différentes. Votre rôle consiste à : • analyser chaque demande ; • identifier les contraintes de transport ; • choisir la solution d’exploitation la plus adaptée ; • justifier votre choix (type de véhicule, organisation, sous-traitance, réglementation, etc.).</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Complétez le tableau suivant.</p>
<p>Demande Contraintes Solution retenue Justification 22 palettes de pièces mécaniques, Clermont → Barcelone, livraison dans 48h International, poids 15 t</p>
<p>3 palettes de produits laitiers frais, Lyon → Marseille, J+1 Température 0-4 °C, ATP FRC</p>
<p>35 t de granulés plastiques en vrac, Thiers → Liège Vrac, international</p>
<p>Conducteur habituel absent, mission urgente Clermont → Paris Pas de véhicule disponible</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch03','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch03:ex3.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch04 Ex 4.1 : Étude de rentabilité d’un véhicule de transport routier de m
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Étude de rentabilité d’un véhicule de transport routier de marchandises</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes affecté au service exploitation de l’entreprise CLARA TRANS SAS. Votre responsable vous demande d’étudier la rentabilité annuelle de l’activité d’un véhicule. Marge commerciale minimale fixée par la direction : 10 % sur le prix de vente.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À partir des données fournies en</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : 1. Déterminer le coût de revient annuel du véhicule en distinguant : o les charges variables ; o les charges fixes liées au véhicule ; o les charges de structure. 2. Calculer le coût de revient journalier du véhicule. 3. Déterminer : o le terme kilométrique ; o le terme journalier. 4. Calculer le seuil de rentabilité de l’activité : o en nombre de jours d’exploitation ; o en kilomètres ; o en chiffre d’affaires critique (CAC). ANNEXE : Données d’exploitation sur 12 mois Montants HT</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.1_Annexe.pdf', 'Ch04_Exercice_4.1_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.10 : Pied de facture carburant
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.10</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Pied de facture carburant</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>TRANSGOTRM a signé un contrat annuel avec MECA POLE. Part carburant contractuelle : 28 %. Indice CNR de référence (à la signature) : 142,5. Indice CNR du mois de facturation : 158,2. Prix HT de la prestation mensuelle : 4 200 €.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Calculez la variation de l''indice CNR.</li><li>Calculez le montant du pied de facture carburant.</li><li>Quel est le montant total HT de la facture ?</li><li>Quelle sanction encourt un client qui refuserait de payer ce supplément ?</li></ol></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.10', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch04 Ex 4.2 : Étude de rentabilité de la tournée du porteur POR 85
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Étude de rentabilité de la tournée du porteur POR 85</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes affecté au service exploitation de l’entreprise TRANSGO. Votre responsable vous confie l’analyse de la rentabilité d’une tournée réalisée pour l’un des clients de l’entreprise. Le véhicule concerné est le porteur POR 85. Ce porteur est exploité sur une base annuelle de : • 110 000 km parcourus ; • 220 jours d’exploitation.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calcul des coûts d’exploitation À partir des données fournies en</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : porteur POR 85 sous les trois formes suivantes : a) Forme monôme b) Forme binôme c) Forme trinôme</p>
<p>2. Analyse de la rentabilité Le chiffre d’affaires journalier réalisé par le véhicule est de 784 € HT par jour Déterminez la rentabilité de la tournée en utilisant deux méthodes différentes, puis calculez : a) Le seuil de rentabilité en kilomètres b) Le seuil de rentabilité en jours d’exploitation c) Le chiffre d’affaires critique (CAC) ANNEXE : Éléments d’exploitation et financiers HT</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.2_Annexe.pdf', 'Ch04_Exercice_4.2_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.3 : Étude de rentabilité d’une tournée régulière en porteur 19 t
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Étude de rentabilité d’une tournée régulière en porteur 19 tonnes</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein du service route de l’entreprise DISTRIGO, située à Clermont-Ferrand (63). À la demande d’un client, l’entreprise met en place une tournée régulière pour une durée contractuelle de cinq ans. Afin d’assurer cette activité, la société prévoit l’acquisition d’un porteur 19 tonnes spécialement affecté à cette tournée. Votre responsable d’exploitation vous demande d’étudier la rentabilité économique de cette opération avant validation définitive du projet.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calcul du coût de revient À partir des données fournies en</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : méthodes suivantes : a) Méthode du monôme b) Méthode du binôme c) Méthode du trinôme 2. Analyse de la rentabilité Le chiffre d’affaires prévisionnel de la tournée est de 679 € HT par jour À l’aide de deux méthodes différentes, déterminez : a) Le seuil de rentabilité en kilomètres b) Le seuil de rentabilité en jours d’exploitation c) Le chiffre d’affaires critique (CAC) 3. Analyse de la marge brute La direction de l’entreprise impose une marge brute minimale moyenne de 7 % du prix de vente Vérifiez si cette exigence est respectée et justifiez votre réponse à l’aide des calculs réalisés.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.3_Annexe.pdf', 'Ch04_Exercice_4.3_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.4 : Étude économique d’une nouvelle tournée de camionnage
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Étude économique d’une nouvelle tournée de camionnage</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes affecté(e) au service camionnage de l’entreprise TRMTRANS, située à Rennes. Le client TRY PROD a sollicité le service commercial pour organiser une nouvelle tournée régulière d’approvisionnement de magasins de bricolage. Cette prestation débutera le 1er janvier de l’année prochaine et sera réalisée du lundi au vendredi, chaque semaine. Pour assurer cette tournée, l’entreprise a acquis un nouveau véhicule, affecté exclusivement à ce trafic. Afin d’établir le prix de vente, le service commercial a défini les premières conditions d’exploitation.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À partir des données fournies ci-dessous, vous devez : 1. Reconstituer le kilométrage hebdomadaire et annuel du véhicule. 2. Calculer le coût réel de la masse salariale brute annuelle, absentéisme compris. 3. Reconstituer les coûts d’exploitation du véhicule sous les formes : o trinôme ; o binôme ; o monôme. 4. Déterminer le chiffre d’affaires hebdomadaire et annuel de la tournée. 5. Calculer la rentabilité : o en kilomètres ; o en jours d’exploitation ; o en chiffre d’affaires critique (CAC). 6. Déterminer la marge dégagée par ce trafic.</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : ANNEXE 1 : A — Conditions d’exploitation définies par le service commercial</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.4_Annexe.pdf', 'Ch04_Exercice_4.4_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.5 : Etude de cotation en messagerie
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.5</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Etude de cotation en messagerie</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous travaillez au service exploitation de l’entreprise MATO MESSAGERIE, implantée à Clermont- Ferrand (63). Plusieurs clients ont sollicité l’entreprise pour des expéditions nationales au départ de Clermont- Ferrand. Votre mission consiste à établir la cotation de chaque envoi</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Pour chaque expédition, calculer le prix HT du transport à l’aide de la grille tarifaire MATO MESSAGERIE</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : ANNEXE 1 : A — Conditions d’application MATO MESSAGERIE</p>
<p>❖ Le poids pris en compte pour la facturation sera le poids réel ; ❖ Pour les envois légers et volumineux, MATO MESSAGERIE applique le principe de la facturation volumétrique, sur la base de 250 kg/m 3 , si le poids volumétrique est supérieur au poids réel ; ❖ Arrondir le poids de taxation au kg supérieur ; ❖ Application de la règle du payant-pour.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.5', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.5_Annexe.pdf', 'Ch04_Exercice_4.5_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.6 : Étude de cotation au mètre linéaire
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.6</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Étude de cotation au mètre linéaire</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous travaillez au service exploitation de l’entreprise TDM TPS, située à Strasbourg (67). Plusieurs clients ont confié à l’entreprise des expéditions nationales comportant des marchandises non gerbables. Ci-dessous la liste de commande</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Calculer le montant HT du transport.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.6', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.6_Annexe.pdf', 'Ch04_Exercice_4.6_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.7 : Étude de cotation — Lots complets
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.7</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Étude de cotation — Lots complets</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l’entreprise ATLANTIC FRET SERVICES, spécialisée dans les opérations de messagerie et de transport national. Vous avez reçu par e-mail plusieurs demandes de transport de la part de vos clients. Voici la liste des commandes reçues à traiter</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Votre responsable vous demande de calculer le coût de revient puis le prix de vente HT des envois suivants.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.7', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch04 Ex 4.8 : Cotation au tarif par tonne
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.8</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Cotation au tarif par tonne</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l’entreprise TRANSGO. Plusieurs clients ont transmis des commandes de transport en lots complets ou partiel au départ de Clermont-Ferrand vers différentes destinations nationales. Ci-dessous la liste des commandes</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Votre responsable vous demande d’établir la cotation de chaque transport</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.8', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.8_Annexe.pdf', 'Ch04_Exercice_4.8_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch04 Ex 4.9 : Tarification lots partiels — poids taxable et grille
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch04-cout-revient-tarification';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 4 &middot; Exercice 4.9</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Tarification lots partiels — poids taxable et grille</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l’entreprise EUROFRET LOGISTIQUE. Votre client LES SUCRERIES D''AUVERGNE vous confie une opération de transport à destination de la société SARL FRUITS-ROUGES située à Collonges-la-Rouge. La commande porte sur : • 22 palettes EUR de big-bags de sucre en poudre ; • un poids réel total de 1 200 kg ; • des dimensions unitaires (palette comprise) de : o 0,80 × 1,20 × 2,08 m. Conditions d’exploitation appliquées par EUROFRET LOGISTIQUE : • coefficient volumétrique : 330 kg/m³ ; • coefficient métrique : 1 790 kg/ml.</p>
<p>Distance du transport : • Issoire → Collonges-la-Rouge : 260 km.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez le volume unitaire d''une palette (marchandise + support). 2. Calculez le volume total des 22 palettes. 3. Calculez le poids volumétrique. 4. Calculez les mètres linéaires. 5. Calculez le poids métrique. 6. Déterminez le poids taxable (arrondi à la centaine supérieure). 7. Lisez le prix dans la grille (distance 260 km → colonne 25 km) et calculez le prix de vente HT. 8. Appliquez la règle du payant pour si nécessaire. Calcul Détail du calcul Résultat Volume unitaire palette 0,80 × 1,20 × (2,08 + 0,15)</p>
<p>Volume total (22 pal.) Vol. unit. × 22</p>
<p>Poids volumétrique Volume total × 330</p>
<p>Mètres linéaires 22 × 0,40</p>
<p>Poids métrique ml × 1 790</p>
<p>Poids taxable max(1 200 / vol. / métr.) arrondi</p>
<p>Prix grille HT Lecture grille</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE :</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch04','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch04:ex4.9', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch04/Ch04_Exercice_4.9_Annexe.pdf', 'Ch04_Exercice_4.9_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch05 Ex 5.1 : Rédiger une offre commerciale positive
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch05-offre-commerciale';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 5 &middot; Exercice 5.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Rédiger une offre commerciale positive</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l’entreprise EUROFRET LOGISTIQUE installée à 145 avenue de Charles de Gaull 63 000 Clermont Ferrand, mail : service.exploitation@eurolog.fr. À la suite de l’étude tarifaire réalisée pour le client TECHNIBOIS concernant un transport entre Clermont-Ferrand et Lille (Exercice 4.8), votre responsable commercial vous demande de formaliser une offre commerciale complète.</p>
<p>Informations complémentaires Prestations</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Rédigez l''offre commerciale complète à l''aide du modèle mail fourni ci-contre</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : chargement conducteur 1h (52,13 €), déchargement conducteur 1h (52,13 €). Coordonnées client : TECHNOBOIS — 117 Avenue Pasteur — 63000 Clermont-Fd. Contact : M. Bernard MARTIN — b.martin@technobois.fr. Date de chargement confirmée : 23/03/20AA à 10h00 — Livraison : 23/03/20AA avant 15h00. Votre référence dossier : TR25-532.</p>
<p>TRAVAIL A REALISER Rédigez l''offre commerciale complète à l''aide du modèle mail fourni ci-contre</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch05','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch05/Ch05_Exercice_5.1_Annexe_Mail.pdf', 'Ch05_Exercice_5.1_Annexe_Mail.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch05 Ex 5.2 : Rédiger une réponse négative argumentée
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch05-offre-commerciale';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 5 &middot; Exercice 5.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Rédiger une réponse négative argumentée</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport chez EUROFRET LOGISTIQUE. Le client MÉTAL AUVERGNE vous a contacté pour confirmer l''enlèvement de ses 5 fardeaux de barres métalliques le 23/03/20AA à 9h00, conformément à sa demande initiale. Après vérification de votre planning, vous constatez que cette opération nécessite un véhicule plateau certifié pour le chargement par grue. Or, votre seul plateau disponible (SREM-03) est en visite technique jusqu''au 25/03/20AA. Vous devez donc refuser la date demandée tout en proposant une solution alternative : un départ le 26/03/20AA.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Rédigez un e-mail de réponse négative à destination du client MÉTAL AUVERGNE en utilisant le modèle de mail ci-dessous</p>
<p>Mail - Exercice 5.2</p>
<p>De A Objet</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch05','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch05/Ch05_Exercice_5.2_Annexe_Mail.pdf', 'Ch05_Exercice_5.2_Annexe_Mail.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch05 Ex 5.3 : Offre commerciale ALPINA / Lyon
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch05-offre-commerciale';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 5 &middot; Exercice 5.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Offre commerciale ALPINA / Lyon</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport chez EUROFRET LOGISTIQUE (service.exploitation@eurolog.fr). Suite au calcul de prix effectué à l''exercice 4.8 pour le dossier Société ALPINA, votre responsable vous demande de rédiger l''offre commerciale par e-mail.</p>
<p>DONNÉES Client Société ALPINA — 28 rue des Artisans, 63000 Clermont- Ferrand Contact Mme Sophie LAMBERT — s.lambert@alpina-sa.fr Trajet Clermont-Ferrand → Lyon Marchandise Pièces mécaniques — 8 palettes EUR Date de chargement 14/04/20AA à 8h30 Date de livraison 14/04/20AA avant 17h00 Référence dossier TR25-118 Prix transport (ex. 4.8) À reporter par l''élève Prestations</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Compléter le modèle d''e-mail ci-dessous</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : Déchargement conducteur : 1h → 52,13 € HT</p>
<p>TRAVAIL A REALISER Compléter le modèle d''e-mail ci-dessous</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch05','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch05/Ch05_Exercice_5.3_Annexe_Mail.pdf', 'Ch05_Exercice_5.3_Annexe_Mail.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch05 Ex 5.4 : Offre commerciale — BATI PRO / Toulouse
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch05-offre-commerciale';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 5 &middot; Exercice 5.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Offre commerciale — BATI PRO / Toulouse</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport chez EUROFRET LOGISTIQUE. Suite au calcul de prix effectué à l''exercice 4.8 pour le dossier BATI PRO, votre responsable vous demande de rédiger l''offre commerciale par e-mail. Le chargement est plus lourd (18 palettes), ce qui nécessite 2 heures de manutention par le conducteur. DONNÉES Client BATI PRO — 54 boulevard de l''Industrie, 63100 Clermont-Ferrand Contact M. Jacques RENARD — j.renard@batipro.fr Trajet Clermont-Ferrand → Toulouse Marchandise Matériaux de chantier — 18 palettes EUR Date de chargement 07/05/20AA à 7h00 Date de livraison 08/05/20AA avant 12h00 Référence dossier TR25-274 Prix transport (ex. 4.8) À reporter par l''élève Prestations</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Compléter le modèle d''e-mail ci-dessous</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : Déchargement conducteur : 1h → 52,13 € HT / Livraison sur rendez-vous : 35,00 € HT</p>
<p>TRAVAIL A REALISER Compléter le modèle d''e-mail ci-dessous</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch05','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch05/Ch05_Exercice_5.4_Annexe_Mail.pdf', 'Ch05_Exercice_5.4_Annexe_Mail.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch05 Ex 5.5 : Rédiger une confirmation d''affrètement
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch05-offre-commerciale';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 5 &middot; Exercice 5.5</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Rédiger une confirmation d''affrètement</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de l’entreprise TRANSGO LOGISTIQUE, située à Clermont-Ferrand. TRANSGO LOGISTIQUE 145 avenue Édouard Michelin 63100 Clermont-Ferrand Tél. : 04 73 88 52 10 Mail : exploitation@transgo-logistique.fr</p>
<p>Votre mission consiste à organiser les opérations de transport confiées par les clients de l’entreprise. Pour certaines expéditions, vous devez recourir à un transporteur sous-traitant référencé par TRANSGO LOGISTIQUE.</p>
<p>Consignes internes TRANSGO LOGISTIQUE • Tous les affrètements doivent être réalisés uniquement avec les sous-traitants référencés. • La marge commerciale appliquée par TRANSGO LOGISTIQUE est de 12 % minimum sur le prix de vente client. • Toute livraison sur rendez-vous doit être indiquée sur la confirmation d’affrètement. • Les horaires de chargement et de livraison doivent impérativement être renseignés.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous devez pour chaque expédition et à l’aide des</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : 1. Choisir le sous-traitant 2. Calculer le coût d’affrètement à l’aide de la grille tarifaire fournie, 3. Compléter la confirmation d’affrètement</p>
<p>Expéditions à traiter</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch05','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch05:ex5.5', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch05/Ch05_Exercice_5.5_Annexe.pdf', 'Ch05_Exercice_5.5_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch06 Ex 6.1 : Affecter un conducteur et un véhicule
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch06-affecter-moyens';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 6 &middot; Exercice 6.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Affecter un conducteur et un véhicule</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Nous sommes le jeudi 18/03/20AA. Vous devez affecter les 3 commandes suivantes. Véhicules non affectés disponibles ce jour : - TRR-01 + SREM-01 (Fourgon, CU 29 t) - TRR-02 + SREM-03 (Plateau, CU 27 t) - PORT-02 (Frigorifique ATP FRC, CU 8,5 t) Conducteurs disponibles ce jeudi : - Jean-Paul LEBLANC (CE, FIMO valide, FCO 03/06/20AB) - Thierry MULLER (CE, FCO 19/04/20AD) - Martin LACHAUD (CE, FCO 10/12/20AC) REPOS JOURNALIER jusqu''à 14h</p>
<p>Commande Nature Véhicule retenu Conducteur retenu Impossibilité éventuelle 532 — Clermont → Montpellier 34 pal. pièces mécaniques, 780 kg, déchargement quai</p>
<p>528 — Moulins → Bari 2 groupes électrogènes, 6 500 kg, grue</p>
<p>540 — Issoire → Collonges 22 pal. EUR sucre en poudre, déchargement latéral</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Pour chaque commande impossible à affecter en moyens propres, précisez la solution alternative à mettre en œuvre.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch06','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch06 Ex 6.2 : Vérifier la situation administrative d''un sous-traitant
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch06-affecter-moyens';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 6 &middot; Exercice 6.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Vérifier la situation administrative d''un sous-traitant</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous envisagez d''affréter TRANSROADSTAR pour une mission urgente Clermont-Fd → Porto (Portugal). Vous consultez le dossier administratif de ce sous-traitant : - Extrait Kbis : émis le 15/02/20AA - Licence communautaire : valide jusqu''au 22/08/20AB - Attestation d''assurance RC : valide jusqu''au 30/06/20AA - Attestation URSSAF : émise le 14/09/20AB (de l''année précédente) - Attestation de vigilance fiscale : émise le 01/03/20AA Nous sommes le 18/03/20AA.</p>
<p>Document Date / Validité Conforme ? (O/N) Observation Extrait Kbis 15/02/20AA</p>
<p>Licence communautaire 22/08/20AB</p>
<p>Attestation assurance RC 30/06/20AA</p>
<p>Attestation URSSAF 14/09/20AB</p>
<p>Attestation fiscale 01/03/20AA</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Pouvez-vous affecter TRANSROADSTAR ? Justifiez et précisez la procédure à suivre si une anomalie est constatée.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch06','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch06 Ex 6.3 : Procédure d''affrètement ponctuel
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch06-affecter-moyens';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 6 &middot; Exercice 6.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Procédure d''affrètement ponctuel</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Remettez dans l''ordre chronologique les 7 étapes de la procédure d''affrètement ponctuel : (Numérotez de 1 à 7)</p>
<p>Étape (à numéroter) Action</p>
<p>Reporter l''opération sur le planning</p>
<p>Négocier et convenir du prix de l''affrètement</p>
<p>Émettre et transmettre la CONFIRMATION D''AFFRÈTEMENT</p>
<p>Vérifier la situation administrative du sous-traitant</p>
<p>Identifier précisément les caractéristiques de l''opération</p>
<p>Rechercher un sous-traitant disponible et adapté</p>
<p>Transmettre toutes les instructions nécessaires au sous-traitant</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch06','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch06 Ex 6.4 : Planifier les opérations de transport
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch06-affecter-moyens';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 6 &middot; Exercice 6.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Planifier les opérations de transport</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous travaillez en qualité d''agent de transit et d''affrètement au sein de la société RAPID ROUTE, entreprise de transport routier de marchandises. RAPID ROUTE – 35 rue des Routiers – 69000 LYON Tél : 04.78.00.00.00 | Fax : 04.78.00.00.01 N° registre du commerce : B 4 5 892 | N° TVA : FR 82 456 892 274 Votre mission Vous recevez les commandes de SUPRAMA relatives à leurs envois de la semaine. Vous devez planifier ces envois, dans le respect de la réglementation et des disponibilités humaines et matérielles.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À l’aide de l’</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : numéros d’ordre.</p>
<p>2- À l’aide de l’annexe 2, affréter la commande n°306, référence B325, à destination de Madrid.</p>
<p>Vous disposez des annexes suivantes : • La fiche client SUPRAMA ; • Le cahier des charges SUPRAMA ; • Les commandes SUPRAMA (allers et retours) ; • La liste des véhicules et leurs disponibilités ; • La liste des conducteurs ainsi que le planning des absences ; • La liste des transporteurs affrétés référencés.</p>
<p>ANNEXES</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch06','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch06:ex6.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch06/Ch06_Exercice_6.4_Annexe.pdf', 'Ch06_Exercice_6.4_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch07 Ex 7.1 : Constituer la pochette de bord
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch07-documents-transport';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 7 &middot; Exercice 7.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Constituer la pochette de bord</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Le conducteur Martin LACHAUD part en mission internationale (Clermont-Fd → Cologne, Allemagne) lundi matin. Vérifiez les documents que vous devez lui remettre avant le départ.</p>
<p>Document Obligatoire O/N En cas d''absence : sanction Copie conforme de la licence de transport communautaire</p>
<p>Certificat d''immatriculation (carte grise)</p>
<p>Attestation d''assurance</p>
<p>Permis de conduire valide (CE)</p>
<p>Carte de Qualification Conducteur (CQC)</p>
<p>Carte conducteur tachygraphe numérique</p>
<p>Lettre de voiture CMR</p>
<p>Passeport ou carte d''identité</p>
<p>Ordre de mission interne</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch07','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch07 Ex 7.2 : Analyser des réserves sur un document de transport
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch07-documents-transport';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 7 &middot; Exercice 7.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyser des réserves sur un document de transport</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À la livraison d''une commande de 18 palettes de pièces mécaniques chez RENAULT TRUCKS (Montpellier), le destinataire refuse de signer le bon de livraison sans réserves. Il constate : 2 palettes avec filmage déchiré et cartons écrasés. Le conducteur contacte le gestionnaire.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Les réserves suivantes sont-elles valables juridiquement ? Justifiez. a) « Sous réserve de déballage » b) « 2 palettes n°14 et n°17 : filmage déchiré, cartons écrasés en surface » 2. Dans quel délai le destinataire doit-il confirmer ses réserves par LRAR ? 3. Que se passe-t-il si ce délai n''est pas respecté ? 4. Quelles mesures le conducteur doit-il prendre sur place ?</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch07','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch07 Ex 7.3 : Identifier les mentions manquantes sur une lettre de voiture
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch07-documents-transport';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 7 &middot; Exercice 7.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Identifier les mentions manquantes sur une lettre de voiture</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Cochez les mentions obligatoires présentes (✓) et signalez les mentions manquantes (✗) :</p>
<p>Mention ✓ Présente ✗ Manquante Nom et adresse de l''expéditeur</p>
<p>Nom et adresse du destinataire</p>
<p>Adresse exacte de chargement</p>
<p>Adresse exacte de livraison</p>
<p>Date et heure de chargement prévues</p>
<p>Nature de la marchandise</p>
<p>Nombre d''unités de charge</p>
<p>Poids brut total</p>
<p>Conditions de paiement (port payé/port dû)</p>
<p>Signature de l''expéditeur</p>
<p>Signature du transporteur</p>
<p>Numéro de la lettre de voiture</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch07','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch07:ex7.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch08 Ex 8.1 : Compléter un planning hebdomadaire
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch08-planifier-operations';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 8 &middot; Exercice 8.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Compléter un planning hebdomadaire</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes embauché en tant que gestionnaire de transport au sein de la société ZALTO TRANS, située : ZALTO TRANS Zone Industrielle La Bouriette 18 rue Jean Monnet 11000 Carcassonne</p>
<p>L’entreprise est spécialisée dans le transport national et international de produits alimentaires liquides en vrac. Nous sommes jeudi. Vous recevez le puits de commandes et vous devez finaliser le planning transport de la semaine suivante.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À l’aide de l’</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE :</p>
<p>Vous disposez dans l’annexe 2 : • Du puits de commandes ; • De la liste des conducteurs avec les absences ; • De la liste des véhicules avec les indisponibilités.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch08','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch08/Ch08_Exercice_8.1_Annexe.pdf', 'Ch08_Exercice_8.1_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch08 Ex 8.2 : Optimiser une tournée de livraison
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch08-planifier-operations';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 8 &middot; Exercice 8.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Optimiser une tournée de livraison</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous devez organiser une tournée de distribution pour le conducteur MULLER, au départ du dépôt de Clermont-Ferrand le lundi 04/04 à 6h00. Les livraisons à effectuer sont situées dans le département du Puy-de-Dôme :</p>
<p>• A : MECA-CONCEPT — Chamalières — créneau de livraison 8h00 à 12h00 — 8 palettes • B : IGM — Gerzat — livraison impérative entre 9h00 et 11h00 — 5 palettes • C : THIERS BÂTIMENT — Thiers — créneau de livraison 10h00 à 17h00 — 3 palettes • D : CONSERVES BEAUMONT — Beaumont — créneau de livraison 14h00 à 16h00 — 6 palettes</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Proposez l''ordre optimal de livraison en respectant les créneaux horaires.</li><li>Calculez le temps de service total (conduite + livraisons).</li><li>Le conducteur respecte-t-il la RSE (temps de service ≤ 12h, pause 45 min si conduite &gt; 4h30) ?</li></ol></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch08','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch08/Ch08_Exercice_8.2_Annexe.pdf', 'Ch08_Exercice_8.2_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch08 Ex 8.3 : Trouver un fret de retour
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch08-planifier-operations';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 8 &middot; Exercice 8.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Trouver un fret de retour</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société DHM TRANS, située à Clermont- Ferrand. L’ensemble routier TRR-01 / SREM-01 de type PLSC vient d’effectuer une livraison à Montpellier le lundi à 14h30. Afin d’éviter un retour à vide vers le dépôt de Clermont-Ferrand, vous consultez la bourse de fret retour disponible au départ de la région Occitanie. Le conducteur LACHAUD est disponible jusqu’à 21h00 maximum.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous devez sélectionner l’offre la plus adaptée.</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : Consignes internes DHM TRANS • Aucun travail entre 21h00 et 6h00 sans autorisation de l’exploitation ; • Vitesse commerciale retenue : 68 km/h ; • Véhicule disponible : semi-remorque bâchée PLSC. La liste des offres de fret</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch08','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch08:ex8.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch08/Ch08_Exercice_8.3_Annexe.pdf', 'Ch08_Exercice_8.3_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch09 Ex 9.1 : Calculer les temps de conduite et vérifier la conformité RSE
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch09-rse-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 9 &middot; Exercice 9.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer les temps de conduite et vérifier la conformité RSE</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Monsieur MARTIN, responsable d’exploitation, vous confie une mission de transport et vous demande d’en étudier la faisabilité au regard de la réglementation sociale européenne (RSE). Le conducteur Jean-Paul LEBLANC doit réaliser une opération de transport entre Clermont- Ferrand et Amsterdam (Pays-Bas). Données de la mission • Trajet : Clermont-Ferrand → Amsterdam • Conducteur : Jean-Paul LEBLANC • Départ prévu : lundi à 8h00 • Distance à parcourir : 1 045 km • Vitesse commerciale retenue : 68 km/h • Temps de chargement à Clermont-Ferrand : 1h00 • Temps de déchargement à Amsterdam : 1h30 • Pause repas : 1h00 (entre 12h30 et 13h30) • Retour du conducteur au dépôt de Clermont-Ferrand prévu le mardi.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculer le temps total de conduite nécessaire à la réalisation de la mission ; 2. Déterminer si la mission peut être effectuée en une seule journée dans le respect de la réglementation RSE et justifier votre réponse ; 3. Établir un plan de marche sur deux jours conforme à la réglementation sociale européenne ; 4. Identifier le type de repos pris par le conducteur entre le lundi soir et le mardi matin.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch09','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch09 Ex 9.2 : Détecter les infractions sur un relevé tachygraphe
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch09-rse-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 9 &middot; Exercice 9.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Détecter les infractions sur un relevé tachygraphe</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Dans le cadre du suivi réglementaire des conducteurs, votre responsable d’exploitation, M. MARTIN, vous demande d’analyser les relevés d’activités hebdomadaires du conducteur Nicolas DURAND afin d’identifier les éventuelles infractions à la réglementation sociale européenne ainsi que les non-respects des consignes internes de l’entreprise.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À l’aide des</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : 1- Contrôler les activités réalisées sur la semaine du conducteur afin d’identifier les éventuelles infractions ainsi que les non-respects des consignes internes de l’entreprise ; 2- Rédiger, à l’aide de l’annexe 1, une courte note d’information destinée à votre hiérarchie afin de signaler les anomalies et observations constatées. ANNEXES ANNEXE 1 Consignes internes TRANS EXPRESS</p>
<p>Consignes quotidiennes À chaque prise de poste, les conducteurs sont tenus de : • Vérifier visuellement l’état général du véhicule ; • Contrôler l’intégrité de la semi-remorque et l’absence éventuelle de fuites ; • Vérifier la présence du bouchon de réservoir ainsi que des équipements obligatoires ; • Contrôler les niveaux des différents liquides (huile moteur, liquide de refroidissement, lave-glace, huile hydraulique) ; • Vérifier le bon fonctionnement de l’éclairage après la mise en circulation ; • S’assurer du bon fonctionnement du tachygraphe ainsi que de la carte conducteur.</p>
<p>La durée des vérifications de prise de poste ne doit pas excéder 15 minutes.</p>
<p>Consignes permanentes relatives au temps de travail • Le temps de service quotidien ne doit pas dépasser 10 heures ; • Exceptionnellement et avec validation de l’exploitation, cette durée peut être portée à 12 heures ; • Sauf accord préalable de l’exploitation, la prise de poste doit intervenir au plus tôt à 5h00 ; • Sauf accord préalable de l’exploitation, la fin de poste doit intervenir au plus tard à 22h00 ; • Les conducteurs doivent respecter strictement les durées maximales de conduite prévues par la RSE ; • Les durées minimales de repos prévues par la réglementation doivent être respectées ; • Une pause minimale de 30 minutes doit être prise après 6 heures de travail continu.</p>
<p>Consignes diverses • Sauf autorisation exceptionnelle de l’exploitation, toute conduite est interdite du samedi 22h00 au dimanche 22h00 ; • Tout incident ou anomalie doit être immédiatement signalé au service exploitation.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch09','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch09/Ch09_Exercice_9.2_Annexe.pdf', 'Ch09_Exercice_9.2_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch09 Ex 9.3 : Analyser une semaine de temps de service
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch09-rse-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 9 &middot; Exercice 9.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyser une semaine de temps de service</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Complétez la colonne infractions.</li><li>Calculez le total de conduite de la semaine.</li><li>La conduite hebdomadaire est-elle conforme ?</li><li>La conduite bi-hebdomadaire est-elle conforme ?</li></ol></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch09','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch09 Ex 9.4 : Vérifier les qualifications d''un conducteur
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch09-rse-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 9 &middot; Exercice 9.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Vérifier les qualifications d''un conducteur</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>La société TRANS EXPRESS doit réaliser une mission de transport de marchandises dangereuses entre Strasbourg et Rotterdam. Le transport concerne des matières corrosives relevant de l’ADR classe 8. Votre responsable d’exploitation vous demande de vérifier si le conducteur proposé peut légalement effectuer cette mission. Mission transport • Trajet : Strasbourg → Rotterdam • Nature du transport : matières dangereuses ADR classe 8 (matières corrosives) • Conducteur proposé : Martin LACHAUD</p>
<p>Dossier conducteur Élément Situation Permis CE Valide jusqu’au 15/04/20AB FIMO Obtenue en 2019</p>
<p>FCO Suivie en octobre 20AC — validité jusqu’en octobre 20AH CQC Valide jusqu’en octobre 20AH Carte conducteur Valide jusqu’au 23/11/20AC Certificat ADR classe 7 Valide Certificat ADR classe 8 Non détenu</p>
<p>Date du contrôle Nous sommes le 18/03/20AA.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Le conducteur est-il qualifié pour cette mission ? Que décidez-vous ?</p>
<p>Qualification Valide O/N Observation Permis CE</p>
<p>FIMO</p>
<p>FCO</p>
<p>CQC</p>
<p>Carte conducteur</p>
<p>Certificat ADR classe 8</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch09','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch09:ex9.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch10 Ex 10.1 : Élaborer un plan de marche
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch10-encadrer-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 10 &middot; Exercice 10.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Élaborer un plan de marche</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont-Ferrand. Vous recevez une demande de transport de la part du client EMS EMBOUTISSAGE pour une livraison à destination de MECA-CONCEPT à Chamalières. Votre responsable d’exploitation vous demande d’étudier l’organisation de cette mission au regard des contraintes d’exploitation et de la réglementation sociale européenne (RSE).</p>
<p>Mission CMD-204 Transport à réaliser entre EMS EMBOUTISSAGE situé à Voiron (38) et MECA-CONCEPT situé à Chamalières (63). • Prise de service du conducteur : lundi 28/03/20AA à 8h00 • Distance à parcourir : 238 km • Temps de chargement à Voiron : 2h00 • Temps de déchargement à Chamalières : 2h00 • Vitesse commerciale retenue : 68 km/h • Pause repas obligatoire : 1h00 entre 12h30 et 13h30 • Repos journalier effectué la nuit précédente : 11h00 (conforme à la réglementation)</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculer le temps de conduite nécessaire à la réalisation de la mission ; 2. Déterminer l’heure prévisionnelle de fin de mission ; 3. Vérifier la conformité de la mission au regard de la réglementation sociale européenne ; 4. Identifier les différentes périodes d’activité du conducteur (conduite, travail, pause, repos). Heure Activité Durée Cumul conduite Cumul service 08h00 Prise de service — Départ dépôt</p>
<p>Trajet vers Voiron (15 min selon distancier)</p>
<p>Chargement EMS EMBOUTISSAGE</p>
<p>Conduite Voiron → Clermont</p>
<p>Pause repas (si nécessaire)</p>
<p>Suite conduite si applicable</p>
<p>Déchargement MECA- CONCEPT</p>
<p>Retour dépôt</p>
<p>FIN DE SERVICE</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch10','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch10 Ex 10.2 : Alerter la hiérarchie — cas pratiques
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch10-encadrer-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 10 &middot; Exercice 10.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Alerter la hiérarchie — cas pratiques</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Situation Alerte hiérarchie O/N Justification Type d''alerte Le conducteur MULLER a effectué 57h de conduite cette semaine</p>
<p>Le conducteur LACHAUD arrive 20 min en retard à son chargement</p>
<p>TRANSROADSTAR a une licence de transport expirée</p>
<p>Un conducteur refuse de signer son ordre de mission</p>
<p>Taux de km à vide : 18 % cette semaine (objectif &lt; 15 %)</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch10','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch10 Ex 10.3 : Calculer les éléments de paie d''un conducteur
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch10-encadrer-conducteurs';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 10 &middot; Exercice 10.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer les éléments de paie d''un conducteur</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Conducteur : Thierry MULLER — Catégorie : Grand routier (&lt; 6 repos/mois à domicile). Durée légale CCNTR : 43h/semaine — Taux horaire brut : 15,20 €. Mois de 4 semaines complètes — Heures de service du mois : 196h. Dont : 16h de nuit (22h-05h) — 0h dimanche. Frais de route : 22 nuits × 39,48 € + 28 repas × 15,96 €.</p>
<p>Élément Calcul Résultat Heures légales du mois 43h × 4</p>
<p>Heures supplémentaires totales 196 − heures légales</p>
<p>H. sup. 25 % (8 premières) 8 × 15,20 × 1,25</p>
<p>H. sup. 50 % (restantes) (HS − 8) × 15,20 × 1,50</p>
<p>Salaire de base Heures légales × 15,20</p>
<p>Majoration nuit 16h × 15,20 × 20 %</p>
<p>Frais couchages 22 × 39,48</p>
<p>Frais repas 28 × 15,96</p>
<p>Total frais de route (exonéré) Couchages + repas</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch10','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch10:ex10.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch11 Ex 11.1 : Gérer un aléa — méthode en 5 étapes
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch11-suivi-aleas';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 11 &middot; Exercice 11.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Gérer un aléa — méthode en 5 étapes</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Il est 11h45, le mardi 23/03/20AA. Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont-Ferrand. Le conducteur Thierry MULLER vous contacte pour signaler une panne moteur sur l’ensemble routier TRR-05 / SREM-05 alors qu’il circule sur l’autoroute A71, à hauteur de Riom. Le véhicule transporte 18 palettes de pièces mécaniques à destination du client SKODA à Montpellier. La livraison est prévue le jour même à 15h00. Le service dépannage annonce un délai d’intervention minimum de 3 heures. Vous disposez toutefois : • d’un autre ensemble routier TRR-02 / SREM-01 type fourgon, disponible au dépôt de Clermont-Ferrand situé à 15 km du lieu de panne ; • du conducteur Martin LACHAUD, immédiatement disponible pour assurer une relève.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>En appliquant la méthode en 5 étapes, décrivez toutes les actions à mener. Rédigez également le message à communiquer au client SKODA. Étape Action à mener 1 — Identifier le problème</p>
<p>2 — Évaluer les conséquences</p>
<p>3 — Mettre en œuvre une solution</p>
<p>4 — Informer les interlocuteurs</p>
<p>5 — Tracer l''événement</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch11','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch11 Ex 11.2 : Gérer un retard cascade
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch11-suivi-aleas';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 11 &middot; Exercice 11.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Gérer un retard cascade</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont-Ferrand. Le conducteur Thierry MULLER réalise une tournée de distribution comprenant plusieurs livraisons dans la région clermontoise. À 9h15, le conducteur vous informe d’un important embouteillage sur l’autoroute A72. Le retard estimé est de 1h45. Vous devez analyser les conséquences de cet aléa sur la tournée et mettre en place les actions nécessaires afin de limiter l’impact client.</p>
<p>Programme initial de la tournée</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Listez les clients impactés par le retard.</li><li>Dans quel ordre devez-vous les contacter ? Pourquoi ?</li><li>Pour le client B (heure impérative), quelle solution proposez-vous ?</li><li>Rédigez le SMS professionnel à envoyer au client B.</li></ol></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch11','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch11 Ex 11.3 : Gérer un refus de livraison
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch11-suivi-aleas';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 11 &middot; Exercice 11.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Gérer un refus de livraison</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont-Ferrand. Le vendredi 28/03 à 14h30, le conducteur Martin LACHAUD effectue une livraison de produits alimentaires surgelés chez le client FRUITS SECS, situé à Mâcon. La marchandise transportée est composée de 5 palettes de fruits congelés devant être maintenues à une température de −18 °C. Lors du contrôle à réception, le responsable du site constate que la température affichée dans la caisse est de −12 °C, alors que le seuil critique maximal autorisé est fixé à −15 °C. Le client : • accepte finalement 2 palettes, mais signe le bon de livraison avec réserves ;</p>
<p>• refuse la réception de 3 palettes, considérées comme non conformes. Vous devez gérer cet incident et assurer le suivi d’exploitation.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1- Indiquer si les réserves émises sur les 2 palettes acceptées doivent être confirmées, en précisant les modalités et les délais applicables ; 2- Déterminer les décisions d’exploitation à prendre concernant les 3 palettes refusées ; 3- Identifier les interlocuteurs à contacter dans les deux heures suivant l’incident ; 4- Préciser les informations et événements à enregistrer dans le TMS afin d’assurer la traçabilité complète du dossier.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch11','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch11:ex11.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch12 Ex 12.1 : Établir une facture de transport
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch12-facturation-litiges-cloture';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 12 &middot; Exercice 12.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Établir une facture de transport</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Mission n°TR25-532 clôturée : MECA-CONCEPT → RENAULT TRUCKS, Clermont-Fd → Montpellier. Prix de vente HT calculé : 456,80 €. Prestations</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculez le total HT de la facture. 2. Calculez la TVA (transport national). 3. Calculez le montant TTC. 4. Quelle mention relative aux pénalités de retard doit figurer sur la facture ? 5. Quel est le montant de l''indemnité forfaitaire légalement due en cas de retard de paiement ? Élément Montant Transport principal HT 456,80 € Prestations</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : Pied de facture carburant : 18,50 €. Délai de paiement contractuel : 30 jours date de facture. Date d''émission facture : 23/03/20AA.</p>
<p>TRAVAIL A REALISER 1. Calculez le total HT de la facture. 2. Calculez la TVA (transport national). 3. Calculez le montant TTC. 4. Quelle mention relative aux pénalités de retard doit figurer sur la facture ? 5. Quel est le montant de l''indemnité forfaitaire légalement due en cas de retard de paiement ? Élément Montant Transport principal HT 456,80 € Prestations annexes HT 104,26 € Pied de facture HT 18,50 € TOTAL HT</p>
<p>TVA 20 %</p>
<p>TOTAL TTC</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch12','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch12 Ex 12.2 : Analyser un litige — recevabilité et plafond
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch12-facturation-litiges-cloture';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 12 &middot; Exercice 12.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyser un litige — recevabilité et plafond</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont-Ferrand. Votre responsable d’exploitation vous confie l’analyse d’un dossier litige concernant une opération de transport national réalisée entre Paris et Lyon. La mission concernait le transport de 5 palettes de produits laitiers, pour un poids total de 2,2 tonnes. Lors de la livraison, le destinataire constate une avarie visible liée à un problème de mouille sur 2 palettes. Les réserves : • ont été formulées de manière précise sur la lettre de voiture CMR le jour de la livraison ; • ont ensuite été confirmées par lettre recommandée avec accusé de réception 2 jours après la livraison. Informations complémentaires : • Valeur réelle des 2 palettes avariées : 3 800 € ; • Poids total de la marchandise endommagée : 280 kg ; • Envoi inférieur à 3 tonnes.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Le litige est-il recevable ? Justifiez. 2. Calculez le plafond d''indemnisation selon le contrat type général (envoi &lt; 3 t). a) Par kg : _____ × 33 € = _____ b) Par colis : _____ × 1 000 € = _____ c) Plafond retenu : _____ 3. Le transporteur peut-il être tenu d''indemniser au-delà de ce plafond ? Dans quels cas ? 4. Quelle aurait été la différence si l''expéditeur avait souscrit une déclaration de valeur de 4 500 € ?</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch12','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch12 Ex 12.3 : Analyser un litige — recevabilité et plafond
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch12-facturation-litiges-cloture';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 12 &middot; Exercice 12.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyser un litige — recevabilité et plafond</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont-Ferrand. Votre responsable d’exploitation vous demande d’analyser un dossier litige relatif à une opération de transport national réalisée entre Lille et Marseille. La mission concernait le transport de 12 palettes de produits alimentaires, pour un poids total de 5,8 tonnes. À la livraison, le destinataire constate des avaries visibles sur plusieurs palettes à la suite d’un problème d’arrimage pendant le transport. Les réserves : • ont été inscrites de manière précise sur la lettre de voiture lors de la livraison ; • ont été confirmées par lettre recommandée avec accusé de réception dans les délais réglementaires. Informations complémentaires : • Nombre de palettes avariées : 4 ; • Valeur réelle des marchandises endommagées : 7 200 € ; • Poids total de la marchandise avariée : 1 150 kg ; • Envoi supérieur à 3,5 tonnes.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Vérifier si le litige est recevable et justifier votre réponse ; 2. Calculer le plafond d’indemnisation applicable selon le contrat type général 3. Indiquer dans quels cas le transporteur pourrait être tenu d’indemniser au-delà du plafond réglementaire ; 4. Expliquer quelle aurait été l’incidence d’une déclaration de valeur souscrite par l’expéditeur.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch12','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch12 Ex 12.4 : Analyse des requêtes et réclamations clients
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch12-facturation-litiges-cloture';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 12 &middot; Exercice 12.4</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyse des requêtes et réclamations clients</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANSGO, implantée à Carcassonne. L’entreprise réalise des opérations de transport frigorifique et de distribution de produits alimentaires pour le compte du client VIANDES OCCITANES. Dans le cadre du suivi qualité et du traitement des litiges transport, votre responsable d’exploitation vous demande d’analyser les différentes requêtes et réclamations clients en cours. Vous devez identifier les responsabilités éventuelles, proposer les actions correctives adaptées et déterminer, lorsque cela est nécessaire, les calculs d’indemnisation applicables.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>À l’aide du tableau ci-dessous : • analyser chaque situation ; • déterminer les actions à mener ; • préciser les interlocuteurs à contacter ; • calculer, si nécessaire, l’indemnisation applicable ; • compléter la colonne « Actions à mener / calculs éventuels de l’indemnisation ».</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch12','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.4', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch12/Ch12_Exercice_12.4_Annexe.pdf', 'Ch12_Exercice_12.4_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch12 Ex 12.5 : Clôturer un dossier avec réserves
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch12-facturation-litiges-cloture';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 12 &middot; Exercice 12.5</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Clôturer un dossier avec réserves</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Mettez dans l''ordre les étapes de clôture d''un dossier de transport ayant généré des réserves : (Numérotez de 1 à 8)</p>
<p>N° Étape de clôture</p>
<p>Déclencher la facturation du transport</p>
<p>Archiver le dossier (CMR signé + photos + échanges TMS)</p>
<p>Vérifier le retour du CMR signé avec réserves</p>
<p>Ouvrir un dossier de suivi litige dans le TMS</p>
<p>Informer le donneur d''ordres de l''existence des réserves</p>
<p>Enregistrer le statut final dans le TMS : « clôturé avec réserves »</p>
<p>Transmettre le dossier à l''assurance RC transporteur</p>
<p>Photographier la marchandise avariée avant déchargement</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch12','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch12:ex12.5', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch13 Ex 13.1 : Calculer et analyser les indicateurs KPI
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch13-kpi-rentabilite';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 13 &middot; Exercice 13.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer et analyser les indicateurs KPI</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANS EXPRESS, implantée à Clermont- Ferrand. Dans le cadre du suivi de performance de l’exploitation, votre responsable vous demande d’analyser les indicateurs clés de performance (KPI) de la semaine 38 afin d’évaluer la qualité de service, la rentabilité des opérations et le niveau d’utilisation du parc véhicules. Les données d’exploitation suivantes vous sont communiquées : • Nombre total de livraisons prévues : 142 • Nombre de livraisons réalisées à l’heure : 128 • Kilométrage total parcouru : 14 800 km • Kilomètres réalisés à vide : 3 200 km • Nombre de litiges ouverts : 4 • Nombre total d’opérations : 142 • Charge utile disponible : 29 t par véhicule × 8 véhicules = 232 t • Charge effectivement transportée : 186 t • Nombre de jours d’exploitation réalisés : 5 jours × 8 véhicules = 40 jours • Nombre de jours disponibles : 40 jours</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>A l’aide de l’</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : 1- Calculer l’ensemble des indicateurs de performance ; 2- Identifier les KPI en situation d’alerte ; 3- Pour chaque indicateur en alerte, proposer : • une cause probable ; • une mesure corrective adaptée.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch13','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch13/Ch13_Exercice_13.1_Annexe.pdf', 'Ch13_Exercice_13.1_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch13 Ex 13.2 : Analyse comptable et financière – Société MANU TRANS
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch13-kpi-rentabilite';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 13 &middot; Exercice 13.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyse comptable et financière – Société MANU TRANS</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes salarié(e) de la société MANU TRANS en qualité de gestionnaire de transport. Votre responsable vous confie l’analyse du bilan et du compte de résultat d’une filiale du groupe située dans le nord de la France. Cette filiale rencontre actuellement des difficultés de trésorerie. Votre mission consiste à étudier les documents comptables fournis afin d’identifier les causes de ces difficultés et de préconiser des solutions correctives à mettre en œuvre rapidement. À cet effet, votre responsable met à votre disposition, en</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><ol><li>Donner une définition précise du bilan et du compte de résultat.</li></ol>
<p>2. Analyser le bilan de la filiale à partir des éléments suivants que vous calculerez pour les exercices 20AA et 20AB : a) Le fonds de roulement net global (FRNG), b) Le besoin en fonds de roulement (BFR), c) La trésorerie nette (TN), d) Comparez et interprétez les résultats obtenus. Détaillez vos calculs. 3. A partir du bilan et du compte de résultat : a) Calculer les délais de paiement clients et fournisseurs pour les exercices 20AA et 20AB (taux de TVA 20%). Arrondir les résultats au nombre de jours supérieur. b) Commentez les résultats obtenus. 4. A partir du compte de résultat, calculer, pour les deux exercices 20AA et 20AB, les soldes intermédiaires de gestion (SIG) de : ❖ La valeur ajoutée ❖ L’excédent brut d’exploitation,</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : résultat de l’entreprise. TRAVAIL A REALISER 1. Donner une définition précise du bilan et du compte de résultat.</p>
<p>2. Analyser le bilan de la filiale à partir des éléments suivants que vous calculerez pour les exercices 20AA et 20AB : a) Le fonds de roulement net global (FRNG), b) Le besoin en fonds de roulement (BFR), c) La trésorerie nette (TN), d) Comparez et interprétez les résultats obtenus. Détaillez vos calculs. 3. A partir du bilan et du compte de résultat : a) Calculer les délais de paiement clients et fournisseurs pour les exercices 20AA et 20AB (taux de TVA 20%). Arrondir les résultats au nombre de jours supérieur. b) Commentez les résultats obtenus. 4. A partir du compte de résultat, calculer, pour les deux exercices 20AA et 20AB, les soldes intermédiaires de gestion (SIG) de : ❖ La valeur ajoutée ❖ L’excédent brut d’exploitation, ANNEXES</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch13','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch13/Ch13_Exercice_13.2_Annexe.pdf', 'Ch13_Exercice_13.2_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch13 Ex 13.3 : Analyser les SIG et détecter une anomalie
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch13-kpi-rentabilite';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 13 &middot; Exercice 13.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyser les SIG et détecter une anomalie</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>La société MG EXPRESS est spécialisée dans le transport de marchandises générales. En votre qualité de gestionnaire de transport, votre responsable vous demande d’analyser les Soldes Intermédiaires de Gestion (SIG) de l’exercice comptable 20AB et de les comparer à ceux de l’exercice 20AA afin d’évaluer l’évolution de la performance de l’entreprise. Pour réaliser cette étude, vous disposez en</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Vous calculerez pour l’exercice 20AA : a) Le fonds de roulement net global (FRNG), b) Le besoin en fonds de roulement (BFR), c) La trésorerie nette (TN), 2. A partir du compte de résultat, calculer, pour l’exercice 20AB, les soldes intermédiaires de gestion (SIG) de :</p>
<p>❖ La valeur ajoutée VA, ❖ L’excédent brut d’exploitation EBE, ❖ Le résultat d’exploitation REX ❖Le résultat courant avant impôt RCAI, ❖ la capacité d’autofinancement (CAF) 3. Compléter le tableau ci-dessous.</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE : 20AA et 20AB. TRAVAIL A REALISER 1. Vous calculerez pour l’exercice 20AA : a) Le fonds de roulement net global (FRNG), b) Le besoin en fonds de roulement (BFR), c) La trésorerie nette (TN), 2. A partir du compte de résultat, calculer, pour l’exercice 20AB, les soldes intermédiaires de gestion (SIG) de :</p>
<p>❖ La valeur ajoutée VA, ❖ L’excédent brut d’exploitation EBE, ❖ Le résultat d’exploitation REX ❖Le résultat courant avant impôt RCAI, ❖ la capacité d’autofinancement (CAF) 3. Compléter le tableau ci-dessous.</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch13','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch13:ex13.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch13/Ch13_Exercice_13.3_Annexe.pdf', 'Ch13_Exercice_13.3_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch14 Ex 14.1 : Calculer et communiquer l''information CO₂
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch14-environnement-rse';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 14 &middot; Exercice 14.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Calculer et communiquer l''information CO₂</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société TRANSATLANTIC LOGISTIQUE. Votre entreprise réalise une opération de transport routier de marchandises entre Paris et Bordeaux à l’aide d’un ensemble articulé de 44 tonnes. Le trajet représente une distance totale de 580 km. Le véhicule transporte 24 tonnes de marchandises, dont 8 tonnes appartenant au client TECHNIBOIS INDUSTRIE. Dans le cadre de la réglementation relative à l’information sur les émissions de gaz à effet de serre dans les prestations de transport, votre responsable vous demande de calculer les émissions de CO₂ imputables à l’envoi du client TECHNIBOIS INDUSTRIE et de préparer les informations devant figurer sur la facture transport. Facteur d’émission ADEME utilisé : 0,820 kgCO₂e/km.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1- Rédiger la mention environnementale à faire apparaître sur la facture du client TECHNIBOIS INDUSTRIE. 2- Indiquer le décret imposant cette obligation ainsi que sa date d’entrée en vigueur. 3- Recalculer les émissions de CO₂ imputables au client si le même transport était effectué avec un véhicule électrique (facteur d’émission : 0,040 kgCO₂e/km).</p>
<p>DONNÉES FOURNIES POUR RÉSOUDRE L''EXERCICE :</p>
<p>Calcul Formule Résultat Émission totale véhicule 0,820 × 580 km</p>
<p>Part de l''envoi MECA- CONCEPT 8 t / 24 t</p>
<p>CO₂ imputable à MECA- CONCEPT Émission totale × part</p></div>
      </div>
<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l''exercice.
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch14','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch14:ex14.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;
  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, 'ccp1-v2/ch14/Ch14_Exercice_14.1_Annexe.pdf', 'Ch14_Exercice_14.1_Annexe.pdf', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;

  -- Ch14 Ex 14.2 : Vérifier la compatibilité ZFE et proposer des solutions vert
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch14-environnement-rse';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 14 &middot; Exercice 14.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Vérifier la compatibilité ZFE et proposer des solutions vertes</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>La société TRANS EXPRESS doit assurer plusieurs opérations de livraison de marchandises dans Paris intra-muros. Dans le cadre de l’organisation des tournées et du respect des réglementations environnementales applicables dans les Zones à Faibles Émissions (ZFE), votre responsable d’exploitation vous demande d’analyser les véhicules actuellement disponibles afin de déterminer ceux pouvant circuler dans Paris en 2026. Vous devrez également proposer des solutions permettant d’assurer la continuité des livraisons tout en limitant l’impact environnemental de l’activité.</p>
<p>Véhicule Norme Euro Vignette Crit''Air Autorisé en ZFE Paris 2026 O/N TRR-01 (FF-514-DD) Euro 6</p>
<p>TRR-02 (HS-189-YG) Euro 5</p>
<p>TRR-03 (DD-461-VV) Euro 4</p>
<p>TRR-04 (FM-698-ZZ) Euro 3</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1- Compléter la colonne « Vignette Crit''Air ». 2- Indiquer quels véhicules sont autorisés à circuler dans la ZFE de Paris en 2026. 3- Proposer une solution à court terme permettant au gestionnaire d’exploitation d’assurer les livraisons avec les véhicules interdits. 4- Citer deux actions relevant de la démarche RSE permettant de réduire durablement les émissions polluantes de l’entreprise.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch14','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch14:ex14.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch15 Ex 15.1 : Identifier les documents pour un transport international
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch15-international';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 15 &middot; Exercice 15.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Identifier les documents pour un transport international</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Transport Document CMR O/N Douane O/N Licence requise Document douanier Clermont-Fd → Cologne (Allemagne)</p>
<p>Moulins → Bari (Italie)</p>
<p>Lyon → Londres (Royaume- Uni)</p>
<p>Clermont-Fd → Marrakech (Maroc)</p>
<p>Strasbourg → Genève (Suisse)</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch15','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch15 Ex 15.2 : Analyser une situation de cabotage
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch15-international';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 15 &middot; Exercice 15.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Analyser une situation de cabotage</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>L’entreprise espagnole IBERTRANS LOGISTICA, spécialisée dans le transport routier de marchandises, a effectué une livraison internationale à Paris le lundi 25/03. À la suite de cette opération, le transporteur souhaite réaliser plusieurs transports nationaux sur le territoire français avant son retour en Espagne. Le programme prévisionnel des opérations est le suivant : • Opération n°1 : Paris → Lyon (mardi 26/03) • Opération n°2 : Lyon → Marseille (mercredi 27/03) • Opération n°3 : Marseille → Bordeaux (vendredi 29/03) • Opération n°4 : Bordeaux → Toulouse (samedi 30/03) En tant que gestionnaire de transport au sein de la société TRANSGOTRM, vous devez vérifier la conformité de ces opérations au regard de la réglementation européenne relative au cabotage routier.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1- Rappeler la réglementation applicable au cabotage routier en France (nombre maximal d’opérations autorisées et durée autorisée). 2- Déterminer si la société IBERTRANS LOGISTICA peut légalement réaliser les quatre opérations prévues. Justifier votre réponse.</p>
<p>3- Indiquer les sanctions encourues en cas de cabotage irrégulier. 4- Expliquer les conséquences possibles pour la société TRANSGOTRM en tant que donneur d’ordres.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch15','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch15 Ex 15.3 : Tarifer un transport international et identifier l''Incoterm
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch15-international';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 15 &middot; Exercice 15.3</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Tarifer un transport international et identifier l''Incoterm</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>La société SA MBL MECANIC, située à Chamalières, doit expédier une commande de pièces mécaniques à destination d’un client basé à Barcelone, en Espagne. L’expédition comprend 33 palettes Europe pour un poids total de 26 tonnes. La distance entre le site de chargement et le lieu de livraison est de 867 km. Les conditions de vente convenues entre SA MBL MECANIC et son client sont établies selon l’Incoterm DAP Barcelone. Le transport est réalisé en moyens propres par la société de transport, avec application de la méthode du trinôme économique. Une marge commerciale de 10 % est appliquée sur le prix de vente HT. Données d’exploitation : • Taux kilométrique (TK) : 0,615 € / km • Taux horaire (TH) : 27,08 € / h • Taux journalier (TJ) : 198,35 € / jour • Temps de chargement : 1 h 30 • Temps de déchargement : 1 h 30 • Durée totale de la mission : 2 jours • Vitesse commerciale moyenne : 68 km/h • Facteur d’émission CO₂ : 0,820 kgCO₂e/km Votre responsable d’exploitation vous demande d’étudier la rentabilité de cette opération de transport ainsi que les obligations de facturation applicables dans le cadre d’un transport international.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Préciser les obligations liées à l’Incoterm DAP Barcelone : • Qui organise le transport ? • Qui prend en charge les frais de transport ? • Jusqu’à quel point le vendeur est-il responsable de la marchandise ? 2. Calculer le coût de revient de la mission à l’aide de la méthode du trinôme. Détaillez vos calculs. 3. Calculer le prix de vente HT. 4. Indiquer si la TVA française est applicable à cette opération de transport international et préciser le montant à facturer au client. Justifier votre réponse. 5. Calculer les émissions de CO₂ générées par cette prestation de transport. 6. Rédiger la mention environnementale devant figurer sur la facture client.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch15','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch15:ex15.3', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch16 Ex 16.1 : Suivre les mouvements de palettes
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch16-supports-charge';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 16 &middot; Exercice 16.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Suivre les mouvements de palettes</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>La société TRANSGO installée à Clermont-Fd assure le suivi des mouvements de palettes Europe échangées avec ses clients. Le responsable d’exploitation vous transmet le relevé des mouvements de palettes pour la semaine du 24 au 28/03/20AA. Votre mission consiste à compléter le tableau de suivi, à identifier les clients présentant une dette palettes et à évaluer le montant financier correspondant.</p>
<p>Date Client Pal. livrées Pal. récupérées Solde semaine Observations 24/03 MECA-LOG 18 18</p>
<p>24/03 SKODA 12 0</p>
<p>Absence d''échange — BL signé 25/03 GEMA SAS 6 8</p>
<p>Régularisation partielle 26/03 LES SUCRERIES 22 20</p>
<p>27/03 FRUITS-ROUGES 10 0</p>
<p>Destinataire absent — report 28/03 MECA-LOG 14 16</p>
<p>Total semaine</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1- Compléter la colonne « Solde semaine » pour chaque ligne. Solde positif : le client doit des palettes à TRANSGO. Solde négatif : TRANSGO doit des palettes au client. 2- Identifier le client présentant la dette palettes la plus importante. 3- Indiquer l’action à entreprendre concernant le client SKODA. 4- Calculer la valeur financière de la dette totale, sur la base de 12 € par palette Europe.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch16','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch16:ex16.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch16 Ex 16.2 : Gérer une dette palettes
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch16-supports-charge';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 16 &middot; Exercice 16.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Gérer une dette palettes</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Vous êtes gestionnaire de transport au sein de la société AUVERGNE LOGISTICS, spécialisée dans le transport routier de marchandises et la distribution palettisée. Dans le cadre du suivi des supports de charge, vous constatez que le client FRUITS SECS, situé à Mâcon, présente une dette de 38 palettes Europe non restituées depuis maintenant 4 semaines. Malgré plusieurs relances effectuées par téléphone auprès du client, aucune régularisation n’a été réalisée à ce jour. La valeur de consigne prévue contractuellement est fixée à 12 € HT par palette Europe. Les Conditions Générales de Vente de la société AUVERGNE LOGISTICS précisent que : « Les palettes consignées doivent être restituées dans un délai maximum de 30 jours. » Votre responsable d’exploitation vous demande de traiter ce dossier afin d’assurer le suivi administratif et financier de cette dette palettes.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Calculer la valeur financière totale de la dette palettes. 2. Identifier les documents permettant de justifier cette dette palettes (citez-en au moins trois). 3. Rédiger un mail de mise en demeure à destination du client FRUITS SECS afin d’obtenir la restitution des palettes ou leur règlement financier. 4. Indiquer les actions pouvant être engagées par l’entreprise si le client ne répond pas aux relances.</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch16','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch16:ex16.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch17 Ex 17.1 : Traduction et vocabulaire métier
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch17-anglais-pro';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 17 &middot; Exercice 17.1</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Traduction et vocabulaire métier</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Français Anglais Français Anglais Expéditeur</p>
<p>Destinataire</p>
<p>Panne</p>
<p>Retard</p>
<p>Bon de livraison signé</p>
<p>Lettre de voiture</p>
<p>Charge utile</p>
<p>Manquant</p>
<p>Avarie</p>
<p>Fret de retour</p>
<p>Transporteur</p>
<p>Sous-traitant</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch17','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch17:ex17.1', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  -- Ch17 Ex 17.2 : Communiquer en anglais face à un aléa
  SELECT id INTO v_module FROM public.modules WHERE slug = 'gotrm-ch17-anglais-pro';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre 17 &middot; Exercice 17.2</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">Communiquer en anglais face à un aléa</div>
    </div>
<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>Your British client LONDON MOTORS calls you at 14h00. He is worried : his delivery (20 Euro pallets of car parts, from Clermont-Fd to Birmingham) was expected this morning at 10h00 but has not arrived yet. You know the driver has experienced a breakdown near Lyon at 09h30. A replacement vehicle is being organised. New ETA: 17h00.</p></div>
      </div>
<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;"><p>1. Answer the client professionally in English. Your reply should include : a) An apology and acknowledgement of the situation. b) A factual explanation of the breakdown. c) The solution in place. d) The new estimated time of arrival. e) A commitment to keep him informed. 2. Translate the following sentence into French: ''The consignee refused the goods due to visible damage on two pallets. We need the signed CMR with reservations.''</p></div>
      </div>', 6, 'moyen',
    ARRAY['CCP1','Ch17','QR-v2'], 'mft-2026-gotrm-ccp1-qr-v2:ch17:ex17.2', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;

  RAISE NOTICE 'CCP1 QR v2 : % questions, % attachments', v_count_questions, v_count_attachments;
END $ccp1_qr_v2$;
