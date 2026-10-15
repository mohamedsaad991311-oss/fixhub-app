// lib/features/suppliers/presentation/providers/suppliers_list_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supplier_service.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SuppliersListState — حالة قائمة الموردين
/// ═══════════════════════════════════════════════════════════
class SuppliersListState {
  final SupplierFilter filter;
  final List<Supplier> suppliers;
  final SupplierStats stats;
  final bool isLoading;
  final String? errorMessage;

  const SuppliersListState({
    this.filter = const SupplierFilter(),
    this.suppliers = const [],
    this.stats = SupplierStats.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && suppliers.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  SuppliersListState copyWith({
    SupplierFilter? filter,
    List<Supplier>? suppliers,
    SupplierStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SuppliersListState(
      filter: filter ?? this.filter,
      suppliers: suppliers ?? this.suppliers,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// SuppliersListNotifier
/// ═══════════════════════════════════════════════════════════
class SuppliersListNotifier extends StateNotifier<SuppliersListState> {
  SuppliersListNotifier(this._ref) : super(const SuppliersListState()) {
    load();
  }

  final Ref _ref;

  SupplierService get _service => _ref.read(supplierServiceProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _service.list(state.filter),
        _service.getStats(),
      ]);

      state = state.copyWith(
        suppliers: results[0] as List<Supplier>,
        stats: results[1] as SupplierStats,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('SuppliersListNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الموردين',
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
        suppliers: results[0] as List<Supplier>,
        stats: results[1] as SupplierStats,
        clearError: true,
      );
    } catch (e) {
      debugPrint('SuppliersListNotifier.refresh error: $e');
    }
  }

  Future<void> setFilter(SupplierFilter filter) async {
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

  Future<void> toggleOnlyActive() async {
    await setFilter(
      state.filter.copyWith(onlyActive: !state.filter.onlyActive),
    );
  }

  Future<void> toggleOnlyWithDebt() async {
    await setFilter(
      state.filter.copyWith(onlyWithDebt: !state.filter.onlyWithDebt),
    );
  }

  Future<void> clearFilters() async {
    await setFilter(const SupplierFilter());
  }

  Future<bool> delete(String id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        state = state.copyWith(
          suppliers: state.suppliers.where((s) => s.id != id).toList(),
        );
        final stats = await _service.getStats();
        state = state.copyWith(stats: stats);
      }
      return ok;
    } catch (e) {
      debugPrint('SuppliersListNotifier.delete error: $e');
      return false;
    }
  }

  Future<bool> setActive(String id, {required bool isActive}) async {
    try {
      final ok = await _service.setActive(id, isActive: isActive);
      if (ok) await refresh();
      return ok;
    } catch (e) {
      debugPrint('SuppliersListNotifier.setActive error: $e');
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

final suppliersListProvider =
    StateNotifierProvider<SuppliersListNotifier, SuppliersListState>((ref) {
  return SuppliersListNotifier(ref);
});

final suppliersListDataProvider = Provider<List<Supplier>>((ref) {
  return ref.watch(suppliersListProvider).suppliers;
});

final suppliersStatsProvider = Provider<SupplierStats>((ref) {
  return ref.watch(suppliersListProvider).stats;
});

final suppliersListLoadingProvider = Provider<bool>((ref) {
  return ref.watch(suppliersListProvider).isLoading;
});

final suppliersListEmptyProvider = Provider<bool>((ref) {
  return ref.watch(suppliersListProvider).isEmpty;
});

final suppliersListFilterProvider = Provider<SupplierFilter>((ref) {
  return ref.watch(suppliersListProvider).filter;
});

final suppliersWithBalanceProvider = Provider<List<Supplier>>((ref) {
  final list = ref.watch(suppliersListDataProvider);
  return list.where((s) => s.balance > 0).toList();
});
