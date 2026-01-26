---
title: "Raspberry Pi GPIO LED Control"
description: "Python RPi.GPIO controlled LED pattern - Foundation of IoT"
category: "iot"
featured: false
featured_image: "/assets/projects/raspberry-pi-hero.jpg"
technologies:
  - "Raspberry Pi"
  - "Python"
  - "GPIO"
  - "Linux"
status: "completed"
start_date: "2023-05-01"
completion_date: "2023-07-15"
github_url: "https://gist.github.com/pavankalyan/raspberry-pi-gpio-led"
---

## Project Overview

Foundation project for Raspberry Pi GPIO programming using Python. Control LED blinking patterns to learn digital output, timing, and hardware interfacing basics.

## Hardware Setup

**Components:**
- Raspberry Pi (any model with GPIO)
- LED (any color)
- 330Ω resistor
- Breadboard and jumper wires

**Wiring:**
```
GPIO17 (Pin 11) → 330Ω Resistor → LED Anode (+)
LED Cathode (-) → GND (Pin 6)
```

## GPIO Pin Layout

```
Raspberry Pi GPIO Pinout (Physical Pins):
Pin 1:  3.3V
Pin 6:  GND
Pin 11: GPIO17 (BCM numbering)
```

## Full Source Code

```python
#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time

# GPIO pin configuration (BCM numbering)
LED_PIN = 17

# Setup
GPIO.setmode(GPIO.BCM)  # Use BCM pin numbering
GPIO.setup(LED_PIN, GPIO.OUT)  # Set GPIO17 as output

print("LED Blink Program Started!")
print("Press Ctrl+C to exit")

try:
    while True:
        # Turn LED ON
        GPIO.output(LED_PIN, GPIO.HIGH)
        print("LED: ON")
        time.sleep(1)  # Wait 1 second
        
        # Turn LED OFF
        GPIO.output(LED_PIN, GPIO.LOW)
        print("LED: OFF")
        time.sleep(1)  # Wait 1 second

except KeyboardInterrupt:
    print("\nProgram stopped by user")

finally:
    # Cleanup GPIO pins
    GPIO.cleanup()
    print("GPIO cleanup complete")
```

## Advanced Pattern: PWM Breathing Effect

```python
#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time

LED_PIN = 17

GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

# Create PWM object with 100Hz frequency
pwm = GPIO.PWM(LED_PIN, 100)
pwm.start(0)  # Start with 0% duty cycle

print("LED Breathing Effect")
print("Press Ctrl+C to exit")

try:
    while True:
        # Fade in (0% to 100%)
        for duty_cycle in range(0, 101, 5):
            pwm.ChangeDutyCycle(duty_cycle)
            time.sleep(0.05)
        
        # Fade out (100% to 0%)
        for duty_cycle in range(100, -1, -5):
            pwm.ChangeDutyCycle(duty_cycle)
            time.sleep(0.05)

except KeyboardInterrupt:
    print("\nProgram stopped")

finally:
    pwm.stop()
    GPIO.cleanup()
    print("GPIO cleanup complete")
```

## Multiple LED Pattern

```python
#!/usr/bin/env python3
import RPi.GPIO as GPIO
import time

# Define LED pins
LEDS = [17, 27, 22]  # GPIO17, GPIO27, GPIO22

GPIO.setmode(GPIO.BCM)

# Setup all LED pins as outputs
for led in LEDS:
    GPIO.setup(led, GPIO.OUT)
    GPIO.output(led, GPIO.LOW)

print("Knight Rider LED Pattern")

try:
    while True:
        # Forward sweep
        for led in LEDS:
            GPIO.output(led, GPIO.HIGH)
            time.sleep(0.2)
            GPIO.output(led, GPIO.LOW)
        
        # Backward sweep
        for led in reversed(LEDS):
            GPIO.output(led, GPIO.HIGH)
            time.sleep(0.2)
            GPIO.output(led, GPIO.LOW)

except KeyboardInterrupt:
    print("\nStopped")

finally:
    GPIO.cleanup()
```

## How It Works

1. **GPIO Setup**: Configure GPIO17 as digital output pin
2. **High/Low Control**: `GPIO.HIGH` = 3.3V (LED ON), `GPIO.LOW` = 0V (LED OFF)
3. **Timing**: `time.sleep()` controls blink duration
4. **PWM**: Pulse Width Modulation for brightness control
5. **Cleanup**: Always call `GPIO.cleanup()` to reset pins

## Key Concepts Learned

- **BCM vs BOARD numbering**: BCM uses GPIO numbers, BOARD uses physical pin numbers
- **Digital Output**: Binary HIGH/LOW states
- **PWM**: Analog-like control using digital pulses
- **Exception Handling**: Proper cleanup on program exit
- **Hardware Interfacing**: Current limiting with resistors

## Installation

```bash
# Update system
sudo apt update
sudo apt upgrade

# Install RPi.GPIO (usually pre-installed)
sudo apt install python3-rpi.gpio

# Run the program
python3 led_blink.py
```

## Troubleshooting

**LED doesn't light:**
- Check wiring polarity (long leg = anode/+)
- Verify resistor value (220Ω-1kΩ range)
- Test with multimeter: GPIO17 should show 3.3V when HIGH

**Permission denied:**
```bash
sudo python3 led_blink.py
# Or add user to gpio group:
sudo usermod -a -G gpio $USER
```

## Applications

- IoT device prototyping
- Home automation controllers
- Sensor indicator lights
- Status displays
- Learning embedded Linux

## Next Steps

- Add button input for interactive control
- Connect multiple sensors (DHT22, PIR, ultrasonic)
- Build web interface with Flask
- Create automated lighting system
- Integrate with MQTT for IoT communication

## Performance

- **Response Time**: <1ms GPIO switching
- **PWM Frequency**: Up to 8kHz
- **Current per Pin**: Max 16mA (use transistor for higher loads)
- **Voltage**: 3.3V logic (NOT 5V tolerant!)
