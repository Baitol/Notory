# State Management & Data Flow (Riverpod) 🔄

This document explains the reactive state management architecture of **Notory** built on **Riverpod 2.x**.

---

## 🌐 Language / Мова
- 🇬🇧 **[English (Current)](DATA_FLOW_AND_STATE.md)**
- 🇺🇦 **[Українська версія](../DATA_FLOW_AND_STATE.md)**

---

## 1. Architectural Advantages of Riverpod

- **Compile-Time Safety**: Riverpod providers are top-level global constants that do not depend on the Flutter widget tree `BuildContext`. They cannot throw runtime `ProviderNotFoundException` errors.
- **Testability & Mocking**: Any provider can be overridden in unit and widget tests using `overrides: [...]`.
- **Unidirectional Data Flow**: Data flows downward from providers to widgets, while state modifications occur strictly through notifier methods.

---

## 2. Provider Definitions (`lib/providers/report_provider.dart`)

### 2.1. `databaseServiceProvider`
```dart
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('databaseServiceProvider must be overridden in main');
});
```
- Acts as a Dependency Injection (DI) token.
- Throws an explicit error if accessed without being initialized in `main.dart`.
- Overridden in `main.dart` with the initialized database service:
  ```dart
  ProviderScope(
    overrides: [
      databaseServiceProvider.overrideWithValue(dbService),
    ],
    child: const NotoryApp(),
  )
  ```

### 2.2. `ReportsNotifier`
```dart
class ReportsNotifier extends StateNotifier<List<ReportWithNotes>> {
  final DatabaseService _db;

  ReportsNotifier(this._db) : super([]) {
    loadReports();
  }
  ...
}
```
- Holds the application's in-memory state as an immutable list `List<ReportWithNotes>`.
- Starts with an empty list `[]` and immediately triggers `loadReports()` upon instantiation to fetch data from SQLite.

### 2.3. `reportsProvider`
```dart
final reportsProvider = StateNotifierProvider<ReportsNotifier, List<ReportWithNotes>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ReportsNotifier(db);
});
```
- Exposes `ReportsNotifier` to the UI.
- Listening widgets subscribe to this provider via `ref.watch(reportsProvider)`.

---

## 3. Data Mutation Lifecycle

Here is the exact step-by-step sequence when a user creates a new report:

```
[ UI Layer: HomeScreen ]
  │
  │ 1. User enters "Site Alpha" and taps "Create"
  ▼
[ ref.read(reportsProvider.notifier).addReport(...) ]
  │
  │ 2. Notifier delegates to DatabaseService
  ▼
[ DatabaseService.saveReport(...) ]
  │
  │ 3. Drift executes: INSERT INTO reports ...
  ▼
[ SQLite Storage (notory.sqlite) ]
  │
  │ 4. Record committed to disk in background isolate
  ▼
[ ReportsNotifier.loadReports() ]
  │
  │ 5. Queries all reports and notes via SQL INNER JOIN
  ▼
[ state = await _db.getAllReports() ]
  │
  │ 6. A NEW immutable List<ReportWithNotes> is assigned to state
  ▼
[ Riverpod Framework ]
  │
  │ 7. Detects reference change and notifies all subscribers
  ▼
[ HomeScreen (ref.watch(reportsProvider)) ]
  │
  │ 8. ListView.builder efficiently re-renders with the new report card
```

---

## 4. Consuming Providers in Widgets

### Observing State (`ref.watch`)
Used inside the `build` method of `ConsumerWidget` or `ConsumerStatefulWidget`:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final reportItems = ref.watch(reportsProvider);
  // Re-runs only when reportsProvider state changes
}
```

### Dispatching Actions (`ref.read`)
Used inside button callbacks (`onPressed`, `onTap`) to avoid unnecessary widget rebuilds:
```dart
ElevatedButton(
  onPressed: () {
    ref.read(reportsProvider.notifier).deleteReport(report.id);
  },
  child: const Text('Delete'),
);
```
