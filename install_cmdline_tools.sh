#!/bin/bash

# Install Android command-line tools
echo "Installing Android command-line tools..."

# Set Android SDK path
export ANDROID_HOME="/Users/akku/Library/Android/sdk"

# Create cmdline-tools directory if it doesn't exist
mkdir -p "$ANDROID_HOME/cmdline-tools"

# Download the latest command-line tools for macOS
echo "Downloading Android command-line tools..."
cd /tmp
curl -o commandlinetools-mac.zip https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip

# Extract the tools
echo "Extracting command-line tools..."
unzip -q commandlinetools-mac.zip

# Move to the correct location
echo "Installing command-line tools..."
mv cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"

# Clean up
rm commandlinetools-mac.zip

echo "Command-line tools installed successfully!"
echo "You can now run: flutter doctor --android-licenses"
