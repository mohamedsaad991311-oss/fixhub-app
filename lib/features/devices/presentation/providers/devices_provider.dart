// lib/features/devices/presentation/providers/devices_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/device_info_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/services/session_manager.dart';
import '../../data/models/active_device.dart';

/// ═══════════════════════════════════════════════════════════════
/// حالة الأجهزة
/// ═══════════════════════════════════════════════════════════════

class DevicesState {
  const DevicesState({
    this.devices = const [],
    this.currentDeviceId,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<ActiveDevice> devices;
  final String? currentDeviceId;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;
  bool get isEmpty => devices.isEmpty && !isLoading;

  /// عدد الأجهزة النشطة
  int get activeCount => devices.where((d) => d.isActive).length;

  /// الأجهزة النشطة فقط
  List<ActiveDevice> get activeDevices =>
      devices.where((d) => d.isActive).toList();

  /// الجهاز الحالي
  ActiveDevice? get currentDevice {
    if (currentDeviceId == null) return null;
    try {
      return devices.firstWhere((d) => d.isCurrentDevice(currentDeviceId!));
    } catch (_) {
      return null;
    }
  }

  DevicesState copyWith({
    List<ActiveDevice>? devices,
    String? currentDeviceId,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return DevicesState(
      devices: devices ?? this.devices,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// مزوّد الأجهزة
/// ═══════════════════════════════════════════════════════════════

class DevicesNotifier extends StateNotifier<DevicesState> {
  DevicesNotifier(this._ref) : super(const DevicesState()) {
    load();
  }

  final Ref _ref;

  SessionManager get _session => _ref.read(sessionManagerProvider);
  DeviceInfoService get _deviceService => _ref.read(deviceInfoServiceProvider);

  // ─────────────────────────────────────────────────────────────
  //  تحميل
  // ─────────────────────────────────────────────────────────────

  /// تحميل قائمة الأجهزة
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 1) الجهاز الحالي
      final currentId = await _deviceService.getDeviceId();

      // 2) بيانات المستخدم
      final authState = _ref.read(authProvider).valueOrNull;
      final user = authState?.user;
      final tenant = authState?.tenant;

      if (user == null || tenant == null) {
        state = state.copyWith(
          isLoading: false,
          currentDeviceId: currentId,
          errorMessage: 'لا يمكن تحديد المستخدم أو الورشة',
        );
        return;
      }

      // 3) تحديد النطاق:
      // - لو tenant admin (owner/manager) → كل أجهزة الورشة
      // - غير كده → أجهزة المستخدم فقط
      final isTenantAdmin = user.isTenantAdmin || user.isAdmin;

      final List<ActiveDevice> devices;

      if (isTenantAdmin) {
        final raw = await _session.getTenantDevices(tenant.id);
        devices = raw.map((e) => ActiveDevice.fromJson(e)).toList();
      } else {
        final raw = await _session.getTenantDevices(tenant.id);
        devices = raw
            .map((e) => ActiveDevice.fromJson(e))
            .where((d) => d.userId == user.userId)
            .toList();
      }

      // ترتيب: الأحدث أولاً
      devices.sort((a, b) {
        final aTime = a.lastSeenAt ?? a.createdAt ?? DateTime(1970);
        final bTime = b.lastSeenAt ?? b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      state = state.copyWith(
        devices: devices,
        currentDeviceId: currentId,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DevicesNotifier.load error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الأجهزة',
      );
    }
  }

  /// تحديث
  Future<void> refresh() => load();

  // ─────────────────────────────────────────────────────────────
  //  إلغاء تفعيل جهاز (للأدمن فقط)
  // ─────────────────────────────────────────────────────────────

  /// إلغاء تفعيل جهاز معيّن
  Future<bool> revokeDevice(String deviceRowId) async {
    if (state.isProcessing) return false;

    // لا يمكن إلغاء تفعيل الجهاز الحالي
    final device = state.devices.firstWhere(
      (d) => d.id == deviceRowId,
      orElse: () => throw StateError('الجهاز غير موجود'),
    );

    if (device.isCurrentDevice(state.currentDeviceId ?? '')) {
      state = state.copyWith(
        errorMessage: 'لا يمكن إلغاء تفعيل الجهاز الحالي',
      );
      return false;
    }

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final user = _ref.read(authProvider).valueOrNull?.user;
      if (user == null) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'لا يمكن تحديد المستخدم',
        );
        return false;
      }

      final ok = await _session.revokeDevice(
        deviceRowId: deviceRowId,
        byUserId: user.userId,
      );

      if (!ok) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'فشل إلغاء تفعيل الجهاز',
        );
        return false;
      }

      // تحديث محلي — الجهاز اتصفّح
      final updated = state.devices
          .map((d) => d.id == deviceRowId
              ? d.copyWith(
                  isActive: false,
                  revokedAt: DateTime.now(),
                  revokedBy: user.userId,
                )
              : d)
          .toList();

      state = state.copyWith(
        devices: updated,
        isProcessing: false,
        successMessage: 'تم إلغاء تفعيل الجهاز',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DevicesNotifier.revokeDevice error: $e');
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء إلغاء التفعيل',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  رسائل
  // ─────────────────────────────────────────────────────────────

  /// مسح رسائل النجاح/الخطأ
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّدات Riverpod
// ═══════════════════════════════════════════════════════════════

final devicesProvider =
    StateNotifierProvider<DevicesNotifier, DevicesState>((ref) {
  return DevicesNotifier(ref);
});

/// قائمة الأجهزة
final devicesListProvider = Provider<List<ActiveDevice>>((ref) {
  return ref.watch(devicesProvider).devices;
});

/// عدد الأجهزة النشطة
final activeDevicesCountProvider = Provider<int>((ref) {
  return ref.watch(devicesProvider).activeCount;
});

/// الجهاز الحالي
final currentActiveDeviceProvider = Provider<ActiveDevice?>((ref) {
  return ref.watch(devicesProvider).currentDevice;
});
