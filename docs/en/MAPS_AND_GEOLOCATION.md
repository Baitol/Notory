# Maps & Geolocation in Notory 🗺️📍

This document explains the principles of GPS hardware interaction, permission handling, offline fallback mechanisms, and map rendering in **Notory**.

---

## 🌐 Language / Мова
- 🇬🇧 **[English (Current)](MAPS_AND_GEOLOCATION.md)**
- 🇺🇦 **[Українська версія](../MAPS_AND_GEOLOCATION.md)**

---

## 1. GPS Hardware & Location Permissions (`geolocator`)

### 1.1. Permission Lifecycle
Before requesting GPS fixes, the application conducts a 3-step validation inside `_getCurrentLocation()`:

```dart
// 1. Is the hardware GPS location service enabled in OS settings?
bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
if (!serviceEnabled) {
  throw 'Location services are disabled. Please enable GPS.';
}

// 2. Has the user granted permission to Notory?
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw 'Location permission denied.';
  }
}

// 3. Are permissions permanently denied?
if (permission == LocationPermission.deniedForever) {
  throw 'Location permissions are permanently denied.';
}
```

### 1.2. High Accuracy with Timeout Protection
```dart
final pos = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: const Duration(seconds: 10),
);
```
- `LocationAccuracy.high`: Forces the OS to prioritize dedicated GPS satellites over Wi-Fi triangulation.
- `timeLimit: Duration(seconds: 10)`: Prevents the UI from hanging when the user is indoors, in tunnels, or in basements.

---

## 2. Graceful Fallback Strategy

In developer emulators or when GPS signal is unavailable, unhandled exceptions would crash an ordinary application. Notory implements a resilient fallback mechanism:

1. **Last-Known Coordinates Cache (`_lastKnownLat`, `_lastKnownLng`)**:
   - Every successful location fix caches the coordinates.
   - When opening an existing report, `didChangeDependencies` seeds coordinates from the most recent note.
2. **Graceful Warning SnackBar**:
   - If GPS times out, an amber `SnackBar` alerts the user:
     `"GPS unavailable. Using last known position."`
   - A fallback `Position` object is returned, allowing the user to record the note without losing their text.
3. **Manual Overrides**:
   - Users can tap **Map** or **Edit** on the note creation sheet to adjust coordinates manually.

---

## 3. Interactive Map (`flutter_map` & `latlong2`)

The map is built using **FlutterMap**, an OpenStreetMap/Leaflet-compatible Dart engine:

### 3.1. Satellite Tile Layer (`TileLayer`)
```dart
TileLayer(
  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  userAgentPackageName: 'com.notory.app',
)
```
Fetches high-resolution ArcGIS World Imagery satellite tiles with caching.

### 3.2. Route Polyline Layer (`PolylineLayer`)
When a report contains 2 or more notes:
```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: _points, // List of chronological LatLng waypoints
      color: Colors.indigoAccent,
      strokeWidth: 4.5,
      borderColor: Colors.indigo[900],
      borderStrokeWidth: 1.5,
    ),
  ],
)
```
Draws a high-contrast indigo route line connecting waypoints in the order they were recorded.

### 3.3. Route Statistics

#### Geodesic Distance Calculation
In `lib/screens/map_screen.dart`, distance is computed using the Great-Circle (Haversine) formula across all consecutive waypoints:
```dart
double totalMeters = 0.0;
for (int i = 0; i < widget.notes.length - 1; i++) {
  totalMeters += Geolocator.distanceBetween(
    widget.notes[i].latitude,
    widget.notes[i].longitude,
    widget.notes[i + 1].latitude,
    widget.notes[i + 1].longitude,
  );
}
_totalDistanceKm = totalMeters / 1000.0;
```

#### Elapsed Inspection Time
```dart
final diff = widget.notes.last.timestamp.difference(widget.notes.first.timestamp);
final hours = diff.inHours;
final minutes = diff.inMinutes.remainder(60);
_elapsedTimeString = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
```

---

## 4. Visual Location Picker (`LocationPickerScreen`)

When an inspector needs to adjust a waypoint:
1. The map opens centered on the note's current coordinates.
2. Tapping anywhere triggers `onTap: (tapPosition, point)`:
   ```dart
   setState(() {
     _selectedLocation = point;
   });
   ```
3. The marker smoothly updates position with an animated teal ripple indicator.
4. "Confirm Location" pops the navigator and returns the selected `LatLng` object to the note form.
