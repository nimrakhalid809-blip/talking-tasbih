#!/bin/bash

# Flutter Build Script for Talking Tasbih
# This script builds the Flutter application for different platforms

echo "================================================"
echo "  Talking Tasbih - Flutter Build"
echo "================================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "Flutter version:"
flutter --version
echo ""

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "Error: Failed to get dependencies"
    exit 1
fi

echo ""
echo "Select build target:"
echo "1) APK (Android)"
echo "2) iOS (iPhone)"
echo "3) Web"
echo "4) Windows"
echo "5) macOS"
echo "6) Linux"
echo ""
read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo "Building APK..."
        flutter build apk --release
        if [ $? -eq 0 ]; then
            echo "Build successful! APK location: build/app/outputs/flutter-apk/app-release.apk"
        fi
        ;;
    2)
        echo "Building iOS..."
        flutter build ios --release
        if [ $? -eq 0 ]; then
            echo "Build successful! Check build/ios/Release-iphoneos/"
        fi
        ;;
    3)
        echo "Building Web..."
        flutter build web --release
        if [ $? -eq 0 ]; then
            echo "Build successful! Web files are in build/web/"
        fi
        ;;
    4)
        echo "Building Windows..."
        flutter build windows --release
        if [ $? -eq 0 ]; then
            echo "Build successful! Executable is in build/windows/runner/Release/"
        fi
        ;;
    5)
        echo "Building macOS..."
        flutter build macos --release
        if [ $? -eq 0 ]; then
            echo "Build successful! App is in build/macos/Build/Products/Release/"
        fi
        ;;
    6)
        echo "Building Linux..."
        flutter build linux --release
        if [ $? -eq 0 ]; then
            echo "Build successful! Executable is in build/linux/x64/release/bundle/"
        fi
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
