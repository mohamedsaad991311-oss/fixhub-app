// lib/core/services/staff_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/models/app_user.dart' show UserRole, UserRoleX;
import '../../features/staff/data/models/staff_member.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  STAFF FILTER
// ═══════════════════════════════════════════════════════════════

class StaffFilter {
  const StaffFilter({
    this.search,
    this.role,
    this.onlyActive = true,
    this.sortBy = StaffSortBy.name,
    this.sortAscending = true,
    this.limit = 100,
    this.offset = 0,
  });

  final String? search;
  final UserRole? role;
  final bool onlyActive;
  final StaffSortBy sortBy;
  final bool sortAscending;
  final int limit;
  final int offset;

  StaffFilter copyWith({
    String? search,
    UserRole? role,
    bool clearRole = false,
    bool? onlyActive,
    StaffSortBy? sortBy,
    bool? sortAscending,
    int? limit,
    int? offset,
  }) {
    return StaffFilter(
      search: search ?? this.search,
      role: clearRole ? null : (role ?? this.role),
      onlyActive: onlyActive ?? this.onlyActive,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

enum StaffSortBy { name, role, hireDate, salary, createdAt }

// ═══════════════════════════════════════════════════════════════
//  STAFF STATS
// ═══════════════════════════════════════════════════════════════

class StaffStats {
  const StaffStats({
    required this.totalStaff,
    required this.activeStaff,
    required this.withAccounts,
    required this.byRole,
    required this.totalSalaries,
  });

  final int totalStaff;
  final int activeStaff;
  final int withAccounts;
  final Map<UserRole, int> byRole;
  final double totalSalaries;

  int countOf(UserRole role) => byRole[role] ?? 0;

  static const StaffStats empty = StaffStats(
    totalStaff: 0,
    activeStaff: 0,
    withAccounts: 0,
    byRole: {},
    totalSalaries: 0,
  );
}

// ═══════════════════════════════════════════════════════════════
//  STAFF SERVICE
// ═══════════════════════════════════════════════════════════════

class StaffService {
  StaffService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'staff';

  // ═════════════════════════════════════════════════════════════
  //  READ
  // ═════════════════════════════════════════════════════════════

  /// قائمة الموظفين
  Future<List<StaffMember>> list([
    StaffFilter filter = const StaffFilter(),
  ]) async {
    try {
      var query = _client.from(_table).select();

      if (filter.onlyActive) {
        query = query.eq('is_active', true);
      }

      if (filter.role != null) {
        query = query.eq('role', filter.role!.name);
      }

      if (filter.search != null && filter.search!.trim().isNotEmpty) {
        final s = filter.search!.trim();
        query = query.or(
          'full_name.ilike.%$s%,'
          'full_name_ar.ilike.%$s%,'
          'email.ilike.%$s%,'
          'phone.ilike.%$s%',
        );
      }

      final column = _sortColumn(filter.sortBy);
      final data = await query
          .order(column, ascending: filter.sortAscending)
          .range(filter.offset, filter.offset + filter.limit - 1);

      return (data as List)
          .map((e) => StaffMember.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.list error: $e');
      }
      return const [];
    }
  }

  Future<StaffMember?> getById(String id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return StaffMember.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.getById error: $e');
      }
      return null;
    }
  }

  Future<StaffMember?> getByUserId(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return StaffMember.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.getByUserId error: $e');
      }
      return null;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  CRUD
  // ═════════════════════════════════════════════════════════════

  Future<StaffMember?> create(StaffMember staff) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return null;

      final payload = staff.toInsertJson()..['tenant_id'] = tenantId;

      final inserted =
          await _client.from(_table).insert(payload).select().single();

      return StaffMember.fromJson(Map<String, dynamic>.from(inserted));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.create error: $e');
      }
      return null;
    }
  }

  Future<StaffMember?> update(StaffMember staff) async {
    try {
      final payload = staff.toJson()
        ..remove('id')
        ..remove('tenant_id')
        ..remove('user_id') // الربط بالـ user ثابت
        ..remove('created_at')
        ..remove('updated_at');

      final updated = await _client
          .from(_table)
          .update(payload)
          .eq('id', staff.id)
          .select()
          .single();

      return StaffMember.fromJson(Map<String, dynamic>.from(updated));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.update error: $e');
      }
      return null;
    }
  }

  Future<bool> delete(String id) async {
    try {
      // حماية: مينفعش نحذف الـ owner
      final staff = await getById(id);
      if (staff == null) return false;
      if (staff.isOwner) {
        if (kDebugMode) {
          debugPrint('StaffService.delete: cannot delete owner');
        }
        return false;
      }

      await _client.from(_table).delete().eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.delete error: $e');
      }
      return false;
    }
  }

  Future<bool> setActive(String id, {required bool isActive}) async {
    try {
      await _client.from(_table).update({'is_active': isActive}).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.setActive error: $e');
      }
      return false;
    }
  }

  /// تغيير الدور
  Future<bool> changeRole(String id, UserRole newRole) async {
    try {
      final staff = await getById(id);
      if (staff == null) return false;

      // حماية: مينفعش نغيّر دور الـ owner
      if (staff.isOwner && newRole != UserRole.owner) {
        if (kDebugMode) {
          debugPrint('StaffService.changeRole: cannot demote owner');
        }
        return false;
      }

      // حدد الصلاحيات تلقائياً حسب الدور
      final permissions = _defaultPermissionsForRole(newRole);

      await _client.from(_table).update({
        'role': newRole.name,
        'permissions': permissions.toJson(),
      }).eq('id', id);

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.changeRole error: $e');
      }
      return false;
    }
  }

  /// تحديث الصلاحيات يدوياً
  Future<bool> updatePermissions(
    String id,
    StaffPermissions permissions,
  ) async {
    try {
      await _client.from(_table).update({
        'permissions': permissions.toJson(),
      }).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.updatePermissions error: $e');
      }
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  STATS
  // ═════════════════════════════════════════════════════════════

  Future<StaffStats> getStats() async {
    try {
      final data =
          await _client.from(_table).select('role, is_active, user_id, salary');

      final rows = (data as List).cast<Map<String, dynamic>>();

      int totalStaff = 0;
      int activeStaff = 0;
      int withAccounts = 0;
      double totalSalaries = 0;
      final byRole = <UserRole, int>{};

      for (final r in rows) {
        totalStaff++;
        final role = UserRoleX.fromString(r['role'] as String?);
        final isActive = r['is_active'] as bool? ?? true;
        final userId = r['user_id'] as String?;
        final salary = _toDouble(r['salary']);

        byRole[role] = (byRole[role] ?? 0) + 1;

        if (isActive) activeStaff++;
        if (userId != null && userId.isNotEmpty) withAccounts++;
        if (isActive && salary > 0) totalSalaries += salary;
      }

      return StaffStats(
        totalStaff: totalStaff,
        activeStaff: activeStaff,
        withAccounts: withAccounts,
        byRole: byRole,
        totalSalaries: totalSalaries,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StaffService.getStats error: $e');
      }
      return StaffStats.empty;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  HELPERS
  // ═════════════════════════════════════════════════════════════

  /// الصلاحيات الافتراضية لكل دور
  StaffPermissions _defaultPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return StaffPermissions.all;
      case UserRole.manager:
        return StaffPermissions.manager;
      case UserRole.technician:
        return StaffPermissions.technician;
      case UserRole.receptionist:
        return StaffPermissions.receptionist;
      case UserRole.accountant:
        return const StaffPermissions(
          canViewReports: true,
          canManageExpenses: true,
        );
    }
  }

  String _sortColumn(StaffSortBy s) {
    switch (s) {
      case StaffSortBy.name:
        return 'full_name';
      case StaffSortBy.role:
        return 'role';
      case StaffSortBy.hireDate:
        return 'hire_date';
      case StaffSortBy.salary:
        return 'salary';
      case StaffSortBy.createdAt:
        return 'created_at';
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final staffServiceProvider = Provider<StaffService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return StaffService(client: client, authService: authService);
});

final staffStreamProvider = StreamProvider.autoDispose
    .family<List<StaffMember>, StaffFilter>((ref, filter) async* {
  final service = ref.watch(staffServiceProvider);

  yield await service.list(filter);

  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    yield await service.list(filter);
  }
});
