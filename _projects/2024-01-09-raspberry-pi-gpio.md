---
title: "Raspberry Pi GPIO LED Control"
date: "2024-01-09"
description: "Python RPi.GPIO controlled LED pattern - Foundation of IoT hardware interfacing"
category: "iot"
featured: false
featured_image: "/R-D/assets/projects/raspberry-pi-hero.jpg"
technologies:
  - "Raspberry Pi"
  - "Python"
  - "RPi.GPIO"
  - "LED Control"
github_url: "https://gist.github.com/pavankalyan/raspberry-pi-gpio-led"
live_demo: ""
status: "completed"
start_date: "2023-05-01"
completion_date: "2023-07-15"
---

## Project Overview

Foundation project for Raspberry Pi GPIO programming using Python. Control LED blinking patterns to learn digital output, timing, and hardware interfacing basics.

## Hardware Setup

**Components:**
- Raspberry Pi (any model with GPIO)
- LED (any color)
- 330Ω resistor
- Breadboard
- Jumper wires

**Wiring Diagram:**
```
Raspberry Pi GPIO Pinout (Physical Pins):
Pin 1:  3.3V
Pin 6:  GND
Pin 11: GPIO 17 (BCM) → LED Anode (through 330Ω resistor)

LED Connection:
GPIO 17 → 330Ω Resistor → LED Anode (+)
LED Cathode (-) → GND
```

## Complete Source Code

### Basic LED Blink

```python
#!/usr/bin/env python3
"""
Raspberry Pi GPIO LED Control
Basic LED blinking with RPi.GPIO library
"""

import RPi.GPIO as GPIO
import time

# GPIO Setup
LED_PIN = 17  # BCM pin 17 (Physical pin 11)
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

def basic_blink():
    """Basic LED blinking pattern"""
    print("Starting basic LED blink...")
    
    try:
        for i in range(20):  # Blink 20 times
            GPIO.output(LED_PIN, GPIO.HIGH)  # LED ON
            print(f"Blink {i+1}: LED ON")
            time.sleep(0.5)
            
            GPIO.output(LED_PIN, GPIO.LOW)   # LED OFF
            print(f"Blink {i+1}: LED OFF")
            time.sleep(0.5)
            
    except KeyboardInterrupt:
        print("\nProgram interrupted by user")
    finally:
        GPIO.cleanup()
        print("GPIO cleanup completed")

if __name__ == "__main__":
    basic_blink()
```

### Advanced PWM Breathing Effect

```python
#!/usr/bin/env python3
"""
Raspberry Pi GPIO LED PWM Control
Breathing effect using PWM (Pulse Width Modulation)
"""

import RPi.GPIO as GPIO
import time

# GPIO Setup
LED_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

# Create PWM instance
pwm = GPIO.PWM(LED_PIN, 1000)  # 1000Hz frequency
pwm.start(0)  # Start with 0% duty cycle

def breathing_effect():
    """Create breathing effect using PWM"""
    print("Starting LED breathing effect...")
    
    try:
        while True:
            # Fade in (0% to 100%)
            for duty_cycle in range(0, 101, 2):
                pwm.ChangeDutyCycle(duty_cycle)
                time.sleep(0.05)
            
            # Fade out (100% to 0%)
            for duty_cycle in range(100, -1, -2):
                pwm.ChangeDutyCycle(duty_cycle)
                time.sleep(0.05)
                
    except KeyboardInterrupt:
        print("\nBreathing effect stopped")
    finally:
        pwm.stop()
        GPIO.cleanup()
        print("PWM stopped and GPIO cleaned up")

if __name__ == "__main__":
    breathing_effect()
```

### Multi-Pattern LED Controller

```python
#!/usr/bin/env python3
"""
Raspberry Pi GPIO Multi-Pattern LED Controller
Multiple LED patterns with user selection
"""

import RPi.GPIO as GPIO
import time
import sys

# GPIO Setup
LED_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)
pwm = GPIO.PWM(LED_PIN, 1000)

class LEDController:
    def __init__(self, pin):
        self.pin = pin
        self.pwm = GPIO.PWM(pin, 1000)
        
    def pattern_fast_blink(self, duration=10):
        """Fast blinking pattern"""
        print("Fast blink pattern...")
        end_time = time.time() + duration
        
        while time.time() < end_time:
            GPIO.output(self.pin, GPIO.HIGH)
            time.sleep(0.1)
            GPIO.output(self.pin, GPIO.LOW)
            time.sleep(0.1)
    
    def pattern_slow_blink(self, duration=10):
        """Slow blinking pattern"""
        print("Slow blink pattern...")
        end_time = time.time() + duration
        
        while time.time() < end_time:
            GPIO.output(self.pin, GPIO.HIGH)
            time.sleep(1.0)
            GPIO.output(self.pin, GPIO.LOW)
            time.sleep(1.0)
    
    def pattern_sos(self, repeats=3):
        """SOS morse code pattern"""
        print("SOS pattern...")
        
        for _ in range(repeats):
            # S (3 short)
            for _ in range(3):
                GPIO.output(self.pin, GPIO.HIGH)
                time.sleep(0.2)
                GPIO.output(self.pin, GPIO.LOW)
                time.sleep(0.2)
            
            time.sleep(0.5)
            
            # O (3 long)
            for _ in range(3):
                GPIO.output(self.pin, GPIO.HIGH)
                time.sleep(0.6)
                GPIO.output(self.pin, GPIO.LOW)
                time.sleep(0.2)
            
            time.sleep(0.5)
            
            # S (3 short)
            for _ in range(3):
                GPIO.output(self.pin, GPIO.HIGH)
                time.sleep(0.2)
                GPIO.output(self.pin, GPIO.LOW)
                time.sleep(0.2)
            
            time.sleep(2.0)  # Pause between SOS repeats
    
    def pattern_breathing(self, duration=15):
        """Breathing effect using PWM"""
        print("Breathing pattern...")
        self.pwm.start(0)
        end_time = time.time() + duration
        
        try:
            while time.time() < end_time:
                # Fade in
                for duty in range(0, 101, 2):
                    self.pwm.ChangeDutyCycle(duty)
                    time.sleep(0.05)
                
                # Fade out
                for duty in range(100, -1, -2):
                    self.pwm.ChangeDutyCycle(duty)
                    time.sleep(0.05)
        finally:
            self.pwm.stop()
    
    def cleanup(self):
        """Clean up GPIO"""
        self.pwm.stop()
        GPIO.cleanup()

def main():
    """Main program with user menu"""
    led = LEDController(LED_PIN)
    
    try:
        while True:
            print("\n=== Raspberry Pi LED Controller ===")
            print("1. Fast Blink")
            print("2. Slow Blink") 
            print("3. SOS Pattern")
            print("4. Breathing Effect")
            print("5. Exit")
            
            choice = input("Select pattern (1-5): ").strip()
            
            if choice == '1':
                led.pattern_fast_blink()
            elif choice == '2':
                led.pattern_slow_blink()
            elif choice == '3':
                led.pattern_sos()
            elif choice == '4':
                led.pattern_breathing()
            elif choice == '5':
                print("Exiting...")
                break
            else:
                print("Invalid choice. Please try again.")
                
    except KeyboardInterrupt:
        print("\nProgram interrupted")
    finally:
        led.cleanup()
        print("GPIO cleanup completed")

if __name__ == "__main__":
    main()
```

## Installation & Setup

### 1. Enable GPIO on Raspberry Pi
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python GPIO library
sudo apt install python3-rpi.gpio -y

# Enable GPIO interface
sudo raspi-config
# Navigate to: Interface Options → GPIO → Enable
```

### 2. Run the Programs
```bash
# Make scripts executable
chmod +x led_basic.py
chmod +x led_pwm.py
chmod +x led_controller.py

# Run basic blink
python3 led_basic.py

# Run PWM breathing effect
python3 led_pwm.py

# Run interactive controller
python3 led_controller.py
```

## Key Concepts Learned

### GPIO Programming
- **GPIO.setmode()**: Set pin numbering mode (BCM vs BOARD)
- **GPIO.setup()**: Configure pins as input/output
- **GPIO.output()**: Control digital output states
- **GPIO.cleanup()**: Proper resource cleanup

### PWM Control
- **PWM frequency**: Controls switching speed (1000Hz)
- **Duty cycle**: Controls brightness (0-100%)
- **ChangeDutyCycle()**: Dynamic brightness control

### Hardware Interfacing
- **Current limiting**: 330Ω resistor protects LED
- **GPIO voltage**: 3.3V logic levels
- **Pin mapping**: Physical vs BCM pin numbering

## Results & Performance

| Pattern | Duration | Current Draw | Brightness Control |
|---------|----------|--------------|-------------------|
| Basic Blink | Variable | ~20mA | On/Off only |
| Fast Blink | 10s | ~20mA | On/Off only |
| Slow Blink | 10s | ~20mA | On/Off only |
| SOS Pattern | ~15s | ~20mA | On/Off only |
| PWM Breathing | Variable | 0-20mA | 0-100% smooth |

## Applications

- **Learning Platform**: GPIO programming fundamentals
- **IoT Foundation**: Hardware interfacing basics
- **Status Indicators**: System state visualization
- **Prototyping**: LED control for larger projects
- **Educational**: Teaching digital electronics

## Troubleshooting

### Common Issues
1. **Permission denied**: Run with `sudo` or add user to gpio group
2. **GPIO already in use**: Call `GPIO.cleanup()` before rerunning
3. **LED not lighting**: Check wiring and resistor value
4. **PWM not smooth**: Increase PWM frequency

### Solutions
```bash
# Add user to gpio group
sudo usermod -a -G gpio $USER

# Reset GPIO state
echo "17" | sudo tee /sys/class/gpio/unexport

# Check GPIO state
gpio readall
```

## Future Enhancements

- **Multiple LEDs**: RGB color mixing
- **Sensor Integration**: Light-dependent control
- **Web Interface**: Remote LED control
- **MQTT Integration**: IoT connectivity
- **Pattern Storage**: Save custom patterns

## Code Repository

Complete source code available at: [GitHub Gist](https://gist.github.com/pavankalyan/raspberry-pi-gpio-led)

---

**Foundation Project**: This GPIO LED control project serves as the foundation for understanding hardware interfacing in IoT development. The concepts learned here apply to controlling motors, sensors, and other electronic components in more complex robotics and automation projects.