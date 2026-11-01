// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Universal Restaurant';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get chooseLanguage => 'Select your language to continue';

  @override
  String get continueBtn => 'Continue →';

  @override
  String get menu => 'Menu';

  @override
  String get cart => 'Cart';

  @override
  String get orders => 'Orders';

  @override
  String get tableEntry => 'Select Table';

  @override
  String get tableNumber => 'Table number';

  @override
  String get tableHint => '1, 2, 3...';

  @override
  String get scanQr => 'Scan QR Code';

  @override
  String get enterTableManually => 'Enter table number';

  @override
  String get tableRequired => 'Please enter table number';

  @override
  String get tableInvalid => 'Table number must be a number';

  @override
  String get tableOccupied => '⚠️ Table Occupied';

  @override
  String get tableOccupiedMsg =>
      'This table is currently in use. Do you want to continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueAnyway => 'Continue';

  @override
  String get goToMenu => 'Go to Menu';

  @override
  String get checking => 'Checking...';

  @override
  String qrScanned(String table) {
    return 'QR Scanned: Table $table';
  }

  @override
  String get invalidQr => 'Invalid QR code. Please try again.';

  @override
  String get scanQrDialog => 'Scan Table QR';

  @override
  String get scanQrDialogContent => 'We use camera to scan table QR code';

  @override
  String get openCamera => 'Open Camera';

  @override
  String get searchFood => 'Search for food...';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String addedToCart(String item) {
    return '$item added to cart!';
  }

  @override
  String get noItemsFound => 'No items found.';

  @override
  String get yourCart => 'Your Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get orderPlaced => 'Order placed successfully!';

  @override
  String get orderError => 'Error placing order';

  @override
  String get som => 'sum';

  @override
  String get kitchenScreen => 'Kitchen Screen';

  @override
  String get newOrders => 'New Orders';

  @override
  String get cooking => 'Cooking';

  @override
  String get ready => 'Ready';

  @override
  String get startCooking => 'Start Cooking';

  @override
  String get markReady => 'Mark as Ready';

  @override
  String get markServed => 'Mark as Served';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCooking => 'Cooking';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusServed => 'Served';

  @override
  String get table => 'Table';

  @override
  String get welcomeRestaurant => 'Welcome to Restaurant App';

  @override
  String get selectRole => 'Please select your role to continue';

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
  String get tableInfo => 'Table number';

  @override
  String get tableOccupiedBadge => 'This table is busy';

  @override
  String get orderTracking => 'Order Tracking';

  @override
  String get all => 'All';

  @override
  String error(String msg) {
    return 'Error: $msg';
  }

  @override
  String get reset => 'Reset';

  @override
  String get restaurantDesc => 'Delicious food, best service';

  @override
  String get openMenu => 'Open Menu';

  @override
  String get myOrders => 'My Orders';

  @override
  String get callStaff => 'Call Staff';

  @override
  String get staffCalled => 'Staff has been called!';

  @override
  String get noActiveOrders => 'No active orders for this table.';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get requestBill => 'Request Bill';

  @override
  String get billRequested => 'Waitress notified for the bill.';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get noOrdersInStage => 'No orders in this stage.';

  @override
  String get qrScanTitle => 'Scan QR Code';

  @override
  String get qrScanManualTitle => 'Enter QR Code';

  @override
  String get confirm => 'Confirm';

  @override
  String get goBack => 'Go Back';

  @override
  String get adminLogin => 'Admin Login';

  @override
  String get adminSignup => 'Admin Registration';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get createAdminAccount => 'Create new admin account';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get confirmCancelOrder =>
      'Are you sure you want to cancel this order?';

  @override
  String get enterTableNumber => 'Enter table number:';

  @override
  String get yes => 'Yes, Cancel';

  @override
  String get no => 'No';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get yesLogout => 'Yes, Logout';

  @override
  String get ready2 => 'Ready';

  @override
  String get goToKitchen => 'Go to Kitchen';

  @override
  String get manageQrCodes => 'Manage QR Codes';

  @override
  String get editMenu => 'Edit Menu';

  @override
  String get webNoCameraTitle => 'No Camera on Web';

  @override
  String get enterQrManually => 'Enter QR code manually:';

  @override
  String get cameraNotAvailable => 'Camera not available on this platform';

  @override
  String get enterQrManuallyShort => 'Enter QR code data manually:';

  @override
  String get adminPanelSubtitle => 'Restaurant management';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Today\'s statistics and real-time data';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get orderCount => 'Orders';

  @override
  String get averageOrder => 'Average Order';

  @override
  String get menuItemsCount => 'Menu Items';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get topOrdered => 'Most Ordered';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get staffCalls => 'Staff Calls';

  @override
  String staffCallAtTable(String table) {
    return 'Table $table - staff requested';
  }

  @override
  String get markDone => 'Done';

  @override
  String get staffCallResolved => 'Staff call resolved';

  @override
  String get noStaffCalls => 'No staff calls';

  @override
  String get staffRequested => 'Staff requested';

  @override
  String get searchOrdersHint => 'Search by table or order ID...';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String tableNumberLabel(String table) {
    return 'Table #$table';
  }

  @override
  String orderNumberLabel(String number) {
    return 'Order #$number';
  }

  @override
  String get kitchenView => 'Kitchen View';

  @override
  String get qrGenerator => 'QR Code Generator';

  @override
  String get menuManagement => 'Menu Management';

  @override
  String confirmCancelTableOrder(String table) {
    return 'Cancel the order for table #$table?';
  }

  @override
  String get sidebarKitchen => 'Kitchen';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get qrCodes => 'QR Codes';

  @override
  String get kitchenOrdersTitle => 'Kitchen Orders';

  @override
  String get noOrdersAtMoment => 'No orders at the moment';

  @override
  String tableWithNumber(String table) {
    return 'Table $table';
  }

  @override
  String get generateTableQrCodes => 'Generate Table QR Codes';

  @override
  String get qrSelectHint =>
      'Select tables to generate QR codes for. Customers can scan these QR codes at their table with their phone.';

  @override
  String selectedTablesCount(String count) {
    return 'Selected Tables: $count';
  }

  @override
  String get clearAll => 'Clear All';

  @override
  String get downloadQrCodes => 'Download QR Codes';

  @override
  String get selectTables => 'Select Tables';

  @override
  String get qrCodesReady => 'QR Codes Ready';

  @override
  String qrGeneratedMessage(String count) {
    return 'Generated QR codes for $count tables.\\n\\nYou can now:\\n- Print them\\n- Display on screens\\n- Share with customers';
  }

  @override
  String get ok => 'OK';
}
