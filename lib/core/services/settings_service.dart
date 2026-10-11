import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/settings/data/models/app_settings.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  SETTINGS SERVICE (singleton per tenant)
// ═══════════════════════════════════════════════════════════════

class SettingsService {
  SettingsService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'settings';

  // ─── Cache مؤقت (لكل instance) ───
  AppSettings? _cached;

  // ─────────────────────────────────────────────────────────────
  //  READ
  // ─────────────────────────────────────────────────────────────

  /// جلب إعدادات الورشة (get-or-create)
  ///
  /// - لو موجودة → يرجّعها
  /// - لو مش موجودة → ينشئ صف جديد بإعدادات افتراضية
  /// - لو في cache → يرجّعه (مع force refresh)
  Future<AppSettings> getSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;

    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return AppSettings.empty;

      final data = await _client
          .from(_table)
          .select()
          .eq('tenant_id', tenantId)
          .maybeSingle();

      if (data == null) {
        // أنشئ صف افتراضي
        return await _createDefault(tenantId);
      }

      final settings = AppSettings.fromJson(Map<String, dynamic>.from(data));
      _cached = settings;
      return settings;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SettingsService.getSettings error: $e');
      }
      return AppSettings.empty;
    }
  }

  /// جلب الإعدادات بدون cache (نسخة جديدة دايماً)
  Future<AppSettings> fetchFresh() => getSettings(forceRefresh: true);

  // ─────────────────────────────────────────────────────────────
  //  WRITE
  // ─────────────────────────────────────────────────────────────

  /// حفظ الإعدادات (insert أو update تلقائي)
  Future<AppSettings?> save(AppSettings settings) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return null;

      final payload = settings.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..['tenant_id'] = tenantId;

      // upsert على tenant_id
      final data = await _client
          .from(_table)
          .upsert(payload, onConflict: 'tenant_id')
          .select()
          .single();

      final updated = AppSettings.fromJson(Map<String, dynamic>.from(data));
      _cached = updated;
      return updated;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SettingsService.save error: $e');
      }
      return null;
    }
  }

  /// تحديث جزئي — ياخد دالة بتعدّل النسخة الحالية
  Future<AppSettings?> update(
    AppSettings Function(AppSettings current) updater,
  ) async {
    final current = await getSettings();
    final modified = updater(current);
    return save(modified);
  }

  // ─────────────────────────────────────────────────────────────
  //  CONVENIENCE UPDATES (للأجزاء الشائعة)
  // ─────────────────────────────────────────────────────────────

  /// حفظ معلومات الورشة الأساسية
  Future<AppSettings?> saveShopInfo({
    required String shopName,
    String? shopPhone,
    String? shopWhatsapp,
    String? shopAddress,
    String? shopLogoUrl,
  }) {
    return update((s) => s.copyWith(
          shopName: shopName,
          shopPhone: shopPhone,
          shopWhatsapp: shopWhatsapp,
          shopAddress: shopAddress,
          shopLogoUrl: shopLogoUrl,
        ));
  }

  /// حفظ قوالب الواتساب
  Future<AppSettings?> saveWhatsappTemplates(
    WhatsappTemplates templates,
  ) {
    return update((s) => s.copyWith(whatsappTemplates: templates));
  }

  /// حفظ إعدادات الإشعارات
  Future<AppSettings?> saveNotificationSettings(
    NotificationSettings notifications,
  ) {
    return update((s) => s.copyWith(notificationSettings: notifications));
  }

  /// حفظ العملة + الضريبة
  Future<AppSettings?> saveFinancialSettings({
    String? currency,
    double? taxRate,
  }) {
    return update((s) => s.copyWith(
          currency: currency,
          taxRate: taxRate,
        ));
  }

  /// حفظ footer الإيصال + الشروط
  Future<AppSettings?> saveReceiptContent({
    String? receiptFooter,
    String? termsConditions,
  }) {
    return update((s) => s.copyWith(
          receiptFooter: receiptFooter,
          termsConditions: termsConditions,
        ));
  }

  // ─────────────────────────────────────────────────────────────
  //  STATIC HELPERS (بدون instance — للاستخدام المباشر)
  // ─────────────────────────────────────────────────────────────

  /// تعبئة قالب بقيم
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

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

  /// إنشاء صف افتراضي لورشة جديدة
  Future<AppSettings> _createDefault(String tenantId) async {
    try {
      final payload = AppSettings.empty.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..['tenant_id'] = tenantId;

      final data = await _client.from(_table).insert(payload).select().single();

      final created = AppSettings.fromJson(Map<String, dynamic>.from(data));
      _cached = created;
      return created;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SettingsService._createDefault error: $e');
      }
      // fallback: ارجع نسخة افتراضية في الذاكرة
      return AppSettings.empty.copyWith(tenantId: tenantId);
    }
  }

  /// إفراغ الـ cache (مثلاً بعد logout)
  void clearCache() {
    _cached = null;
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return SettingsService(client: client, authService: authService);
});

/// Stream لإعدادات الورشة (يُحدَّث تلقائياً)
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final service = ref.watch(settingsServiceProvider);
  return service.getSettings();
});

/// Stream للإعدادات مع إمكانية التحديث الفوري
final appSettingsNotifierProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final service = ref.watch(settingsServiceProvider);
    return service.getSettings();
  }

  /// إعادة تحميل من Supabase
  Future<void> refresh() async {
    state = const AsyncLoading();
    final service = ref.read(settingsServiceProvider);
    state = await AsyncValue.guard(() => service.fetchFresh());
  }

  /// حفظ إعدادات كاملة
  Future<bool> save(AppSettings settings) async {
    final service = ref.read(settingsServiceProvider);
    final result = await service.save(settings);
    if (result != null) {
      state = AsyncData(result);
      return true;
    }
    return false;
  }

  /// تحديث جزئي (اسم مختلف عن AsyncNotifier.update المحجوز)
  Future<bool> patch(
    AppSettings Function(AppSettings) updater,
  ) async {
    final service = ref.read(settingsServiceProvider);
    final result = await service.update(updater);
    if (result != null) {
      state = AsyncData(result);
      return true;
    }
    return false;
  }
}
