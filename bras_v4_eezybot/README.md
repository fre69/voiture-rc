# bras_v4_eezybot — EEZYbotARM MK2 adapté voiture Mecanum

Design basé sur **EEZYbotARM MK2** par daGHIZmo (CC BY-NC 4.0).
Source officielle : https://www.thingiverse.com/thing:1454048
Site auteur : http://www.eezyrobots.it/eba_mk2.html

## Adaptations vs MK2 original

1. **Pas de rotation de base** : la voiture Mecanum pivote sur elle-même → on supprime l'étage de rotation (économie : 1× MG996R, 1× roulement 606ZZ, 25 billes Ø6, 1× M6, 6 STL)
2. **Plaque de fixation châssis** : pièce custom OpenSCAD à ajouter sous la base MK2 pour la visser au châssis alu Mecanum (à concevoir après mesures)

## Structure du dossier

```
bras_v4_eezybot/
├── README.md                  ← ce fichier
├── NOTES_ASSEMBLAGE.md        ← journal d'assemblage à remplir
├── stl_original/
│   ├── README.txt             ← README original daGHIZmo
│   ├── LICENSE.txt            ← CC BY-NC
│   ├── print/                 ← 16 STL À IMPRIMER ✅
│   ├── skip_no_rotation/      ← 6 STL à ignorer (rotation de base) ❌
│   ├── reference_cad/         ← .step / .dwg / .pdf pince (référence)
│   └── docs_images/           ← images daGHIZmo (explosions, rendus)
└── support_chassis.scad       ← à créer : plaque d'adaptation châssis
```

## À faire (ordre)

- [x] ~~Télécharger le zip STL Thingiverse~~
- [x] ~~Extraire et trier les STL (print / skip)~~
- [ ] **Imprimer les 16 STL dans `print/`** (voir tableau §STL à imprimer)
- [ ] Commander la visserie M4 (voir `../BRAS_ROBOTIQUE_SPEC.md` §BOM)
- [ ] Prendre les mesures du châssis Mecanum (voir `../BRAS_ROBOTIQUE_SPEC.md` §5.2)
- [ ] Concevoir `support_chassis.scad` en OpenSCAD (prochaine session Claude)
- [ ] Imprimer `support_chassis`
- [ ] Assembler selon https://www.instructables.com/EEZYbotARM-Mk2-3D-Printed-Robot/ **(sauter toute la partie base tournante)**

---

## STL à imprimer ✅ (dossier `stl_original/print/`)

| Fichier | Rôle | Qté | Notes d'impression |
|---|---|---|---|
| `EBAmk2_001_base.STL` | Pédestal (base fixe du bras — reçoit les 2 MG996R épaule) | 1 | Support requis sous surplombs |
| `EBAmk2_002_mainarm.STL` | Bras principal vertical (piloté par MG996R épaule) | 1 | Pièce longue, bien orienter sur plateau |
| `EBAmk2_003_varm.STL` | Bras vertical du parallélogramme (piloté par MG996R #2) | 1 | |
| `EBAmk2_004_link135.STL` | Biellette droite 135 mm | 1 | Imprimer à plat |
| `EBAmk2_005_link135angled.STL` | Biellette 135 mm coudée | 1 | Idem |
| `EBAmk2_006_horarm__.STL` | Avant-bras horizontal (base) | **Choix** | Version originale |
| `EBAmk2_006_horarm_plate.STL` | Avant-bras horizontal avec plaque de renfort | **Choix** | Version renforcée — **privilégier celle-ci** |
| `EBAmk2_007_trialink.STL` | Triangle de liaison | 1 | |
| `EBAmk2_008_link147_new.STL` | Biellette 147 mm (version mise à jour) | 1 | |
| `EBAmk2_009_trialinkfront.STL` | Triangle avant (porte la pince) | 1 | |
| `EBAmk2_014_claw_base.STL` | Corps de la pince | 1 | Reçoit le SG90 |
| `EBAmk2_015_claw_finger_dx.STL` | Doigt droit mâchoire | 1 | |
| `EBAmk2_016_claw_gear_drive.STL` | Engrenage menant (sur SG90) | 1 | Petite pièce, brim recommandé |
| `EBAmk2_017_claw_finger_sx.STL` | Doigt gauche mâchoire | 1 | |
| `EBAmk2_018_claw_gear_driven.STL` | Engrenage mené | 1 | Petite pièce, brim recommandé |
| `EBAmk2_019_drive_cover.STL` | Capot esthétique pince | 1 | **Optionnel** |

> **Choix `006_horarm__` ou `006_horarm_plate`** : imprimer en priorité la version `_plate` (renforcée). La version `__` n'est à imprimer que si la `_plate` ne convient pas à l'assemblage. Les deux sont dans `print/` pour laisser le choix.

**Total à imprimer : 14 pièces obligatoires + 1 optionnelle + 1 choix sur 2 (horarm) = ~15 prints.**

### Paramètres d'impression recommandés
| Paramètre | Valeur |
|---|---|
| Matière | PLA ou PETG |
| Épaisseur couche | 0.2 mm |
| Remplissage | 25-40 % (40 % pour le pédestal et le bras principal) |
| Parois | 3 (rigidité pivots) |
| Support | Auto (certaines pièces comme `001_base` en ont besoin) |
| Vitesse | 50-60 mm/s |
| Adhésion plateau | Brim pour petites pièces (engrenages) |

---

## STL à ignorer ❌ (dossier `stl_original/skip_no_rotation/`)

| Fichier | Rôle (dans MK2 standard) | Pourquoi zappé |
|---|---|---|
| `EBAmk2_010_gearservo.STL` | Pignon sur servo rotation | Pas de rotation |
| `EBAmk2_010_gearservo_22DENTI.STL` | Variante pignon 22 dents | Idem |
| `EBAmk2_011_gearmast.STL` | Couronne dentée de rotation | Idem |
| `EBAmk2_011_gearmast_full.STL` | Variante couronne pleine | Idem |
| `EBAmk2_012_mainbase.STL` | Plateau rotatif intermédiaire (sur billes) | Idem |
| `EBAmk2_013_lower_base.STL` | Base fixe inférieure (contient servo rotation + roulement 606ZZ) | **Remplacée par `support_chassis.scad` custom** |

Matériel également économisé : **1× MG996R, 1× roulement 606ZZ, 25× billes Ø6 mm, 1× vis M6×25, 1× écrou nylstop M6**.

---

## Fichiers de référence CAO

Le dossier `stl_original/reference_cad/` contient les sources CAO de la pince fournies par l'auteur :
- `EBAmk2_014_claw_std.step` — format STEP (importable FreeCAD, SolidWorks, Fusion 360)
- `EBAmk2_014_claw_std.dwg` — plan 2D AutoCAD
- `EBAmk2_014_claw_std.pdf` — plan 2D lisible

Utile si on doit modifier l'interface mâchoires plus tard (quick-coupler remplaçable selon l'auteur).

---

## Licence et attribution

Ce dossier d'adaptation reste sous **CC BY-NC 4.0** comme l'original.

**Attribution obligatoire** dans tout fichier dérivé :
> *"Based on EEZYbotARM MK2 by daGHIZmo — licensed CC BY-NC 4.0 — https://www.thingiverse.com/thing:1454048"*

Les fichiers `LICENSE.txt` et `README.txt` originaux sont conservés dans `stl_original/`.
