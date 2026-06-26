# Netravest

Netravest is a Flutter-based companion application developed as a research prototype to interface with smart assistive vests for visually impaired individuals. As an academic research project, it serves as a safety dashboard and telemetry interface, enabling real-time monitoring of vest sensors, camera status feeds, rapid SOS broadcasting, and location sharing, designed to evaluate and improve the safety, independence, and mobility of visually impaired users.

---

## Core Features

- **Real-Time Vest Telemetry**: Live indicators for battery levels (UPS Hat), sensor connectivity (LiDAR), and camera status over MQTT protocol.
- **Device Pairing & Connection Page**: Custom premium layout featuring rounded cards, input fields, tap-scaling button animations, fast shortcut buttons, and isolated telemetry topic routing (`netravest/{deviceCode}/status` and `netravest/{deviceCode}/command`).
- **Inline Device Status & Logout Panel**: Manage pairing status or unpair directly from the dashboard using an inline expanded panel that adapts to grid layouts.
- **Vest Online/Offline Indicator**: Visual status badge showing whether the companion application is actively connected to the vest broker.
- **Automated Reverse Geocoding**: Automatically translates raw GPS coordinates received from the vest (Ublox Neo M8N) into human-readable street addresses using the free OpenStreetMap Nominatim API.
- **Instant SOS & Geolocation Broadcast**: Single-tap SOS button that instantly opens WhatsApp to broadcast emergency messages with a Google Maps link of the current GPS coordinate.
- **Smart WhatsApp / Call Integrations**: Smart speed-dial panel that opens WhatsApp chats/calls for normal contacts, while automatically falling back to traditional cellular dialers for short emergency numbers (e.g., 110, 118).
- **Emergency Contact Manager**: Seamlessly expand the phone panel to add new emergency contacts or delete existing ones, immediately updating the telemetry UI.
- **Decoupled Architecture**: Logic is cleanly separated into dedicated Geocoding, Telemetry, and Provider state management layers.

---

## Project Architecture & Structure

The codebase is structured using a service-provider modular pattern:

```text
lib/
├── main.dart                      # App entry point & Provider initialization
├── pages/
│   ├── device_login_page.dart     # Custom pairing page for device connection
│   └── homepage_emergency.dart    # Main dashboard grid layout
├── providers/
│   └── emergency_provider.dart    # State manager (holds UI state, delegates logic to services)
├── services/
│   ├── geocoding_service.dart     # Service handling reverse geocoding via Nominatim API
│   └── telemetry_service.dart     # Service managing MQTT connection & subscriptions
└── widgets/
    ├── address_bar.dart           # GPS Address bar display & location sharing trigger
    ├── expanded_call_panel.dart   # Extracted speed dial list & contact manager
    ├── expanded_device_logout_panel.dart # Inline device unpair & status panel
    ├── expanded_settings_panel.dart # Expandable settings options panel
    ├── info_panel.dart            # Battery progress, LiDAR, Camera & connection indicators
    ├── settings_button.dart       # General styled dashboard buttons
    └── sos_button.dart            # Big SOS trigger widget
```

---

## Getting Started

### Prerequisites
Make sure you have installed the following requirements:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.1 or newer recommended)
* Dart SDK (compatible with SDK constraints `^3.12.1`)
* An Android or iOS Emulator / Physical device with Developer Options enabled

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/HanifMuzafarGunawan/Netravest-v1.1.9.git
   cd netravest
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Project**:
   ```bash
   flutter run
   ```

---

## Dependencies

This project leverages industry-standard packages to provide robust features:
* [provider](https://pub.dev/packages/provider) - State management and dependency injection.
* [http](https://pub.dev/packages/http) - Reverse geocoding network request client.
* [url_launcher](https://pub.dev/packages/url_launcher) - Launching external apps (WhatsApp & Phone dialers).
* [mqtt_client](https://pub.dev/packages/mqtt_client) - Real-time subscriber to the vest telemetry broker.
* [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) - Automating cross-platform launcher icon setup.

---

## Research & Academic License
This repository contains proprietary research material and software code developed for academic research purposes. It is private, confidential, and not intended for public or commercial distribution. All rights reserved by the researchers.
