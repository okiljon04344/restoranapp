// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get tableEntry => 'Table Entry';

  @override
  String get scanQr => 'Scan QR Code';

  @override
  String get enterTableManually => 'Enter table manually';

  @override
  String get searchFood => 'Search for food...';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get orderNow => 'Order Now';

  @override
  String get total => 'Total';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCooking => 'Cooking';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusServed => 'Served';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get kitchenOrders => 'Kitchen Orders';
}
