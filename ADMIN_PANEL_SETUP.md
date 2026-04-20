# Web-Only Admin Panel Setup

## Overview

Your restaurant app now has a dedicated web-only admin panel that can be deployed to Firebase Hosting. The admin panel is completely separate from the main universal app, making it easier to manage and deploy independently.

## Project Structure

```
lib/
├── main.dart              # Main app (all platforms)
├── main_admin.dart        # Admin panel (web-only) ⭐
├── app/
│   ├── app.dart          # Main app config
│   ├── app_admin.dart    # Admin app config ⭐
│   ├── router.dart       # Main router
│   └── router_admin.dart # Admin router ⭐
```

## Quick Start

### Option 1: Using the Deploy Script (Recommended)

#### Linux/macOS:
```bash
chmod +x deploy_admin.sh
./deploy_admin.sh
```

#### Windows:
```cmd
deploy_admin.bat
```

### Option 2: Manual Build & Deploy

1. **Build the admin panel:**
   ```bash
   flutter build web --target=lib/main_admin.dart --release
   ```

2. **Deploy to Firebase:**
   ```bash
   firebase deploy --only hosting:admin
   ```

## What's New

✅ **Separate Admin Entry Point** (`lib/main_admin.dart`)
- Minimal initialization
- Admin-focused routing
- Optimized for web

✅ **Admin Router** (`lib/app/router_admin.dart`)
- Language Selection
- Admin Login
- Dashboard

✅ **Firebase Configuration** (`firebase.json`)
- Web hosting enabled
- SPA rewriting configured
- Admin target setup

✅ **Deployment Scripts**
- `deploy_admin.sh` (Linux/macOS)
- `deploy_admin.bat` (Windows)

## Testing Locally

```bash
# Run the admin panel locally
flutter run -t lib/main_admin.dart -d chrome
```

## Production Deployment

```bash
# Full production deployment
firebase deploy --only hosting:admin

# Check deployment status
firebase hosting:channel:list

# View deployment details
firebase hosting:sites:list
```

## Architecture

### Main Universal App (`lib/main.dart`)
- Works on: Android, iOS, Web, Linux, macOS, Windows
- Features: Customer, Kitchen, Admin access control

### Admin Panel (`lib/main_admin.dart`)
- Works on: Web only
- Features: Admin dashboard, faster deployment
- Benefits: Separate from main app, web optimization

## Next Steps

1. ✅ Configure environment variables
2. ✅ Set up admin authentication in Firebase
3. ✅ Deploy using `./deploy_admin.sh`
4. ✅ Access at `https://cafeoder.web.app`

## Troubleshooting

**Build Fails:**
```bash
flutter clean
rm -rf build
flutter pub get
flutter build web --target=lib/main_admin.dart --release
```

**Deployment Fails:**
```bash
firebase logout
firebase login
firebase deploy --only hosting:admin
```

**Want to revert:**
All changes are isolated. The main app (`lib/main.dart`) is unchanged.

## Files Modified/Created

- ✨ `lib/main_admin.dart` - New admin entry point
- ✨ `lib/app/app_admin.dart` - New admin app configuration
- ✨ `lib/app/router_admin.dart` - New admin routing
- 📝 `firebase.json` - Updated with hosting config
- 📝 `deploy_admin.sh` - Deployment script (Linux/macOS)
- 📝 `deploy_admin.bat` - Deployment script (Windows)
- 📝 `ADMIN_DEPLOYMENT.md` - Full deployment guide

## Support

For questions or issues, refer to:
- [ADMIN_DEPLOYMENT.md](./ADMIN_DEPLOYMENT.md) - Detailed deployment guide
- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Flutter Web Documentation](https://flutter.dev/docs/get-started/web)
