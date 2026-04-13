# Robot Mecanum ESP32 — Documentation Technique Complète

## 1. Vue d'ensemble du projet

Robot 4 roues Mecanum piloté par manette Xbox Series via Bluetooth, avec bras robotique 2 axes (épaule + pince). Firmware ESP32 Arduino.

### Fonctionnalités cibles
- Pilotage omnidirectionnel (avancer/reculer, strafe latéral, rotation sur place)
- Bras robotique : épaule haut/bas (MG996R) + pince ouvrir/fermer (SG90)
- Détection d'obstacles (HC-SR04)
- Mode turbo (vitesse max augmentée)
- Failsafe : arrêt moteurs si manette déconnectée

---

## 2. Hardware

### 2.1 Microcontrôleur
- **ESP32-WROOM-32 DevKitC** (4 Mo flash)
- Bluetooth Classic supporté (nécessaire pour Bluepad32 + Xbox)
- Framework : Arduino (PlatformIO ou Arduino IDE)

### 2.2 Quad Motor Driver — OPEN-SMART (HR8833 ×2)
- Carte : OPEN-SMART Quad Motor Driver
- Chips : 2× HR8833 (dual H-bridge chacun = 4 canaux moteur)
- Alimentation moteur : 5-12V (alimenté en 7.4V depuis 2S 18650)
- Courant max : 1.5A RMS par canal
- **Contrôle : PWM direct** (pas I2C)
- Chaque moteur est contrôlé par 2 pins : IN1 et IN2
  - IN1=HIGH + IN2=LOW → marche avant
  - IN1=LOW + IN2=HIGH → marche arrière
  - IN1=LOW + IN2=LOW → roue libre (coast)
  - IN1=HIGH + IN2=HIGH → frein (brake)
- Pour le contrôle de vitesse : PWM sur IN1 (analogWrite), IN2 en digital
  - Marche avant : analogWrite(IN1, speed), digitalWrite(IN2, LOW)
  - Marche arrière : analogWrite(IN1, 255-speed), digitalWrite(IN2, HIGH)

### 2.3 Moteurs et roues
- 4× moteurs TT DC avec réducteur (probablement 1:48)
- 4× roues Mecanum ~60mm
- Vitesse typique : ~200 RPM à 6V, ~2-3 km/h
- Courant nominal : ~200-250 mA par moteur

### 2.4 Disposition des roues Mecanum (vue de dessus)

```
AVANT (HC-SR04)
┌─────────────────────┐
│  FL(A)       FR(B)  │    FL = Front Left  = Motor A
│   ╲           ╱     │    FR = Front Right = Motor B
│                     │    RL = Rear Left   = Motor C
│   ╱           ╲     │    RR = Rear Right  = Motor D
│  RL(C)       RR(D)  │
└─────────────────────┘
ARRIÈRE
```

### 2.5 Cinématique Mecanum

Le mixage des 3 axes (avancer, strafe, rotation) vers les 4 roues :

```
FL = avancer + strafe + rotation
FR = avancer - strafe - rotation
RL = avancer - strafe + rotation
RR = avancer + strafe - rotation
```

Où :
- `avancer` = [-255, +255] (négatif = reculer)
- `strafe`  = [-255, +255] (négatif = gauche, positif = droite)
- `rotation`= [-255, +255] (négatif = gauche, positif = droite)

Le résultat pour chaque moteur doit être **clampé** à [-255, +255] puis appliqué :
- Valeur positive → marche avant
- Valeur négative → marche arrière (inverser et utiliser la valeur absolue)

### 2.6 Servomoteurs (bras robotique)
- **Épaule** : MG996R (couple ~10 kg·cm, 4.8-6V)
  - Plage PWM : 500-2400 µs (vérifier avec servo réel)
  - Plage angulaire utile : ~45° (bas) à ~135° (haut), 90° = horizontal
- **Pince** : SG90 (couple ~1.8 kg·cm, 4.8-6V)
  - Plage PWM : 500-2400 µs
  - 0° = fermé, 90° = ouvert (ajuster selon montage réel)
- Contrôle : PWM direct depuis ESP32 (librairie ESP32Servo)

### 2.7 Capteurs ultrason HC-SR04 (×4)
- **4 capteurs** positionnés : avant, arrière, gauche, droite
- Portée : 2 cm à 400 cm
- Trigger : pulse HIGH de 10 µs → Echo : durée proportionnelle à la distance
- Distance (cm) = durée (µs) / 58
- **Optimisation GPIO** : les 4 triggers sont câblés ensemble sur 1 seul GPIO (pulse simultané), les 4 echos sur 4 GPIO séparés. Les capteurs ne s'interfèrent pas car ils pointent dans des directions différentes.
- Lecture séquentielle (pas simultanée) pour éviter les échos croisés : lire un echo à la fois avec timeout

### 2.8 Capteurs infrarouges (×4) via PCF8574 (I2C)
- **4 capteurs IR** positionnés en **diagonale** : avant-gauche, avant-droit, arrière-gauche, arrière-droit
- Connectés sur un **PCF8574** (expandeur I/O 8 bits sur I2C)
- Adresse I2C par défaut : 0x20 (vérifier, configurable via A0/A1/A2)
- Lecture digitale : 0 = obstacle détecté, 1 = pas d'obstacle (ou l'inverse selon le modèle)
- Portée typique : 2-30 cm (détection courte distance, complémentaire aux ultrason)
- 4 pins du PCF8574 utilisés (P0-P3), 4 pins libres (P4-P7) pour extensions futures

### Vue de dessus — couverture capteurs 360°
```
              US AVANT
                 ↑
      IR ↗               ↖ IR
  US ←   ┌───────────────┐   → US
  GAUCHE │     ROBOT      │  DROITE
         └───────────────┘
      IR ↙               ↘ IR
                 ↓
             US ARRIÈRE
```
Les ultrason (US) couvrent les 4 axes cardinaux (longue portée ~4m).
Les infrarouges (IR) couvrent les 4 diagonales (courte portée ~30cm).

### 2.8 Manette Xbox Series (modèle 1914 "Electric Volt")
- Connexion : Bluetooth via librairie **Bluepad32**
- Protocole : BR/EDR (Bluetooth Classic) ou BLE selon firmware manette
- **Bluepad32** gère automatiquement le pairing et la lecture des données

### 2.9 Alimentation
- **Moteurs** : 2× 18650 en série (2S) = 7.4V nominal (8.4V max) → directement sur Quad Motor Driver (entrée 5-12V)
- **ESP32** : alimenté via USB (pour développement) ou Mini560 buck 7.4V→5V sur Vin (pour usage autonome)
- **Servos** : Mini560 buck 7.4V→5V séparé (pour éviter perturbations ESP32)
- **Note** : pour le développement initial, ESP32 en USB et moteurs sur batteries

---

## 3. Pinout ESP32

```
GPIO 25 → Motor A IN1 (Front Left)
GPIO 26 → Motor A IN2 (Front Left)
GPIO 27 → Motor B IN1 (Front Right)
GPIO 14 → Motor B IN2 (Front Right)
GPIO 12 → Motor C IN1 (Rear Left)
GPIO 13 → Motor C IN2 (Rear Left)
GPIO 15 → Motor D IN1 (Rear Right)
GPIO  4 → Motor D IN2 (Rear Right)

GPIO 32 → Servo Épaule (MG996R) — PWM 50Hz
GPIO 33 → Servo Pince (SG90) — PWM 50Hz

GPIO 17 → HC-SR04 Trigger PARTAGÉ (1 fil vers les 4 triggers)
GPIO 16 → HC-SR04 Echo AVANT
GPIO  2 → HC-SR04 Echo ARRIÈRE (⚠️ LED intégrée, OK en output mais vérifier)
GPIO  5 → HC-SR04 Echo GAUCHE
GPIO 18 → HC-SR04 Echo DROITE

GPIO 21 → SDA (I2C : PCF8574 capteurs IR + extensions futures)
GPIO 22 → SCL (I2C : PCF8574 capteurs IR + extensions futures)

Bluetooth → interne (pas de GPIO dédié)
```

> **Note GPIO 2** : cette pin est connectée à la LED intégrée sur certains DevKitC.
> Si ça pose problème, utiliser GPIO 19 à la place.
> 
> **Total : 17 GPIO utilisés** sur ~25 disponibles.
> GPIO libres : 19, 23, 34, 35, 36, 39 (34-39 = input only)

### GPIO à éviter sur ESP32
- GPIO 0  : boot mode (pull-up)
- GPIO 1  : TX0 (serial debug)
- GPIO 2  : boot mode / LED intégrée
- GPIO 3  : RX0 (serial debug)
- GPIO 5  : strapping pin
- GPIO 6-11 : connectés au flash SPI interne (NE PAS UTILISER)
- GPIO 34-39 : input only (pas de PWM output)

---

## 4. Mapping manette Xbox Series

### Axes analogiques (valeurs -512 à +511)

```
ctl->axisX()   = Stick gauche horizontal  → Strafe
ctl->axisY()   = Stick gauche vertical    → Avancer/Reculer (INVERSÉ: Y négatif = avant)
ctl->axisRX()  = Stick droit horizontal   → (non utilisé, libre)
ctl->axisRY()  = Stick droit vertical     → Épaule bras (haut/bas)
ctl->brake()   = Gâchette LT (0-1023)    → Pince ouvrir
ctl->throttle()= Gâchette RT (0-1023)    → Pince fermer
```

### Boutons digitaux

```
ctl->l1()      = Bumper LB               → Pivot robot gauche
ctl->r1()      = Bumper RB               → Pivot robot droite
ctl->a()       = Bouton A                → Toggle phares (futur)
ctl->b()       = Bouton B                → Klaxon/buzzer (futur)
ctl->x()       = Bouton X                → Toggle mode vitesse (normal/lent)
ctl->y()       = Bouton Y                → Home bras (position repos)
ctl->thumbL()  = Click L3                → Toggle mode turbo
ctl->thumbR()  = Click R3                → (libre)
ctl->miscButtons() & 0x02 = Share        → (libre)
```

### Logique de contrôle

```
// Axes de déplacement
avancer  = -ctl->axisY()     // Inversé car stick Y négatif = pousser vers le haut
strafe   = ctl->axisX()
rotation = 0
if (ctl->l1()) rotation = -PIVOT_SPEED  // Pivot gauche
if (ctl->r1()) rotation = +PIVOT_SPEED  // Pivot droite

// Zone morte (deadzone) : ignorer les valeurs entre -30 et +30
// Mapper les valeurs de [-512,+511] vers [-255,+255]

// Bras
epaule_target += ctl->axisRY() * SHOULDER_SPEED  // Incrémenter la position
pince_pos = map(ctl->throttle() - ctl->brake(), -1023, 1023, PINCE_MIN, PINCE_MAX)

// Mode turbo : multiplicateur de vitesse ×1.5
// HC-SR04 : si distance < 15 cm et avancer > 0, réduire/bloquer la vitesse avant
```

---

## 5. Librairies requises

### Bluepad32 (manette Xbox)
- **Installation** : Ajouter le Board Manager URL Bluepad32 dans Arduino IDE :
  `https://raw.githubusercontent.com/ricardoquesada/esp32-arduino-lib-builder/master/bluepad32_files/package_esp32_bluepad32_index.json`
- Sélectionner la board **Bluepad32 > ESP32 Dev Module** (ou DOIT ESP32 DEVKIT V1)
- **IMPORTANT** : Bluepad32 remplace le core ESP32 Arduino standard. Il ne faut PAS installer le core ESP32 normal en parallèle.
- Exemple de base : File > Examples > Bluepad32_ESP32 > Controller

### ESP32Servo
- Contrôle PWM des servos sur ESP32
- `#include <ESP32Servo.h>`
- Installation via Library Manager Arduino IDE

### Pas de librairie externe pour :
- HC-SR04 : `pulseIn()` natif suffit
- Moteurs HR8833 : `analogWrite()` / `ledcWrite()` natif ESP32

---

## 6. Architecture logicielle

```
setup()
├── BP32.setup(&onConnect, &onDisconnect)
├── Initialiser GPIO moteurs (OUTPUT)
├── Attacher servos (ESP32Servo)
├── Initialiser HC-SR04

loop()
├── BP32.update()
├── Si manette connectée :
│   ├── Lire axes + boutons
│   ├── Appliquer deadzone
│   ├── Mapper vers [-255, +255]
│   ├── Calculer mixage Mecanum (4 vitesses moteurs)
│   ├── Appliquer mode turbo si activé
│   ├── Lire HC-SR04 ×4 séquentiellement (toutes les 100ms, un capteur par cycle)
│   ├── Lire PCF8574 capteurs IR diagonales (via I2C, rapide)
│   ├── Anti-collision multi-directionnelle :
│   │   ├── Si obstacle AVANT < 15cm et avancer > 0 : bloquer avancer
│   │   ├── Si obstacle ARRIÈRE < 15cm et avancer < 0 : bloquer reculer
│   │   ├── Si obstacle GAUCHE < 15cm et strafe < 0 : bloquer strafe gauche
│   │   ├── Si obstacle DROITE < 15cm et strafe > 0 : bloquer strafe droite
│   │   └── Si IR diagonale détecte : réduire vitesse dans la direction concernée
│   ├── Clamper vitesses [-255, +255]
│   ├── Appliquer PWM aux 4 moteurs
│   ├── Calculer position épaule (incrémental depuis stick droit Y)
│   ├── Calculer position pince (gâchettes LT/RT)
│   └── Appliquer servo positions
├── Si manette déconnectée :
│   ├── Arrêter tous les moteurs (coast)
│   └── Garder servos en position actuelle
└── Delay 10-20 ms (rate limit ~50-100 Hz)
```

### Constantes à calibrer
```cpp
#define DEADZONE 30            // Zone morte sticks
#define MAX_SPEED 200          // Vitesse max normale (0-255)
#define TURBO_SPEED 255        // Vitesse max turbo
#define PIVOT_SPEED 150        // Vitesse de pivot (LB/RB)
#define SHOULDER_SPEED 0.5     // Vitesse de déplacement épaule (degrés par tick)
#define SHOULDER_MIN 45        // Angle min épaule (degrés)
#define SHOULDER_MAX 135       // Angle max épaule (degrés)
#define PINCE_OPEN 10          // Angle pince ouverte (degrés)
#define PINCE_CLOSE 90         // Angle pince fermée (degrés)
#define OBSTACLE_DISTANCE 15   // Distance obstacle ultrason (cm)
#define IR_SLOW_FACTOR 0.5     // Réduction vitesse si IR diagonale détecte
#define HC_SR04_INTERVAL 100   // Intervalle lecture cycle complet 4 ultrason (ms)
                               // = 1 capteur toutes les 25ms en round-robin
```

---

## 7. Câblage physique

### Quad Motor Driver OPEN-SMART
- **Motor Power** (bornier) : + et - des 18650 2S (7.4V)
- **Moteur A** (connecteur JST gauche haut) : moteur Front Left
- **Moteur B** (connecteur JST gauche) : moteur Front Right
- **Moteur C** (connecteur JST gauche) : moteur Rear Left
- **Moteur D** (connecteur JST gauche bas) : moteur Rear Right
- **PWMA/B/C/D** (connecteur droit) : vers GPIO ESP32 (voir pinout §3)
- **VIN/GND** (sur la carte) : alimentation logique 5V depuis Mini560 ou USB

> **IMPORTANT** : La correspondance exacte entre les connecteurs physiques
> et les moteurs A/B/C/D doit être vérifiée empiriquement.
> Si un moteur tourne dans le mauvais sens, inverser IN1/IN2 dans le code
> (pas besoin de recâbler).

### Servos
- **Fil signal (orange/blanc)** → GPIO ESP32
- **Fil +V (rouge)** → 5V depuis Mini560 dédié servos
- **Fil GND (marron/noir)** → GND commun (IMPORTANT : relier le GND du Mini560 servos au GND de l'ESP32)

### HC-SR04 (×4, trigger partagé)
- **VCC** (×4) → 5V
- **GND** (×4) → GND
- **Trig** (×4 reliés ensemble) → GPIO 17
- **Echo AVANT** → GPIO 16
- **Echo ARRIÈRE** → GPIO 2 (ou 19)
- **Echo GAUCHE** → GPIO 5
- **Echo DROITE** → GPIO 18
- ⚠️ Les Echo sortent du 5V, l'ESP32 est 3.3V tolérant sur la plupart des GPIO, mais un diviseur de tension 5V→3.3V est recommandé

### PCF8574 (capteurs IR diagonales)
- **VCC** → 3.3V ou 5V
- **GND** → GND
- **SDA** → GPIO 21
- **SCL** → GPIO 22
- **A0/A1/A2** → GND (adresse 0x20) ou selon configuration
- **P0** → IR capteur avant-gauche
- **P1** → IR capteur avant-droit
- **P2** → IR capteur arrière-gauche
- **P3** → IR capteur arrière-droit
- **P4-P7** → libres (extensions futures)

---

## 8. Notes de développement

### Priorités d'implémentation
1. **Phase 1** : Connexion Bluepad32 + manette Xbox + rotation moteurs de base
2. **Phase 2** : Mixage Mecanum complet (avancer, strafe, pivot)
3. **Phase 3** : Servos bras (épaule + pince)
4. **Phase 4** : HC-SR04 anti-collision
5. **Phase 5** : Modes (turbo, vitesse), calibration, polish

### Pièges connus
- **Bluepad32 board** : il faut sélectionner la board Bluepad32, pas la board ESP32 standard. Sinon le Bluetooth ne marchera pas.
- **PWM ESP32** : Arduino `analogWrite()` n'existe pas nativement sur ESP32 avant Arduino core 3.x. Utiliser `ledcWrite()` ou le core Bluepad32 qui le supporte.
- **Sens des moteurs** : les roues Mecanum ont un sens d'installation (les rouleaux forment un X vu de dessus). Si un mouvement ne marche pas correctement, vérifier le sens de rotation de chaque moteur individuellement.
- **Stick Y inversé** : sur les manettes Xbox, pousser le stick vers le haut donne une valeur Y **négative**. Il faut inverser.
- **Servos et boot** : les servos peuvent faire un mouvement brusque au démarrage de l'ESP32. Initialiser les servos à leur position neutre dans setup() avant d'attacher.

### Test individuel moteurs (à faire en premier)
Tester chaque moteur séparément pour :
1. Vérifier qu'il tourne (câblage OK)
2. Vérifier le sens (marche avant = robot avance)
3. Ajuster dans le code si un moteur est inversé

```cpp
// Test rapide : faire tourner chaque moteur 2 secondes avant, 2 secondes arrière
void testMotor(int pin1, int pin2) {
  analogWrite(pin1, 150); digitalWrite(pin2, LOW);  // avant
  delay(2000);
  analogWrite(pin1, 255-150); digitalWrite(pin2, HIGH);  // arrière
  delay(2000);
  analogWrite(pin1, 0); digitalWrite(pin2, LOW);  // stop
}
```

---

## 9. Évolutions futures (hors scope initial)

- **Mode autonome** : navigation automatique avec évitement d'obstacles 360° (ultrason + IR). Tous les capteurs sont déjà en place ! Le robot explore en évitant les murs/meubles. Commutable via bouton Xbox (ex: bouton Share).
- **ESP32-CAM** : module caméra séparé, streaming WiFi vers smartphone
- **LEDs WS2812B** : phares et éclairage ambiance (1 GPIO, librairie FastLED)
- **Buzzer** : klaxon (1 GPIO)
- **FlySky FS-i6X + IA6B** : télécommande RC longue portée (iBus sur UART)
- **WiFi** : contrôle secondaire depuis smartphone (WebSocket server sur ESP32)
- **PCA9685** : si besoin de plus de servos (tourelle caméra pan/tilt, bras 4+ axes)
- **OV7670** : capteur caméra brut en stock, mais nécessite trop de GPIO — préférer ESP32-CAM

---

## 10. Liste d'achats

### À commander (budget ~5€)
| Composant | Qté | Prix estimé | Note |
|-----------|-----|-------------|------|
| BMS 2S 20A | 2 | ~4-5€ | Protection batteries 18650. Chercher "BMS 2S 7.4V 20A balance" sur AliExpress |

### Déjà en stock
| Composant | Qté | Status |
|-----------|-----|--------|
| ESP32-WROOM-32 DevKitC | 1 | ✅ |
| Manette Xbox Series | 1 | ✅ |
| OPEN-SMART Quad Motor Driver | 1 | ✅ |
| Châssis alu + 4 moteurs TT Mecanum | 1 | ✅ |
| HC-SR04 | 4 (avant/arrière/gauche/droite) | ✅ |
| PCF8574 + capteurs IR | 1 + 4 (diagonales) | ✅ |
| Servos MG996R | 4 (2 utilisés par voiture) | ✅ |
| Servos SG90 | 6 (2 utilisés par voiture) | ✅ |
| Accus 18650 | 8 | ✅ |
| Boîtier 2× 18650 avec interrupteur | 1 | ✅ |
| Mini560 buck DC-DC 5V | 2 | ✅ |
| PCA9685 16ch PWM (futur) | 1 | ✅ |
| OV7670 caméra (non utilisé) | 1 | ✅ |
| Elegoo Neptune 4 Plus (imprimante 3D) | 1 | ✅ |
