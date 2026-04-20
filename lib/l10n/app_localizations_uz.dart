// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get menu => 'Menyu';
  @override
  String get cart => 'Savatcha';
  @override
  String get orders => 'Buyurtmalar';
  @override
  String get chooseLanguage => 'Tilni tanlang';
  @override
  String get tableEntry => 'Stol tanlang';
  @override
  String get scanQr => 'QR-kodni skanerlang';
  @override
  String get enterTableManually => 'Stol raqamini kiriting';
  @override
  String get searchFood => 'Taomlarni qidirish...';
  @override
  String get addToCart => 'Savatchaga qo\'shish';
  @override
  String get orderNow => 'Buyurtma berish';
  @override
  String get total => 'Jami';
  @override
  String get statusPending => 'Kutilmoqda';
  @override
  String get statusCooking => 'Tayyorlanmoqda';
  @override
  String get statusReady => 'Tayyor';
  @override
  String get statusServed => 'Yetkazildi';
  @override
  String get adminDashboard => 'Admin paneli';
  @override
  String get kitchenOrders => 'Oshxona buyurtmalari';

  @override
  String get restaurantName => 'Universal Restoran';
  @override
  String get restaurantDesc => 'Mazali taomlar, eng yaxshi xizmat';
  @override
  String get tableNumber => 'Stol raqami';
  @override
  String get tableOccupied => 'Bu stol band';
  @override
  String get reset => 'Qayta';
  @override
  String get openMenu => 'Menyuni ochish';
  @override
  String get myOrders => 'Mening buyurtmalarim';
  @override
  String get callStaff => 'Xodim chaqirish';
  @override
  String get staffCalled => 'Xodim chaqirildi!';

  @override
  String get welcome => 'Xush kelibsiz!';
  @override
  String get enterTableOrScan => 'Stol raqamini kiriting yoki stolda QR codeni skanerlang.';
  @override
  String get tableNumberLabel => 'Stol raqami';
  @override
  String get tableNumberHint => '1, 2, 3...';
  @override
  String get goToMenu => 'Menyuga o\'tish';
  @override
  String get checking => 'Tekshirilmoqda...';
  @override
  String get scanQrTitle => 'QR Codeni Skanerlang';
  @override
  String get scanQrDescription => 'Stol QR-ini skanerlash uchun kamerani ishlatamiz';
  @override
  String get cancel => 'Bekor';
  @override
  String get openCamera => 'Kamera oching';
  @override
  String get enterTableNumber => 'Stol raqamini kiriting';
  @override
  String get tableNumberMustBeNumber => 'Stol raqami sonda bo\'lishi kerak';
  @override
  String get tableOccupiedTitle => 'Stol band';
  @override
  String get tableOccupiedMessage => 'Bu stol hozir ishlatilyapti. Davom ettirishni xohlaysizmi?';
  @override
  String get continueText => 'Davom etish';
  @override
  String get invalidQrCode => 'QR kod noto\'g\'ri. Qayta urinib ko\'ring.';
  @override
  String qrScannedTable(String tableNum) => 'QR skanerlandi: Stol $tableNum';
  @override
  String errorMessage(String message) => 'Xato: $message';

  @override
  String get all => 'Hammasi';
  @override
  String get noItemsFound => 'Hech narsa topilmadi.';
  @override
  String itemAdded(String item) => '$item qo\'shildi!';
  @override
  String get currency => 'so\'m';

  @override
  String get yourCart => 'Sizning savatchangiz';
  @override
  String get cartEmpty => 'Savatcha bo\'sh';
  @override
  String get totalAmount => 'Jami summa';
  @override
  String get confirmOrder => 'Buyurtmani tasdiqlash';

  @override
  String tableOrders(String tableId) => 'Stol $tableId - Buyurtmalar';
  @override
  String get noActiveOrders => 'Bu stol uchun faol buyurtmalar yo\'q.';
  @override
  String get subtotal => 'Jami';
  @override
  String get waitressNotified => 'Ofitsiant chaqirildi.';
  @override
  String get requestBill => 'Hisob so\'rash';
  @override
  String get preparing => 'Tayyorlanmoqda';
  @override
  String get ready => 'Tayyor';
  @override
  String get delivered => 'Yetkazildi';

  @override
  String get kitchenScreen => 'Oshxona ekrani';
  @override
  String get newOrders => 'Yangi buyurtmalar';
  @override
  String get cooking => 'Tayyorlanmoqda';
  @override
  String get startCooking => 'Tayyorlashni boshlash';
  @override
  String get markAsReady => 'Tayyor deb belgilash';
  @override
  String get markAsServed => 'Yetkazildi deb belgilash';
  @override
  String get noOrdersInStage => 'Bu bosqichda buyurtmalar yo\'q.';
  @override
  String get items => 'ta';

  @override
  String get menuManagement => 'Menyu boshqaruvi';
  @override
  String get cancelOrderByTable => 'Stol bo\'yicha buyurtmani bekor qilish';
  @override
  String get staffCalls => 'Xodim chaqiruvlari';
  @override
  String get activeOrders => 'Faol buyurtmalar';
  @override
  String get noOrdersYet => 'Hali buyurtmalar yo\'q';
  @override
  String get enterTableNumberColon => 'Stol raqamini kiriting:';
  @override
  String get cancelOrderBtn => 'Buyurtmani bekor qilish';
  @override
  String tableOrderCancelled(String tableNum) => 'Stol #$tableNum buyurtmasi bekor qilindi';
  @override
  String get noActiveOrderForTable => 'Bu stol uchun faol buyurtma topilmadi';
  @override
  String get staffCallResolved => 'Xodim chaqiruvi bajarildi';
  @override
  String get orderCancelled => 'Buyurtma bekor qilindi';
  @override
  String get confirmTitle => 'Tasdiqlash';
  @override
  String cancelOrderForTable(String tableNumber) => 'Stol #$tableNumber buyurtmasini bekor qilasizmi?';
  @override
  String get no => 'Yo\'q';
  @override
  String get yesCancel => 'Ha, bekor qilish';
  @override
  String get categories => 'Kategoriyalar';
  @override
  String get menuItems => 'Menyu mahsulotlari';
  @override
  String get system => 'Tizim';
  @override
  String get live => 'Jonli';
  @override
  String get resolve => 'Bajarish';
  @override
  String calledAt(String time) => 'Chaqirilgan: $time';
  @override
  String get tableLabel => 'Stol';

  @override
  String get adminLogin => 'Admin kirish';
  @override
  String get emailAndPasswordRequired => 'Email va parolni kiriting';
  @override
  String get email => 'Email';
  @override
  String get emailHint => 'admin@gmail.com';
  @override
  String get password => 'Parol';
  @override
  String get login => 'Kirish';
  @override
  String get createNewAdmin => 'Yangi admin akkaunt yaratish';
  @override
  String get debugFirebase => 'Debug - Firebase holati';
  @override
  String get noAdminRights => 'Sizning admin huquqlaringiz yo\'q.';
  @override
  String get userNotFound => 'Bu emailda foydalanuvchi topilmadi';
  @override
  String get wrongPassword => 'Parol noto\'g\'ri';
  @override
  String get invalidCredential => 'Email yoki parol noto\'g\'ri';
  @override
  String get networkError => 'Internetga ulanishda xato';
  @override
  String get tooManyRequests => 'Juda ko\'p urinish. Birozdan so\'ng qayta urinib ko\'ring';

  @override
  String get welcomeToApp => 'Restoran ilovasiga xush kelibsiz';
  @override
  String get selectRoleToContinue => 'Davom etish uchun rolingizni tanlang';
  @override
  String get customerMode => 'Mijoz rejimi';
  @override
  String get customerSubtitle => 'Stolingizdan mazali taomlar buyurtma qiling';
  @override
  String get adminPanel => 'Admin paneli';
  @override
  String get adminSubtitle => 'Kategoriyalar, menyu va buyurtmalarni boshqaring';
  @override
  String get kitchenDisplay => 'Oshxona ekrani';
  @override
  String get kitchenSubtitle => 'Yangi va tayyorlanayotgan buyurtmalar';

  @override
  String get selectLanguage => 'Tilni tanlang';
  @override
  String get selectLanguageSubtitle => 'O\'zingizga qulay tilni tanlang';
  @override
  String deviceLanguage(String language) => 'Qurilma tili: $language';
  @override
  String get failedToSaveLanguage => 'Til sozlamasini saqlashda xato';
  @override
  String get errorSelectingLanguage => 'Tilni tanlashda xato';
}
