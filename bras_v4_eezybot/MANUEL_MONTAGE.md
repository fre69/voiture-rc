# Manuel de montage — Bras EEZYbotARM MK2 adapté Mecanum

Version simplifiée **sans rotation de base** (les étapes rotation du manuel original sont sautées).

## Sources de référence
- **Vidéo YouTube (Chris Riley, recommandée)** : https://www.youtube.com/watch?v=R2MI-tpXyS4
- **Instructables (manuel officiel daGHIZmo)** : https://www.instructables.com/EEZYbotARM-Mk2-3D-Printed-Robot/
- **Site auteur** : http://www.eezyrobots.it/eba_mk2.html

> ⚠️ La vidéo YouTube est plus claire que les photos Instructables pour les détails de manipulation. **Regarde-la au moins une fois en entier avant de commencer.**

---

## Pré-requis avant montage

- [ ] Les 14 STL du dossier `stl_original/print/` sont imprimés et nettoyés (bavures, support enlevé)
- [ ] Visserie M3 + M4 réceptionnée (voir `BRAS_ROBOTIQUE_SPEC.md` §3)
- [ ] 2× MG996R + 1× SG90 prêts (avec leurs palonniers et vis auto-taraudeuses fournies)
- [ ] Outils : tournevis cruciforme PH1/PH2, clé Allen 2.5/3 mm, pince à long bec, scie à métaux ou Dremel pour couper les tiges filetées M4
- [ ] **`support_chassis.scad` imprimé** (pièce custom à concevoir séparément après mesures du châssis)

---

## Étape 0 — Fixation du bras au châssis (custom, hors manuel original)

> Cette étape **remplace** toute la section "rotation de base" du manuel original.

1. Visser la **plaque `support_chassis`** (custom) sur le châssis alu Mecanum, position prévue à l'avant
   - 4× vis M3 (à confirmer selon pattern du châssis)
2. Visser `EBAmk2_001_base.STL` sur la plaque `support_chassis`
   - Utiliser les 2-3 trous existants au fond de `001_base` (ceux qui servaient à fixer le mainbase rotatif)
   - 2× vis M3 + écrou nylstop M3

---

## Étape 1 — Servos d'épaule et parallélogramme

### 1.1 Installer les 2 MG996R dans `001_base`

Les 2 servos se logent dans les emplacements latéraux de `EBAmk2_001_base.STL`, **arbres face avant**.

- **MG996R #1 (épaule)** : côté qui pilotera `EBAmk2_002_mainarm.STL`
- **MG996R #2 (parallélogramme)** : côté qui pilotera `EBAmk2_003_varm.STL`

Pour chaque MG996R :
1. **Placer le servo au centre (90°)** AVANT de le fixer mécaniquement (via le contrôleur ESP32, ou en alimentant brièvement le servo avec une commande 1500 µs)
2. Insérer le servo dans son logement, arbre vers l'avant
3. Fixer avec **les 4 vis auto-taraudeuses fournies avec le servo** (2 par côté)
4. Câble du servo passe par l'arrière de la base

### 1.2 Installer les palonniers

- Visser le palonnier MG996R single-arm (livré avec le servo) sur l'arbre de chaque servo
- Vis M3 centrale du palonnier (vis fournie avec le servo)
- **Le palonnier doit être perpendiculaire à l'axe vertical** (servo au centre 90° → palonnier horizontal vers l'avant)

---

## Étape 2 — Montage du bras vertical et parallélogramme

### 2.1 Articulation principale (axe X horizontal)

1. Positionner `EBAmk2_002_mainarm.STL` (bras principal vertical) à plat sur la base
2. Positionner `EBAmk2_003_varm.STL` (bras vertical parallélogramme) à côté, dans son logement
3. Insérer la **tige filetée M4 × 60 mm** à travers l'axe horizontal de la base, en traversant les 2 pièces
4. Aux extrémités : **écrou nylstop M4** + rondelle M4

> Réglage des écrous : serrer jusqu'à blocage de la rotation, puis **desserrer** d'1/4 à 1/2 tour jusqu'à obtenir une rotation fluide sans jeu en Z.

### 2.2 Liaison bras → palonniers servos

Chaque bras se relie au palonnier de son servo via :
- 1× vis M3×10 (auto-taraudeuse) ou M3×15
- Le bras a un trou aligné avec un trou du palonnier

Faire pour `mainarm` ↔ palonnier MG996R #1, et `varm` ↔ palonnier MG996R #2.

### 2.3 Liaison parallélogramme inférieure

- `EBAmk2_004_link135.STL` (biellette droite 135 mm) : connecte la base à la première articulation
  - 2× vis M4 × 20 mm + écrous nylstop M4
- `EBAmk2_005_link135angled.STL` (biellette coudée 135 mm) : autre côté
  - 2× vis M4 × 20 mm + écrous nylstop M4

---

## Étape 3 — Avant-bras et triangle

### 3.1 Triangle de transmission

1. Positionner `EBAmk2_007_trialink.STL` au sommet du parallélogramme arrière
2. Positionner `EBAmk2_009_trialinkfront.STL` (triangle avant porte-pince) au sommet du bras principal
3. Connecter via la **tige filetée M4 × 32 mm** + 2× écrou nylstop M4

### 3.2 Avant-bras horizontal

1. `EBAmk2_006_horarm_plate.STL` (avant-bras renforcé) se fixe au triangle avant
2. 2× vis M4 × 20 mm + écrous nylstop M4

### 3.3 Biellette supérieure

- `EBAmk2_008_link147_new.STL` (biellette 147 mm) : ferme le parallélogramme entre le triangle arrière et l'avant-bras
- 2× vis M4 × 20 mm + écrous nylstop M4

> À ce stade tu dois pouvoir bouger le bras à la main et l'**avant-bras reste horizontal** quoi qu'il arrive (parallélogramme actif). Vérifier avant d'aller plus loin.

---

## Étape 4 — Pince

### 4.1 Engrenages mâchoires

1. `EBAmk2_015_claw_finger_dx.STL` (doigt droit) reçoit `EBAmk2_018_claw_gear_driven.STL` (engrenage mené) — collé ou vissé
2. `EBAmk2_017_claw_finger_sx.STL` (doigt gauche) reçoit `EBAmk2_016_claw_gear_drive.STL` (engrenage menant) — collé ou vissé

### 4.2 Servo SG90 + corps pince

1. Insérer le **SG90 dans `EBAmk2_014_claw_base.STL`** (corps pince)
2. Fixer avec 2× vis auto-taraudeuses fournies avec le SG90
3. Centrer le SG90 (90° = pince à mi-course) AVANT de poursuivre
4. Visser le palonnier SG90 fourni → fixe l'engrenage menant `claw_gear_drive`

### 4.3 Assemblage final pince

1. Insérer les 2 doigts dans le corps pince, engrenages engagés
2. Pivots des doigts : **2× vis M3 × 20 mm** + écrous nylstop M3
3. Vérifier l'ouverture/fermeture à la main : doit être fluide, sans jeu excessif

### 4.4 Fixation pince sur l'avant-bras

- Le corps pince a un système de **fast-release** (quick coupler) qui se clipse sur l'avant-bras
- Glisser dans le rail de `horarm_plate`, puis sécuriser avec 1× vis **M3 × 10 mm hex creuse** (la vis spéciale du BOM)

---

## Étape 5 — Câblage électrique

3 servos à connecter à l'ESP32 (voir `ROBOT_MECANUM_ESP32_SPEC.md` pour les pins exacts) :

| Servo | Position | Câble passe par... |
|---|---|---|
| MG996R #1 (épaule) | Côté gauche `001_base` | Arrière de la base |
| MG996R #2 (parallélogramme) | Côté droit `001_base` | Arrière de la base |
| SG90 (pince) | Sur la pince | À l'**intérieur** de l'avant-bras (le horarm est creux pour ça) |

**Astuce vidéo Chris Riley** : router le câble SG90 dans le creux du `horarm_plate` AVANT de finaliser la pince — sinon faut tout démonter.

---

## Étape 6 — Premier test et calibration

### 6.1 Vérification mécanique à froid (servos non alimentés)

- [ ] Bouger l'épaule à la main : course d'environ 90° (de l'horizontale au quasi-vertical)
- [ ] Bouger le parallélogramme à la main : course d'environ 90°
- [ ] Avant-bras reste horizontal pendant tout le mouvement
- [ ] Pince ouvre/ferme à la main, doigts bougent symétriquement

### 6.2 Premier test sous tension

> ⚠️ Avant de mettre les 3 servos sous PWM, **METTRE EN BUTÉE BASSE** chaque articulation à la main (épaule baissée, parallélogramme replié, pince fermée). Sinon un servo qui démarre mal positionné peut forcer mécaniquement.

1. Brancher l'alimentation 5V (mini560 buck)
2. Envoyer 1500 µs sur chaque servo (position centre)
3. Le bras doit se positionner en mi-course sans bruit, sans tremblement
4. Si un servo grogne / vibre / bloque → couper et vérifier l'assemblage

### 6.3 Calibration des limites angulaires

Pour chaque servo, déterminer **les pulses min/max sans forcer mécaniquement** :

1. Démarrer à 1500 µs
2. Diminuer progressivement par pas de 50 µs jusqu'à approche de la butée → noter `min_pulse`
3. Idem en augmentant jusqu'à l'autre butée → noter `max_pulse`
4. **Ajouter une marge de sécurité de 50-100 µs** par rapport aux butées physiques

Reporter les valeurs dans `bras_v4_eezybot/NOTES_ASSEMBLAGE.md`.

---

## Notes de réglage classiques

- **Écrous nylstop sur les pivots** : règle d'or = serrer jusqu'à blocage, puis **desserrer 1/4 à 1/2 tour** pour obtenir rotation fluide sans jeu. Le freinfilet n'est pas nécessaire (les nylstop tiennent).
- **Sens de rotation des servos** : si un servo va dans le mauvais sens à la commande PWM, l'inverser logiciellement (`servo.write(180-angle)`) plutôt que de retourner mécaniquement.
- **Si la pince ne ferme pas complètement** : ajuster le centrage du palonnier SG90 (le retirer + tourner d'un cran avant de revisser).
- **Si le parallélogramme bloque en haut/bas** : vérifier qu'aucune biellette ne touche une autre pièce. Limiter en logiciel les angles épaule/coude pour rester dans la zone sûre.

---

## Ce qui change vs manuel daGHIZmo original

| Étape originale | Notre version |
|---|---|
| Step 1 — Main base avec rotation, 25 billes, 606zz, 3 vis M3 dans receptacles, vis M6×25 | **Sautée** → remplacée par étape 0 (fixation `001_base` sur `support_chassis` puis châssis Mecanum) |
| Step 2 — Main arms (3 servos dont 1 rotation) | Étape 1+2 — **2 MG996R seulement**, pas le 3e |
| Step 3 — Gripper | Étape 4 — identique |
| Cable routing à l'arrière "pour rotation libre verticale" | Cable routing direct vers l'ESP32 sur le châssis, pas besoin de slack rotation |
