# Повний опис файлів кодової бази Notory 📂

У цьому документі зібрано детальний опис принципу роботи, призначення, внутрішніх класів, методів та логіки взаємодії для **кожного файлу** проєкту Notory.

---

## Таблиця файлів у проєкті

| Файл | Шар / Модуль | Головне призначення |
|---|---|---|
| [`lib/main.dart`](#1-libmaindart) | Bootstrap & App Root | Точка входу, налаштування теми Material 3, DI для Riverpod. |
| [`lib/models/database.dart`](#2-libmodelsdatabasedart) | Data / Drift ORM | Опис таблиць SQLite (`Notes`, `Reports`, `ReportNotes`), конфігурація з'єднання. |
| [`lib/models/database.g.dart`](#3-libmodelsdatabasegdart) | Generated Code | Автогенерований код Drift (класи рядків, супутники компаньйони, DAO). |
| [`lib/services/database_service.dart`](#4-libservicesdatabase_servicedart) | Service Layer | Бізнес-операції з базою, SQL JOIN, транзакції, очищення сирітських нотаток. |
| [`lib/providers/report_provider.dart`](#5-libprovidersreport_providerdart) | State Management | Провайдери Riverpod, клас `ReportsNotifier` для реактивного стану UI. |
| [`lib/screens/home_screen.dart`](#6-libscreenshome_screendart) | Presentation (UI) | Головний екран: список усіх звітів, створення та редагування звітів, видалення. |
| [`lib/screens/report_detail_screen.dart`](#7-libscreensreport_detail_screendart) | Presentation (UI) | Деталі звіту: хронологічна стрічка нотаток, отримання GPS, редагування. |
| [`lib/screens/map_screen.dart`](#8-libscreensmap_screendart) | Presentation (UI) | Інтерактивна мапа OpenStreetMap/ArcGIS, маршрут полілінії, розрахунок дистанції й часу. |
| [`lib/screens/location_picker_screen.dart`](#9-libscreenslocation_picker_screendart) | Presentation (UI) | Інтерактивний вибір координати на мапі з анімацією та кнопкою поточної локації. |
| [`pubspec.yaml`](#10-pubspecyaml) | Project Config | Залежності Flutter, версії бібліотек, налаштування шрифтів та ассетів. |
| [`analysis_options.yaml`](#11-analysis_optionsyaml) | Linter Config | Правила статичного аналізу коду Dart та лінтера `flutter_lints`. |
| [`android/app/build.gradle.kts`](#12-androidappbuildgradlekts) | Android Build Config | Налаштування збірки Android: Gradle 9.1, AGP 9.0, Java 17, applicationId. |
| [`ios/Runner/Info.plist`](#13-iosrunnerinfoplist) | iOS Native Config | Опис дозволів для iOS (зокрема запит доступу до геолокації). |

---

## 1. `lib/main.dart`

### Призначення
Головна точка входу (entry point) додатку Flutter. Відповідає за низькорівневу ініціалізацію платформи, відкриття локальної бази даних, реєстрацію сервісів через `ProviderScope` та визначення глобальної візуальної теми.

### Класи та компоненти
1. **`void main() async`**:
   - `WidgetsFlutterBinding.ensureInitialized()`: обов'язковий виклик для асинхронного доступу до нативних каналів до запуску UI.
   - Створює екземпляр бази `final db = AppDatabase()`.
   - Створює екземпляр сервісу `final dbService = DatabaseService(db)`.
   - Викликає `runApp` з кореневим віджетом `ProviderScope`.
   - Застосовує патерн перевизначення залежності (`overrides: [databaseServiceProvider.overrideWithValue(dbService)]`), щоб усі віджети отримували вже готовий сервіс без повторного створення.

2. **`class NotoryApp extends StatelessWidget`**:
   - Повертає кореневий віджет `MaterialApp`.
   - Встановлює назву додатку (`title: 'Notory'`).
   - Вимикає банер налагодження (`debugShowCheckedModeBanner: false`).
   - Налаштовує темний режим (`themeMode: ThemeMode.dark`).
   - Задає палітру **Material 3**:
     - Колір фону екранів `scaffoldBackgroundColor: Color(0xFF0F172A)` (глибокий синьо-сірий).
     - Колір карток `surface: Color(0xFF1E293B)`.
     - Первинний акцентний колір `Colors.indigoAccent`.
     - Вторинний акцент `Colors.tealAccent`.
   - Встановлює стартовий екран `home: const HomeScreen()`.

---

## 2. `lib/models/database.dart`

### Призначення
Опис схеми локальної реляційної бази даних SQLite засобами бібліотеки **Drift**. Оголошує структуру таблиць, типи колонок, первинні та зовнішні ключі, а також конфігурацію зв'язку з файловою системою пристрою.

### Структури таблиць

1. **`class Notes extends Table`**:
   Таблиця для збереження окремих польових заміток та геоміток:
   - `IntColumn get id => integer().autoIncrement()();` — унікальний ідентифікатор замітки з автоінкрементом.
   - `TextColumn get content => text()();` — текстовий опис замітки.
   - `DateTimeColumn get timestamp => dateTime()();` — точний час фіксації точки.
   - `RealColumn get latitude => real()();` — географічна широта (double).
   - `RealColumn get longitude => real()();` — географічна довгота (double).

2. **`class Reports extends Table`**:
   Таблиця для збереження звітів інспекцій:
   - `IntColumn get id => integer().autoIncrement()();` — первинний ключ звіту.
   - `TextColumn get title => text()();` — назва звіту (наприклад, "Інспекція ділянки №5").
   - `TextColumn get description => text()();` — розширений опис мети або умов інспекції.
   - `DateTimeColumn get createdAt => dateTime()();` — дата та час створення звіту.

3. **`class ReportNotes extends Table`**:
   Проміжна таблиця зв'язку багато-до-багатьох (Many-to-Many):
   - `IntColumn get reportId => integer().references(Reports, #id)();` — зовнішній ключ до таблиці звітів.
   - `IntColumn get noteId => integer().references(Notes, #id)();` — зовнішній ключ до таблиці заміток.
   - `@override Set<Column> get primaryKey => {reportId, noteId};` — складений первинний ключ, що запобігає дублюванню однакових зв'язків.

4. **`class AppDatabase extends _$AppDatabase`**:
   - Анотація `@DriftDatabase(tables: [Notes, Reports, ReportNotes])`.
   - Конструктор `AppDatabase() : super(_openConnection());`.
   - `int get schemaVersion => 1;` — версія схеми для майбутніх міграцій.

5. **`LazyDatabase _openConnection()`**:
   - Знаходить шлях до папки документів додатку: `await getApplicationDocumentsDirectory()`.
   - Формує повний шлях до файлу: `p.join(dbFolder.path, 'notory.sqlite')`.
   - Створює підключення у фоновому потоці через `NativeDatabase.createInBackground(file)`.

---

## 3. `lib/models/database.g.dart`

### Призначення
Автогенерований бібліотекою `drift_dev` файл (результат виконання команди `dart run build_runner build`).

### Що генерується автоматично
- Класи моделей даних: `Note` (з полями `id`, `content`, `timestamp`, `latitude`, `longitude`) та `Report` (`id`, `title`, `description`, `createdAt`).
- Спеціальні класи-компаньйони `NotesCompanion`, `ReportsCompanion`, `ReportNotesCompanion` для безпечного додавання й оновлення записів без ризику помилок типізації `null`.
- Базовий клас `_$AppDatabase` з реалізацією низькорівневих SQL-інструкцій вибірки, вставки, оновлення та видалення.
- Метод серіалізації в JSON та десеріалізації.

> ⚠️ **Важливо**: Цей файл ніколи не редагується вручну. При зміні `database.dart` запускається `dart run build_runner build --delete-conflicting-outputs`.

---

## 4. `lib/services/database_service.dart`

### Призначення
Сервісний шар, що інкапсулює всю бізнес-логіку взаємодії з базою даних. Він захищає UI від складних SQL-конструкцій та гарантує цілісність даних завдяки механізму транзакцій.

### Класи та методи

1. **`class ReportWithNotes`**:
   - DTO (Data Transfer Object) модель, що поєднує об'єкт звіту `final Report report` та пов'язаний список заміток `final List<Note> notes`.

2. **`class DatabaseService`**:
   - `Future<List<ReportWithNotes>> getAllReports()`:
     - Отримує всі звіти, впорядковані за часом створення від найновішого: `orderBy([(r) => OrderingTerm.desc(r.createdAt)])`.
     - Для кожного звіту асинхронно викликає допоміжний метод `_getNotesForReport(report.id)`.
     - Повертає повний агрегований список `ReportWithNotes`.
   - `Future<List<Note>> _getNotesForReport(int reportId)`:
     - Виконує SQL INNER JOIN між таблицею `notes` та `reportNotes`, де `reportNotes.noteId == notes.id` та `reportNotes.reportId == reportId`.
   - `Future<int> saveReport(ReportsCompanion companion)`:
     - Вставляє новий або оновлює існуючий звіт через `insertOnConflictUpdate`.
   - `Future<void> deleteReport(int id)`:
     - Виконується в межах єдиної атомарної транзакції `_db.transaction(...)`.
     - Знаходить ідентифікатори всіх нотаток, які належали цьому звіту.
     - Видаляє рядки з таблиці зв'язків `reportNotes`.
     - **Очищення осиротілих нотаток**: перевіряє, чи нотатка пов'язана з іншими звітами; якщо ні — видаляє її з таблиці `notes`.
     - Видаляє сам звіт з таблиці `reports`.
   - `Future<void> addNoteToReport(int reportId, NotesCompanion noteCompanion)`:
     - У транзакції додає новий запис у `notes`, отримує згенерований `noteId` і створює зв'язок у `reportNotes`.
   - `Future<void> updateNote(NotesCompanion companion)`:
     - Оновлює текст або координати існуючої замітки.
   - `Future<void> deleteNote(int reportId, int noteId)`:
     - Видаляє зв'язок нотатки з конкретним звітом. Якщо нотатка більше ніде не використовується — видаляє її з бази.

---

## 5. `lib/providers/report_provider.dart`

### Призначення
Шар управління станом за допомогою бібліотеки **Riverpod**. Забезпечує реактивний зв'язок між сервісом даних та екранами додатку.

### Компоненти
1. **`final databaseServiceProvider = Provider<DatabaseService>(...)`**:
   - Базовий провайдер сервісу. Викидає `UnimplementedError`, якщо не був перевизначений у `main.dart`.
2. **`class ReportsNotifier extends StateNotifier<List<ReportWithNotes>>`**:
   - Зберігає поточний список усіх звітів у змінній `state`.
   - Конструктор `ReportsNotifier(this._db)` автоматично ініціює первинне завантаження `loadReports()`.
   - Методи-мутатори стану:
     - `loadReports()`: запитує дані з `_db.getAllReports()` і оновлює `state`.
     - `addReport(title, description)`: зберігає звіт та викликає перезавантаження списку.
     - `updateReport(report, newTitle, newDescription)`: оновлює атрибути звіту.
     - `deleteReport(id)`: видаляє звіт і сповіщає підписників.
     - `addNote(reportId, content, latitude, longitude)`: додає нотатку з координатами до звіту.
     - `updateNote(...)`: оновлює вміст або координати замітки.
     - `deleteNote(reportId, noteId)`: видаляє нотатку та оновлює стан.
3. **`final reportsProvider = StateNotifierProvider<ReportsNotifier, List<ReportWithNotes>>`**:
   - Глобальний провайдер, на який підписуються віджети (`ref.watch(reportsProvider)`). При будь-якій зміні `state` інтерфейс автоматично та без затримок перемальовується.

---

## 6. `lib/screens/home_screen.dart`

### Призначення
Головний екран додатку. Відображає список створених звітів, лічильник кількості звітів, кнопку створення нового звіту та контекстні дії редагування/видалення.

### Структура та логіка
1. **`class HomeScreen extends ConsumerWidget`**:
   - У методі `build` виконує підписку на провайдер: `final reportItems = ref.watch(reportsProvider)`.
   - Верхня панель `AppBar`: показує назву 'Notory' та кількість активних звітів (`"3 Reports"`).
   - Тіло екрану `body`:
     - Якщо `reportItems.isEmpty` — показує гарне пусте повідомлення з іконкою теки та текстом підказки.
     - Якщо є звіти — відображає `ListView.builder` зі списком карток `_ReportCard`.
   - Кнопка швидкої дії `FloatingActionButton.extended`: відкриває модальне вікно `_showReportForm` для створення нового звіту.

2. **`void _showReportForm(BuildContext context, WidgetRef ref, [Report? report])`**:
   - Відкриває `showModalBottomSheet` із закругленими краями та полем введення назви й опису.
   - Якщо передано існуючий `report`, відкривається в режимі редагування з заповненими полями.
   - При підтвердженні викликає або `ref.read(reportsProvider.notifier).addReport(...)`, або `updateReport(...)`.

3. **`class _ReportCard extends ConsumerWidget`**:
   - Картка звіту в темному стилі Material 3.
   - Натискання на картку (`InkWell.onTap`) здійснює перехід на детальний екран звіту `ReportDetailScreen(reportId: report.id)`.
   - Відображає:
     - Назву звіту жирним шрифтом.
     - Опис (обрізається до 2 рядків).
     - Час створення через `DateFormat.yMMMd().add_jm()`.
     - Бейдж із кількістю прив'язаних нотаток (наприклад, `5 notes`).
     - Меню з трьома крапками (`PopupMenuButton`) з опціями **Edit** та **Delete** (з вікном підтвердження `_showDeleteConfirm`).

---

## 7. `lib/screens/report_detail_screen.dart`

### Призначення
Центральний робочий екран для проведення інспекції. Відображає хронологічну стрічку нотаток для обраного звіту, керує зчитуванням геопозиції через GPS, надає можливість ручного коригування координат або вибору їх на мапі, а також містить перехід до повноекранної мапи маршруту.

### Ключові механізми

1. **Отримання геолокації (`_getCurrentLocation`)**:
   - Перевіряє, чи увімкнено модуль GPS на пристрої (`isLocationServiceEnabled`).
   - Перевіряє та запитує дозволи на геолокацію (`checkPermission`, `requestPermission`).
   - Зчитує позицію з високою точністю `LocationAccuracy.high` з таймаутом у 10 секунд.
   - **Інтелектуальний Fallback**: якщо GPS недоступний або стався таймаут, додаток не «падає». Він використовує останню успішно зафіксовану точку (`_lastKnownLat`, `_lastKnownLng`) або координати попередньої замітки з показом попереджувального повідомлення у `SnackBar`.

2. **Ручне введення координат (`_showManualLocationDialog`)**:
   - Відображає діалог для ручного введення широти й довготи через текстові поля з валідацією діапазонів (-90..90 для Lat, -180..180 для Lng).

3. **Додавання та редагування замітки (`_addNewNote`, `_editNote`)**:
   - Відкриває `ModalBottomSheet` із попередньо визначеними координатами.
   - Надає дві кнопки швидкої зміни локації:
     - **Map**: відкриває інтерактивний екран `LocationPickerScreen`.
     - **Edit**: відкриває ручний діалог вводу.
   - Поле введення деталей замітки з автоматичним фокусом.
   - При збереженні викликає `ref.read(reportsProvider.notifier).addNote` або `updateNote`.

4. **Візуальна стрічка часу (Timeline View)**:
   - Використовує `CustomScrollView` зі `SliverAppBar` та `SliverList`.
   - Кожна замітка малюється вздовж вертикальної лінії часу з підсвіченими вузлами (вузлові точки маршруту).
   - Віджет `_ExpandableNoteCard`: картка, що розгортається при натисканні (показує точні координати, кнопку редагування та видалення).

---

## 8. `lib/screens/map_screen.dart`

### Призначення
Екран візуалізації маршруту польової інспекції. Показує всі замітки звіту на інтерактивній мапі у вигляді пронумерованих географічних маркерів, сполучених лінією маршруту (полілінією), та обчислює сумарні характеристики походу.

### Алгоритми та функціонал
1. **Підготовка даних у `initState`**:
   - Перетворює список нотаток у масив координат `LatLng`.
   - **Обчислення географічного центру**: знаходить середнє арифметичне широти та довготи всіх точок для початкового центрування камери мапи.
   - **Обчислення загальної дистанції (`_totalDistanceKm`)**: послідовно проходить усі пари сусідніх точок і підсумовує відстань між ними за формулою геодезичної кривини через `Geolocator.distanceBetween(...)`.
   - **Обчислення витраченого часу (`_elapsedTimeString`)**: різниця в часі між першою та останньою заміткою у форматі `Xh Ym`.

2. **Шари мапи `FlutterMap`**:
   - `TileLayer`: завантажує високоякісні супутникові/топографічні тайли ArcGIS World Imagery / OpenStreetMap.
   - `PolylineLayer`: малює синю лінію маршруту завтовшки 4.5 px вздовж усіх точок у хронологічному порядку.
   - `MarkerLayer`: генерує інтерактивні круглі маркери з номерами точок.

3. **Взаємодія**:
   - Натискання на маркер центрує камеру на обраній точці та відкриває інформаційну картку внизу екрану з текстом нотатки та часом.
   - Кнопка центрирування в AppBar повертає масштаб на огляд усього маршруту.

---

## 9. `lib/screens/location_picker_screen.dart`

### Призначення
Спеціалізований екран для візуального вибору або коригування географічних координат на мапі.

### Особливості реалізації
- Приймає початкову координату `initialLocation`.
- Дозволяє користувачу натиснути у будь-якій точці мапи (`onTap: (tapPosition, point)`), миттєво переміщуючи маркер вибору в обране місце.
- Маркер має ефект пульсації (`BoxDecoration` з напівпрозорою бірюзовою аурою).
- Кнопка швидкого визначення GPS (FAB) переміщує маркер до поточного місцезнаходження користувача через `Geolocator.getCurrentPosition`.
- Нижня панель відображає точні обрані координати з точністю до 6 знаків після коми та кнопку **Confirm Location**, яка повертає вибраний об'єкт `LatLng` через `Navigator.pop(context, _selectedLocation)`.

---

## 10. `pubspec.yaml`

### Призначення
Маніфест проєкту Flutter, що визначає метадані додатку, обмеження версій мови Dart та Flutter SDK, а також перелік зовнішніх залежностей.

### Ключові залежності:
- `flutter_riverpod: ^2.5.1` — декларативне управління станом.
- `drift: ^2.20.0` та `sqlite3_flutter_libs: ^0.5.0` — база даних SQLite та нативні C-бібліотеки для iOS/Android.
- `geolocator: ^10.1.0` — доступ до нативного GPS-модуля пристрою.
- `flutter_map: ^6.1.0` та `latlong2: ^0.9.0` — рендеринг тайлових мап та обчислення координат.
- `path_provider: ^2.1.2` — пошук стандартних системних папок на пристрої.
- `intl: ^0.19.0` — форматування дат та часу.
- `build_runner: ^2.4.12` та `drift_dev: ^2.20.0` (у `dev_dependencies`) — інструменти кодогенерації для бази даних.

---

## 11. `analysis_options.yaml`

### Призначення
Конфігурація статичного аналізу вихідного коду. Підключає офіційний набір правил `package:flutter_lints/flutter.yaml`, контролюючи дотримання стандартів чистоти коду, безпеки типів та стилістики оформлення Dart-коду.

---

## 12. `android/app/build.gradle.kts` та `android/settings.gradle.kts`

### Призначення
Скрипти системи автоматизації збірки Android на базі **Gradle Kotlin DSL**.
- Використовує **Gradle 9.1.0** та **Android Gradle Plugin 9.0.1**.
- Задає цільову платформу компіляції: **Java 17** (`sourceCompatibility = JavaVersion.VERSION_17`, `targetCompatibility = JavaVersion.VERSION_17`, `jvmTarget = JVM_17`).
- Встановлює унікальний ідентифікатор пакету `com.notory.notory`.
- Підключає офіційний Flutter Gradle плагін `dev.flutter.flutter-gradle-plugin`.

---

## 13. `ios/Runner/Info.plist`

### Призначення
Конфігураційний файл нативної частини iOS (iOS Property List).
- Містить системні декларації дозволів для Apple App Review та системи безпеки iOS:
  - `NSLocationWhenInUseUsageDescription`: текст, який користувач бачить у системному діалозі при першому запиті доступу до GPS (*"This app requires access to your location to automatically capture where your notes are recorded in the report."*).
  - `NSLocationAlwaysAndWhenInUseUsageDescription`: дозвіл для геопозиціонування під час використання додатку.
- Налаштовує підтримувані орієнтації екрану для iPhone та iPad.
