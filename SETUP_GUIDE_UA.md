# Notory — Повний посібник зі встановлення та запуску (Mac та Windows PC)

Цей посібник містить вичерпні покрокові інструкції для встановлення, налаштування, збірки та запуску проєкту **Notory** з нуля. Інструкція розрахована на ситуацію, коли ви починаєте з **абсолютно «чистого» Mac або ПК без будь-якого попередньо встановленого програмного забезпечення для розробників, пакетних менеджерів чи SDK**.

---

## Зміст
1. [Огляд проєкту та архітектура](#1-огляд-проєкту-та-архітектура)
2. [Зведена таблиця вимог та версій](#2-зведена-таблиця-вимог-та-версій)
3. [Інструкція для Mac (З нуля на чистому комп'ютері)](#3-інструкція-для-mac-з-нуля-на-чистому-компютері)
   - [Крок 3.1: Термінал та архітектура процесора](#крок-31-термінал-та-архітектура-процесора)
   - [Крок 3.2: Встановлення Apple Command Line Tools](#крок-32-встановлення-apple-command-line-tools)
   - [Крок 3.3: Встановлення Rosetta 2 (тільки для Apple Silicon)](#крок-33-встановлення-rosetta-2-тільки-для-apple-silicon)
   - [Крок 3.4: Встановлення Homebrew (пакетний менеджер)](#крок-34-встановлення-homebrew-пакетний-менеджер)
   - [Крок 3.5: Встановлення та налаштування Git](#крок-35-встановлення-та-налаштування-git)
   - [Крок 3.6: Встановлення Flutter SDK та налаштування змінних оточення](#крок-36-встановлення-flutter-sdk-та-налаштування-змінних-оточення)
   - [Крок 3.7: Налаштування iOS Toolchain (Xcode та симулятор)](#крок-37-налаштування-ios-toolchain-xcode-та-симулятор)
   - [Крок 3.8: Встановлення CocoaPods](#крок-38-встановлення-cocoapods)
   - [Крок 3.9: Встановлення JDK 17 та Android Studio (для Android на Mac)](#крок-39-встановлення-jdk-17-та-android-studio-для-android-на-mac)
   - [Крок 3.10: Встановлення редактора коду (VS Code)](#крок-310-встановлення-редактора-коду-vs-code)
   - [Крок 3.11: Перевірка системи через `flutter doctor`](#крок-311-перевірка-системи-через-flutter-doctor)
   - [Крок 3.12: Клонування, генерація коду та запуск Notory на Mac](#крок-312-клонування-генерація-коду-та-запуск-notory-на-mac)
4. [Інструкція для PC (Windows 10 / 11) з нуля](#4-інструкція-для-pc-windows-10--11-з-нуля)
   - [Крок 4.1: Налаштування PowerShell та пакетного менеджера](#крок-41-налаштування-powershell-та-пакетного-менеджера)
   - [Крок 4.2: Встановлення Git для Windows](#крок-42-встановлення-git-для-windows)
   - [Крок 4.3: Встановлення Java Development Kit (JDK 17)](#крок-43-встановлення-java-development-kit-jdk-17)
   - [Крок 4.4: Встановлення Flutter SDK та налаштування PATH](#крок-44-встановлення-flutter-sdk-та-налаштування-path)
   - [Крок 4.5: Встановлення та налаштування Android Studio та SDK](#крок-45-встановлення-та-налаштування-android-studio-та-sdk)
   - [Крок 4.6: Прийняття ліцензій Android та створення емулятора (AVD)](#крок-46-прийняття-ліцензій-android-та-створення-емулятора-avd)
   - [Крок 4.7: Встановлення редактора коду (VS Code)](#крок-47-встановлення-редактора-коду-vs-code)
   - [Крок 4.8: Перевірка системи через `flutter doctor`](#крок-48-перевірка-системи-через-flutter-doctor)
   - [Крок 4.9: Клонування, збірка та запуск Notory на PC](#крок-49-клонування-збірка-та-запуск-notory-на-pc)
5. [Важливі особливості проєкту та емуляція функцій](#5-важливі-особливості-проєкту-та-емуляція-функцій)
   - [Симуляція GPS / Геолокації в симуляторах](#симуляція-gps--геолокації-в-симуляторах)
   - [Локальна база даних SQLite та генерація коду Drift](#локальна-база-даних-sqlite-та-генерація-коду-drift)
6. [Вирішення типових проблем (Troubleshooting)](#6-вирішення-типових-проблем-troubleshooting)

---

## 1. Огляд проєкту та архітектура

**Notory** — це кросплатформний мобільний та веб-додаток для польових інспекцій, створення звітів та фіксації заміток із точною геоприв'язкою.

- **Фреймворк**: Flutter (Dart 3.x, Flutter 3.38+)
- **Управління станом**: `flutter_riverpod` (v2.5.1)
- **Локальна база даних**: `drift` (v2.20.0) + `sqlite3_flutter_libs`
- **Мапи та геолокація**: `geolocator` (v10.1.0), `flutter_map` (v6.1.0) з OpenStreetMap, `latlong2`
- **Android Toolchain**: Android Gradle Plugin 9.0.1, Gradle 9.1.0, Kotlin 2.3.20, Java 17 Target

---

## 2. Зведена таблиця вимог та версій

| Компонент | Рекомендована версія | Для чого потрібен |
|---|---|---|
| **ОС (Mac)** | macOS Sonoma 14+ або Sequoia 15+ | Розробка під iOS та Android |
| **ОС (PC)** | Windows 10 (64-bit) / Windows 11 | Розробка під Android та Web |
| **Flutter SDK** | `>= 3.38.4` (Dart `>= 3.12.2`) | Основний фреймворк проєкту |
| **JDK (Java)** | **OpenJDK 17** | **Обов'язково**: Gradle 9.1 вимагає саме Java 17 |
| **Xcode** *(тільки Mac)* | Xcode 15+ (з Mac App Store) | Збірка під симулятор iOS та iPhone |
| **CocoaPods** *(тільки Mac)* | 1.14+ | Менеджер нативних залежностей iOS |
| **Android Studio** | Остання стабільна версія | Android SDK, Command-line Tools, емулятори |
| **VS Code** | Остання стабільна версія | Рекомендований редактор з плагінами Flutter/Dart |

---

## 3. Інструкція для Mac (З нуля на чистому комп'ютері)

Уявіть, що ви щойно дістали новенький Mac із коробки. Перед вами стандартний робочий стіл macOS. Виконуйте кроки послідовно.

### Крок 3.1: Термінал та архітектура процесора
1. Натисніть `Cmd + Пробіл`, введіть **Terminal** і натисніть `Enter`.
2. Перевірте архітектуру вашого Mac:
   ```bash
   uname -m
   ```
   - Якщо вивело `arm64` — це **Apple Silicon** (M1 / M2 / M3 / M4).
   - Якщо вивело `x86_64` — це процесор **Intel**.

---

### Крок 3.2: Встановлення Apple Command Line Tools
macOS потребує базових інструментів компіляції Apple (clang, make, системний git):
1. У терміналі виконайте:
   ```bash
   xcode-select --install
   ```
2. З'явиться графічне вікно: *«The xcode-select command requires the command line developer tools. Would you like to install the tools now?»*.
3. Натисніть **Install**, прийміть умови ліцензії та дочекайтеся завершення завантаження (займає ~2-5 хвилин).
4. Перевірте результат:
   ```bash
   xcode-select -p
   # Повинно повернути: /Library/Developer/CommandLineTools (або шлях до Xcode)
   ```

---

### Крок 3.3: Встановлення Rosetta 2 (тільки для Apple Silicon)
Якщо на кроці 3.1 ви отримали `arm64`, деякі компоненти емуляторів та утиліт Android потребують середовища трансляції Rosetta:
```bash
softwareupdate --install-rosetta --agree-to-license
```

---

### Крок 3.4: Встановлення Homebrew (пакетний менеджер)
Homebrew — це стандартний менеджер пакетів для macOS, необхідний для встановлення утиліт розробника.
1. Запустіть офіційний скрипт встановлення Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Під час встановлення система попросить ввести пароль користувача Mac. Введіть його (символи не відображатимуться) і натисніть `Enter`.
3. **ВАЖЛИВИЙ КРОК (Додавання Homebrew у PATH)**:
   Після завершення скрипту прочитайте підказку в розділі **Next steps**. Виконайте команди:
   ```bash
   echo >> ~/.zprofile
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
   *(Примітка: на процесорах Intel шлях буде `/usr/local/bin/brew`, скопіюйте точні команди, які вивів інсталятор).*
4. Перевірте працездатність:
   ```bash
   brew --version
   ```

---

### Крок 3.5: Встановлення та налаштування Git
1. Встановіть Git через Homebrew:
   ```bash
   brew install git
   ```
2. Налаштуйте ім'я та електронну пошту:
   ```bash
   git config --global user.name "Ваше Ім'я"
   git config --global user.email "your.email@example.com"
   ```

---

### Крок 3.6: Встановлення Flutter SDK та налаштування змінних оточення
1. Створіть директорію для розробки у домашній папці:
   ```bash
   mkdir -p ~/development
   cd ~/development
   ```
2. Завантажте Flutter SDK:
   - **Для Apple Silicon (M1/M2/M3/M4)**:
     ```bash
     curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.29.0-stable.zip
     unzip flutter_macos_arm64_*.zip
     rm flutter_macos_arm64_*.zip
     ```
   - **Для Intel (x86_64)**:
     ```bash
     curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.29.0-stable.zip
     unzip flutter_macos_3.*.zip
     rm flutter_macos_3.*.zip
     ```
3. Додайте бінарники Flutter до глобального `PATH` у `~/.zshrc`:
   ```bash
   echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
4. Перевірте доступність команди `flutter`:
   ```bash
   which flutter
   flutter --version
   ```

---

### Крок 3.7: Налаштування iOS Toolchain (Xcode та симулятор)
Для запуску застосунку на симуляторі iPhone або фізичному пристрої iOS потрібен Xcode.

1. **Встановлення Xcode**:
   - Відкрийте **Mac App Store**.
   - Знайдіть **Xcode** і натисніть **Get / Отримати** (обсяг ~12-15 ГБ).
2. **Прив'язка інструментів розробника**:
   Після встановлення виконайте у Терміналі:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```
3. **Прийняття умов ліцензії**:
   ```bash
   sudo xcodebuild -license accept
   ```
4. **Запуск первинної ініціалізації**:
   ```bash
   sudo xcodebuild -runFirstLaunch
   ```
5. **Встановлення образу симулятора iOS**:
   - Відкрийте Xcode (`open -a Xcode`).
   - Перейдіть у **Xcode > Settings > Platforms** (або комбінація `Cmd + ,`).
   - Переконайтеся, що встановлена платформа **iOS Simulator** (наприклад, iOS 17 чи iOS 18). Якщо ні — натисніть **Get** навпроти iOS.
6. Перевірте відкриття симулятора:
   ```bash
   open -a Simulator
   ```

---

### Крок 3.8: Встановлення CocoaPods
CocoaPods керує нативними бібліотеками для iOS (зокрема `sqlite3_flutter_libs` та `geolocator_apple`):
1. Встановіть CocoaPods через Homebrew:
   ```bash
   brew install cocoapods
   ```
2. Перевірте версію:
   ```bash
   pod --version
   ```

---

### Крок 3.9: Встановлення JDK 17 та Android Studio (для Android на Mac)
Проєкт Notory використовує Gradle 9.1 та Android Gradle Plugin 9.0, які вимагають **Java 17**.

1. **Встановлення OpenJDK 17**:
   ```bash
   brew install openjdk@17
   ```
   Додайте Java 17 у змінну оточення:
   ```bash
   echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
   echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zshrc
   source ~/.zshrc
   ```
   Перевірте версію:
   ```bash
   java -version
   # Повинно вивести: openjdk version "17.x.x"
   ```

2. **Встановлення Android Studio**:
   ```bash
   brew install --cask android-studio
   ```
3. **Перший запуск Android Studio**:
   - Відкрийте Android Studio через Spotlight або папку Applications.
   - Оберіть **Do not import settings**.
   - Пройдіть Майстер налаштування (оберіть **Standard**).
   - Дозвольте завантажити Android SDK та платформи.
4. **Встановлення Command-line Tools**:
   - На вітальному екрані натисніть **More Actions > SDK Manager** (або Settings > Languages & Frameworks > Android SDK).
   - Перейдіть на вкладку **SDK Tools**.
   - Поставте прапорець навпроти **Android SDK Command-line Tools (latest)**.
   - Переконайтеся, що позначено **Android SDK Platform-Tools** та **Android Emulator**.
   - Натисніть **Apply** та **OK**.
5. **Налаштування змінних оточення для Android SDK у `~/.zshrc`**:
   ```bash
   echo 'export ANDROID_HOME="$HOME/Library/Android/sdk"' >> ~/.zshrc
   echo 'export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
6. **Прийняття ліцензій Android**:
   У Терміналі виконайте:
   ```bash
   flutter doctor --android-licenses
   ```
   Натискайте `y` та `Enter` на всі запитання для підтвердження ліцензій.
7. **Створення емулятора Android (AVD)**:
   - В Android Studio відкрийте **More Actions > Virtual Device Manager**.
   - Натисніть **Create Device** (наприклад, Pixel 8).
   - Оберіть системний образ (наприклад, **API 34** або **API 35** з Google Play).
   - Натисніть **Finish**.

---

### Крок 3.10: Встановлення редактора коду (VS Code)
1. Встановіть Visual Studio Code:
   ```bash
   brew install --cask visual-studio-code
   ```
2. Відкрийте VS Code, натисніть `Cmd + Shift + X` (розділ розширень) та встановіть:
   - **Flutter** (від Dart Code)
   - **Dart** (від Dart Code)

---

### Крок 3.11: Перевірка системи через `flutter doctor`
У Терміналі запустіть діагностику:
```bash
flutter doctor -v
```
Ви повинні побачити зелені позначки `[✓]` біля кожного пункту:
- `[✓] Flutter`
- `[✓] Android toolchain`
- `[✓] Xcode`
- `[✓] Chrome`
- `[✓] Android Studio`
- `[✓] VS Code`
- `[✓] Connected device`

---

### Крок 3.12: Клонування, генерація коду та запуск Notory на Mac

1. **Клонуйте репозиторій**:
   ```bash
   cd ~
   git clone <ПОСИЛАННЯ_НА_РЕПОЗИТОРІЙ> Notory
   cd Notory
   ```
2. **Завантажте залежності Flutter**:
   ```bash
   flutter pub get
   ```
3. **Згенеруйте класи бази даних Drift (SQLite)**:
   Проєкт використовує кодогенерацію для таблиць Drift. Обов'язково виконайте:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   *(Ця команда створює файл `lib/models/database.g.dart`).*
4. **Встановіть залежності CocoaPods для iOS**:
   ```bash
   cd ios
   pod install
   cd ..
   ```
5. **Запустіть симулятор iOS**:
   ```bash
   open -a Simulator
   ```
6. **Запустіть застосунок Notory**:
   ```bash
   flutter run
   ```
   Якщо запитає цільовий пристрій — введіть номер симулятора (наприклад, `1` для iPhone 16).

---

## 4. Інструкція для PC (Windows 10 / 11) з нуля

Якщо перед вами чистий комп'ютер на Windows без попередніх інструментів програмування.

### Крок 4.1: Налаштування PowerShell та пакетного менеджера
1. Натисніть кнопку «Пуск», знайдіть **PowerShell**, клацніть правою кнопкою миші та оберіть **Запуск від імені адміністратора**.
2. Дозвольте виконання локальних скриптів:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```
3. Перевірте наявність Windows Package Manager:
   ```powershell
   winget --version
   ```

---

### Крок 4.2: Встановлення Git для Windows
1. Виконайте в PowerShell:
   ```powershell
   winget install --id Git.Git -e --source winget
   ```
2. Закрийте PowerShell та відкрийте звичайне вікно PowerShell (не від адміністратора).
3. Налаштуйте ім'я та пошту:
   ```powershell
   git config --global user.name "Ваше Ім'я"
   git config --global user.email "your.email@example.com"
   ```

---

### Крок 4.3: Встановлення Java Development Kit (JDK 17)
Збірка Android у проєкті налаштована під **Java 17** (`JavaVersion.VERSION_17`, Gradle 9.1).
1. Встановіть Microsoft OpenJDK 17:
   ```powershell
   winget install Microsoft.OpenJDK.17
   ```
2. Встановіть змінну оточення `JAVA_HOME`:
   ```powershell
   [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Microsoft\jdk-17", "User")
   ```
3. Перевірте у новому вікні PowerShell:
   ```powershell
   java -version
   # Повинно показати версію 17.x
   ```

---

### Крок 4.4: Встановлення Flutter SDK та налаштування PATH
1. Створіть робочу папку в корені диска `C:\` (уникайте шляхів із пробілами чи спецсимволами на зразок `Program Files`):
   ```powershell
   New-Item -ItemType Directory -Path "C:\src" -Force
   ```
2. Завантажте та розпакуйте офіційний архів Flutter SDK:
   ```powershell
   Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.0-stable.zip" -OutFile "C:\src\flutter.zip"
   Expand-Archive -Path "C:\src\flutter.zip" -DestinationPath "C:\src"
   Remove-Item "C:\src\flutter.zip"
   ```
3. Додайте `C:\src\flutter\bin` до змінної `Path`:
   ```powershell
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
   if ($currentPath -notlike "*C:\src\flutter\bin*") {
       [Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\src\flutter\bin", "User")
   }
   ```
4. Перезапустіть PowerShell і перевірте команду:
   ```powershell
   flutter --version
   ```

---

### Крок 4.5: Встановлення та налаштування Android Studio та SDK
1. Встановіть Android Studio через Winget:
   ```powershell
   winget install Google.AndroidStudio
   ```
2. Відкрийте Android Studio через меню «Пуск».
3. Пройдіть початковий Майстер налаштування (тип установки — **Standard**). За замовчуванням SDK встановиться в `%LOCALAPPDATA%\Android\Sdk`.
4. Встановіть Command-line Tools:
   - На стартовому вікні оберіть **More Actions > SDK Manager**.
   - Перейдіть на вкладку **SDK Tools**.
   - Поставте прапорці:
     - **Android SDK Command-line Tools (latest)**
     - **Android SDK Build-Tools**
     - **Android Emulator**
   - Натисніть **Apply** та підтвердіть завантаження.
5. Налаштуйте системні змінні:
   ```powershell
   $sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
   [Environment]::SetEnvironmentVariable("Path", "$currentPath;$sdkPath\platform-tools;$sdkPath\emulator", "User")
   ```

---

### Крок 4.6: Прийняття ліцензій Android та створення емулятора (AVD)
1. У новому вікні PowerShell запустіть:
   ```powershell
   flutter doctor --android-licenses
   ```
   Введіть `y` та натисніть `Enter` на всі запитання.
2. В Android Studio відкрийте **More Actions > Virtual Device Manager**.
3. Створіть пристрій (наприклад, Pixel 8) з образом **API 34** або **API 35** (з Google Play).
4. Запустіть емулятор кнопкою **Play** для перевірки.

---

### Крок 4.7: Встановлення редактора коду (VS Code)
1. Встановіть VS Code:
   ```powershell
   winget install Microsoft.VisualStudioCode
   ```
2. Відкрийте VS Code, натисніть `Ctrl + Shift + X` та встановіть розширення:
   - **Flutter**
   - **Dart**

---

### Крок 4.8: Перевірка системи через `flutter doctor`
У PowerShell виконайте:
```powershell
flutter doctor -v
```
Переконайтеся, що всі пункти мають зелені позначки `[✓]`.

---

### Крок 4.9: Клонування, збірка та запуск Notory на PC

1. **Клонуйте проєкт**:
   ```powershell
   cd C:\
   git clone <ПОСИЛАННЯ_НА_РЕПОЗИТОРІЙ> Notory
   cd Notory
   ```
2. **Встановіть пакети**:
   ```powershell
   flutter pub get
   ```
3. **Згенеруйте схему бази даних Drift**:
   ```powershell
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Запустіть емулятор та додаток**:
   ```powershell
   flutter devices
   # Запуск на емуляторі Android:
   flutter run -d android

   # Або запуск у браузері Chrome:
   flutter run -d chrome
   ```

---

## 5. Важливі особливості проєкту та емуляція функцій

### Симуляція GPS / Геолокації в симуляторах
Додаток Notory прив'язує географічні координати до кожної польової нотатки та звіту через плагін `geolocator` і відображає їх на інтерактивній мапі `flutter_map`. Оскільки симулятори не мають фізичного приймача супутників, **координати потрібно передавати вручну**:

#### У симуляторі iOS (Mac):
1. У верхньому системному меню macOS оберіть **Features > Location** (або **Debug > Location**).
2. Оберіть готовий маршрут (наприклад, **City Bicycle Ride**) або введіть точні координати через **Custom Location...** (наприклад, `50.4501` широта, `30.5234` довгота — Київ).
3. Під час запиту в додатку натисніть **Allow While Using App** («Дозволити під час використання додатку»).

#### В емуляторі Android (Mac та PC):
1. На бічній панелі емулятора натисніть кнопку з трьома крапками **(`...`)** (Extended Controls).
2. Перейдіть у вкладку **Location**.
3. Введіть координати або знайдіть точку на мапі та натисніть **Send** у нижньому правому куті.
4. У вікні додатку підтвердіть дозвіл на доступ до геолокації (**While using the app** та **Precise**).

---

### Локальна база даних SQLite та генерація коду Drift
Усі звіти та польові замітки зберігаються локально в базі даних SQLite за допомогою бібліотеки Drift (`lib/models/database.dart`).

- Файл бази даних автоматично створюється при першому запуску додатку у внутрішній папці пристрою (`notory.sqlite`).
- Якщо ви змінюєте структури таблиць у `database.dart`, **обов'язково** оновлюйте згенерований код:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Або увімкніть автоматичний моніторинг змін під час розробки:
  ```bash
  dart run build_runner watch --delete-conflicting-outputs
  ```

---

## 6. Вирішення типових проблем (Troubleshooting)

### Помилка 1: `xcode-select: error: tool 'xcodebuild' requires Xcode` (Mac)
- **Причина**: Активна директорія вказує на базові утиліти CommandLineTools замість повного Xcode.
- **Вирішення**:
  ```bash
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```

---

### Помилка 2: `CocoaPods' output: pod: command not found` або збої `Podfile` (Mac)
- **Причина**: CocoaPods не встановлено або кеш залежностей пошкоджено.
- **Вирішення**:
  ```bash
  brew install cocoapods
  cd ios
  rm -rf Pods Podfile.lock .symlinks
  pod repo update
  pod install
  cd ..
  ```

---

### Помилка 3: `cmdline-tools component is missing` у `flutter doctor`
- **Причина**: В Android Studio не позначено компонент командного рядка.
- **Вирішення**:
  1. Відкрийте Android Studio > SDK Manager > вкладка **SDK Tools**.
  2. Позначте **Android SDK Command-line Tools (latest)** та натисніть **Apply**.
  3. Повторно виконайте: `flutter doctor --android-licenses`.

---

### Помилка 4: `Unsupported class file major version` або збій Gradle
- **Причина**: Невідповідна версія Java (наприклад, Java 8 або Java 21/23 замість Java 17).
- **Вирішення**:
  Перевірте версію командою `java -version`. Gradle 9.1 у цьому проєкті налаштовано на роботу з **Java 17**. Встановіть JDK 17 та оновіть змінну `JAVA_HOME`.

---

### Помилка 5: Відсутній файл `database.g.dart` або помилки `_$AppDatabase`
- **Причина**: Після клонування проєкту не було запущено генерацію коду Drift.
- **Вирішення**:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

### Помилка 6: Додаток зависає при запиті геолокації в симуляторі
- **Причина**: У симуляторі або емуляторі встановлено статус локації «None».
- **Вирішення**: Передайте координати у симулятор, як описано у [Розділі 5](#симуляція-gps--геолокації-в-симуляторах).

---

## Шпаргалка основних щоденних команд

```bash
# Отримати пакети
flutter pub get

# Згенерувати код бази даних Drift
dart run build_runner build --delete-conflicting-outputs

# Перевірити підключені пристрої
flutter devices

# Запустити додаток за замовчуванням
flutter run

# Запустити на конкретній платформі
flutter run -d chrome        # Браузер Chrome
flutter run -d iphone        # Симулятор iOS (Mac)
flutter run -d emulator-5554 # Емулятор Android

# Запуск тестів
flutter test
```
