// lib/features/receipts/presentation/providers/receipt_detail_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/receipt_service.dart';
import '../../data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptDetailState — حالة تفاصيل إيصال واحد
/// ═══════════════════════════════════════════════════════════
class ReceiptDetailState {
  final String receiptId;
  final Receipt? receipt;
  final List<Map<String, dynamic>> statusHistory;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const ReceiptDetailState({
    required this.receiptId,
    this.receipt,
    this.statusHistory = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get hasReceipt => receipt != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  ReceiptDetailState copyWith({
    String? receiptId,
    Receipt? receipt,
    bool clearReceipt = false,
    List<Map<String, dynamic>>? statusHistory,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReceiptDetailState(
      receiptId: receiptId ?? this.receiptId,
      receipt: clearReceipt ? null : (receipt ?? this.receipt),
      statusHistory: statusHistory ?? this.statusHistory,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReceiptDetailNotifier — إدارة تفاصيل إيصال
/// ═══════════════════════════════════════════════════════════
class ReceiptDetailNotifier extends StateNotifier<ReceiptDetailState> {
  ReceiptDetailNotifier(this._ref, String receiptId)
      : super(ReceiptDetailState(receiptId: receiptId)) {
    load();
  }

  final Ref _ref;

  ReceiptService get _service => _ref.read(receiptServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final receipt = await _service.getById(state.receiptId);
      if (receipt == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'الإيصال غير موجود',
        );
        return;
      }

      final history = await _service.getStatusHistory(state.receiptId);

      state = state.copyWith(
        receipt: receipt,
        statusHistory: history,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الإيصال',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final receipt = await _service.getById(state.receiptId);
      if (receipt == null) return;
      final history = await _service.getStatusHistory(state.receiptId);
      state = state.copyWith(receipt: receipt, statusHistory: history);
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  STATUS
  // ─────────────────────────────────────────────────────────

  Future<bool> changeStatus({
    required ReceiptStatus newStatus,
    String? note,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.changeStatus(
        receiptId: state.receiptId,
        newStatus: newStatus,
        note: note,
      );

      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تغيير الحالة',
        );
        return false;
      }

      final history = await _service.getStatusHistory(state.receiptId);

      state = state.copyWith(
        receipt: updated,
        statusHistory: history,
        isUpdating: false,
      );
      return true;
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.changeStatus error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تغيير الحالة',
      );
      return false;
    }
  }

  Future<bool> advanceStatus({String? note}) async {
    final current = state.receipt;
    if (current == null) return false;
    final next = current.status.next;
    if (next == null) return false;
    return changeStatus(newStatus: next, note: note);
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE
  // ─────────────────────────────────────────────────────────

  Future<bool> update(Receipt receipt) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.update(receipt);
      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث الإيصال',
        );
        return false;
      }
      state = state.copyWith(receipt: updated, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.update error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث الإيصال',
      );
      return false;
    }
  }

  Future<bool> patch(Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.patch(state.receiptId, data);
      if (ok) {
        await refresh();
        state = state.copyWith(isUpdating: false);
      } else {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل التحديث',
        );
      }
      return ok;
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.patch error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل التحديث',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  TRACKING
  // ─────────────────────────────────────────────────────────

  Future<String?> refreshTrackingToken() async {
    try {
      final token = await _service.refreshTrackingToken(state.receiptId);
      if (token != null) await refresh();
      return token;
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.refreshTrackingToken error: $e');
      return null;
    }
  }

  Future<bool> revokeTrackingToken() async {
    try {
      final ok = await _service.revokeTrackingToken(state.receiptId);
      if (ok) await refresh();
      return ok;
    } catch (e) {
      debugPrint('ReceiptDetailNotifier.revokeTrackingToken error: $e');
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

/// Family provider
final receiptDetailProvider = StateNotifierProvider.family<
    ReceiptDetailNotifier, ReceiptDetailState, String>((ref, id) {
  return ReceiptDetailNotifier(ref, id);
});

/// اختصار: الإيصال نفسه
final receiptByIdProvider = Provider.family<Receipt?, String>((ref, id) {
  return ref.watch(receiptDetailProvider(id)).receipt;
});

/// اختصار: هل التحميل جاري؟
final receiptLoadingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(receiptDetailProvider(id)).isLoading;
});

/// اختصار: هل التحديث جاري؟
final receiptUpdatingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(receiptDetailProvider(id)).isUpdating;
});

/// اختصار: history
final receiptHistoryProvider =
    Provider.family<List<Map<String, dynamic>>, String>(
  (ref, id) {
    return ref.watch(receiptDetailProvider(id)).statusHistory;
  },
);
