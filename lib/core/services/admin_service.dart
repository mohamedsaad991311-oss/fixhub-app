// lib/core/services/admin_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/models/app_user.dart';
import '../../features/auth/data/models/tenant.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  نموذج طلب إعادة تعيين الجهاز
// ═══════════════════════════════════════════════════════════════

class DeviceResetRequest {
  const DeviceResetRequest({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.status,
    required this.requestedAt,
    this.currentDeviceId,
    this.requestedDeviceName,
    this.requestedPlatform,
    this.reason,
    this.reviewedAt,
    this.reviewedBy,
    this.adminNotes,
  });

  final String id;
  final String tenantId;
  final String userId;
  final String status; // pending / approved / rejected
  final DateTime requestedAt;
  final String? currentDeviceId;
  final String? requestedDeviceName;
  final String? requestedPlatform;
  final String? reason;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? adminNotes;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// الحالة بالعربي
  String get statusLabelAr {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  factory DeviceResetRequest.fromJson(Map<String, dynamic> json) {
    return DeviceResetRequest(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      requestedAt: _parseDate(json['requested_at']) ?? DateTime.now(),
      currentDeviceId: json['current_device_id'] as String?,
      requestedDeviceName: json['requested_device_name'] as String?,
      requestedPlatform: json['requested_platform'] as String?,
      reason: json['reason'] as String?,
      reviewedAt: _parseDate(json['reviewed_at']),
      reviewedBy: json['reviewed_by'] as String?,
      adminNotes: json['admin_notes'] as String?,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
//  إحصائيات النظام العامة
// ═══════════════════════════════════════════════════════════════

class SystemStats {
  const SystemStats({
    this.totalTenants = 0,
    this.activeTenants = 0,
    this.totalStaff = 0,
    this.totalReceipts = 0,
    this.pendingDeviceResets = 0,
  });

  final int totalTenants;
  final int activeTenants;
  final int totalStaff;
  final int totalReceipts;
  final int pendingDeviceResets;

  static const SystemStats empty = SystemStats();
}

// ═══════════════════════════════════════════════════════════════
//  خدمة الأدمن
// ═══════════════════════════════════════════════════════════════

class AdminService {
  AdminService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  // ─────────────────────────────────────────────────────────────
  //  إدارة الورش (Tenants)
  // ─────────────────────────────────────────────────────────────

  /// جلب كل الورش
  Future<List<Tenant>> listTenants() async {
    try {
      final data = await _client
          .from('tenants')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Tenant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.listTenants error: $e');
      }
      return const [];
    }
  }

  /// تفعيل/تعطيل ورشة
  Future<bool> setTenantActive(String tenantId, bool active) async {
    try {
      await _client
          .from('tenants')
          .update({'is_active': active}).eq('id', tenantId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.setTenantActive error: $e');
      }
      return false;
    }
  }

  /// تحديث خطة الاشتراك
  Future<bool> setSubscription({
    required String tenantId,
    required String plan,
    required DateTime expiresAt,
  }) async {
    try {
      await _client.from('tenants').update({
        'subscription_plan': plan,
        'subscription_expires_at': expiresAt.toIso8601String(),
      }).eq('id', tenantId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.setSubscription error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  إدارة الموظفين
  // ─────────────────────────────────────────────────────────────

  /// جلب كل الموظفين (كل الورش)
  Future<List<AppUser>> listAllStaff() async {
    try {
      final data = await _client
          .from('staff')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.listAllStaff error: $e');
      }
      return const [];
    }
  }

  /// جلب موظفي ورشة معينة
  Future<List<AppUser>> listTenantStaff(String tenantId) async {
    try {
      final data = await _client
          .from('staff')
          .select()
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.listTenantStaff error: $e');
      }
      return const [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  طلبات إعادة تعيين الجهاز
  // ─────────────────────────────────────────────────────────────

  /// جلب طلبات إعادة التعيين (مع فلترة اختيارية)
  Future<List<DeviceResetRequest>> listDeviceResetRequests({
    String? status,
    int limit = 100,
  }) async {
    try {
      var query = _client.from('device_reset_requests').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final data =
          await query.order('requested_at', ascending: false).limit(limit);

      return (data as List)
          .map((e) => DeviceResetRequest.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.listDeviceResetRequests error: $e');
      }
      return const [];
    }
  }

  /// عدد الطلبات المعلقة
  Future<int> countPendingDeviceResets() async {
    try {
      final data = await _client
          .from('device_reset_requests')
          .select('id')
          .eq('status', 'pending');

      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// الموافقة على طلب إعادة تعيين
  ///
  /// 1) تحديث الطلب → approved
  /// 2) حذف الأجهزة القديمة للمستخدم
  Future<bool> approveDeviceReset(
    String requestId, {
    String? adminNotes,
  }) async {
    try {
      // 1) اجلب الطلب
      final data = await _client
          .from('device_reset_requests')
          .select()
          .eq('id', requestId)
          .maybeSingle();

      if (data == null) return false;

      final request = DeviceResetRequest.fromJson(
        Map<String, dynamic>.from(data),
      );

      // 2) حدّث الحالة
      await _client.from('device_reset_requests').update({
        'status': 'approved',
        'admin_notes': adminNotes,
      }).eq('id', requestId);

      // 3) احذف الأجهزة القديمة للمستخدم
      await _client
          .from('active_devices')
          .delete()
          .eq('user_id', request.userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.approveDeviceReset error: $e');
      }
      return false;
    }
  }

  /// رفض طلب إعادة تعيين
  Future<bool> rejectDeviceReset(
    String requestId, {
    String? adminNotes,
  }) async {
    try {
      await _client.from('device_reset_requests').update({
        'status': 'rejected',
        'admin_notes': adminNotes,
      }).eq('id', requestId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.rejectDeviceReset error: $e');
      }
      return false;
    }
  }

  /// إنشاء طلب إعادة تعيين (من المستخدم)
  Future<bool> createDeviceResetRequest({
    required String tenantId,
    required String currentDeviceId,
    String? requestedDeviceName,
    String? requestedPlatform,
    String? reason,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return false;

      // تحقق إن مفيش طلب معلق
      final existing = await _client
          .from('device_reset_requests')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (existing != null) return false;

      await _client.from('device_reset_requests').insert({
        'tenant_id': tenantId,
        'user_id': userId,
        'current_device_id': currentDeviceId,
        'requested_device_name': requestedDeviceName,
        'requested_platform': requestedPlatform,
        'reason': reason,
        'status': 'pending',
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.createDeviceResetRequest error: $e');
      }
      return false;
    }
  }

  /// جلب طلب المستخدم الحالي (لو موجود)
  Future<DeviceResetRequest?> getMyPendingRequest() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return null;

      final data = await _client
          .from('device_reset_requests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (data == null) return null;
      return DeviceResetRequest.fromJson(
        Map<String, dynamic>.from(data),
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  إحصائيات النظام
  // ─────────────────────────────────────────────────────────────

  Future<SystemStats> getSystemStats() async {
    try {
      final tenants = await _client.from('tenants').select('is_active');
      final tenantRows = (tenants as List);

      final totalTenants = tenantRows.length;
      final activeTenants =
          tenantRows.where((t) => t['is_active'] == true).length;

      final staff = await _client.from('staff').select('id');
      final receipts = await _client.from('receipts').select('id');
      final pendingResets = await countPendingDeviceResets();

      return SystemStats(
        totalTenants: totalTenants,
        activeTenants: activeTenants,
        totalStaff: (staff as List).length,
        totalReceipts: (receipts as List).length,
        pendingDeviceResets: pendingResets,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AdminService.getSystemStats error: $e');
      }
      return SystemStats.empty;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّد Riverpod
// ═══════════════════════════════════════════════════════════════

final adminServiceProvider = Provider<AdminService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return AdminService(
    client: client,
    authService: authService,
  );
});
