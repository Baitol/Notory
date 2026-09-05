# Схема та принципи роботи бази даних SQLite (Drift) 🗄️

У цьому документі детально описано організацію збереження даних у додатку **Notory**: схему таблиць, типи даних, зв'язки, транзакційну безпеку та утилізацію видалених записів.

---

## 1. Чому обрано Drift та SQLite?

1. **Повна автономність (Offline-First)**: SQLite зберігає всі дані локально в одному файлі на диску пристрою (`notory.sqlite`).
2. **Типобезпека (Type Safety)**: Drift компілює таблиці Dart у строго типізовані класи. Помилки в назвах колонок або типах виявляються на етапі компіляції, а не під час виконання.
3. **Фонова робота без зависання UI**:
   Підключення налаштовано через ізолят:
   ```dart
   LazyDatabase _openConnection() {
     return LazyDatabase(() async {
       final dbFolder = await getApplicationDocumentsDirectory();
       final file = File(p.join(dbFolder.path, 'notory.sqlite'));
       return NativeDatabase.createInBackground(file);
     });
   }
   ```
   Усі запити до диска виконуються у фоновому потоці операційної системи завдяки бібліотеці `sqlite3_flutter_libs`.

---

## 2. Діаграма сутностей та зв'язків (ER-діаграма)

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

## 3. Опис таблиць

### 3.1. Таблиця `Notes` (Польові замітки)
Зберігає окремі точки польової фіксації з точними географічними координатами:

| Колонка | Тип у Dart | Тип у SQLite | Опис |
|---|---|---|---|
| `id` | `int` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Унікальний номер замітки |
| `content` | `String` | `TEXT` | Текст нотатки, зауваження інспектора |
| `timestamp` | `DateTime` | `INTEGER` (Unix Timestamp) | Дата та точний час фіксації |
| `latitude` | `double` | `REAL` | Географічна широта (-90.0 .. +90.0) |
| `longitude` | `double` | `REAL` | Географічна довгота (-180.0 .. +180.0) |

### 3.2. Таблиця `Reports` (Звіти інспекцій)
Зберігає метадані звітів, що об'єднують серії заміток:

| Колонка | Тип у Dart | Тип у SQLite | Опис |
|---|---|---|---|
| `id` | `int` | `INTEGER PRIMARY KEY AUTOINCREMENT` | Унікальний номер звіту |
| `title` | `String` | `TEXT` | Назва інспекційного звіту |
| `description` | `String` | `TEXT` | Розширений опис або коментар |
| `createdAt` | `DateTime` | `INTEGER` (Unix Timestamp) | Дата та час створення звіту |

### 3.3. Таблиця зв'язку `ReportNotes` (Many-to-Many)
Забезпечує зв'язок між звітами та замітками:

| Колонка | Тип у Dart | Тип у SQLite | Обмеження |
|---|---|---|---|
| `reportId` | `int` | `INTEGER` | Foreign Key -> `Reports(id)` |
| `noteId` | `int` | `INTEGER` | Foreign Key -> `Notes(id)` |

- **Складений первинний ключ**: `@override Set<Column> get primaryKey => {reportId, noteId};`
- Забезпечує цілісність: одна й та сама нотатка не може бути прив'язана до одного звіту двічі.

---

## 4. Логіка бізнес-операцій та очищення «сирітських» записів (Orphan Cleanup)

При видаленні даних важливо не залишати у базі сміттєві рядки, на які ніхто не посилається. Це реалізовано в `DatabaseService`:

### 4.1. Безпечне видалення звіту (`deleteReport`)
Операція виконується всередині транзакції `_db.transaction`:
1. Знаходимо всі `noteId`, прикріплені до цього звіту.
2. Видаляємо зв'язки з таблиці `ReportNotes` для цього `reportId`.
3. Для кожної знайденої нотатки перевіряємо: чи залишилися ще якісь записи в `ReportNotes` з цим `noteId`?
   - Якщо ні (нотатка осиротіла) -> викликається `_db.delete(_db.notes)..where((n) => n.id.equals(noteId))`.
4. Видаляється сам запис із таблиці `Reports`.

### 4.2. Додавання нотатки до звіту (`addNoteToReport`)
Виконується атомарно:
1. Нотатка записується в `Notes`, SQLite повертає згенерований `noteId`.
2. Одразу створюється запис у `ReportNotes` з парою `(reportId, noteId)`.

---

## 5. Генерація коду та оновлення схеми

При будь-якій зміні полів чи таблиць у файлі `lib/models/database.dart`:
```bash
# Одноразове перегенерування
dart run build_runner build --delete-conflicting-outputs

# Або фоновий режим автогенерації при збереженні файлу:
dart run build_runner watch --delete-conflicting-outputs
```
Команда оновить `lib/models/database.g.dart`.
