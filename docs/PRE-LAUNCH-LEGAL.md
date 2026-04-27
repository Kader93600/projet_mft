# Checklist juridique pré-déploiement

Document de travail interne. À cocher **avant** d'ouvrir les inscriptions.

---

## 1. À compléter dans le code

Tous les champs `[À COMPLÉTER]` du fichier `lib/legal-config.ts` doivent être remplis avec les vraies valeurs de l'organisme :

- [ ] Raison sociale exacte (KBis)
- [ ] Forme juridique (SAS / SASU / EURL / SARL / EI)
- [ ] SIRET (14 chiffres)
- [ ] RCS (ville + numéro)
- [ ] Numéro de TVA intracommunautaire
- [ ] Capital social
- [ ] Adresse complète
- [ ] Représentant légal (nom du président / gérant)
- [ ] Directeur de publication (souvent = représentant légal)
- [ ] Téléphone + emails (contact / support / DPO / accessibilité)
- [ ] Numéro de déclaration d'activité OF (11 chiffres + région)
- [ ] Numéro de certification Qualiopi
- [ ] Nom de l'organisme certificateur Qualiopi
- [ ] Nom du DPO ou délégué (peut être interne)
- [ ] Médiateur de la consommation (CM2C, ANM Conso, etc. — abonnement obligatoire en B2C)
- [ ] Date de dernière mise à jour des CGV (`LEGAL_LAST_UPDATE`)

Une fois fait :

```bash
git diff lib/legal-config.ts   # vérifier qu'aucun [À COMPLÉTER] ne reste
grep -r "À COMPLÉTER" lib/legal-config.ts   # doit ne rien renvoyer
```

---

## 2. Démarches administratives à faire

### 2.1 Hébergement et données (RGPD)

- [ ] **DPA Supabase signé**. Aller sur https://supabase.com/dashboard → Project Settings → Legal → Data Processing Agreement → Sign. Conserver une copie PDF.
- [ ] **Région EU confirmée**. Project Settings → General → Region : doit être `eu-west-3 (Paris)` ou `eu-central-1 (Frankfurt)`. Si autre, prévoir migration **avant** premiers vraies données.
- [ ] **Backups vérifiés**. Project Settings → Database → Backups : daily activé. Faire un test de restauration sur projet de staging.
- [ ] **Tester un export RGPD complet** depuis `/mes-donnees` → `Télécharger (.json)`. Vérifier que toutes les tables y figurent.
- [ ] **Tester `anonymize_user`** sur un compte de test. Vérifier que les PII disparaissent et que les stats restent.

### 2.2 Organisme de formation

- [ ] **Déclaration d'activité OF** à jour (DREETS de la région — anciennement DIRECCTE).
- [ ] **Bilan Pédagogique et Financier (BPF)** N-1 transmis à la DGEFP avant le 30 avril.
- [ ] **Certification Qualiopi** valide (durée 3 ans, audit de surveillance à 18 mois).
- [ ] **Référencement Datadock / OPCO** si vous visez ces financeurs.
- [ ] **Inscription EDOF** (Mon Compte Formation / Caisse des Dépôts) si vous visez le CPF — délai ~3 mois, démarrer tôt.

### 2.3 Médiation et assurance

- [ ] **Adhésion à un médiateur** de la consommation (CM2C, ANM Conso, MEDICYS…). ~120 €/an. Obligatoire dès 1 client B2C.
- [ ] **Assurance Responsabilité Civile Professionnelle**. Vérifier que la couverture inclut formation à distance.

### 2.4 Fiscalité

- [ ] **Exonération TVA** confirmée pour vos prestations (article 261-4-4° du CGI : organismes de formation déclarés). Demander l'attestation à votre comptable.
- [ ] Comptes bancaires séparés si auto-financement vs paiements OPCO (recommandation expert-comptable, non obligatoire).

### 2.5 Communication / marketing

- [ ] **Logo Qualiopi officiel** téléchargé depuis le site de votre certificateur, à afficher avec mention « action de formation ».
- [ ] **Mention « France Compétences »** + n° RNCP visible sur la landing.
- [ ] Affichage du **taux de réussite, satisfaction, insertion** (obligation Qualiopi 9). Aujourd'hui placeholders dans `lib/legal-config.ts → qualiopi.*`. À mettre à jour dès la 1ère cohorte (et tous les 12 mois min).

---

## 3. Variables d'environnement de production

Créer `.env.production.local` (ne pas commit) avec :

```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...   # uniquement pour scripts serveur
SUPABASE_PROJECT_ID=...

# Email transactionnel (à choisir : Resend / Postmark / SendGrid)
EMAIL_PROVIDER_API_KEY=...
EMAIL_FROM_ADDRESS=contact@gotrm-academy.fr

# Sentry
SENTRY_DSN=...
SENTRY_AUTH_TOKEN=...
```

- [ ] Ajouter ces variables dans Vercel → Project → Settings → Environment Variables (scope: Production).
- [ ] Configurer **DKIM, SPF, DMARC** sur le domaine email envoyeur.
- [ ] Vérifier la délivrabilité avec https://www.mail-tester.com (score > 9/10).

---

## 4. Tests d'acceptation pré-déploiement

À jouer manuellement (ou à automatiser en E2E) :

- [ ] Signup → onboarding → positionnement → dashboard accessible.
- [ ] Inscription via formulaire → email d'accusé de réception reçu.
- [ ] Téléchargement convention de formation PDF → contenu cohérent.
- [ ] Examen blanc en plein écran → sortie détectée → log `focus_loss_count > 0`.
- [ ] Cookie banner → "Refuser tout" → aucun cookie analytics posé.
- [ ] Demande de suppression RGPD → email DPO reçu côté admin.
- [ ] Export `/mes-donnees` → JSON complet.
- [ ] Connexion admin → accès à `/admin/rgpd` → liste vide ou cohérente.
- [ ] Mode sombre activé → cohérent sur toutes les pages publiques + connectées.

---

## 5. Pages légales publiques (bilan)

Toutes ces pages doivent être accessibles **sans authentification** :

| Route                        | Statut |
|------------------------------|--------|
| `/mentions-legales`          | ✅      |
| `/cgu`                       | ✅      |
| `/cgv`                       | ✅      |
| `/confidentialite`           | ✅ (existant) |
| `/retractation`              | ✅      |
| `/reglement-interieur`       | ✅      |
| `/accessibilite`             | ✅ (existant) |

Vérifier que :

- [ ] Le footer est visible sur la landing `/` (composant `<LegalFooter />`).
- [ ] Les liens en pied de la page de login pointent vers les bonnes routes.
- [ ] Aucune route légale n'est bloquée par le middleware.

---

## 6. Suivi des modifications légales

Toute modification des CGV / CGU / politique de confidentialité doit :

1. Incrémenter `LEGAL_LAST_UPDATE` dans `lib/legal-config.ts`.
2. Faire l'objet d'une notification interne aux Stagiaires actifs (table `notifications`).
3. Conserver un historique versionné (commit Git + tag, ou table `legal_versions` si vous voulez tracer en BDD).

Pour les modifications majeures (ex. nouveau financeur, sous-traitant) :

- [ ] Notifier les Stagiaires par email.
- [ ] Mettre à jour la registre des traitements RGPD.
- [ ] Re-signer le DPA si changement de sous-traitant.
