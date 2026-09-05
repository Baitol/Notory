# Мапи та геолокація в Notory 🗺️📍

У цьому документі розкрито принципи роботи з супутниковою навігацією (GPS), обробкою дозволів операційної системи, відмовостійкістю до збоїв сигналу та рендерингом інтерактивних мап.

---

## 1. Робота з геопозицією (Пакет `geolocator`)

### 1.1. Життєвий цикл перевірки дозволів
Перед спробою отримати координати додаток виконує 3-етапну перевірку в методі `_getCurrentLocation()`:

```dart
// 1. Чи взагалі ввімкнено GPS-модуль у налаштуваннях пристрою?
bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
if (!serviceEnabled) {
  throw 'Location services are disabled. Please enable GPS.';
}

// 2. Чи надано додатку дозвіл?
LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  // Запит системного діалогового вікна дозволів
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw 'Location permission denied.';
  }
}

// 3. Чи не заборонено доступ назавжди (у налаштуваннях ОС)?
if (permission == LocationPermission.deniedForever) {
  throw 'Location permissions are permanently denied.';
}
```

### 1.2. Отримання точних координат
```dart
final pos = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  timeLimit: const Duration(seconds: 10),
);
```
- `LocationAccuracy.high` змушує пристрій використовувати супутники GPS (а не лише вежі стільникового зв'язку чи Wi-Fi).
- `timeLimit: Duration(seconds: 10)` запобігає «вічному зависанню» інтерфейсу в підземних приміщеннях або залізобетонних будівлях без сигналу.

---

## 2. Інтелектуальний захист від збоїв (Fallback Mechanism)

У симуляторах розробника або при втраті сигналу супутників звичайний додаток завершився б аварійно (викинув необроблене виключення). У Notory реалізовано багаторівневий Fallback:

1. **Кешування останньої відомої точки (`_lastKnownLat`, `_lastKnownLng`)**:
   - При кожному успішному отриманні GPS або додаванні нової замітки поточні координати зберігаються у змінних екземпляра віджета.
   - При відкритті звіту `didChangeDependencies` знаходить найсвіжішу нотатку та ініціалізує останні координати з неї.
2. **М'яка обробка помилок**:
   - Якщо GPS викидає виключення (таймаут або відмова в дозволі), блок `catch` показує користувачу інформативний жовтий `SnackBar`:
     `"GPS unavailable. Using last known position."`
   - Функція повертає об'єкт `Position` з останніми відомими координатами, дозволяючи користувачеві продовжити опис нотатки без втрати даних.
3. **Ручне коригування**:
   - Користувач у будь-який момент може натиснути кнопку **Map** або **Edit** у вікні замітки та вказати точку самостійно.

---

## 3. Інтерактивна мапа (Пакет `flutter_map` та `latlong2`)

Мапа у Notory реалізована за допомогою **FlutterMap** на базі відкритого рушія OpenStreetMap / Leaflet:

### 3.1. Джерело тайлів (TileLayer)
```dart
TileLayer(
  urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  userAgentPackageName: 'com.notory.app',
)
```
Використовує супутникові тайли високої роздільної здатності ArcGIS World Imagery з підтримкою кешування фрагментів мапи.

### 3.2. Побудова лінії маршруту (PolylineLayer)
Коли звіт містить 2 або більше нотаток:
```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: _points, // список точок LatLng у хронологічному порядку
      color: Colors.indigoAccent,
      strokeWidth: 4.5,
      borderColor: Colors.indigo[900],
      borderStrokeWidth: 1.5,
    ),
  ],
)
```
Мапа малює контрастну лінію маршруту, що з'єднує замітки у хронологічному порядку їх створення.

### 3.3. Розрахунок польових показників (Статистика)

#### Розрахунок сумарної дистанції маршруту
У файлі `lib/screens/map_screen.dart` обчислюється точна відстань між точками вздовж лінії маршруту з урахуванням кривини Землі:
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

#### Розрахунок тривалості інспекції
```dart
final diff = widget.notes.last.timestamp.difference(widget.notes.first.timestamp);
final hours = diff.inHours;
final minutes = diff.inMinutes.remainder(60);
_elapsedTimeString = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
```

---

## 4. Екран візуального вибору локації (`LocationPickerScreen`)

Коли інспектору потрібно відкоригувати точку або поставити замітку не там, де він стоїть, а на об'єкті попереду:
1. Карта відкривається за поточними координатами.
2. При натисканні на будь-яку ділянку мапи спрацьовує обробник `onTap: (tapPosition, point)`:
   ```dart
   setState(() {
     _selectedLocation = point;
   });
   ```
3. Маркер вибору миттєво переміщується на нову позицію.
4. Кнопка «Confirm Location» повертає обраний об'єкт `LatLng` через системний навігатор.
