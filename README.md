# Universal Restaurant App

Ready Flutter project skeleton for:
- Customer app
- Admin panel
- Kitchen screen

## Setup

1. Open the folder in your editor.
2. Run:
   ```bash
   flutter pub get
   ```
3. Connect Firebase:
   ```bash
   flutterfire configure
   ```
4. Replace `lib/firebase_options.dart` with your generated file.
5. Run the app:
   ```bash
   flutter run
   ```

## What is included

- Riverpod state management
- go_router navigation
- Firebase initialization with safe fallback
- Reusable app shell
- Demo restaurant menu, tables, and orders structure
- Clean folder structure for future scaling

## Next things you can add

- Real Firestore repositories
- QR table scan
- Printing receipts
- Delivery module
- Multi-branch support
- Uzbek / Japanese / English localization
