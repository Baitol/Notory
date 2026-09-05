# Notory - Complete Installation & Setup Guide (Mac & Windows PC)

This guide provides step-by-step instructions for installing, configuring, building, and running the **Notory** project from scratch. It is written under the assumption that you are starting with a **completely clean, factory-fresh Mac or PC without any developer tools, package managers, or SDKs installed**.

---

## Table of Contents
1. [Project Overview & Architecture](#1-project-overview--architecture)
2. [Prerequisites Summary](#2-prerequisites-summary)
3. [Mac Setup Guide (Zero-to-Running on an Empty Mac)](#3-mac-setup-guide-zero-to-running-on-an-empty-mac)
   - [Step 3.1: Terminal & Hardware Architecture](#step-31-terminal--hardware-architecture)
   - [Step 3.2: Install Apple Command Line Tools](#step-32-install-apple-command-line-tools)
   - [Step 3.3: (Apple Silicon only) Install Rosetta 2](#step-33-apple-silicon-only-install-rosetta-2)
   - [Step 3.4: Install Homebrew (Package Manager)](#step-34-install-homebrew-package-manager)
   - [Step 3.5: Install Git & Configure Identity](#step-35-install-git--configure-identity)
   - [Step 3.6: Install Flutter SDK & Configure Shell PATH](#step-36-install-flutter-sdk--configure-shell-path)
   - [Step 3.7: Set Up iOS Toolchain (Xcode & Simulator)](#step-37-set-up-ios-toolchain-xcode--simulator)
   - [Step 3.8: Install CocoaPods](#step-38-install-cocoapods)
   - [Step 3.9: Install JDK 17 & Android Studio (for Android builds on Mac)](#step-39-install-jdk-17--android-studio-for-android-builds-on-mac)
   - [Step 3.10: Install Code Editor (VS Code)](#step-310-install-code-editor-vs-code)
   - [Step 3.11: Validate System with `flutter doctor`](#step-311-validate-system-with-flutter-doctor)
   - [Step 3.12: Clone, Build & Run Notory on Mac](#step-312-clone-build--run-notory-on-mac)
4. [PC (Windows) Setup Guide (Zero-to-Running on a Fresh PC)](#4-pc-windows-setup-guide-zero-to-running-on-a-fresh-pc)
   - [Step 4.1: Configure PowerShell & Windows Package Manager](#step-41-configure-powershell--windows-package-manager)
   - [Step 4.2: Install Git for Windows](#step-42-install-git-for-windows)
   - [Step 4.3: Install Java Development Kit (JDK 17)](#step-43-install-java-development-kit-jdk-17)
   - [Step 4.4: Install Flutter SDK & Configure PATH](#step-44-install-flutter-sdk--configure-path)
   - [Step 4.5: Install & Configure Android Studio & SDK Components](#step-45-install--configure-android-studio--sdk-components)
   - [Step 4.6: Accept Android Licenses & Create Virtual Device (AVD)](#step-46-accept-android-licenses--create-virtual-device-avd)
   - [Step 4.7: Install Code Editor (VS Code)](#step-47-install-code-editor-vs-code)
   - [Step 4.8: Validate System with `flutter doctor`](#step-48-validate-system-with-flutter-doctor)
   - [Step 4.9: Clone, Build & Run Notory on PC](#step-49-clone-build--run-notory-on-pc)
5. [Critical Project Features & Simulation Settings](#5-critical-project-features--simulation-settings)
   - [Simulating GPS / Geolocation](#simulating-gps--geolocation)
   - [Local SQLite Database & Drift Code Generation](#local-sqlite-database--drift-code-generation)
6. [Common Issues & Troubleshooting Guide](#6-common-issues--troubleshooting-guide)

---

## 1. Project Overview & Architecture

**Notory** is a mobile/desktop field-inspection and geotagged report management application built with Flutter.

- **Framework**: Flutter (Dart 3.x, Flutter 3.38+)
- **State Management**: `flutter_riverpod` (v2.5.1)
- **Local Database**: `drift` (v2.20.0) + `sqlite3_flutter_libs`
- **Geolocation & Mapping**: `geolocator` (v10.1.0), `flutter_map` (v6.1.0) with OpenStreetMap, `latlong2`
- **Android Toolchain**: Android Gradle Plugin 9.0.1, Gradle 9.1.0, Kotlin 2.3.20, Java 17 Target

---

## 2. Prerequisites Summary

| Component | Minimum Version / Recommendation | Required For |
|---|---|---|
| **OS (Mac)** | macOS Sonoma 14+ or Sequoia 15+ | iOS & Android development |
| **OS (PC)** | Windows 10 (64-bit) / Windows 11 | Android & Web development |
| **Flutter SDK** | >= 3.38.4 (Dart >= 3.12.2) | All platforms |
| **JDK** | OpenJDK 17 (Required by Gradle 9.1 & AGP 9.0) | Android builds |
| **Xcode** | Xcode 15+ (from Mac App Store) | iOS Simulator & Device builds (Mac only) |
| **CocoaPods** | CocoaPods 1.14+ | iOS Pod dependencies (Mac only) |
| **Android Studio** | Ladybug / Koala / Hedgehog (Latest) | Android SDK, Command-line Tools, Emulators |
| **VS Code** | Latest Stable with Flutter & Dart Extensions | Recommended IDE |

---

## 3. Mac Setup Guide (Zero-to-Running on an Empty Mac)

Imagine you just unboxed a brand-new Mac. You are staring at the default macOS desktop. Follow these steps in order.

### Step 3.1: Terminal & Hardware Architecture
1. Press `Cmd + Space` to open Spotlight, type **Terminal**, and press `Enter`.
2. Determine whether your Mac is Apple Silicon (M1/M2/M3/M4) or Intel by running:
   ```bash
   uname -m
   ```
   - If output is `arm64`, you are on **Apple Silicon**.
   - If output is `x86_64`, you are on **Intel**.

---

### Step 3.2: Install Apple Command Line Tools
macOS requires Apple's core development tools (clang, make, git stub, etc.):
1. In Terminal, run:
   ```bash
   xcode-select --install
   ```
2. A graphical pop-up window will appear asking: *"The xcode-select command requires the command line developer tools. Would you like to install the tools now?"*
3. Click **Install**, agree to the terms, and wait for the download to complete (takes ~2-5 minutes).
4. Verify the installation succeeded:
   ```bash
   xcode-select -p
   # Output should be: /Library/Developer/CommandLineTools (or /Applications/Xcode.app/Contents/Developer)
   ```

---

### Step 3.3: (Apple Silicon only) Install Rosetta 2
If `uname -m` returned `arm64`, some Android tools and legacy libraries still require Rosetta translation:
```bash
softwareupdate --install-rosetta --agree-to-license
```

---

### Step 3.4: Install Homebrew (Package Manager)
Homebrew is the standard package manager for macOS, needed to install CocoaPods, Git, JDK, and other utilities cleanly.
1. Run the official Homebrew installer:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. During installation, it may ask for your Mac user password. Type it (characters will not show) and press `Enter`.
3. **CRITICAL STEP (Adding Homebrew to your PATH)**:
   Once the script finishes, read the instructions at the end of the script under **Next steps**. Run the following commands:
   ```bash
   echo >> ~/.zprofile
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
   *(Note: On Intel Macs, the path is `/usr/local/bin/brew`, but the installer prints the exact commands to copy-paste).*
4. Verify Homebrew:
   ```bash
   brew --version
   ```

---

### Step 3.5: Install Git & Configure Identity
1. Install Git via Homebrew:
   ```bash
   brew install git
   ```
2. Set your Git identity (required for Git commits and repository actions):
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

---

### Step 3.6: Install Flutter SDK & Configure Shell PATH
1. Create a development directory in your user home:
   ```bash
   mkdir -p ~/development
   cd ~/development
   ```
2. Download the Flutter SDK:
   - **For Apple Silicon (M1/M2/M3/M4)**:
     ```bash
     curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.29.0-stable.zip
     unzip flutter_macos_arm64_*.zip
     rm flutter_macos_arm64_*.zip
     ```
   - **For Intel (x86_64)**:
     ```bash
     curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.29.0-stable.zip
     unzip flutter_macos_3.*.zip
     rm flutter_macos_3.*.zip
     ```
   *(Alternatively, you can clone Flutter master/stable: `git clone https://github.com/flutter/flutter.git -b stable ~/development/flutter`)*

3. Add Flutter to your shell profile (`~/.zshrc`):
   ```bash
   echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
4. Verify Flutter command:
   ```bash
   which flutter
   flutter --version
   ```

---

### Step 3.7: Set Up iOS Toolchain (Xcode & Simulator)
To build and run on iOS (Simulator or physical iPhone), Xcode is mandatory.

1. **Install Xcode**:
   - Open the **App Store** on your Mac.
   - Search for **Xcode** and click **Get / Install** (this is ~10-15 GB, so allow some time).
2. **Configure Xcode Command Line Tools**:
   Once Xcode finishes installing, link it in Terminal:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```
3. **Accept Xcode License**:
   ```bash
   sudo xcodebuild -license accept
   ```
4. **Run First Launch Setup**:
   ```bash
   sudo xcodebuild -runFirstLaunch
   ```
5. **Install iOS Simulator Runtime**:
   - Open Xcode (`open -a Xcode`).
   - If prompted with *"Install additional required components?"*, click **Install**.
   - Go to **Xcode > Settings > Platforms** (or `Cmd + ,`).
   - Ensure an **iOS Simulator** platform (e.g. iOS 17 or iOS 18) is installed. If not, click **Get** next to iOS.
6. Verify Simulator works:
   ```bash
   open -a Simulator
   ```

---

### Step 3.8: Install CocoaPods
CocoaPods manages native iOS libraries (such as `sqlite3_flutter_libs` and `geolocator_apple`).
1. Install CocoaPods via Homebrew:
   ```bash
   brew install cocoapods
   ```
2. Verify CocoaPods:
   ```bash
   pod --version
   ```

---

### Step 3.9: Install JDK 17 & Android Studio (for Android builds on Mac)
This project requires **Java 17** (due to Gradle 9.1.0).

1. **Install OpenJDK 17**:
   ```bash
   brew install openjdk@17
   ```
   Add Java 17 to your PATH:
   ```bash
   echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
   echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zshrc
   source ~/.zshrc
   ```
   Verify:
   ```bash
   java -version
   # Must display: openjdk version "17.x.x"
   ```

2. **Install Android Studio**:
   ```bash
   brew install --cask android-studio
   ```
3. **Run Android Studio Setup Wizard**:
   - Open Android Studio from Spotlight or Applications.
   - Select **Do not import settings**.
   - Follow the Setup Wizard (Choose **Standard** setup).
   - Allow it to download the Android SDK, platform tools, and build tools.
4. **Install Android SDK Command-line Tools**:
   - On the Android Studio welcome screen, click **More Actions > SDK Manager** (or Settings > Languages & Frameworks > Android SDK).
   - Go to the **SDK Tools** tab.
   - Check the box for **Android SDK Command-line Tools (latest)**.
   - Check **Android SDK Platform-Tools**.
   - Click **Apply** and **OK** to download and install.
5. **Set Android Environment Variables in `~/.zshrc`**:
   ```bash
   echo 'export ANDROID_HOME="$HOME/Library/Android/sdk"' >> ~/.zshrc
   echo 'export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
6. **Accept Android Licenses**:
   In Terminal, run:
   ```bash
   flutter doctor --android-licenses
   ```
   Press `y` and `Enter` to accept every license prompt.
7. **Create an Android Virtual Device (AVD)**:
   - In Android Studio, click **More Actions > Virtual Device Manager**.
   - Click **Create Device** (e.g. Pixel 8).
   - Select a system image (e.g. **VanillaIceCream (API 35)** or **UpsideDownCake (API 34)** with Google Play).
   - Click **Next** and **Finish**.

---

### Step 3.10: Install Code Editor (VS Code)
1. Install Visual Studio Code:
   ```bash
   brew install --cask visual-studio-code
   ```
2. Open VS Code.
3. Press `Cmd + Shift + X` to open the Extensions view.
4. Search for and install:
   - **Flutter** (Publisher: Dart Code)
   - **Dart** (Publisher: Dart Code)

---

### Step 3.11: Validate System with `flutter doctor`
In your Terminal, run:
```bash
flutter doctor -v
```
You should see green checkmarks `[✓]` for:
- `[✓] Flutter (Channel stable, ...)`
- `[✓] Android toolchain - develop for Android devices`
- `[✓] Xcode - develop for iOS and macOS`
- `[✓] Chrome - develop for the web`
- `[✓] Android Studio`
- `[✓] VS Code`
- `[✓] Connected device`

*(Note: If you don't intend to deploy to macOS desktop, yellow warnings for macOS desktop can be ignored).*

---

### Step 3.12: Clone, Build & Run Notory on Mac

1. **Clone the repository**:
   ```bash
   cd ~
   git clone <REPO_URL> Notory
   cd Notory
   ```
2. **Fetch Flutter packages**:
   ```bash
   flutter pub get
   ```
3. **Run Code Generation (Drift SQLite)**:
   The project uses `drift` with code generation for table schema mappings. Run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   *(This ensures `lib/models/database.g.dart` is in sync with `database.dart`).*
4. **Install iOS Pods**:
   ```bash
   cd ios
   pod install
   cd ..
   ```
5. **Launch the iOS Simulator**:
   ```bash
   open -a Simulator
   ```
   Wait until the simulated iPhone boots to the home screen.
6. **Run Notory**:
   ```bash
   flutter run
   ```
   If prompted to choose a device, select your active Simulator (e.g., `1` for iPhone 16).

---

## 4. PC (Windows) Setup Guide (Zero-to-Running on a Fresh PC)

Imagine you just unboxed or reinstalled a clean Windows 10 or 11 PC. Follow these steps in order.

### Step 4.1: Configure PowerShell & Windows Package Manager
1. Click the Start menu, search for **PowerShell**, right-click it, and select **Run as administrator**.
2. Allow script execution for your user account:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```
3. Check if Windows Package Manager (`winget`) is available:
   ```powershell
   winget --version
   ```
   *(Note: Winget is built into modern Windows 10/11 via the "App Installer" in Microsoft Store).*

---

### Step 4.2: Install Git for Windows
1. Run in PowerShell:
   ```powershell
   winget install --id Git.Git -e --source winget
   ```
2. Once installed, close PowerShell and open a standard (non-admin) PowerShell window.
3. Configure your Git identity:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

---

### Step 4.3: Install Java Development Kit (JDK 17)
Gradle 9.1 and Android Gradle Plugin 9.0 in Notory require **Java 17**.
1. Install Microsoft OpenJDK 17 or Eclipse Temurin 17:
   ```powershell
   winget install Microsoft.OpenJDK.17
   ```
2. Configure `JAVA_HOME` environment variable:
   ```powershell
   [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Microsoft\jdk-17", "User")
   ```
3. Verify Java installation (in a fresh PowerShell window):
   ```powershell
   java -version
   # Output should confirm OpenJDK 17
   ```

---

### Step 4.4: Install Flutter SDK & Configure PATH
1. Create a root development folder (avoid paths with spaces or special privileges like `C:\Program Files`):
   ```powershell
   New-Item -ItemType Directory -Path "C:\src" -Force
   ```
2. Download Flutter SDK for Windows:
   - Visit https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.0-stable.zip or download using PowerShell:
   ```powershell
   Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.0-stable.zip" -OutFile "C:\src\flutter.zip"
   Expand-Archive -Path "C:\src\flutter.zip" -DestinationPath "C:\src"
   Remove-Item "C:\src\flutter.zip"
   ```
3. Add `C:\src\flutter\bin` to your User `PATH`:
   ```powershell
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
   if ($currentPath -notlike "*C:\src\flutter\bin*") {
       [Environment]::SetEnvironmentVariable("Path", "$currentPath;C:\src\flutter\bin", "User")
   }
   ```
4. Close and reopen PowerShell, then test:
   ```powershell
   flutter --version
   ```

---

### Step 4.5: Install & Configure Android Studio & SDK Components
1. Install Android Studio via Winget:
   ```powershell
   winget install Google.AndroidStudio
   ```
2. Open Android Studio from the Start Menu.
3. Complete the Setup Wizard:
   - Choose **Standard** setup.
   - Accept the license agreements and let it install the Android SDK to `%LOCALAPPDATA%\Android\Sdk`.
4. Install Android SDK Command-line Tools:
   - On the Welcome screen, select **More Actions > SDK Manager**.
   - Navigate to the **SDK Tools** tab.
   - Check **Android SDK Command-line Tools (latest)**.
   - Check **Android SDK Build-Tools** and **Android Emulator**.
   - Click **Apply** and **OK**.
5. Set `ANDROID_HOME` environment variable:
   ```powershell
   $sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
   [Environment]::SetEnvironmentVariable("Path", "$currentPath;$sdkPath\platform-tools;$sdkPath\emulator", "User")
   ```

---

### Step 4.6: Accept Android Licenses & Create Virtual Device (AVD)
1. In a new PowerShell window, run:
   ```powershell
   flutter doctor --android-licenses
   ```
   Type `y` and press `Enter` for all prompts.
2. In Android Studio, go to **More Actions > Virtual Device Manager**.
3. Click **Create Device**:
   - Choose **Pixel 8** (or any phone).
   - Select system image **API 34** or **API 35** (with Google Play).
   - Click **Finish**.
4. Test launch the emulator by clicking the green **Play** button in Device Manager.

---

### Step 4.7: Install Code Editor (VS Code)
1. Install VS Code:
   ```powershell
   winget install Microsoft.VisualStudioCode
   ```
2. Open VS Code, press `Ctrl + Shift + X`, and install:
   - **Flutter** extension
   - **Dart** extension

---

### Step 4.8: Validate System with `flutter doctor`
Open PowerShell and run:
```powershell
flutter doctor -v
```
Ensure that Flutter, Android toolchain, Android Studio, and VS Code are all checked with green tick marks.

---

### Step 4.9: Clone, Build & Run Notory on PC

1. **Clone the repository**:
   ```powershell
   cd C:\
   git clone <REPO_URL> Notory
   cd Notory
   ```
2. **Install Flutter packages**:
   ```powershell
   flutter pub get
   ```
3. **Run Code Generation (Drift database)**:
   ```powershell
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **List Available Devices**:
   ```powershell
   flutter devices
   ```
5. **Run the App**:
   - On Android Emulator (start the emulator first from Android Studio or run `flutter emulators --launch <id>`):
     ```powershell
     flutter run -d android
     ```
   - On Web (Chrome):
     ```powershell
     flutter run -d chrome
     ```

---

## 5. Critical Project Features & Simulation Settings

### Simulating GPS / Geolocation
Notory captures coordinates for field notes and reports via `geolocator` and displays them on OpenStreetMap with `flutter_map`. **Simulators/emulators do not have a physical GPS chip, so you must simulate coordinates**:

#### On iOS Simulator (Mac):
1. In the macOS top menu bar, click **Features > Location** (or **Debug > Location** depending on Xcode version).
2. Choose one of:
   - **Apple** (Infinite Loop, Cupertino)
   - **City Bicycle Ride** (dynamic moving coordinates)
   - **Custom Location...** (enter specific Latitude and Longitude, e.g. `37.7749`, `-122.4194`)
3. When the app opens, click **Allow While Using App** when prompted for location permission.

#### On Android Emulator (Mac & PC):
1. On the floating emulator toolbar on the right side, click the **three dots (`...`)** to open **Extended Controls**.
2. Click **Location**.
3. Search for an address or enter coordinates (e.g. Latitude: `37.7749`, Longitude: `-122.4194`).
4. Click **Send** in the bottom right corner.
5. In the app, accept the Android location permission modal (**While using the app** and **Precise**).

---

### Local SQLite Database & Drift Code Generation
Notory stores notes and reports locally using an SQLite database managed by Drift (`lib/models/database.dart`).

- The database file is created automatically on first run in the app's documents folder (`notory.sqlite`).
- If you edit tables in `database.dart`, you **must** re-generate the data access classes:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Or run the watcher during active schema development:
  ```bash
  dart run build_runner watch --delete-conflicting-outputs
  ```

---

## 6. Common Issues & Troubleshooting Guide

### Issue 1: `xcode-select: error: tool 'xcodebuild' requires Xcode` (Mac)
- **Cause**: Active developer directory is pointing to Command Line Tools instead of the full Xcode application.
- **Fix**:
  ```bash
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```

---

### Issue 2: `CocoaPods' output: pod: command not found` or `Podfile.lock` errors (Mac)
- **Cause**: CocoaPods is missing or outdated.
- **Fix**:
  ```bash
  brew install cocoapods
  cd ios
  rm -rf Pods Podfile.lock .symlinks
  pod repo update
  pod install
  cd ..
  ```

---

### Issue 3: `cmdline-tools component is missing` in `flutter doctor`
- **Cause**: The command-line tools were not selected in Android Studio SDK Manager.
- **Fix**:
  1. Open Android Studio > Settings / Preferences > Languages & Frameworks > Android SDK.
  2. Select **SDK Tools** tab.
  3. Check **Android SDK Command-line Tools (latest)** and click **Apply**.
  4. Run `flutter doctor --android-licenses` again.

---

### Issue 4: `Unsupported class file major version` or Gradle build failure
- **Cause**: Java version mismatch (e.g. Java 8 or Java 23 when Gradle requires Java 17).
- **Fix**:
  Verify your active JDK:
  ```bash
  java -version
  ```
  Ensure it points to **Java 17**. If not, install Java 17 and update `JAVA_HOME` as shown in Steps 3.9 (Mac) or 4.3 (Windows).

---

### Issue 5: `database.g.dart is missing` or compilation errors referencing `_$AppDatabase`
- **Cause**: Drift generated code was not built after cloning.
- **Fix**:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

### Issue 6: `Location permission denied` or GPS hanging indefinitely in Simulator
- **Cause**: The emulator/simulator has default location set to "None".
- **Fix**: Set a simulated location as described in [Section 5](#simulating-gps--geolocation) and ensure location permissions are granted in the simulator settings.

---

## Summary of Essential Daily Commands

```bash
# Get dependencies
flutter pub get

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Check connected devices
flutter devices

# Run on default device
flutter run

# Run on specific target
flutter run -d chrome        # Web
flutter run -d iphone        # iOS Simulator (Mac)
flutter run -d emulator-5554 # Android Emulator

# Run tests
flutter test
```
