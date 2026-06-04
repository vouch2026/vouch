#!/bin/bash

# 1. Install Flutter
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable
fi

# 2. Add Flutter to the PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Explicitly enable web and disable analytics
flutter config --enable-web
flutter config --no-analytics
flutter precache --web

# 4. Get Dependencies
echo "Getting dependencies..."
flutter pub get

# 5. Generate Code (Freezed, JSON Serializable, etc.)
echo "Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# 6. Build the web project
echo "Building web project..."
# --no-source-maps reduces memory usage and build time
flutter build web --release --no-source-maps
