import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('uz')
  ];

  String get menu;
  String get cart;
  String get orders;
  String get chooseLanguage;
  String get tableEntry;
  String get scanQr;
  String get enterTableManually;
  String get searchFood;
  String get addToCart;
  String get orderNow;
  String get total;
  String get statusPending;
  String get statusCooking;
  String get statusReady;
  String get statusServed;
  String get adminDashboard;
  String get kitchenOrders;

  String get restaurantName;
  String get restaurantDesc;
  String get tableNumber;
  String get tableOccupied;
  String get reset;
  String get openMenu;
  String get myOrders;
  String get callStaff;
  String get staffCalled;

  String get welcome;
  String get enterTableOrScan;
  String get tableNumberLabel;
  String get tableNumberHint;
  String get goToMenu;
  String get checking;
  String get scanQrTitle;
  String get scanQrDescription;
  String get cancel;
  String get openCamera;
  String get enterTableNumber;
  String get tableNumberMustBeNumber;
  String get tableOccupiedTitle;
  String get tableOccupiedMessage;
  String get continueText;
  String get invalidQrCode;
  String qrScannedTable(String tableNum);
  String errorMessage(String message);

  String get all;
  String get noItemsFound;
  String itemAdded(String item);
  String get currency;

  String get yourCart;
  String get cartEmpty;
  String get totalAmount;
  String get confirmOrder;

  String tableOrders(String tableId);
  String get noActiveOrders;
  String get subtotal;
  String get waitressNotified;
  String get requestBill;
  String get preparing;
  String get ready;
  String get delivered;

  String get kitchenScreen;
  String get newOrders;
  String get cooking;
  String get startCooking;
  String get markAsReady;
  String get markAsServed;
  String get noOrdersInStage;
  String get items;

  String get menuManagement;
  String get cancelOrderByTable;
  String get staffCalls;
  String get activeOrders;
  String get noOrdersYet;
  String get enterTableNumberColon;
  String get cancelOrderBtn;
  String tableOrderCancelled(String tableNum);
  String get noActiveOrderForTable;
  String get staffCallResolved;
  String get orderCancelled;
  String get confirmTitle;
  String cancelOrderForTable(String tableNumber);
  String get no;
  String get yesCancel;
  String get categories;
  String get menuItems;
  String get system;
  String get live;
  String get resolve;
  String calledAt(String time);
  String get tableLabel;

  String get adminLogin;
  String get emailAndPasswordRequired;
  String get email;
  String get emailHint;
  String get password;
  String get login;
  String get createNewAdmin;
  String get debugFirebase;
  String get noAdminRights;
  String get userNotFound;
  String get wrongPassword;
  String get invalidCredential;
  String get networkError;
  String get tooManyRequests;

  String get welcomeToApp;
  String get selectRoleToContinue;
  String get customerMode;
  String get customerSubtitle;
  String get adminPanel;
  String get adminSubtitle;
  String get kitchenDisplay;
  String get kitchenSubtitle;

  String get selectLanguage;
  String get selectLanguageSubtitle;
  String deviceLanguage(String language);
  String get failedToSaveLanguage;
  String get errorSelectingLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
