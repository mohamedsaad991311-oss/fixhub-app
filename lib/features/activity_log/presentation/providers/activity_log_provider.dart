// lib/features/activity_log/presentation/providers/activity_log_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/activity_log_service.dart';

// ═══════════════════════════════════════════════════════════════
//  حالة سجل النشاط
// ═══════════════════════════════════════════════════════════════

class ActivityLogState {
  const ActivityLogState({
    this.logs = const [],
    this.filter = const ActivityLogFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  final List<ActivityLog> logs;
  final ActivityLogFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isEmpty => logs.isEmpty && !isLoading;

  /// هل فيه فلاتر مطبقة؟
  bool get hasActiveFilters =>
      filter.action != null ||
      filter.entityType != null ||
      filter.userId != null ||
      filter.fromDate != null ||
      filter.toDate != null ||
      (filter.search != null && filter.search!.isNotEmpty);

  ActivityLogState copyWith({
    List<ActivityLog>? logs,
    ActivityLogFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActivityLogState(
      logs: logs ?? this.logs,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّد سجل النشاط
// ═══════════════════════════════════════════════════════════════

class ActivityLogNotifier extends StateNotifier<ActivityLogState> {
  ActivityLogNotifier(this._service) : super(const ActivityLogState()) {
    load();
  }

  final ActivityLogService _service;

  static const int _pageSize = 50;

  // ─────────────────────────────────────────────────────────────
  //  تحميل
  // ─────────────────────────────────────────────────────────────

  /// تحميل الصفحة الأولى
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final logs = await _service.list(
        state.filter.copyWith(limit: _pageSize, offset: 0),
      );

      state = state.copyWith(
        logs: logs,
        isLoading: false,
        hasMore: logs.length == _pageSize,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ActivityLogNotifier.load error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل السجل',
      );
    }
  }

  /// تحديث
  Future<void> refresh() => load();

  /// تحميل المزيد (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final logs = await _service.list(
        state.filter.copyWith(
          limit: _pageSize,
          offset: state.logs.length,
        ),
      );

      state = state.copyWith(
        logs: [...state.logs, ...logs],
        isLoadingMore: false,
        hasMore: logs.length == _pageSize,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ActivityLogNotifier.loadMore error: $e');
      }
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'فشل تحميل المزيد',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  فلترة
  // ─────────────────────────────────────────────────────────────

  /// تعيين الفلتر
  Future<void> setFilter(ActivityLogFilter filter) async {
    state = state.copyWith(filter: filter);
    await load();
  }

  /// تعيين فلتر الإجراء
  Future<void> setAction(String? action) async {
    final newFilter = action == null
        ? state.filter.copyWith(clearAction: true)
        : state.filter.copyWith(action: action);
    await setFilter(newFilter);
  }

  /// تعيين فلتر نوع الكيان
  Future<void> setEntityType(String? entityType) async {
    final newFilter = entityType == null
        ? state.filter.copyWith(clearEntityType: true)
        : state.filter.copyWith(entityType: entityType);
    await setFilter(newFilter);
  }

  /// تعيين فلتر الفترة
  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    await setFilter(
      state.filter.copyWith(fromDate: from, toDate: to),
    );
  }

  /// تعيين البحث
  Future<void> setSearch(String? query) async {
    final newFilter = (query == null || query.trim().isEmpty)
        ? state.filter.copyWith(search: '')
        : state.filter.copyWith(search: query.trim());
    await setFilter(newFilter);
  }

  /// مسح كل الفلاتر
  Future<void> clearFilters() async {
    await setFilter(const ActivityLogFilter());
  }

  // ─────────────────────────────────────────────────────────────
  //  رسائل
  // ─────────────────────────────────────────────────────────────

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّدات Riverpod
// ═══════════════════════════════════════════════════════════════

final activityLogProvider =
    StateNotifierProvider<ActivityLogNotifier, ActivityLogState>((ref) {
  final service = ref.watch(activityLogServiceProvider);
  return ActivityLogNotifier(service);
});

/// قائمة السجلات
final activityLogsListProvider = Provider<List<ActivityLog>>((ref) {
  return ref.watch(activityLogProvider).logs;
});

/// هل التحميل جاري؟
final activityLogLoadingProvider = Provider<bool>((ref) {
  return ref.watch(activityLogProvider).isLoading;
});

/// هل فيه فلاتر مطبقة؟
final activityLogHasFiltersProvider = Provider<bool>((ref) {
  return ref.watch(activityLogProvider).hasActiveFilters;
});
