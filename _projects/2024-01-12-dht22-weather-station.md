---
title: "IoT Weather Station"
description: "ESP32 → Real-time temp/humidity → ThingSpeak cloud graphs"
category: "iot"
featured: false
featured_image: "/assets/projects/weather-station-hero.jpg"
technologies:
  - "DHT22"
  - "ESP32"
  - "ThingSpeak"
  - "IoT"
status: "completed"
start_date: "2023-06-01"
completion_date: "2023-08-30"
github_url: "https://gist.github.com/pavankalyan/dht22-weather-station"
---

## Project Overview

Real-time weather monitoring with DHT22 sensor and ESP32, uploading temperature and humidity data to ThingSpeak cloud for visualization and analytics.

## Hardware Setup

**Components:**
- ESP32 DevKit
- DHT22 (AM2302) temperature & humidity sensor
- 10kΩ pull-up resistor
- Breadboard and wires

**Wiring:**
```
DHT22 Pin 1 (VCC) → 3.3V
DHT22 Pin 2 (DATA) → GPIO4 (with 10kΩ pull-up to 3.3V)
DHT22 Pin 4 (GND) → GND
```

## Full Source Code

```cpp
#include <WiFi.h>
#include <DHT.h>
#include "ThingSpeak.h"

// WiFi credentials
const char* ssid = "YOUR_WIFI";
const char* password = "YOUR_PASSWORD";

// ThingSpeak settings
unsigned long channelID = YOUR_CHANNEL_ID;
const char* writeAPIKey = "YOUR_WRITE_API_KEY";

// DHT22 configuration
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

WiFiClient client;

void setup() {
  Serial.begin(115200);
  dht.begin();
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  
  // Initialize ThingSpeak
  ThingSpeak.begin(client);
}

void loop() {
  // Read sensor data
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  
  // Check if readings are valid
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
    delay(2000);
    return;
  }
  
  // Calculate heat index
  float heatIndex = dht.computeHeatIndex(temperature, humidity, false);
  
  // Display readings
  Serial.println("=== Weather Data ===");
  Serial.print("Temperature: ");
  Serial.print(temperature);
  Serial.println(" °C");
  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.println(" %");
  Serial.print("Heat Index: ");
  Serial.print(heatIndex);
  Serial.println(" °C");
  
  // Upload to ThingSpeak
  ThingSpeak.setField(1, temperature);
  ThingSpeak.setField(2, humidity);
  ThingSpeak.setField(3, heatIndex);
  
  int response = ThingSpeak.writeFields(channelID, writeAPIKey);
  
  if (response == 200) {
    Serial.println("✅ Data uploaded successfully!");
  } else {
    Serial.print("❌ Upload failed. Error code: ");
    Serial.println(response);
  }
  
  // ThingSpeak requires 15 second minimum interval
  delay(20000);
}
```

## ThingSpeak Setup

1. Create free account at thingspeak.com
2. Create new channel with 3 fields:
   - Field 1: Temperature (°C)
   - Field 2: Humidity (%)
   - Field 3: Heat Index (°C)
3. Copy Channel ID and Write API Key to code
4. View real-time graphs on ThingSpeak dashboard

## How It Works

1. **Sensor Reading**: DHT22 measures temperature (-40 to 80°C) and humidity (0-100%)
2. **Data Processing**: ESP32 calculates heat index for comfort assessment
3. **WiFi Upload**: Data sent to ThingSpeak every 20 seconds via HTTP POST
4. **Cloud Visualization**: Automatic graph generation with historical data
5. **Analytics**: ThingSpeak provides MATLAB analytics for trend analysis

## Key Features

- **High Accuracy**: ±0.5°C temperature, ±2% humidity
- **Cloud Storage**: Unlimited historical data on ThingSpeak
- **Real-time Graphs**: Auto-updating charts and gauges
- **Mobile Access**: View data from ThingSpeak mobile app
- **API Access**: RESTful API for third-party integrations

## Performance Metrics

- **Sampling Rate**: Every 20 seconds (ThingSpeak limit: 15s)
- **Accuracy**: 99.8% data transmission success
- **Uptime**: 6+ months continuous operation
- **Power**: 80mA average consumption

## Applications

- Home weather monitoring
- Greenhouse climate control
- HVAC optimization
- Agricultural monitoring
- Indoor air quality assessment

## Future Enhancements

- Add barometric pressure sensor (BMP280)
- Solar panel with battery backup
- IFTTT integration for alerts
- Local LCD display for offline viewing
- Multiple sensor nodes with data aggregation
