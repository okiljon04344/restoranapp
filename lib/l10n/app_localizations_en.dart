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
  String get cancel => 'Cancel';

  @override
  String get goToMenu => 'Go to Menu';

  @override
  String get checking => 'Checking...';

  @override
  String get invalidQr => 'Invalid QR code. Please try again.';

  @override
  String get searchFood => 'Search for food...';

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
  String get tableInfo => 'Table number';

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
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get confirmCancelOrder =>
      'Are you sure you want to cancel this order?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get editMenu => 'Edit Menu';

  @override
  String get cameraNotAvailable => 'Camera not available on this platform';

  @override
  String get enterQrManuallyShort => 'Enter QR code data manually:';

  @override
  String get adminPanelSubtitle => 'Restaurant management';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Figures from the orders of the last 7 days';

  @override
  String get todayRevenue => 'Revenue today (paid)';

  @override
  String get averageOrder => 'Average paid order (today)';

  @override
  String get categoriesLabel => 'Categories';

  @override
  String get topOrdered => 'Most Ordered';

  @override
  String get staffCalls => 'Staff Calls';

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
  String orderNumberLabel(String number) {
    return 'Order #$number';
  }

  @override
  String confirmCancelTableOrder(String table) {
    return 'Cancel the order for table #$table?';
  }

  @override
  String get sidebarKitchen => 'Kitchen';

  @override
  String get ingredients => 'Ingredients';

  @override
  String tableWithNumber(String table) {
    return 'Table $table';
  }

  @override
  String get qrSelectHint =>
      'Customers can only order at tables registered here. Print the QR code and place it on the table.';

  @override
  String get ok => 'OK';

  @override
  String get newIngredient => 'New Ingredient';

  @override
  String get ingredientsSubtitle =>
      'List of ingredients needed to prepare dishes';

  @override
  String lowStockAlert(String count) {
    return 'Low Stock ($count ingredients)';
  }

  @override
  String get lowStock => 'Low Stock';

  @override
  String get noIngredientsFound => 'No ingredients found';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String minQuantityShort(String value) {
    return 'Min: $value';
  }

  @override
  String get addIngredientTitle => 'Add New Ingredient';

  @override
  String get editIngredientTitle => 'Edit Ingredient';

  @override
  String get ingredientName => 'Ingredient Name';

  @override
  String get unitLabel => 'Unit';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get minimumQuantityLabel => 'Minimum Quantity';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get ingredientAdded => 'Ingredient added';

  @override
  String get ingredientUpdated => 'Ingredient updated';

  @override
  String get ingredientDeleted => 'Ingredient deleted';

  @override
  String get addAction => 'Add';

  @override
  String get saveAction => 'Save';

  @override
  String get deleteIngredientConfirm =>
      'Do you want to delete this ingredient?';

  @override
  String get unitPiece => 'pcs';

  @override
  String get unitKg => 'kg';

  @override
  String get unitGram => 'g';

  @override
  String get unitLiter => 'l';

  @override
  String get unitMl => 'ml';

  @override
  String get unitBox => 'box';

  @override
  String get unitPack => 'pack';

  @override
  String get fillRequiredFields => 'Please fill all required fields';

  @override
  String get menuItemAdded => 'Menu item added successfully';

  @override
  String get addNewMenuItem => 'Add New Menu Item';

  @override
  String get itemNameRequired => 'Item Name *';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get priceRequired => 'Price *';

  @override
  String get categoryRequired => 'Category *';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get addMenuItem => 'Add Menu Item';

  @override
  String get menuItems => 'Menu Items';

  @override
  String get noMenuItemsYet => 'No menu items yet';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get confirmDeleteItem => 'Are you sure you want to delete this item?';

  @override
  String get itemDeleted => 'Item deleted';

  @override
  String get createNewCategory => 'Create New Category';

  @override
  String get categoryNameHint => 'Category name';

  @override
  String get createAction => 'Create';

  @override
  String get categoryCreated => 'Category created';

  @override
  String get enterCategoryName => 'Enter category name';

  @override
  String torchError(String error) {
    return 'Torch error: $error';
  }

  @override
  String cameraError(String error) {
    return 'Camera error: $error';
  }

  @override
  String get placeQrInFrame => 'Place the QR code inside the frame';

  @override
  String get enterEmailPassword => 'Please enter your email and password';

  @override
  String get authUserNotFound => 'No user found with this email';

  @override
  String get authWrongPassword => 'Incorrect password';

  @override
  String get authInvalidCredential => 'Incorrect email or password';

  @override
  String get authNetworkError => 'Network connection error';

  @override
  String get authTooManyRequests => 'Too many attempts. Please try again later';

  @override
  String get authEmailInUse => 'This email is already registered';

  @override
  String get authWeakPassword =>
      'Password is too weak (at least 6 characters required)';

  @override
  String get authInvalidEmail => 'Invalid email format';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordHint =>
      'Choose a strong password of at least 6 characters';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get retry => 'Retry';

  @override
  String get errOrderNotFound => 'This order no longer exists.';

  @override
  String get errInvalidTransition =>
      'The order status has already changed. Please check the latest status.';

  @override
  String errItemUnavailable(String name) {
    return '\"$name\" is currently unavailable.';
  }

  @override
  String errInsufficientStock(String name) {
    return 'Not enough stock: $name.';
  }

  @override
  String get errBillNotReady =>
      'The bill can be closed once every order of the table has been served.';

  @override
  String get errNothingToPay => 'This table has no open orders.';

  @override
  String get errTableExists => 'A table with this number already exists.';

  @override
  String get errCategoryInUse => 'This category still contains menu items.';

  @override
  String get errPermissionDenied =>
      'You do not have permission for this action.';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get accessDenied =>
      'Sign in with a staff account that has access to this screen.';

  @override
  String get staffLogin => 'Staff sign-in';

  @override
  String get staffLoginSubtitle => 'Kitchen display and admin panel';

  @override
  String get authNoStaffAccess =>
      'This account has no staff access yet. An access request was sent; ask an admin to approve it.';

  @override
  String get requestStaffAccount => 'Request a staff account';

  @override
  String get staffRequestSent =>
      'Account created. An admin has to approve it before you can sign in.';

  @override
  String get staffSignupHint =>
      'Create an account for kitchen staff. It gets access after an admin approves the request.';

  @override
  String tableNotFound(String table) {
    return 'Table $table is not registered. Please check the number or ask the staff.';
  }

  @override
  String tableDisabled(String table) {
    return 'Table $table is currently not available for ordering.';
  }

  @override
  String get billTotal => 'Bill total';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get soldOut => 'Sold out';

  @override
  String get bills => 'Bills';

  @override
  String get noOpenBills => 'No open bills';

  @override
  String get closeBill => 'Close bill (paid)';

  @override
  String confirmCloseBill(String table, String total) {
    return 'Mark the bill of table $table ($total) as paid?';
  }

  @override
  String billClosed(String table) {
    return 'Table $table: bill closed';
  }

  @override
  String get billRequestedByTable => 'Bill requested';

  @override
  String get tablesAndQr => 'Tables & QR codes';

  @override
  String get addTable => 'Add table';

  @override
  String tableAdded(String table) {
    return 'Table $table added';
  }

  @override
  String get printQrCodes => 'Print QR codes';

  @override
  String get noTablesYet =>
      'No tables yet. Add a table to generate its QR code.';

  @override
  String confirmDeleteTable(String table) {
    return 'Delete table $table? Its QR code will stop working.';
  }

  @override
  String get tableStatusDisabled => 'Disabled';

  @override
  String get tableStatusFree => 'Free';

  @override
  String get staffSection => 'Staff';

  @override
  String get staffAdminHint =>
      'Kitchen staff create an account from the sign-in page; approve the request here to give it access to orders and stock.';

  @override
  String get staffRequestsTitle => 'Access requests';

  @override
  String get noStaffRequests => 'No pending requests';

  @override
  String get approveAction => 'Approve';

  @override
  String get rejectAction => 'Reject';

  @override
  String staffApproved(String email) {
    return '$email now has kitchen access';
  }

  @override
  String get kitchenStaffTitle => 'Kitchen staff';

  @override
  String get noKitchenStaff => 'No kitchen staff yet';

  @override
  String get revokeAction => 'Revoke access';

  @override
  String confirmRevokeStaff(String email) {
    return 'Remove kitchen access for $email?';
  }

  @override
  String confirmDeleteCategory(String name) {
    return 'Delete the category \"$name\"?';
  }

  @override
  String get createCategoryFirst => 'Create a category first.';

  @override
  String get menuItemUpdated => 'Menu item updated';

  @override
  String recipeLinesCount(String count) {
    return 'Recipe: $count ingredients';
  }

  @override
  String get availableOnMenu => 'Shown on the menu';

  @override
  String get recipeTitle => 'Recipe (per portion)';

  @override
  String get recipeHint =>
      'These quantities are taken from stock when the kitchen accepts an order.';

  @override
  String get addRecipeLine => 'Add ingredient';

  @override
  String get weekRevenue => 'Revenue this week';

  @override
  String get todayOrdersCount => 'Orders today';

  @override
  String get weekOrdersCount => 'Orders this week';

  @override
  String get openOrdersCount => 'Open orders';

  @override
  String get cancelledToday => 'Cancelled today';

  @override
  String get tableStatusOccupied => 'Occupied';
}
