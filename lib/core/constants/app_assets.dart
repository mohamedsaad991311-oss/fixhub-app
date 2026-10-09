// lib/core/constants/app_assets.dart

/// ═══════════════════════════════════════════════════════════
/// AppAssets — مسارات الأصول (Images, Icons, Lottie, Fonts)
/// ═══════════════════════════════════════════════════════════
///
/// كل مسار asset في التطبيق لازم يبقى هنا.
/// ده بيضمن:
/// - مفيش أخطاء إملائية
/// - سهولة التعديل
/// - autocomplete في الـ IDE
///
class AppAssets {
  AppAssets._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) IMAGES — الصور
  // ═══════════════════════════════════════════════════════════

  static const String _imagesPath = 'assets/images';

  /// شعار التطبيق
  static const String logo = '$_imagesPath/logo.png';

  /// شعار التطبيق (أبيض — للـ Dark)
  static const String logoWhite = '$_imagesPath/logo_white.png';

  /// شعار مع النص
  static const String logoWithText = '$_imagesPath/logo_with_text.png';

  /// صورة الـ onboarding 1
  static const String onboarding1 = '$_imagesPath/onboarding_1.png';

  /// صورة الـ onboarding 2
  static const String onboarding2 = '$_imagesPath/onboarding_2.png';

  /// صورة الـ onboarding 3
  static const String onboarding3 = '$_imagesPath/onboarding_3.png';

  /// صورة "لا يوجد بيانات"
  static const String emptyState = '$_imagesPath/empty_state.png';

  /// صورة "لا يوجد إنترنت"
  static const String noInternet = '$_imagesPath/no_internet.png';

  /// صورة الخطأ العام
  static const String errorImage = '$_imagesPath/error.png';

  /// صورة النجاح
  static const String successImage = '$_imagesPath/success.png';

  /// صورة الخلفية (للـ Splash)
  static const String splashBackground = '$_imagesPath/splash_bg.png';

  /// صورة placeholder للأفاتار
  static const String avatarPlaceholder = '$_imagesPath/avatar.png';

  // ═══════════════════════════════════════════════════════════
  // 2) ICONS — الأيقونات
  // ═══════════════════════════════════════════════════════════

  static const String _iconsPath = 'assets/icons';

  /// أيقونة الإيصال
  static const String receiptIcon = '$_iconsPath/receipt.svg';

  /// أيقونة المخزون
  static const String inventoryIcon = '$_iconsPath/inventory.svg';

  /// أيقونة الموردين
  static const String supplierIcon = '$_iconsPath/supplier.svg';

  /// أيقونة الموظفين
  static const String staffIcon = '$_iconsPath/staff.svg';

  /// أيقونة التقارير
  static const String reportsIcon = '$_iconsPath/reports.svg';

  /// أيقونة الإعدادات
  static const String settingsIcon = '$_iconsPath/settings.svg';

  /// أيقونة التتبع
  static const String trackingIcon = '$_iconsPath/tracking.svg';

  /// أيقونة الواتساب
  static const String whatsappIcon = '$_iconsPath/whatsapp.svg';

  /// أيقونة الطباعة
  static const String printIcon = '$_iconsPath/print.svg';

  /// أيقونة الماسح
  static const String scannerIcon = '$_iconsPath/scanner.svg';

  // ═══════════════════════════════════════════════════════════
  // 3) LOTTIE — رسومات متحركة
  // ═══════════════════════════════════════════════════════════

  static const String _lottiePath = 'assets/lottie';

  /// تحميل
  static const String loading = '$_lottiePath/loading.json';

  /// نجاح
  static const String success = '$_lottiePath/success.json';

  /// خطأ
  static const String error = '$_lottiePath/error.json';

  /// لا يوجد بيانات
  static const String empty = '$_lottiePath/empty.json';

  /// لا يوجد إنترنت
  static const String offline = '$_lottiePath/offline.json';

  /// شاشة الترحيب
  static const String welcome = '$_lottiePath/welcome.json';

  /// إصلاح الجهاز
  static const String repairing = '$_lottiePath/repairing.json';

  /// جاهز
  static const String ready = '$_lottiePath/ready.json';

  /// تم التسليم
  static const String delivered = '$_lottiePath/delivered.json';

  // ═══════════════════════════════════════════════════════════
  // 4) FONTS — الخطوط
  // ═══════════════════════════════════════════════════════════

  /// ⚠️ ملاحظة: بنستخدم Google Fonts (Cairo, Amiri, Playfair)
  /// عشان كده مفيش خطوط محلية حالياً.
  ///
  /// لو حبيت تضيف خط محلي:
  /// 1. حط الملف في assets/fonts/
  /// 2. ضيفه في pubspec.yaml
  /// 3. ضيف المسار هنا

  static const String _fontsPath = 'assets/fonts';

  /// الخط العربي الأساسي (احتياطي)
  static const String fontCairo = '$_fontsPath/Cairo-Regular.ttf';

  /// الخط العربي العريض (احتياطي)
  static const String fontCairoBold = '$_fontsPath/Cairo-Bold.ttf';

  // ═══════════════════════════════════════════════════════════
  // 5) دوال مساعدة
  // ═══════════════════════════════════════════════════════════

  /// التحقق من امتداد الصورة
  static bool isImage(String path) {
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp');
  }

  /// التحقق من امتداد SVG
  static bool isSvg(String path) => path.endsWith('.svg');

  /// التحقق من امتداد Lottie
  static bool isLottie(String path) => path.endsWith('.json');

  /// التحقق من امتداد خط
  static bool isFont(String path) =>
      path.endsWith('.ttf') || path.endsWith('.otf');

  /// إرجاع المسار الكامل لأصل
  ///
  /// (مفيد لو حبيت تختار folder ديناميكياً)
  static String assetPath(String folder, String fileName) {
    return 'assets/$folder/$fileName';
  }
}