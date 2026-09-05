# Управління станом та потік даних (Riverpod) 🔄

У цьому документі детально розглядається архітектура управління станом (State Management) додатку **Notory** на базі бібліотеки **Riverpod 2.x**.

---

## 1. Архітектурні переваги використання Riverpod

- **Compile-Time Safety (Безпека на етапі компіляції)**: на відміну від класичного `Provider`, Riverpod не залежить від дерева `BuildContext`. Провайдери є глобальними константами й не можуть викинути `ProviderNotFoundException`.
- **Просте тестування та мокінг**: будь-який провайдер можна підмінити в тестах за допомогою директиви `overrides: [...]`.
- **Односпрямований потік даних (Unidirectional Data Flow)**: стан передається зверху вниз від моделей до віджетів, а команди модифікації викликаються лише через методи `Notifier`.

---

## 2. Опис провайдерів у `lib/providers/report_provider.dart`

### 2.1. `databaseServiceProvider`
```dart
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('databaseServiceProvider must be overridden in main');
});
```
- Служить контейнером для впровадження залежностей (Dependency Injection).
- Викидає виключення, якщо його випадково спробують використати без ініціалізації у `main.dart`.
- У `main.dart` перевизначається вже готовим екземпляром:
  ```dart
  ProviderScope(
    overrides: [
      databaseServiceProvider.overrideWithValue(dbService),
    ],
    child: const NotoryApp(),
  )
  ```

### 2.2. Клас стану `ReportsNotifier`
```dart
class ReportsNotifier extends StateNotifier<List<ReportWithNotes>> {
  final DatabaseService _db;

  ReportsNotifier(this._db) : super([]) {
    loadReports();
  }
  ...
}
```
- Зберігає поточний стан додатку як незмінний (immutable) список `List<ReportWithNotes>`.
- Початковий стан — порожній список `[]`.
- У момент створення конструктор автоматично запускає метод `loadReports()`, який зчитує всі дані зі сховища SQLite.

### 2.3. `reportsProvider`
```dart
final reportsProvider = StateNotifierProvider<ReportsNotifier, List<ReportWithNotes>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ReportsNotifier(db);
});
```
- Зв'язує `ReportsNotifier` із `databaseServiceProvider`.
- Якщо сервіс бази даних зміниться або перезапуститься, Riverpod автоматично створить новий екземпляр нотифікатора.

---

## 3. Повний цикл оновлення даних (Data Mutation Lifecycle)

Розглянемо покроково, що відбувається, коли користувач створює новий звіт:

```
[ Екран HomeScreen ]
  │
  │ 1. Користувач вводить назву "Ділянка А" і тисне "Create"
  ▼
[ ref.read(reportsProvider.notifier).addReport(...) ]
  │
  │ 2. Нотифікатор викликає метод сервісу
  ▼
[ DatabaseService.saveReport(...) ]
  │
  │ 3. Drift виконує SQL-інструкцію INSERT INTO reports...
  ▼
[ SQLite File (notory.sqlite) ]
  │
  │ 4. Запис зафіксовано на диску
  ▼
[ ReportsNotifier.loadReports() ]
  │
  │ 5. Запит усіх звітів із приєднаними нотатками через SQL JOIN
  ▼
[ state = await _db.getAllReports() ]
  │
  │ 6. Змінній state присвоюється НОВИЙ незмінний список
  ▼
[ Riverpod Framework ]
  │
  │ 7. Сповіщає всіх підписників про зміну посилання на state
  ▼
[ HomeScreen (ref.watch(reportsProvider)) ]
  │
  │ 8. ListView.builder ефективно перемальовується з новою карткою
```

---

## 4. Підписка на стан у віджетах

### Спостереження (`ref.watch`)
Використовується всередині методу `build` віджетів `ConsumerWidget` або `ConsumerStatefulWidget`:
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final reportItems = ref.watch(reportsProvider);
  // Віджет підписаний: будь-яка зміна списку викличе швидкий re-render
}
```

### Виклик дій (`ref.read`)
Використовується в обробниках натискань кнопок (`onPressed`, `onTap`), щоб уникнути зайвих перемалювань:
```dart
ElevatedButton(
  onPressed: () {
    ref.read(reportsProvider.notifier).deleteReport(report.id);
  },
  child: const Text('Delete'),
);
```
