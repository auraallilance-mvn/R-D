---
title: "GPS Tracking System"
description: "Real-time Lat/Lng via NEO-6M + TinyGPS++ parsing"
category: "iot"
featured: false
featured_image: "/assets/projects/gps-tracking-hero.jpg"
technologies:
  - "NEO-6M"
  - "Arduino"
  - "GPS"
  - "TinyGPS++"
status: "completed"
start_date: "2023-09-01"
completion_date: "2023-10-15"
github_url: "https://gist.github.com/pavankalyan/neo6m-gps-tracker"
---

## Project Overview

Real-time GPS tracking using NEO-6M module with Arduino. Parse NMEA sentences to extract latitude, longitude, altitude, speed, and satellite count using TinyGPS++ library.

## Hardware Setup

**Components:**
- Arduino Uno
- NEO-6M GPS module
- Active GPS antenna
- USB power or 9V battery

**Wiring:**
```
NEO-6M → Arduino
VCC → 5V
GND → GND
TX → Pin 4 (Arduino RX via SoftwareSerial)
RX → Pin 3 (Arduino TX via SoftwareSerial)
```

## Full Source Code

```cpp
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

// GPS module connection
const int GPS_RX_PIN = 4;
const int GPS_TX_PIN = 3;
const int GPS_BAUD = 9600;

// Create GPS and serial objects
TinyGPSPlus gps;
SoftwareSerial gpsSerial(GPS_RX_PIN, GPS_TX_PIN);

void setup() {
  Serial.begin(115200);
  gpsSerial.begin(GPS_BAUD);
  
  Serial.println("NEO-6M GPS Tracker");
  Serial.println("Waiting for GPS signal...");
  Serial.println("(Place antenna near window for best results)");
  Serial.println();
}

void loop() {
  // Read GPS data
  while (gpsSerial.available() > 0) {
    if (gps.encode(gpsSerial.read())) {
      displayGPSInfo();
    }
  }
  
  // Check if no data received for 5 seconds
  if (millis() > 5000 && gps.charsProcessed() < 10) {
    Serial.println("No GPS data received. Check wiring!");
    delay(1000);
  }
}

void displayGPSInfo() {
  Serial.println("========== GPS DATA ==========");
  
  // Location
  if (gps.location.isValid()) {
    Serial.print("📍 Latitude:  ");
    Serial.println(gps.location.lat(), 6);
    Serial.print("📍 Longitude: ");
    Serial.println(gps.location.lng(), 6);
    
    // Google Maps link
    Serial.print("🗺️  Maps: https://maps.google.com/?q=");
    Serial.print(gps.location.lat(), 6);
    Serial.print(",");
    Serial.println(gps.location.lng(), 6);
  } else {
    Serial.println("📍 Location: INVALID");
  }
  
  // Altitude
  if (gps.altitude.isValid()) {
    Serial.print("⛰️  Altitude: ");
    Serial.print(gps.altitude.meters());
    Serial.println(" m");
  }
  
  // Speed
  if (gps.speed.isValid()) {
    Serial.print("🚗 Speed: ");
    Serial.print(gps.speed.kmph());
    Serial.println(" km/h");
  }
  
  // Satellites
  if (gps.satellites.isValid()) {
    Serial.print("🛰️  Satellites: ");
    Serial.println(gps.satellites.value());
  }
  
  // Date & Time (UTC)
  if (gps.date.isValid() && gps.time.isValid()) {
    Serial.print("🕐 Date/Time: ");
    Serial.print(gps.date.day());
    Serial.print("/");
    Serial.print(gps.date.month());
    Serial.print("/");
    Serial.print(gps.date.year());
    Serial.print(" ");
    Serial.print(gps.time.hour());
    Serial.print(":");
    Serial.print(gps.time.minute());
    Serial.print(":");
    Serial.print(gps.time.second());
    Serial.println(" UTC");
  }
  
  // HDOP (Horizontal Dilution of Precision - accuracy indicator)
  if (gps.hdop.isValid()) {
    Serial.print("📊 HDOP: ");
    Serial.print(gps.hdop.hdop());
    Serial.print(" (");
    if (gps.hdop.hdop() < 2) Serial.print("Excellent");
    else if (gps.hdop.hdop() < 5) Serial.print("Good");
    else if (gps.hdop.hdop() < 10) Serial.print("Moderate");
    else Serial.print("Poor");
    Serial.println(")");
  }
  
  Serial.println("==============================");
  Serial.println();
  
  delay(2000);
}
```

## GPS Data Parsing Example

**Raw NMEA Sentence:**
```
$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47
```

**TinyGPS++ Parsed Output:**
```
Latitude:  48.117300
Longitude: 11.516667
Altitude:  545.4 m
Satellites: 8
HDOP: 0.9 (Excellent)
```

## How It Works

1. **Satellite Communication**: NEO-6M receives signals from GPS satellites
2. **NMEA Protocol**: GPS sends data in NMEA 0183 format (text sentences)
3. **TinyGPS++ Parsing**: Library decodes NMEA sentences into usable data
4. **Validation**: `isValid()` checks ensure data quality before use
5. **Serial Output**: Display formatted GPS information every 2 seconds

## Key Features

- **High Accuracy**: ±2.5m CEP (Circular Error Probable)
- **Fast Fix**: Cold start <30s, Hot start <1s
- **Multi-GNSS**: GPS + GLONASS support
- **Low Power**: 45mA active, 10mA backup mode
- **Update Rate**: 1Hz default (configurable to 10Hz)

## Installation

```bash
# Install TinyGPS++ library in Arduino IDE:
# Sketch → Include Library → Manage Libraries
# Search "TinyGPS++" → Install
```

## Troubleshooting

**No GPS fix:**
- Place antenna near window with clear sky view
- Wait 30-60 seconds for cold start
- Check LED on NEO-6M (blinking = searching, solid = fix)
- Avoid indoor/underground locations

**Garbage data:**
- Verify baud rate (9600 for NEO-6M)
- Check TX/RX wiring (TX→RX, RX→TX)
- Ensure 5V power supply

**Low satellite count:**
- Move to open area away from buildings
- Check antenna connection
- Wait for satellite acquisition (can take minutes)

## Applications

- **Vehicle Tracking**: Fleet management systems
- **Asset Tracking**: Shipping container monitoring
- **Geofencing**: Boundary alert systems
- **Navigation**: Autonomous robots and drones
- **Sports Tracking**: Running/cycling route logging
- **Wildlife Tracking**: Animal migration studies

## Advanced Features

### Data Logging to SD Card

```cpp
#include <SD.h>

File dataFile = SD.open("gps_log.txt", FILE_WRITE);
if (dataFile) {
  dataFile.print(gps.location.lat(), 6);
  dataFile.print(",");
  dataFile.println(gps.location.lng(), 6);
  dataFile.close();
}
```

### Distance Calculation

```cpp
// Calculate distance between two GPS coordinates
double distanceTo(double lat2, double lng2) {
  return TinyGPSPlus::distanceBetween(
    gps.location.lat(),
    gps.location.lng(),
    lat2,
    lng2
  );
}
```

### Course/Heading

```cpp
if (gps.course.isValid()) {
  Serial.print("Heading: ");
  Serial.print(gps.course.deg());
  Serial.println("°");
}
```

## Performance Metrics

- **Position Accuracy**: 2.5m CEP (50% probability)
- **Velocity Accuracy**: 0.1 m/s
- **Time Accuracy**: 1 microsecond (UTC)
- **Sensitivity**: -161 dBm (tracking)
- **Channels**: 50 (GPS + GLONASS)

## Future Enhancements

- ESP32 integration for WiFi GPS tracking
- Real-time map display on OLED/TFT
- Geofence alerts via SMS (GSM module)
- Speed limit warnings
- Trip statistics (distance, avg speed, duration)
- Google Maps API integration for reverse geocoding

## Technical Specifications

**NEO-6M Module:**
- Chipset: u-blox 6
- Frequency: L1 (1575.42 MHz)
- Update Rate: 1Hz (default), up to 10Hz
- Accuracy: 2.5m CEP
- Cold Start: <27s
- Hot Start: <1s
- Power: 45mA @ 3.3V
