// lib/features/admin/presentation/providers/admin_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/admin_service.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/data/models/tenant.dart';

// ═══════════════════════════════════════════════════════════════
//  حالة الأدمن
// ═══════════════════════════════════════════════════════════════

class AdminState {
  const AdminState({
    this.tenants = const [],
    this.allStaff = const [],
    this.requests = const [],
    this.stats = SystemStats.empty,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<Tenant> tenants;
  final List<AppUser> allStaff;
  final List<DeviceResetRequest> requests;
  final SystemStats stats;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;

  /// الطلبات المعلقة
  List<DeviceResetRequest> get pendingRequests =>
      requests.where((r) => r.isPending).toList();

  /// عدد الطلبات المعلقة
  int get pendingCount => pendingRequests.length;

  AdminState copyWith({
    List<Tenant>? tenants,
    List<AppUser>? allStaff,
    List<DeviceResetRequest>? requests,
    SystemStats? stats,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return AdminState(
      tenants: tenants ?? this.tenants,
      allStaff: allStaff ?? this.allStaff,
      requests: requests ?? this.requests,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّد الأدمن
// ═══════════════════════════════════════════════════════════════

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier(this._service) : super(const AdminState());

  final AdminService _service;

  // ─────────────────────────────────────────────────────────────
  //  تحميل
  // ─────────────────────────────────────────────────────────────

  /// تحميل كل بيانات الأدمن
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tenants = await _service.listTenants();
      final allStaff = await _service.listAllStaff();
      final requests = await _service.listDeviceResetRequests();
      final stats = await _service.getSystemStats();

      state = state.copyWith(
        tenants: tenants,
        allStaff: allStaff,
        requests: requests,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminNotifier.loadAll error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل البيانات',
      );
    }
  }

  /// تحديث
  Future<void> refresh() => loadAll();

  // ─────────────────────────────────────────────────────────────
  //  إدارة الورش
  // ─────────────────────────────────────────────────────────────

  /// تفعيل/تعطيل ورشة
  Future<bool> toggleTenantActive(String tenantId, bool active) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    final success = await _service.setTenantActive(tenantId, active);

    if (!success) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'فشل تحديث حالة الورشة',
      );
      return false;
    }

    // تحديث القائمة محلياً
    final updated = state.tenants.map((t) {
      if (t.id == tenantId) {
        return t.copyWith(isActive: active);
      }
      return t;
    }).toList();

    state = state.copyWith(
      tenants: updated,
      isProcessing: false,
      successMessage: active ? 'تم تفعيل الورشة' : 'تم تعطيل الورشة',
    );
    return true;
  }

  /// تحديث خطة الاشتراك
  Future<bool> setSubscription({
    required String tenantId,
    required String plan,
    required DateTime expiresAt,
  }) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    final success = await _service.setSubscription(
      tenantId: tenantId,
      plan: plan,
      expiresAt: expiresAt,
    );

    if (!success) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'فشل تحديث الاشتراك',
      );
      return false;
    }

    state = state.copyWith(
      isProcessing: false,
      successMessage: 'تم تحديث الاشتراك',
    );

    // إعادة تحميل البيانات
    await loadAll();
    return true;
  }

  // ─────────────────────────────────────────────────────────────
  //  طلبات إعادة التعيين
  // ─────────────────────────────────────────────────────────────

  /// الموافقة على طلب
  Future<bool> approveReset(String requestId, {String? notes}) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    final success = await _service.approveDeviceReset(
      requestId,
      adminNotes: notes,
    );

    if (!success) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'فشل الموافقة على الطلب',
      );
      return false;
    }

    // إزالة من القائمة أو تحديثها
    final updated = state.requests.map((r) {
      if (r.id == requestId) {
        return DeviceResetRequest(
          id: r.id,
          tenantId: r.tenantId,
          userId: r.userId,
          status: 'approved',
          requestedAt: r.requestedAt,
          currentDeviceId: r.currentDeviceId,
          requestedDeviceName: r.requestedDeviceName,
          requestedPlatform: r.requestedPlatform,
          reason: r.reason,
          reviewedAt: DateTime.now(),
          reviewedBy: r.reviewedBy,
          adminNotes: notes,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(
      requests: updated,
      isProcessing: false,
      successMessage: 'تمت الموافقة على الطلب',
    );

    // تحديث الإحصائيات
    final newStats = await _service.getSystemStats();
    state = state.copyWith(stats: newStats);
    return true;
  }

  /// رفض طلب
  Future<bool> rejectReset(String requestId, {String? notes}) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    final success = await _service.rejectDeviceReset(
      requestId,
      adminNotes: notes,
    );

    if (!success) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'فشل رفض الطلب',
      );
      return false;
    }

    final updated = state.requests.map((r) {
      if (r.id == requestId) {
        return DeviceResetRequest(
          id: r.id,
          tenantId: r.tenantId,
          userId: r.userId,
          status: 'rejected',
          requestedAt: r.requestedAt,
          currentDeviceId: r.currentDeviceId,
          requestedDeviceName: r.requestedDeviceName,
          requestedPlatform: r.requestedPlatform,
          reason: r.reason,
          reviewedAt: DateTime.now(),
          reviewedBy: r.reviewedBy,
          adminNotes: notes,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(
      requests: updated,
      isProcessing: false,
      successMessage: 'تم رفض الطلب',
    );

    final newStats = await _service.getSystemStats();
    state = state.copyWith(stats: newStats);
    return true;
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

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final service = ref.watch(adminServiceProvider);
  return AdminNotifier(service);
});

/// إحصائيات النظام
final adminStatsProvider = Provider<SystemStats>((ref) {
  return ref.watch(adminProvider).stats;
});

/// عدد الطلبات المعلقة (للـ badge)
final pendingResetCountProvider = Provider<int>((ref) {
  return ref.watch(adminProvider).pendingCount;
});

/// قائمة الطلبات المعلقة
final pendingResetRequestsProvider = Provider<List<DeviceResetRequest>>((ref) {
  return ref.watch(adminProvider).pendingRequests;
});

/// قائمة كل الورش
final allTenantsProvider = Provider<List<Tenant>>((ref) {
  return ref.watch(adminProvider).tenants;
});
