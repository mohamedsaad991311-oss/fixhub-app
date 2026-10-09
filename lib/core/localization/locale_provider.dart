import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════
/// 🌍 مزود اللغة (Locale Provider)
/// ═══════════════════════════════════════════════
class LocaleNotifier extends StateNotifier<Locale> {
  static const _key = 'app_locale';
  static const _defaultLocale = Locale('ar');

  LocaleNotifier() : super(_defaultLocale) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        state = Locale(code);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(newLocale);
  }

  Future<void> setArabic() => setLocale(const Locale('ar'));
  Future<void> setEnglish() => setLocale(const Locale('en'));

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

final textDirectionProvider = Provider<TextDirection>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'ar'
      ? TextDirection.rtl
      : TextDirection.ltr;
});