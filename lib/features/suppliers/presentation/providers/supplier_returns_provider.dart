// lib/features/suppliers/presentation/providers/supplier_returns_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supplier_service.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierReturnsState — حالة قائمة مرتجعات مورد
/// ═══════════════════════════════════════════════════════════
class SupplierReturnsState {
  final String supplierId;
  final List<SupplierReturn> returns;
  final ReturnStatus? statusFilter;
  final String? search;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const SupplierReturnsState({
    required this.supplierId,
    this.returns = const [],
    this.statusFilter,
    this.search,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && returns.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// إجمالي المرتجعات
  double get totalAmount => returns.fold<double>(0, (sum, r) => sum + r.total);

  /// عدد المرتجعات حسب الحالة
  Map<ReturnStatus, int> get countByStatus {
    final map = <ReturnStatus, int>{};
    for (final r in returns) {
      map[r.status] = (map[r.status] ?? 0) + 1;
    }
    return map;
  }

  /// عدد المرتجعات المعلّقة
  int get pendingCount => returns
      .where((r) =>
          r.status == ReturnStatus.pending || r.status == ReturnStatus.approved)
      .length;

  /// العدد المكتمل
  int get completedCount =>
      returns.where((r) => r.status == ReturnStatus.completed).length;

  /// المرتجعات المفلترة
  List<SupplierReturn> get filteredReturns {
    var list = returns;

    if (statusFilter != null) {
      list = list.where((r) => r.status == statusFilter).toList();
    }

    if (search != null && search!.trim().isNotEmpty) {
      final q = search!.toLowerCase().trim();
      list = list
          .where((r) =>
              (r.returnNumber?.toLowerCase().contains(q) ?? false) ||
              (r.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  SupplierReturnsState copyWith({
    String? supplierId,
    List<SupplierReturn>? returns,
    ReturnStatus? statusFilter,
    bool clearStatusFilter = false,
    String? search,
    bool clearSearch = false,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierReturnsState(
      supplierId: supplierId ?? this.supplierId,
      returns: returns ?? this.returns,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      search: clearSearch ? null : (search ?? this.search),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// SupplierReturnsNotifier
/// ═══════════════════════════════════════════════════════════
class SupplierReturnsNotifier extends StateNotifier<SupplierReturnsState> {
  SupplierReturnsNotifier(this._ref, String supplierId)
      : super(SupplierReturnsState(supplierId: supplierId)) {
    load();
  }

  final Ref _ref;

  SupplierService get _service => _ref.read(supplierServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final returns = await _service.listReturns(
        supplierId: state.supplierId,
      );
      state = state.copyWith(returns: returns, isLoading: false);
    } catch (e) {
      debugPrint('SupplierReturnsNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل المرتجعات',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final returns = await _service.listReturns(
        supplierId: state.supplierId,
      );
      state = state.copyWith(returns: returns, clearError: true);
    } catch (e) {
      debugPrint('SupplierReturnsNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  CREATE
  // ─────────────────────────────────────────────────────────

  Future<bool> createReturn(SupplierReturn ret) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final created = await _service.createReturn(ret);
      if (created == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل إنشاء المرتجع',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierReturnsNotifier.createReturn error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل إنشاء المرتجع',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  STATUS
  // ─────────────────────────────────────────────────────────

  Future<bool> changeStatus({
    required String returnId,
    required ReturnStatus newStatus,
    String? note,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final result = await _service.changeReturnStatus(
        returnId: returnId,
        newStatus: newStatus,
        note: note,
      );
      if (result == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث الحالة',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierReturnsNotifier.changeStatus error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث الحالة',
      );
      return false;
    }
  }

  /// الموافقة على المرتجع
  Future<bool> approve(String returnId) => changeStatus(
        returnId: returnId,
        newStatus: ReturnStatus.approved,
      );

  /// إكمال المرتجع (يخصم من الرصيد)
  Future<bool> complete(String returnId) => changeStatus(
        returnId: returnId,
        newStatus: ReturnStatus.completed,
      );

  /// رفض المرتجع
  Future<bool> reject(String returnId, {String? reason}) => changeStatus(
        returnId: returnId,
        newStatus: ReturnStatus.rejected,
        note: reason,
      );

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  Future<bool> deleteReturn(String id) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.deleteReturn(id);
      if (ok) {
        state = state.copyWith(
          returns: state.returns.where((r) => r.id != id).toList(),
        );
      }
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('SupplierReturnsNotifier.deleteReturn error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل حذف المرتجع',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  void filterByStatus(ReturnStatus? status) {
    state = status == null
        ? state.copyWith(clearStatusFilter: true)
        : state.copyWith(statusFilter: status);
  }

  void search(String? query) {
    final trimmed = query?.trim();
    state = (trimmed == null || trimmed.isEmpty)
        ? state.copyWith(clearSearch: true)
        : state.copyWith(search: trimmed);
  }

  void clearFilters() {
    state = state.copyWith(clearStatusFilter: true, clearSearch: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final supplierReturnsListProvider = StateNotifierProvider.family<
    SupplierReturnsNotifier, SupplierReturnsState, String>((ref, id) {
  return SupplierReturnsNotifier(ref, id);
});

/// المرتجعات المفلترة
final supplierReturnsFilteredProvider =
    Provider.family<List<SupplierReturn>, String>((ref, id) {
  return ref.watch(supplierReturnsListProvider(id)).filteredReturns;
});

/// إجمالي المرتجعات
final supplierReturnsTotalProvider = Provider.family<double, String>((ref, id) {
  return ref.watch(supplierReturnsListProvider(id)).totalAmount;
});

/// عدد المرتجعات حسب الحالة
final supplierReturnsCountsProvider =
    Provider.family<Map<ReturnStatus, int>, String>((ref, id) {
  return ref.watch(supplierReturnsListProvider(id)).countByStatus;
});

/// عدد المرتجعات المعلّقة
final supplierReturnsPendingProvider = Provider.family<int, String>((ref, id) {
  return ref.watch(supplierReturnsListProvider(id)).pendingCount;
});

/// فلتر الحالة الحالي
final supplierReturnsStatusFilterProvider =
    Provider.family<ReturnStatus?, String>((ref, id) {
  return ref.watch(supplierReturnsListProvider(id)).statusFilter;
});
