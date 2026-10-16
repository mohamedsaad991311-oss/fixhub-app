// lib/features/delivery/presentation/providers/delivery_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/receipt_service.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════════
/// DELIVERY STATE
/// ═══════════════════════════════════════════════════════════════

class DeliveryState {
  const DeliveryState({
    this.receipts = const [],
    this.isLoading = false,
    this.isDelivering = false,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  /// الإيصالات الجاهزة للتسليم (status = ready)
  final List<Receipt> receipts;

  final bool isLoading;
  final bool isDelivering;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;

  /// قائمة مفلترة بالبحث
  List<Receipt> get filteredReceipts {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return receipts;

    return receipts.where((r) {
      return r.customerName.toLowerCase().contains(q) ||
          (r.customerPhone?.toLowerCase() ?? '').contains(q) ||
          (r.deviceImei?.toLowerCase() ?? '').contains(q) ||
          r.receiptNumber.toLowerCase().contains(q) ||
          (r.deviceModel?.toLowerCase() ?? '').contains(q) ||
          (r.deviceBrand?.toLowerCase() ?? '').contains(q);
    }).toList();
  }

  /// إجمالي المتبقي (المبلغ النهائي - العربون) لكل الإيصالات
  double get totalPending {
    return receipts.fold<double>(0, (sum, r) {
      final remaining = (r.finalCost > 0 ? r.finalCost : r.total) - r.deposit;
      return sum + (remaining > 0 ? remaining : 0);
    });
  }

  /// إجمالي العربون المستلم
  double get totalDeposits {
    return receipts.fold<double>(0, (sum, r) => sum + r.deposit);
  }

  DeliveryState copyWith({
    List<Receipt>? receipts,
    bool? isLoading,
    bool? isDelivering,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return DeliveryState(
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      isDelivering: isDelivering ?? this.isDelivering,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// DELIVERY NOTIFIER
/// ═══════════════════════════════════════════════════════════════

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  DeliveryNotifier(this._service) : super(const DeliveryState()) {
    loadReadyReceipts();
  }

  final ReceiptService _service;

  // ═══════════════════════════════════════════════════════════════
  //  LOAD — جلب الإيصالات الجاهزة (status = ready)
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadReadyReceipts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final receipts = await _service.list(
        const ReceiptFilter(
          status: ReceiptStatus.ready,
          sortBy: ReceiptSortBy.updatedAt,
          sortAscending: false,
          limit: 100,
        ),
      );

      state = state.copyWith(
        receipts: receipts,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DeliveryNotifier.loadReadyReceipts error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الإيصالات الجاهزة',
      );
    }
  }

  Future<void> refresh() => loadReadyReceipts();

  // ═══════════════════════════════════════════════════════════════
  //  SEARCH
  // ═══════════════════════════════════════════════════════════════

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // ═══════════════════════════════════════════════════════════════
  //  DELIVER — تسليم الإيصال
  // ═══════════════════════════════════════════════════════════════

  /// تسليم الإيصال (تغيير الحالة إلى delivered)
  Future<bool> deliverReceipt(
    String receiptId, {
    String? note,
    double? finalCost,
  }) async {
    if (state.isDelivering) return false;

    state = state.copyWith(
      isDelivering: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      // لو في finalCost جديد → حدّثه قبل التسليم
      if (finalCost != null && finalCost > 0) {
        final existing = state.receipts.firstWhere(
          (r) => r.id == receiptId,
          orElse: () => throw StateError('الإيصال غير موجود'),
        );

        await _service.patch(receiptId, {
          'final_cost': finalCost,
          'total': finalCost,
        });
        // نحدث محلياً بعد التسليم (الـ changeStatus هيرجع النسخة المحدثة)
        debugPrint('Final cost updated: ${existing.id} → $finalCost');
      }

      final updated = await _service.changeStatus(
        receiptId: receiptId,
        newStatus: ReceiptStatus.delivered,
        note: note ?? 'تم تسليم الجهاز للعميل',
      );

      if (updated == null) {
        state = state.copyWith(
          isDelivering: false,
          errorMessage: 'فشل تسليم الإيصال',
        );
        return false;
      }

      // إزالة من قائمة ready
      final newList = state.receipts.where((r) => r.id != receiptId).toList();

      state = state.copyWith(
        receipts: newList,
        isDelivering: false,
        successMessage: 'تم تسليم الإيصال بنجاح',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DeliveryNotifier.deliverReceipt error: $e');
      }
      state = state.copyWith(
        isDelivering: false,
        errorMessage: 'حدث خطأ أثناء التسليم',
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  MESSAGES
  // ═══════════════════════════════════════════════════════════════

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  final service = ref.watch(receiptServiceProvider);
  return DeliveryNotifier(service);
});

/// provider مشتق: قائمة مفلترة
final filteredDeliveryReceiptsProvider = Provider<List<Receipt>>((ref) {
  return ref.watch(deliveryProvider).filteredReceipts;
});

/// provider مشتق: إجمالي المتبقي
final totalPendingProvider = Provider<double>((ref) {
  return ref.watch(deliveryProvider).totalPending;
});

/// provider مشتق: عدد الإيصالات الجاهزة
final readyCountProvider = Provider<int>((ref) {
  return ref.watch(deliveryProvider).receipts.length;
});
