#!/bin/bash

# 1. Install Flutter (Cloudflare caches the environment, but it's safer to clone if missing)
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

# 4. Create .env file from Cloudflare Environment Variables
echo "Creating .env file..."
touch .env
echo "SUPABASE_URL=$SUPABASE_URL" >> .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env
echo "SUPABASE_ORG_BUCKET=${SUPABASE_ORG_BUCKET:-org-pictures}" >> .env
echo "SUPABASE_ANNOUNCEMENTS_BUCKET=${SUPABASE_ANNOUNCEMENTS_BUCKET:-announcement-pictures}" >> .env
EVENTS_BUCKET_VAL="${SUPABASE_EVENT_BUCKET:-${SUPABASE_EVENTS_BUCKET:-event-pictures}}"
echo "SUPABASE_EVENT_BUCKET=$EVENTS_BUCKET_VAL" >> .env
echo "SUPABASE_EVENTS_BUCKET=$EVENTS_BUCKET_VAL" >> .env
echo "SUPABASE_RECEIPTS_BUCKET=${SUPABASE_RECEIPTS_BUCKET:-receipt-pictures}" >> .env
echo "SUPABASE_HIGHLIGHTS_BUCKET=${SUPABASE_HIGHLIGHTS_BUCKET:-highlight-pictures}" >> .env
echo "SUPABASE_EXCUSE_BUCKET=${SUPABASE_EXCUSE_BUCKET:-excuse-pictures}" >> .env

# 5. Get Dependencies
echo "Getting dependencies..."
flutter pub get

# 6. Generate Code 
echo "Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

# 7. Build the web project with Wasm
echo "Building web project with WebAssembly..."
flutter build web --wasm --release --no-source-maps

# 8. Create the Cloudflare _headers file for Cross-Origin Isolation
echo "Generating Cloudflare _headers file..."
echo "/*" > build/web/_headers
echo "  Cross-Origin-Embedder-Policy: require-corp" >> build/web/_headers
echo "  Cross-Origin-Opener-Policy: same-origin" >> build/web/_headers