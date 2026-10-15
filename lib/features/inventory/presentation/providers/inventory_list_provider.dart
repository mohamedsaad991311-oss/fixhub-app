// lib/features/inventory/presentation/providers/inventory_list_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/inventory_service.dart';
import '../../data/models/inventory_item.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryListState — حالة قائمة الأصناف
/// ═══════════════════════════════════════════════════════════
class InventoryListState {
  final InventoryFilter filter;
  final List<InventoryItem> items;
  final InventoryStats stats;
  final bool isLoading;
  final String? errorMessage;

  const InventoryListState({
    this.filter = const InventoryFilter(),
    this.items = const [],
    this.stats = InventoryStats.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && items.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  InventoryListState copyWith({
    InventoryFilter? filter,
    List<InventoryItem>? items,
    InventoryStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryListState(
      filter: filter ?? this.filter,
      items: items ?? this.items,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// InventoryListNotifier — إدارة قائمة الأصناف
/// ═══════════════════════════════════════════════════════════
class InventoryListNotifier extends StateNotifier<InventoryListState> {
  InventoryListNotifier(this._ref) : super(const InventoryListState()) {
    load();
  }

  final Ref _ref;

  InventoryService get _service => _ref.read(inventoryServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  /// تحميل القائمة + الإحصائيات
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getStats(),
      ]);

      final items = results[0] as List<InventoryItem>;
      final stats = results[1] as InventoryStats;

      state = state.copyWith(
        items: items,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('InventoryListNotifier.load error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل المخزون',
      );
    }
  }

  /// تحديث صامت (بدون loading)
  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getStats(),
      ]);

      state = state.copyWith(
        items: results[0] as List<InventoryItem>,
        stats: results[1] as InventoryStats,
        clearError: true,
      );
    } catch (e) {
      debugPrint('InventoryListNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  Future<void> setFilter(InventoryFilter filter) async {
    state = state.copyWith(filter: filter, isLoading: true);
    await load();
  }

  /// بحث
  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    final newFilter = (trimmed == null || trimmed.isEmpty)
        ? state.filter.copyWith(search: '')
        : state.filter.copyWith(search: trimmed);
    await setFilter(newFilter);
  }

  /// فلتر بالفئة
  Future<void> filterByCategory(InventoryCategory? category) async {
    final newFilter = category == null
        ? state.filter.copyWith(clearCategory: true)
        : state.filter.copyWith(category: category);
    await setFilter(newFilter);
  }

  /// إظهار المنخفض فقط
  Future<void> toggleLowStock() async {
    await setFilter(
      state.filter.copyWith(
        onlyLowStock: !state.filter.onlyLowStock,
        onlyOutOfStock: false, // مينفعش الاتنين مع بعض
      ),
    );
  }

  /// إظهار اللي خلص فقط
  Future<void> toggleOutOfStock() async {
    await setFilter(
      state.filter.copyWith(
        onlyOutOfStock: !state.filter.onlyOutOfStock,
        onlyLowStock: false,
      ),
    );
  }

  /// مسح كل الفلاتر
  Future<void> clearFilters() async {
    await setFilter(const InventoryFilter());
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        state = state.copyWith(
          items: state.items.where((i) => i.id != id).toList(),
        );
        // حدّث الإحصائيات
        final stats = await _service.getStats();
        state = state.copyWith(stats: stats);
      }
      return ok;
    } catch (e) {
      debugPrint('InventoryListNotifier.delete error: $e');
      return false;
    }
  }

  /// تفعيل/تعطيل
  Future<bool> setActive(String id, {required bool isActive}) async {
    try {
      final ok = await _service.setActive(id, isActive: isActive);
      if (ok) await refresh();
      return ok;
    } catch (e) {
      debugPrint('InventoryListNotifier.setActive error: $e');
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

/// الـ provider الرئيسي
final inventoryListProvider =
    StateNotifierProvider<InventoryListNotifier, InventoryListState>((ref) {
  return InventoryListNotifier(ref);
});

/// اختصار: القائمة
final inventoryListDataProvider = Provider<List<InventoryItem>>((ref) {
  return ref.watch(inventoryListProvider).items;
});

/// اختصار: الإحصائيات
final inventoryStatsProvider = Provider<InventoryStats>((ref) {
  return ref.watch(inventoryListProvider).stats;
});

/// اختصار: هل التحميل جاري؟
final inventoryListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(inventoryListProvider).isLoading;
});

/// اختصار: هل فاضية؟
final inventoryListEmptyProvider = Provider<bool>((ref) {
  return ref.watch(inventoryListProvider).isEmpty;
});

/// اختصار: الفلتر
final inventoryListFilterProvider = Provider<InventoryFilter>((ref) {
  return ref.watch(inventoryListProvider).filter;
});

/// الأصناف المنخفضة (client-side filter)
final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryListDataProvider);
  return items.where((i) => i.isLowStock).toList();
});

/// الأصناف اللي خلصت
final outOfStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final items = ref.watch(inventoryListDataProvider);
  return items.where((i) => i.quantity <= 0).toList();
});
