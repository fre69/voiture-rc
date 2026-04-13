# Robot Mecanum ESP32

Robot 4 roues Mecanum pilote par manette Xbox Series via Bluetooth, avec bras robotique 2 axes.

## Hardware

- ESP32-WROOM-32 DevKitC
- OPEN-SMART Quad Motor Driver (HR8833 x2)
- 4x moteurs TT DC + roues Mecanum 60mm
- Bras : MG996R (epaule) + SG90 (pince)
- 4x HC-SR04 ultrason (avant/arriere/gauche/droite)
- 4x capteurs IR via PCF8574 I2C (diagonales)
- Alimentation : 2x 18650 en serie (7.4V)

## Fonctionnalites

- Deplacement omnidirectionnel (avancer, strafe, pivot)
- Anti-collision 360 degres (ultrason + IR)
- Bras robotique : epaule haut/bas + pince ouvrir/fermer
- Mode turbo (L3)
- Failsafe : arret moteurs si manette deconnectee

## Controles manette Xbox

| Controle | Action |
|----------|--------|
| Stick gauche | Avancer/reculer + strafe |
| LB / RB | Pivot gauche / droite |
| Stick droit Y | Epaule haut/bas |
| LT / RT | Pince ouvrir / fermer |
| L3 (click) | Toggle turbo |
| Y | Home bras |

## Build

### PlatformIO (recommande)

```bash
pio run -t upload
pio device monitor
```

### Arduino IDE

1. Ajouter le Board Manager URL Bluepad32 :
   `https://raw.githubusercontent.com/ricardoquesada/esp32-arduino-lib-builder/master/bluepad32_files/package_esp32_bluepad32_index.json`
2. Selectionner : **Bluepad32 > ESP32 Dev Module**
3. Installer la librairie **ESP32Servo**
4. Compiler et telecharger

## Commandes Serial (debug)

| Commande | Effet |
|----------|-------|
| `T` | Test moteurs (2s avant + 2s arriere chacun) |
| `S` | Affiche distances ultrason + etat capteurs IR |

## Documentation

Voir [ROBOT_MECANUM_ESP32_SPEC.md](ROBOT_MECANUM_ESP32_SPEC.md) pour la documentation technique complete (pinout, cablage, cinematique, calibration).
