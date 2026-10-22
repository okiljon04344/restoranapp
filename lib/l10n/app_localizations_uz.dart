// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Universal Restoran';

  @override
  String get welcomeTitle => 'Xush kelibsiz!';

  @override
  String get chooseLanguage => 'Davom etish uchun tilni tanlang';

  @override
  String get continueBtn => 'Davom etish →';

  @override
  String get menu => 'Menyu';

  @override
  String get cart => 'Savatcha';

  @override
  String get orders => 'Buyurtmalar';

  @override
  String get tableEntry => 'Stol tanlang';

  @override
  String get tableNumber => 'Stol raqami';

  @override
  String get tableHint => '1, 2, 3...';

  @override
  String get scanQr => 'QR-kodni skanerlang';

  @override
  String get enterTableManually => 'Stol raqamini kiriting';

  @override
  String get tableRequired => 'Stol raqamini kiriting';

  @override
  String get tableInvalid => 'Stol raqami son bo\'lishi kerak';

  @override
  String get tableOccupied => '⚠️ Stol Band';

  @override
  String get tableOccupiedMsg =>
      'Bu stol hozir ishlatilyapti. Davom ettirishni xohlaysizmi?';

  @override
  String get cancel => 'Bekor';

  @override
  String get continueAnyway => 'Davom etish';

  @override
  String get goToMenu => 'Menyuga o\'tish';

  @override
  String get checking => 'Tekshirilmoqda...';

  @override
  String qrScanned(String table) {
    return 'QR Skanerlandi: Stol $table';
  }

  @override
  String get invalidQr => 'Noto\'g\'ri QR kod. Qaytadan urinib ko\'ring.';

  @override
  String get scanQrDialog => 'Stol QR-ini Skanerlang';

  @override
  String get scanQrDialogContent =>
      'Stol QR-ini skanerlash uchun kamera ishlatamiz';

  @override
  String get openCamera => 'Kamera Oching';

  @override
  String get searchFood => 'Taomlarni qidirish...';

  @override
  String get addToCart => 'Savatchaga qo\'shish';

  @override
  String addedToCart(String item) {
    return '$item savatchaga qo\'shildi!';
  }

  @override
  String get noItemsFound => 'Taom topilmadi.';

  @override
  String get yourCart => 'Savatcham';

  @override
  String get cartEmpty => 'Savatcha bo\'sh';

  @override
  String get totalAmount => 'Jami summa';

  @override
  String get placeOrder => 'Buyurtma berish';

  @override
  String get orderPlaced => 'Buyurtma muvaffaqiyatli berildi!';

  @override
  String get orderError => 'Buyurtma berishda xato';

  @override
  String get som => 'so\'m';

  @override
  String get kitchenScreen => 'Oshxona ekrani';

  @override
  String get newOrders => 'Yangi buyurtmalar';

  @override
  String get cooking => 'Tayyorlanmoqda';

  @override
  String get ready => 'Tayyor';

  @override
  String get startCooking => 'Pishirishni boshlash';

  @override
  String get markReady => 'Tayyor deb belgilash';

  @override
  String get markServed => 'Yetkazildi deb belgilash';

  @override
  String get statusPending => 'Kutilmoqda';

  @override
  String get statusCooking => 'Tayyorlanmoqda';

  @override
  String get statusReady => 'Tayyor';

  @override
  String get statusServed => 'Yetkazildi';

  @override
  String get table => 'Stol';

  @override
  String get welcomeRestaurant => 'Restoranga xush kelibsiz';

  @override
  String get selectRole => 'Davom etish uchun rolni tanlang';

  @override
  String get customerMode => 'Mijoz rejimi';

  @override
  String get customerSubtitle => 'Stoldan taom buyurtma bering';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get adminSubtitle => 'Kategoriya, menyu va buyurtmalarni boshqarish';

  @override
  String get kitchenDisplay => 'Oshxona ekrani';

  @override
  String get kitchenSubtitle => 'Yangi buyurtmalarni kuzatish va tayyorlash';

  @override
  String get tableInfo => 'Stol raqami';

  @override
  String get tableOccupiedBadge => 'Bu stol band';

  @override
  String get orderTracking => 'Buyurtma kuzatuvi';

  @override
  String get all => 'Barchasi';

  @override
  String error(String msg) {
    return 'Xato: $msg';
  }

  @override
  String get reset => 'Qayta boshlash';

  @override
  String get restaurantDesc => 'Mazali taom, eng yaxshi xizmat';

  @override
  String get openMenu => 'Menyuni ochish';

  @override
  String get myOrders => 'Mening buyurtmalarim';

  @override
  String get callStaff => 'Xodim chaqirish';

  @override
  String get staffCalled => 'Xodim chaqirildi!';

  @override
  String get noActiveOrders => 'Bu stol uchun faol buyurtmalar yo\'q.';

  @override
  String get subtotal => 'Jami';

  @override
  String get requestBill => 'Hisob so\'rash';

  @override
  String get billRequested => 'Ofitsiant hisob uchun xabardor qilindi.';

  @override
  String get statusPreparing => 'Tayyorlanmoqda';

  @override
  String get statusDelivered => 'Yetkazildi';

  @override
  String get noOrdersInStage => 'Bu bosqichda buyurtmalar yo\'q.';

  @override
  String get qrScanTitle => 'QR Codeni Skanerlang';

  @override
  String get qrScanManualTitle => 'QR Kodni Kiritib Chiqing';

  @override
  String get confirm => 'Tasdiqlang';

  @override
  String get goBack => 'Orqaga qaytish';

  @override
  String get adminLogin => 'Admin Kirish';

  @override
  String get adminSignup => 'Admin Ro\'yxatdan o\'tish';

  @override
  String get login => 'Kirish';

  @override
  String get register => 'Ro\'yxatdan o\'tish';

  @override
  String get createAdminAccount => 'Yangi admin akkaunt yaratish';

  @override
  String get cancelOrder => 'Sifarishni Bekor Qilish';

  @override
  String get confirmCancelOrder => 'Bu sifarishni bekor qilishni xohlaysizmi?';

  @override
  String get enterTableNumber => 'Stol raqamini kiriting:';

  @override
  String get yes => 'Ha, Bekor Qilish';

  @override
  String get no => 'Yo\'q';

  @override
  String get logout => 'Chiqish';

  @override
  String get logoutConfirm => 'Sistemadan chiqmoqchisiz?';

  @override
  String get yesLogout => 'Ha, Chiqish';

  @override
  String get ready2 => 'Tayyorlandi';

  @override
  String get goToKitchen => 'Oshxonaga o\'tish';

  @override
  String get manageQrCodes => 'QR Kodlarni Boshqarish';

  @override
  String get editMenu => 'Menyunu Tahrirlash';

  @override
  String get webNoCameraTitle => 'Veb-da kamera mavjud emas';

  @override
  String get enterQrManually => 'Qr code-ni qo\'lda kiritib chiqing:';

  @override
  String get cameraNotAvailable => 'Kamera bu platform-da mavjud emas';

  @override
  String get enterQrManuallyShort =>
      'QR code ma\'lumotini qo\'lda kiritib chiqing:';
}
