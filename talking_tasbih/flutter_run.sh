#!/bin/bash

# Flutter Run Script for Talking Tasbih
# This script sets up the environment and runs the Flutter application

echo "================================================"
echo "  Talking Tasbih - Flutter Run"
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
echo "Starting Talking Tasbih application..."
echo ""

# Run the app
flutter run
