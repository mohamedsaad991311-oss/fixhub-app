// lib/features/scanner/presentation/providers/scanner_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/services/inventory_service.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../inventory/data/models/inventory_item.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════════
/// SCANNER MODE — نوع المسح
/// ═══════════════════════════════════════════════════════════════

enum ScanMode {
  /// تصنيف تلقائي (IMEI / RCP- / barcode)
  auto,

  /// IMEI للجهاز (15 رقم)
  imei,

  /// رقم إيصال (RCP-YYYYMMDD-XXXX)
  receipt,

  /// باركود قطعة مخزون
  inventory,

  /// QR / أي كود آخر
  qr,
}

extension ScanModeX on ScanMode {
  String get labelAr {
    switch (this) {
      case ScanMode.auto:
        return 'تلقائي';
      case ScanMode.imei:
        return 'IMEI';
      case ScanMode.receipt:
        return 'رقم إيصال';
      case ScanMode.inventory:
        return 'قطعة مخزون';
      case ScanMode.qr:
        return 'QR';
    }
  }
}

/// ═══════════════════════════════════════════════════════════════
/// SCAN RESULT TYPE — نوع النتيجة المكتشفة
/// ═══════════════════════════════════════════════════════════════

enum ScanResultType {
  /// IMEI (15 رقم)
  imei,

  /// رقم إيصال (RCP-YYYYMMDD-XXXX)
  receiptNumber,

  /// Token تتبع (32 حرف alphanumeric)
  trackingToken,

  /// باركود مخزون (SKU-style)
  inventoryBarcode,

  /// QR / غير معروف
  unknown,
}

extension ScanResultTypeX on ScanResultType {
  String get labelAr {
    switch (this) {
      case ScanResultType.imei:
        return 'IMEI';
      case ScanResultType.receiptNumber:
        return 'رقم إيصال';
      case ScanResultType.trackingToken:
        return 'رمز تتبع';
      case ScanResultType.inventoryBarcode:
        return 'باركود مخزون';
      case ScanResultType.unknown:
        return 'غير معروف';
    }
  }
}

/// ═══════════════════════════════════════════════════════════════
/// SCAN LOOKUP RESULT — نتيجة البحث
/// ═══════════════════════════════════════════════════════════════

class ScanLookupResult {
  const ScanLookupResult({
    required this.rawValue,
    required this.type,
    this.receipt,
    this.inventoryItem,
    this.trackingToken,
    this.errorMessage,
  });

  final String rawValue;
  final ScanResultType type;

  /// لو النتيجة إيصال
  final Receipt? receipt;

  /// لو النتيجة قطعة مخزون
  final InventoryItem? inventoryItem;

  /// لو النتيجة token تتبع
  final String? trackingToken;

  /// خطأ إن وجد
  final String? errorMessage;

  bool get hasMatch =>
      receipt != null || inventoryItem != null || trackingToken != null;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}

/// ═══════════════════════════════════════════════════════════════
/// SCANNER STATE
/// ═══════════════════════════════════════════════════════════════

class ScannerState {
  const ScannerState({
    this.mode = ScanMode.auto,
    this.lastType,
    this.lastValue,
    this.isSearching = false,
    this.result,
    this.errorMessage,
    this.isTorchOn = false,
    this.cameraFacing = CameraFacing.back,
    this.isProcessing = false,
  });

  final ScanMode mode;
  final ScanResultType? lastType;
  final String? lastValue;
  final bool isSearching;
  final ScanLookupResult? result;
  final String? errorMessage;
  final bool isTorchOn;
  final CameraFacing cameraFacing;

  /// لمنع المسح المتكرر بسرعة
  final bool isProcessing;

  ScannerState copyWith({
    ScanMode? mode,
    ScanResultType? lastType,
    String? lastValue,
    bool? isSearching,
    ScanLookupResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
    bool? isTorchOn,
    CameraFacing? cameraFacing,
    bool? isProcessing,
  }) {
    return ScannerState(
      mode: mode ?? this.mode,
      lastType: lastType ?? this.lastType,
      lastValue: lastValue ?? this.lastValue,
      isSearching: isSearching ?? this.isSearching,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isTorchOn: isTorchOn ?? this.isTorchOn,
      cameraFacing: cameraFacing ?? this.cameraFacing,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// SCANNER NOTIFIER
/// ═══════════════════════════════════════════════════════════════

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._ref) : super(const ScannerState());

  final Ref _ref;

  ReceiptService get _receiptService => _ref.read(receiptServiceProvider);
  InventoryService get _inventoryService => _ref.read(inventoryServiceProvider);

  /// ═══════════════════════════════════════════════════════════
  /// ON DETECT — يتنادى لما الكاميرا تمسح حاجة
  /// ═══════════════════════════════════════════════════════════
  Future<void> onDetect(String rawValue) async {
    // منع المسح المتكرر
    if (state.isProcessing) return;
    if (rawValue.trim().isEmpty) return;

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearResult: true,
      lastValue: rawValue,
    );

    try {
      // 1) صنّف القيمة
      final type = _classify(rawValue);

      state = state.copyWith(lastType: type);

      // 2) ابحث في Supabase حسب النوع
      final result = await _lookup(rawValue, type);

      state = state.copyWith(
        result: result,
        isSearching: false,
        isProcessing: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ScannerNotifier.onDetect error: $e');
      }
      state = state.copyWith(
        isSearching: false,
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء البحث',
      );
    }
  }

  /// ═══════════════════════════════════════════════════════════
  /// CLASSIFY — تصنيف القيمة
  /// ═══════════════════════════════════════════════════════════
  ScanResultType _classify(String value) {
    final v = value.trim();

    // IMEI: 15 رقم
    if (RegExp(r'^\d{15}$').hasMatch(v)) {
      return ScanResultType.imei;
    }

    // رقم إيصال: RCP-YYYYMMDD-XXXX
    if (RegExp(r'^RCP-\d{8}-\d{4,5}$').hasMatch(v)) {
      return ScanResultType.receiptNumber;
    }

    // Tracking token: 32 حرف alphanumeric
    if (RegExp(r'^[A-Za-z0-9]{32}$').hasMatch(v)) {
      return ScanResultType.trackingToken;
    }

    // باركود مخزون: يبدأ بـ SKU- أو INV-
    if (RegExp(r'^(SKU|INV)-', caseSensitive: false).hasMatch(v)) {
      return ScanResultType.inventoryBarcode;
    }

    return ScanResultType.unknown;
  }

  /// ═══════════════════════════════════════════════════════════
  /// LOOKUP — بحث في Supabase
  /// ═══════════════════════════════════════════════════════════
  Future<ScanLookupResult> _lookup(String rawValue, ScanResultType type) async {
    state = state.copyWith(isSearching: true);

    try {
      switch (type) {
        case ScanResultType.receiptNumber:
          final receipt = await _receiptService.getByNumber(rawValue.trim());
          return ScanLookupResult(
            rawValue: rawValue,
            type: type,
            receipt: receipt,
            errorMessage: receipt == null ? 'لا يوجد إيصال بهذا الرقم' : null,
          );

        case ScanResultType.trackingToken:
          final receipt =
              await _receiptService.getByTrackingToken(rawValue.trim());
          return ScanLookupResult(
            rawValue: rawValue,
            type: type,
            receipt: receipt,
            trackingToken: receipt != null ? rawValue : null,
            errorMessage: receipt == null ? 'رمز تتبع غير صالح' : null,
          );

        case ScanResultType.imei:
          // ابحث عن إيصال بنفس IMEI
          final receipts = await _receiptService.list(
            ReceiptFilter(
              customerSearch: rawValue.trim(),
              limit: 1,
            ),
          );
          final receipt = receipts.isNotEmpty ? receipts.first : null;
          return ScanLookupResult(
            rawValue: rawValue,
            type: type,
            receipt: receipt,
            errorMessage: receipt == null ? 'لا يوجد إيصال بهذا IMEI' : null,
          );

        case ScanResultType.inventoryBarcode:
          // ابحث في المخزون
          final items = await _inventoryService.list(
            InventoryFilter(
              search: rawValue.trim(),
              limit: 1,
            ),
          );
          final item = items.isNotEmpty ? items.first : null;
          return ScanLookupResult(
            rawValue: rawValue,
            type: type,
            inventoryItem: item,
            errorMessage: item == null ? 'لا توجد قطعة بهذا الباركود' : null,
          );

        case ScanResultType.unknown:
          return ScanLookupResult(
            rawValue: rawValue,
            type: type,
            errorMessage: 'نوع الكود غير معروف',
          );
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ScannerNotifier._lookup error: $e');
      }
      return ScanLookupResult(
        rawValue: rawValue,
        type: type,
        errorMessage: 'خطأ في البحث',
      );
    }
  }

  /// ═══════════════════════════════════════════════════════════
  /// ACTIONS
  /// ═══════════════════════════════════════════════════════════

  void setMode(ScanMode mode) {
    state = state.copyWith(
      mode: mode,
      clearResult: true,
      clearError: true,
    );
  }

  void toggleTorch() {
    state = state.copyWith(isTorchOn: !state.isTorchOn);
  }

  void switchCamera() {
    state = state.copyWith(
      cameraFacing: state.cameraFacing == CameraFacing.back
          ? CameraFacing.front
          : CameraFacing.back,
    );
  }

  /// إعادة تعيين بعد المسح (للسماح بمسح جديد)
  void reset() {
    state = state.copyWith(
      clearResult: true,
      clearError: true,
      isProcessing: false,
      isSearching: false,
    );
  }

  /// تحرير القفل بعد فترة (للسماح بالمسح التالي)
  void releaseLock() {
    state = state.copyWith(isProcessing: false);
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(ref);
});

/// provider مشتق: هل فيه نتيجة؟
final scannerHasResultProvider = Provider<bool>((ref) {
  return ref.watch(scannerProvider).result?.hasMatch ?? false;
});

/// provider مشتق: نوع آخر مسح
final scannerLastTypeProvider = Provider<ScanResultType?>((ref) {
  return ref.watch(scannerProvider).lastType;
});
