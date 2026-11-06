// lib/features/inventory/presentation/providers/inventory_list_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/inventory_service.dart';
import '../../data/models/inventory_item.dart';

// ═══════════════════════════════════════════════════════════
//  INVENTORY LIST STATE
// ═══════════════════════════════════════════════════════════
class InventoryListState {
  final List<InventoryItem> items;
  final InventoryFilter filter;
  final InventoryStats stats;
  final bool isLoading;
  final String? errorMessage;

  const InventoryListState({
    this.items = const [],
    this.filter = const InventoryFilter(),
    this.stats = InventoryStats.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isEmpty => !isLoading && !hasError && items.isEmpty;

  InventoryListState copyWith({
    List<InventoryItem>? items,
    InventoryFilter? filter,
    InventoryStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryListState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  INVENTORY LIST NOTIFIER
// ═══════════════════════════════════════════════════════════
class InventoryListNotifier extends StateNotifier<InventoryListState> {
  InventoryListNotifier(this._ref) : super(const InventoryListState()) {
    load();
  }

  final Ref _ref;
  InventoryService get _service => _ref.read(inventoryServiceProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _service.list(state.filter);
      final stats = await _service.getStats();
      state = state.copyWith(items: items, stats: stats, isLoading: false);
    } catch (e) {
      debugPrint('InventoryListNotifier.load error: $e');
      state =
          state.copyWith(isLoading: false, errorMessage: 'فشل تحميل المخزون');
    }
  }

  Future<void> refresh() => load();

  void search(String query) {
    final newFilter = state.filter.copyWith(search: query, offset: 0);
    state = state.copyWith(filter: newFilter);
    load();
  }

  void filterByCategory(InventoryCategory? category) {
    final newFilter = state.filter.copyWith(
      category: category,
      clearCategory: category == null,
      offset: 0,
    );
    state = state.copyWith(filter: newFilter);
    load();
  }

  // ✅ فلتر الموردين
  void filterBySupplier(String? supplierId) {
    final newFilter = state.filter.copyWith(
      supplierId: supplierId,
      clearSupplier: supplierId == null,
      offset: 0,
    );
    state = state.copyWith(filter: newFilter);
    load();
  }

  // ✅ فلتر الماركة
  void filterByBrand(String? brandName) {
    final newFilter = state.filter.copyWith(
      brandName: brandName,
      clearBrand: brandName == null,
      offset: 0,
    );
    state = state.copyWith(filter: newFilter);
    load();
  }

  void toggleLowStock() {
    final newFilter = state.filter.copyWith(
      onlyLowStock: !state.filter.onlyLowStock,
      onlyOutOfStock: false,
      offset: 0,
    );
    state = state.copyWith(filter: newFilter);
    load();
  }

  void toggleOutOfStock() {
    final newFilter = state.filter.copyWith(
      onlyOutOfStock: !state.filter.onlyOutOfStock,
      onlyLowStock: false,
      offset: 0,
    );
    state = state.copyWith(filter: newFilter);
    load();
  }

  void clearFilters() {
    state = state.copyWith(filter: const InventoryFilter());
    load();
  }

  Future<bool> delete(String id) async {
    final ok = await _service.delete(id);
    if (ok) load();
    return ok;
  }
}

// ═══════════════════════════════════════════════════════════
//  PROVIDER
// ═══════════════════════════════════════════════════════════
final inventoryListProvider =
    StateNotifierProvider<InventoryListNotifier, InventoryListState>((ref) {
  return InventoryListNotifier(ref);
});
