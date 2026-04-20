#!/bin/bash

# Admin Panel Build and Deploy Script
# This script builds the admin panel for web and deploys to Firebase

set -e

echo "🔨 Building Admin Panel for Web..."
flutter clean
flutter pub get
flutter build web --target=lib/main_admin.dart --release

echo "✅ Build complete!"
echo ""
echo "📦 Deploying to Firebase Hosting..."
firebase deploy --only hosting:admin

echo ""
echo "🎉 Admin panel deployed successfully!"
echo "🌐 View your admin panel at: https://cafeoder.web.app"
