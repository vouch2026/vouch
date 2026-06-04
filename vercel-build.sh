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

# 5. Build the web project
echo "Building web project..."
# Use default renderer (auto) to avoid flag compatibility issues in some environments
flutter build web --release
