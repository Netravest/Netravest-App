# 🛡️ Netravest

Netravest is a Flutter-based companion application engineered to integrate seamlessly with smart assistive vests for visually impaired individuals. It serves as a centralized safety hub, enabling real-time monitoring of vest sensors and camera feeds, rapid SOS broadcasting, instant GPS location sharing, and customizable speed-dial emergency contacts to significantly enhance user safety, mobility, and independence.

---

## 🌟 Core Features

- **📡 Vest Telemetry Integration**: Real-time status indicators for camera feeds and telemetry sensors embedded within the smart vest.
- **🚨 Instant SOS Trigger**: A prominent, single-tap SOS button that triggers urgent alerts and logs emergency events instantly.
- **📍 GPS Location Services**: Instant geolocation tracking with options to copy raw address coordinates to the clipboard and share live GPS points with relatives.
- **📞 Dynamic Call Expansion**: An expandable speed-dial tile that transitions smoothly into a full-height emergency contact manager, complete with dynamic contact additions.
- **⚡ Provider State Management**: Organized using the Provider pattern, separating clean business logic (`EmergencyProvider`) from modular UI components to ensure lightweight rendering and selective rebuild performance.

---

## 📁 Project Architecture & Structure

The codebase is refactored into a modular directory structure to ensure clean architecture and scalability:

```text
lib/
├── main.dart                      # App entry point & Provider initialization
├── providers/
│   └── emergency_provider.dart    # App state & business logic
├── pages/
│   └── homepage_emergency.dart    # Main dashboard grid layout
└── widgets/
    ├── address_bar.dart           # GPS Location component
    ├── info_panel.dart            # Sensor, battery, and clock indicators
    ├── menu_button.dart           # General dashboard tiles
    └── sos_button.dart            # Main SOS gesture trigger widget
```

---

## 🛠️ Getting Started

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

3. **Configure App Icons & Launch Screen** (Optional/Already pre-built):
   To regenerate launcher icons or configure launch layouts:
   ```bash
   dart run flutter_launcher_icons
   ```

4. **Run the Project**:
   ```bash
   flutter run
   ```

---

## ⚙️ Dependencies

This project leverages industry-standard packages to provide robust features:
* [provider](https://pub.dev/packages/provider) - State management and dependency injection.
* [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) - Automating cross-platform launcher icon setup.

---

## 📄 License
This project is private and proprietary. All rights reserved. Created as part of the Smart Vest Companion development ecosystem.
