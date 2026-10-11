// lib/core/services/pin_lock_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ═══════════════════════════════════════════════════════════════
//  PIN CONFIG
// ═══════════════════════════════════════════════════════════════

class PinConfig {
  const PinConfig({
    this.minLength = 4,
    this.maxLength = 6,
    this.maxAttempts = 10,
    this.lockoutThresholds = const [
      LockoutRule(attempts: 3, lockDuration: Duration(seconds: 30)),
      LockoutRule(attempts: 5, lockDuration: Duration(minutes: 5)),
      LockoutRule(attempts: 10, lockDuration: Duration(minutes: 30)),
    ],
  });

  final int minLength;
  final int maxLength;
  final int maxAttempts;
  final List<LockoutRule> lockoutThresholds;

  /// الحصول على مدة القفل حسب عدد المحاولات
  Duration? lockoutFor(int attempts) {
    Duration? duration;
    for (final rule in lockoutThresholds) {
      if (attempts >= rule.attempts) {
        duration = rule.lockDuration;
      }
    }
    return duration;
  }
}

class LockoutRule {
  const LockoutRule({
    required this.attempts,
    required this.lockDuration,
  });

  final int attempts;
  final Duration lockDuration;
}

// ═══════════════════════════════════════════════════════════════
//  PIN RESULT
// ═══════════════════════════════════════════════════════════════

enum PinResult {
  success,
  wrongPin,
  locked,
  notSet,
  invalid,
  error,
}

extension PinResultX on PinResult {
  bool get isSuccess => this == PinResult.success;

  String get messageAr {
    switch (this) {
      case PinResult.success:
        return 'تم بنجاح';
      case PinResult.wrongPin:
        return 'رمز PIN غير صحيح';
      case PinResult.locked:
        return 'القفل مؤقتاً. حاول بعد قليل.';
      case PinResult.notSet:
        return 'لم يتم إعداد PIN بعد';
      case PinResult.invalid:
        return 'صيغة PIN غير صحيحة';
      case PinResult.error:
        return 'حدث خطأ غير متوقع';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  PIN LOCK SERVICE
// ═══════════════════════════════════════════════════════════════

class PinLockService {
  PinLockService({
    FlutterSecureStorage? storage,
    PinConfig config = const PinConfig(),
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _config = config;

  final FlutterSecureStorage _storage;
  final PinConfig _config;

  // ─── Storage Keys ───
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _pinLengthKey = 'pin_length';
  static const String _failedAttemptsKey = 'pin_failed_attempts';
  static const String _lockedUntilKey = 'pin_locked_until';
  static const String _enabledKey = 'pin_enabled';

  // ─── Cache ───
  bool? _cachedEnabled;
  int? _cachedFailedAttempts;

  // ─── Getters ───
  PinConfig get config => _config;

  // ─────────────────────────────────────────────────────────────
  //  STATUS
  // ─────────────────────────────────────────────────────────────

  /// هل فيه PIN معيّن؟
  Future<bool> hasPin() async {
    try {
      final hash = await _storage.read(key: _pinHashKey);
      return hash != null && hash.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// هل الـ PIN lock مُفعَّل؟
  Future<bool> isEnabled() async {
    if (_cachedEnabled != null) return _cachedEnabled!;
    try {
      final value = await _storage.read(key: _enabledKey);
      _cachedEnabled = value == 'true';
      return _cachedEnabled!;
    } catch (_) {
      return false;
    }
  }

  /// تفعيل/تعطيل PIN (بدون حذف الـ PIN نفسه)
  Future<bool> setEnabled({required bool enabled}) async {
    try {
      if (enabled) {
        await _storage.write(key: _enabledKey, value: 'true');
      } else {
        await _storage.delete(key: _enabledKey);
      }
      _cachedEnabled = enabled;
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('setEnabled error: $e');
      }
      return false;
    }
  }

  /// طول الـ PIN الحالي
  Future<int?> getPinLength() async {
    try {
      final value = await _storage.read(key: _pinLengthKey);
      if (value == null) return null;
      return int.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SETUP
  // ─────────────────────────────────────────────────────────────

  /// إعداد PIN جديد (أول مرة)
  ///
  /// لو فيه PIN موجود → هيحل محل القديم
  Future<PinResult> setupPin(String pin) async {
    // 1. Validation
    if (!_isValidPin(pin)) return PinResult.invalid;

    try {
      // 2. Generate salt
      final salt = _generateSalt();

      // 3. Hash PIN + salt
      final hash = _hashPin(pin, salt);

      // 4. Store
      await _storage.write(key: _pinHashKey, value: hash);
      await _storage.write(key: _pinSaltKey, value: salt);
      await _storage.write(key: _pinLengthKey, value: pin.length.toString());

      // 5. Reset state
      await _clearFailedAttempts();
      await _storage.delete(key: _lockedUntilKey);

      // 6. Enable
      await setEnabled(enabled: true);

      // 7. Init defaults
      return PinResult.success;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('setupPin error: $e');
      }
      return PinResult.error;
    }
  }

  /// تغيير PIN (محتاج القديم)
  Future<PinResult> changePin({
    required String oldPin,
    required String newPin,
  }) async {
    final verify = await verifyPin(oldPin);
    if (!verify.isSuccess) return verify;

    if (!_isValidPin(newPin)) return PinResult.invalid;
    return setupPin(newPin);
  }

  /// حذف PIN
  Future<bool> removePin() async {
    try {
      await _storage.delete(key: _pinHashKey);
      await _storage.delete(key: _pinSaltKey);
      await _storage.delete(key: _pinLengthKey);
      await _storage.delete(key: _enabledKey);
      await _storage.delete(key: _failedAttemptsKey);
      await _storage.delete(key: _lockedUntilKey);

      _cachedEnabled = null;
      _cachedFailedAttempts = null;
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('removePin error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  VERIFY
  // ─────────────────────────────────────────────────────────────

  /// التحقق من PIN
  Future<PinResult> verifyPin(String pin) async {
    // 1. هل فيه PIN؟
    if (!await hasPin()) return PinResult.notSet;

    // 2. هل القفل مفعّل؟
    if (await isLocked()) return PinResult.locked;

    // 3. Validation (بس لو طوله مش من النوع الصح)
    if (pin.isEmpty) return PinResult.invalid;

    try {
      // 4. اجيب الـ salt + hash
      final salt = await _storage.read(key: _pinSaltKey);
      final storedHash = await _storage.read(key: _pinHashKey);
      if (salt == null || storedHash == null) {
        return PinResult.notSet;
      }

      // 5. احسب hash الجديد
      final computedHash = _hashPin(pin, salt);

      // 6. قارن (constant-time)
      final matches = _constantTimeEquals(computedHash, storedHash);

      if (matches) {
        await _clearFailedAttempts();
        return PinResult.success;
      } else {
        await _incrementFailedAttempts();
        // فحص لو اتقفل بعد الفشل
        if (await isLocked()) return PinResult.locked;
        return PinResult.wrongPin;
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('verifyPin error: $e');
      }
      return PinResult.error;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  LOCKOUT
  // ─────────────────────────────────────────────────────────────

  /// هل الحساب مقفول مؤقتاً؟
  Future<bool> isLocked() async {
    try {
      final lockedUntil = await getLockedUntil();
      if (lockedUntil == null) return false;
      return DateTime.now().isBefore(lockedUntil);
    } catch (_) {
      return false;
    }
  }

  /// لغاية إمتى الحساب مقفول؟
  Future<DateTime?> getLockedUntil() async {
    try {
      final value = await _storage.read(key: _lockedUntilKey);
      if (value == null) return null;
      return DateTime.tryParse(value);
    } catch (_) {
      return null;
    }
  }

  /// الوقت المتبقي للقفل (بالثواني)
  Future<int> getRemainingLockSeconds() async {
    final lockedUntil = await getLockedUntil();
    if (lockedUntil == null) return 0;
    final remaining = lockedUntil.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  /// عدد المحاولات الفاشلة
  Future<int> getFailedAttempts() async {
    if (_cachedFailedAttempts != null) return _cachedFailedAttempts!;
    try {
      final value = await _storage.read(key: _failedAttemptsKey);
      _cachedFailedAttempts = int.tryParse(value ?? '0') ?? 0;
      return _cachedFailedAttempts!;
    } catch (_) {
      return 0;
    }
  }

  /// عدد المحاولات المتبقية قبل القفل التالي
  Future<int> getRemainingAttempts() async {
    final attempts = await getFailedAttempts();
    final nextThreshold = _config.lockoutThresholds.firstWhere(
      (rule) => attempts < rule.attempts,
      orElse: () => _config.lockoutThresholds.last,
    );
    final remaining = nextThreshold.attempts - attempts;
    return remaining < 0 ? 0 : remaining;
  }

  /// إعادة تعيين المحاولات (بعد sign in ناجح بكلمة مرور)
  Future<void> resetAttempts() async {
    await _clearFailedAttempts();
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

  bool _isValidPin(String pin) {
    if (pin.isEmpty) return false;
    if (pin.length < _config.minLength) return false;
    if (pin.length > _config.maxLength) return false;
    // أرقام فقط
    if (!RegExp(r'^\d+$').hasMatch(pin)) return false;
    return true;
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin:$salt');
    final digest = sha256.convert(bytes);
    // Hash مرتين (تقليل احتمال collision)
    final secondDigest = sha256.convert(
      utf8.encode('${digest.toString()}:$salt'),
    );
    return secondDigest.toString();
  }

  /// مقارنة constant-time (تفادي timing attacks)
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  Future<void> _incrementFailedAttempts() async {
    final current = await getFailedAttempts();
    final next = current + 1;
    _cachedFailedAttempts = next;

    await _storage.write(key: _failedAttemptsKey, value: next.toString());

    // شوف لو لازم نقفل
    final lockDuration = _config.lockoutFor(next);
    if (lockDuration != null) {
      final lockedUntil = DateTime.now().add(lockDuration);
      await _storage.write(
        key: _lockedUntilKey,
        value: lockedUntil.toIso8601String(),
      );

      if (kDebugMode) {
        // ignore: avoid_print
        print(
            '🔒 PIN locked for ${lockDuration.inMinutes}m after $next attempts');
      }
    }
  }

  Future<void> _clearFailedAttempts() async {
    _cachedFailedAttempts = 0;
    try {
      await _storage.delete(key: _failedAttemptsKey);
      await _storage.delete(key: _lockedUntilKey);
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

final pinLockServiceProvider = Provider<PinLockService>((ref) {
  return PinLockService();
});

/// هل فيه PIN معيّن؟
final hasPinProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(pinLockServiceProvider);
  return service.hasPin();
});

/// هل PIN مُفعّل؟
final pinEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(pinLockServiceProvider);
  return service.isEnabled();
});

/// هل الحساب مقفول؟
final pinLockedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(pinLockServiceProvider);
  return service.isLocked();
});
