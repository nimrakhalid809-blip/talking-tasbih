@echo off
REM Flutter Run Script for Talking Tasbih (Windows)
REM This script sets up the environment and runs the Flutter application

echo ================================================
echo   Talking Tasbih - Flutter Run
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
echo Starting Talking Tasbih application...
echo.

REM Run the app
flutter run
