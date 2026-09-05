# Notory Architecture & Codebase Documentation 📚

This directory contains comprehensive technical documentation explaining the internal architecture, operating principles, file responsibilities, database schema, state management, and map/geolocation subsystems of the **Notory** application.

---

## 🌐 Language / Мова
- 🇬🇧 **[English Documentation (Current)](README.md)**
- 🇺🇦 **[Українська документація](../README.md)**

---

## 🧭 Documentation Index

| Document | Description |
|---|---|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | High-level layered architecture, application lifecycle (bootstrap), technology stack, and navigation flow diagram. |
| **[FILES_DESCRIPTION.md](FILES_DESCRIPTION.md)** | **Exhaustive file-by-file breakdown**: what every single file in the project does, its classes, methods, fields, and interactions. |
| **[DATA_FLOW_AND_STATE.md](DATA_FLOW_AND_STATE.md)** | Riverpod state management, unidirectional data flow, action dispatching, and reactive UI updates. |
| **[DATABASE_SCHEMA.md](DATABASE_SCHEMA.md)** | Drift & SQLite local database architecture, table definitions, Many-to-Many relationships, atomic transactions, and orphan cleanup. |
| **[MAPS_AND_GEOLOCATION.md](MAPS_AND_GEOLOCATION.md)** | GPS hardware lifecycle, location permissions, graceful fallback caching, OpenStreetMap/ArcGIS rendering, route polyline, and distance/time calculations. |

---

## 🎯 System Overview

Notory is an offline-first mobile and desktop application for recording field notes with GPS coordinates and organizing them into structured inspection reports:

```
┌─────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER (UI)                   │
│   HomeScreen  │  ReportDetailScreen  │  MapScreen  │ Picker │
└──────────────────────────────┬──────────────────────────────┘
                               │  Watch state (ref.watch)
                               │  Dispatch actions (ref.read / notifier)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│             STATE MANAGEMENT LAYER (Riverpod)               │
│                     ReportsNotifier                         │
│             (holds immutable List<ReportWithNotes>)         │
└──────────────────────────────┬──────────────────────────────┘
                               │  Calls database service methods
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER                          │
│                     DatabaseService                         │
│     (business logic, atomic transactions, query joins)      │
└──────────────────────────────┬──────────────────────────────┘
                               │  Drift Query API
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               DATA ACCESS LAYER (Drift DAO)                 │
│               AppDatabase (Drift SQLite API)                │
└──────────────────────────────┬──────────────────────────────┘
                               │  File I/O in background isolate
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   PHYSICAL STORAGE                          │
│                     notory.sqlite                           │
└─────────────────────────────────────────────────────────────┘
```
