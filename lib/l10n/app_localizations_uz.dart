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

  @override
  String get adminPanelSubtitle => 'Restoran boshqaruvi';

  @override
  String get dashboard => 'Boshqaruv paneli';

  @override
  String get dashboardSubtitle =>
      'Bugungi statistika va real vaqt ma\'lumotlari';

  @override
  String get todayRevenue => 'Bugungi daromad';

  @override
  String get orderCount => 'Buyurtmalar soni';

  @override
  String get averageOrder => 'O\'rtacha buyurtma';

  @override
  String get menuItemsCount => 'Menyu mahsulotlari';

  @override
  String get categoriesLabel => 'Kategoriyalar';

  @override
  String get topOrdered => 'Eng ko\'p buyurtma qilingan';

  @override
  String get statusCompleted => 'Tugallandi';

  @override
  String get staffCalls => 'Xodim chaqiruvlari';

  @override
  String staffCallAtTable(String table) {
    return 'Stol $table - xodim chaqirdi';
  }

  @override
  String get markDone => 'Tayyorlandi';

  @override
  String get staffCallResolved => 'Xodim chaqiruvi bajarildi';

  @override
  String get noStaffCalls => 'Hozircha chaqiruvlar yo\'q';

  @override
  String get staffRequested => 'Xodim chaqirilmoqda';

  @override
  String get searchOrdersHint => 'Stol yoki buyurtma ID bo\'yicha qidiring...';

  @override
  String get noOrdersFound => 'Buyurtmalar topilmadi';

  @override
  String tableNumberLabel(String table) {
    return 'Stol #$table';
  }

  @override
  String orderNumberLabel(String number) {
    return 'Buyurtma #$number';
  }

  @override
  String get kitchenView => 'Oshxona ko\'rinishi';

  @override
  String get qrGenerator => 'QR kod generatori';

  @override
  String get menuManagement => 'Menyu boshqaruvi';

  @override
  String confirmCancelTableOrder(String table) {
    return 'Stol #$table buyurtmasini bekor qilmoqchimisiz?';
  }

  @override
  String get sidebarKitchen => 'Oshxona';

  @override
  String get ingredients => 'Masalliqlar';

  @override
  String get qrCodes => 'QR kodlar';

  @override
  String get kitchenOrdersTitle => 'Oshxona buyurtmalari';

  @override
  String get noOrdersAtMoment => 'Hozircha buyurtmalar yo\'q';

  @override
  String tableWithNumber(String table) {
    return 'Stol $table';
  }

  @override
  String get generateTableQrCodes => 'Stollar uchun QR kodlar yaratish';

  @override
  String get qrSelectHint =>
      'QR kod yaratiladigan stollarni tanlang. Mijozlar stolida telefon orqali QR kodni skanerlashi mumkin.';

  @override
  String selectedTablesCount(String count) {
    return 'Tanlangan stollar: $count';
  }

  @override
  String get clearAll => 'Hammasini tozalash';

  @override
  String get downloadQrCodes => 'QR kodlarni yuklab olish';

  @override
  String get selectTables => 'Stollarni tanlang';

  @override
  String get qrCodesReady => 'QR kodlar tayyor';

  @override
  String qrGeneratedMessage(String count) {
    return '$count ta stol uchun QR kodlar yaratildi.\\n\\nEndi siz:\\n- Chop etishingiz\\n- Ekranlarda ko\'rsatishingiz\\n- Mijozlarga ulashishingiz mumkin';
  }

  @override
  String get ok => 'OK';

  @override
  String get ingredientsManagement => 'Masalliqlar boshqaruvi';

  @override
  String get newIngredient => 'Yangi masalliq';

  @override
  String get ingredientsSubtitle =>
      'Taom tayyorlash uchun kerakli masalliqlar ro\'yxati';

  @override
  String lowStockAlert(String count) {
    return 'Kam qolgan ($count ta masalliq)';
  }

  @override
  String get lowStock => 'Kam qolgan';

  @override
  String get updateAction => 'Yangilash';

  @override
  String get noIngredientsFound => 'Masalliq topilmadi';

  @override
  String get editAction => 'Tahrirlash';

  @override
  String get deleteAction => 'O\'chirish';

  @override
  String minQuantityShort(String value) {
    return 'Min: $value';
  }

  @override
  String get addIngredientTitle => 'Yangi masalliq qo\'shish';

  @override
  String get editIngredientTitle => 'Masalliqni tahrirlash';

  @override
  String get ingredientName => 'Masalliq nomi';

  @override
  String get unitLabel => 'Birlik';

  @override
  String get quantityLabel => 'Miqdori';

  @override
  String get minimumQuantityLabel => 'Minimal miqdor';

  @override
  String get fillAllFields => 'Barcha maydonlarni to\'ldiring';

  @override
  String get ingredientAdded => 'Masalliq qo\'shildi';

  @override
  String get ingredientUpdated => 'Masalliq yangilandi';

  @override
  String get ingredientDeleted => 'Masalliq o\'chirildi';

  @override
  String get addAction => 'Qo\'shish';

  @override
  String get saveAction => 'Saqlash';

  @override
  String get deleteIngredientConfirm =>
      'Ushbu masalliqni o\'chirib tashlamoqchimisiz?';

  @override
  String get yesDelete => 'Ha, o\'chirish';

  @override
  String get unitPiece => 'dona';

  @override
  String get unitKg => 'kg';

  @override
  String get unitGram => 'g';

  @override
  String get unitLiter => 'l';

  @override
  String get unitMl => 'ml';

  @override
  String get unitBox => 'quti';

  @override
  String get unitPack => 'qadoq';

  @override
  String get fillRequiredFields => 'Barcha majburiy maydonlarni to\'ldiring';

  @override
  String get menuItemAdded => 'Menyu mahsuloti qo\'shildi';

  @override
  String get addNewMenuItem => 'Yangi menyu mahsulotini qo\'shish';

  @override
  String get itemNameRequired => 'Mahsulot nomi *';

  @override
  String get itemNameHint => 'masalan, Tovuqli palov';

  @override
  String get descriptionLabel => 'Tavsif';

  @override
  String get itemDescriptionHint => 'Mahsulot tavsifi...';

  @override
  String get priceRequired => 'Narxi *';

  @override
  String get categoryRequired => 'Kategoriya *';

  @override
  String get newLabel => 'Yangi';

  @override
  String get imageUrl => 'Rasm URL manzili';

  @override
  String get addingInProgress => 'Qo\'shilmoqda...';

  @override
  String get addMenuItem => 'Menyu mahsulotini qo\'shish';

  @override
  String get menuItems => 'Menyu mahsulotlari';

  @override
  String get noMenuItemsYet => 'Hozircha menyu mahsulotlari yo\'q';

  @override
  String get deleteItem => 'Mahsulotni o\'chirish';

  @override
  String get confirmDeleteItem => 'Bu mahsulotni o\'chirishni xohlaysizmi?';

  @override
  String get itemDeleted => 'Mahsulot o\'chirildi';

  @override
  String get createNewCategory => 'Yangi kategoriya yaratish';

  @override
  String get categoryNameHint => 'Kategoriya nomi';

  @override
  String get createAction => 'Yaratish';

  @override
  String get categoryCreated => 'Kategoriya yaratildi';

  @override
  String get enterCategoryName => 'Kategoriya nomini kiriting';

  @override
  String torchError(String error) {
    return 'Chiroq xatosi: $error';
  }

  @override
  String cameraError(String error) {
    return 'Kamera xatosi: $error';
  }

  @override
  String get placeQrInFrame => 'QR kodni ramka ichiga joylashtiring';

  @override
  String orderItemsSummary(String count, String total) {
    return '$count ta mahsulot • $total';
  }
}
