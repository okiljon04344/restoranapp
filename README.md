# Universal Restaurant App (QR オーダー & 店舗管理システム)

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
飲食店の店内オペレーションをデジタル化する **3つのロール統合型アプリケーション** です。  
1つのコードベースで **顧客（モバイル・Web）・キッチンスタッフ・店舗管理者** の画面を提供し、**日本語・英語・ウズベク語** の3言語をリアルタイムに切り替えられます。

### 主な機能
| ロール | 主な機能 |
|---|---|
| **顧客 (Customer)** | QRコードでのテーブル番号読み取り、カテゴリ別メニュー閲覧、カート管理、注文送信、リアルタイム注文ステータス追跡、スタッフ呼び出し |
| **キッチン (Kitchen KDS)** | 新規注文のリアルタイム受信、調理ステータス変更（受付 → 調理中 → 提供準備完了） |
| **管理者 (Admin)** | メニュー・カテゴリの CRUD 管理、在庫（食材・最小在庫アラート）管理、テーブル状況確認、スタッフ呼び出し対応、売上・注文ダッシュボード |

### 技術スタック
- **フレームワーク:** Flutter / Dart (Mobile, Web, Desktop 対応)
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

---

## English

### Overview
**Universal Restaurant App** unifies three restaurant workflows in a single Flutter codebase:
1. **Customer App:** QR code table scanning, multilingual menu browsing, cart & order placement, live order status tracking, and waiter call button.
2. **Kitchen Display (KDS):** Real-time order queue and status progression (`pending` → `preparing` → `ready`).
3. **Admin Dashboard:** Menu & category management, ingredient inventory tracking with low-stock alerts, table monitoring, and staff call notifications.

Supports **Japanese (`ja`)**, **English (`en`)**, and **Uzbek (`uz`)** with automatic device locale detection and persistent language switching.

---

## O'zbekcha

### Umumiy ma'lumot
**Universal Restaurant App** — restoran va kafelar uchun mijoz, oshxona va administrator tizimlarini bitta Flutter loyihasida birlashtirgan ko'p tilli (O'zbek, Yapon, Ingliz) ilova:
- **Mijoz ekrani:** QR kod orqali stolga ulanish, menyu, savatcha, buyurtma holatini jonli kuzatish va ofitsiant chaqirish.
- **Oshxona ekrani:** Tushgan buyurtmalarni real vaqtda ko'rish va tayyorlanish bosqichlarini boshqarish.
- **Admin panel:** Taomlar va kategoriyalarni boshqarish, ombor va masalliqlar qoldig'ini nazorat qilish, stollarni kuzatish.

---

© 2026 Okiljon Nabev — [Portfolio](https://okiljon04344.github.io) ・ [GitHub](https://github.com/okiljon04344)
