import 'package:drift/drift.dart';
import '../models/database.dart';

/// Convenience data class holding a [Report] and its associated [Note] list.
class ReportWithNotes {
  final Report report;
  final List<Note> notes;

  const ReportWithNotes({required this.report, required this.notes});
}

/// All database operations, replacing the old IsarService.
class DatabaseService {
  final AppDatabase _db;

  DatabaseService(this._db);

  // -------------------------------------------------------------------------
  // Reports
  // -------------------------------------------------------------------------

  /// Returns all reports ordered by newest first, each with its notes loaded.
  Future<List<ReportWithNotes>> getAllReports() async {
    final reports = await (_db.select(_db.reports)
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();

    final result = <ReportWithNotes>[];
    for (final report in reports) {
      final notes = await _getNotesForReport(report.id);
      result.add(ReportWithNotes(report: report, notes: notes));
    }
    return result;
  }

  Future<List<Note>> _getNotesForReport(int reportId) async {
    final query = _db.select(_db.notes).join([
      innerJoin(
        _db.reportNotes,
        _db.reportNotes.noteId.equalsExp(_db.notes.id),
      ),
    ])
      ..where(_db.reportNotes.reportId.equals(reportId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.notes)).toList();
  }

  /// Inserts or updates a report row, returning the assigned id.
  Future<int> saveReport(ReportsCompanion companion) {
    return _db.into(_db.reports).insertOnConflictUpdate(companion);
  }

  /// Deletes a report and all its linked notes (cascades via join table).
  Future<void> deleteReport(int id) async {
    await _db.transaction(() async {
      // Collect note ids linked only to this report.
      final linkedNoteIds = await (_db.select(_db.reportNotes)
            ..where((rn) => rn.reportId.equals(id)))
          .map((rn) => rn.noteId)
          .get();

      // Remove join rows.
      await (_db.delete(_db.reportNotes)
            ..where((rn) => rn.reportId.equals(id)))
          .go();

      // Remove notes that are now orphaned (no longer linked to any report).
      for (final noteId in linkedNoteIds) {
        final stillLinked = await (_db.select(_db.reportNotes)
              ..where((rn) => rn.noteId.equals(noteId)))
            .get();
        if (stillLinked.isEmpty) {
          await (_db.delete(_db.notes)..where((n) => n.id.equals(noteId))).go();
        }
      }

      // Remove the report itself.
      await (_db.delete(_db.reports)..where((r) => r.id.equals(id))).go();
    });
  }

  // -------------------------------------------------------------------------
  // Notes
  // -------------------------------------------------------------------------

  /// Inserts a note and links it to [reportId].
  Future<void> addNoteToReport(int reportId, NotesCompanion noteCompanion) async {
    await _db.transaction(() async {
      final noteId = await _db.into(_db.notes).insert(noteCompanion);
      await _db.into(_db.reportNotes).insert(
            ReportNotesCompanion.insert(reportId: reportId, noteId: noteId),
          );
    });
  }

  /// Updates an existing note row.
  Future<void> updateNote(NotesCompanion companion) async {
    await (_db.update(_db.notes)
          ..where((n) => n.id.equals(companion.id.value)))
        .write(companion);
  }

  /// Removes a note from a report; deletes the note if it becomes orphaned.
  Future<void> deleteNote(int reportId, int noteId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.reportNotes)
            ..where(
              (rn) =>
                  rn.reportId.equals(reportId) & rn.noteId.equals(noteId),
            ))
          .go();

      final stillLinked = await (_db.select(_db.reportNotes)
            ..where((rn) => rn.noteId.equals(noteId)))
          .get();
      if (stillLinked.isEmpty) {
        await (_db.delete(_db.notes)..where((n) => n.id.equals(noteId))).go();
      }
    });
  }
}
