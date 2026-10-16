// lib/core/services/biometric_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

// ═══════════════════════════════════════════════════════════════
//  BIOMETRIC RESULT
// ═══════════════════════════════════════════════════════════════

enum BiometricResult {
  success,
  failed,
  cancelled,
  unavailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  error,
}

extension BiometricResultX on BiometricResult {
  bool get isSuccess => this == BiometricResult.success;

  String get messageAr {
    switch (this) {
      case BiometricResult.success:
        return 'تم بنجاح';
      case BiometricResult.failed:
        return 'فشلت المصادقة. حاول مرة أخرى.';
      case BiometricResult.cancelled:
        return 'تم إلغاء المصادقة';
      case BiometricResult.unavailable:
        return 'البصمة غير متاحة على هذا الجهاز';
      case BiometricResult.notEnrolled:
        return 'لم يتم إعداد البصمة على الجهاز';
      case BiometricResult.lockedOut:
        return 'تم قفل البصمة مؤقتاً. حاول بعد قليل.';
      case BiometricResult.permanentlyLockedOut:
        return 'تم قفل البصمة. استخدم كلمة المرور.';
      case BiometricResult.error:
        return 'حدث خطأ غير متوقع';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  BIOMETRIC SERVICE
// ═══════════════════════════════════════════════════════════════

class BiometricService {
  BiometricService({LocalAuthentication? auth, FlutterSecureStorage? storage})
      : _auth = auth ?? LocalAuthentication(),
        _storage = storage ?? const FlutterSecureStorage();

  final LocalAuthentication _auth;
  final FlutterSecureStorage _storage;

  static const String _enabledKey = 'biometric_enabled';

  // ─────────────────────────────────────────────────────────────
  //  AVAILABILITY
  // ─────────────────────────────────────────────────────────────

  /// هل المنصة تدعم البصمة؟
  bool get isPlatformSupported {
    if (kIsWeb) return false;
    if (Platform.isAndroid || Platform.isIOS) return true;
    return false;
  }

  /// هل الجهاز يدعم البصمة + تم إعدادها؟
  Future<bool> isAvailable() async {
    if (!isPlatformSupported) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('biometric isAvailable error: $e');
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// جلب أنواع البصمة المتاحة
  Future<List<BiometricType>> getAvailableTypes() async {
    if (!isPlatformSupported) return const [];
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// هل فيه بصمة مُسجَّلة على الجهاز؟
  Future<bool> hasEnrolledBiometrics() async {
    final types = await getAvailableTypes();
    return types.isNotEmpty;
  }

  /// اسم البصمة المناسب للمنصة (للعرض)
  Future<String> getBiometricName({bool isArabic = true}) async {
    if (!isPlatformSupported) {
      return isArabic ? 'رمز PIN' : 'PIN';
    }

    final types = await getAvailableTypes();

    if (types.contains(BiometricType.face)) {
      if (Platform.isIOS) {
        return 'Face ID';
      }
      return isArabic ? 'التعرف على الوجه' : 'Face Recognition';
    }

    if (types.contains(BiometricType.iris)) {
      return isArabic ? 'قزحية العين' : 'Iris';
    }

    if (types.contains(BiometricType.fingerprint)) {
      if (Platform.isIOS) {
        return 'Touch ID';
      }
      return isArabic ? 'بصمة الإصبع' : 'Fingerprint';
    }

    return isArabic ? 'البصمة' : 'Biometric';
  }

  // ─────────────────────────────────────────────────────────────
  //  ENABLE / DISABLE
  // ─────────────────────────────────────────────────────────────

  /// هل البصمة مُفعّلة من إعدادات التطبيق؟
  Future<bool> isEnabled() async {
    try {
      final value = await _storage.read(key: _enabledKey);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// تفعيل/تعطيل البصمة
  Future<bool> setEnabled({required bool enabled}) async {
    try {
      if (enabled) {
        await _storage.write(key: _enabledKey, value: 'true');
      } else {
        await _storage.delete(key: _enabledKey);
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('setEnabled error: $e');
      }
      return false;
    }
  }

  /// هل البصمة جاهزة للاستخدام؟
  Future<bool> isReady() async {
    if (!await isEnabled()) return false;
    if (!await isAvailable()) return false;
    return await hasEnrolledBiometrics();
  }

  // ─────────────────────────────────────────────────────────────
  //  AUTHENTICATE
  // ─────────────────────────────────────────────────────────────

  /// محاولة مصادقة بالبصمة
  Future<BiometricResult> authenticate({
    String? reason,
    bool allowFallback = true,
  }) async {
    if (!isPlatformSupported) {
      return BiometricResult.unavailable;
    }

    if (!await isAvailable()) {
      return BiometricResult.unavailable;
    }

    if (!await hasEnrolledBiometrics()) {
      return BiometricResult.notEnrolled;
    }

    final message = reason ??
        (Platform.isIOS
            ? 'افتح FixHub باستخدام Face ID'
            : 'افتح FixHub باستخدام البصمة');

    try {
      final success = await _auth.authenticate(
        localizedReason: message,
        options: AuthenticationOptions(
          biometricOnly: !allowFallback,
          stickyAuth: true,
          sensitiveTransaction: true,
          useErrorDialogs: true,
        ),
      );

      return success ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      return _mapPlatformException(e);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('biometric authenticate error: $e');
      }
      return BiometricResult.error;
    }
  }

  /// مصادقة ببصمة فقط (بدون fallback لكلمة المرور)
  Future<BiometricResult> authenticateStrict({String? reason}) {
    return authenticate(reason: reason, allowFallback: false);
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

  BiometricResult _mapPlatformException(PlatformException e) {
    final code = e.code.toLowerCase();

    if (code.contains('notavailable') || code.contains('notavailableerror')) {
      return BiometricResult.unavailable;
    }
    if (code.contains('notenrolled')) {
      return BiometricResult.notEnrolled;
    }
    if (code.contains('lockedout') || code.contains('lockedoutpermanently')) {
      if (code.contains('permanent')) {
        return BiometricResult.permanentlyLockedOut;
      }
      return BiometricResult.lockedOut;
    }
    if (code.contains('canceled') || code.contains('cancel')) {
      return BiometricResult.cancelled;
    }
    if (code.contains('passcode')) {
      return BiometricResult.cancelled;
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('biometric platform error: ${e.code} — ${e.message}');
    }
    return BiometricResult.error;
  }

  /// إعادة تعيين "lockout" — للاستخدام بعد sign in
  Future<void> resetLockout() async {
    // local_auth مفيش عندها API مباشر لإعادة التعيين
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// هل البصمة جاهزة؟
final biometricReadyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isReady();
});

/// هل البصمة مُفعّلة؟
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isEnabled();
});
