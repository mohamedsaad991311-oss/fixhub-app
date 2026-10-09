// lib/core/constants/app_constants.dart

/// ═══════════════════════════════════════════════════════════
/// AppConstants — ثوابت تقنية للتطبيق
/// ═══════════════════════════════════════════════════════════
///
/// ده المكان الوحيد لـ:
/// - أسماء Hive Boxes
/// - مفاتيح SharedPreferences
/// - مفاتيح التخزين المحلي
/// - Timeouts
/// - Durations
/// - Limits
///
class AppConstants {
  AppConstants._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) HIVE BOXES
  // ═══════════════════════════════════════════════════════════

  /// Box إعدادات الثيم
  static const String themeBox = 'theme_settings';

  /// Box إعدادات اللغة
  static const String localeBox = 'locale_settings';

  /// Box بيانات المستخدم الحالي
  static const String userBox = 'user_data';

  /// Box إعدادات التطبيق (shop info, whatsapp, ...)
  static const String settingsBox = 'app_settings';

  /// Box الكاش العام
  static const String cacheBox = 'cache_data';

  /// Box الإيصالات (offline)
  static const String receiptsBox = 'receipts_data';

  /// Box المخزون (offline)
  static const String inventoryBox = 'inventory_data';

  /// Box الموردين (offline)
  static const String suppliersBox = 'suppliers_data';

  /// Box الموظفين (offline)
  static const String staffBox = 'staff_data';

  /// Box المزامنة (queue للعمليات المعلقة)
  static const String syncQueueBox = 'sync_queue';

  // ═══════════════════════════════════════════════════════════
  // 2) SHARED PREFERENCES KEYS
  // ═══════════════════════════════════════════════════════════

  /// هل شاشات الـ onboarding اتعرضت؟
  static const String prefsOnboardingDone = 'onboarding_done';

  /// هل دي أول مرة يفتح التطبيق؟
  static const String prefsFirstLaunch = 'first_launch';

  /// تاريخ آخر مزامنة
  static const String prefsLastSync = 'last_sync';

  /// هل البصمة مفعّلة؟
  static const String prefsBiometricEnabled = 'biometric_enabled';

  /// هل PIN مفعّل؟
  static const String prefsPinEnabled = 'pin_enabled';

  /// رقم الـ PIN (مشفر)
  static const String prefsPinHash = 'pin_hash';

  /// هل المستخدم مسجّل دخول؟
  static const String prefsLoggedIn = 'logged_in';

  /// تاريخ انتهاء الاشتراك
  static const String prefsSubscriptionExpiry = 'subscription_expiry';

  /// هل الاشتراك Pro؟
  static const String prefsIsPro = 'is_pro';

  // ═══════════════════════════════════════════════════════════
  // 3) SECURE STORAGE KEYS
  // ═══════════════════════════════════════════════════════════

  /// مفتاح Supabase session
  static const String secureSupabaseSession = 'supabase_session';

  /// مفتاح الـ access token
  static const String secureAccessToken = 'access_token';

  /// مفتاح الـ refresh token
  static const String secureRefreshToken = 'refresh_token';

  /// مفتاح الـ PIN المشفر
  static const String securePinHash = 'secure_pin_hash';

  // ═══════════════════════════════════════════════════════════
  // 4) TIMEOUTS
  // ═══════════════════════════════════════════════════════════

  /// timeout قصير (للطلبات السريعة)
  static const Duration timeoutShort = Duration(seconds: 10);

  /// timeout متوسط (افتراضي)
  static const Duration timeoutMedium = Duration(seconds: 30);

  /// timeout طويل (للرفع الكبير)
  static const Duration timeoutLong = Duration(minutes: 2);

  /// timeout للاتصال
  static const Duration timeoutConnection = Duration(seconds: 15);

  // ═══════════════════════════════════════════════════════════
  // 5) ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════

  /// حركة سريعة
  static const Duration animQuick = Duration(milliseconds: 150);

  /// حركة عادية
  static const Duration animNormal = Duration(milliseconds: 300);

  /// حركة بطيئة
  static const Duration animSlow = Duration(milliseconds: 500);

  /// مدة ظهور SnackBar
  static const Duration snackBarDuration = Duration(seconds: 3);

  /// مدة ظهور Toast
  static const Duration toastDuration = Duration(seconds: 2);

  // ═══════════════════════════════════════════════════════════
  // 6) LIMITS
  // ═══════════════════════════════════════════════════════════

  /// الحد الأقصى لحجم الصورة (MB)
  static const int maxImageSizeMB = 5;

  /// الحد الأقصى لحجم الصورة (bytes)
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  /// الحد الأقصى لعدد الملفات المرفوعة
  static const int maxUploadFiles = 5;

  /// الحد الأدنى لطول كلمة المرور
  static const int minPasswordLength = 6;

  /// الحد الأقصى لطول كلمة المرور
  static const int maxPasswordLength = 32;

  /// طول الـ PIN
  static const int pinLength = 4;

  /// الحد الأقصى لعدد المحاولات قبل القفل
  static const int maxLoginAttempts = 5;

  /// مدة القفل بعد تجاوز المحاولات (دقائق)
  static const int lockoutDurationMinutes = 15;

  // ═══════════════════════════════════════════════════════════
  // 7) API / NETWORK
  // ═══════════════════════════════════════════════════════════

  /// عدد العناصر في الصفحة (pagination)
  static const int pageSize = 20;

  /// الحد الأقصى لعناصر الصفحة
  static const int maxPageSize = 100;

  /// عدد محاولات إعادة الطلب
  static const int maxRetries = 3;

  /// تأخير بين المحاولات (ثواني)
  static const int retryDelaySeconds = 2;

  // ═══════════════════════════════════════════════════════════
  // 8) FILE PATHS
  // ═══════════════════════════════════════════════════════════

  /// مجلد الصور المرفوعة
  static const String uploadsFolder = 'uploads';

  /// مجلد الإيصالات المطبوعة
  static const String receiptsFolder = 'receipts';

  /// مجلد النسخ الاحتياطي
  static const String backupsFolder = 'backups';

  /// مجلد الفواتير
  static const String invoicesFolder = 'invoices';

  /// بادئة أسماء الملفات المرفوعة
  static const String uploadFilePrefix = 'fixhub_';

  // ═══════════════════════════════════════════════════════════
  // 9) STATUS CODES (للاستخدام الداخلي)
  // ═══════════════════════════════════════════════════════════

  /// كود النجاح
  static const int codeSuccess = 200;

  /// كود الإنشاء
  static const int codeCreated = 201;

  /// كود طلب غير صحيح
  static const int codeBadRequest = 400;

  /// كود غير مصرح
  static const int codeUnauthorized = 401;

  /// كود ممنوع
  static const int codeForbidden = 403;

  /// كود غير موجود
  static const int codeNotFound = 404;

  /// كود خطأ السيرفر
  static const int codeServerError = 500;

  // ═══════════════════════════════════════════════════════════
  // 10) REGEX PATTERNS
  // ═══════════════════════════════════════════════════════════

  /// نمط البريد الإلكتروني
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// نمط رقم الموبايل المصري
  static const String egyptPhonePattern = r'^(010|011|012|015)\d{8}$';

  /// نمط رقم الموبايل الدولي (مع +)
  static const String intlPhonePattern = r'^\+?[1-9]\d{1,14}$';

  /// نمط كلمة المرور (6-32 حرف)
  static const String passwordPattern = r'^.{6,32}$';

  /// نمط الـ PIN (4 أرقام)
  static const String pinPattern = r'^\d{4}$';

  /// نمط الرقم العشري
  static const String decimalPattern = r'^\d+(\.\d+)?$';

  /// نمط الأرقام فقط
  static const String digitsOnlyPattern = r'^\d+$';
}