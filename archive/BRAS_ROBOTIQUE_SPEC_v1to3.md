# Bras Robotique 2 Servos + Parallélogramme — Cahier des charges pour modèle OpenSCAD

## 1. Vue d'ensemble

Bras robotique simple à 2 degrés de liberté pour robot Mecanum.
Monté sur le plateau supérieur du châssis alu.
Pas de rotation de base (le robot pivote sur lui-même).
**Parallélogramme passif** pour maintenir la pince horizontale quelle que soit la position de l'épaule.

### Principe du parallélogramme
```
Position basse :                    Position haute :

    D●━━━━━━━━━●C Pince              D●━━━━━━━━━●C Pince
     ┃(horizontal)┃                  ╱         ╱  (toujours horizontal !)
     ┃ Bras       ┃ Biellette     Bras      Biellette
     ┃            ┃              ╱         ╱
    A●━━━━━━━━━●B             A●━━━━━━━━━●B
     Support                    Support

ABCD forme un parallélogramme :
- A = axe MG996R (épaule, motorisé)
- B = pivot libre sur le support (au-dessus de A)
- AD = bras principal (longueur L)
- BC = biellette (longueur L, identique au bras)
- AB = entraxe pivots sur le support (hauteur H)
- DC = entraxe pivots bout du bras (hauteur H, identique à AB)
→ CD reste TOUJOURS parallèle à AB
→ la pince reste TOUJOURS horizontale
```

### Mouvements
- **Épaule** : rotation verticale haut/bas (MG996R) — plage ~90°
- **Pince** : ouverture/fermeture (SG90) — plage ~60°
- **Parallélogramme** : maintien horizontal passif (mécanique, pas de servo)

### Matériaux
- **PETG** : toutes les pièces structurelles (bras, support, corps pince)
- **TPU** : embouts de doigts (grip), butées fin de course, silent blocks

---

## 2. Dimensions des servos

### MG996R (épaule)
```
              ┌─────────┐
              │ Palonnier│
    ┌─────────┼────●────┼─────────┐
    │         └─────────┘         │
    │                             │
    │      ╔═══════════════╗      │
    │      ║               ║      │
    │      ║    MG996R     ║      │
    │      ║               ║      │
    │      ╚═══════════════╝      │
    │  ▲                     ▲    │
    └──┤  oreilles fixation  ├────┘
       ▼                     ▼

Dimensions (mm) :
- Corps : 40.7 (L) × 19.7 (l) × 42.9 (H, avec axe)
- Axe de sortie : à 10 mm du bord supérieur
- Oreilles de fixation : dépassent de 7.5 mm de chaque côté
  → Largeur totale avec oreilles : 54.7 mm
- Trous de fixation oreilles : M3 (3.2 mm), entraxe 49 mm × 10 mm
- Diamètre axe : 5.8 mm (cannelé 25 dents)
- Palonnier fourni : croix ou simple, fixation vis M3
- Câble : sort du bas, longueur ~300 mm
```

### SG90 (pince)
```
Dimensions (mm) :
- Corps : 22.5 (L) × 12.0 (l) × 26.7 (H, avec axe)
- Axe de sortie : centré, dépasse de ~4 mm
- Oreilles de fixation : dépassent de 2.5 mm de chaque côté
  → Largeur totale avec oreilles : 32.5 mm
- Trous de fixation oreilles : M2 (2.2 mm), entraxe 27.5 mm
- Diamètre axe : 4.7 mm (cannelé 21 dents)
- Palonnier fourni : simple bras ou croix
- Câble : sort du bas, longueur ~150 mm
```

---

## 3. Pièces à modéliser

### Pièce 1 — Support épaule avec double pivot (PETG)

Équerre en L qui fixe le MG996R au châssis alu.
Le servo est monté **horizontalement**, axe pointant vers l'avant du robot.
**Inclut un 2ème pivot** au-dessus de l'axe servo pour la biellette du parallélogramme.

```
Vue de côté :

     Pivot B (biellette) ──── ●  ← vis M3 libre (pivot passif)
                              │
                    30 mm     │  (entraxe A-B)
                              │
     Pivot A (épaule) ─────── ●  ← axe MG996R (motorisé)
                         ╔════╧════╗
                         ║  MG996R  ║
                         ║          ║
                         ╠══════════╣── oreilles servo
                         ║          ║
                    ═════╩══════════╩════════════
                              Base fixée au châssis

Vue de face :
    ┌──────────────────────────┐
    │          ○                │  ← pivot B biellette (M3, traverse la paroi)
    │                          │
    │  ┌────────────────────┐  │
    │  │     Logement        │  │  ← évidement pour le corps servo
    │  │     MG996R          │  │     profondeur 20 mm (demi servo)
    │  │                     │  │
    │  └────────────────────┘  │
    │  ○                    ○  │  ← trous oreilles servo M3
    │                          │
    ├──────────────────────────┤
    │  ○    ○        ○    ○   │  ← 4 trous fixation châssis M3
    └──────────────────────────┘
```

#### Cotes
```
- Largeur base : 56 mm (peut être réduit vs 60 mm initial)
- Profondeur base : 45 mm
- Hauteur totale : ~54 mm (U-bracket compact, vs 85 mm initial)
  → Le servo est bas, la plaque avant s'affine vers le pivot B
- Épaisseur parois : 3 mm (U-bracket) à 5 mm (L-bracket)
- Logement servo : 41 × 20 × 20 mm (avec jeu de 0.3 mm)
- Fentes pour oreilles servo : 2 × (8 × 3.5 mm)
- Trous fixation oreilles : 2 × M3 (3.2 mm), entraxe 49 mm
- Trous fixation châssis : 4 × M3 (3.2 mm), en rectangle 50 × 20 mm
- Passage câble servo : fente 8 × 4 mm en bas de la paroi
- Rainure pour silent block TPU : 2 mm de profondeur sous la base

PARALLÉLOGRAMME :
- Pivot B (biellette) : trou traversant M3 (3.2 mm) dans la paroi
- Position pivot B : 30 mm AU-DESSUS de l'axe MG996R (entraxe A-B = 30 mm)
- Pivot B aligné horizontalement avec l'axe MG996R (même plan vertical)
- Renforts autour du pivot B : bossage de 12 mm de diamètre, épaisseur 8 mm
- Le pivot B doit pouvoir accueillir une vis M3 × 25 mm + rondelle + écrou nylstop
  (la biellette tourne librement autour de cette vis)
```

#### Paramètres d'impression
- PETG, 4 murs, 50% remplissage gyroïde, 6 couches dessus/dessous
- Imprimer le L couché (base à plat sur le plateau)

---

### Pièce 2 — Bras principal (PETG)

Bras rigide reliant le palonnier MG996R au point C (pivot pince).
Le bras ne porte **que le pivot C** à son extrémité. Le pivot D (biellette) est sur la **platine CD** (pièce 2b), qui est une pièce séparée pivotant librement en C.

> **⚠️ Leçon d'implémentation** : On ne peut PAS fixer D rigidement sur le bras à 30 mm au-dessus de C dans le repère du bras. Quand le bras tourne, ce point D rigide ne reste pas aligné avec la biellette. La platine CD doit être une pièce séparée qui pivote en C et que la biellette maintient verticale.

```
Vue de côté :

    Pivot D (biellette)─── ●  ← trou M3 (biellette s'attache ici)
                           │
                  30 mm    │  (entraxe C-D = entraxe A-B = 30 mm)
                           │
    Pivot C (bras)──────── ●━━━━━━━━━━━━━━━━● Axe MG996R (pivot A)
                           ┃     Bras        ┃
                           ┃   100 mm        ┃
                      Pince/SG90 ici

Vue de dessus :
    ┌────────────────────────────────────────────┐
    │ ○ Fixation      Profil renforcé      ○     │ ← pivot C (palonnier)
    │   pince                              MG996R│
    │ ○ Fixation                                 │ ← pivot D (biellette)
    │   biellette                                │
    └────────────────────────────────────────────┘
    ◄──────────────── 100 mm ────────────────────►

Vue de coupe (section transversale) :
    ┌──────────┐
    │██████████│  ← paroi supérieure 2.5 mm
    │██      ██│  ← parois latérales 2.5 mm
    │██      ██│     évidement intérieur (passage câbles SG90 + biellette)
    │██████████│  ← paroi inférieure 2.5 mm
    └──────────┘
    ◄── 15 ──►
       mm
    Hauteur section : 12 mm
```

#### Cotes
```
- Longueur totale : 100 mm (ajustable, plus court = plus résistant)
- Section extérieure : 15 × 12 mm (largeur × hauteur)
- Épaisseur parois : 2.5 mm
- Canal intérieur : 10 × 7 mm (passage câble SG90)
- Extrémité côté épaule (pivot A/C) :
  - Trou central : 5.8 mm (axe servo) + méplat pour vis palonnier
  - Fixation palonnier MG996R : vis M3 traversante
  - Renfort : épaississement à 20 × 15 mm sur 15 mm de long
- Extrémité côté pince (pivots C/D) :
  - Platine élargie : 25 × 40 mm (pour accueillir les 2 pivots)
  - Pivot C (bas, fixation pince) :
    - Plateforme pour visser le logement SG90
    - 2 trous M2 (2.2 mm), entraxe 27.5 mm (oreilles SG90)
    - Le SG90 est monté axe vers le bas
  - Pivot D (haut, fixation biellette) :
    - Trou traversant M3 (3.2 mm)
    - À 30 mm AU-DESSUS du pivot C (même entraxe que A-B sur le support)
    - Bossage renforcé 12 mm diamètre autour du trou
  - Entraxe C-D = 30 mm (CRITIQUE : doit être identique à A-B)
- Nervure de renfort longitudinale en dessous (2 mm × 2 mm en triangle)
```

#### Paramètres d'impression
- PETG, 4 murs, 60% remplissage gyroïde, 6 couches dessus/dessous
- Imprimer à plat (longueur sur le plateau, section en hauteur)
- Orientation : les couches perpendiculaires à la longueur pour résistance en flexion

---

### Pièce 2b — Platine CD (PETG) — AJOUT

Barre verticale libre en rotation au point C (sur le bras), maintenue verticale par la biellette.
C'est cette pièce qui porte la pince et qui reste horizontale grâce au parallélogramme.

```
Vue de côté :

    ○ Pivot D (M3, fixation biellette)
    │            ← patte latérale vers biellette (offset Y)
    │ Platine
    │ verticale
    │ 30 mm
    │
    ○ Pivot C (M3, liaison bras + fixation pince)
    │
    ┌─┴─┐
    │SG90│  ← la pince est fixée sous C
    └────┘
```

#### Cotes
```
- Hauteur : 30 mm (entraxe C-D, CRITIQUE = identique à A-B)
- Largeur : 20 mm
- Épaisseur : 5 mm
- Pivot C (bas) : trou M3 (3.2 mm), traverse en X → liaison avec le bras
- Pivot D (haut) : trou M3 (3.2 mm), traverse en Y → liaison avec la biellette
- Patte D : fourche (2 flasques) encadrant la biellette, offset Y = 14 mm
- Sous C : plateforme de fixation pince (2 × M2, entraxe 27.5 mm)
```

#### Paramètres d'impression
- PETG, 4 murs, 60% remplissage
- Imprimer à plat

---

### Pièce 3 — Corps de pince (PETG)

Mécanisme de pince à engrenage actionné par le SG90.

```
Vue de face (pince ouverte) :

    ╭──────╮              ╭──────╮
    │Doigt │              │Doigt │
    │gauche│              │ droit│
    │      │              │      │
    ╰──┬───╯              ╰───┬──╯
       │    ┌──────────┐      │
       ╰────┤ Engrenage├──────╯
            │  + SG90  │
            └──────────┘

Vue de face (pince fermée) :

         ╭──────╮╭──────╮
         │Doigt ││Doigt │
         │gauche││ droit│
         │      ││      │
         ╰──┬───╯╰───┬──╯
            │ ┌────┐  │
            ╰─┤Gear├──╯
              │SG90│
              └────┘
```

#### Mécanisme

> **⚠️ Règle de coplanarité** : L'axe de rotation du SG90 et les axes pivots des doigts
> doivent être **parallèles** (dans le même plan). Sinon le palonnier tourne dans un plan
> incompatible avec l'ouverture des doigts et le mécanisme ne fonctionne pas.

```
Option A — Engrenages involute (recommandé, cf. tallerinventores) :
  - SG90 axe en Z, pignon sur l'axe
  - 2 mâchoires avec secteur denté, pivots en Z
  - Le pignon entraîne les 2 mâchoires en sens inverse
  - Tout dans le plan XY → coplanaire ✓

Option B — Bielles (plus simple mais moins fiable) :
  - SG90 axe en Z, palonnier dans le plan XY
  - 2 doigts pivotant en Z (pas en X !)
  - Palonnier → 2 biellettes → bras interne de chaque doigt
  - Tout dans le plan XY → coplanaire ✓

Option C (NE MARCHE PAS) :
  - SG90 axe en Z + doigts pivotant en X
  - Le palonnier tourne en XY, les doigts s'ouvrent en YZ
  - Plans perpendiculaires → mécanisme impossible ✗

- Ouverture max : 50 mm entre les doigts (assez pour une balle de tennis)
- Ouverture min : 0 mm (doigts se touchent)
- Course SG90 utilisée : ~60° (de 60° à 120°)
```

#### Cotes corps
```
- Largeur : 55 mm
- Profondeur : 25 mm
- Hauteur (sans doigts) : 30 mm
- Logement SG90 intégré : 23 × 12.5 × 27 mm (avec jeu 0.3 mm)
- Fixation sur le bras : 2 × M2 + plateforme d'appui
- Axes pivots doigts : 2 × trou 3.2 mm (vis M3)
```

#### Paramètres d'impression
- PETG, 4 murs, 40% remplissage, 6 couches dessus/dessous
- L'engrenage/pignon : 100% remplissage
- Supports nécessaires pour le logement SG90

---

### Pièce 4 — Doigts de pince (PETG + TPU)

2 doigts symétriques (miroir l'un de l'autre).

```
Vue de profil d'un doigt :

    ┌───────────┐
    │           │ ← embout TPU (grip)
    │  PETG     ├─┐
    │           │T│
    │           │P│
    │           │U│
    └────┬──────┘ │
         │        │
    Pivot (M3)    │
                  └─ surface de contact rainurée
```

#### Cotes doigt
```
- Longueur : 50 mm
- Largeur : 12 mm
- Épaisseur : 5 mm
- Trou pivot : 3.2 mm (M3) à 8 mm du bas
- Trou biellette : 2.2 mm (M2) à 15 mm du bas
- Embout TPU : zone de contact 15 × 12 × 3 mm
  - Fixation : emboîtement en queue d'aronde ou trou + clip
  - Surface : rainures 1 mm pour meilleur grip
```

#### Paramètres d'impression
- Doigts PETG : 4 murs, 50% remplissage
- Embouts TPU : 3 murs, 30% remplissage, shore 95A recommandé

---

### Pièce 5 — Butées fin de course (TPU)

2 petits tampons amortisseurs.

```
- Dimensions : 10 × 8 × 3 mm
- Shore 85A-95A
- Collés ou emboîtés sur le support épaule
- Position : là où le bras arrive en butée haute et basse
```

---

### Pièce 6 — Silent blocks (TPU)

4 rondelles pour isoler le support épaule des vibrations.

```
- Diamètre extérieur : 10 mm
- Diamètre intérieur : 3.2 mm (passage vis M3)
- Épaisseur : 2 mm
- Shore 85A-95A
- Placées entre la base du support et le châssis alu
```

---

### Pièce 7 — Biellette parallélogramme (PETG)

Barre rigide reliant le pivot B (support) au pivot D (bout du bras).
C'est cette pièce qui maintient la pince horizontale.

```
Vue de côté :

    ○ Pivot D (bout du bras)
    ┃
    ┃  Biellette
    ┃  (barre simple)
    ┃
    ○ Pivot B (support épaule)

Vue de face :
    ┌───────────────────────────────────────┐
    │  ○                              ○    │
    │  Pivot B                    Pivot D   │
    └───────────────────────────────────────┘
    ◄────────────── 100 mm ────────────────►
```

#### RÈGLE CRITIQUE DU PARALLÉLOGRAMME
```
La biellette DOIT avoir exactement la même longueur (entraxe trou à trou)
que le bras principal (entraxe pivot A à pivot C).

  Longueur biellette (B→D) = Longueur bras (A→C) = 100 mm

Et l'entraxe sur le support (A→B) doit être identique à l'entraxe
sur la platine bout de bras (C→D) = 30 mm

Si ces 2 conditions sont respectées, ABCD est un parallélogramme
et la pince reste horizontale automatiquement.
```

#### Cotes
```
- Longueur entraxe trous : 100 mm (IDENTIQUE au bras principal)
- Section : 12 × 8 mm (rectangulaire plein, pas besoin de canal câble)
- Épaisseur : 8 mm
- Trous aux extrémités : 3.2 mm (M3), avec bossage renforcé 14 mm
- Chanfreins 1 mm sur les arêtes longitudinales (confort visuel)
```

#### Paramètres d'impression
- PETG, 4 murs, 60% remplissage gyroïde
- Imprimer à plat (longueur sur le plateau)
- Pièce simple et rapide (~30 min)

---

## 4. Assemblage

### Ordre de montage
```
1. Insérer les silent blocks TPU dans les trous de la base du support
2. Visser le support épaule sur le châssis alu (4 × M3)
3. Glisser le MG996R dans le logement, fixer les oreilles (2 × M3)
4. Fixer le palonnier MG996R sur le bras principal (vis centrale M3)
5. Installer la vis pivot B sur le support :
   → Fourche (2 flasques) à Y=14mm, vis M3 × 25 + rondelles + nylstop
   → La biellette passera ENTRE les 2 flasques
6. Assembler la pince : SG90 dans le corps, doigts sur les pivots (axes Z !)
7. Clipser les embouts TPU sur les doigts
8. Monter la platine CD sur le bras au pivot C (vis M3)
   → La platine doit pivoter librement autour de C
9. Visser la pince sous la platine CD (2 × M2)
10. Accrocher la biellette :
   - Extrémité basse → fourche pivot B sur le support (vis M3 déjà en place)
   - Extrémité haute → fourche pivot D sur la platine CD (vis M3 × 25 + nylstop)
11. Coller les butées TPU sur le support
12. Passer le câble SG90 dans le canal du bras
13. VÉRIFIER : bouger le bras à la main, la pince doit rester horizontale
    à toutes les positions. Si elle penche, vérifier les entraxes.
    La platine CD doit rester verticale à tous les angles.
```

### Détail des pivots B et D (fourches)
```
Les pivots B (support) et D (platine CD) utilisent des FOURCHES :
deux flasques de part et d'autre de la biellette.

    Flasque ─┐   ┌─ Biellette ─┐   ┌─ Flasque
              │   │    (12mm)   │   │
              │   │             │   │
     ─────── ○───┼─────────────┼───○ ───────
              vis M3 traverse tout

La vis M3 × 25 traverse : flasque → rondelle → biellette → rondelle → flasque → nylstop
La biellette tourne librement sur la vis.
```

### Visserie nécessaire
```
- 4 × vis M3 × 10 mm (support châssis)
- 2 × vis M3 × 10 mm (oreilles MG996R)
- 1 × vis M3 × 8 mm (palonnier MG996R sur bras)
- 1 × vis M3 × 12 mm (pivot C : bras ↔ platine CD)
- 2 × vis M3 × 16 mm + écrous nylstop (pivots doigts pince)
- 2 × vis M3 × 25 mm + 4 rondelles + 2 écrous nylstop
    (pivots biellette : B sur support, D sur platine CD)
    (chaque vis traverse : flasque → rondelle → biellette → rondelle → flasque → nylstop)
- 2 × vis M2 × 10 mm (fixation pince sur platine CD)
- 2 × vis M2 × 8 mm (oreilles SG90, ou vis fournies)
```

---

## 5. Vérifications avant impression

- [ ] Le logement MG996R a 0.3 mm de jeu de chaque côté
- [ ] Le logement SG90 a 0.3 mm de jeu de chaque côté
- [ ] Le canal câble du bras est assez large (10 × 7 mm min)
- [ ] Les trous de vis sont au bon diamètre (3.2 pour M3, 2.2 pour M2)
- [ ] La hauteur du support épaule dégage le bras du châssis en position basse
- [ ] L'ouverture max de la pince est suffisante (~50 mm)
- [ ] Le bras ne touche pas le boîtier 18650 en position basse
- [ ] Le poids total du bras + pince + biellette < 100g (capacité MG996R OK)

### Vérifications parallélogramme (CRITIQUES)
- [ ] Entraxe A-B (support) = entraxe C-D (platine CD) = 30 mm exactement
- [ ] Longueur bras (A→C) = longueur biellette (B→D) = 100 mm exactement
- [ ] La platine CD pivote librement en C sur le bras (vis M3 pas trop serrée)
- [ ] La platine CD reste verticale à tous les angles (vérifier avec la biellette)
- [ ] Le pivot B a assez de dégagement (fourche) pour la biellette
- [ ] Le pivot D a assez de dégagement (fourche) pour la biellette
- [ ] La biellette est décalée en Y (offset ~14 mm) pour ne pas toucher le bras
- [ ] Les pivots B et D tournent librement (vis M3 + rondelles + nylstop)

### Vérifications mécanisme pince
- [ ] L'axe SG90 et les pivots doigts sont PARALLÈLES (tous en Z, ou tous en X)
- [ ] Le palonnier tourne dans le MÊME PLAN que l'ouverture des doigts
- [ ] Le corps pince a une zone ouverte pour le palonnier et les biellettes
- [ ] Les biellettes de commande ne collisionnent pas avec le corps

---

## 6. Notes OpenSCAD

### Bonnes pratiques
```openscad
$fn = 50;  // résolution cylindres (augmenter pour export final)
tolerance = 0.3;  // jeu d'assemblage

// Paramètres principaux du parallélogramme (CRITIQUES)
longueur_bras = 100;       // mm — longueur bras ET biellette (identiques !)
entraxe_pivots = 30;       // mm — entraxe A-B ET C-D (identiques !)
ouverture_pince = 50;      // mm — ouverture max de la pince

// Système de coordonnées assemblage :
//   Origine = pivot A (axe MG996R)
//   X = avant (direction du bras)
//   Y = latéral (axe servo)
//   Z = haut

// Modules pièces (9 pièces, export STL individuel) :
// support_epaule()         — U-bracket + fourche pivot B à Y=14
// bras()                   — tube A→C, trou axe servo à X=0
// platine_cd()             — barre verticale C→D, fourche pivot D
// biellette()              — barre simple B→D, même longueur que bras
// corps_pince()            — boîtier SG90 + zone ouverte mécanisme
// doigt(mirror=false)      — pivot axe Z + bras interne pour palonnier
// embout_tpu()             — grip souple pour bout des doigts
// butee_tpu()              — amortisseur fin de course
// silent_block()           — rondelle anti-vibration

// Modules visualisation (pas d'export) :
// mg996r()                 — fantôme servo épaule
// sg90()                   — fantôme servo pince

// Assemblage :
// assemblage_complet(angle_epaule=45, angle_pince=25)
//
// Parallélogramme dans l'assemblage :
//   A = [0, 0, 0]                       (fixe, axe MG996R)
//   B = [0, 14, H_pivot]                (fixe, fourche sur support)
//   Bras : rotate([0, -angle, 0]) de A vers C
//   C = [L*cos(a), 0, L*sin(a)]         (bout du bras)
//   Platine CD : à C, reste VERTICALE (pièce séparée)
//   D = [C.x, 14, C.z + H_pivot]        (haut de la platine)
//   Biellette : translate(B) rotate([0, -angle, 0]) de B vers D
//
// ⚠️  La platine CD ne tourne PAS avec le bras.
//     C'est la biellette qui la maintient verticale.
```

### Validation du parallélogramme dans OpenSCAD
```openscad
// Pour vérifier visuellement que le parallélogramme fonctionne,
// créer une animation avec angle_epaule qui varie :
//
// angle = 45 + 90 * $t;  // $t va de 0 à 1 dans l'animation OpenSCAD
//
// Points du parallélogramme :
// A = [0, 0]                                    (axe MG996R, fixe)
// B = [0, entraxe_pivots]                       (pivot biellette, fixe)
// C = A + longueur_bras * [cos(angle), sin(angle)]   (bout du bras)
// D = C + [0, entraxe_pivots]                   (bout biellette)
//
// Vérifier que D == B + longueur_bras * [cos(angle), sin(angle)]
// Si oui, le parallélogramme est correct.
```

### Export
- Exporter chaque pièce en STL séparé (8 fichiers)
- Le module assemblage_complet sert à visualiser, pas à imprimer
- Prévoir `longueur_bras` et `entraxe_pivots` comme paramètres ajustables
- Prévoir `ouverture_pince` ajustable (défaut 50 mm)
- Imprimer 2 exemplaires de chaque pièce (2 voitures)

---

## 7. Références OpenSCAD — Servos et bras robotiques

### Modèles servo MG996R

| Projet | Description | URL |
|--------|-------------|-----|
| collinalexbell/chiron | Modèle paramétrique complet avec corps, oreilles, 4 trous, palonnier | https://github.com/collinalexbell/chiron/blob/main/hardware/actuators/servo-mg996r/servo-mg996r.scad |
| joeiddon/chess_robot | Modèle propre : corps 40.3×20×37, oreilles, axe décalé | https://github.com/joeiddon/chess_robot/blob/master/model/scads/mg996r.scad |
| mcampo/lazy-tv | Origine au centre de l'axe, corps 40.5×20×39.3 | https://github.com/mcampo/lazy-tv/blob/master/servo.scad |
| imageguy/projects | Modèle détaillé avec moyeu cannelé | https://github.com/imageguy/projects/blob/main/dust/model/plib/MG996R_servo.scad |

### Modèles servo SG90

| Projet | Description | URL |
|--------|-------------|-----|
| openscad/MCAD (officiel) | `towerprosg90()` — référence officielle, LGPL 2.1 | https://github.com/openscad/MCAD/blob/master/servos.scad |
| ledalert/cadmodel-sg90 | Modèle détaillé avec moyeu décentré, trous keyhole, fasteners | https://github.com/ledalert/cadmodel-sg90/blob/master/sg90.scad |
| kartchnb/openscad-servo-library | Bibliothèque paramétrique data-driven, cotes mesurées sur pièces réelles | https://github.com/kartchnb/openscad-servo-library |
| tallerinventores/educational-robot-arm | `servo9g()` complet avec câbles, moyeu, palonnier | https://github.com/tallerinventores/educational-robot-arm-with-6DOF/blob/master/src/educational-robot-arm-with-6DOF.scad |

### Supports / brackets servo MG996R

| Projet | Description | URL |
|--------|-------------|-----|
| Haus1775/kinetic-sand-table | U-bracket compact, servo par le haut, passage câbles | https://github.com/Haus1775/kinetic-sand-table/blob/main/cad/servo-mount.scad |
| maniginam/foldit | Berceau 4 parois, fentes oreilles, trous traversants | https://github.com/maniginam/foldit/blob/main/hardware_files/servo_mount.scad |
| Abinand2631/robotic-finger-design | Bracket épaule avec adaptateur PVC, modules séparés | https://github.com/Abinand2631/robotic-finger-design/blob/main/scad_designs/joints/shoulder_joint_bracket.scad |

### Pinces / grippers SG90

| Projet | Description | URL |
|--------|-------------|-----|
| gordon-krefting/robots | **Gripper complet** avec engrenages, biellettes, animation `$t` | https://github.com/gordon-krefting/robots/blob/master/gripper/scad/gripper.scad |
| tallerinventores/educational-robot-arm | **Mâchoires à engrenages involute**, surfaces dentelées, SG90 | https://github.com/tallerinventores/educational-robot-arm-with-6DOF/blob/master/src/educational-robot-arm-with-6DOF.scad |
| ledalert/cadmodel-sg90 | Fasteners/clips de montage SG90 | https://github.com/ledalert/cadmodel-sg90 |

### Bras robotiques complets en OpenSCAD

| Projet | Description | URL |
|--------|-------------|-----|
| tallerinventores/educational-robot-arm-with-6DOF | **Bras 6 axes complet**, gripper à engrenages, GPLv3 | https://github.com/tallerinventores/educational-robot-arm-with-6DOF |
| collinalexbell/chiron | Robot avec MG996R, structure complète | https://github.com/collinalexbell/chiron |
| Abinand2631/robotic-finger-design | Design doigt robotique avec articulations | https://github.com/Abinand2631/robotic-finger-design |

### Thingiverse (STL + parfois SCAD)

| Nom | Description | URL |
|-----|-------------|-----|
| MG996R Servo Model (PagliaIndustries) | Modèle 3D MG996R | https://www.thingiverse.com/thing:4894842 |
| Simple Servo Motor - Parametric (JB86) | Servo paramétrique | https://www.thingiverse.com/thing:6173969 |
| Microservo SG90 - openscad (pols66) | SG90 en OpenSCAD | https://www.thingiverse.com/thing:2250808 |
