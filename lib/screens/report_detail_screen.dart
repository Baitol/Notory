import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/database.dart';
import '../services/database_service.dart';
import '../providers/report_provider.dart';
import 'map_screen.dart';
import 'location_picker_screen.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final int reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  bool _isLocating = false;

  // Tracks the last successfully used coordinates so GPS failures
  // can fall back to the most-recent known position instead of a hardcoded mock.
  double? _lastKnownLat;
  double? _lastKnownLng;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Seed last-known coords from the most recent note if we haven't
    // captured a live GPS fix yet.
    if (_lastKnownLat == null) {
      final reportItems = ref.read(reportsProvider);
      final item = reportItems.cast<ReportWithNotes?>().firstWhere(
            (r) => r?.report.id == widget.reportId,
            orElse: () => null,
          );
      if (item != null && item.notes.isNotEmpty) {
        final sorted = item.notes.toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _lastKnownLat = sorted.last.latitude;
        _lastKnownLng = sorted.last.longitude;
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable GPS.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      // Fetch current position with a timeout
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      // Cache for future fallback
      _lastKnownLat = pos.latitude;
      _lastKnownLng = pos.longitude;
      return pos;
    } catch (e) {
      debugPrint('Location error: $e');

      // Build a friendly fallback message
      final bool hasLastKnown = _lastKnownLat != null && _lastKnownLng != null;
      final String fallbackMsg = hasLastKnown
          ? 'GPS unavailable. Using last known position.'
          : 'GPS unavailable. Using default fallback position.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fallbackMsg),
            backgroundColor: Colors.amber[900],
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Prefer last known coords; fall back to a neutral default only if none exist.
      return Position(
        latitude: _lastKnownLat ?? 0.0,
        longitude: _lastKnownLng ?? 0.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  /// Shows a dialog that lets the user manually type in latitude and longitude.
  /// Returns [true] if the user confirmed new values, [false] if cancelled.
  Future<bool> _showManualLocationDialog(
    BuildContext ctx,
    TextEditingController latCtrl,
    TextEditingController lngCtrl,
  ) async {
    final formKey = GlobalKey<FormState>();
    return await showDialog<bool>(
          context: ctx,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.edit_location_alt, color: Colors.tealAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Set Location Manually',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  _coordField(
                    controller: latCtrl,
                    label: 'Latitude',
                    hint: 'e.g. 48.8584',
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < -90 || parsed > 90) return 'Must be between -90 and 90';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _coordField(
                    controller: lngCtrl,
                    label: 'Longitude',
                    hint: 'e.g. 2.2945',
                    validator: (v) {
                      final parsed = double.tryParse(v ?? '');
                      if (parsed == null) return 'Enter a valid number';
                      if (parsed < -180 || parsed > 180) return 'Must be between -180 and 180';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogCtx, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _coordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.tealAccent, fontSize: 13),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.tealAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  void _addNewNote(Report report) async {
    final position = await _getCurrentLocation();
    if (position == null) return;

    if (!mounted) return;

    final noteController = TextEditingController();
    // Mutable location that the user can override manually
    double finalLat = position.latitude;
    double finalLng = position.longitude;
    // These controllers power the manual-entry dialog and are seeded from GPS
    final latController = TextEditingController(text: finalLat.toStringAsFixed(6));
    final lngController = TextEditingController(text: finalLng.toStringAsFixed(6));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(stCtx).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Entry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── Location row ──────────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        final selected = await Navigator.push<LatLng>(
                          stCtx,
                          MaterialPageRoute(
                            builder: (context) => LocationPickerScreen(
                              initialLocation: LatLng(finalLat, finalLng),
                            ),
                          ),
                        );
                        if (selected != null) {
                          setSheetState(() {
                            finalLat = selected.latitude;
                            finalLng = selected.longitude;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.tealAccent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Lat: ${finalLat.toStringAsFixed(5)},  Lng: ${finalLng.toStringAsFixed(5)}',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Map Button
                            GestureDetector(
                              onTap: () async {
                                final selected = await Navigator.push<LatLng>(
                                  stCtx,
                                  MaterialPageRoute(
                                    builder: (context) => LocationPickerScreen(
                                      initialLocation: LatLng(finalLat, finalLng),
                                    ),
                                  ),
                                );
                                if (selected != null) {
                                  setSheetState(() {
                                    finalLat = selected.latitude;
                                    finalLng = selected.longitude;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map, size: 13, color: Colors.tealAccent),
                                    SizedBox(width: 4),
                                    Text(
                                      'Map',
                                      style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Manual Input Button
                            GestureDetector(
                              onTap: () async {
                                latController.text = finalLat.toStringAsFixed(6);
                                lngController.text = finalLng.toStringAsFixed(6);
                                final confirmed = await _showManualLocationDialog(
                                  stCtx,
                                  latController,
                                  lngController,
                                );
                                if (confirmed) {
                                  setSheetState(() {
                                    finalLat = double.parse(latController.text);
                                    finalLng = double.parse(lngController.text);
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 13, color: Colors.tealAccent),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.tealAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Timestamp row
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.indigoAccent),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.jm().format(DateTime.now()),
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ── Note text field ───────────────────────────────────
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        hintText: 'Enter details about this point...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.indigoAccent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[800]!),
                        ),
                      ),
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final text = noteController.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(stCtx).showSnackBar(
                            const SnackBar(content: Text('Note content cannot be empty')),
                          );
                          return;
                        }

                        ref.read(reportsProvider.notifier).addNote(
                              report.id,
                              text,
                              finalLat,
                              finalLng,
                            );

                        // Update last-known cache with what was actually saved
                        _lastKnownLat = finalLat;
                        _lastKnownLng = finalLng;

                        Navigator.pop(stCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Entry'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editNote(Note note) {
    final noteController = TextEditingController(text: note.content);
    double finalLat = note.latitude;
    double finalLng = note.longitude;
    final latController = TextEditingController(text: finalLat.toStringAsFixed(6));
    final lngController = TextEditingController(text: finalLng.toStringAsFixed(6));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(stCtx).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Edit Entry',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ── Location row ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.tealAccent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Lat: ${finalLat.toStringAsFixed(5)},  Lng: ${finalLng.toStringAsFixed(5)}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Map picker button
                          GestureDetector(
                            onTap: () async {
                              final selected = await Navigator.push<LatLng>(
                                stCtx,
                                MaterialPageRoute(
                                  builder: (context) => LocationPickerScreen(
                                    initialLocation: LatLng(finalLat, finalLng),
                                  ),
                                ),
                              );
                              if (selected != null) {
                                setSheetState(() {
                                  finalLat = selected.latitude;
                                  finalLng = selected.longitude;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map, size: 13, color: Colors.tealAccent),
                                  SizedBox(width: 4),
                                  Text(
                                    'Map',
                                    style: TextStyle(
                                      color: Colors.tealAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Manual Input button
                          GestureDetector(
                            onTap: () async {
                              latController.text = finalLat.toStringAsFixed(6);
                              lngController.text = finalLng.toStringAsFixed(6);
                              final confirmed = await _showManualLocationDialog(
                                stCtx,
                                latController,
                                lngController,
                              );
                              if (confirmed) {
                                setSheetState(() {
                                  finalLat = double.parse(latController.text);
                                  finalLng = double.parse(lngController.text);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.tealAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, size: 13, color: Colors.tealAccent),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: Colors.tealAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Timestamp row
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.indigoAccent),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.yMMMd().add_jm().format(note.timestamp),
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.indigoAccent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[800]!),
                        ),
                      ),
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final text = noteController.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(stCtx).showSnackBar(
                            const SnackBar(content: Text('Note content cannot be empty')),
                          );
                          return;
                        }

                        ref.read(reportsProvider.notifier).updateNote(
                              widget.reportId,
                              note,
                              text,
                              finalLat,
                              finalLng,
                            );

                        Navigator.pop(stCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteNote(int noteId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note? It will also remove this waypoint from the route map.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                ref.read(reportsProvider.notifier).deleteNote(widget.reportId, noteId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportItems = ref.watch(reportsProvider);
    final item = reportItems.cast<ReportWithNotes?>().firstWhere(
          (r) => r?.report.id == widget.reportId,
          orElse: () => null,
        );

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Details')),
        body: const Center(child: Text('Report not found.')),
      );
    }

    final report = item.report;
    final sortedNotes = item.notes.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(report.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.map, color: Colors.tealAccent),
                onPressed: sortedNotes.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(
                              reportTitle: report.title,
                              notes: sortedNotes,
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
          // Report Info Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REPORT DETAILS',
                        style: TextStyle(
                          color: Colors.indigoAccent[100],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(report.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (report.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      report.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: sortedNotes.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(
                                        reportTitle: report.title,
                                        notes: sortedNotes,
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.route_outlined),
                          label: const Text('View Route Map'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.tealAccent,
                            disabledForegroundColor: Colors.grey[700],
                            side: BorderSide(
                              color: sortedNotes.isEmpty
                                  ? Colors.grey[800]!
                                  : Colors.tealAccent.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Notes Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.timeline, size: 20, color: Colors.indigoAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Chronological Log',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[300],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${sortedNotes.length} Entries',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chronological Notes List
          sortedNotes.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.location_off_outlined,
                              size: 48, color: Colors.grey[800]),
                          const SizedBox(height: 12),
                          Text(
                            'No Entries Yet',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Add New Entry" below to tag your current location.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = sortedNotes[index];
                      final isFirst = index == 0;
                      final isLast = index == sortedNotes.length - 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline Node & Line
                            Column(
                              children: [
                                Container(
                                  width: 2,
                                  height: isFirst ? 16 : 24,
                                  color: isFirst
                                      ? Colors.transparent
                                      : Colors.indigo.withOpacity(0.5),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.tealAccent,
                                    border: Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.tealAccent.withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: isLast ? 24 : 40,
                                  color: isLast
                                      ? Colors.transparent
                                      : Colors.indigo.withOpacity(0.5),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Note Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExpandableNoteCard(
                                  note: note,
                                  index: index + 1,
                                  onEdit: () => _editNote(note),
                                  onDelete: () => _deleteNote(note.id),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: sortedNotes.length,
                  ),
                ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLocating ? null : () => _addNewNote(report),
        label: _isLocating
            ? const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Getting GPS...'),
                ],
              )
            : const Text('Add New Entry'),
        icon: _isLocating ? null : const Icon(Icons.add_location_alt),
        backgroundColor: _isLocating ? Colors.grey[700] : Colors.tealAccent,
        foregroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}

class _ExpandableNoteCard extends StatefulWidget {
  final Note note;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpandableNoteCard({
    required this.note,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ExpandableNoteCard> createState() => _ExpandableNoteCardState();
}

class _ExpandableNoteCardState extends State<_ExpandableNoteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat.jm().format(widget.note.timestamp);
    final formattedDate = DateFormat.yMMMd().format(widget.note.timestamp);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.indigoAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${widget.index}',
                          style: const TextStyle(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($formattedDate)',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.note.content,
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              if (_isExpanded) ...[
                const Divider(height: 20, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GEOLOCATION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lat: ${widget.note.latitude.toStringAsFixed(6)}\nLng: ${widget.note.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.tealAccent, size: 20),
                          onPressed: widget.onEdit,
                          tooltip: 'Edit Note',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                          onPressed: widget.onDelete,
                          tooltip: 'Delete Note',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
