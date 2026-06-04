#!/bin/bash

# 1. Install Flutter (using a specific version for stability)
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable
fi

# 2. Add Flutter to the PATH
export PATH="$PATH:$(pwd)/flutter/bin"

# 3. Disable Analytics and Pre-download Web artifacts
flutter config --no-analytics
flutter precache --web

# 4. Get Dependencies
echo "Getting dependencies..."
flutter pub get

# 5. Build the web project
echo "Building web project..."
# Using --web-renderer canvaskit for better performance, or html for faster load. 
# You can change this to 'html' if you prefer.
flutter build web --release --web-renderer canvaskit
