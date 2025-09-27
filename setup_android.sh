#!/bin/bash

# Setup Android environment for Flutter development
echo "Setting up Android environment for Flutter..."

# Set Android SDK path
export ANDROID_HOME="/Users/akku/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"

# Add to shell profile for persistence
SHELL_PROFILE=""
if [ -f ~/.zshrc ]; then
    SHELL_PROFILE=~/.zshrc
elif [ -f ~/.bash_profile ]; then
    SHELL_PROFILE=~/.bash_profile
elif [ -f ~/.bashrc ]; then
    SHELL_PROFILE=~/.bashrc
fi

if [ -n "$SHELL_PROFILE" ]; then
    echo "Adding Android environment variables to $SHELL_PROFILE"
    
    # Check if ANDROID_HOME is already in the profile
    if ! grep -q "ANDROID_HOME" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Android SDK" >> "$SHELL_PROFILE"
        echo "export ANDROID_HOME=\"/Users/akku/Library/Android/sdk\"" >> "$SHELL_PROFILE"
        echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/cmdline-tools/latest/bin\"" >> "$SHELL_PROFILE"
        echo "Android environment variables added to $SHELL_PROFILE"
        echo "Please run 'source $SHELL_PROFILE' or restart your terminal"
    else
        echo "Android environment variables already exist in $SHELL_PROFILE"
    fi
fi

# Check if cmdline-tools exist
if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo "Command-line tools not found. Please install them through Android Studio:"
    echo "1. Open Android Studio"
    echo "2. Go to Tools > SDK Manager"
    echo "3. Go to SDK Tools tab"
    echo "4. Check 'Android SDK Command-line Tools (latest)'"
    echo "5. Click Apply to install"
    echo ""
    echo "Alternatively, you can download them manually from:"
    echo "https://developer.android.com/studio#command-line-tools-only"
fi

echo "Setup complete!"
