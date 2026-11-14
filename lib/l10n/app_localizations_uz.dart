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
  String get cancel => 'Bekor';

  @override
  String get goToMenu => 'Menyuga o\'tish';

  @override
  String get checking => 'Tekshirilmoqda...';

  @override
  String get invalidQr => 'Noto\'g\'ri QR kod. Qaytadan urinib ko\'ring.';

  @override
  String get searchFood => 'Taomlarni qidirish...';

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
  String get tableInfo => 'Stol raqami';

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
  String get login => 'Kirish';

  @override
  String get register => 'Ro\'yxatdan o\'tish';

  @override
  String get cancelOrder => 'Sifarishni Bekor Qilish';

  @override
  String get confirmCancelOrder => 'Bu sifarishni bekor qilishni xohlaysizmi?';

  @override
  String get yes => 'Ha';

  @override
  String get no => 'Yo\'q';

  @override
  String get logout => 'Chiqish';

  @override
  String get logoutConfirm => 'Sistemadan chiqmoqchisiz?';

  @override
  String get editMenu => 'Menyunu Tahrirlash';

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
      'Oxirgi 7 kunlik buyurtmalar bo\'yicha ko\'rsatkichlar';

  @override
  String get todayRevenue => 'Bugungi tushum (to\'langan)';

  @override
  String get averageOrder => 'O\'rtacha to\'langan buyurtma (bugun)';

  @override
  String get categoriesLabel => 'Kategoriyalar';

  @override
  String get topOrdered => 'Eng ko\'p buyurtma qilingan';

  @override
  String get staffCalls => 'Xodim chaqiruvlari';

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
  String orderNumberLabel(String number) {
    return 'Buyurtma #$number';
  }

  @override
  String confirmCancelTableOrder(String table) {
    return 'Stol #$table buyurtmasini bekor qilmoqchimisiz?';
  }

  @override
  String get sidebarKitchen => 'Oshxona';

  @override
  String get ingredients => 'Masalliqlar';

  @override
  String tableWithNumber(String table) {
    return 'Stol $table';
  }

  @override
  String get qrSelectHint =>
      'Mijozlar faqat shu yerda ro\'yxatga olingan stollarda buyurtma bera oladi. QR kodni chop etib, stolga qo\'ying.';

  @override
  String get ok => 'OK';

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
  String get descriptionLabel => 'Tavsif';

  @override
  String get priceRequired => 'Narxi *';

  @override
  String get categoryRequired => 'Kategoriya *';

  @override
  String get imageUrl => 'Rasm URL manzili';

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
  String get enterEmailPassword => 'Email va parolni kiriting';

  @override
  String get authUserNotFound => 'Bu email bilan foydalanuvchi topilmadi';

  @override
  String get authWrongPassword => 'Parol noto\'g\'ri';

  @override
  String get authInvalidCredential => 'Email yoki parol noto\'g\'ri';

  @override
  String get authNetworkError => 'Internetga ulanishda xato';

  @override
  String get authTooManyRequests =>
      'Juda ko\'p urinish. Birozdan so\'ng qayta urinib ko\'ring';

  @override
  String get authEmailInUse => 'Bu email allaqachon ro\'yxatdan o\'tgan';

  @override
  String get authWeakPassword => 'Parol juda oddiy (kamida 6 ta belgi kerak)';

  @override
  String get authInvalidEmail => 'Email noto\'g\'ri formatda';

  @override
  String get passwordsMismatch => 'Parollar mos kelmadi';

  @override
  String get passwordTooShort => 'Parol kamida 6 ta belgi bo\'lishi kerak';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get confirmPasswordLabel => 'Parolni tasdiqlang';

  @override
  String get passwordHint => 'Kamida 6 ta belgidan iborat kuchli parol tanlang';

  @override
  String get statusPaid => 'To\'langan';

  @override
  String get statusCancelled => 'Bekor qilingan';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get errOrderNotFound => 'Bu buyurtma topilmadi.';

  @override
  String get errInvalidTransition =>
      'Buyurtma holati allaqachon o\'zgargan. Oxirgi holatni tekshiring.';

  @override
  String errItemUnavailable(String name) {
    return '\"$name\" hozircha mavjud emas.';
  }

  @override
  String errInsufficientStock(String name) {
    return 'Omborda yetarli emas: $name.';
  }

  @override
  String get errBillNotReady =>
      'Stolning barcha buyurtmalari berilgandan keyin hisobni yopish mumkin.';

  @override
  String get errNothingToPay => 'Bu stolda ochiq buyurtma yo\'q.';

  @override
  String get errTableExists => 'Bu raqamli stol allaqachon mavjud.';

  @override
  String get errCategoryInUse => 'Bu kategoriyada hali taomlar bor.';

  @override
  String get errPermissionDenied => 'Bu amal uchun ruxsatingiz yo\'q.';

  @override
  String get invalidNumber => 'To\'g\'ri son kiriting';

  @override
  String get pageNotFound => 'Sahifa topilmadi';

  @override
  String get accessDenied =>
      'Bu sahifaga ruxsati bor xodim akkaunti bilan kiring.';

  @override
  String get staffLogin => 'Xodimlar uchun kirish';

  @override
  String get staffLoginSubtitle => 'Oshxona ekrani va admin panel';

  @override
  String get authNoStaffAccess =>
      'Bu akkauntda hali xodim huquqi yo\'q. Ruxsat so\'rovi yuborildi; admindan tasdiqlashni so\'rang.';

  @override
  String get requestStaffAccount => 'Xodim akkauntini so\'rash';

  @override
  String get staffRequestSent =>
      'Akkaunt yaratildi. Kirish uchun admin tasdiqlashi kerak.';

  @override
  String get staffSignupHint =>
      'Oshxona xodimi uchun akkaunt yarating. Admin so\'rovni tasdiqlagach ruxsat beriladi.';

  @override
  String tableNotFound(String table) {
    return '$table-stol ro\'yxatda yo\'q. Raqamni tekshiring yoki xodimga murojaat qiling.';
  }

  @override
  String tableDisabled(String table) {
    return '$table-stolda hozircha buyurtma qabul qilinmaydi.';
  }

  @override
  String get billTotal => 'Hisob jami';

  @override
  String get orderCancelled => 'Buyurtma bekor qilindi';

  @override
  String get soldOut => 'Tugagan';

  @override
  String get bills => 'Hisoblar';

  @override
  String get noOpenBills => 'Ochiq hisoblar yo\'q';

  @override
  String get closeBill => 'Hisobni yopish (to\'landi)';

  @override
  String confirmCloseBill(String table, String total) {
    return '$table-stol hisobi ($total) to\'langan deb belgilansinmi?';
  }

  @override
  String billClosed(String table) {
    return '$table-stol: hisob yopildi';
  }

  @override
  String get billRequestedByTable => 'Hisob so\'raldi';

  @override
  String get tablesAndQr => 'Stollar va QR kodlar';

  @override
  String get addTable => 'Stol qo\'shish';

  @override
  String tableAdded(String table) {
    return '$table-stol qo\'shildi';
  }

  @override
  String get printQrCodes => 'QR kodlarni chop etish';

  @override
  String get noTablesYet =>
      'Hali stollar yo\'q. QR kod yaratish uchun stol qo\'shing.';

  @override
  String confirmDeleteTable(String table) {
    return '$table-stol o\'chirilsinmi? Uning QR kodi ishlamay qoladi.';
  }

  @override
  String get tableStatusDisabled => 'O\'chirilgan';

  @override
  String get tableStatusFree => 'Bo\'sh';

  @override
  String get staffSection => 'Xodimlar';

  @override
  String get staffAdminHint =>
      'Oshxona xodimlari kirish sahifasidan akkaunt yaratadi; buyurtmalar va omborga ruxsat berish uchun so\'rovni shu yerda tasdiqlang.';

  @override
  String get staffRequestsTitle => 'Ruxsat so\'rovlari';

  @override
  String get noStaffRequests => 'Kutilayotgan so\'rovlar yo\'q';

  @override
  String get approveAction => 'Tasdiqlash';

  @override
  String get rejectAction => 'Rad etish';

  @override
  String staffApproved(String email) {
    return '$email ga oshxona ruxsati berildi';
  }

  @override
  String get kitchenStaffTitle => 'Oshxona xodimlari';

  @override
  String get noKitchenStaff => 'Hali oshxona xodimlari yo\'q';

  @override
  String get revokeAction => 'Ruxsatni bekor qilish';

  @override
  String confirmRevokeStaff(String email) {
    return '$email ning oshxona ruxsati bekor qilinsinmi?';
  }

  @override
  String confirmDeleteCategory(String name) {
    return '\"$name\" kategoriyasi o\'chirilsinmi?';
  }

  @override
  String get createCategoryFirst => 'Avval kategoriya yarating.';

  @override
  String get menuItemUpdated => 'Taom yangilandi';

  @override
  String recipeLinesCount(String count) {
    return 'Retsept: $count ta masalliq';
  }

  @override
  String get availableOnMenu => 'Menyuda ko\'rsatiladi';

  @override
  String get recipeTitle => 'Retsept (bir porsiya uchun)';

  @override
  String get recipeHint =>
      'Oshxona buyurtmani qabul qilganda bu miqdorlar ombordan ayriladi.';

  @override
  String get addRecipeLine => 'Masalliq qo\'shish';

  @override
  String get weekRevenue => 'Shu haftalik tushum';

  @override
  String get todayOrdersCount => 'Bugungi buyurtmalar';

  @override
  String get weekOrdersCount => 'Shu haftalik buyurtmalar';

  @override
  String get openOrdersCount => 'Ochiq buyurtmalar';

  @override
  String get cancelledToday => 'Bugun bekor qilingan';

  @override
  String get tableStatusOccupied => 'Band';
}
