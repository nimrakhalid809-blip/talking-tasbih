# Talking Tasbih - Working Directory

This directory contains the working environment for the **Talking Tasbih** Flutter application.

## Quick Start

### macOS/Linux

**Run the application:**
```bash
bash flutter_run.sh
```

**Build the application:**
```bash
bash flutter_build.sh
```

### Windows

**Run the application:**
```cmd
flutter_run.bat
```

**Build the application:**
```cmd
flutter_build.bat
```

## Directory Structure

```
talking_tasbih/
├── flutter_run.sh       # Run script for macOS/Linux
├── flutter_run.bat      # Run script for Windows
├── flutter_build.sh     # Build script for macOS/Linux
├── flutter_build.bat    # Build script for Windows
└── README.md           # This file
```

## Prerequisites

- Flutter SDK installed ([Download](https://flutter.dev/docs/get-started/install))
- Dart SDK (included with Flutter)
- Android Studio/Xcode (for iOS builds)
- Git

## Scripts Overview

### flutter_run.sh / flutter_run.bat
This script:
- Verifies Flutter installation
- Gets project dependencies
- Runs the Flutter application in debug mode

### flutter_build.sh / flutter_build.bat
This script:
- Verifies Flutter installation
- Gets project dependencies
- Prompts you to select a build target:
  - **APK** - Android mobile build
  - **iOS** - iPhone/iPad build
  - **Web** - Web browser build
  - **Windows** - Windows desktop build
  - **macOS** - macOS desktop build
  - **Linux** - Linux desktop build

## Useful Flutter Commands

```bash
# Check Flutter setup
flutter doctor

# Get project dependencies
flutter pub get

# Clean build files
flutter clean

# Run tests
flutter test

# Generate code/models
flutter pub run build_runner build
```

## Troubleshooting

**Flutter not found:**
- Ensure Flutter is installed and added to your PATH
- Run `flutter doctor` to diagnose issues

**Build failures:**
- Run `flutter clean` to clear build cache
- Run `flutter pub get` to update dependencies
- Check `flutter doctor` for platform-specific issues

**Android build issues:**
- Ensure Android SDK is properly configured
- Run `flutter doctor -v` for detailed diagnostics

## Support

For more information about Flutter, visit: https://flutter.dev
