// lib/core/router/route_names.dart

/// ═══════════════════════════════════════════════════════════
/// RouteNames — ثوابت أسماء المسارات
/// ═══════════════════════════════════════════════════════════
///
/// كل مسار في التطبيق لازم يبقى هنا.
/// الفايدة:
/// - مفيش magic strings
/// - autocomplete
/// - سهل التعديل
///
class RouteNames {
  RouteNames._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) ROOT & SPLASH
  // ═══════════════════════════════════════════════════════════

  /// المسار الجذر
  static const String root = '/';

  /// شاشة البداية
  static const String splash = '/splash';

  // ═══════════════════════════════════════════════════════════
  // 2) ONBOARDING
  // ═══════════════════════════════════════════════════════════

  /// شاشات الترحيب
  static const String onboarding = '/onboarding';

  // ═══════════════════════════════════════════════════════════
  // 3) AUTH
  // ═══════════════════════════════════════════════════════════

  /// تسجيل الدخول
  static const String login = '/login';

  /// إنشاء حساب
  static const String signup = '/signup';

  /// نسيت كلمة المرور
  static const String forgotPassword = '/forgot-password';

  /// إعادة تعيين كلمة المرور
  static const String resetPassword = '/reset-password';

  /// قفل PIN
  static const String pinLock = '/pin-lock';

  // ═══════════════════════════════════════════════════════════
  // 4) MAIN APP (تحت الـ Shell)
  // ═══════════════════════════════════════════════════════════

  /// الرئيسية (Dashboard)
  static const String home = '/home';

  /// الإيصالات (قائمة)
  static const String receipts = '/receipts';

  /// تفاصيل إيصال
  static const String receiptDetail = '/receipts/:id';

  /// إنشاء إيصال (استلام جهاز)
  static const String receiptCreate = '/receipts/create';

  /// معالج استلام جهاز جديد (Wizard 3 خطوات)
  static const String receivingWizard = '/receipts/receiving';

  /// تعديل إيصال
  static const String receiptEdit = '/receipts/:id/edit';

  /// المخزون
  static const String inventory = '/inventory';

  /// تفاصيل قطعة
  static const String inventoryDetail = '/inventory/:id';

  /// إضافة/تعديل قطعة
  static const String inventoryEdit = '/inventory/edit';

  /// الموردين
  static const String suppliers = '/suppliers';

  /// تفاصيل مورد
  static const String supplierDetail = '/suppliers/:id';

  /// إضافة/تعديل مورد
  static const String supplierEdit = '/suppliers/edit';

  /// فواتير الموردين
  static const String supplierInvoices = '/suppliers/:id/invoices';

  /// مدفوعات الموردين
  static const String supplierPayments = '/suppliers/:id/payments';

  /// مرتجعات الموردين
  static const String supplierReturns = '/suppliers/:id/returns';

  /// الموظفين
  static const String staff = '/staff';

  /// تفاصيل موظف
  static const String staffDetail = '/staff/:id';

  /// إضافة/تعديل موظف
  static const String staffEdit = '/staff/edit';

  /// المصروفات
  static const String expenses = '/expenses';

  /// تفاصيل مصروف
  static const String expenseDetail = '/expenses/:id';

  /// إضافة/تعديل مصروف
  static const String expenseEdit = '/expenses/edit';

  /// التسليم
  static const String delivery = '/delivery';

  /// التقارير
  static const String reports = '/reports';

  /// الماسح
  static const String scanner = '/scanner';

  /// التتبع
  static const String tracking = '/tracking';

  /// تفاصيل تتبع
  static const String trackingDetail = '/tracking/:token';

  /// المزامنة السحابية
  static const String cloudSync = '/cloud-sync';

  /// النسخ الاحتياطي
  static const String backup = '/backup';

  /// سجل النشاط
  static const String activityLog = '/activity-log';

  /// الاشتراكات
  static const String subscription = '/subscription';

  // ═══════════════════════════════════════════════════════════
  // 5) SETTINGS
  // ═══════════════════════════════════════════════════════════

  /// الإعدادات
  static const String settings = '/settings';

  /// معلومات الورشة
  static const String shopInfo = '/settings/shop-info';

  /// الواتساب
  static const String whatsappSettings = '/settings/whatsapp';

  /// المظهر
  static const String themeSettings = '/settings/theme';

  /// اللغة
  static const String languageSettings = '/settings/language';

  /// الأمان
  static const String securitySettings = '/settings/security';

  /// النسخ الاحتياطي
  static const String backupSettings = '/settings/backup';

  /// الاشتراك
  static const String subscriptionSettings = '/settings/subscription';

  /// حول التطبيق
  static const String about = '/settings/about';

  // ═══════════════════════════════════════════════════════════
  // 6) ADMIN
  // ═══════════════════════════════════════════════════════════

  /// لوحة الأدمن
  static const String adminDashboard = '/admin';

  /// طلب إعادة تعيين الجهاز (للعميل)
  static const String deviceResetRequest = '/device-reset-request';

  /// الأجهزة المرتبطة بالحساب
  static const String devices = '/devices';

  /// دعوات الموظفين
  static const String invitations = '/invitations';
  // ═══════════════════════════════════════════════════════════
  // 7) ERROR / NOT FOUND
  // ═══════════════════════════════════════════════════════════

  /// خطأ 404
  static const String notFound = '/404';

  /// خطأ عام
  static const String error = '/error';

  // ═══════════════════════════════════════════════════════════
  // 8) دوال مساعدة
  // ═══════════════════════════════════════════════════════════

  /// توليد مسار تفاصيل إيصال
  static String receiptDetailOf(String id) => '/receipts/$id';

  /// توليد مسار تعديل إيصال
  static String receiptEditOf(String id) => '/receipts/$id/edit';

  /// توليد مسار تفاصيل قطعة
  static String inventoryDetailOf(String id) => '/inventory/$id';

  /// توليد مسار تفاصيل مورد
  static String supplierDetailOf(String id) => '/suppliers/$id';

  /// توليد مسار تفاصيل موظف
  static String staffDetailOf(String id) => '/staff/$id';

  /// توليد مسار تفاصيل مصروف
  static String expenseDetailOf(String id) => '/expenses/$id';

  /// توليد مسار تفاصيل تتبع
  static String trackingDetailOf(String token) => '/tracking/$token';

  /// توليد مسار فواتير مورد
  static String supplierInvoicesOf(String id) => '/suppliers/$id/invoices';

  /// توليد مسار مدفوعات مورد
  static String supplierPaymentsOf(String id) => '/suppliers/$id/payments';

  /// توليد مسار مرتجعات مورد
  static String supplierReturnsOf(String id) => '/suppliers/$id/returns';
}
