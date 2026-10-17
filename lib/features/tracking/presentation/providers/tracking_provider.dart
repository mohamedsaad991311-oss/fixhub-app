// lib/features/tracking/presentation/providers/tracking_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/receipt_service.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════════
/// حالة التتبع
/// ═══════════════════════════════════════════════════════════════

class TrackingState {
  const TrackingState({
    this.receipts = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  final List<Receipt> receipts;
  final bool isLoading;
  final bool isProcessing;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;
  bool get isEmpty => receipts.isEmpty && !isLoading;

  /// الإيصالات مع البحث
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

  /// عدد الإيصالات اللي عندها tracking token
  int get withTrackingCount {
    return receipts.where((r) {
      final t = r.trackingToken;
      return t != null && t.isNotEmpty;
    }).length;
  }

  TrackingState copyWith({
    List<Receipt>? receipts,
    bool? isLoading,
    bool? isProcessing,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return TrackingState(
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// مزوّد التتبع
/// ═══════════════════════════════════════════════════════════════

class TrackingNotifier extends StateNotifier<TrackingState> {
  TrackingNotifier(this._service) : super(const TrackingState()) {
    load();
  }

  final ReceiptService _service;

  // ─────────────────────────────────────────────────────────────
  //  تحميل
  // ─────────────────────────────────────────────────────────────

  /// تحميل الإيصالات النشطة (للتتبع)
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // نجيب الإيصالات النشطة (مش delivered/rejected)
      // + الإيصالات المسلّمة حديثاً (ممكن تتبعها للضمان)
      final all = await _service.list(
        const ReceiptFilter(
          sortBy: ReceiptSortBy.createdAt,
          sortAscending: false,
          limit: 200,
        ),
      );

      // نفلتر: لازم يكون عنده tracking_token
      final withTracking = all.where((r) {
        final t = r.trackingToken;
        return t != null && t.isNotEmpty;
      }).toList();

      // ترتيب: الأحدث أولاً
      withTracking.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      state = state.copyWith(
        receipts: withTracking,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('TrackingNotifier.load error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل روابط التتبع',
      );
    }
  }

  /// تحديث
  Future<void> refresh() => load();

  // ─────────────────────────────────────────────────────────────
  //  تجديد الرابط
  // ─────────────────────────────────────────────────────────────

  /// تجديد token الإيصال (ينشئ رابط جديد)
  Future<String?> regenerateToken(String receiptId) async {
    if (state.isProcessing) return null;

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final newToken = await _service.refreshTrackingToken(receiptId);

      if (newToken == null) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'فشل تجديد الرابط',
        );
        return null;
      }

      // تحديث محلي — الإيصال ده بقى عنده token جديد
      // (نحتاج نجيبه من DB عشان نحدّث)
      final fresh = await _service.getById(receiptId);

      List<Receipt> updated;
      if (fresh != null) {
        updated =
            state.receipts.map((r) => r.id == receiptId ? fresh : r).toList();
      } else {
        updated = state.receipts;
      }

      state = state.copyWith(
        receipts: updated,
        isProcessing: false,
        successMessage: 'تم تجديد الرابط',
      );
      return newToken;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('TrackingNotifier.regenerateToken error: $e');
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء التجديد',
      );
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  إلغاء الرابط
  // ─────────────────────────────────────────────────────────────

  /// إلغاء token الإيصال (يوقف التتبع)
  Future<bool> revokeToken(String receiptId) async {
    if (state.isProcessing) return false;

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final ok = await _service.revokeTrackingToken(receiptId);

      if (!ok) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'فشل إلغاء الرابط',
        );
        return false;
      }

      // إزالة الإيصال من القائمة (لأنه بقى بلا token)
      final updated = state.receipts.where((r) => r.id != receiptId).toList();

      state = state.copyWith(
        receipts: updated,
        isProcessing: false,
        successMessage: 'تم إلغاء رابط التتبع',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('TrackingNotifier.revokeToken error: $e');
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء الإلغاء',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  البحث
  // ─────────────────────────────────────────────────────────────

  /// تعيين نص البحث
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// مسح البحث
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // ─────────────────────────────────────────────────────────────
  //  رسائل
  // ─────────────────────────────────────────────────────────────

  /// مسح رسائل النجاح/الخطأ
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ═══════════════════════════════════════════════════════════════
//  مزوّدات Riverpod
// ═══════════════════════════════════════════════════════════════

final trackingProvider =
    StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  final service = ref.watch(receiptServiceProvider);
  return TrackingNotifier(service);
});

/// قائمة الإيصالات المفلترة
final filteredTrackingReceiptsProvider = Provider<List<Receipt>>((ref) {
  return ref.watch(trackingProvider).filteredReceipts;
});

/// عدد الإيصالات اللي عندها تتبع
final trackingReceiptsCountProvider = Provider<int>((ref) {
  return ref.watch(trackingProvider).receipts.length;
});
