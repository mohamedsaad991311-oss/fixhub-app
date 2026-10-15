// lib/features/inventory/presentation/providers/inventory_detail_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/inventory_service.dart';
import '../../data/models/inventory_item.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryDetailState — حالة تفاصيل صنف
/// ═══════════════════════════════════════════════════════════
class InventoryDetailState {
  final String itemId;
  final InventoryItem? item;
  final List<InventoryMovement> movements;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const InventoryDetailState({
    required this.itemId,
    this.item,
    this.movements = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get hasItem => item != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  InventoryDetailState copyWith({
    String? itemId,
    InventoryItem? item,
    bool clearItem = false,
    List<InventoryMovement>? movements,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryDetailState(
      itemId: itemId ?? this.itemId,
      item: clearItem ? null : (item ?? this.item),
      movements: movements ?? this.movements,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// InventoryDetailNotifier
/// ═══════════════════════════════════════════════════════════
class InventoryDetailNotifier extends StateNotifier<InventoryDetailState> {
  InventoryDetailNotifier(this._ref, String itemId)
      : super(InventoryDetailState(itemId: itemId)) {
    load();
  }

  final Ref _ref;

  InventoryService get _service => _ref.read(inventoryServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final item = await _service.getById(state.itemId);
      if (item == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'الصنف غير موجود',
        );
        return;
      }

      final movements = await _service.getMovements(
        inventoryId: state.itemId,
        limit: 50,
      );

      state = state.copyWith(
        item: item,
        movements: movements,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('InventoryDetailNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الصنف',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final item = await _service.getById(state.itemId);
      if (item == null) return;
      final movements = await _service.getMovements(
        inventoryId: state.itemId,
        limit: 50,
      );
      state = state.copyWith(item: item, movements: movements);
    } catch (e) {
      debugPrint('InventoryDetailNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE
  // ─────────────────────────────────────────────────────────

  Future<bool> update(InventoryItem item) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.update(item);
      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث الصنف',
        );
        return false;
      }
      state = state.copyWith(item: updated, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('InventoryDetailNotifier.update error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث الصنف',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  STOCK MOVEMENTS
  // ─────────────────────────────────────────────────────────

  /// إدخال كمية
  Future<bool> stockIn({
    required int quantity,
    MovementType type = MovementType.purchase,
    double? unitCost,
    String? notes,
  }) async {
    return _applyMovement(
      action: () => _service.stockIn(
        inventoryId: state.itemId,
        quantity: quantity,
        type: type,
        unitCost: unitCost,
        notes: notes,
      ),
      successMsg: 'تم إدخال $quantity وحدة',
    );
  }

  /// إخراج كمية
  Future<bool> stockOut({
    required int quantity,
    MovementType type = MovementType.usage,
    String? notes,
  }) async {
    return _applyMovement(
      action: () => _service.stockOut(
        inventoryId: state.itemId,
        quantity: quantity,
        type: type,
        notes: notes,
      ),
      successMsg: 'تم إخراج $quantity وحدة',
    );
  }

  /// تسوية الكمية (تعيين قيمة جديدة)
  Future<bool> adjustStock({
    required int newQuantity,
    String? notes,
  }) async {
    return _applyMovement(
      action: () => _service.adjustStock(
        inventoryId: state.itemId,
        newQuantity: newQuantity,
        notes: notes,
      ),
      successMsg: 'تم تعديل الكمية',
    );
  }

  Future<bool> _applyMovement({
    required Future<InventoryItem?> Function() action,
    required String successMsg,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await action();
      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل العملية — تأكد من الكمية',
        );
        return false;
      }

      // أعد تحميل الـ movements
      final movements = await _service.getMovements(
        inventoryId: state.itemId,
        limit: 50,
      );

      state = state.copyWith(
        item: updated,
        movements: movements,
        isUpdating: false,
      );

      debugPrint('✅ $successMsg');
      return true;
    } catch (e) {
      debugPrint('InventoryDetailNotifier._applyMovement error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل العملية',
      );
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

/// Family provider — كل صنف له notifier
final inventoryDetailProvider = StateNotifierProvider.family<
    InventoryDetailNotifier, InventoryDetailState, String>((ref, id) {
  return InventoryDetailNotifier(ref, id);
});

/// اختصار: الصنف نفسه
final inventoryItemByIdProvider =
    Provider.family<InventoryItem?, String>((ref, id) {
  return ref.watch(inventoryDetailProvider(id)).item;
});

/// اختصار: الحركات
final inventoryMovementsProvider =
    Provider.family<List<InventoryMovement>, String>((ref, id) {
  return ref.watch(inventoryDetailProvider(id)).movements;
});

/// اختصار: هل التحميل جاري؟
final inventoryItemLoadingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(inventoryDetailProvider(id)).isLoading;
});

/// اختصار: هل التحديث جاري؟
final inventoryItemUpdatingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(inventoryDetailProvider(id)).isUpdating;
});
