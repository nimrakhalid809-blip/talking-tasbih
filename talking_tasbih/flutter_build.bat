@echo off
REM Flutter Build Script for Talking Tasbih (Windows)
REM This script builds the Flutter application for different platforms

echo ================================================
echo   Talking Tasbih - Flutter Build
echo ================================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo Flutter version:
flutter --version
echo.

echo Getting Flutter dependencies...
flutter pub get

if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    exit /b 1
)

echo.
echo Select build target:
echo 1 - APK (Android)
echo 2 - iOS (iPhone)
echo 3 - Web
echo 4 - Windows
echo 5 - macOS
echo 6 - Linux
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    echo Building APK...
    flutter build apk --release
    if %errorlevel% equ 0 echo Build successful! APK location: build\app\outputs\flutter-apk\app-release.apk
) else if "%choice%"=="2" (
    echo Building iOS...
    flutter build ios --release
    if %errorlevel% equ 0 echo Build successful! Check build\ios\Release-iphoneos\
) else if "%choice%"=="3" (
    echo Building Web...
    flutter build web --release
    if %errorlevel% equ 0 echo Build successful! Web files are in build\web\
) else if "%choice%"=="4" (
    echo Building Windows...
    flutter build windows --release
    if %errorlevel% equ 0 echo Build successful! Executable is in build\windows\runner\Release\
) else if "%choice%"=="5" (
    echo Building macOS...
    flutter build macos --release
    if %errorlevel% equ 0 echo Build successful! App is in build\macos\Build\Products\Release\
) else if "%choice%"=="6" (
    echo Building Linux...
    flutter build linux --release
    if %errorlevel% equ 0 echo Build successful! Executable is in build\linux\x64\release\bundle\
) else (
    echo Invalid choice. Exiting.
    exit /b 1
)
