# Bras Robotique — Spec v4 (EEZYbotARM MK2 adapté)

**Statut** : 📋 Spec définitive, v4 EEZYbotARM MK2. En attente visserie M4 + téléchargement STL par l'utilisateur.
**Dernière mise à jour** : 2026-04-24
**Design de base** : [EEZYbotARM MK2](https://www.thingiverse.com/thing:1454048) par daGHIZmo (CC BY-NC 4.0)

---

## 1. Décision et historique

### Pourquoi EEZYbotARM MK2 (et pas un design maison)
Les versions v1, v2, v3 (fichiers `.scad` créés maison) ont toutes échoué à l'impression — voir `archive/README.md` pour les détails. Après trois itérations, la décision a été prise de repartir d'un **design open-source éprouvé** :
- Des milliers d'impressions réussies à travers le monde
- Tolérances validées, dimensions réelles du MG996R prises en compte (arbre excentré, oreilles, etc.)
- Documentation d'assemblage complète (Instructables, vidéos YouTube)
- Licence CC BY-NC compatible avec projet perso

### Pourquoi MK2 et pas MK1 / MK3
- MK1 trop petit, charge utile insuffisante
- MK3 utilise NEMA 17 (steppers) → trop complexe pour ce projet
- MK2 = sweet spot : 2 MG996R + 1 SG90 + 1 servo rotation, charge ~100 g, reach ~225 mm

### Adaptations pour voiture Mecanum
| Aspect | EEZYbotARM MK2 standard | Notre version |
|---|---|---|
| Servos MG996R | 3 (base rotation + épaule + parallélogramme) | **2** (épaule + parallélogramme) |
| Rotation de base | Oui, via servo + couronne dentée + 25 billes | **Non** — la voiture Mecanum pivote |
| Roulement 606ZZ | Requis | **Pas besoin** |
| 25 billes Ø6 | Requis | **Pas besoin** |
| Vis M6 | Requis (axe rotation base) | **Pas besoin** |
| Fixation au sol | Vis à travers la base | **Plaque d'adaptation custom** pour châssis alu Mecanum |

---

## 2. Topologie cinématique

```
        [Pince SG90]
            |
     Avant-bras (Horizontal_Arm)
       /              \
     /  biellette     |   parallélogramme assure
   /   (passive)      |   orientation pince constante
  |                   |
  Bras vertical    Triangle (Vertical_Arm)
       |                |
    MG996R #1         MG996R #2
   (épaule)        (parallélogramme)
       \             /
        [Base fixe]
             |
    [Plaque châssis]
             |
       [Voiture Mecanum]
```

**2 degrés de liberté actifs** (plan vertical) + **rotation de la voiture** pour le 3ᵉ axe → couverture 3D complète devant le robot.

### Plage de mouvement typique (EEZYbotARM MK2)
- Épaule (MG996R #1) : ~45° à 135° (vertical)
- Parallélogramme (MG996R #2) : ~0° à 90°
- Pince (SG90) : 0° fermé, ~60° ouvert
- Reach maximum : ~225 mm devant la voiture
- Charge utile recommandée : 100 g max

---

## 3. BOM — Matériel complet

### 3.1 Servomoteurs
| Composant | Qté | Rôle | Stock actuel |
|---|---|---|---|
| MG996R | 2 | Épaule + parallélogramme | ✅ en stock |
| SG90 | 1 | Pince | ✅ en stock |

### 3.2 Visserie (hors base rotative, déjà exclue)

| Référence | Qté | Rôle | Type d'achat |
|---|---|---|---|
| **M3 × 20 mm** (tête cyl.) | 2 | Fixation serre-joints pince | kit M3 |
| **M3 × 10 mm** (hex recessed) | 1 | Fixation engrenage pince | kit M3 |
| **Écrou nylstop M3** | 2 | Pince | kit M3 |
| **M4 × 20 mm** (tête cyl.) | 5 | Pivots bras | **kit M4** |
| **M4 × 30 mm** | 1 | Pivot | **kit M4** |
| **M4 × 40 mm** | 1 | Pivot | **kit M4** |
| **Tige filetée M4 × 32 mm** | 1 | Axe parallélogramme | **à acheter** |
| **Tige filetée M4 × 60 mm** | 1 | Axe principal | **à acheter** |
| **Écrou nylstop M4** | 9 | Tous pivots | **kit M4** |
| **Rondelle M4** | ~15 | Sous têtes/écrous | **kit M4** |

### 3.3 Liens AliExpress — visserie

> ⚠️ Les URLs de produits AliExpress changent régulièrement. Utiliser les **recherches** ci-dessous plutôt que des liens directs, qui peuvent être périmés.

**Option la plus économique** : un kit assortiment M4 + quelques tiges filetées.

#### Kit M4 tout-en-un (vis + écrous + rondelles)
- Recherche : [`M4 screw kit assortment nylock`](https://www.aliexpress.com/w/wholesale-M4-screw-kit-assortment-nylock.html)
- Recherche : [`M4 bolt nut washer set`](https://www.aliexpress.com/w/wholesale-M4-bolt-nut-washer-set.html)
- Prix typique : 5-10€ pour ~300 pièces toutes tailles 6-50 mm

#### Tiges filetées M4 (les 2 pièces critiques)
- Recherche : [`M4 threaded rod 60mm`](https://www.aliexpress.com/w/wholesale-M4-threaded-rod-60mm.html)
- Recherche : [`M4 threaded rod stud set`](https://www.aliexpress.com/w/wholesale-M4-threaded-rod-stud-set.html)
- Alternative simple : acheter **1 tige filetée M4 × 1 m** (~1-2€) et la couper au Dremel / scie à métaux aux longueurs voulues (32 mm + 60 mm)

#### Kit M3 (si besoin de compléter ton stock existant)
- Recherche : [`M3 screw nut washer kit`](https://www.aliexpress.com/w/wholesale-M3-screw-nut-washer-kit.html)
- Écrous nylstop M3 : [`M3 nylock nut`](https://www.aliexpress.com/w/wholesale-M3-nylock-nut.html)

**Budget total estimé** : 5-8 € en un seul kit M4 + tige filetée.

---

## 4. Fichiers STL

### 4.1 Téléchargement
Option A (avec compte Thingiverse) : https://www.thingiverse.com/thing:1454048 → `Download All Files`
Option B (sans login) : https://cults3d.com/en/3d-model/tool/eezybotarm-mk2

Extraire le zip dans `bras_v4_eezybot/stl_original/`.

### 4.2 À imprimer
Voir `bras_v4_eezybot/README.md` section "Liste STL" pour le détail.
**Résumé** : ~15 STL à imprimer, ~7 à jeter (étage rotatif supprimé).

### 4.3 Paramètres d'impression recommandés
| Paramètre | Valeur |
|---|---|
| Matière | PLA ou PETG |
| Épaisseur couche | 0.2 mm |
| Remplissage | 25-40 % |
| Parois | 3 (rigidité pivots) |
| Support | Auto (quelques pièces nécessitent un support) |
| Vitesse | 50-60 mm/s (précision des cavités servo) |
| Adhésion plateau | Brim recommandé pour les petites pièces |

Temps d'impression total estimé : **6-10 heures** (toutes pièces confondues, selon imprimante).

---

## 5. Plaque d'adaptation châssis Mecanum

### 5.1 Besoin
La base EEZYbotARM originale se fixe avec 3 vis M3 à travers sa plaque inférieure. Il faut une **plaque d'adaptation** qui :
- Se visse sur ces 3 trous M3 par-dessus
- Se fixe sur le châssis alu Mecanum par-dessous (pattern de trous à mesurer)

### 5.2 Mesures à prendre sur le châssis (à faire avant de concevoir la pièce)
1. Mesurer le **pattern de perçage du châssis** (entraxe en X et Y entre les trous d'accessoires les plus proches du centre avant)
2. Mesurer le **diamètre des trous** du châssis (typiquement M3 ou M4)
3. Mesurer l'**espace libre** devant l'électronique ESP32 / driver moteur pour caler la base du bras
4. Noter la **hauteur disponible** sous le bras (est-ce que le bras au repos rentre dans le gabarit ou dépasse-t-il en hauteur ?)

### 5.3 Conception prévue
Fichier : `bras_v4_eezybot/support_chassis.scad`
Principe :
- Plaque rectangulaire 3 mm d'épaisseur (PLA/PETG)
- 3 trous M3 alignés avec la base MK2 (entraxe à relever dans le STL `Main_Base`)
- N trous M3/M4 alignés avec le pattern châssis (à mesurer)
- Éventuellement cale de surélévation si besoin de dégager des composants

**À faire dans la prochaine session** après livraison visserie + mesures châssis.

---

## 6. Plan d'assemblage

### 6.1 Ordre recommandé
1. Imprimer toutes les pièces (§4.2)
2. Imprimer la plaque d'adaptation châssis (§5)
3. Nettoyer les pièces (bavures, support) + percer/aléser les trous si serrés
4. **Installer les servos** sur leurs logements respectifs (palonnier en position 90° avant fixation)
5. **Assembler le parallélogramme** (biellettes + triangle) — suivre l'Instructables pas à pas
6. Fixer la base sur la plaque châssis via les 3 vis M3
7. Visser la plaque châssis sur la voiture
8. Connecter les 3 signaux PWM (2× MG996R + 1× SG90) aux 3 GPIO ESP32 dédiés bras
9. Calibrer les angles (voir `ROBOT_MECANUM_ESP32_SPEC.md` §2.6 — les pulses 500-2400 µs peuvent nécessiter ajustement)

### 6.2 Références d'assemblage
- **Instructables officielle** : https://www.instructables.com/EEZYbotARM-Mk2-3D-Printed-Robot/
- **Vidéo YouTube (Chris's Basement)** : https://www.youtube.com/watch?v=R2MI-tpXyS4
- **Bibliothèque Python de contrôle (référence pour le firmware)** : https://github.com/meisben/easyEEZYbotARM

### 6.3 Points d'attention pendant l'assemblage
- **Écrous nylstop** : serrer jusqu'à blocage, puis **desserrer** jusqu'à obtenir une rotation fluide sans jeu excessif (géométrie parallélogramme sensible au jeu)
- **Palonniers MG996R** : mettre le servo au centre (angle 90°) AVANT de fixer définitivement, sinon plage de mouvement décalée
- **Sens des servos** : certains MG996R tournent à l'envers ; prévoir d'inverser la consigne dans le firmware au besoin

---

## 7. Pièces imprimées v1-v3 — à jeter ou recycler

| Pièce | Décision | Raison |
|---|---|---|
| `support_epaule` (v3) | ❌ Jeter | Géométrie non-recyclable (hypothèse arbre MG996R centré fausse) |
| `bras` (v3) | ❌ Jeter | Fourche trop étroite, pas d'adaptation possible |
| `platine_cd` (v3) | ❌ Jeter | Ne s'emboîte pas |
| `machoire_gauche` / `machoire_droite` (v3) | ❌ Jeter | Engrenages custom incompatibles avec pince MK2 |
| `biellette` (v3) | ❌ Jeter | Dimensions propres au design v3 |
| `pince_corps` (v3) | ❌ Jeter | Idem |

Matière PLA : recyclable en broyant les pièces → bobine refilament si matériel dispo. Sinon tri déchets plastiques.

---

## 8. Licence et attribution

Le design EEZYbotARM MK2 est publié sous **CC BY-NC 4.0** par son auteur daGHIZmo (Carlo Franciscone).

Ce projet respecte la licence en :
- **BY** : attribution conservée dans tous les fichiers dérivés (ce spec, README, SCAD du support custom)
- **NC** : usage strictement non-commercial (projet perso, pas de vente)

**Tout fichier dérivé** (ex: `support_chassis.scad`) doit porter la même licence CC BY-NC 4.0 et mentionner l'auteur original.

---

## 9. État courant et TODO

### ✅ Fait (2026-04-24)
- [x] Diagnostic des échecs v3 (4 bugs identifiés)
- [x] Choix du design de remplacement (EEZYbotARM MK2)
- [x] Archivage des v1/v2/v3 dans `archive/`
- [x] Création dossier `bras_v4_eezybot/` avec README
- [x] Rédaction de cette spec v4
- [x] **Téléchargement et extraction des STL officiels** (user)
- [x] **Tri des STL : 16 à imprimer dans `stl_original/print/` + 6 à ignorer dans `stl_original/skip_no_rotation/`**

### ⏳ En attente utilisateur
- [ ] Commander visserie M4 sur AliExpress (§3.3)
- [ ] **Lancer l'impression 3D des 16 STL** (voir `bras_v4_eezybot/README.md` §STL à imprimer)
- [ ] Prendre les mesures du châssis Mecanum (§5.2)

### 🔜 Prochaines étapes Claude
- [ ] Concevoir `support_chassis.scad` après mesures châssis
- [ ] Valider le câblage PWM des 3 servos (pins ESP32 — à aligner avec `ROBOT_MECANUM_ESP32_SPEC.md`)
- [ ] Préparer fonctions firmware de calibration servo + limites angulaires

---

## 10. Ressources externes

### Design & STL
- [Thingiverse — page officielle](https://www.thingiverse.com/thing:1454048)
- [Cults3D — mirror gratuit](https://cults3d.com/en/3d-model/tool/eezybotarm-mk2)
- [MyMiniFactory](https://www.myminifactory.com/object/3d-print-eezybotarm-mk2-46620)

### Tutoriels & assemblage
- [Instructables officielle](https://www.instructables.com/EEZYbotARM-Mk2-3D-Printed-Robot/)
- [Site auteur eezyrobots.it](http://www.eezyrobots.it/eba_mk2.html)

### Code de contrôle (référence)
- [miguetecnologia/EEZYbotARM-MK2 (Arduino)](https://github.com/miguetecnologia/EEZYbotARM-MK2)
- [meisben/easyEEZYbotARM (Python + kinematics)](https://github.com/meisben/easyEEZYbotARM) — MIT license
- [justbuchanan/eezybotarm-mk2-software (Qt GUI)](https://github.com/justbuchanan/eezybotarm-mk2-software)

### Inspiration adaptation véhicule
- [Thingiverse 3686505 — Base for FPV Rover](https://www.thingiverse.com/thing:3686505) (MK2 monté sur rover, exemple)
