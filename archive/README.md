# Archive — pièces obsolètes

Ce dossier contient les itérations abandonnées du bras robotique.
**Ne pas réutiliser** : ces fichiers sont conservés uniquement pour historique.

## Contenu

| Fichier | Date | Pourquoi abandonné |
|---|---|---|
| `bras_robotique_v1.scad` | 2026-04-14 | Première ébauche, géométrie incorrecte |
| `bras_robotique_v2.scad` | 2026-04-15 | Corrections partielles, collisions non résolues |
| `bras_robotique_v3.scad` | 2026-04-24 | **Impression échouée** — 4 bugs bloquants : (1) arbre MG996R modélisé centré alors qu'il est excentré, (2) passage axe sur support_epaule = trou rond bloquant l'insertion des oreilles par le haut, (3) plateforme pince (24 mm) trop large pour la fourche du bras (21.6 mm), (4) platine_cd ne s'emboîte pas dans pince_corps |
| `BRAS_ROBOTIQUE_SPEC_v1to3.md` | 2026-04-15 | Spec des versions DIY abandonnées |

## Nouvelle approche (v4)

Remplacé par un design open-source éprouvé : **EEZYbotARM MK2** (auteur daGHIZmo, licence CC BY-NC).
Voir `/BRAS_ROBOTIQUE_SPEC.md` à la racine et `/bras_v4_eezybot/`.
