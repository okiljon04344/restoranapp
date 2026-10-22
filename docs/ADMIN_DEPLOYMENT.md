# Admin Panel Deployment Guide

This guide explains how to build and deploy the web-only admin panel to Firebase Hosting.

## Prerequisites

- Flutter SDK with web support enabled
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project configured (cafeoder)
- Admin access to your Firebase project

## Setup

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

Select your Firebase project when prompted.

## Building the Admin Panel

### Build for Web (Admin Only)

```bash
flutter build web --target=lib/main_admin.dart --release
```

This will create an optimized web build in `build/web/` using the admin-only app entry point.

## Deployment to Firebase Hosting

### Deploy to Firebase

```bash
firebase deploy --only hosting:admin
```

This command will:
- Upload the `build/web` directory to Firebase Hosting
- Use the "admin" hosting target configured in `firebase.json`
- Apply SPA rewrite rules for client-side routing
- Set cache control headers (max-age: 1 hour)

### Monitor Deployment

After deployment, you can:
- View your live admin panel at: `https://<project-id>.web.app`
- Check deployment status: `firebase hosting:channel:list`
- View logs: `firebase functions:log`

## Full Workflow

Complete steps to build and deploy:

```bash
# Build the web app
flutter clean
flutter pub get
flutter build web --target=lib/main_admin.dart --release

# Deploy to Firebase
firebase deploy --only hosting:admin
```

## Features

- **Web-Only**: Admin panel runs only on web browsers
- **Single Page App**: React to URL changes without page reloads
- **Responsive Design**: Works on desktop and tablet browsers
- **Firebase Integration**: All data synced with Firestore in real-time
- **Secure Authentication**: Admin login with role-based access

## Configuration

The admin app uses a simplified router (`router_admin.dart`) that includes:
- Language selection
- Admin login
- Dashboard access

To modify routes, edit `lib/app/router_admin.dart`.

## Troubleshooting

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter build web --target=lib/main_admin.dart --release
```

### Deployment Issues
```bash
# Check Firebase configuration
firebase use --list

# Verify hosting configuration
firebase hosting:sites:list

# View build folder
ls -la build/web
```

## Environment

- **Project ID**: cafeoder
- **Hosting URL**: https://cafeoder.web.app
- **Admin App Target**: lib/main_admin.dart
