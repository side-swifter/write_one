#!/bin/bash

# Demo script to show hot reload in action
echo "🔥 Hot Reload Demo for WriteOne"
echo "================================"
echo ""

# Check if flutter run is active
if ! pgrep -f "flutter run" > /dev/null; then
    echo "❌ Flutter app is not running."
    echo "Please start the app first with: flutter run -d emulator-5554"
    exit 1
fi

echo "✅ Flutter app is running with hot reload enabled!"
echo ""

echo "This demo will make changes to your app and you'll see them update instantly."
echo "Make sure you can see the Android emulator screen."
echo ""

read -p "Press Enter to start the demo..."

# Demo 1: Change app title color
echo ""
echo "🎨 Demo 1: Changing app theme color from blue to green..."
sleep 2

# Backup original main.dart
cp lib/main.dart lib/main.dart.backup

# Change color to green
sed -i '' 's/seedColor: Colors\.blue,/seedColor: Colors.green,/' lib/main.dart

echo "✅ Changed theme color to green - check your emulator!"
echo ""

read -p "Press Enter for next demo..."

# Demo 2: Change welcome text
echo ""
echo "📝 Demo 2: Changing welcome text..."
sleep 2

sed -i '' 's/Welcome to WriteOne!/Hello from Hot Reload Demo!/' lib/pages/home_page.dart

echo "✅ Changed welcome text - check your emulator!"
echo ""

read -p "Press Enter for next demo..."

# Demo 3: Change color to purple
echo ""
echo "🎨 Demo 3: Changing theme color to purple..."
sleep 2

sed -i '' 's/seedColor: Colors\.green,/seedColor: Colors.purple,/' lib/main.dart

echo "✅ Changed theme color to purple - check your emulator!"
echo ""

read -p "Press Enter to restore original code..."

# Restore original files
echo ""
echo "🔄 Restoring original code..."

mv lib/main.dart.backup lib/main.dart
sed -i '' 's/Hello from Hot Reload Demo!/Welcome to WriteOne!/' lib/pages/home_page.dart

echo "✅ Original code restored!"
echo ""

echo "🎉 Hot Reload Demo Complete!"
echo ""
echo "Key takeaways:"
echo "• Changes appear instantly without losing app state"
echo "• No need to rebuild or restart the app"
echo "• Perfect for UI development and testing"
echo "• Works with colors, text, layouts, and more"
echo ""
echo "Try making your own changes to any .dart file and save to see hot reload in action!"
