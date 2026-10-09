// lib/core/config/app_env.dart

/// ═══════════════════════════════════════════════════════════
/// AppEnv — مفاتيح البيئة (Supabase وغيرها)
/// ═══════════════════════════════════════════════════════════
///
/// ⚠️ مهم جداً:
/// - الملف ده فيه مفاتيح حساسة
/// - لا ترفعه على GitHub بمفاتيح حقيقية
/// - استخدم --dart-define أو .env في الإنتاج
///
/// حالياً: placeholders (نستبدلها في المرحلة 8)
///
class AppEnv {
  AppEnv._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) Supabase
  // ═══════════════════════════════════════════════════════════

  /// رابط مشروع Supabase
  ///
  /// مثال: 'https://abcdefgh.supabase.co'
   static const String supabaseUrl = 'https://skhssmwzdrubgkoykavo.supabase.co';

  /// مفتاح Supabase العام (anon key)
  ///
  /// ⚠️ آمن للاستخدام في التطبيق (public)
  /// لكن لا ترفعه على GitHub
     static const String supabasePublishableKey = 'sb_publishable_Xpex2k09D6RaW0bmCpkoMg_DeH3V2BE';

  /// مفتاح Service Role (للسيرفر فقط)
  ///
  /// ⚠️ خطر جداً — لا تحطه في التطبيق أبداً
  /// (يُستخدم فقط في Edge Functions)
  static const String supabaseServiceRoleKey = 'YOUR_SERVICE_ROLE_KEY';
  /// (يُستخدم فقط في Edge Functions)
  // ═══════════════════════════════════════════════════════════
  // 2) اسم المشروع
  // ═══════════════════════════════════════════════════════════

  /// اسم مشروع Supabase (للعرض فقط)
  static const String supabaseProjectName = 'FixHub';

  /// المنطقة (Region)
  ///
  /// أمثلة: 'us-east-1', 'eu-central-1', 'ap-south-1'
  static const String supabaseRegion = 'me-central-1';

  // ═══════════════════════════════════════════════════════════
  // 3) مفاتيح مستقبلية (Phase 8+)
  // ═══════════════════════════════════════════════════════════

  // ─── Firebase (لاحقاً — للإشعارات) ───

  /// Firebase API Key
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';

  /// Firebase Project ID
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';

  /// Firebase Sender ID
  static const String firebaseSenderId = 'YOUR_FIREBASE_SENDER_ID';

  // ─── RevenueCat (لاحقاً — للاشتراكات) ───

  /// RevenueCat API Key (Android)
  static const String revenueCatAndroidKey = 'YOUR_REVENUECAT_ANDROID';

  /// RevenueCat API Key (iOS)
  static const String revenueCatIosKey = 'YOUR_REVENUECAT_IOS';

  /// RevenueCat Entitlement (اسم الباقة)
  static const String revenueCatEntitlement = 'pro';

  // ─── Google Maps (لاحقاً — للعناوين) ───

  /// Google Maps API Key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_KEY';

  // ═══════════════════════════════════════════════════════════
  // 4) دوال مساعدة
  // ═══════════════════════════════════════════════════════════

  /// هل Supabase متظبط؟
  ///
  /// ترجع false لو المفاتيح لسه placeholders
    static bool get isSupabaseConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseUrl.isNotEmpty &&
        supabasePublishableKey != 'YOUR_PUBLISHABLE_KEY' &&
        supabasePublishableKey.isNotEmpty;
  }

  /// هل Firebase متظبط؟
  static bool get isFirebaseConfigured {
    return firebaseApiKey != 'YOUR_FIREBASE_API_KEY';
  }

  /// هل RevenueCat متظبط؟
  static bool get isRevenueCatConfigured {
    return revenueCatAndroidKey != 'YOUR_REVENUECAT_ANDROID' ||
        revenueCatIosKey != 'YOUR_REVENUECAT_IOS';
  }

  /// طباعة تحذير لو Supabase مش متظبط (للاستخدام في Debug)
  static void warnIfNotConfigured() {
    if (!isSupabaseConfigured) {
      // ignore: avoid_print
      print(
        '⚠️ [AppEnv] Supabase مش متظبط! '
        'عدّل lib/core/config/app_env.dart',
      );
    }
  }
}