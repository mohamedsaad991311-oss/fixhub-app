// lib/features/devices/data/models/active_device.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// ActiveDevice — نموذج جهاز مرتبط بحساب مستخدم
/// ═══════════════════════════════════════════════════════════════
///
/// يطابق جدول `active_devices` في Supabase:
/// id, user_id, tenant_id, device_id, device_name, device_model,
/// platform, os_version, app_version, app_build_number, last_ip,
/// last_seen_at, created_at, is_active, revoked_at, revoked_by
///
class ActiveDevice {
  const ActiveDevice({
    required this.id,
    required this.userId,
    required this.tenantId,
    required this.deviceId,
    required this.isActive,
    this.deviceName,
    this.deviceModel,
    this.platform,
    this.osVersion,
    this.appVersion,
    this.appBuildNumber,
    this.lastIp,
    this.lastSeenAt,
    this.createdAt,
    this.revokedAt,
    this.revokedBy,
  });

  final String id;
  final String userId;
  final String tenantId;
  final String deviceId;
  final bool isActive;
  final String? deviceName;
  final String? deviceModel;
  final String? platform;
  final String? osVersion;
  final String? appVersion;
  final String? appBuildNumber;
  final String? lastIp;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;
  final DateTime? revokedAt;
  final String? revokedBy;

  // ═══════════════════════════════════════════════════════════════
  //  getters مساعدة
  // ═══════════════════════════════════════════════════════════════

  /// الاسم المعروض (device_name أو device_model أو "جهاز غير معروف")
  String get displayName {
    if (deviceName != null && deviceName!.isNotEmpty) {
      return deviceName!;
    }
    if (deviceModel != null && deviceModel!.isNotEmpty) {
      return deviceModel!;
    }
    return 'جهاز غير معروف';
  }

  /// اسم المنصة بالعربي
  String get platformLabel {
    switch (platform?.toLowerCase()) {
      case 'android':
        return 'أندرويد';
      case 'ios':
        return 'iOS';
      case 'windows':
        return 'ويندوز';
      case 'macos':
        return 'ماك';
      case 'linux':
        return 'لينكس';
      case 'web':
        return 'الويب';
      default:
        return 'غير محدد';
    }
  }

  /// أيقونة المنصة
  IconData get platformIcon {
    switch (platform?.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.laptop_windows;
      case 'macos':
        return Icons.laptop_mac;
      case 'linux':
        return Icons.laptop;
      case 'web':
        return Icons.language;
      default:
        return Icons.devices_other;
    }
  }

  /// هل هذا هو الجهاز الحالي؟
  bool isCurrentDevice(String currentDeviceId) => deviceId == currentDeviceId;

  /// آخر ظهور بصيغة نسبية بالعربي
  String get relativeLastSeen {
    if (lastSeenAt == null) return 'غير معروف';
    final now = DateTime.now();
    final diff = now.difference(lastSeenAt!);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    return '${lastSeenAt!.day}/${lastSeenAt!.month}/${lastSeenAt!.year}';
  }

  // ═══════════════════════════════════════════════════════════════
  //  fromJson / toJson
  // ═══════════════════════════════════════════════════════════════

  factory ActiveDevice.fromJson(Map<String, dynamic> json) {
    return ActiveDevice(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      deviceName: json['device_name'] as String?,
      deviceModel: json['device_model'] as String?,
      platform: json['platform'] as String?,
      osVersion: json['os_version'] as String?,
      appVersion: json['app_version'] as String?,
      appBuildNumber: json['app_build_number'] as String?,
      lastIp: json['last_ip'] as String?,
      lastSeenAt: _parseDate(json['last_seen_at']),
      createdAt: _parseDate(json['created_at']),
      revokedAt: _parseDate(json['revoked_at']),
      revokedBy: json['revoked_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'tenant_id': tenantId,
        'device_id': deviceId,
        'is_active': isActive,
        'device_name': deviceName,
        'device_model': deviceModel,
        'platform': platform,
        'os_version': osVersion,
        'app_version': appVersion,
        'app_build_number': appBuildNumber,
        'last_ip': lastIp,
        'last_seen_at': lastSeenAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'revoked_at': revokedAt?.toIso8601String(),
        'revoked_by': revokedBy,
      };

  // ═══════════════════════════════════════════════════════════════
  //  copyWith
  // ═══════════════════════════════════════════════════════════════

  ActiveDevice copyWith({
    String? id,
    String? userId,
    String? tenantId,
    String? deviceId,
    bool? isActive,
    String? deviceName,
    String? deviceModel,
    String? platform,
    String? osVersion,
    String? appVersion,
    String? appBuildNumber,
    String? lastIp,
    DateTime? lastSeenAt,
    DateTime? createdAt,
    DateTime? revokedAt,
    String? revokedBy,
  }) {
    return ActiveDevice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      isActive: isActive ?? this.isActive,
      deviceName: deviceName ?? this.deviceName,
      deviceModel: deviceModel ?? this.deviceModel,
      platform: platform ?? this.platform,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
      lastIp: lastIp ?? this.lastIp,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedBy: revokedBy ?? this.revokedBy,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() =>
      'ActiveDevice($displayName, $platformLabel, active: $isActive)';
}
