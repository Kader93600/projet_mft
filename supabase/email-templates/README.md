# 📧 Templates Supabase Auth — MA FORMATION TRANSPORT

Templates HTML brandés MFT pour Supabase Auth, à coller dans le Dashboard
Supabase → **Authentication** → **Email Templates**.

## Quand sont-ils envoyés ?

| Template | Fichier | Déclencheur |
|---|---|---|
| **Confirm signup** | `01-confirm-signup.html` | Création de compte → demande de confirmation email |
| **Reset password** | `02-reset-password.html` | "Mot de passe oublié" cliqué |
| **Magic link** | `03-magic-link.html` | Login sans mot de passe (passwordless) |
| **Change email address** | `04-change-email.html` | User change son email dans son compte |
| **Invite user** | `05-invite.html` | Admin invite un user manuellement |

## Variables disponibles (Supabase)

Supabase injecte ces placeholders Go-template dans les templates :

| Variable | Contenu |
|---|---|
| `{{ .ConfirmationURL }}` | Lien complet de confirmation (déjà signé) |
| `{{ .Token }}` | Token brut 6 chiffres (alternative au lien) |
| `{{ .TokenHash }}` | Hash du token |
| `{{ .SiteURL }}` | URL du site (Site URL config Supabase) |
| `{{ .Email }}` | Email du destinataire |
| `{{ .Data.X }}` | Custom data (si défini lors du signup) |

## Comment installer

1. Va sur **https://supabase.com/dashboard** → projet → **Authentication** → **Email Templates**
2. Sélectionne le template à modifier (Confirm signup, Reset password, etc.)
3. **Copie le contenu HTML** du fichier correspondant
4. **Colle** dans le champ "Message body" de Supabase
5. **Modifie aussi "Subject heading"** :
   - Confirm signup → `Confirmez votre inscription chez MA FORMATION TRANSPORT`
   - Reset password → `Réinitialisez votre mot de passe — MA FORMATION TRANSPORT`
   - Magic link → `Votre lien de connexion — MA FORMATION TRANSPORT`
   - Change email → `Confirmez votre nouvelle adresse email`
   - Invite user → `Vous avez été invité chez MA FORMATION TRANSPORT`
6. Save

## Design

- Layout cohérent avec les autres emails MFT (cf. `lib/email.ts`)
- Navy `#0E1240` + signal-lime `#9FE220` + ivory `#FAF8F4`
- Compatible Outlook + Gmail + Apple Mail + dark mode iOS
- Tables HTML pour compat maximale
- Mobile-first responsive

## Pour debug

Supabase ne permet pas de prévisualiser le rendu d'un template avec
les variables injectées. Pour tester :
1. Déclenche réellement le flow (signup / reset password / etc.)
2. Vérifie l'email reçu

⚠️ Garde toujours le lien `{{ .ConfirmationURL }}` (sinon le mail est inutile).
