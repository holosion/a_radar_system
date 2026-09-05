import processing.serial.*;

Serial arduino;

// ===============================
// SERIAL SETTINGS
// ===============================

final int BAUD_RATE = 9600;

// Arduino is COM4
final int ARDUINO_PORT = 1;


// ===============================
// RADAR SETTINGS
// ===============================

float angle = 90;
float distance = 999;

final float MAX_DISTANCE = 200;

float centerX;
float centerY;
float radarRadius;


// ===============================
// SETUP
// ===============================

void setup() {

  size(1000, 700);

  centerX = width / 2;
  centerY = height - 80;

  radarRadius = 560;

  println("Available Serial Ports:");

  for (int i = 0; i < Serial.list().length; i++) {
    println(i + ": " + Serial.list()[i]);
  }

  // Connect to Arduino COM4
  arduino = new Serial(
    this,
    Serial.list()[ARDUINO_PORT],
    BAUD_RATE
  );

  arduino.clear();

  // Read data line by line
  arduino.bufferUntil('\n');

  smooth();
}


// ===============================
// MAIN LOOP
// ===============================

void draw() {

  background(0);

  drawTitle();

  drawRadar();

  drawScanner();

  drawTarget();

  drawStatus();

  drawData();
}


// ===============================
// TITLE
// ===============================

void drawTitle() {

  fill(0, 255, 0);

  textAlign(CENTER);

  textSize(30);

  text(
    "ARDUINO RADAR SECURITY SYSTEM",
    width / 2,
    40
  );

  textAlign(LEFT);
}


// ===============================
// RADAR
// ===============================

void drawRadar() {

  stroke(0, 180, 0);
  strokeWeight(2);

  noFill();


  // Main radar arcs

  arc(
    centerX,
    centerY,
    radarRadius * 2,
    radarRadius * 2,
    PI,
    TWO_PI
  );

  arc(
    centerX,
    centerY,
    radarRadius * 1.5,
    radarRadius * 1.5,
    PI,
    TWO_PI
  );

  arc(
    centerX,
    centerY,
    radarRadius,
    radarRadius,
    PI,
    TWO_PI
  );

  arc(
    centerX,
    centerY,
    radarRadius * 0.5,
    radarRadius * 0.5,
    PI,
    TWO_PI
  );


  // Horizontal base

  line(
    centerX - radarRadius,
    centerY,
    centerX + radarRadius,
    centerY
  );


  // Radar angle lines

  drawRadarLine(0);
  drawRadarLine(30);
  drawRadarLine(60);
  drawRadarLine(90);
  drawRadarLine(120);
  drawRadarLine(150);
  drawRadarLine(180);


  // Distance labels

  fill(0, 255, 0);

  textSize(15);

  text(
    "50 cm",
    centerX + 10,
    centerY - radarRadius * 0.25
  );

  text(
    "100 cm",
    centerX + 10,
    centerY - radarRadius * 0.50
  );

  text(
    "150 cm",
    centerX + 10,
    centerY - radarRadius * 0.75
  );

  text(
    "200 cm",
    centerX + 10,
    centerY - radarRadius
  );


  // Angle labels

  text("180°",
       centerX - radarRadius - 40,
       centerY + 25);

  text("150°",
       centerX - radarRadius * 0.87,
       centerY - radarRadius * 0.50);

  text("120°",
       centerX - radarRadius * 0.52,
       centerY - radarRadius * 0.87);

  text("90°",
       centerX - 15,
       centerY - radarRadius - 10);

  text("60°",
       centerX + radarRadius * 0.48,
       centerY - radarRadius * 0.87);

  text("30°",
       centerX + radarRadius * 0.84,
       centerY - radarRadius * 0.50);

  text("0°",
       centerX + radarRadius + 10,
       centerY + 25);
}


// ===============================
// RADAR LINES
// ===============================

void drawRadarLine(float degrees) {

  float a = radians(degrees);

  float x =
    centerX + cos(a) * radarRadius;

  float y =
    centerY - sin(a) * radarRadius;

  line(
    centerX,
    centerY,
    x,
    y
  );
}


// ===============================
// SCANNING LINE
// ===============================

void drawScanner() {

  float a = radians(angle);

  float x =
    centerX + cos(a) * radarRadius;

  float y =
    centerY - sin(a) * radarRadius;


  // Scanner beam

  stroke(0, 255, 0);

  strokeWeight(4);

  line(
    centerX,
    centerY,
    x,
    y
  );


  // Center

  fill(0, 255, 0);

  noStroke();

  ellipse(
    centerX,
    centerY,
    14,
    14
  );
}


// ===============================
// DETECTED OBJECT
// ===============================

void drawTarget() {

  if (distance <= 0 || distance > MAX_DISTANCE) {
    return;
  }


  // Convert distance to radar radius

  float r = map(
    distance,
    0,
    MAX_DISTANCE,
    0,
    radarRadius
  );


  float a = radians(angle);


  float x =
    centerX + cos(a) * r;

  float y =
    centerY - sin(a) * r;


  // ===============================
  // TARGET COLOR
  // ===============================

  if (distance <= 40) {

    // DANGER

    fill(255, 0, 0);

    stroke(255, 0, 0);

  }
  else if (distance <= 100) {

    // WARNING

    fill(255, 255, 0);

    stroke(255, 255, 0);

  }
  else {

    // SAFE

    fill(0, 255, 0);

    stroke(0, 255, 0);
  }


  strokeWeight(3);


  // Target

  ellipse(
    x,
    y,
    20,
    20
  );


  // Target ring

  noFill();

  ellipse(
    x,
    y,
    40,
    40
  );


  // Distance

  fill(255);

  textSize(14);

  text(
    int(distance) + " cm",
    x + 15,
    y
  );
}


// ===============================
// STATUS
// ===============================

void drawStatus() {

  textSize(22);


  if (distance <= 40) {

    fill(255, 0, 0);

    text(
      "⚠ INTRUDER DETECTED",
      30,
      80
    );

  }
  else if (distance <= 100) {

    fill(255, 255, 0);

    text(
      "⚠ WARNING",
      30,
      80
    );

  }
  else {

    fill(0, 255, 0);

    text(
      "✓ AREA CLEAR",
      30,
      80
    );
  }
}


// ===============================
// DATA DISPLAY
// ===============================

void drawData() {

  fill(0, 255, 0);

  textSize(18);

  text(
    "ANGLE: " + int(angle) + "°",
    30,
    height - 45
  );

  text(
    "DISTANCE: " + int(distance) + " cm",
    220,
    height - 45
  );

  text(
    "MAX RANGE: " + int(MAX_DISTANCE) + " cm",
    450,
    height - 45
  );
}


// ===============================
// RECEIVE ARDUINO DATA
// ===============================

void serialEvent(Serial port) {

  String data = port.readStringUntil('\n');


  if (data == null) {
    return;
  }


  data = trim(data);


  // Arduino sends:
  //
  // angle,distance
  //
  // Example:
  //
  // 45,73

  String[] values =
    split(data, ',');


  if (values.length == 2) {

    try {

      float newAngle =
        float(trim(values[0]));

      float newDistance =
        float(trim(values[1]));


      // Check angle

      if (newAngle >= 0 &&
          newAngle <= 180) {

        angle = newAngle;
      }


      // Check distance

      if (newDistance >= 0 &&
          newDistance <= 400) {

        distance = newDistance;
      }


      // Print received data

      println(
        "Angle: " +
        int(angle) +
        " | Distance: " +
        int(distance) +
        " cm"
      );

    }

    catch(Exception e) {

      println(
        "Invalid data: " + data
      );
    }
  }
}
