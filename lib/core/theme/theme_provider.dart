// lib/core/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../localization/locale_provider.dart';
import 'app_theme.dart';
import 'theme_model.dart';

/// ═══════════════════════════════════════════════════════════
/// Theme Provider — إدارة الثيم عبر Riverpod + Hive
/// ═══════════════════════════════════════════════════════════
///
/// - Hive box: 'theme_settings'
/// - مفتاح التخزين: 'current'
/// - يقرأ ويحفظ تلقائياً
///
class ThemeKeys {
  ThemeKeys._();
  static const String boxName = 'theme_settings';
  static const String storageKey = 'current';
}

// ═══════════════════════════════════════════════════════════
// 1) ThemeNotifier — StateNotifier يدير الحالة
// ═══════════════════════════════════════════════════════════

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(ThemeSettings.defaults) {
    _load();
  }

  late final Box _box;

  /// تحميل الإعدادات من Hive
  Future<void> _load() async {
    try {
      _box = await Hive.openBox(ThemeKeys.boxName);
      final data = _box.get(ThemeKeys.storageKey);
      if (data != null && data is Map) {
        state = ThemeSettings.fromMap(data);
      }
    } catch (e) {
      // في حالة الفشل، نفضل على القيم الافتراضية
      debugPrint('ThemeNotifier._load error: $e');
    }
  }

  /// حفظ الإعدادات في Hive
  Future<void> _save() async {
    try {
      await _box.put(ThemeKeys.storageKey, state.toMap());
    } catch (e) {
      debugPrint('ThemeNotifier._save error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  // API العامة
  // ─────────────────────────────────────────────────────────

  /// تغيير مجموعة الألوان
  void setColorScheme(ColorSchemeType type) {
    state = state.copyWith(colorScheme: type);
    _save();
  }

  /// تغيير الوضع (Light / Dark / System)
  void setMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
    _save();
  }

  /// تغيير نمط التصميم
  void setStyle(ThemeStyle style) {
    state = state.copyWith(style: style);
    _save();
  }

  /// تغيير حجم الخط
  void setFontScale(FontScale scale) {
    state = state.copyWith(fontScale: scale);
    _save();
  }

  /// تغيير شكل الحواف
  void setCornerStyle(CornerStyle corner) {
    state = state.copyWith(cornerStyle: corner);
    _save();
  }

  /// تغيير شدة الزجاج
  void setGlassIntensity(GlassIntensity intensity) {
    state = state.copyWith(glassIntensity: intensity);
    _save();
  }

  /// إعادة كل الإعدادات للافتراضي
  void resetToDefaults() {
    state = ThemeSettings.defaults;
    _save();
  }
}

// ═══════════════════════════════════════════════════════════
// 2) themeProvider — الحالة الرئيسية
// ═══════════════════════════════════════════════════════════

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});

// ═══════════════════════════════════════════════════════════
// 3) themeModeProvider — ThemeMode للـ MaterialApp
// ═══════════════════════════════════════════════════════════

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(themeProvider);
  return AppTheme.themeMode(settings.mode);
});

// ═══════════════════════════════════════════════════════════
// 4) lightThemeProvider — ThemeData للوضع الفاتح
// ═══════════════════════════════════════════════════════════

final lightThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeProvider);
  final locale = ref.watch(localeProvider);
  final isArabic = locale.languageCode == 'ar';

  return AppTheme.light(settings, isArabic: isArabic);
});

// ═══════════════════════════════════════════════════════════
// 5) darkThemeProvider — ThemeData للوضع الداكن
// ═══════════════════════════════════════════════════════════

final darkThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeProvider);
  final locale = ref.watch(localeProvider);
  final isArabic = locale.languageCode == 'ar';

  return AppTheme.dark(settings, isArabic: isArabic);
});