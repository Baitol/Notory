import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/database.dart';
import '../services/database_service.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('databaseServiceProvider must be overridden in main');
});

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ReportsNotifier extends StateNotifier<List<ReportWithNotes>> {
  final DatabaseService _db;

  ReportsNotifier(this._db) : super([]) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = await _db.getAllReports();
  }

  Future<void> addReport(String title, String description) async {
    await _db.saveReport(
      ReportsCompanion.insert(
        title: title,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
    await loadReports();
  }

  Future<void> updateReport(
      Report report, String newTitle, String newDescription) async {
    await _db.saveReport(
      ReportsCompanion(
        id: Value(report.id),
        title: Value(newTitle),
        description: Value(newDescription),
        createdAt: Value(report.createdAt),
      ),
    );
    await loadReports();
  }

  Future<void> deleteReport(int id) async {
    await _db.deleteReport(id);
    await loadReports();
  }

  Future<void> addNote(
      int reportId, String content, double latitude, double longitude) async {
    await _db.addNoteToReport(
      reportId,
      NotesCompanion.insert(
        content: content,
        timestamp: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
      ),
    );
    await loadReports();
  }

  Future<void> updateNote(int reportId, Note note, String newContent, double latitude, double longitude) async {
    await _db.updateNote(
      NotesCompanion(
        id: Value(note.id),
        content: Value(newContent),
        timestamp: Value(note.timestamp),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    );
    await loadReports();
  }

  Future<void> deleteNote(int reportId, int noteId) async {
    await _db.deleteNote(reportId, noteId);
    await loadReports();
  }
}

// ---------------------------------------------------------------------------
// StateNotifierProvider
// ---------------------------------------------------------------------------

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, List<ReportWithNotes>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ReportsNotifier(db);
});
