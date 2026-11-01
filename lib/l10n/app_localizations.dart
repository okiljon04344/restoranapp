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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Universal Restaurant'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language to continue'**
  String get chooseLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get continueBtn;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @tableEntry.
  ///
  /// In en, this message translates to:
  /// **'Select Table'**
  String get tableEntry;

  /// No description provided for @tableNumber.
  ///
  /// In en, this message translates to:
  /// **'Table number'**
  String get tableNumber;

  /// No description provided for @tableHint.
  ///
  /// In en, this message translates to:
  /// **'1, 2, 3...'**
  String get tableHint;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQr;

  /// No description provided for @enterTableManually.
  ///
  /// In en, this message translates to:
  /// **'Enter table number'**
  String get enterTableManually;

  /// No description provided for @tableRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter table number'**
  String get tableRequired;

  /// No description provided for @tableInvalid.
  ///
  /// In en, this message translates to:
  /// **'Table number must be a number'**
  String get tableInvalid;

  /// No description provided for @tableOccupied.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Table Occupied'**
  String get tableOccupied;

  /// No description provided for @tableOccupiedMsg.
  ///
  /// In en, this message translates to:
  /// **'This table is currently in use. Do you want to continue?'**
  String get tableOccupiedMsg;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAnyway;

  /// No description provided for @goToMenu.
  ///
  /// In en, this message translates to:
  /// **'Go to Menu'**
  String get goToMenu;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @qrScanned.
  ///
  /// In en, this message translates to:
  /// **'QR Scanned: Table {table}'**
  String qrScanned(String table);

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Please try again.'**
  String get invalidQr;

  /// No description provided for @scanQrDialog.
  ///
  /// In en, this message translates to:
  /// **'Scan Table QR'**
  String get scanQrDialog;

  /// No description provided for @scanQrDialogContent.
  ///
  /// In en, this message translates to:
  /// **'We use camera to scan table QR code'**
  String get scanQrDialogContent;

  /// No description provided for @openCamera.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get openCamera;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search for food...'**
  String get searchFood;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{item} added to cart!'**
  String addedToCart(String item);

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get noItemsFound;

  /// No description provided for @yourCart.
  ///
  /// In en, this message translates to:
  /// **'Your Cart'**
  String get yourCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully!'**
  String get orderPlaced;

  /// No description provided for @orderError.
  ///
  /// In en, this message translates to:
  /// **'Error placing order'**
  String get orderError;

  /// No description provided for @som.
  ///
  /// In en, this message translates to:
  /// **'sum'**
  String get som;

  /// No description provided for @kitchenScreen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Screen'**
  String get kitchenScreen;

  /// No description provided for @newOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrders;

  /// No description provided for @cooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get cooking;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// No description provided for @markReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markReady;

  /// No description provided for @markServed.
  ///
  /// In en, this message translates to:
  /// **'Mark as Served'**
  String get markServed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get statusCooking;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusServed.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get statusServed;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @welcomeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Restaurant App'**
  String get welcomeRestaurant;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select your role to continue'**
  String get selectRole;

  /// No description provided for @customerMode.
  ///
  /// In en, this message translates to:
  /// **'Customer Mode'**
  String get customerMode;

  /// No description provided for @customerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order delicious food from your table'**
  String get customerSubtitle;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @adminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage categories, menu, and orders'**
  String get adminSubtitle;

  /// No description provided for @kitchenDisplay.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Display'**
  String get kitchenDisplay;

  /// No description provided for @kitchenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and prepare incoming orders'**
  String get kitchenSubtitle;

  /// No description provided for @tableInfo.
  ///
  /// In en, this message translates to:
  /// **'Table number'**
  String get tableInfo;

  /// No description provided for @tableOccupiedBadge.
  ///
  /// In en, this message translates to:
  /// **'This table is busy'**
  String get tableOccupiedBadge;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order Tracking'**
  String get orderTracking;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {msg}'**
  String error(String msg);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @restaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'Delicious food, best service'**
  String get restaurantDesc;

  /// No description provided for @openMenu.
  ///
  /// In en, this message translates to:
  /// **'Open Menu'**
  String get openMenu;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @callStaff.
  ///
  /// In en, this message translates to:
  /// **'Call Staff'**
  String get callStaff;

  /// No description provided for @staffCalled.
  ///
  /// In en, this message translates to:
  /// **'Staff has been called!'**
  String get staffCalled;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders for this table.'**
  String get noActiveOrders;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @requestBill.
  ///
  /// In en, this message translates to:
  /// **'Request Bill'**
  String get requestBill;

  /// No description provided for @billRequested.
  ///
  /// In en, this message translates to:
  /// **'Waitress notified for the bill.'**
  String get billRequested;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @noOrdersInStage.
  ///
  /// In en, this message translates to:
  /// **'No orders in this stage.'**
  String get noOrdersInStage;

  /// No description provided for @qrScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get qrScanTitle;

  /// No description provided for @qrScanManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter QR Code'**
  String get qrScanManualTitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @adminLogin.
  ///
  /// In en, this message translates to:
  /// **'Admin Login'**
  String get adminLogin;

  /// No description provided for @adminSignup.
  ///
  /// In en, this message translates to:
  /// **'Admin Registration'**
  String get adminSignup;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new admin account'**
  String get createAdminAccount;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @confirmCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get confirmCancelOrder;

  /// No description provided for @enterTableNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter table number:'**
  String get enterTableNumber;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @yesLogout.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yesLogout;

  /// No description provided for @ready2.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready2;

  /// No description provided for @goToKitchen.
  ///
  /// In en, this message translates to:
  /// **'Go to Kitchen'**
  String get goToKitchen;

  /// No description provided for @manageQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Manage QR Codes'**
  String get manageQrCodes;

  /// No description provided for @editMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit Menu'**
  String get editMenu;

  /// No description provided for @webNoCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'No Camera on Web'**
  String get webNoCameraTitle;

  /// No description provided for @enterQrManually.
  ///
  /// In en, this message translates to:
  /// **'Enter QR code manually:'**
  String get enterQrManually;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available on this platform'**
  String get cameraNotAvailable;

  /// No description provided for @enterQrManuallyShort.
  ///
  /// In en, this message translates to:
  /// **'Enter QR code data manually:'**
  String get enterQrManuallyShort;

  /// No description provided for @adminPanelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant management'**
  String get adminPanelSubtitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s statistics and real-time data'**
  String get dashboardSubtitle;

  /// No description provided for @todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get todayRevenue;

  /// No description provided for @orderCount.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orderCount;

  /// No description provided for @averageOrder.
  ///
  /// In en, this message translates to:
  /// **'Average Order'**
  String get averageOrder;

  /// No description provided for @menuItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Menu Items'**
  String get menuItemsCount;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesLabel;

  /// No description provided for @topOrdered.
  ///
  /// In en, this message translates to:
  /// **'Most Ordered'**
  String get topOrdered;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @staffCalls.
  ///
  /// In en, this message translates to:
  /// **'Staff Calls'**
  String get staffCalls;

  /// No description provided for @staffCallAtTable.
  ///
  /// In en, this message translates to:
  /// **'Table {table} - staff requested'**
  String staffCallAtTable(String table);

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get markDone;

  /// No description provided for @staffCallResolved.
  ///
  /// In en, this message translates to:
  /// **'Staff call resolved'**
  String get staffCallResolved;

  /// No description provided for @noStaffCalls.
  ///
  /// In en, this message translates to:
  /// **'No staff calls'**
  String get noStaffCalls;

  /// No description provided for @staffRequested.
  ///
  /// In en, this message translates to:
  /// **'Staff requested'**
  String get staffRequested;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by table or order ID...'**
  String get searchOrdersHint;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @tableNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Table #{table}'**
  String tableNumberLabel(String table);

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumberLabel(String number);

  /// No description provided for @kitchenView.
  ///
  /// In en, this message translates to:
  /// **'Kitchen View'**
  String get kitchenView;

  /// No description provided for @qrGenerator.
  ///
  /// In en, this message translates to:
  /// **'QR Code Generator'**
  String get qrGenerator;

  /// No description provided for @menuManagement.
  ///
  /// In en, this message translates to:
  /// **'Menu Management'**
  String get menuManagement;

  /// No description provided for @confirmCancelTableOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel the order for table #{table}?'**
  String confirmCancelTableOrder(String table);

  /// No description provided for @sidebarKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get sidebarKitchen;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @qrCodes.
  ///
  /// In en, this message translates to:
  /// **'QR Codes'**
  String get qrCodes;

  /// No description provided for @kitchenOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Orders'**
  String get kitchenOrdersTitle;

  /// No description provided for @noOrdersAtMoment.
  ///
  /// In en, this message translates to:
  /// **'No orders at the moment'**
  String get noOrdersAtMoment;

  /// No description provided for @tableWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Table {table}'**
  String tableWithNumber(String table);

  /// No description provided for @generateTableQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Generate Table QR Codes'**
  String get generateTableQrCodes;

  /// No description provided for @qrSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select tables to generate QR codes for. Customers can scan these QR codes at their table with their phone.'**
  String get qrSelectHint;

  /// No description provided for @selectedTablesCount.
  ///
  /// In en, this message translates to:
  /// **'Selected Tables: {count}'**
  String selectedTablesCount(String count);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @downloadQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Download QR Codes'**
  String get downloadQrCodes;

  /// No description provided for @selectTables.
  ///
  /// In en, this message translates to:
  /// **'Select Tables'**
  String get selectTables;

  /// No description provided for @qrCodesReady.
  ///
  /// In en, this message translates to:
  /// **'QR Codes Ready'**
  String get qrCodesReady;

  /// No description provided for @qrGeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Generated QR codes for {count} tables.\\n\\nYou can now:\\n- Print them\\n- Display on screens\\n- Share with customers'**
  String qrGeneratedMessage(String count);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @ingredientsManagement.
  ///
  /// In en, this message translates to:
  /// **'Ingredients Management'**
  String get ingredientsManagement;

  /// No description provided for @newIngredient.
  ///
  /// In en, this message translates to:
  /// **'New Ingredient'**
  String get newIngredient;

  /// No description provided for @ingredientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List of ingredients needed to prepare dishes'**
  String get ingredientsSubtitle;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock ({count} ingredients)'**
  String lowStockAlert(String count);

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @noIngredientsFound.
  ///
  /// In en, this message translates to:
  /// **'No ingredients found'**
  String get noIngredientsFound;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @minQuantityShort.
  ///
  /// In en, this message translates to:
  /// **'Min: {value}'**
  String minQuantityShort(String value);

  /// No description provided for @addIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Ingredient'**
  String get addIngredientTitle;

  /// No description provided for @editIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredientTitle;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get ingredientName;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @minimumQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Quantity'**
  String get minimumQuantityLabel;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @ingredientAdded.
  ///
  /// In en, this message translates to:
  /// **'Ingredient added'**
  String get ingredientAdded;

  /// No description provided for @ingredientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Ingredient updated'**
  String get ingredientUpdated;

  /// No description provided for @ingredientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Ingredient deleted'**
  String get ingredientDeleted;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @deleteIngredientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this ingredient?'**
  String get deleteIngredientConfirm;

  /// No description provided for @yesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get yesDelete;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPiece;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGram;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get unitLiter;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get unitBox;

  /// No description provided for @unitPack.
  ///
  /// In en, this message translates to:
  /// **'pack'**
  String get unitPack;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillRequiredFields;

  /// No description provided for @menuItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Menu item added successfully'**
  String get menuItemAdded;

  /// No description provided for @addNewMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Menu Item'**
  String get addNewMenuItem;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item Name *'**
  String get itemNameRequired;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Chicken Biryani'**
  String get itemNameHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @itemDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Item description...'**
  String get itemDescriptionHint;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price *'**
  String get priceRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryRequired;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @addingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get addingInProgress;

  /// No description provided for @addMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Add Menu Item'**
  String get addMenuItem;

  /// No description provided for @menuItems.
  ///
  /// In en, this message translates to:
  /// **'Menu Items'**
  String get menuItems;

  /// No description provided for @noMenuItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No menu items yet'**
  String get noMenuItemsYet;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @confirmDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteItem;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @createNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Create New Category'**
  String get createNewCategory;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameHint;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get categoryCreated;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @torchError.
  ///
  /// In en, this message translates to:
  /// **'Torch error: {error}'**
  String torchError(String error);

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(String error);

  /// No description provided for @placeQrInFrame.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code inside the frame'**
  String get placeQrInFrame;

  /// No description provided for @orderItemsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} items • {total}'**
  String orderItemsSummary(String count, String total);
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
