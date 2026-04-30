# Product

## Register

product

## Users

**Stagiaires** (cœur de cible)
- Adultes 25-55 ans, professionnels du transport ou en reconversion (chauffeurs, dirigeants TPE, demandeurs d'emploi)
- Niveau scolaire variable, du CAP au Bac+3
- Souvent peu à l'aise avec le numérique → l'interface doit rester accessible
- Job-to-be-done : **réussir un titre RNCP / une attestation pro** (Capacité -3,5T, GOTRM, FIMO/FCO, ECSR, Taxi-VTC, Commissionnaire) qui débloque un emploi ou la création d'entreprise
- Contexte d'usage : préparation à la maison entre deux journées de travail, sur mobile autant que desktop

**Formateurs**
- Pros expérimentés du secteur, suivent 10-30 stagiaires en parallèle
- Job : corriger les copies QR, animer la messagerie, suivre la progression

**Admin / Super-admin**
- Direction de l'organisme + équipe pédagogique
- Job : pilotage, conformité Qualiopi, financement, audit

## Product Purpose

MA FORMATION TRANSPORT est la plateforme e-learning de référence pour la
préparation aux titres pros et certifications du transport routier
(marchandises et voyageurs). Elle fournit un parcours complet : modules
pédagogiques, quiz d'entraînement, examens blancs corrigés par des
formateurs réels, suivi administratif Qualiopi.

**Succès** = un stagiaire passe son examen RNCP avec confiance, un
organisme passe son audit Qualiopi sans accroc, un financeur
(CPF / OPCO / France Travail) reçoit ses justificatifs en 1 clic.

## Brand Personality

**Premium, moderne, pédagogique.**

- **Voix** : claire et directe, sans jargon administratif. Tutoie pas, vouvoie poliment.
- **Ton** : sérieux et expert, mais jamais froid. Confiance sans arrogance.
- **Émotion cible** : "je suis entre les mains de pros qui me prennent au sérieux".
- **Pas marketing-bullshit** : pas de "révolution", pas de "leader", pas de
  promesse impossible. Les chiffres parlent (taux de réussite, satisfaction).

## Anti-references

À fuir absolument :
- **Studi / Skill&You / Educatel old-school** : design daté 2010-2015, gros
  blocs de texte, photos stock corporate, boutons orange criards
- **Sites de formation low-cost** type Coursera générique, templates WordPress
  EdTech, école de chauffeur "fait maison"
- **Corporate ennuyeux** type formations CCI : tableaux gris, navigation
  hiérarchique lourde, accordéons sans fin
- **Gadget over-animé** : parallax sauvage, scroll-jacking, particules,
  animations de chargement décoratives
- **Bricolé / amateur** : composants désalignés, couleurs mal harmonisées,
  cartes sans hiérarchie, espacements aléatoires

Inspirations positives :
- **Stripe** pour la clarté typographique, les sections rythmées, la sobriété
- **Apple** pour l'espace, le poids visuel maîtrisé, le détail léché
- **Linear** pour la rigueur produit, les micro-interactions discrètes

## Design Principles

1. **Premium par la sobriété, pas par la décoration.** Espace, typo, hiérarchie
   d'abord — effets visuels en dernier recours.
2. **Confiance par la précision.** Chiffres, dates, statuts toujours exacts et
   visibles. Pas de placeholder, pas de "lorem ipsum" en prod.
3. **Pédagogique reste lisible.** Aucune section ne doit perdre le stagiaire.
   Une action principale par écran, jamais deux concurrentes.
4. **Multi-formations identifiable.** Chaque formation a une couleur d'accent.
   Le badge formation est l'élément le plus reconnaissable.
5. **Mobile équivalent au desktop.** 50 % des stagiaires révisent sur téléphone.
   Aucun parcours critique ne doit dégrader sur petit écran.

## Accessibility & Inclusion

- **WCAG 2.1 AA** comme socle (contraste, focus visible, alt textes, hiérarchie
  H1→H6 sémantique).
- **Tailles de typo généreuses** : minimum 15 px pour le corps de texte, 16 px
  recommandé. Public adulte, parfois presbyte.
- **Reduced motion** : `prefers-reduced-motion` désactive tous les transitions
  non-essentielles (pas seulement les marketing).
- **Public francophone** : contenu en français exclusivement à ce stade. Pas
  de copy "tech anglo" non traduit.
- **Référent handicap** documenté (`accessibilityContact` dans
  `lib/legal-config.ts`) — Qualiopi indicateur 21.
