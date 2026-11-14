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
飲食店の店内オペレーションを 1 つの Flutter コードベースで扱うアプリです。お客様のテーブル QR 注文、キッチン（スタッフ）画面、管理パネルを含み、日本語・英語・ウズベク語を切り替えられます。データは Cloud Firestore、認証は Firebase Auth を使用します。オンライン決済は含みません。支払いはスタッフが「会計を締める」操作で記録します。

### ロールと機能
| ロール | 認証 | 機能 |
|---|---|---|
| **お客様** | 匿名サインイン（自動） | テーブル QR の読み取り／番号入力（登録済みで有効なテーブルのみ）、メニュー閲覧（売り切れ表示）、カート、注文、注文ステータスの追跡、受付前の注文キャンセル、スタッフ呼び出し、会計依頼 |
| **キッチン** | メール／パスワード + `staff/{uid}` | 注文キュー（受付 → 調理中 → 準備完了 → 提供済み）、注文キャンセル、テーブルごとの会計締め（支払い済みの記録）、呼び出し対応 |
| **管理者** | メール／パスワード + `admins/{uid}` | キッチンの全機能に加え、ダッシュボード、注文一覧、テーブル登録・有効／無効・QR 印刷、メニュー／カテゴリ／レシピ管理、食材在庫、スタッフ申請の承認・取り消し |

### 注文ライフサイクル
`pending`（受付待ち）→ `preparing`（調理中）→ `ready`（準備完了）→ `served`（提供済み）→ `paid`（支払い済み）。`cancelled` は `pending` と `preparing` からのみ可能です。
- お客様がキャンセルできるのは `pending` の自分の注文だけです。スタッフは `pending` / `preparing` をキャンセルできます。
- テーブルに `pending`〜`served` の注文がある間、そのテーブルは「使用中」です。スタッフが会計を締めると、そのテーブルの `served` の注文がすべて `paid` になり、テーブルが空きます。キッチンに残っている注文がある間は会計を締められません。
- 状態遷移はリポジトリ内の Firestore トランザクションで検証します。

### 在庫
- メニューごとにレシピ（食材と 1 人前の使用量）を登録します。
- キッチンが注文を受け付ける（`pending → preparing`）ときに、1 つのトランザクションで食材在庫を差し引き、価格をメニューから再計算します。在庫が足りない場合は受け付けられず、不足している食材名が表示されます。
- 在庫が 1 人前に満たなくなったメニューには `outOfStock` フラグが付き、お客様の画面で「売り切れ」と表示され注文できません。在庫の編集・レシピの変更・`preparing` の注文のキャンセル（在庫を戻します）でフラグは再計算されます。
- 管理者はメニューを手動で非表示（`isAvailable`）にもできます。
- 最小在庫以下の食材は在庫画面とダッシュボードで警告表示されます。

### ダッシュボードの集計
直近 7 日間の注文から計算します。売上は `paid` の注文のみを、会計を締めた日で集計します（本日／今週）。注文数はキャンセルを除きます。人気ランキングは今週の提供数（数量）の上位 5 件です。

### Firestore の構成
```
admins/{uid}                 管理者（コンソール／Admin SDK からのみ作成）
staff/{uid}                  キッチンスタッフ（管理者が承認すると作成）
staffRequests/{uid}          スタッフのアクセス申請
cafes/main_cafe/
  tables/table_{n}           number, name, isActive
  categories/{id}            name, sortOrder
  menuItems/{id}             name, price, categoryId, isAvailable, outOfStock, recipe[]
  ingredients/{id}           name, unit, quantity, minimumQuantity
  orders/{id}                tableNumber, tableId, customerUid, items[], total, status, createdAt, paidAt
  calls/{id}                 tableNumber, type (staff|bill), status
```
セキュリティルール（`firestore.rules`）の要点: メニューとテーブルは誰でも読めます。注文の作成はサインイン済みで、登録済みかつ有効なテーブルに対する自分の `pending` 注文のみ。注文の読み取りは本人またはスタッフのみ。食材はスタッフのみ読み取り可、キッチンは数量のみ更新可。メニュー・テーブル・カテゴリ・スタッフの書き込みは管理者のみ。

### セットアップ
1. Firebase プロジェクトを用意し、`flutterfire configure` で `lib/firebase_options.dart` を生成します（リポジトリ内のファイルは作者のプロジェクト用です）。
2. Firebase コンソールの Authentication で **メール／パスワード** と **匿名** を有効にし、Firestore データベースを作成します。
3. ルールをデプロイします: `firebase use <project-id>` → `firebase deploy --only firestore:rules`。クエリは単一フィールドのみなので複合インデックスは不要です。
4. **最初の管理者**: コンソールの Authentication でユーザーを作成し、その UID をドキュメント ID として Firestore に `admins/{uid}` を作成します（フィールドは任意）。クライアントから `admins` には書き込めません。
5. **キッチンアカウント**: スタッフがログイン画面の「スタッフアカウントを申請」でアカウントを作成 → 管理者が管理パネルの「スタッフ」で承認します。取り消しも同じ画面で行います。
6. 管理パネルでテーブルを登録して QR を印刷し、カテゴリ・食材・メニュー（レシピ）を登録します。

```bash
flutter pub get
flutter gen-l10n          # ARB を変更した場合
flutter analyze --no-fatal-infos
flutter test
flutter run               # お客様 + スタッフ（デスクトップ／Web ではロール選択画面）
flutter run -t lib/main_admin.dart -d chrome   # スタッフ専用エントリー
```
スタッフ専用エントリーの Web デプロイ: `flutter build web --target=lib/main_admin.dart --release` → `firebase deploy --only hosting`。

### テストと検証範囲
- `flutter test`: `fake_cloud_firestore` を使ったリポジトリテスト（注文ライフサイクル、在庫の差し引きと復元、会計締め、テーブル検証、スタッフ承認、集計）と、主要画面のウィジェットテスト。
- `firestore_rules_test/`: Firestore エミュレーター上で `firestore.rules` を 3 つのロールについて検証するテスト（`cd firestore_rules_test && npm install && npm test`、Node 20 以上と Java 21 以上が必要）。
- CI（GitHub Actions）は上記 2 つと `flutter analyze --no-fatal-infos` を実行します。

**アプリ自体を実際の Firebase プロジェクトや実機で動かした確認は行っていません。** 匿名サインイン、カメラでの QR 読み取り、QR 印刷ダイアログ、通知音は本番相当の環境で確認してください。

### 既知の制限
- オンライン決済はありません。
- 注文は端末（匿名セッション）に紐づくため、同じテーブルの別の端末の注文はお客様同士では見えません（スタッフ側ではテーブル単位で合算されます）。
- QR の内容は `table_{番号}` で、番号の手入力も可能です。店外からの注文を防ぐ仕組みはありません。
- 注文作成時の金額はクライアントが送信します。キッチンが受け付ける時点でメニュー価格から再計算されます。

---

## English

### Overview
One Flutter codebase for in-restaurant operations: customer QR table ordering, a kitchen/staff screen and an admin panel, in Japanese, English and Uzbek. Data lives in Cloud Firestore and sign-in uses Firebase Auth. There is no online payment; staff record a payment by closing the table's bill.

### Roles and features
| Role | Sign-in | Features |
|---|---|---|
| **Customer** | anonymous (automatic) | Scan the table QR code or type the number (only registered, enabled tables are accepted), browse the menu (sold-out items are marked), cart, place orders, track order status, cancel an order before it is accepted, call staff, request the bill |
| **Kitchen** | email/password + `staff/{uid}` | Order queue (accept → cooking → ready → served), cancel orders, close a table's bill (records it as paid), handle calls |
| **Admin** | email/password + `admins/{uid}` | Everything the kitchen can do, plus dashboard, order list, table registration / enable / disable / QR printing, menu / category / recipe management, ingredient stock, approving and revoking staff accounts |

### Order lifecycle
`pending` → `preparing` → `ready` → `served` → `paid`. `cancelled` is reachable from `pending` and `preparing` only.
- A customer can cancel only their own `pending` order. Staff can cancel `pending` and `preparing` orders.
- A table is "occupied" while it has orders in `pending`…`served`. When staff close the bill, every `served` order of the table becomes `paid` and the table is free again. The bill cannot be closed while an order of the table is still in the kitchen.
- Transitions are validated inside Firestore transactions in the repository.

### Inventory
- Each menu item has a recipe (ingredients and the quantity one portion uses).
- When the kitchen accepts an order (`pending → preparing`), one transaction deducts the ingredients from stock and re-prices the order from the menu. If stock is short the order is not accepted and the missing ingredient is shown.
- A menu item whose ingredients no longer cover one portion gets the `outOfStock` flag; customers see it as "Sold out" and cannot order it. The flag is recomputed when stock or a recipe is edited and when a `preparing` order is cancelled (its stock is returned).
- Admins can also take an item off the menu manually (`isAvailable`).
- Ingredients at or below their minimum quantity are highlighted on the stock page and the dashboard.

### Dashboard figures
Computed from the orders of the last 7 days. Revenue counts `paid` orders only, on the day the bill was closed (today / this week). Order counts exclude cancelled orders. The ranking is this week's top 5 items by portions sold.

### Firestore layout
```
admins/{uid}                 admins (created from the console / Admin SDK only)
staff/{uid}                  kitchen staff (created when an admin approves a request)
staffRequests/{uid}          staff access requests
cafes/main_cafe/
  tables/table_{n}           number, name, isActive
  categories/{id}            name, sortOrder
  menuItems/{id}             name, price, categoryId, isAvailable, outOfStock, recipe[]
  ingredients/{id}           name, unit, quantity, minimumQuantity
  orders/{id}                tableNumber, tableId, customerUid, items[], total, status, createdAt, paidAt
  calls/{id}                 tableNumber, type (staff|bill), status
```
Security rules (`firestore.rules`) in short: menu and tables are world-readable. An order can be created only by a signed-in session, as its own `pending` order, for a registered and enabled table. Orders are readable by their owner and by staff. Ingredients are readable by staff only; the kitchen may change quantities only. Menu, tables, categories and staff documents are writable by admins only.

### Setup
1. Create a Firebase project and generate `lib/firebase_options.dart` with `flutterfire configure` (the file in the repository points at the author's project).
2. In the Firebase console enable the **Email/Password** and **Anonymous** sign-in providers and create the Firestore database.
3. Deploy the rules: `firebase use <project-id>`, then `firebase deploy --only firestore:rules`. All queries are single-field, so no composite index is needed.
4. **First admin:** create a user in Authentication, then create the Firestore document `admins/{uid}` with that user's UID as the document id (any fields). Clients cannot write to `admins`.
5. **Kitchen accounts:** the staff member creates an account with "Request a staff account" on the sign-in page; an admin approves it under "Staff" in the admin panel. Access is revoked on the same page.
6. In the admin panel register the tables and print their QR codes, then add categories, ingredients and menu items (with recipes).

```bash
flutter pub get
flutter gen-l10n          # after changing the ARB files
flutter analyze --no-fatal-infos
flutter test
flutter run               # customer + staff (role selection on desktop / web)
flutter run -t lib/main_admin.dart -d chrome   # staff-only entry point
```
Web deploy of the staff-only entry point: `flutter build web --target=lib/main_admin.dart --release`, then `firebase deploy --only hosting`.

### Tests and what was verified
- `flutter test`: repository tests on `fake_cloud_firestore` (order lifecycle, stock deduction and return, bill closing, table validation, staff approval, analytics) and widget tests of the main screens.
- `firestore_rules_test/`: checks `firestore.rules` for the three roles against the Firestore emulator (`cd firestore_rules_test && npm install && npm test`; needs Node 20+ and Java 21+).
- CI (GitHub Actions) runs both, plus `flutter analyze --no-fatal-infos`.

**The app itself has not been run against a real Firebase project or on a device.** Check anonymous sign-in, camera QR scanning, the QR print dialog and the alert sound in a production-like environment.

### Known limitations
- No online payment.
- Orders belong to a device (anonymous session), so guests at the same table do not see each other's orders (staff see them combined per table).
- The QR payload is `table_{number}` and the number can also be typed; nothing prevents ordering from outside the restaurant.
- The total of a new order is sent by the client; it is recomputed from menu prices when the kitchen accepts the order.

---

## O'zbekcha

### Umumiy ma'lumot
Restoran ichidagi ish jarayonlari uchun bitta Flutter loyihasi: mijozlar uchun stol QR kodi orqali buyurtma, oshxona (xodimlar) ekrani va admin panel. Yapon, ingliz va o'zbek tillarida ishlaydi. Ma'lumotlar Cloud Firestore'da saqlanadi, kirish Firebase Auth orqali. Onlayn to'lov yo'q; to'lovni xodim stol hisobini yopish orqali qayd etadi.

### Rollar va imkoniyatlar
| Rol | Kirish | Imkoniyatlar |
|---|---|---|
| **Mijoz** | anonim (avtomatik) | Stol QR kodini skanerlash yoki raqamni kiritish (faqat ro'yxatdagi va yoqilgan stollar qabul qilinadi), menyu (tugagan taomlar belgilanadi), savatcha, buyurtma berish, buyurtma holatini kuzatish, qabul qilinmagan buyurtmani bekor qilish, xodim chaqirish, hisob so'rash |
| **Oshxona** | email/parol + `staff/{uid}` | Buyurtmalar navbati (qabul → tayyorlanmoqda → tayyor → berildi), buyurtmani bekor qilish, stol hisobini yopish (to'langan deb qayd etish), chaqiruvlarga javob berish |
| **Admin** | email/parol + `admins/{uid}` | Oshxonaning barcha imkoniyatlari, shuningdek dashboard, buyurtmalar ro'yxati, stollarni ro'yxatga olish / yoqish / o'chirish / QR chop etish, menyu / kategoriya / retsept boshqaruvi, masalliqlar ombori, xodim so'rovlarini tasdiqlash va bekor qilish |

### Buyurtma bosqichlari
`pending` → `preparing` → `ready` → `served` → `paid`. `cancelled` holatiga faqat `pending` va `preparing` dan o'tish mumkin.
- Mijoz faqat o'zining `pending` buyurtmasini bekor qila oladi. Xodimlar `pending` va `preparing` buyurtmalarni bekor qila oladi.
- Stolda `pending`…`served` holatidagi buyurtma bor ekan, stol "band" hisoblanadi. Xodim hisobni yopganda stolning barcha `served` buyurtmalari `paid` bo'ladi va stol bo'shaydi. Stol buyurtmasi hali oshxonada bo'lsa, hisobni yopib bo'lmaydi.
- O'tishlar repozitoriydagi Firestore tranzaksiyalarida tekshiriladi.

### Ombor
- Har bir taomga retsept biriktiriladi (masalliqlar va bir porsiyaga ketadigan miqdor).
- Oshxona buyurtmani qabul qilganda (`pending → preparing`) bitta tranzaksiyada masalliqlar ombordan ayriladi va narx menyudan qayta hisoblanadi. Masalliq yetmasa, buyurtma qabul qilinmaydi va yetishmayotgan masalliq nomi ko'rsatiladi.
- Masalliqlari bir porsiyaga yetmay qolgan taomga `outOfStock` belgisi qo'yiladi; mijoz uni "Tugagan" deb ko'radi va buyurtma bera olmaydi. Belgi ombor yoki retsept tahrirlanganda hamda `preparing` buyurtma bekor qilinganda (masalliqlar qaytariladi) qayta hisoblanadi.
- Admin taomni menyudan qo'lda ham olib qo'yishi mumkin (`isAvailable`).
- Minimal miqdorga tushgan masalliqlar ombor sahifasida va dashboardda ogohlantirish bilan ko'rsatiladi.

### Dashboard ko'rsatkichlari
Oxirgi 7 kunlik buyurtmalardan hisoblanadi. Tushumga faqat `paid` buyurtmalar, hisob yopilgan kun bo'yicha kiradi (bugun / shu hafta). Buyurtmalar soniga bekor qilinganlar kirmaydi. Reyting — shu haftada eng ko'p sotilgan 5 ta taom (porsiyalar soni bo'yicha).

### Firestore tuzilishi
```
admins/{uid}                 adminlar (faqat konsol / Admin SDK orqali yaratiladi)
staff/{uid}                  oshxona xodimlari (admin so'rovni tasdiqlaganda yaratiladi)
staffRequests/{uid}          xodimlarning ruxsat so'rovlari
cafes/main_cafe/
  tables/table_{n}           number, name, isActive
  categories/{id}            name, sortOrder
  menuItems/{id}             name, price, categoryId, isAvailable, outOfStock, recipe[]
  ingredients/{id}           name, unit, quantity, minimumQuantity
  orders/{id}                tableNumber, tableId, customerUid, items[], total, status, createdAt, paidAt
  calls/{id}                 tableNumber, type (staff|bill), status
```
Xavfsizlik qoidalari (`firestore.rules`) qisqacha: menyu va stollarni hamma o'qiy oladi. Buyurtmani faqat tizimga kirgan sessiya, o'z nomidan, `pending` holatida, ro'yxatdagi va yoqilgan stol uchun yarata oladi. Buyurtmani faqat egasi va xodimlar o'qiy oladi. Masalliqlarni faqat xodimlar o'qiydi; oshxona faqat miqdorni o'zgartira oladi. Menyu, stollar, kategoriyalar va xodim hujjatlarini faqat admin yoza oladi.

### O'rnatish
1. Firebase loyihasini yarating va `flutterfire configure` orqali `lib/firebase_options.dart` faylini yarating (repozitoriydagi fayl muallif loyihasiga tegishli).
2. Firebase konsolida Authentication bo'limida **Email/Password** va **Anonymous** usullarini yoqing hamda Firestore bazasini yarating.
3. Qoidalarni joylang: `firebase use <project-id>`, so'ng `firebase deploy --only firestore:rules`. Barcha so'rovlar bitta maydon bo'yicha, shuning uchun kompozit indeks kerak emas.
4. **Birinchi admin:** Authentication'da foydalanuvchi yarating, so'ng Firestore'da hujjat identifikatori shu foydalanuvchining UID'si bo'lgan `admins/{uid}` hujjatini yarating (maydonlar ixtiyoriy). Klient `admins` ga yoza olmaydi.
5. **Oshxona akkauntlari:** xodim kirish sahifasida "Xodim akkauntini so'rash" orqali akkaunt yaratadi; admin uni admin paneldagi "Xodimlar" bo'limida tasdiqlaydi. Ruxsat ham shu yerda bekor qilinadi.
6. Admin panelda stollarni ro'yxatga oling va QR kodlarini chop eting, so'ng kategoriya, masalliq va taomlarni (retsepti bilan) qo'shing.

```bash
flutter pub get
flutter gen-l10n          # ARB fayllari o'zgarganda
flutter analyze --no-fatal-infos
flutter test
flutter run               # mijoz + xodimlar (desktop / web'da rol tanlash sahifasi)
flutter run -t lib/main_admin.dart -d chrome   # faqat xodimlar uchun kirish nuqtasi
```
Faqat xodimlar uchun kirish nuqtasini web'ga joylash: `flutter build web --target=lib/main_admin.dart --release`, so'ng `firebase deploy --only hosting`.

### Testlar va nima tekshirilgan
- `flutter test`: `fake_cloud_firestore` asosidagi repozitoriy testlari (buyurtma bosqichlari, ombordan ayirish va qaytarish, hisobni yopish, stolni tekshirish, xodimni tasdiqlash, statistika) va asosiy ekranlarning vidjet testlari.
- `firestore_rules_test/`: `firestore.rules` ni uchta rol uchun Firestore emulyatorida tekshiradi (`cd firestore_rules_test && npm install && npm test`; Node 20+ va Java 21+ kerak).
- CI (GitHub Actions) ikkalasini hamda `flutter analyze --no-fatal-infos` ni ishga tushiradi.

**Ilovaning o'zi haqiqiy Firebase loyihasida yoki qurilmada ishga tushirib ko'rilmagan.** Anonim kirish, kamera orqali QR skanerlash, QR chop etish oynasi va ogohlantirish ovozini real muhitda tekshiring.

### Ma'lum cheklovlar
- Onlayn to'lov yo'q.
- Buyurtmalar qurilmaga (anonim sessiyaga) bog'langan, shuning uchun bir stoldagi mehmonlar bir-birining buyurtmasini ko'rmaydi (xodimlar ularni stol bo'yicha birga ko'radi).
- QR kod mazmuni `table_{raqam}` va raqamni qo'lda kiritish ham mumkin; restoran tashqarisidan buyurtma berishni cheklaydigan mexanizm yo'q.
- Yangi buyurtma summasini klient yuboradi; oshxona buyurtmani qabul qilganda u menyu narxlaridan qayta hisoblanadi.

---

© 2026 Okiljon Nabiev — [Portfolio](https://okiljon04344.github.io) ・ [GitHub](https://github.com/okiljon04344)
