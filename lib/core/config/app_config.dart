// lib/core/config/app_config.dart

/// ═══════════════════════════════════════════════════════════
/// AppConfig — الإعدادات المركزية للتطبيق
/// ═══════════════════════════════════════════════════════════
///
/// ده المكان الوحيد اللي بنعدّل فيه:
/// - اسم التطبيق
/// - رقم الواتساب
/// - قوالب رسائل الواتساب
/// - الأسعار الافتراضية
/// - إعدادات عامة
///
class AppConfig {
  AppConfig._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) معلومات التطبيق
  // ═══════════════════════════════════════════════════════════

  /// اسم التطبيق (يظهر في AppBar + Splash + About)
  static const String appName = 'FixHub';

  /// اسم التطبيق بالعربي
  static const String appNameAr = 'فيكس هَب';

  /// الإصدار (يتحدّث يدوياً أو من package_info_plus لاحقاً)
  static const String appVersion = '1.0.0';

  /// رقم الإصدار (للمقارنة)
  static const int appBuildNumber = 1;

  /// Bundle ID
  static const String bundleId = 'com.fixhub.app';

  /// الموقع الرسمي / الدعم
  static const String supportEmail = 'support@fixhub.app';
  static const String supportPhone = '+201000000000';

  // ═══════════════════════════════════════════════════════════
  // 2) الواتساب
  // ═══════════════════════════════════════════════════════════

  /// كود الدولة الافتراضي (مصر)
  static const String defaultCountryCode = '+20';

  /// رابط الواتساب الرسمي (wa.me)
  static const String whatsappBaseUrl = 'https://wa.me';

  /// قالب رسالة ترحيب للعميل الجديد
  static const String whatsappWelcomeTemplate =
      'مرحباً {customerName} 👋\n'
      'شكراً لاختيارك {shopName}.\n'
      'تم استلام جهازك: {deviceName}\n'
      'رقم الإيصال: {receiptNumber}\n'
      'يمكنك متابعة حالة الجهاز عبر الرابط:\n'
      '{trackingUrl}';

  /// قالب رسالة تحديث الحالة
  static const String whatsappStatusUpdateTemplate =
      'مرحباً {customerName} 👋\n'
      'تحديث بخصوص جهازك: {deviceName}\n'
      'الحالة الجديدة: {status}\n'
      'رقم الإيصال: {receiptNumber}\n'
      '{notes}';

  /// قالب رسالة "جاهز للاستلام"
  static const String whatsappReadyTemplate =
      'مرحباً {customerName} 👋\n'
      'خبر سعيد! جهازك جاهز للاستلام ✅\n'
      'الجهاز: {deviceName}\n'
      'المبلغ المطلوب: {amount}\n'
      'رقم الإيصال: {receiptNumber}\n'
      'في انتظارك في {shopName} 🏪';

  /// قالب رسالة "تم التسليم"
  static const String whatsappDeliveredTemplate =
      'شكراً لتعاملك معنا {customerName} 🙏\n'
      'تم تسليم جهازك: {deviceName}\n'
      'نتمنى لك تجربة ممتازة!\n'
      'لو حابب تقييمنا: {reviewUrl}';

  /// قالب رسالة التذكير
  static const String whatsappReminderTemplate =
      'مرحباً {customerName} 👋\n'
      'تذكير بخصوص جهازك: {deviceName}\n'
      'رقم الإيصال: {receiptNumber}\n'
      'في انتظارك في {shopName} 🏪';

  // ═══════════════════════════════════════════════════════════
  // 3) العملة والأسعار
  // ═══════════════════════════════════════════════════════════

  /// رمز العملة الافتراضي
  static const String currencySymbol = 'ج.م';

  /// كود العملة (ISO 4217)
  static const String currencyCode = 'EGP';

  /// عدد الخانات العشرية
  static const int currencyDecimals = 2;

  /// موضع رمز العملة (before / after)
  static const bool currencySymbolBefore = false;

  // ═══════════════════════════════════════════════════════════
  // 4) الفواتير والإيصالات
  // ═══════════════════════════════════════════════════════════

  /// بادئة رقم الإيصال
  static const String receiptPrefix = 'RCP';

  /// عدد خانات رقم الإيصال (مثلاً RCP-0001)
  static const int receiptNumberPadding = 4;

  /// نسبة الضريبة الافتراضية (%)
  static const double defaultTaxRate = 0.0;

  /// نسبة الخصم الأقصى المسموح (%)
  static const double maxDiscountPercent = 50.0;

  // ═══════════════════════════════════════════════════════════
  // 5) تتبع العميل
  // ═══════════════════════════════════════════════════════════

  /// رابط صفحة التتبع (يستخدم {token})
  static const String trackingUrlTemplate =
      'https://fixhub.app/track/{token}';

  /// مدة صلاحية التوكن (بالأيام)
  static const int trackingTokenExpiryDays = 90;

  // ═══════════════════════════════════════════════════════════
  // 6) إعدادات عامة
  // ═══════════════════════════════════════════════════════════

  /// اللغة الافتراضية
  static const String defaultLocale = 'ar';

  /// هل التطبيق RTL افتراضياً؟
  static const bool defaultRtl = true;

  /// عدد العناصر في الصفحة (pagination)
  static const int defaultPageSize = 20;

  /// timeout للطلبات (بالثواني)
  static const int networkTimeoutSeconds = 30;

  /// عدد محاولات إعادة الطلب
  static const int maxRetryAttempts = 3;

  /// تفعيل وضع Debug
  static const bool isDebugMode = true;

  // ═══════════════════════════════════════════════════════════
  // 7) قوالب إضافية
  // ═══════════════════════════════════════════════════════════

  /// حالة رفض الجهاز (سبب)
  static const String rejectionReasonDefault =
      'الجهاز غير قابل للإصلاح';

  /// ملاحظة افتراضية لعدم وجود قطع غيار
  static const String waitingPartsDefault =
      'في انتظار قطعة غيار من المورد';

  // ═══════════════════════════════════════════════════════════
  // 8) دوال مساعدة
  // ═══════════════════════════════════════════════════════════

  /// استبدال placeholders في قالب الرسالة
  ///
  /// مثال:
  /// ```dart
  /// AppConfig.fillTemplate(
  ///   AppConfig.whatsappWelcomeTemplate,
  ///   {
  ///     'customerName': 'أحمد',
  ///     'shopName': 'ورشة النور',
  ///     'deviceName': 'iPhone 13',
  ///     'receiptNumber': 'RCP-0001',
  ///     'trackingUrl': 'https://...',
  ///   },
  /// );
  /// ```
  static String fillTemplate(
    String template,
    Map<String, String> values,
  ) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// توليد رابط تتبع كامل من التوكن
  static String buildTrackingUrl(String token) {
    return trackingUrlTemplate.replaceAll('{token}', token);
  }

  /// توليد رقم إيصال كامل من الرقم
  static String formatReceiptNumber(int number) {
    final padded = number.toString().padLeft(receiptNumberPadding, '0');
    return '$receiptPrefix-$padded';
  }
}