#include <Servo.h>

// =============================
// PIN CONNECTIONS
// =============================

const int TRIG_PIN = 7;
const int ECHO_PIN = 6;

const int BUZZER_PIN = 8;

const int GREEN_LED = 2;
const int YELLOW_LED = 3;
const int RED_LED = 4;

const int SERVO_PIN = 9;


// =============================
// SETTINGS
// =============================

const int WARNING_DISTANCE = 100;  // cm
const int DANGER_DISTANCE = 40;    // cm

Servo radarServo;


// =============================
// SETUP
// =============================

void setup() {

  // Serial communication with Processing
  Serial.begin(9600);

  // Ultrasonic sensor
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Buzzer
  pinMode(BUZZER_PIN, OUTPUT);

  // LEDs
  pinMode(GREEN_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);

  // Servo
  radarServo.attach(SERVO_PIN);

  // Initial state
  digitalWrite(GREEN_LED, HIGH);
  digitalWrite(YELLOW_LED, LOW);
  digitalWrite(RED_LED, LOW);
  digitalWrite(BUZZER_PIN, LOW);

  radarServo.write(90);

  delay(1000);
}


// =============================
// GET DISTANCE
// =============================

long getDistance() {

  // Make sure trigger is LOW
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  // Send ultrasonic pulse
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Read echo
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);

  // No object detected
  if (duration == 0) {
    return 999;
  }

  // Convert time to centimeters
  long distance = duration * 0.034 / 2;

  return distance;
}


// =============================
// SECURITY SYSTEM
// =============================

void checkSecurity(long distance) {

  // SAFE
  if (distance > WARNING_DISTANCE) {

    digitalWrite(GREEN_LED, HIGH);
    digitalWrite(YELLOW_LED, LOW);
    digitalWrite(RED_LED, LOW);

    digitalWrite(BUZZER_PIN, LOW);
  }

  // WARNING
  else if (distance > DANGER_DISTANCE) {

    digitalWrite(GREEN_LED, LOW);
    digitalWrite(YELLOW_LED, HIGH);
    digitalWrite(RED_LED, LOW);

    digitalWrite(BUZZER_PIN, LOW);
  }

  // DANGER
  else {

    digitalWrite(GREEN_LED, LOW);
    digitalWrite(YELLOW_LED, LOW);
    digitalWrite(RED_LED, HIGH);

    digitalWrite(BUZZER_PIN, HIGH);
  }
}


// =============================
// SEND RADAR DATA
// =============================

void sendRadarData(int angle, long distance) {

  // Processing expects:
  //
  // angle,distance
  //
  // Example:
  // 45,73

  Serial.print(angle);
  Serial.print(",");
  Serial.println(distance);
}


// =============================
// SCAN 0° → 180°
// =============================

void scanForward() {

  for (int angle = 0; angle <= 180; angle += 2) {

    radarServo.write(angle);

    delay(30);

    long distance = getDistance();

    checkSecurity(distance);

    sendRadarData(angle, distance);
  }
}


// =============================
// SCAN 180° → 0°
// =============================

void scanBackward() {

  for (int angle = 180; angle >= 0; angle -= 2) {

    radarServo.write(angle);

    delay(30);

    long distance = getDistance();

    checkSecurity(distance);

    sendRadarData(angle, distance);
  }
}


// =============================
// MAIN LOOP
// =============================

void loop() {

  scanForward();

  scanBackward();
}