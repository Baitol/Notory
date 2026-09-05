# SQLite Database Schema & Principles (Drift) 🗄️

This document details the local data persistence architecture of **Notory**: table definitions, data types, relational constraints, transaction management, and cleanup of deleted records.

---

## 🌐 Language / Мова
- 🇬🇧 **[English (Current)](DATABASE_SCHEMA.md)**
- 🇺🇦 **[Українська версія](../DATABASE_SCHEMA.md)**

---

## 1. Why Drift & SQLite?

1. **True Offline-First Storage**: All data is persisted locally in a single SQLite file (`notory.sqlite`) on the device.
2. **Compile-Time Type Safety**: Drift generates strongly typed Dart models from table definitions, catching schema mismatches during compilation.
3. **Background Isolate Execution**:
   ```dart
   LazyDatabase _openConnection() {
     return LazyDatabase(() async {
       final dbFolder = await getApplicationDocumentsDirectory();
       final file = File(p.join(dbFolder.path, 'notory.sqlite'));
       return NativeDatabase.createInBackground(file);
     });
   }
   ```
   All disk I/O occurs on a background OS thread via `sqlite3_flutter_libs`, preventing any UI jank or frame drops.

---

## 2. Entity Relationship Diagram (ERD)

```
┌─────────────────────────┐               ┌─────────────────────────┐
│         Reports         │               │          Notes          │
├─────────────────────────┤               ├─────────────────────────┤
│ id (PK, AutoIncrement)  │◄─────────┐    │ id (PK, AutoIncrement)  │◄─────────┐
│ title (Text)            │          │    │ content (Text)          │          │
│ description (Text)      │          │    │ timestamp (DateTime)    │          │
│ createdAt (DateTime)    │          │    │ latitude (Real / Double)│          │
└─────────────────────────┘          │    │ longitude (Real/Double) │          │
                                     │    └─────────────────────────┘          │
                                     │                                         │
                               ┌─────┴──────────────────┐                      │
                               │      ReportNotes       │                      │
                               ├────────────────────────┤                      │
                               │ reportId (FK -> Reports)                      │
                               │ noteId   (FK -> Notes) ├──────────────────────┘
                               │ PK: (reportId, noteId) │
                               └────────────────────────┘
```

---

## 3. Table Definitions

### 3.1. `Notes` Table
Stores individual field notes tagged with geographical coordinates:

| Column | Dart Type | SQLite Type | Description |
|---|---|---|---|
| `id` | `int` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Unique note identifier |
| `content` | `String` | `TEXT` | Text description of the field observation |
| `timestamp` | `DateTime` | `INTEGER` (Unix epoch) | Date and time recorded |
| `latitude` | `double` | `REAL` | Latitude (-90.0 to +90.0) |
| `longitude` | `double` | `REAL` | Longitude (-180.0 to +180.0) |

### 3.2. `Reports` Table
Stores inspection report metadata:

| Column | Dart Type | SQLite Type | Description |
|---|---|---|---|
| `id` | `int` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Unique report identifier |
| `title` | `String` | `TEXT` | Title of the report |
| `description` | `String` | `TEXT` | Scope, purpose, or additional notes |
| `createdAt` | `DateTime` | `INTEGER` (Unix epoch) | Date and time created |

### 3.3. `ReportNotes` Join Table (Many-to-Many)
Connects reports to notes:

| Column | Dart Type | SQLite Type | Constraint |
|---|---|---|---|
| `reportId` | `int` | `INTEGER` | Foreign Key -> `Reports(id)` |
| `noteId` | `int` | `INTEGER` | Foreign Key -> `Notes(id)` |

- **Composite Primary Key**: `@override Set<Column> get primaryKey => {reportId, noteId};`
- Prevents duplicate links between the same report and note.

---

## 4. Transaction Management & Orphan Cleanup

When deleting reports or notes, `DatabaseService` ensures relational integrity inside database transactions:

### 4.1. Safe Report Deletion (`deleteReport`)
Executed within an atomic `_db.transaction(...)`:
1. Queries all `noteId` entries associated with the given `reportId`.
2. Deletes the join rows from `ReportNotes`.
3. For each note ID, checks if it is still referenced by another report.
   - If not referenced anywhere else (an orphaned note), deletes the note from `Notes`.
4. Deletes the report itself from `Reports`.

### 4.2. Adding a Note to a Report (`addNoteToReport`)
Executed atomically:
1. Inserts the note into `Notes`, returning the auto-generated `noteId`.
2. Inserts a join row into `ReportNotes` linking `reportId` and `noteId`.

---

## 5. Code Generation & Schema Updates

Whenever modifying table definitions in `lib/models/database.dart`:
```bash
# Run one-off build
dart run build_runner build --delete-conflicting-outputs

# Or run in watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```
This updates `lib/models/database.g.dart`.
