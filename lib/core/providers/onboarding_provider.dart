// lib/core/providers/onboarding_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'prefs_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// OnboardingNotifier — إدارة حالة الـ onboarding
/// ═══════════════════════════════════════════════════════════
///
/// بيقرأ ويكتب `onboarding_done` في SharedPreferences.
///
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this.ref) : super(false) {
    _load();
  }

  final Ref ref;

  void _load() {
    final prefs = ref.read(sharedPrefsProvider);
    state = prefs.getBool(AppConstants.prefsOnboardingDone) ?? false;
  }

  /// تعيين إن الـ onboarding خلص
  Future<void> complete() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(AppConstants.prefsOnboardingDone, true);
    state = true;
  }

  /// إعادة الـ onboarding (للتطوير/الاختبار)
  Future<void> reset() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(AppConstants.prefsOnboardingDone, false);
    state = false;
  }
}

/// ═══════════════════════════════════════════════════════════
/// onboardingProvider — حالة الـ onboarding
/// ═══════════════════════════════════════════════════════════
///
/// - `true`  → المستخدم شاف الـ onboarding
/// - `false` → المستخدم لسه ما شافهوش
///
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});