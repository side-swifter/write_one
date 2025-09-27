#!/bin/bash

# Build script for Android APK
echo "Building Android APK for write_one..."

# Source the environment
source ~/.zshrc

# Clean previous builds (optional)
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build the APK
echo "Building APK..."
flutter build apk

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    ls -la build/app/outputs/flutter-apk/app-release.apk
else
    echo "❌ Build failed!"
    exit 1
fi
