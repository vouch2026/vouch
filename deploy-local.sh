#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting local build and deployment process..."

# 1. Install dependencies
echo "📦 Getting pub dependencies..."
flutter pub get

# 2. Generate code
echo "⚙️ Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Build the Flutter web project
echo "🌐 Building web project..."
flutter build web --release --no-source-maps

# 4. Copy vercel.json into build/web directory so rewrite/redirect rules are deployed
echo "📄 Copying vercel.json to build/web..."
cp vercel.json build/web/

# 5. Deploy to Vercel
echo "📤 Deploying to Vercel..."
vercel deploy --prod build/web

echo "🎉 Deployment completed successfully!"
