# Notory 📝📍

A modern, offline-first mobile and desktop application for field inspection reporting and geotagged notes, built with **Flutter**, **Riverpod**, and **Drift (SQLite)**.

---

## 🌐 Documentation Languages / Мови документації
- 🇬🇧 **[English Setup Guide (SETUP_GUIDE.md)](SETUP_GUIDE.md)**
- 🇺🇦 **[Український посібник зі встановлення (SETUP_GUIDE_UA.md)](SETUP_GUIDE_UA.md)** | **[Опис проєкту українською (README_UA.md)](README_UA.md)**

---

## 🚀 Features

- **Field Notes with Geotagging**: Create notes automatically tagged with GPS coordinates, timestamps, and details.
- **Interactive OpenStreetMap**: View note pins and reports on interactive maps powered by `flutter_map` and OpenStreetMap.
- **Custom Inspection Reports**: Bundle multiple geotagged notes into categorized inspection reports.
- **Offline-First Architecture**: Persistent local SQLite database managed by Drift, designed to work completely offline.
- **Dark Mode UI**: Clean Material 3 design with dark slate accents.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite with reactive streams)
- **Maps & Geolocation**: [`flutter_map`](https://pub.dev/packages/flutter_map), [`geolocator`](https://pub.dev/packages/geolocator), [`latlong2`](https://pub.dev/packages/latlong2)
- **Build Tooling**: Android Gradle Plugin 9.0, Gradle 9.1, Java 17

---

## 📖 Installation & Setup Guides

For detailed, step-by-step setup guides designed even for **completely empty computers** (freshly unboxed Mac or clean Windows PC without any developer tools):

👉 **[Read the Full English Setup Guide (SETUP_GUIDE.md)](SETUP_GUIDE.md)**  
👉 **[Читати повну інструкцію українською мовою (SETUP_GUIDE_UA.md)](SETUP_GUIDE_UA.md)**

### Quick Start (If Flutter & SDKs are already installed)

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run Drift database code generator
dart run build_runner build --delete-conflicting-outputs

# 3. (Mac only) Install iOS CocoaPods
cd ios && pod install && cd ..

# 4. Run on your preferred target
flutter run
```

---

## 📱 Platforms Supported

- **iOS** (iOS 13+) via Xcode / iOS Simulator
- **Android** (API 21+) via Android Studio / Android Emulator
- **Web** (Chrome / Edge / Safari) via `flutter run -d chrome`
