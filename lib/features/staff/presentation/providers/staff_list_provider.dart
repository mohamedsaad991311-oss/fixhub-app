// lib/features/staff/presentation/providers/staff_list_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/staff_service.dart';
import '../../../auth/data/models/app_user.dart' show UserRole;
import '../../data/models/staff_member.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffListState — حالة قائمة الموظفين
/// ═══════════════════════════════════════════════════════════
class StaffListState {
  final StaffFilter filter;
  final List<StaffMember> staff;
  final StaffStats stats;
  final bool isLoading;
  final String? errorMessage;

  const StaffListState({
    this.filter = const StaffFilter(),
    this.staff = const [],
    this.stats = StaffStats.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && staff.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  StaffListState copyWith({
    StaffFilter? filter,
    List<StaffMember>? staff,
    StaffStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaffListState(
      filter: filter ?? this.filter,
      staff: staff ?? this.staff,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// StaffListNotifier
/// ═══════════════════════════════════════════════════════════
class StaffListNotifier extends StateNotifier<StaffListState> {
  StaffListNotifier(this._ref) : super(const StaffListState()) {
    load();
  }

  final Ref _ref;

  StaffService get _service => _ref.read(staffServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getStats(),
      ]);

      state = state.copyWith(
        staff: results[0] as List<StaffMember>,
        stats: results[1] as StaffStats,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('StaffListNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الموظفين',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getStats(),
      ]);

      state = state.copyWith(
        staff: results[0] as List<StaffMember>,
        stats: results[1] as StaffStats,
        clearError: true,
      );
    } catch (e) {
      debugPrint('StaffListNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  Future<void> setFilter(StaffFilter filter) async {
    state = state.copyWith(filter: filter, isLoading: true);
    await load();
  }

  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    final newFilter = (trimmed == null || trimmed.isEmpty)
        ? state.filter.copyWith(search: '')
        : state.filter.copyWith(search: trimmed);
    await setFilter(newFilter);
  }

  Future<void> filterByRole(UserRole? role) async {
    final newFilter = role == null
        ? state.filter.copyWith(clearRole: true)
        : state.filter.copyWith(role: role);
    await setFilter(newFilter);
  }

  Future<void> toggleOnlyActive() async {
    await setFilter(
      state.filter.copyWith(onlyActive: !state.filter.onlyActive),
    );
  }

  Future<void> clearFilters() async {
    await setFilter(const StaffFilter());
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        state = state.copyWith(
          staff: state.staff.where((s) => s.id != id).toList(),
        );
        final stats = await _service.getStats();
        state = state.copyWith(stats: stats);
      }
      return ok;
    } catch (e) {
      debugPrint('StaffListNotifier.delete error: $e');
      return false;
    }
  }

  Future<bool> setActive(String id, {required bool isActive}) async {
    try {
      final ok = await _service.setActive(id, isActive: isActive);
      if (ok) await refresh();
      return ok;
    } catch (e) {
      debugPrint('StaffListNotifier.setActive error: $e');
      return false;
    }
  }

  /// تغيير الدور
  Future<bool> changeRole(String id, UserRole newRole) async {
    try {
      final ok = await _service.changeRole(id, newRole);
      if (ok) await refresh();
      return ok;
    } catch (e) {
      debugPrint('StaffListNotifier.changeRole error: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final staffListProvider =
    StateNotifierProvider<StaffListNotifier, StaffListState>((ref) {
  return StaffListNotifier(ref);
});

/// اختصار: القائمة
final staffListDataProvider = Provider<List<StaffMember>>((ref) {
  return ref.watch(staffListProvider).staff;
});

/// اختصار: الإحصائيات
final staffStatsProvider = Provider<StaffStats>((ref) {
  return ref.watch(staffListProvider).stats;
});

/// اختصار: هل التحميل جاري؟
final staffListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(staffListProvider).isLoading;
});

/// اختصار: هل القائمة فاضية؟
final staffListEmptyProvider = Provider<bool>((ref) {
  return ref.watch(staffListProvider).isEmpty;
});

/// اختصار: الفلتر الحالي
final staffListFilterProvider = Provider<StaffFilter>((ref) {
  return ref.watch(staffListProvider).filter;
});

/// الموظفين اللي عندهم حساب
final staffWithAccountsProvider = Provider<List<StaffMember>>((ref) {
  return ref.watch(staffListDataProvider).where((s) => s.hasAccount).toList();
});

/// الموظفين حسب الدور
final staffByRoleProvider = Provider.family<List<StaffMember>, UserRole>(
  (ref, role) {
    return ref
        .watch(staffListDataProvider)
        .where((s) => s.role == role)
        .toList();
  },
);
