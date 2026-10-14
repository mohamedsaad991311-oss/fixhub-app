// lib/features/receipts/presentation/providers/receipts_list_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/receipt_service.dart';
import '../../data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptsListState — حالة قائمة الإيصالات
/// ═══════════════════════════════════════════════════════════
class ReceiptsListState {
  final ReceiptFilter filter;
  final List<Receipt> receipts;
  final bool isLoading;
  final String? errorMessage;
  final int totalCount;

  const ReceiptsListState({
    this.filter = const ReceiptFilter(),
    this.receipts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.totalCount = 0,
  });

  bool get isEmpty => !isLoading && receipts.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  ReceiptsListState copyWith({
    ReceiptFilter? filter,
    List<Receipt>? receipts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? totalCount,
  }) {
    return ReceiptsListState(
      filter: filter ?? this.filter,
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReceiptsListNotifier — إدارة قائمة الإيصالات
/// ═══════════════════════════════════════════════════════════
class ReceiptsListNotifier extends StateNotifier<ReceiptsListState> {
  ReceiptsListNotifier(this._ref) : super(const ReceiptsListState()) {
    load();
  }

  final Ref _ref;

  ReceiptService get _service => _ref.read(receiptServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  /// تحميل القائمة (مع الفلتر الحالي)
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _service.list(state.filter);
      state = state.copyWith(
        receipts: list,
        totalCount: list.length,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReceiptsListNotifier.load error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الإيصالات',
      );
    }
  }

  /// تحديث القائمة (من غير loading)
  Future<void> refresh() async {
    try {
      final list = await _service.list(state.filter);
      state = state.copyWith(
        receipts: list,
        totalCount: list.length,
        clearError: true,
      );
    } catch (e) {
      debugPrint('ReceiptsListNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  /// تحديث الفلتر + إعادة التحميل
  Future<void> setFilter(ReceiptFilter filter) async {
    state = state.copyWith(filter: filter, isLoading: true);
    await load();
  }

  /// فلتر بالحالة
  Future<void> filterByStatus(ReceiptStatus? status) async {
    final newFilter = status == null
        ? state.filter.copyWith(clearStatus: true)
        : state.filter.copyWith(status: status);
    await setFilter(newFilter);
  }

  /// فلتر بالأولوية
  Future<void> filterByPriority(ReceiptPriority? priority) async {
    final newFilter = priority == null
        ? state.filter.copyWith(clearPriority: true)
        : state.filter.copyWith(priority: priority);
    await setFilter(newFilter);
  }

  /// بحث في العملاء
  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await setFilter(state.filter.copyWith(customerSearch: null));
    } else {
      await setFilter(state.filter.copyWith(customerSearch: trimmed));
    }
  }

  /// إظهار النشطة فقط (مش delivered/rejected)
  Future<void> toggleOnlyActive() async {
    await setFilter(
      state.filter.copyWith(onlyActive: !state.filter.onlyActive),
    );
  }

  /// إظهار المتأخرة فقط
  Future<void> toggleOnlyDelayed() async {
    await setFilter(
      state.filter.copyWith(onlyDelayed: !state.filter.onlyDelayed),
    );
  }

  /// مسح كل الفلاتر
  Future<void> clearFilters() async {
    await setFilter(const ReceiptFilter());
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  /// حذف إيصال من القائمة
  Future<bool> delete(String id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        state = state.copyWith(
          receipts: state.receipts.where((r) => r.id != id).toList(),
          totalCount: state.totalCount - 1,
        );
      }
      return ok;
    } catch (e) {
      debugPrint('ReceiptsListNotifier.delete error: $e');
      return false;
    }
  }

  /// مسح الخطأ
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

/// الـ provider الرئيسي لحالة القائمة
final receiptsListProvider =
    StateNotifierProvider<ReceiptsListNotifier, ReceiptsListState>((ref) {
  return ReceiptsListNotifier(ref);
});

/// اختصار: قائمة الإيصالات
final receiptsListDataProvider = Provider<List<Receipt>>((ref) {
  return ref.watch(receiptsListProvider).receipts;
});

/// اختصار: هل التحميل جاري؟
final receiptsListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(receiptsListProvider).isLoading;
});

/// اختصار: هل القائمة فاضية؟
final receiptsListEmptyProvider = Provider<bool>((ref) {
  return ref.watch(receiptsListProvider).isEmpty;
});

/// اختصار: الفلتر الحالي
final receiptsListFilterProvider = Provider<ReceiptFilter>((ref) {
  return ref.watch(receiptsListProvider).filter;
});

/// إحصائيات حسب الحالة (من القائمة الحالية)
final receiptsStatsProvider = Provider<Map<ReceiptStatus, int>>((ref) {
  final receipts = ref.watch(receiptsListDataProvider);
  final stats = <ReceiptStatus, int>{};
  for (final r in receipts) {
    stats[r.status] = (stats[r.status] ?? 0) + 1;
  }
  return stats;
});
