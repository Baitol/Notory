# Detailed File-by-File Codebase Reference 📂

This document provides a comprehensive, detailed breakdown of every file in the **Notory** project: its purpose, architectural layer, classes, methods, parameters, and system interactions.

---

## 🌐 Language / Мова
- 🇬🇧 **[English (Current)](FILES_DESCRIPTION.md)**
- 🇺🇦 **[Українська версія](../FILES_DESCRIPTION.md)**

---

## Codebase Summary Table

| File | Layer | Primary Responsibility |
|---|---|---|
| [`lib/main.dart`](#1-libmaindart) | Bootstrap & App Root | Application entry point, Material 3 dark theme, Riverpod DI setup. |
| [`lib/models/database.dart`](#2-libmodelsdatabasedart) | Data / Drift ORM | SQLite table definitions (`Notes`, `Reports`, `ReportNotes`), connection config. |
| [`lib/models/database.g.dart`](#3-libmodelsdatabasegdart) | Generated Code | Generated Drift code (data classes, companions, SQL query execution). |
| [`lib/services/database_service.dart`](#4-libservicesdatabase_servicedart) | Service Layer | Business database queries, SQL INNER JOINs, atomic transactions, orphan cleanup. |
| [`lib/providers/report_provider.dart`](#5-libprovidersreport_providerdart) | State Management | Riverpod providers, `ReportsNotifier` managing reactive UI updates. |
| [`lib/screens/home_screen.dart`](#6-libscreenshome_screendart) | Presentation (UI) | Home dashboard: list of inspection reports, create/edit modal sheet, delete confirm. |
| [`lib/screens/report_detail_screen.dart`](#7-libscreensreport_detail_screendart) | Presentation (UI) | Inspection view: chronological notes timeline, GPS acquisition, manual/map edits. |
| [`lib/screens/map_screen.dart`](#8-libscreensmap_screendart) | Presentation (UI) | Interactive route map, polylines, waypoint markers, distance and elapsed time. |
| [`lib/screens/location_picker_screen.dart`](#9-libscreenslocation_picker_screendart) | Presentation (UI) | Interactive map-based coordinate picker with pulse effect and current GPS button. |
| [`pubspec.yaml`](#10-pubspecyaml) | Project Config | Flutter dependencies, SDK version bounds, asset and font configuration. |
| [`analysis_options.yaml`](#11-analysis_optionsyaml) | Linter Config | Dart static analysis configuration with `flutter_lints`. |
| [`android/app/build.gradle.kts`](#12-androidappbuildgradlekts) | Android Build Config | Android build configuration: Gradle 9.1, AGP 9.0, Java 17, applicationId. |
| [`ios/Runner/Info.plist`](#13-iosrunnerinfoplist) | iOS Native Config | iOS permissions configuration (including GPS location usage descriptions). |

---

## 1. `lib/main.dart`

### Purpose
The bootstrap entry point for the Flutter application. It initializes platform channels, opens the Drift SQLite database, registers global providers in `ProviderScope`, and defines the global application theme.

### Components & Classes
1. **`void main() async`**:
   - `WidgetsFlutterBinding.ensureInitialized()`: Ensures asynchronous platform channels are ready before accessing the local filesystem.
   - `final db = AppDatabase()`: Instantiates the Drift SQLite database.
   - `final dbService = DatabaseService(db)`: Instantiates the database service layer.
   - `runApp(ProviderScope(...))`: Mounts the root widget inside Riverpod's provider container.
   - `databaseServiceProvider.overrideWithValue(dbService)`: Injects the service instance so all descendant widgets can access it without duplicate instantiations.

2. **`class NotoryApp extends StatelessWidget`**:
   - Returns the root `MaterialApp`.
   - `title: 'Notory'`.
   - `debugShowCheckedModeBanner: false`: Hides the debug watermark banner.
   - `themeMode: ThemeMode.dark`: Enforces dark mode styling.
   - Theme configuration:
     - `useMaterial3: true`.
     - `scaffoldBackgroundColor: Color(0xFF0F172A)` (Slate 900).
     - `surface: Color(0xFF1E293B)` (Slate 800).
     - `primary: Colors.indigoAccent`.
     - `secondary: Colors.tealAccent`.
   - Sets initial route: `home: const HomeScreen()`.

---

## 2. `lib/models/database.dart`

### Purpose
Defines the SQLite database schema using Drift's typed table DSL. Declares columns, primary keys, foreign key references, and sets up connection logic.

### Table Definitions

1. **`class Notes extends Table`**:
   Stores individual geotagged field notes:
   - `id`: `integer().autoIncrement()()` — Primary key.
   - `content`: `text()()` — Note text content.
   - `timestamp`: `dateTime()()` — Recording date and time.
   - `latitude`: `real()()` — Latitude (-90.0 to +90.0).
   - `longitude`: `real()()` — Longitude (-180.0 to +180.0).

2. **`class Reports extends Table`**:
   Stores inspection reports:
   - `id`: `integer().autoIncrement()()` — Primary key.
   - `title`: `text()()` — Report title.
   - `description`: `text()()` — Detailed description or scope.
   - `createdAt`: `dateTime()()` — Creation date and time.

3. **`class ReportNotes extends Table`**:
   Many-to-Many join table:
   - `reportId`: `integer().references(Reports, #id)()` — Foreign key to `Reports`.
   - `noteId`: `integer().references(Notes, #id)()` — Foreign key to `Notes`.
   - `@override Set<Column> get primaryKey => {reportId, noteId};` — Composite primary key.

4. **`class AppDatabase extends _$AppDatabase`**:
   - Annotated with `@DriftDatabase(tables: [Notes, Reports, ReportNotes])`.
   - Extends the generated `_$AppDatabase`.
   - `schemaVersion => 1`: Schema version number.

5. **`LazyDatabase _openConnection()`**:
   - Queries `getApplicationDocumentsDirectory()`.
   - Resolves `notory.sqlite`.
   - Creates background native database connection via `NativeDatabase.createInBackground(file)`.

---

## 3. `lib/models/database.g.dart`

### Purpose
The generated counterpart to `database.dart`, generated by `drift_dev` via `build_runner`.

### Generated Classes
- `Note` and `Report`: Strongly typed Dart data classes.
- `NotesCompanion`, `ReportsCompanion`, `ReportNotesCompanion`: Value wrapper classes used for insertions and updates.
- `_$AppDatabase`: Implements the low-level query execution and table metadata.

> ⚠️ **Note**: This file should never be manually edited. Re-generate it using:
> `dart run build_runner build --delete-conflicting-outputs`

---

## 4. `lib/services/database_service.dart`

### Purpose
The service layer that coordinates database queries, enforces relational constraints, and manages transactions.

### Classes & Methods

1. **`class ReportWithNotes`**:
   - DTO class containing `final Report report` and `final List<Note> notes`.

2. **`class DatabaseService`**:
   - `Future<List<ReportWithNotes>> getAllReports()`:
     - Fetches all reports sorted descending by `createdAt`.
     - Executes `_getNotesForReport(report.id)` for each report.
   - `Future<List<Note>> _getNotesForReport(int reportId)`:
     - Performs an SQL `innerJoin` between `notes` and `reportNotes` matching `reportId`.
   - `Future<int> saveReport(ReportsCompanion companion)`:
     - Performs an `insertOnConflictUpdate` on the `reports` table.
   - `Future<void> deleteReport(int id)`:
     - Runs inside an atomic `_db.transaction(...)`.
     - Identifies note IDs linked to this report.
     - Deletes join rows from `reportNotes`.
     - **Orphan Cleanup**: Deletes any note that is no longer referenced by any other report.
     - Deletes the report row itself.
   - `Future<void> addNoteToReport(int reportId, NotesCompanion noteCompanion)`:
     - Inserts the note and creates the corresponding join row in `reportNotes`.
   - `Future<void> updateNote(NotesCompanion companion)`:
     - Updates an existing note's content and coordinates.
   - `Future<void> deleteNote(int reportId, int noteId)`:
     - Removes the join row; deletes the note if orphaned.

---

## 5. `lib/providers/report_provider.dart`

### Purpose
Riverpod state management layer connecting the database service to the presentation widgets.

### Components
1. **`databaseServiceProvider`**: Base `Provider<DatabaseService>` overridden in `main.dart`.
2. **`class ReportsNotifier extends StateNotifier<List<ReportWithNotes>>`**:
   - Holds the application's in-memory list of reports.
   - Automatically loads reports on initialization (`loadReports()`).
   - Action methods:
     - `loadReports()`: Fetches all reports and updates `state`.
     - `addReport(title, description)`: Inserts a report and refreshes state.
     - `updateReport(report, newTitle, newDescription)`: Updates report attributes.
     - `deleteReport(id)`: Deletes a report and refreshes state.
     - `addNote(reportId, content, latitude, longitude)`: Adds a note to a report.
     - `updateNote(...)`: Updates note text and coordinates.
     - `deleteNote(reportId, noteId)`: Deletes a note and refreshes state.
3. **`reportsProvider`**: `StateNotifierProvider` watched by UI widgets via `ref.watch(reportsProvider)`.

---

## 6. `lib/screens/home_screen.dart`

### Purpose
The primary dashboard displaying the list of inspection reports, creating new reports, and editing/deleting existing ones.

### Structure & Behavior
1. **`HomeScreen` (`ConsumerWidget`)**:
   - Watches `reportsProvider`: `final reportItems = ref.watch(reportsProvider)`.
   - If empty, renders an empty state illustration with an open-folder icon and helpful prompt.
   - If reports exist, renders a `ListView.builder` of `_ReportCard` items.
   - FAB button triggers `_showReportForm(...)` bottom sheet.
2. **`_showReportForm(context, ref, [report])`**:
   - Displays a rounded modal bottom sheet containing title and description `TextField` widgets.
   - Operates in either "Create" or "Edit" mode depending on whether `report` was provided.
3. **`_ReportCard` (`ConsumerWidget`)**:
   - Displays the report title, description preview, formatted creation date, and note count badge.
   - Tapping the card navigates to `ReportDetailScreen(reportId: report.id)`.
   - Trailing `PopupMenuButton` provides Edit and Delete options (with confirmation dialog).

---

## 7. `lib/screens/report_detail_screen.dart`

### Purpose
The core field-inspection screen displaying chronological notes for a selected report, requesting live GPS fixes, allowing manual location overrides, and launching the route map.

### Key Logic & Features
1. **GPS Acquisition (`_getCurrentLocation`)**:
   - Verifies location services and requests permissions.
   - Calls `Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10))`.
   - **Graceful Fallback**: If GPS times out or is disabled, caches and reuses the last-known coordinate (`_lastKnownLat`/`_lastKnownLng`) while displaying an amber `SnackBar`.
2. **Manual Location Dialog (`_showManualLocationDialog`)**:
   - Allows typing exact coordinates with validation (-90..90 for Lat, -180..180 for Lng).
3. **Adding & Editing Notes (`_addNewNote`, `_editNote`)**:
   - Opens a modal sheet displaying current coordinates.
   - Provides quick **Map** (launches `LocationPickerScreen`) and **Edit** (launches manual dialog) actions.
4. **Chronological Timeline View**:
   - Uses `CustomScrollView` and `SliverList` to draw a vertical route line connecting waypoint cards.
   - `_ExpandableNoteCard` expands on tap to show exact coordinates and action buttons.

---

## 8. `lib/screens/map_screen.dart`

### Purpose
Fullscreen interactive route map visualizing all waypoints, drawing the connecting route polyline, and displaying inspection statistics.

### Functionality & Calculations
1. **Initial Calculations**:
   - Computes the geometric center (`avgLat`, `avgLng`) to center the map camera.
   - Sums geodesic distances between consecutive points using `Geolocator.distanceBetween(...)` to compute `_totalDistanceKm`.
   - Computes elapsed time between the first and last note timestamp (`_elapsedTimeString`).
2. **FlutterMap Layers**:
   - `TileLayer`: ArcGIS World Imagery satellite tiles.
   - `PolylineLayer`: 4.5px indigo line tracing the path between waypoints.
   - `MarkerLayer`: Numbered badges for each waypoint.
3. **Interactivity**:
   - Tapping a marker centers the camera and opens a detail card at the bottom of the screen.
   - Center button in the AppBar resets the camera to show the full route.

---

## 9. `lib/screens/location_picker_screen.dart`

### Purpose
Visual map-based coordinate picker allowing users to manually designate a note location.

### Implementation
- Listens to map taps via `onTap: (tapPosition, point)` and repositions the marker.
- Marker features a pulsing teal ripple effect for visual clarity.
- FAB button relocates the camera to the user's live GPS coordinates.
- Bottom sheet displays formatted coordinates and a "Confirm Location" button returning the selected `LatLng`.

---

## 10. `pubspec.yaml`

### Purpose
The Flutter project manifest defining metadata, SDK constraints, and dependencies:
- `flutter_riverpod: ^2.5.1`: Reactive state management.
- `drift: ^2.20.0` & `sqlite3_flutter_libs: ^0.5.0`: Local SQLite storage.
- `geolocator: ^10.1.0`: Native GPS hardware integration.
- `flutter_map: ^6.1.0` & `latlong2: ^0.9.0`: OpenStreetMap rendering.
- `path_provider: ^2.1.2`: Resolves document storage paths.
- `intl: ^0.19.0`: Date and time formatting.
- `build_runner: ^2.4.12` & `drift_dev: ^2.20.0`: Compile-time code generation.

---

## 11. `analysis_options.yaml`

### Purpose
Configures the Dart static analysis engine with `package:flutter_lints/flutter.yaml` rules, enforcing code quality, type safety, and clean formatting.

---

## 12. `android/app/build.gradle.kts` & `settings.gradle.kts`

### Purpose
Android Gradle configuration using Kotlin DSL:
- Configured for **Gradle 9.1.0** and **Android Gradle Plugin 9.0.1**.
- Enforces **Java 17** compatibility (`JavaVersion.VERSION_17`, `JVM_17`).
- Defines package namespace `com.notory.notory`.

---

## 13. `ios/Runner/Info.plist`

### Purpose
iOS platform configuration and permission declarations:
- `NSLocationWhenInUseUsageDescription`: User-facing prompt explaining why GPS access is needed for geotagging notes.
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Extended location usage description.
- Sets supported interface orientations for iPhone and iPad.
