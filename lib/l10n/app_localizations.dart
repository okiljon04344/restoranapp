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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @invalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Please try again.'**
  String get invalidQr;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search for food...'**
  String get searchFood;

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

  /// No description provided for @tableInfo.
  ///
  /// In en, this message translates to:
  /// **'Table number'**
  String get tableInfo;

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

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
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

  /// No description provided for @editMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit Menu'**
  String get editMenu;

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
  /// **'Figures from the orders of the last 7 days'**
  String get dashboardSubtitle;

  /// No description provided for @todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue today (paid)'**
  String get todayRevenue;

  /// No description provided for @averageOrder.
  ///
  /// In en, this message translates to:
  /// **'Average paid order (today)'**
  String get averageOrder;

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

  /// No description provided for @staffCalls.
  ///
  /// In en, this message translates to:
  /// **'Staff Calls'**
  String get staffCalls;

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

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumberLabel(String number);

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

  /// No description provided for @tableWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Table {table}'**
  String tableWithNumber(String table);

  /// No description provided for @qrSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Customers can only order at tables registered here. Print the QR code and place it on the table.'**
  String get qrSelectHint;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

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

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

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

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

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

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password'**
  String get enterEmailPassword;

  /// No description provided for @authUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email'**
  String get authUserNotFound;

  /// No description provided for @authWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authWrongPassword;

  /// No description provided for @authInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get authInvalidCredential;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error'**
  String get authNetworkError;

  /// No description provided for @authTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get authTooManyRequests;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (at least 6 characters required)'**
  String get authWeakPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get authInvalidEmail;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password of at least 6 characters'**
  String get passwordHint;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'This order no longer exists.'**
  String get errOrderNotFound;

  /// No description provided for @errInvalidTransition.
  ///
  /// In en, this message translates to:
  /// **'The order status has already changed. Please check the latest status.'**
  String get errInvalidTransition;

  /// No description provided for @errItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is currently unavailable.'**
  String errItemUnavailable(String name);

  /// No description provided for @errInsufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Not enough stock: {name}.'**
  String errInsufficientStock(String name);

  /// No description provided for @errBillNotReady.
  ///
  /// In en, this message translates to:
  /// **'The bill can be closed once every order of the table has been served.'**
  String get errBillNotReady;

  /// No description provided for @errNothingToPay.
  ///
  /// In en, this message translates to:
  /// **'This table has no open orders.'**
  String get errNothingToPay;

  /// No description provided for @errTableExists.
  ///
  /// In en, this message translates to:
  /// **'A table with this number already exists.'**
  String get errTableExists;

  /// No description provided for @errCategoryInUse.
  ///
  /// In en, this message translates to:
  /// **'This category still contains menu items.'**
  String get errCategoryInUse;

  /// No description provided for @errPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errPermissionDenied;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get invalidNumber;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a staff account that has access to this screen.'**
  String get accessDenied;

  /// No description provided for @staffLogin.
  ///
  /// In en, this message translates to:
  /// **'Staff sign-in'**
  String get staffLogin;

  /// No description provided for @staffLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen display and admin panel'**
  String get staffLoginSubtitle;

  /// No description provided for @authNoStaffAccess.
  ///
  /// In en, this message translates to:
  /// **'This account has no staff access yet. An access request was sent; ask an admin to approve it.'**
  String get authNoStaffAccess;

  /// No description provided for @requestStaffAccount.
  ///
  /// In en, this message translates to:
  /// **'Request a staff account'**
  String get requestStaffAccount;

  /// No description provided for @staffRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Account created. An admin has to approve it before you can sign in.'**
  String get staffRequestSent;

  /// No description provided for @staffSignupHint.
  ///
  /// In en, this message translates to:
  /// **'Create an account for kitchen staff. It gets access after an admin approves the request.'**
  String get staffSignupHint;

  /// No description provided for @tableNotFound.
  ///
  /// In en, this message translates to:
  /// **'Table {table} is not registered. Please check the number or ask the staff.'**
  String tableNotFound(String table);

  /// No description provided for @tableDisabled.
  ///
  /// In en, this message translates to:
  /// **'Table {table} is currently not available for ordering.'**
  String tableDisabled(String table);

  /// No description provided for @billTotal.
  ///
  /// In en, this message translates to:
  /// **'Bill total'**
  String get billTotal;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @noOpenBills.
  ///
  /// In en, this message translates to:
  /// **'No open bills'**
  String get noOpenBills;

  /// No description provided for @closeBill.
  ///
  /// In en, this message translates to:
  /// **'Close bill (paid)'**
  String get closeBill;

  /// No description provided for @confirmCloseBill.
  ///
  /// In en, this message translates to:
  /// **'Mark the bill of table {table} ({total}) as paid?'**
  String confirmCloseBill(String table, String total);

  /// No description provided for @billClosed.
  ///
  /// In en, this message translates to:
  /// **'Table {table}: bill closed'**
  String billClosed(String table);

  /// No description provided for @billRequestedByTable.
  ///
  /// In en, this message translates to:
  /// **'Bill requested'**
  String get billRequestedByTable;

  /// No description provided for @tablesAndQr.
  ///
  /// In en, this message translates to:
  /// **'Tables & QR codes'**
  String get tablesAndQr;

  /// No description provided for @addTable.
  ///
  /// In en, this message translates to:
  /// **'Add table'**
  String get addTable;

  /// No description provided for @tableAdded.
  ///
  /// In en, this message translates to:
  /// **'Table {table} added'**
  String tableAdded(String table);

  /// No description provided for @printQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Print QR codes'**
  String get printQrCodes;

  /// No description provided for @noTablesYet.
  ///
  /// In en, this message translates to:
  /// **'No tables yet. Add a table to generate its QR code.'**
  String get noTablesYet;

  /// No description provided for @confirmDeleteTable.
  ///
  /// In en, this message translates to:
  /// **'Delete table {table}? Its QR code will stop working.'**
  String confirmDeleteTable(String table);

  /// No description provided for @tableStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get tableStatusDisabled;

  /// No description provided for @tableStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tableStatusFree;

  /// No description provided for @staffSection.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffSection;

  /// No description provided for @staffAdminHint.
  ///
  /// In en, this message translates to:
  /// **'Kitchen staff create an account from the sign-in page; approve the request here to give it access to orders and stock.'**
  String get staffAdminHint;

  /// No description provided for @staffRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Access requests'**
  String get staffRequestsTitle;

  /// No description provided for @noStaffRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noStaffRequests;

  /// No description provided for @approveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveAction;

  /// No description provided for @rejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAction;

  /// No description provided for @staffApproved.
  ///
  /// In en, this message translates to:
  /// **'{email} now has kitchen access'**
  String staffApproved(String email);

  /// No description provided for @kitchenStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen staff'**
  String get kitchenStaffTitle;

  /// No description provided for @noKitchenStaff.
  ///
  /// In en, this message translates to:
  /// **'No kitchen staff yet'**
  String get noKitchenStaff;

  /// No description provided for @revokeAction.
  ///
  /// In en, this message translates to:
  /// **'Revoke access'**
  String get revokeAction;

  /// No description provided for @confirmRevokeStaff.
  ///
  /// In en, this message translates to:
  /// **'Remove kitchen access for {email}?'**
  String confirmRevokeStaff(String email);

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete the category \"{name}\"?'**
  String confirmDeleteCategory(String name);

  /// No description provided for @createCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a category first.'**
  String get createCategoryFirst;

  /// No description provided for @menuItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Menu item updated'**
  String get menuItemUpdated;

  /// No description provided for @recipeLinesCount.
  ///
  /// In en, this message translates to:
  /// **'Recipe: {count} ingredients'**
  String recipeLinesCount(String count);

  /// No description provided for @availableOnMenu.
  ///
  /// In en, this message translates to:
  /// **'Shown on the menu'**
  String get availableOnMenu;

  /// No description provided for @recipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe (per portion)'**
  String get recipeTitle;

  /// No description provided for @recipeHint.
  ///
  /// In en, this message translates to:
  /// **'These quantities are taken from stock when the kitchen accepts an order.'**
  String get recipeHint;

  /// No description provided for @addRecipeLine.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addRecipeLine;

  /// No description provided for @weekRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue this week'**
  String get weekRevenue;

  /// No description provided for @todayOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'Orders today'**
  String get todayOrdersCount;

  /// No description provided for @weekOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'Orders this week'**
  String get weekOrdersCount;

  /// No description provided for @openOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get openOrdersCount;

  /// No description provided for @cancelledToday.
  ///
  /// In en, this message translates to:
  /// **'Cancelled today'**
  String get cancelledToday;

  /// No description provided for @tableStatusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get tableStatusOccupied;
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
