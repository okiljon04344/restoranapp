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

  @override
  String get restaurantName => 'Universal Restaurant';
  @override
  String get restaurantDesc => 'Delicious food, best service';
  @override
  String get tableNumber => 'Table number';
  @override
  String get tableOccupied => 'This table is occupied';
  @override
  String get reset => 'Reset';
  @override
  String get openMenu => 'Open Menu';
  @override
  String get myOrders => 'My Orders';
  @override
  String get callStaff => 'Call Staff';
  @override
  String get staffCalled => 'Staff has been called!';

  @override
  String get welcome => 'Welcome!';
  @override
  String get enterTableOrScan => 'Enter the table number or scan the QR code at the table.';
  @override
  String get tableNumberLabel => 'Table number';
  @override
  String get tableNumberHint => '1, 2, 3...';
  @override
  String get goToMenu => 'Go to Menu';
  @override
  String get checking => 'Checking...';
  @override
  String get scanQrTitle => 'Scan QR Code';
  @override
  String get scanQrDescription => 'We will use the camera to scan the table QR code';
  @override
  String get cancel => 'Cancel';
  @override
  String get openCamera => 'Open Camera';
  @override
  String get enterTableNumber => 'Enter table number';
  @override
  String get tableNumberMustBeNumber => 'Table number must be a number';
  @override
  String get tableOccupiedTitle => 'Table Occupied';
  @override
  String get tableOccupiedMessage => 'This table is currently in use. Do you want to continue?';
  @override
  String get continueText => 'Continue';
  @override
  String get invalidQrCode => 'Invalid QR code. Please try again.';
  @override
  String qrScannedTable(String tableNum) => 'QR Scanned: Table $tableNum';
  @override
  String errorMessage(String message) => 'Error: $message';

  @override
  String get all => 'All';
  @override
  String get noItemsFound => 'No items found.';
  @override
  String itemAdded(String item) => '$item added!';
  @override
  String get currency => 'so\'m';

  @override
  String get yourCart => 'Your Cart';
  @override
  String get cartEmpty => 'Your cart is empty';
  @override
  String get totalAmount => 'Total Amount';
  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String tableOrders(String tableId) => 'Table $tableId - Orders';
  @override
  String get noActiveOrders => 'No active orders for this table.';
  @override
  String get subtotal => 'Subtotal';
  @override
  String get waitressNotified => 'Waitress notified for the bill.';
  @override
  String get requestBill => 'Request Bill';
  @override
  String get preparing => 'Preparing';
  @override
  String get ready => 'Ready';
  @override
  String get delivered => 'Delivered';

  @override
  String get kitchenScreen => 'Kitchen Screen';
  @override
  String get newOrders => 'New Orders';
  @override
  String get cooking => 'Cooking';
  @override
  String get startCooking => 'Start Cooking';
  @override
  String get markAsReady => 'Mark as Ready';
  @override
  String get markAsServed => 'Mark as Served';
  @override
  String get noOrdersInStage => 'No orders in this stage.';
  @override
  String get items => 'items';

  @override
  String get menuManagement => 'Menu Management';
  @override
  String get cancelOrderByTable => 'Cancel Order by Table';
  @override
  String get staffCalls => 'Staff Calls';
  @override
  String get activeOrders => 'Active Orders';
  @override
  String get noOrdersYet => 'No orders yet';
  @override
  String get enterTableNumberColon => 'Enter table number:';
  @override
  String get cancelOrderBtn => 'Cancel Order';
  @override
  String tableOrderCancelled(String tableNum) => 'Table #$tableNum order cancelled';
  @override
  String get noActiveOrderForTable => 'No active order found for this table';
  @override
  String get staffCallResolved => 'Staff call resolved';
  @override
  String get orderCancelled => 'Order cancelled';
  @override
  String get confirmTitle => 'Confirm';
  @override
  String cancelOrderForTable(String tableNumber) => 'Cancel order for table #$tableNumber?';
  @override
  String get no => 'No';
  @override
  String get yesCancel => 'Yes, Cancel';
  @override
  String get categories => 'Categories';
  @override
  String get menuItems => 'Menu Items';
  @override
  String get system => 'System';
  @override
  String get live => 'Live';
  @override
  String get resolve => 'Resolve';
  @override
  String calledAt(String time) => 'Called at $time';
  @override
  String get tableLabel => 'Table';

  @override
  String get adminLogin => 'Admin Login';
  @override
  String get emailAndPasswordRequired => 'Please enter email and password';
  @override
  String get email => 'Email';
  @override
  String get emailHint => 'admin@gmail.com';
  @override
  String get password => 'Password';
  @override
  String get login => 'Login';
  @override
  String get createNewAdmin => 'Create new admin account';
  @override
  String get debugFirebase => 'Debug - Firebase Status';
  @override
  String get noAdminRights => 'You do not have admin rights.';
  @override
  String get userNotFound => 'No user found with this email';
  @override
  String get wrongPassword => 'Wrong password';
  @override
  String get invalidCredential => 'Email or password is incorrect';
  @override
  String get networkError => 'Network connection error';
  @override
  String get tooManyRequests => 'Too many attempts. Please try again later';

  @override
  String get welcomeToApp => 'Welcome to Restaurant App';
  @override
  String get selectRoleToContinue => 'Please select your role to continue';
  @override
  String get customerMode => 'Customer Mode';
  @override
  String get customerSubtitle => 'Order delicious food from your table';
  @override
  String get adminPanel => 'Admin Panel';
  @override
  String get adminSubtitle => 'Manage categories, menu, and orders';
  @override
  String get kitchenDisplay => 'Kitchen Display';
  @override
  String get kitchenSubtitle => 'Track and prepare incoming orders';

  @override
  String get selectLanguage => 'Select Your Language';
  @override
  String get selectLanguageSubtitle => 'Choose your preferred language';
  @override
  String deviceLanguage(String language) => 'Device language: $language';
  @override
  String get failedToSaveLanguage => 'Failed to save language preference';
  @override
  String get errorSelectingLanguage => 'Error selecting language';
}
