// lib/core/services/device_info_service.dart

import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ═══════════════════════════════════════════════════════════════
//  DEVICE INFO — بيانات الجهاز
// ═══════════════════════════════════════════════════════════════

class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
    required this.appBuildNumber,
  });

  /// معرّف فريد للجهاز (UUID hex ثابت)
  final String deviceId;

  /// اسم مقروء للجهاز (Samsung A52, iPhone 13...)
  final String deviceName;

  /// الموديل الفني (SM-A525F, iPhone14,5...)
  final String deviceModel;

  /// المنصة: android / ios / windows / web / linux / macos
  final String platform;

  /// نسخة النظام (Android 13, iOS 16.4...)
  final String osVersion;

  /// نسخة التطبيق (1.0.0)
  final String appVersion;

  /// رقم البناء (42)
  final String appBuildNumber;

  /// للعرض المختصر
  String get displayName => deviceName.isNotEmpty ? deviceName : deviceModel;

  /// للعرض الكامل
  String get fullDescription => '$deviceName • $osVersion';

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'device_name': deviceName,
        'device_model': deviceModel,
        'platform': platform,
        'os_version': osVersion,
        'app_version': appVersion,
        'app_build_number': appBuildNumber,
      };

  @override
  String toString() =>
      'DeviceInfo($deviceName, $platform $osVersion, id: ${deviceId.substring(0, 8)}...)';
}

// ═══════════════════════════════════════════════════════════════
//  DEVICE INFO SERVICE
// ═══════════════════════════════════════════════════════════════

class DeviceInfoService {
  DeviceInfoService({
    FlutterSecureStorage? storage,
    DeviceInfoPlugin? deviceInfo,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final FlutterSecureStorage _storage;
  final DeviceInfoPlugin _deviceInfo;

  static const String _deviceIdKey = 'fixhub_device_id';

  // ─── Cache ───
  DeviceInfo? _cached;

  /// جلب معلومات الجهاز (مع cache)
  Future<DeviceInfo> getInfo({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached!;

    final deviceId = await _getOrCreateDeviceId();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceName = 'Unknown';
    String deviceModel = 'Unknown';
    String platform = 'unknown';
    String osVersion = 'unknown';

    try {
      if (kIsWeb) {
        platform = 'web';
        deviceName = 'Web Browser';
        deviceModel = 'Web';
        osVersion = 'Web';
      } else if (Platform.isAndroid) {
        platform = 'android';
        final info = await _deviceInfo.androidInfo;
        deviceName = '${info.manufacturer} ${info.model}';
        deviceModel = info.model;
        osVersion = 'Android ${info.version.release}';
      } else if (Platform.isIOS) {
        platform = 'ios';
        final info = await _deviceInfo.iosInfo;
        deviceName = info.name;
        deviceModel = info.utsname.machine;
        osVersion = 'iOS ${info.systemVersion}';
      } else if (Platform.isWindows) {
        platform = 'windows';
        final info = await _deviceInfo.windowsInfo;
        deviceName = info.computerName;
        deviceModel = info.productName;
        osVersion = 'Windows ${info.releaseId}';
      } else if (Platform.isMacOS) {
        platform = 'macos';
        final info = await _deviceInfo.macOsInfo;
        deviceName = info.computerName;
        deviceModel = info.model;
        osVersion = 'macOS ${info.osRelease}';
      } else if (Platform.isLinux) {
        platform = 'linux';
        final info = await _deviceInfo.linuxInfo;
        deviceName = info.prettyName;
        deviceModel = info.id;
        osVersion = info.version ?? 'Linux';
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DeviceInfoService.getInfo error: $e');
      }
    }

    final info = DeviceInfo(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceModel: deviceModel,
      platform: platform,
      osVersion: osVersion,
      appVersion: packageInfo.version,
      appBuildNumber: packageInfo.buildNumber,
    );

    _cached = info;
    return info;
  }

  /// جلب معرّف الجهاز فقط (بدون معلومات إضافية)
  Future<String> getDeviceId() async {
    if (_cached != null) return _cached!.deviceId;
    return _getOrCreateDeviceId();
  }

  /// حذف الـ device_id (نادراً — للاختبار)
  Future<void> clearDeviceId() async {
    try {
      await _storage.delete(key: _deviceIdKey);
      _cached = null;
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL
  // ─────────────────────────────────────────────────────────────

  /// جلب أو توليد device_id ثابت
  Future<String> _getOrCreateDeviceId() async {
    try {
      // 1. حاول اقرأ من secure storage
      final existing = await _storage.read(key: _deviceIdKey);
      if (existing != null && existing.isNotEmpty) {
        return existing;
      }

      // 2. ما لقيناش → ولّد جديد
      final newId = _generateDeviceId();
      await _storage.write(key: _deviceIdKey, value: newId);
      return newId;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_getOrCreateDeviceId error: $e');
      }
      // fallback: ولّد في الذاكرة بس (مش ثابت)
      return _generateDeviceId();
    }
  }

  /// توليد 32-char hex ID (يشبه UUID v4)
  String _generateDeviceId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));

    // اضبط بتات UUID v4 (اختياري — للتوافق مع قواعد UUID)
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant

    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

final deviceInfoServiceProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService();
});

/// معلومات الجهاز (Async)
final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  final service = ref.watch(deviceInfoServiceProvider);
  return service.getInfo();
});

/// device_id فقط (للعمليات السريعة)
final deviceIdProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(deviceInfoServiceProvider);
  return service.getDeviceId();
});
