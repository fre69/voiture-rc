// ============================================================
// Robot Mecanum ESP32 — Firmware
// Phases 1-5 : Xbox + Mecanum + Bras + Ultrason + IR
// ============================================================

#include <Arduino.h>
#include <Bluepad32.h>
#include <ESP32Servo.h>
#include <Wire.h>

// ======================== PINS ========================
// Moteurs (OPEN-SMART Quad Driver / HR8833 x2)
#define FL_IN1 25   // Front Left  — Motor A
#define FL_IN2 26
#define FR_IN1 27   // Front Right — Motor B
#define FR_IN2 14
#define RL_IN1 12   // Rear Left   — Motor C
#define RL_IN2 13
#define RR_IN1 15   // Rear Right  — Motor D
#define RR_IN2  4

// Servos bras robotique
#define PIN_SHOULDER 32  // MG996R epaule
#define PIN_GRIPPER  33  // SG90 pince

// HC-SR04 ultrason (trigger partage, 4 echos)
#define US_TRIGGER   17  // Trigger commun aux 4 capteurs
#define US_ECHO_FWD  16  // Echo avant
#define US_ECHO_REAR  2  // Echo arriere (LED integree, OK en input)
#define US_ECHO_LEFT  5  // Echo gauche
#define US_ECHO_RIGHT 18 // Echo droite

// PCF8574 capteurs IR (I2C)
#define PCF8574_ADDR 0x20  // Adresse I2C (A0=A1=A2=GND)
#define IR_FL_BIT    0     // P0 = IR avant-gauche
#define IR_FR_BIT    1     // P1 = IR avant-droit
#define IR_RL_BIT    2     // P2 = IR arriere-gauche
#define IR_RR_BIT    3     // P3 = IR arriere-droit

// ======================== CONSTANTES ========================
// A calibrer selon le robot reel
#define DEADZONE        30      // Zone morte sticks (sur [-512,+511])
#define MAX_SPEED       200     // Vitesse max normale (0-255)
#define TURBO_SPEED     255     // Vitesse max turbo
#define PIVOT_SPEED     150     // Vitesse rotation LB/RB

#define SHOULDER_MIN    45      // Angle min epaule (degres)
#define SHOULDER_MAX    135     // Angle max epaule (degres)
#define SHOULDER_HOME   90      // Position repos epaule
#define SHOULDER_DEG_S  45.0f   // Vitesse epaule (degres/seconde a plein stick)

#define GRIPPER_OPEN    10      // Angle pince ouverte (degres)
#define GRIPPER_CLOSE   90      // Angle pince fermee (degres)
#define GRIPPER_HOME    45      // Position repos pince

#define OBSTACLE_DIST_CM  15     // Seuil obstacle ultrason (cm)
#define US_TIMEOUT_US     25000  // Timeout echo ultrason (us) ~4.3m max
#define US_INTERVAL_MS    25     // Intervalle entre chaque capteur US (ms)
#define IR_SLOW_FACTOR    0.5f   // Reduction vitesse si IR diagonale detecte

#define CONTROLLER_TIMEOUT_MS 5000  // Failsafe si manette muette (ms)

// ======================== GLOBALS ========================
ControllerPtr myControllers[BP32_MAX_GAMEPADS];
Servo shoulderServo;
Servo gripperServo;

float shoulderAngle = SHOULDER_HOME;
bool turboMode = false;
bool prevL3 = false;              // Anti-rebond toggle turbo
unsigned long lastDataTime = 0;   // Derniere reception manette
unsigned long lastLoopTime = 0;   // Pour delta-time epaule

// Capteurs ultrason — distances en cm (999 = pas d'obstacle)
float usDist[4] = {999, 999, 999, 999};  // [AVANT, ARRIERE, GAUCHE, DROITE]
const int usEchoPins[4] = {US_ECHO_FWD, US_ECHO_REAR, US_ECHO_LEFT, US_ECHO_RIGHT};
const char* usNames[4] = {"AVT", "ARR", "GAU", "DRT"};
int usCurrentSensor = 0;                  // Round-robin index
unsigned long usLastRead = 0;             // Dernier pulse ultrason

// Capteurs IR — etat brut du PCF8574
uint8_t irState = 0xFF;  // 0xFF = aucun obstacle (bits actifs = pas d'obstacle)

// ======================== MOTOR CONTROL ========================

// Pilote un moteur HR8833 : speed dans [-255, +255]
//   > 0 = marche avant (PWM sur IN1, IN2 LOW)
//   < 0 = marche arriere (PWM inverse sur IN1, IN2 HIGH)
//   = 0 = roue libre (coast)
void setMotor(int pin1, int pin2, int speed) {
    speed = constrain(speed, -255, 255);
    if (speed > 0) {
        analogWrite(pin1, speed);
        digitalWrite(pin2, LOW);
    } else if (speed < 0) {
        analogWrite(pin1, 255 + speed);
        digitalWrite(pin2, HIGH);
    } else {
        analogWrite(pin1, 0);
        digitalWrite(pin2, LOW);
    }
}

void stopAllMotors() {
    setMotor(FL_IN1, FL_IN2, 0);
    setMotor(FR_IN1, FR_IN2, 0);
    setMotor(RL_IN1, RL_IN2, 0);
    setMotor(RR_IN1, RR_IN2, 0);
}

// ======================== MECANUM MIXING ========================
// FL = fwd + strafe + rot
// FR = fwd - strafe - rot
// RL = fwd - strafe + rot
// RR = fwd + strafe - rot
void mecanumDrive(int fwd, int strafe, int rot) {
    int fl = fwd + strafe + rot;
    int fr = fwd - strafe - rot;
    int rl = fwd - strafe + rot;
    int rr = fwd + strafe - rot;

    // Normaliser si un moteur depasse 255 (garder les proportions)
    int maxVal = max(max(abs(fl), abs(fr)), max(abs(rl), abs(rr)));
    if (maxVal > 255) {
        fl = fl * 255 / maxVal;
        fr = fr * 255 / maxVal;
        rl = rl * 255 / maxVal;
        rr = rr * 255 / maxVal;
    }

    setMotor(FL_IN1, FL_IN2, fl);
    setMotor(FR_IN1, FR_IN2, fr);
    setMotor(RL_IN1, RL_IN2, rl);
    setMotor(RR_IN1, RR_IN2, rr);
}

// ======================== INPUT HELPERS ========================

int applyDeadzone(int value) {
    return (abs(value) < DEADZONE) ? 0 : value;
}

// Mappe [-512, +511] vers [-255, +255]
int mapAxis(int value) {
    return map(constrain(value, -512, 511), -512, 511, -255, 255);
}

// ======================== HC-SR04 ULTRASON ========================

// Lit UN capteur ultrason (round-robin). Appeler toutes les ~25ms.
void updateUltrasonic() {
    unsigned long now = millis();
    if (now - usLastRead < US_INTERVAL_MS) return;
    usLastRead = now;

    // Pulse trigger (commun aux 4 capteurs)
    digitalWrite(US_TRIGGER, LOW);
    delayMicroseconds(2);
    digitalWrite(US_TRIGGER, HIGH);
    delayMicroseconds(10);
    digitalWrite(US_TRIGGER, LOW);

    // Lire l'echo du capteur courant
    long duration = pulseIn(usEchoPins[usCurrentSensor], HIGH, US_TIMEOUT_US);

    if (duration > 0) {
        usDist[usCurrentSensor] = duration / 58.0f;
    } else {
        usDist[usCurrentSensor] = 999;  // Pas d'echo = pas d'obstacle
    }

    // Round-robin : capteur suivant
    usCurrentSensor = (usCurrentSensor + 1) % 4;
}

// ======================== CAPTEURS IR (PCF8574) ========================

// Lit les 4 capteurs IR via I2C. Rapide (~0.5ms).
void updateIR() {
    Wire.requestFrom((uint8_t)PCF8574_ADDR, (uint8_t)1);
    if (Wire.available()) {
        irState = Wire.read();
    }
}

// Retourne true si le capteur IR detecte un obstacle (bit a 0 = obstacle)
bool irDetected(int bit) {
    return !(irState & (1 << bit));
}

// ======================== BLUEPAD32 CALLBACKS ========================

void onConnectedController(ControllerPtr ctl) {
    for (int i = 0; i < BP32_MAX_GAMEPADS; i++) {
        if (myControllers[i] == nullptr) {
            myControllers[i] = ctl;
            Serial.printf("Manette connectee [%d]\n", i);
            return;
        }
    }
    Serial.println("Manette ignoree : pas de slot libre");
}

void onDisconnectedController(ControllerPtr ctl) {
    for (int i = 0; i < BP32_MAX_GAMEPADS; i++) {
        if (myControllers[i] == ctl) {
            myControllers[i] = nullptr;
            Serial.printf("Manette deconnectee [%d]\n", i);
            break;
        }
    }
    stopAllMotors();
}

// ======================== PROCESS GAMEPAD ========================

void processGamepad(ControllerPtr ctl) {
    if (!ctl->isConnected() || !ctl->hasData()) return;
    lastDataTime = millis();

    // --- Delta time pour mouvement epaule independant du framerate ---
    unsigned long now = millis();
    float dt = (now - lastLoopTime) / 1000.0f;
    lastLoopTime = now;
    if (dt > 0.1f) dt = 0.1f;  // Clamper si grosse pause

    // ---- DEPLACEMENT ----
    int fwd    = mapAxis(applyDeadzone(-ctl->axisY()));  // Y inverse
    int strafe = mapAxis(applyDeadzone(ctl->axisX()));

    int rot = 0;
    if (ctl->l1()) rot = -PIVOT_SPEED;  // Pivot gauche
    if (ctl->r1()) rot = +PIVOT_SPEED;  // Pivot droite

    // Appliquer limite de vitesse
    int maxSpd = turboMode ? TURBO_SPEED : MAX_SPEED;
    fwd    = fwd    * maxSpd / 255;
    strafe = strafe * maxSpd / 255;

    // ---- ANTI-COLLISION ULTRASON (axes cardinaux) ----
    if (usDist[0] < OBSTACLE_DIST_CM && fwd > 0)      fwd = 0;     // Avant
    if (usDist[1] < OBSTACLE_DIST_CM && fwd < 0)      fwd = 0;     // Arriere
    if (usDist[2] < OBSTACLE_DIST_CM && strafe < 0)    strafe = 0;  // Gauche
    if (usDist[3] < OBSTACLE_DIST_CM && strafe > 0)    strafe = 0;  // Droite

    // ---- ANTI-COLLISION IR (diagonales) ----
    bool irFL = irDetected(IR_FL_BIT);
    bool irFR = irDetected(IR_FR_BIT);
    bool irRL = irDetected(IR_RL_BIT);
    bool irRR = irDetected(IR_RR_BIT);

    if (irFL && fwd > 0)    fwd    = (int)(fwd * IR_SLOW_FACTOR);
    if (irFL && strafe < 0) strafe = (int)(strafe * IR_SLOW_FACTOR);
    if (irFR && fwd > 0)    fwd    = (int)(fwd * IR_SLOW_FACTOR);
    if (irFR && strafe > 0) strafe = (int)(strafe * IR_SLOW_FACTOR);
    if (irRL && fwd < 0)    fwd    = (int)(fwd * IR_SLOW_FACTOR);
    if (irRL && strafe < 0) strafe = (int)(strafe * IR_SLOW_FACTOR);
    if (irRR && fwd < 0)    fwd    = (int)(fwd * IR_SLOW_FACTOR);
    if (irRR && strafe > 0) strafe = (int)(strafe * IR_SLOW_FACTOR);

    mecanumDrive(fwd, strafe, rot);

    // ---- TOGGLE TURBO (L3) ----
    bool l3 = ctl->thumbL();
    if (l3 && !prevL3) {
        turboMode = !turboMode;
        Serial.printf("Turbo: %s\n", turboMode ? "ON" : "OFF");
    }
    prevL3 = l3;

    // ---- EPAULE (stick droit Y) ----
    int shoulderInput = applyDeadzone(ctl->axisRY());
    if (shoulderInput != 0) {
        shoulderAngle -= (shoulderInput / 512.0f) * SHOULDER_DEG_S * dt;
        shoulderAngle = constrain(shoulderAngle, (float)SHOULDER_MIN, (float)SHOULDER_MAX);
    }

    if (ctl->y()) {
        shoulderAngle = SHOULDER_HOME;
    }
    shoulderServo.write((int)shoulderAngle);

    // ---- PINCE (gachettes LT/RT) ----
    int gripperInput = ctl->throttle() - ctl->brake();
    int gripperAngle = map(gripperInput, -1023, 1023, GRIPPER_OPEN, GRIPPER_CLOSE);
    gripperServo.write(gripperAngle);
}

// ======================== TEST MOTEURS ========================

void testMotor(const char* name, int pin1, int pin2) {
    Serial.printf("  Test %s : avant...", name);
    setMotor(pin1, pin2, 150);
    delay(2000);
    Serial.print(" arriere...");
    setMotor(pin1, pin2, -150);
    delay(2000);
    setMotor(pin1, pin2, 0);
    Serial.println(" OK");
}

void runMotorTest() {
    Serial.println("=== TEST MOTEURS ===");
    testMotor("FL (Motor A)", FL_IN1, FL_IN2);
    testMotor("FR (Motor B)", FR_IN1, FR_IN2);
    testMotor("RL (Motor C)", RL_IN1, RL_IN2);
    testMotor("RR (Motor D)", RR_IN1, RR_IN2);
    Serial.println("=== FIN TEST ===");
    Serial.println("Si un moteur tourne dans le mauvais sens,");
    Serial.println("inverser IN1/IN2 dans les #define.");
}

// ======================== SETUP ========================

void setup() {
    Serial.begin(115200);
    Serial.println();
    Serial.println("================================");
    Serial.println(" Robot Mecanum ESP32");
    Serial.println(" Phases 1-5 : Complet");
    Serial.println("================================");

    // GPIO moteurs en sortie
    const int motorPins[] = {FL_IN1, FL_IN2, FR_IN1, FR_IN2,
                             RL_IN1, RL_IN2, RR_IN1, RR_IN2};
    for (int pin : motorPins) {
        pinMode(pin, OUTPUT);
        digitalWrite(pin, LOW);
    }

    // Servos — position home AVANT attach pour eviter mouvement brusque
    shoulderServo.attach(PIN_SHOULDER, 500, 2400);
    gripperServo.attach(PIN_GRIPPER, 500, 2400);
    shoulderServo.write(SHOULDER_HOME);
    gripperServo.write(GRIPPER_HOME);

    // HC-SR04
    pinMode(US_TRIGGER, OUTPUT);
    digitalWrite(US_TRIGGER, LOW);
    for (int pin : usEchoPins) {
        pinMode(pin, INPUT);
    }

    // I2C pour PCF8574 (capteurs IR)
    Wire.begin(21, 22);  // SDA=21, SCL=22

    // Bluepad32
    BP32.setup(&onConnectedController, &onDisconnectedController);
    BP32.forgetBluetoothKeys();  // Pairing frais a chaque boot (retirer apres dev)

    lastLoopTime = millis();
    lastDataTime = millis();

    Serial.println();
    Serial.println("Pret ! En attente de la manette Xbox...");
    Serial.println("Envoyer 'T' pour tester moteurs, 'S' pour lire capteurs.");
}

// ======================== LOOP ========================

void loop() {
    // Commandes serie
    if (Serial.available()) {
        char c = Serial.read();
        if (c == 'T' || c == 't') {
            runMotorTest();
        } else if (c == 'S' || c == 's') {
            Serial.println("=== CAPTEURS ===");
            Serial.printf("  US: AVT=%.0fcm  ARR=%.0fcm  GAU=%.0fcm  DRT=%.0fcm\n",
                          usDist[0], usDist[1], usDist[2], usDist[3]);
            Serial.printf("  IR: FL=%d  FR=%d  RL=%d  RR=%d  (1=obstacle)\n",
                          irDetected(IR_FL_BIT), irDetected(IR_FR_BIT),
                          irDetected(IR_RL_BIT), irDetected(IR_RR_BIT));
        }
    }

    // Mise a jour capteurs (non bloquant, round-robin)
    updateUltrasonic();
    updateIR();

    // Mise a jour Bluepad32
    bool dataUpdated = BP32.update();
    if (dataUpdated) {
        for (auto ctl : myControllers) {
            if (ctl && ctl->isConnected()) {
                processGamepad(ctl);
            }
        }
    }

    // Failsafe : si aucune donnee manette depuis CONTROLLER_TIMEOUT_MS
    if (millis() - lastDataTime > CONTROLLER_TIMEOUT_MS) {
        stopAllMotors();
    }

    vTaskDelay(1);  // Laisser le scheduler FreeRTOS respirer
}
