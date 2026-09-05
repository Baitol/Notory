# Notory 📝📍

Сучасний, орієнтований на автономну роботу (offline-first) мобільний та десктопний додаток для польових інспекцій та нотаток із геоприв'язкою, розроблений на **Flutter**, **Riverpod** та **Drift (SQLite)**.

---

## 🌐 Документація та посібники
- 🇺🇦 **[Повний посібник зі встановлення українською (SETUP_GUIDE_UA.md)](SETUP_GUIDE_UA.md)**
- 🇬🇧 **[English Setup Guide (SETUP_GUIDE.md)](SETUP_GUIDE.md)** | **[English README](README.md)**
- 📚 **[Технічна документація архітектури та кодової бази (папка docs/)](docs/README.md)**:
  - 🏛️ [Загальна архітектура системи (docs/ARCHITECTURE.md)](docs/ARCHITECTURE.md)
  - 📂 [Детальний розбір кожного файлу проєкту (docs/FILES_DESCRIPTION.md)](docs/FILES_DESCRIPTION.md)
  - 🗄️ [Схема бази даних SQLite та Drift (docs/DATABASE_SCHEMA.md)](docs/DATABASE_SCHEMA.md)
  - 🔄 [Управління станом та потік даних Riverpod (docs/DATA_FLOW_AND_STATE.md)](docs/DATA_FLOW_AND_STATE.md)
  - 🗺️ [Геолокація GPS та мапи (docs/MAPS_AND_GEOLOCATION.md)](docs/MAPS_AND_GEOLOCATION.md)

---

## 🚀 Функціонал

- **Польові нотатки з геоприв'язкою**: Створення заміток із автоматичним визначенням GPS-координат, часу та опису.
- **Інтерактивна мапа OpenStreetMap**: Відображення маркерів заміток та інспекційних звітів за допомогою `flutter_map`.
- **Звіти польових інспекцій**: Об'єднання декількох заміток з координатами в структуровані звіти.
- **Offline-First архітектура**: Локальна база даних SQLite на Drift, яка працює повністю без підключення до Інтернету.
- **Темна тема**: Сучасний інтерфейс Material 3 у темній палітрі кольорів (Slate).

---

## 🛠️ Стек технологій

- **Фреймворк**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Менеджер стану**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **База даних**: [Drift](https://drift.simonbinder.eu/) (SQLite з реактивними потоками)
- **Мапи та геолокація**: [`flutter_map`](https://pub.dev/packages/flutter_map), [`geolocator`](https://pub.dev/packages/geolocator), [`latlong2`](https://pub.dev/packages/latlong2)
- **Інструменти збірки**: Android Gradle Plugin 9.0, Gradle 9.1, Java 17

---

## 📖 Посібники зі встановлення та налаштування

Для детальних покрокових інструкцій, розрахованих навіть на **абсолютно «чисті» комп'ютери** (новенький Mac або чистий ПК без попередньо встановлених програм для розробки):

👉 **[Відкрити повний посібник українською мовою (SETUP_GUIDE_UA.md)](SETUP_GUIDE_UA.md)**

### Швидкий старт (якщо Flutter та SDK уже встановлено)

```bash
# 1. Завантажити пакети
flutter pub get

# 2. Згенерувати схему бази даних Drift
dart run build_runner build --delete-conflicting-outputs

# 3. (Тільки для Mac) Встановити CocoaPods
cd ios && pod install && cd ..

# 4. Запустити на обраному пристрої
flutter run
```

---

## 📱 Підтримувані платформи

- **iOS** (iOS 13+) через Xcode / iOS Simulator
- **Android** (API 21+) через Android Studio / Android Emulator
- **Web** (Chrome / Edge / Safari) через команду `flutter run -d chrome`
