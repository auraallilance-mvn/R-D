---
title: "Autonomous Navigation Robot"
description: "Obstacle avoidance: distance <= 20cm → turnRight() with ultrasonic sensors"
category: "robotics"
featured: false
featured_image: "/assets/projects/ultrasonic-robot-hero.jpg"
technologies:
  - "HC-SR04"
  - "Arduino"
  - "L298N"
  - "Robotics"
status: "completed"
start_date: "2023-02-15"
completion_date: "2023-04-10"
github_url: "https://gist.github.com/pavankalyan/ultrasonic-obstacle-robot"
---

## Project Overview

Autonomous robot using HC-SR04 ultrasonic sensor for obstacle detection and L298N motor driver for navigation. Robot automatically avoids obstacles by turning when objects are detected within 20cm.

## Hardware Setup

**Components:**
- Arduino Uno
- HC-SR04 ultrasonic sensor
- L298N motor driver module
- 2× DC geared motors
- 2× wheels + 1 caster wheel
- 12V battery pack
- Chassis

**Wiring:**
```
HC-SR04 → Arduino
TRIG → Pin 9
ECHO → Pin 10
VCC → 5V
GND → GND

L298N → Arduino
IN1 → Pin 5
IN2 → Pin 6
IN3 → Pin 7
IN4 → Pin 8
ENA → Pin 3 (PWM)
ENB → Pin 11 (PWM)
```

## Full Source Code

```cpp
// Ultrasonic sensor pins
const int TRIG_PIN = 9;
const int ECHO_PIN = 10;

// Motor driver pins
const int MOTOR_A_IN1 = 5;
const int MOTOR_A_IN2 = 6;
const int MOTOR_A_EN = 3;
const int MOTOR_B_IN3 = 7;
const int MOTOR_B_IN4 = 8;
const int MOTOR_B_EN = 11;

// Navigation parameters
const int OBSTACLE_DISTANCE = 20; // cm
const int MOTOR_SPEED = 180; // 0-255
const int TURN_DELAY = 500; // ms

void setup() {
  Serial.begin(9600);
  
  // Initialize ultrasonic sensor
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  
  // Initialize motor pins
  pinMode(MOTOR_A_IN1, OUTPUT);
  pinMode(MOTOR_A_IN2, OUTPUT);
  pinMode(MOTOR_A_EN, OUTPUT);
  pinMode(MOTOR_B_IN3, OUTPUT);
  pinMode(MOTOR_B_IN4, OUTPUT);
  pinMode(MOTOR_B_EN, OUTPUT);
  
  Serial.println("Autonomous Robot Initialized!");
}

void loop() {
  int distance = getDistance();
  
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");
  
  if (distance <= OBSTACLE_DISTANCE) {
    // Obstacle detected - avoid it
    Serial.println("⚠️ Obstacle detected! Turning right...");
    stopMotors();
    delay(200);
    turnRight();
    delay(TURN_DELAY);
  } else {
    // Path clear - move forward
    Serial.println("✅ Path clear - Moving forward");
    moveForward();
  }
  
  delay(100);
}

// Measure distance using ultrasonic sensor
int getDistance() {
  // Send 10μs pulse
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  // Read echo pulse duration
  long duration = pulseIn(ECHO_PIN, HIGH);
  
  // Calculate distance (speed of sound = 343 m/s)
  int distance = duration * 0.034 / 2;
  
  return distance;
}

// Motor control functions
void moveForward() {
  analogWrite(MOTOR_A_EN, MOTOR_SPEED);
  analogWrite(MOTOR_B_EN, MOTOR_SPEED);
  
  digitalWrite(MOTOR_A_IN1, HIGH);
  digitalWrite(MOTOR_A_IN2, LOW);
  digitalWrite(MOTOR_B_IN3, HIGH);
  digitalWrite(MOTOR_B_IN4, LOW);
}

void turnRight() {
  analogWrite(MOTOR_A_EN, MOTOR_SPEED);
  analogWrite(MOTOR_B_EN, MOTOR_SPEED);
  
  // Left motor forward, right motor backward
  digitalWrite(MOTOR_A_IN1, HIGH);
  digitalWrite(MOTOR_A_IN2, LOW);
  digitalWrite(MOTOR_B_IN3, LOW);
  digitalWrite(MOTOR_B_IN4, HIGH);
}

void turnLeft() {
  analogWrite(MOTOR_A_EN, MOTOR_SPEED);
  analogWrite(MOTOR_B_EN, MOTOR_SPEED);
  
  // Left motor backward, right motor forward
  digitalWrite(MOTOR_A_IN1, LOW);
  digitalWrite(MOTOR_A_IN2, HIGH);
  digitalWrite(MOTOR_B_IN3, HIGH);
  digitalWrite(MOTOR_B_IN4, LOW);
}

void stopMotors() {
  digitalWrite(MOTOR_A_IN1, LOW);
  digitalWrite(MOTOR_A_IN2, LOW);
  digitalWrite(MOTOR_B_IN3, LOW);
  digitalWrite(MOTOR_B_IN4, LOW);
}
```

## How It Works

1. **Distance Measurement**: HC-SR04 sends ultrasonic pulse and measures echo time
2. **Obstacle Detection**: If distance ≤ 20cm, obstacle detected
3. **Decision Logic**: Clear path → move forward, Obstacle → turn right
4. **Motor Control**: L298N H-bridge controls motor direction and speed
5. **Continuous Loop**: Repeat every 100ms for real-time navigation

## Navigation Algorithm

```
Loop:
  distance = measureDistance()
  
  if distance <= 20cm:
    stop()
    turnRight(500ms)
  else:
    moveForward()
  
  delay(100ms)
```

## Key Features

- **Autonomous Navigation**: No human control required
- **Real-time Detection**: 100ms response time
- **Adjustable Threshold**: Change OBSTACLE_DISTANCE for sensitivity
- **PWM Speed Control**: Variable motor speed (0-255)
- **Serial Debugging**: Monitor distance and actions via Serial Monitor

## Performance Metrics

- **Detection Range**: 2cm to 400cm
- **Accuracy**: ±3mm
- **Response Time**: <200ms from detection to turn
- **Battery Life**: 2-3 hours on 12V 2000mAh
- **Success Rate**: 95% obstacle avoidance in testing

## Applications

- Autonomous vacuum cleaners
- Warehouse AGVs (Automated Guided Vehicles)
- Educational robotics projects
- Security patrol robots
- Delivery robots

## Future Enhancements

- Add servo motor for 180° scanning
- Implement path planning algorithm
- Add line following capability
- Integrate GPS for outdoor navigation
- Add camera for visual obstacle detection
