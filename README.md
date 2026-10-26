# Universal Restaurant App

[![CI](https://github.com/okiljon04344/restoranapp/actions/workflows/ci.yml/badge.svg)](https://github.com/okiljon04344/restoranapp/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2D6A4F?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![i18n](https://img.shields.io/badge/i18n-JA_%7C_EN_%7C_UZ-10a37f)

[日本語](#日本語) ・ [English](#english) ・ [O'zbekcha](#ozbekcha)

---

## 日本語

### 概要
飲食店の店内オペレーションをデジタル化する アプリケーションです。  
QR コードによるテーブル注文と店舗管理を 1 つの Flutter コードベースで実装しています。顧客・キッチンスタッフ・店舗管理者の画面を持ち、日本語・英語・ウズベク語を切り替えられます。

### 主な機能
| ロール | 主な機能 |
|---|---|
| **顧客 (Customer)** | QRコードでのテーブル番号読み取り、カテゴリ別メニュー閲覧、カート管理、注文送信、リアルタイム注文ステータス追跡、スタッフ呼び出し |
| **キッチン (Kitchen KDS)** | 新規注文のリアルタイム受信、調理ステータス変更（受付 → 調理中 → 提供準備完了） |
| **管理者 (Admin)** | メニュー・カテゴリの CRUD 管理、在庫（食材・最小在庫アラート）管理、テーブル状況確認、スタッフ呼び出し対応、売上・注文ダッシュボード |

### 技術スタック
- **フレームワーク:** Flutter / Dart
- **状態管理 & ルーティング:** `flutter_riverpod`, `go_router`
- **バックエンド:** Firebase Auth, Cloud Firestore
- **ローカル保存 & 多言語:** Hive, `flutter_localizations` (ARB による日本語・英語・ウズベク語対応)
- **デバイス連携:** `mobile_scanner` (QR コードスキャン)

### セットアップ・実行
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Firebase プロジェクトの設定（`lib/firebase_options.dart`）が必要です。

### 管理者権限
管理者権限は Firestore の `admins/{uid}` ドキュメントの有無で判定します（セキュリティルールとアプリの両方で同じ判定）。管理者の登録は Firebase コンソールまたは Admin SDK から行います。クライアントから `admins` コレクションへ書き込むことはできません。

### 管理画面の Web デプロイ
管理画面専用のエントリーポイント（`lib/main_admin.dart`）を Firebase Hosting にデプロイできます。
```bash
flutter build web --target=lib/main_admin.dart --release
firebase deploy --only hosting:admin
```

---

## English

### Overview
**Universal Restaurant App** unifies three restaurant workflows in a single Flutter codebase:
1. **Customer App:** QR code table scanning, multilingual menu browsing, cart & order placement, live order status tracking, and waiter call button.
2. **Kitchen Display (KDS):** Real-time order queue and status progression (`pending` → `preparing` → `ready`).
3. **Admin Dashboard:** Menu & category management, ingredient inventory tracking with low-stock alerts, table monitoring, and staff call notifications.

Supports Japanese (`ja`), English (`en`) and Uzbek (`uz`).

**Admin role:** admin access is determined by the existence of a Firestore document at `admins/{uid}`, checked both in the security rules and in the app. Admins are registered from the Firebase console or the Admin SDK; clients cannot write to `admins`.

**Admin web deploy:** `flutter build web --target=lib/main_admin.dart --release`, then `firebase deploy --only hosting:admin`.

---

## O'zbekcha

### Umumiy ma'lumot
**Universal Restaurant App** — restoran va kafelar uchun mijoz, oshxona va administrator tizimlarini bitta Flutter loyihasida birlashtirgan ko'p tilli (O'zbek, Yapon, Ingliz) ilova.
- **Mijoz ekrani:** QR kod orqali stolga ulanish, menyu, savatcha, buyurtma holatini jonli kuzatish va ofitsiant chaqirish.
- **Oshxona ekrani:** Tushgan buyurtmalarni real vaqtda ko'rish va tayyorlanish bosqichlarini boshqarish.
- **Admin panel:** Taomlar va kategoriyalarni boshqarish, ombor va masalliqlar qoldig'ini nazorat qilish, stollarni kuzatish.

Admin huquqi Firestore'dagi `admins/{uid}` hujjati mavjudligi bilan aniqlanadi; adminlar Firebase konsoli yoki Admin SDK orqali qo'shiladi.

---

© 2026 Okiljon Nabiev — [Portfolio](https://okiljon04344.github.io) ・ [GitHub](https://github.com/okiljon04344)
