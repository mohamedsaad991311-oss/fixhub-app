// lib/core/router/route_names.dart

/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
/// RouteNames â€” Ø«ÙˆØ§Ø¨Øª Ø£Ø³Ù…Ø§Ø¡ Ø§Ù„Ù…Ø³Ø§Ø±Ø§Øª
/// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
///
/// ÙƒÙ„ Ù…Ø³Ø§Ø± ÙÙŠ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ Ù„Ø§Ø²Ù… ÙŠØ¨Ù‚Ù‰ Ù‡Ù†Ø§.
/// Ø§Ù„ÙØ§ÙŠØ¯Ø©:
/// - Ù…ÙÙŠØ´ magic strings
/// - autocomplete
/// - Ø³Ù‡Ù„ Ø§Ù„ØªØ¹Ø¯ÙŠÙ„
///
class RouteNames {
  RouteNames._(); // Ù…Ù†Ø¹ Ø§Ù„Ø¥Ù†Ø´Ø§Ø¡

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 1) ROOT & SPLASH
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Ø§Ù„Ù…Ø³Ø§Ø± Ø§Ù„Ø¬Ø°Ø±
  static const String root = '/';

  /// Ø´Ø§Ø´Ø© Ø§Ù„Ø¨Ø¯Ø§ÙŠØ©
  static const String splash = '/splash';

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 2) ONBOARDING
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Ø´Ø§Ø´Ø§Øª Ø§Ù„ØªØ±Ø­ÙŠØ¨
  static const String onboarding = '/onboarding';

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 3) AUTH
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„
  static const String login = '/login';

  /// Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨
  static const String signup = '/signup';

  /// Ù†Ø³ÙŠØª ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±
  static const String forgotPassword = '/forgot-password';

  /// Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ† ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±
  static const String resetPassword = '/reset-password';

  /// Ù‚ÙÙ„ PIN
  static const String pinLock = '/pin-lock';

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 4) MAIN APP (ØªØ­Øª Ø§Ù„Ù€ Shell)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ© (Dashboard)
  static const String home = '/home';

  /// Ø§Ù„Ø¥ÙŠØµØ§Ù„Ø§Øª (Ù‚Ø§Ø¦Ù…Ø©)
  static const String receipts = '/receipts';

  /// ØªÙØ§ØµÙŠÙ„ Ø¥ÙŠØµØ§Ù„
  static const String receiptDetail = '/receipts/:id';

  /// Ø¥Ù†Ø´Ø§Ø¡ Ø¥ÙŠØµØ§Ù„ (Ø§Ø³ØªÙ„Ø§Ù… Ø¬Ù‡Ø§Ø²)
  static const String receiptCreate = '/receipts/create';

  /// Ù…Ø¹Ø§Ù„Ø¬ Ø§Ø³ØªÙ„Ø§Ù… Ø¬Ù‡Ø§Ø² Ø¬Ø¯ÙŠØ¯ (Wizard 3 Ø®Ø·ÙˆØ§Øª)
  static const String receivingWizard = '/receipts/receiving';

  /// ØªØ¹Ø¯ÙŠÙ„ Ø¥ÙŠØµØ§Ù„
  static const String receiptEdit = '/receipts/:id/edit';

  /// Ø§Ù„Ù…Ø®Ø²ÙˆÙ†
  static const String inventory = '/inventory';

  /// Point of Sale
  static const String pos = '/pos';

  /// ØªÙØ§ØµÙŠÙ„ Ù‚Ø·Ø¹Ø©
  static const String inventoryDetail = '/inventory/:id';

  /// Ø¥Ø¶Ø§ÙØ©/ØªØ¹Ø¯ÙŠÙ„ Ù‚Ø·Ø¹Ø©
  static const String inventoryEdit = '/inventory/edit';

  /// Ø§Ù„Ù…ÙˆØ±Ø¯ÙŠÙ†
  static const String suppliers = '/suppliers';

  /// ØªÙØ§ØµÙŠÙ„ Ù…ÙˆØ±Ø¯
  static const String supplierDetail = '/suppliers/:id';

  /// Ø¥Ø¶Ø§ÙØ©/ØªØ¹Ø¯ÙŠÙ„ Ù…ÙˆØ±Ø¯
  static const String supplierEdit = '/suppliers/edit';

  /// ÙÙˆØ§ØªÙŠØ± Ø§Ù„Ù…ÙˆØ±Ø¯ÙŠÙ†
  static const String supplierInvoices = '/suppliers/:id/invoices';

  /// Ù…Ø¯ÙÙˆØ¹Ø§Øª Ø§Ù„Ù…ÙˆØ±Ø¯ÙŠÙ†
  static const String supplierPayments = '/suppliers/:id/payments';

  /// Ù…Ø±ØªØ¬Ø¹Ø§Øª Ø§Ù„Ù…ÙˆØ±Ø¯ÙŠÙ†
  static const String supplierReturns = '/suppliers/:id/returns';

  /// Ø§Ù„Ù…ÙˆØ¸ÙÙŠÙ†
  static const String staff = '/staff';

  /// ØªÙØ§ØµÙŠÙ„ Ù…ÙˆØ¸Ù
  static const String staffDetail = '/staff/:id';

  /// Ø¥Ø¶Ø§ÙØ©/ØªØ¹Ø¯ÙŠÙ„ Ù…ÙˆØ¸Ù
  static const String staffEdit = '/staff/edit';

  /// Ø§Ù„Ù…ØµØ±ÙˆÙØ§Øª
  static const String expenses = '/expenses';

  /// ØªÙØ§ØµÙŠÙ„ Ù…ØµØ±ÙˆÙ
  static const String expenseDetail = '/expenses/:id';

  /// Ø¥Ø¶Ø§ÙØ©/ØªØ¹Ø¯ÙŠÙ„ Ù…ØµØ±ÙˆÙ
  static const String expenseEdit = '/expenses/edit';

  /// Ø§Ù„ØªØ³Ù„ÙŠÙ…
  static const String delivery = '/delivery';

  /// Ø§Ù„ØªÙ‚Ø§Ø±ÙŠØ±
  static const String reports = '/reports';

  /// Ø§Ù„Ù…Ø§Ø³Ø­
  static const String scanner = '/scanner';

  /// Ø§Ù„ØªØªØ¨Ø¹
  static const String tracking = '/tracking';

  /// ØªÙØ§ØµÙŠÙ„ ØªØªØ¨Ø¹
  static const String trackingDetail = '/tracking/:token';

  /// Ø§Ù„Ù…Ø²Ø§Ù…Ù†Ø© Ø§Ù„Ø³Ø­Ø§Ø¨ÙŠØ©
  static const String cloudSync = '/cloud-sync';

  /// Ø§Ù„Ù†Ø³Ø® Ø§Ù„Ø§Ø­ØªÙŠØ§Ø·ÙŠ
  static const String backup = '/backup';

  /// Ø³Ø¬Ù„ Ø§Ù„Ù†Ø´Ø§Ø·
  static const String activityLog = '/activity-log';

  /// Ø§Ù„Ø§Ø´ØªØ±Ø§ÙƒØ§Øª
  static const String subscription = '/subscription';

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 5) SETTINGS
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª
  static const String settings = '/settings';

  /// Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„ÙˆØ±Ø´Ø©
  static const String shopInfo = '/settings/shop-info';

  /// Ø§Ù„ÙˆØ§ØªØ³Ø§Ø¨
  static const String whatsappSettings = '/settings/whatsapp';

  /// Ø§Ù„Ù…Ø¸Ù‡Ø±
  static const String themeSettings = '/settings/theme';

  /// Ø§Ù„Ù„ØºØ©
  static const String languageSettings = '/settings/language';

  /// Ø§Ù„Ø£Ù…Ø§Ù†
  static const String securitySettings = '/settings/security';

  /// Ø§Ù„Ù†Ø³Ø® Ø§Ù„Ø§Ø­ØªÙŠØ§Ø·ÙŠ
  static const String backupSettings = '/settings/backup';

  /// Ø§Ù„Ø§Ø´ØªØ±Ø§Ùƒ
  static const String subscriptionSettings = '/settings/subscription';

  /// Ø­ÙˆÙ„ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚
  static const String about = '/settings/about';

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 6) ADMIN
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Ù„ÙˆØ­Ø© Ø§Ù„Ø£Ø¯Ù…Ù†
  static const String adminDashboard = '/admin';

  /// Ø·Ù„Ø¨ Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ† Ø§Ù„Ø¬Ù‡Ø§Ø² (Ù„Ù„Ø¹Ù…ÙŠÙ„)
  static const String deviceResetRequest = '/device-reset-request';

  /// Ø§Ù„Ø£Ø¬Ù‡Ø²Ø© Ø§Ù„Ù…Ø±ØªØ¨Ø·Ø© Ø¨Ø§Ù„Ø­Ø³Ø§Ø¨
  static const String devices = '/devices';

  /// Ø¯Ø¹ÙˆØ§Øª Ø§Ù„Ù…ÙˆØ¸ÙÙŠÙ†
  static const String invitations = '/invitations';
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 7) ERROR / NOT FOUND
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Ø®Ø·Ø£ 404
  static const String notFound = '/404';

  /// Ø®Ø·Ø£ Ø¹Ø§Ù…
  static const String error = '/error';

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // 8) Ø¯ÙˆØ§Ù„ Ù…Ø³Ø§Ø¹Ø¯Ø©
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªÙØ§ØµÙŠÙ„ Ø¥ÙŠØµØ§Ù„
  static String receiptDetailOf(String id) => '/receipts/$id';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªØ¹Ø¯ÙŠÙ„ Ø¥ÙŠØµØ§Ù„
  static String receiptEditOf(String id) => '/receipts/$id/edit';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªÙØ§ØµÙŠÙ„ Ù‚Ø·Ø¹Ø©
  static String inventoryDetailOf(String id) => '/inventory/$id';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªÙØ§ØµÙŠÙ„ Ù…ÙˆØ±Ø¯
  static String supplierDetailOf(String id) => '/suppliers/$id';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªÙØ§ØµÙŠÙ„ Ù…ÙˆØ¸Ù
  static String staffDetailOf(String id) => '/staff/$id';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªÙØ§ØµÙŠÙ„ Ù…ØµØ±ÙˆÙ
  static String expenseDetailOf(String id) => '/expenses/$id';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ØªÙØ§ØµÙŠÙ„ ØªØªØ¨Ø¹
  static String trackingDetailOf(String token) => '/tracking/$token';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± ÙÙˆØ§ØªÙŠØ± Ù…ÙˆØ±Ø¯
  static String supplierInvoicesOf(String id) => '/suppliers/$id/invoices';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± Ù…Ø¯ÙÙˆØ¹Ø§Øª Ù…ÙˆØ±Ø¯
  static String supplierPaymentsOf(String id) => '/suppliers/$id/payments';

  /// ØªÙˆÙ„ÙŠØ¯ Ù…Ø³Ø§Ø± Ù…Ø±ØªØ¬Ø¹Ø§Øª Ù…ÙˆØ±Ø¯
  static String supplierReturnsOf(String id) => '/suppliers/$id/returns';
}

