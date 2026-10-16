// lib/core/services/activity_log_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  ثوابت الإجراءات
// ═══════════════════════════════════════════════════════════════

class ActivityAction {
  ActivityAction._();

  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String statusChange = 'status_change';
  static const String payment = 'payment';
  static const String print = 'print';
  static const String export = 'export';
  static const String restore = 'restore';
  static const String invite = 'invite';
  static const String view = 'view';

  static const List<String> all = [
    create,
    update,
    delete,
    login,
    logout,
    statusChange,
    payment,
    print,
    export,
    restore,
    invite,
    view,
  ];

  /// ترجمة الإجراء للعربي
  static String labelAr(String action) {
    switch (action) {
      case create:
        return 'إنشاء';
      case update:
        return 'تعديل';
      case delete:
        return 'حذف';
      case login:
        return 'تسجيل دخول';
      case logout:
        return 'تسجيل خروج';
      case statusChange:
        return 'تغيير حالة';
      case payment:
        return 'دفعة';
      case print:
        return 'طباعة';
      case export:
        return 'تصدير';
      case restore:
        return 'استرجاع';
      case invite:
        return 'دعوة';
      case view:
        return 'عرض';
      default:
        return action;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  ثوابت الكيانات
// ═══════════════════════════════════════════════════════════════

class EntityType {
  EntityType._();

  static const String receipt = 'receipt';
  static const String inventory = 'inventory';
  static const String expense = 'expense';
  static const String supplier = 'supplier';
  static const String staff = 'staff';
  static const String settings = 'settings';
  static const String payment = 'payment';
  static const String invoice = 'invoice';
  static const String user = 'user';
  static const String device = 'device';

  static const List<String> all = [
    receipt,
    inventory,
    expense,
    supplier,
    staff,
    settings,
    payment,
    invoice,
    user,
    device,
  ];

  /// ترجمة نوع الكيان للعربي
  static String labelAr(String entity) {
    switch (entity) {
      case receipt:
        return 'إيصال';
      case inventory:
        return 'قطعة مخزون';
      case expense:
        return 'مصروف';
      case supplier:
        return 'مورد';
      case staff:
        return 'موظف';
      case settings:
        return 'إعدادات';
      case payment:
        return 'دفعة';
      case invoice:
        return 'فاتورة';
      case user:
        return 'مستخدم';
      case device:
        return 'جهاز';
      default:
        return entity;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  نموذج سجل النشاط
// ═══════════════════════════════════════════════════════════════

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.tenantId,
    required this.action,
    this.userId,
    this.entityType,
    this.entityId,
    this.description,
    this.metadata = const {},
    this.ipAddress,
    this.userAgent,
    this.createdAt,
  });

  final String id;
  final String tenantId;
  final String action;
  final String? userId;
  final String? entityType;
  final String? entityId;
  final String? description;
  final Map<String, dynamic> metadata;
  final String? ipAddress;
  final String? userAgent;
  final DateTime? createdAt;

  /// وصف الإجراء بالعربي
  String get actionLabelAr => ActivityAction.labelAr(action);

  /// وصف الكيان بالعربي
  String get entityLabelAr {
    if (entityType == null || entityType!.isEmpty) return '';
    return EntityType.labelAr(entityType!);
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> meta = {};
    final rawMeta = json['metadata'];
    if (rawMeta is Map) {
      meta = Map<String, dynamic>.from(rawMeta);
    }

    return ActivityLog(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      action: json['action'] as String? ?? 'unknown',
      userId: json['user_id'] as String?,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as String?,
      description: json['description'] as String?,
      metadata: meta,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'tenant_id': tenantId,
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'description': description,
        'metadata': metadata,
        'ip_address': ipAddress,
        'user_agent': userAgent,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
//  فلتر سجل النشاط
// ═══════════════════════════════════════════════════════════════

class ActivityLogFilter {
  const ActivityLogFilter({
    this.action,
    this.entityType,
    this.entityId,
    this.userId,
    this.fromDate,
    this.toDate,
    this.search,
    this.limit = 100,
    this.offset = 0,
  });

  final String? action;
  final String? entityType;
  final String? entityId;
  final String? userId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? search;
  final int limit;
  final int offset;

  ActivityLogFilter copyWith({
    String? action,
    bool clearAction = false,
    String? entityType,
    bool clearEntityType = false,
    String? entityId,
    String? userId,
    bool clearUserId = false,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    int? limit,
    int? offset,
  }) {
    return ActivityLogFilter(
      action: clearAction ? null : (action ?? this.action),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      entityId: entityId ?? this.entityId,
      userId: clearUserId ? null : (userId ?? this.userId),
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      search: search ?? this.search,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  خدمة سجل النشاط
// ═══════════════════════════════════════════════════════════════

class ActivityLogService {
  ActivityLogService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'activity_log';

  // ─────────────────────────────────────────────────────────────
  //  قراءة
  // ─────────────────────────────────────────────────────────────

  /// جلب سجل النشاط مع فلترة
  Future<List<ActivityLog>> list([
    ActivityLogFilter filter = const ActivityLogFilter(),
  ]) async {
    try {
      var query = _client.from(_table).select();

      if (filter.action != null) {
        query = query.eq('action', filter.action!);
      }
      if (filter.entityType != null) {
        query = query.eq('entity_type', filter.entityType!);
      }
      if (filter.entityId != null) {
        query = query.eq('entity_id', filter.entityId!);
      }
      if (filter.userId != null) {
        query = query.eq('user_id', filter.userId!);
      }
      if (filter.fromDate != null) {
        query = query.gte(
          'created_at',
          filter.fromDate!.toIso8601String(),
        );
      }
      if (filter.toDate != null) {
        query = query.lte(
          'created_at',
          filter.toDate!.toIso8601String(),
        );
      }
      if (filter.search != null && filter.search!.trim().isNotEmpty) {
        query = query.ilike('description', '%${filter.search!.trim()}%');
      }

      final data = await query.order('created_at', ascending: false).range(
            filter.offset,
            filter.offset + filter.limit - 1,
          );

      return (data as List)
          .map((e) => ActivityLog.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ActivityLogService.list error: $e');
      }
      return const [];
    }
  }

  /// جلب سجل نشاط كيان معين
  Future<List<ActivityLog>> getByEntity(
    String entityType,
    String entityId, {
    int limit = 50,
  }) {
    return list(
      ActivityLogFilter(
        entityType: entityType,
        entityId: entityId,
        limit: limit,
      ),
    );
  }

  /// جلب سجل نشاط موظف معين
  Future<List<ActivityLog>> getUserActivity(
    String userId, {
    int limit = 50,
  }) {
    return list(ActivityLogFilter(userId: userId, limit: limit));
  }

  // ─────────────────────────────────────────────────────────────
  //  إحصائيات
  // ─────────────────────────────────────────────────────────────

  /// عدد الأنشطة في فترة
  Future<int> countInRange({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _client.from(_table).select('id');

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final data = await query;
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  تسجيل نشاط جديد
  // ─────────────────────────────────────────────────────────────

  /// تسجيل نشاط جديد (يُستدعى تلقائياً من العمليات)
  Future<bool> log({
    required String action,
    String? entityType,
    String? entityId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return false;

      final userId = _authService.currentUser?.id;

      await _client.from(_table).insert({
        'tenant_id': tenantId,
        'user_id': userId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'description': description,
        'metadata': metadata ?? {},
        'user_agent': _detectUserAgent(),
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ActivityLogService.log error: $e');
      }
      return false;
    }
  }

  /// حذف أنشطة قديمة (للتنظيف — الأنشطة الأقدم من سنة)
  Future<int> deleteOlderThan(DateTime cutoff) async {
    try {
      final data = await _client
          .from(_table)
          .delete()
          .lt('created_at', cutoff.toIso8601String())
          .select('id');

      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  مساعدات داخلية
  // ─────────────────────────────────────────────────────────────

  /// كشف المنصة (لحقل user_agent)
  String _detectUserAgent() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isLinux) return 'linux';
    } catch (_) {}
    return 'unknown';
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّد Riverpod
// ═══════════════════════════════════════════════════════════════

final activityLogServiceProvider = Provider<ActivityLogService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return ActivityLogService(
    client: client,
    authService: authService,
  );
});
