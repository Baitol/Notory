import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/database.dart';

class MapScreen extends StatefulWidget {
  final String reportTitle;
  final List<Note> notes;

  const MapScreen({
    super.key,
    required this.reportTitle,
    required this.notes,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  late final List<LatLng> _points;
  late final LatLng _center;
  Note? _selectedNote;
  double _totalDistanceKm = 0.0;
  String _elapsedTimeString = '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Map points
    _points = widget.notes.map((n) => LatLng(n.latitude, n.longitude)).toList();

    // Calculate center
    double avgLat = _points.map((p) => p.latitude).reduce((a, b) => a + b) / _points.length;
    double avgLng = _points.map((p) => p.longitude).reduce((a, b) => a + b) / _points.length;
    _center = LatLng(avgLat, avgLng);

    // Calculate distance
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

    // Calculate elapsed time
    if (widget.notes.length > 1) {
      final diff = widget.notes.last.timestamp.difference(widget.notes.first.timestamp);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);
      if (hours > 0) {
        _elapsedTimeString = '${hours}h ${minutes}m';
      } else {
        _elapsedTimeString = '${minutes}m';
      }
    } else {
      _elapsedTimeString = '0m';
    }
  }

  void _resetView() {
    _mapController.move(_center, 13.0);
    setState(() {
      _selectedNote = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.reportTitle} Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong, color: Colors.tealAccent),
            onPressed: _resetView,
            tooltip: 'Center Route',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flutter Map Integration
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              // OpenStreetMap Layer
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.notory.app',
              ),
              // Route Traveled Polyline Layer
              if (_points.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _points,
                      color: Colors.indigoAccent,
                      strokeWidth: 4.5,
                      borderColor: Colors.indigo[900],
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
              // Markers Layer
              MarkerLayer(
                markers: List.generate(widget.notes.length, (index) {
                  final note = widget.notes[index];
                  final point = _points[index];
                  final isSelected = _selectedNote?.id == note.id;

                  return Marker(
                    point: point,
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedNote = note;
                        });
                        _mapController.move(point, 15.0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.tealAccent : Colors.indigoAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isSelected ? Colors.tealAccent : Colors.indigoAccent)
                                  .withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          // Route stats overlay card at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: const Color(0xFF1E293B).withOpacity(0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.alt_route,
                      title: 'Distance',
                      value: '${_totalDistanceKm.toStringAsFixed(2)} km',
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[800]),
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      title: 'Elapsed Time',
                      value: _elapsedTimeString,
                    ),
                    Container(width: 1, height: 30, color: Colors.grey[800]),
                    _buildStatItem(
                      icon: Icons.place,
                      title: 'Waypoints',
                      value: '${widget.notes.length}',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected note details popup overlay at bottom
          if (_selectedNote != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: const Color(0xFF1E293B),
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.tealAccent, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.tealAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Waypoint #${widget.notes.indexOf(_selectedNote!) + 1}',
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat.jm().format(_selectedNote!.timestamp),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedNote!.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const Divider(height: 16, color: Colors.grey),
                      Row(
                        children: [
                          const Icon(Icons.explore_outlined, size: 16, color: Colors.indigoAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Lat: ${_selectedNote!.latitude.toStringAsFixed(5)}, Lng: ${_selectedNote!.longitude.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontFamily: 'monospace',
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedNote = null;
                              });
                            },
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.tealAccent),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
