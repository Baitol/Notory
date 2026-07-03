// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, Note>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$NotesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _contentMeta = const VerificationMeta('content');
@override
late final GeneratedColumn<String> content = GeneratedColumn<String>('content', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _timestampMeta = const VerificationMeta('timestamp');
@override
late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>('timestamp', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _latitudeMeta = const VerificationMeta('latitude');
@override
late final GeneratedColumn<double> latitude = GeneratedColumn<double>('latitude', aliasedName, false, type: DriftSqlType.double, requiredDuringInsert: true);
static const VerificationMeta _longitudeMeta = const VerificationMeta('longitude');
@override
late final GeneratedColumn<double> longitude = GeneratedColumn<double>('longitude', aliasedName, false, type: DriftSqlType.double, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, content, timestamp, latitude, longitude];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'notes';
@override
VerificationContext validateIntegrity(Insertable<Note> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('content')) {
context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));} else if (isInserting) {
context.missing(_contentMeta);
}
if (data.containsKey('timestamp')) {
context.handle(_timestampMeta, timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));} else if (isInserting) {
context.missing(_timestampMeta);
}
if (data.containsKey('latitude')) {
context.handle(_latitudeMeta, latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));} else if (isInserting) {
context.missing(_latitudeMeta);
}
if (data.containsKey('longitude')) {
context.handle(_longitudeMeta, longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));} else if (isInserting) {
context.missing(_longitudeMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Note map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Note(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, content: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}content'])!, timestamp: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!, latitude: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}latitude'])!, longitude: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}longitude'])!, );
}
@override
$NotesTable createAlias(String alias) {
return $NotesTable(attachedDatabase, alias);}}class Note extends DataClass implements Insertable<Note> 
{
final int id;
final String content;
final DateTime timestamp;
final double latitude;
final double longitude;
const Note({required this.id, required this.content, required this.timestamp, required this.latitude, required this.longitude});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['content'] = Variable<String>(content);
map['timestamp'] = Variable<DateTime>(timestamp);
map['latitude'] = Variable<double>(latitude);
map['longitude'] = Variable<double>(longitude);
return map; 
}
NotesCompanion toCompanion(bool nullToAbsent) {
return NotesCompanion(id: Value(id),content: Value(content),timestamp: Value(timestamp),latitude: Value(latitude),longitude: Value(longitude),);
}
factory Note.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Note(id: serializer.fromJson<int>(json['id']),content: serializer.fromJson<String>(json['content']),timestamp: serializer.fromJson<DateTime>(json['timestamp']),latitude: serializer.fromJson<double>(json['latitude']),longitude: serializer.fromJson<double>(json['longitude']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'content': serializer.toJson<String>(content),'timestamp': serializer.toJson<DateTime>(timestamp),'latitude': serializer.toJson<double>(latitude),'longitude': serializer.toJson<double>(longitude),};}Note copyWith({int? id,String? content,DateTime? timestamp,double? latitude,double? longitude}) => Note(id: id ?? this.id,content: content ?? this.content,timestamp: timestamp ?? this.timestamp,latitude: latitude ?? this.latitude,longitude: longitude ?? this.longitude,);Note copyWithCompanion(NotesCompanion data) {
return Note(
id: data.id.present ? data.id.value : this.id,content: data.content.present ? data.content.value : this.content,timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,latitude: data.latitude.present ? data.latitude.value : this.latitude,longitude: data.longitude.present ? data.longitude.value : this.longitude,);
}
@override
String toString() {return (StringBuffer('Note(')..write('id: $id, ')..write('content: $content, ')..write('timestamp: $timestamp, ')..write('latitude: $latitude, ')..write('longitude: $longitude')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, content, timestamp, latitude, longitude);@override
bool operator ==(Object other) => identical(this, other) || (other is Note && other.id == this.id && other.content == this.content && other.timestamp == this.timestamp && other.latitude == this.latitude && other.longitude == this.longitude);
}class NotesCompanion extends UpdateCompanion<Note> {
final Value<int> id;
final Value<String> content;
final Value<DateTime> timestamp;
final Value<double> latitude;
final Value<double> longitude;
const NotesCompanion({this.id = const Value.absent(),this.content = const Value.absent(),this.timestamp = const Value.absent(),this.latitude = const Value.absent(),this.longitude = const Value.absent(),});
NotesCompanion.insert({this.id = const Value.absent(),required String content,required DateTime timestamp,required double latitude,required double longitude,}): content = Value(content), timestamp = Value(timestamp), latitude = Value(latitude), longitude = Value(longitude);
static Insertable<Note> custom({Expression<int>? id, 
Expression<String>? content, 
Expression<DateTime>? timestamp, 
Expression<double>? latitude, 
Expression<double>? longitude, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (content != null)'content': content,if (timestamp != null)'timestamp': timestamp,if (latitude != null)'latitude': latitude,if (longitude != null)'longitude': longitude,});
}NotesCompanion copyWith({Value<int>? id, Value<String>? content, Value<DateTime>? timestamp, Value<double>? latitude, Value<double>? longitude}) {
return NotesCompanion(id: id ?? this.id,content: content ?? this.content,timestamp: timestamp ?? this.timestamp,latitude: latitude ?? this.latitude,longitude: longitude ?? this.longitude,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (content.present) {
map['content'] = Variable<String>(content.value);}
if (timestamp.present) {
map['timestamp'] = Variable<DateTime>(timestamp.value);}
if (latitude.present) {
map['latitude'] = Variable<double>(latitude.value);}
if (longitude.present) {
map['longitude'] = Variable<double>(longitude.value);}
return map; 
}
@override
String toString() {return (StringBuffer('NotesCompanion(')..write('id: $id, ')..write('content: $content, ')..write('timestamp: $timestamp, ')..write('latitude: $latitude, ')..write('longitude: $longitude')..write(')')).toString();}
}
class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$ReportsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
@override
late final GeneratedColumn<String> description = GeneratedColumn<String>('description', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, title, description, createdAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'reports';
@override
VerificationContext validateIntegrity(Insertable<Report> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('description')) {
context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));} else if (isInserting) {
context.missing(_descriptionMeta);
}
if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));} else if (isInserting) {
context.missing(_createdAtMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Report map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Report(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, );
}
@override
$ReportsTable createAlias(String alias) {
return $ReportsTable(attachedDatabase, alias);}}class Report extends DataClass implements Insertable<Report> 
{
final int id;
final String title;
final String description;
final DateTime createdAt;
const Report({required this.id, required this.title, required this.description, required this.createdAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['title'] = Variable<String>(title);
map['description'] = Variable<String>(description);
map['created_at'] = Variable<DateTime>(createdAt);
return map; 
}
ReportsCompanion toCompanion(bool nullToAbsent) {
return ReportsCompanion(id: Value(id),title: Value(title),description: Value(description),createdAt: Value(createdAt),);
}
factory Report.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Report(id: serializer.fromJson<int>(json['id']),title: serializer.fromJson<String>(json['title']),description: serializer.fromJson<String>(json['description']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'title': serializer.toJson<String>(title),'description': serializer.toJson<String>(description),'createdAt': serializer.toJson<DateTime>(createdAt),};}Report copyWith({int? id,String? title,String? description,DateTime? createdAt}) => Report(id: id ?? this.id,title: title ?? this.title,description: description ?? this.description,createdAt: createdAt ?? this.createdAt,);Report copyWithCompanion(ReportsCompanion data) {
return Report(
id: data.id.present ? data.id.value : this.id,title: data.title.present ? data.title.value : this.title,description: data.description.present ? data.description.value : this.description,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,);
}
@override
String toString() {return (StringBuffer('Report(')..write('id: $id, ')..write('title: $title, ')..write('description: $description, ')..write('createdAt: $createdAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, title, description, createdAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Report && other.id == this.id && other.title == this.title && other.description == this.description && other.createdAt == this.createdAt);
}class ReportsCompanion extends UpdateCompanion<Report> {
final Value<int> id;
final Value<String> title;
final Value<String> description;
final Value<DateTime> createdAt;
const ReportsCompanion({this.id = const Value.absent(),this.title = const Value.absent(),this.description = const Value.absent(),this.createdAt = const Value.absent(),});
ReportsCompanion.insert({this.id = const Value.absent(),required String title,required String description,required DateTime createdAt,}): title = Value(title), description = Value(description), createdAt = Value(createdAt);
static Insertable<Report> custom({Expression<int>? id, 
Expression<String>? title, 
Expression<String>? description, 
Expression<DateTime>? createdAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (title != null)'title': title,if (description != null)'description': description,if (createdAt != null)'created_at': createdAt,});
}ReportsCompanion copyWith({Value<int>? id, Value<String>? title, Value<String>? description, Value<DateTime>? createdAt}) {
return ReportsCompanion(id: id ?? this.id,title: title ?? this.title,description: description ?? this.description,createdAt: createdAt ?? this.createdAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (description.present) {
map['description'] = Variable<String>(description.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('ReportsCompanion(')..write('id: $id, ')..write('title: $title, ')..write('description: $description, ')..write('createdAt: $createdAt')..write(')')).toString();}
}
class $ReportNotesTable extends ReportNotes with TableInfo<$ReportNotesTable, ReportNote>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$ReportNotesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _reportIdMeta = const VerificationMeta('reportId');
@override
late final GeneratedColumn<int> reportId = GeneratedColumn<int>('report_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES reports (id)'));
static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
@override
late final GeneratedColumn<int> noteId = GeneratedColumn<int>('note_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES notes (id)'));
@override
List<GeneratedColumn> get $columns => [reportId, noteId];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'report_notes';
@override
VerificationContext validateIntegrity(Insertable<ReportNote> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('report_id')) {
context.handle(_reportIdMeta, reportId.isAcceptableOrUnknown(data['report_id']!, _reportIdMeta));} else if (isInserting) {
context.missing(_reportIdMeta);
}
if (data.containsKey('note_id')) {
context.handle(_noteIdMeta, noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta));} else if (isInserting) {
context.missing(_noteIdMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {reportId, noteId};
@override ReportNote map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return ReportNote(reportId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}report_id'])!, noteId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}note_id'])!, );
}
@override
$ReportNotesTable createAlias(String alias) {
return $ReportNotesTable(attachedDatabase, alias);}}class ReportNote extends DataClass implements Insertable<ReportNote> 
{
final int reportId;
final int noteId;
const ReportNote({required this.reportId, required this.noteId});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['report_id'] = Variable<int>(reportId);
map['note_id'] = Variable<int>(noteId);
return map; 
}
ReportNotesCompanion toCompanion(bool nullToAbsent) {
return ReportNotesCompanion(reportId: Value(reportId),noteId: Value(noteId),);
}
factory ReportNote.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return ReportNote(reportId: serializer.fromJson<int>(json['reportId']),noteId: serializer.fromJson<int>(json['noteId']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'reportId': serializer.toJson<int>(reportId),'noteId': serializer.toJson<int>(noteId),};}ReportNote copyWith({int? reportId,int? noteId}) => ReportNote(reportId: reportId ?? this.reportId,noteId: noteId ?? this.noteId,);ReportNote copyWithCompanion(ReportNotesCompanion data) {
return ReportNote(
reportId: data.reportId.present ? data.reportId.value : this.reportId,noteId: data.noteId.present ? data.noteId.value : this.noteId,);
}
@override
String toString() {return (StringBuffer('ReportNote(')..write('reportId: $reportId, ')..write('noteId: $noteId')..write(')')).toString();}
@override
 int get hashCode => Object.hash(reportId, noteId);@override
bool operator ==(Object other) => identical(this, other) || (other is ReportNote && other.reportId == this.reportId && other.noteId == this.noteId);
}class ReportNotesCompanion extends UpdateCompanion<ReportNote> {
final Value<int> reportId;
final Value<int> noteId;
final Value<int> rowid;
const ReportNotesCompanion({this.reportId = const Value.absent(),this.noteId = const Value.absent(),this.rowid = const Value.absent(),});
ReportNotesCompanion.insert({required int reportId,required int noteId,this.rowid = const Value.absent(),}): reportId = Value(reportId), noteId = Value(noteId);
static Insertable<ReportNote> custom({Expression<int>? reportId, 
Expression<int>? noteId, 
Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (reportId != null)'report_id': reportId,if (noteId != null)'note_id': noteId,if (rowid != null)'rowid': rowid,});
}ReportNotesCompanion copyWith({Value<int>? reportId, Value<int>? noteId, Value<int>? rowid}) {
return ReportNotesCompanion(reportId: reportId ?? this.reportId,noteId: noteId ?? this.noteId,rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (reportId.present) {
map['report_id'] = Variable<int>(reportId.value);}
if (noteId.present) {
map['note_id'] = Variable<int>(noteId.value);}
if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('ReportNotesCompanion(')..write('reportId: $reportId, ')..write('noteId: $noteId, ')..write('rowid: $rowid')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $NotesTable notes = $NotesTable(this);
late final $ReportsTable reports = $ReportsTable(this);
late final $ReportNotesTable reportNotes = $ReportNotesTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [notes, reports, reportNotes];
}
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({Value<int> id,required String content,required DateTime timestamp,required double latitude,required double longitude,});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({Value<int> id,Value<String> content,Value<DateTime> timestamp,Value<double> latitude,Value<double> longitude,});
      final class $$NotesTableReferences extends BaseReferences<
        _$AppDatabase,
        $NotesTable,
        Note> {
        $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);
        
                  
                  static MultiTypedResultKey<
          $ReportNotesTable,
          List<ReportNote>
        > _reportNotesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(
          db.reportNotes, 
          aliasName: $_aliasNameGenerator(
            db.notes.id,
            db.reportNotes.noteId)
        );

          $$ReportNotesTableProcessedTableManager get reportNotesRefs {
        final manager = $$ReportNotesTableTableManager(
            $_db, $_db.reportNotes
            ).filter(
              (f) => f.noteId.id(
              $_item.id
            )
          );

          final cache = $_typedResult.readTableOrNull(_reportNotesRefsTable($_db));
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));


        }
        

      }class $$NotesTableFilterComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude,
      builder: (column) => 
      ColumnFilters(column));
      
        Expression<bool> reportNotesRefs(
          Expression<bool> Function( $$ReportNotesTableFilterComposer f) f
        ) {
                final $$ReportNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportNotes,
      getReferencedColumn: (t) => t.noteId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportNotesTableFilterComposer(
              $db: $db,
              $table: $db.reportNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$NotesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$NotesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp,
      builder: (column) => column);
      
GeneratedColumn<double> get latitude => $composableBuilder(
      column: $table.latitude,
      builder: (column) => column);
      
GeneratedColumn<double> get longitude => $composableBuilder(
      column: $table.longitude,
      builder: (column) => column);
      
        Expression<T> reportNotesRefs<T extends Object>(
          Expression<T> Function( $$ReportNotesTableAnnotationComposer a) f
        ) {
                final $$ReportNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportNotes,
      getReferencedColumn: (t) => t.noteId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportNotesTableAnnotationComposer(
              $db: $db,
              $table: $db.reportNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$NotesTableTableManager extends RootTableManager    <_$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note,$$NotesTableReferences),
    Note,
    PrefetchHooks Function({bool reportNotesRefs})
    > {
    $$NotesTableTableManager(_$AppDatabase db, $NotesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$NotesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$NotesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$NotesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> content = const Value.absent(),Value<DateTime> timestamp = const Value.absent(),Value<double> latitude = const Value.absent(),Value<double> longitude = const Value.absent(),})=> NotesCompanion(id: id,content: content,timestamp: timestamp,latitude: latitude,longitude: longitude,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String content,required DateTime timestamp,required double latitude,required double longitude,})=> NotesCompanion.insert(id: id,content: content,timestamp: timestamp,latitude: latitude,longitude: longitude,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$NotesTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({reportNotesRefs = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             if (reportNotesRefs) db.reportNotes
            ],
            addJoins: null,
            getPrefetchedDataCallback: (items) async {
            return [
                      if (reportNotesRefs) await $_getPrefetchedData(
                  currentTable: table,
                  referencedTable:
                      $$NotesTableReferences._reportNotesRefsTable(db),
                  managerFromTypedResult: (p0) =>
                      $$NotesTableReferences(db, table, p0).reportNotesRefs,
                  referencedItemsForCurrentItem: (item, referencedItems) =>
                      referencedItems.where((e) => e.noteId == item.id),
                  typedResults: items)
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$NotesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note,$$NotesTableReferences),
    Note,
    PrefetchHooks Function({bool reportNotesRefs})
    >;typedef $$ReportsTableCreateCompanionBuilder = ReportsCompanion Function({Value<int> id,required String title,required String description,required DateTime createdAt,});
typedef $$ReportsTableUpdateCompanionBuilder = ReportsCompanion Function({Value<int> id,Value<String> title,Value<String> description,Value<DateTime> createdAt,});
      final class $$ReportsTableReferences extends BaseReferences<
        _$AppDatabase,
        $ReportsTable,
        Report> {
        $$ReportsTableReferences(super.$_db, super.$_table, super.$_typedResult);
        
                  
                  static MultiTypedResultKey<
          $ReportNotesTable,
          List<ReportNote>
        > _reportNotesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(
          db.reportNotes, 
          aliasName: $_aliasNameGenerator(
            db.reports.id,
            db.reportNotes.reportId)
        );

          $$ReportNotesTableProcessedTableManager get reportNotesRefs {
        final manager = $$ReportNotesTableTableManager(
            $_db, $_db.reportNotes
            ).filter(
              (f) => f.reportId.id(
              $_item.id
            )
          );

          final cache = $_typedResult.readTableOrNull(_reportNotesRefsTable($_db));
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));


        }
        

      }class $$ReportsTableFilterComposer extends Composer<
        _$AppDatabase,
        $ReportsTable> {
        $$ReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get description => $composableBuilder(
      column: $table.description,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
        Expression<bool> reportNotesRefs(
          Expression<bool> Function( $$ReportNotesTableFilterComposer f) f
        ) {
                final $$ReportNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportNotes,
      getReferencedColumn: (t) => t.reportId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportNotesTableFilterComposer(
              $db: $db,
              $table: $db.reportNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$ReportsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $ReportsTable> {
        $$ReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$ReportsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $ReportsTable> {
        $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
        Expression<T> reportNotesRefs<T extends Object>(
          Expression<T> Function( $$ReportNotesTableAnnotationComposer a) f
        ) {
                final $$ReportNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reportNotes,
      getReferencedColumn: (t) => t.reportId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportNotesTableAnnotationComposer(
              $db: $db,
              $table: $db.reportNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$ReportsTableTableManager extends RootTableManager    <_$AppDatabase,
    $ReportsTable,
    Report,
    $$ReportsTableFilterComposer,
    $$ReportsTableOrderingComposer,
    $$ReportsTableAnnotationComposer,
    $$ReportsTableCreateCompanionBuilder,
    $$ReportsTableUpdateCompanionBuilder,
    (Report,$$ReportsTableReferences),
    Report,
    PrefetchHooks Function({bool reportNotesRefs})
    > {
    $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$ReportsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$ReportsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$ReportsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> title = const Value.absent(),Value<String> description = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),})=> ReportsCompanion(id: id,title: title,description: description,createdAt: createdAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String title,required String description,required DateTime createdAt,})=> ReportsCompanion.insert(id: id,title: title,description: description,createdAt: createdAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$ReportsTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({reportNotesRefs = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             if (reportNotesRefs) db.reportNotes
            ],
            addJoins: null,
            getPrefetchedDataCallback: (items) async {
            return [
                      if (reportNotesRefs) await $_getPrefetchedData(
                  currentTable: table,
                  referencedTable:
                      $$ReportsTableReferences._reportNotesRefsTable(db),
                  managerFromTypedResult: (p0) =>
                      $$ReportsTableReferences(db, table, p0).reportNotesRefs,
                  referencedItemsForCurrentItem: (item, referencedItems) =>
                      referencedItems.where((e) => e.reportId == item.id),
                  typedResults: items)
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$ReportsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $ReportsTable,
    Report,
    $$ReportsTableFilterComposer,
    $$ReportsTableOrderingComposer,
    $$ReportsTableAnnotationComposer,
    $$ReportsTableCreateCompanionBuilder,
    $$ReportsTableUpdateCompanionBuilder,
    (Report,$$ReportsTableReferences),
    Report,
    PrefetchHooks Function({bool reportNotesRefs})
    >;typedef $$ReportNotesTableCreateCompanionBuilder = ReportNotesCompanion Function({required int reportId,required int noteId,Value<int> rowid,});
typedef $$ReportNotesTableUpdateCompanionBuilder = ReportNotesCompanion Function({Value<int> reportId,Value<int> noteId,Value<int> rowid,});
      final class $$ReportNotesTableReferences extends BaseReferences<
        _$AppDatabase,
        $ReportNotesTable,
        ReportNote> {
        $$ReportNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);
        
                          static $ReportsTable _reportIdTable(_$AppDatabase db) => 
            db.reports.createAlias($_aliasNameGenerator(
            db.reportNotes.reportId,
            db.reports.id));
          

        $$ReportsTableProcessedTableManager? get reportId {
          if ($_item.reportId == null) return null;
          final manager = $$ReportsTableTableManager($_db, $_db.reports).filter((f) => f.id($_item.reportId!));
          final item = $_typedResult.readTableOrNull(_reportIdTable($_db));
          if (item == null) return manager;
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
        }

                  static $NotesTable _noteIdTable(_$AppDatabase db) => 
            db.notes.createAlias($_aliasNameGenerator(
            db.reportNotes.noteId,
            db.notes.id));
          

        $$NotesTableProcessedTableManager? get noteId {
          if ($_item.noteId == null) return null;
          final manager = $$NotesTableTableManager($_db, $_db.notes).filter((f) => f.id($_item.noteId!));
          final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
          if (item == null) return manager;
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
        }


      }class $$ReportNotesTableFilterComposer extends Composer<
        _$AppDatabase,
        $ReportNotesTable> {
        $$ReportNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
                  $$ReportsTableFilterComposer get reportId {
                final $$ReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportsTableFilterComposer(
              $db: $db,
              $table: $db.reports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        $$NotesTableFilterComposer get noteId {
                final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$ReportNotesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $ReportNotesTable> {
        $$ReportNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
                  $$ReportsTableOrderingComposer get reportId {
                final $$ReportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportsTableOrderingComposer(
              $db: $db,
              $table: $db.reports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        $$NotesTableOrderingComposer get noteId {
                final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$NotesTableOrderingComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$ReportNotesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $ReportNotesTable> {
        $$ReportNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
                  $$ReportsTableAnnotationComposer get reportId {
                final $$ReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reportId,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$ReportsTableAnnotationComposer(
              $db: $db,
              $table: $db.reports,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        $$NotesTableAnnotationComposer get noteId {
                final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) => 
      $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$ReportNotesTableTableManager extends RootTableManager    <_$AppDatabase,
    $ReportNotesTable,
    ReportNote,
    $$ReportNotesTableFilterComposer,
    $$ReportNotesTableOrderingComposer,
    $$ReportNotesTableAnnotationComposer,
    $$ReportNotesTableCreateCompanionBuilder,
    $$ReportNotesTableUpdateCompanionBuilder,
    (ReportNote,$$ReportNotesTableReferences),
    ReportNote,
    PrefetchHooks Function({bool reportId,bool noteId})
    > {
    $$ReportNotesTableTableManager(_$AppDatabase db, $ReportNotesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$ReportNotesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$ReportNotesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$ReportNotesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> reportId = const Value.absent(),Value<int> noteId = const Value.absent(),Value<int> rowid = const Value.absent(),})=> ReportNotesCompanion(reportId: reportId,noteId: noteId,rowid: rowid,),
        createCompanionCallback: ({required int reportId,required int noteId,Value<int> rowid = const Value.absent(),})=> ReportNotesCompanion.insert(reportId: reportId,noteId: noteId,rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$ReportNotesTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({reportId = false,noteId = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             
            ],
            addJoins: <T extends TableManagerState<dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic>>(state) {

                                  if (reportId){
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.reportId,
                    referencedTable:
                        $$ReportNotesTableReferences._reportIdTable(db),
                    referencedColumn:
                        $$ReportNotesTableReferences._reportIdTable(db).id,
                  ) as T;
               }
                  if (noteId){
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.noteId,
                    referencedTable:
                        $$ReportNotesTableReferences._noteIdTable(db),
                    referencedColumn:
                        $$ReportNotesTableReferences._noteIdTable(db).id,
                  ) as T;
               }

                return state;
              }
,
            getPrefetchedDataCallback: (items) async {
            return [
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$ReportNotesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $ReportNotesTable,
    ReportNote,
    $$ReportNotesTableFilterComposer,
    $$ReportNotesTableOrderingComposer,
    $$ReportNotesTableAnnotationComposer,
    $$ReportNotesTableCreateCompanionBuilder,
    $$ReportNotesTableUpdateCompanionBuilder,
    (ReportNote,$$ReportNotesTableReferences),
    ReportNote,
    PrefetchHooks Function({bool reportId,bool noteId})
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$NotesTableTableManager get notes => $$NotesTableTableManager(_db, _db.notes);
$$ReportsTableTableManager get reports => $$ReportsTableTableManager(_db, _db.reports);
$$ReportNotesTableTableManager get reportNotes => $$ReportNotesTableTableManager(_db, _db.reportNotes);
}
