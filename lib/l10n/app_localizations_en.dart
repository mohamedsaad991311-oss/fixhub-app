// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FixHub';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get home => 'Home';

  @override
  String get receipts => 'Receipts';

  @override
  String get inventory => 'Inventory';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get staff => 'Staff';

  @override
  String get expenses => 'Expenses';

  @override
  String get reports => 'Reports';

  @override
  String get scanner => 'Scanner';

  @override
  String get cloud => 'Cloud';

  @override
  String get delivery => 'Delivery';

  @override
  String get inventoryItems => 'Items';

  @override
  String get inventoryQuantity => 'Quantity';

  @override
  String get inventoryValue => 'Value';

  @override
  String get inventoryNewItem => 'New Item';

  @override
  String get inventoryEmpty => 'No items in inventory';

  @override
  String get inventoryEmptySubtitle => 'Start by adding your first item';

  @override
  String get inventoryNoResults => 'No results for current filter';

  @override
  String get inventoryNoResultsSubtitle => 'Try changing or clearing filters';

  @override
  String get inventoryClearFilters => 'Clear Filters';

  @override
  String get inventoryDeleteTitle => 'Delete item?';

  @override
  String get inventoryDeleteConfirm =>
      'Are you sure you want to delete this item?';

  @override
  String get inventoryDeleted => 'Deleted';

  @override
  String get inventoryDeleteFailed => 'Delete failed';

  @override
  String get retry => 'Retry';

  @override
  String get viewDetails => 'View Details';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get newReceipt => 'New Receipt';

  @override
  String get newExpense => 'New Expense';

  @override
  String get newSupplier => 'New Supplier';

  @override
  String get newStaff => 'New Staff';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get activeRepairs => 'Active Repairs';

  @override
  String get pendingDeliveries => 'Pending Deliveries';

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String get total => 'Total';

  @override
  String get status => 'Status';

  @override
  String get customer => 'Customer';

  @override
  String get device => 'Device';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get actions => 'Actions';

  @override
  String get notes => 'Notes';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get details => 'Details';

  @override
  String get print => 'Print';

  @override
  String get share => 'Share';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get or => 'Or';

  @override
  String get biometric => 'Biometric';

  @override
  String get pinCode => 'PIN Code';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signupNow => 'Sign up now';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get sessionExpired =>
      'Session expired. Please login with email or phone.';

  @override
  String get biometricFailed => 'Biometric authentication failed';

  @override
  String get deviceBlockedTitle => 'Account linked to another device';

  @override
  String get deviceBlockedMessage =>
      'This account is active on another device. For your security, login is allowed from one device only.';

  @override
  String get currentDevice => 'Currently registered device';

  @override
  String get unknownDevice => 'Unknown';

  @override
  String get platform => 'Platform';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get contactAdminHint =>
      'Contact the shop manager to deactivate the old device.';

  @override
  String get contactAdmin => 'Contact Manager';

  @override
  String get tryAgain => 'Try logging in again';

  @override
  String get now => 'Now';

  @override
  String minutesAgo(Object count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get custom => 'Custom';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get fromDate => 'From date';

  @override
  String get toDate => 'To date';

  @override
  String get reportsLoadFailed => 'Failed to load reports';

  @override
  String get reportsNoData => 'No data for the selected period';

  @override
  String get reportsTotalRevenue => 'Total Revenue';

  @override
  String get reportsTotalExpenses => 'Total Expenses';

  @override
  String get reportsNetProfit => 'Net Profit';

  @override
  String get reportsTotalReceipts => 'Total Receipts';

  @override
  String get reportsDeliveredReceipts => 'Delivered';

  @override
  String get reportsActiveReceipts => 'Active';

  @override
  String get reportsRejectedReceipts => 'Rejected';

  @override
  String get reportsTotalDeposits => 'Total Deposits';

  @override
  String get reportsPendingAmount => 'Pending Collection';

  @override
  String get reportsProfitMargin => 'Profit Margin';

  @override
  String get reportsAvgPerReceipt => 'Avg per Receipt';

  @override
  String get reportsDeliveryRate => 'Delivery Rate';

  @override
  String get reportsExpensesByCategory => 'Expenses by Category';

  @override
  String get reportsRevenueChart => 'Revenue';

  @override
  String get reportsExpensesChart => 'Expenses';

  @override
  String get reportsTopReceipts => 'Top Receipts';

  @override
  String get reportsStockValue => 'Stock Value';

  @override
  String get reportsLowStock => 'Low Stock';

  @override
  String get reportsOutOfStock => 'Out of Stock';

  @override
  String get reportsTotalSuppliers => 'Suppliers';

  @override
  String get reportsTotalDebt => 'Total Debt';

  @override
  String get reportsTotalOwed => 'Total Owed';

  @override
  String get reportsDuringPeriod => 'During period';

  @override
  String get reportsProfit => 'Profit';

  @override
  String get reportsLoss => 'Loss';

  @override
  String get reportsOfRevenue => 'Of revenue';

  @override
  String reportsReceiptDeliveredCount(Object count) {
    return '$count receipts delivered';
  }
}
