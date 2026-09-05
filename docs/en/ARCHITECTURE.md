# Notory Application Architecture 🏛️

This document describes the high-level architecture of the **Notory** application, component interactions, bootstrap lifecycle, and core engineering decisions.

---

## 🌐 Language / Мова
- 🇬🇧 **[English (Current)](ARCHITECTURE.md)**
- 🇺🇦 **[Українська версія](../ARCHITECTURE.md)**

---

## 1. Architectural Pattern: Layered Architecture

The application follows a clean, layered architecture with strict separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│    lib/screens/ (Widgets, Sheets, Dialogs, Map Overlays)    │
└──────────────────────────────┬──────────────────────────────┘
                               │ Observes state & dispatches actions
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 STATE MANAGEMENT LAYER                      │
│       lib/providers/ (Riverpod Notifiers & Providers)       │
└──────────────────────────────┬──────────────────────────────┘
                               │ Invokes business operations
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                          │
│     lib/services/ (DatabaseService, SQL joins, cleanup)     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Drift Typed Queries & Transactions
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                DATA ACCESS LAYER (PERSISTENCE)              │
│       lib/models/ (Drift AppDatabase, Tables, Schemas)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ Native OS file operations (Isolate)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      PHYSICAL STORAGE                       │
│                SQLite file (notory.sqlite)                  │
└─────────────────────────────────────────────────────────────┘
```

1. **Presentation Layer (`lib/screens/`)**:
   - Built with Flutter widgets (`ConsumerWidget`, `ConsumerStatefulWidget`).
   - Purely responsible for rendering the UI, handling user gestures (taps, text input, navigation), and presenting feedback (snackbars, dialogs).
   - Contains no direct SQL queries or low-level file I/O.

2. **State Management Layer (`lib/providers/`)**:
   - Implemented using **Riverpod** (`flutter_riverpod`).
   - The central entity is `ReportsNotifier`, which extends `StateNotifier<List<ReportWithNotes>>`.
   - Holds the in-memory state of the application, responds to UI events, calls the service layer, and notifies listening widgets whenever state changes.

3. **Service Layer (`lib/services/`)**:
   - The `DatabaseService` class encapsulates business logic and relational integrity:
     - Aggregates reports with their linked notes via SQL INNER JOINs.
     - Ensures atomicity of complex database mutations using `_db.transaction(...)`.
     - Automatically cleans up orphaned notes when links or reports are deleted.

4. **Data Access / Persistence Layer (`lib/models/`)**:
   - Uses **Drift** (a compile-time type-safe SQLite abstraction for Dart).
   - `AppDatabase` manages table definitions (`Notes`, `Reports`, `ReportNotes`), schema versioning, and connection lifecycle.
   - Operates in a background Dart isolate (`NativeDatabase.createInBackground`) via `sqlite3_flutter_libs`, preventing any UI jank or frame drops.

---

## 2. Application Bootstrap & Lifecycle

The application entry point is located in `lib/main.dart`:

```dart
void main() async {
  // 1. Initialize Flutter Engine channel bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Instantiate the SQLite database (Drift)
  final db = AppDatabase();

  // 3. Instantiate the service layer with the database dependency
  final dbService = DatabaseService(db);

  // 4. Launch root widget tree wrapped in Riverpod's ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        // Dependency Injection: override the unimplemented base provider
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const NotoryApp(),
    ),
  );
}
```

### Execution Steps:
1. `WidgetsFlutterBinding.ensureInitialized()`: Ensures platform channels are ready before opening file paths with `path_provider`.
2. `AppDatabase()`: Creates a `LazyDatabase` that resolves the application documents directory (`notory.sqlite`) and opens the SQLite database in a background isolate upon first access.
3. `DatabaseService(db)`: Wraps database queries into business methods.
4. `ProviderScope(overrides: [...])`: Leverages Riverpod's dependency injection pattern. The base `databaseServiceProvider` is overridden with the initialized instance, eliminating race conditions.
5. When `HomeScreen` mounts, it calls `ref.watch(reportsProvider)`. The `ReportsNotifier` constructor immediately runs `loadReports()`, reading all saved data from SQLite and rendering it.

---

## 3. Navigation Graph

```
                       ┌─────────────────────────┐
                       │       HomeScreen        │
                       │   (Inspection Reports)  │
                       └────────────┬────────────┘
                                    │
           ┌────────────────────────┴────────────────────────┐
           ▼ (Tap Report Card)                               ▼ (Tap "+ New Report" FAB)
┌───────────────────────────────┐               ┌─────────────────────────────────┐
│      ReportDetailScreen       │               │      ModalBottomSheet           │
│    (Chronological Notes)      │               │     (Create/Edit Report)        │
└──────────────┬────────────────┘               └─────────────────────────────────┘
               │
      ┌────────┴─────────────────────────────┐
      │ (Tap Map Icon / "View Route Map")    │ (Tap "+ Add New Entry" / Edit)
      ▼                                      ▼
┌───────────────────────────┐      ┌──────────────────────────────────┐
│         MapScreen         │      │      ModalBottomSheet            │
│  (Interactive Route Map,  │      │     (Enter Note Details)         │
│   Polylines & Statistics) │      └─────────────────┬────────────────┘
└───────────────────────────┘                        │
                                  ┌──────────────────┴──────────────────┐
                                  ▼ (Tap "Map")                         ▼ (Tap "Edit")
                      ┌───────────────────────┐             ┌───────────────────────┐
                      │ LocationPickerScreen  │             │ ManualLocationDialog  │
                      │  (Visual Map Picker)  │             │ (Type Lat/Lng values) │
                      └───────────────────────┘             └───────────────────────┘
```

---

## 4. Offline-First Philosophy

Notory operates completely offline without external network or server dependencies:
- **Local Persistence**: Reports, field notes, timestamps, and GPS coordinates are stored directly in SQLite on the user's device.
- **Maps**: OpenStreetMap and ArcGIS World Imagery tile layers are fetched when online, while note data and GPS coordinates function reliably without connectivity.
- **Zero Authentication Requirement**: The user can start creating reports and recording GPS waypoints immediately upon launching the application.

---

## 5. Design System

The application uses **Material 3** with a custom dark slate theme:
- **Background**: Slate 900 (`0xFF0F172A`).
- **Surface / Card Background**: Slate 800 (`0xFF1E293B`).
- **Primary Accent**: `Colors.indigoAccent` (buttons, active tabs, route polylines).
- **Secondary Accent**: `Colors.tealAccent` (GPS indicators, waypoint badges, location confirmation).
- **Destructive Actions**: `Colors.redAccent` (deleting notes or reports).
- **Typography**: Monospaced font (`fontFamily: 'monospace'`) for coordinates to enhance legibility of floating-point values.
