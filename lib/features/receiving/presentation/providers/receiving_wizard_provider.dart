// lib/features/receiving/presentation/providers/receiving_wizard_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../inventory/data/models/inventory_item.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../receipts/data/models/receipt.dart';
import 'receiving_form_provider.dart';

// ═══════════════════════════════════════════════════════════
//  WizardStep — خطوات الـ Wizard
// ═══════════════════════════════════════════════════════════
enum WizardStep {
  customer, // 0 — بيانات العميل
  device, // 1 — بيانات الجهاز + الأعطال
  review, // 2 — المراجعة والتأكيد
}

extension WizardStepX on WizardStep {
  String get labelAr {
    switch (this) {
      case WizardStep.customer:
        return 'العميل';
      case WizardStep.device:
        return 'الجهاز';
      case WizardStep.review:
        return 'المراجعة';
    }
  }

  String get labelEn {
    switch (this) {
      case WizardStep.customer:
        return 'Customer';
      case WizardStep.device:
        return 'Device';
      case WizardStep.review:
        return 'Review';
    }
  }

  int get index {
    switch (this) {
      case WizardStep.customer:
        return 0;
      case WizardStep.device:
        return 1;
      case WizardStep.review:
        return 2;
    }
  }

  static WizardStep fromIndex(int i) {
    if (i <= 0) return WizardStep.customer;
    if (i == 1) return WizardStep.device;
    return WizardStep.review;
  }
}

// ═══════════════════════════════════════════════════════════
//  ReceivingWizardState — حالة الـ Wizard
// ═══════════════════════════════════════════════════════════
class ReceivingWizardState {
  final WizardStep currentStep;
  final bool isSubmitting;
  final String? errorMessage;
  final Receipt? createdReceipt;

  const ReceivingWizardState({
    this.currentStep = WizardStep.customer,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdReceipt,
  });

  int get currentIndex => currentStep.index;
  bool get isFirstStep => currentStep == WizardStep.customer;
  bool get isLastStep => currentStep == WizardStep.review;
  bool get isSuccess => createdReceipt != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  ReceivingWizardState copyWith({
    WizardStep? currentStep,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Receipt? createdReceipt,
    bool clearReceipt = false,
  }) {
    return ReceivingWizardState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdReceipt:
          clearReceipt ? null : (createdReceipt ?? this.createdReceipt),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ReceivingWizardNotifier — إدارة الخطوات + الحفظ
// ═══════════════════════════════════════════════════════════
class ReceivingWizardNotifier extends StateNotifier<ReceivingWizardState> {
  ReceivingWizardNotifier(this._ref) : super(const ReceivingWizardState());

  final Ref _ref;

  // ─── Navigation ───

  void next() {
    if (state.currentStep == WizardStep.review) return;
    state = state.copyWith(
      currentStep: WizardStepX.fromIndex(state.currentIndex + 1),
    );
  }

  void back() {
    if (state.currentStep == WizardStep.customer) return;
    state = state.copyWith(
      currentStep: WizardStepX.fromIndex(state.currentIndex - 1),
    );
  }

  void goTo(WizardStep step) {
    if (step.index > state.currentIndex) {
      final form = _ref.read(receivingFormProvider);
      if (step.index >= 1 && !form.isStep1Valid) return;
      if (step.index >= 2 && !form.isStep2Valid) return;
    }
    state = state.copyWith(currentStep: step);
  }

  // ─── Submit ───

  Future<bool> submit() async {
    final form = _ref.read(receivingFormProvider);

    if (!form.isComplete) {
      state = state.copyWith(
        errorMessage: 'الرجاء إكمال البيانات المطلوبة',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final service = _ref.read(receiptServiceProvider);
      final draft = _ref.read(receivingFormProvider.notifier).toReceiptDraft();

      final created = await service.create(draft: draft);

      if (created == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'فشل إنشاء الإيصال. حاول مرة أخرى.',
        );
        return false;
      }

      // ✅ خصم القطع من المخزون (الباج 2)
      final usedItems = form.usedItems;
      if (usedItems.isNotEmpty) {
        final inventoryService = _ref.read(inventoryServiceProvider);
        for (final used in usedItems) {
          try {
            await inventoryService.stockOut(
              inventoryId: used.inventoryId,
              quantity: used.quantity,
              type: MovementType.usage,
              referenceId: created.id,
              referenceType: 'receipt',
              notes: 'استخدام في إيصال ${created.receiptNumber}',
            );
          } catch (e) {
            // لو فشل خصم قطعة، نسجل الخطأ بس منوقفش العملية
            debugPrint('فشل خصم القطعة ${used.itemName}: $e');
          }
        }
      }

      state = state.copyWith(
        isSubmitting: false,
        createdReceipt: created,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('ReceivingWizardNotifier.submit error: $e');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'حدث خطأ غير متوقع. حاول مرة أخرى.',
      );
      return false;
    }
  }

  // ─── Reset ───

  void reset() {
    _ref.read(receivingFormProvider.notifier).reset();
    state = const ReceivingWizardState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  PROVIDER
// ═══════════════════════════════════════════════════════════

final receivingWizardProvider =
    StateNotifierProvider<ReceivingWizardNotifier, ReceivingWizardState>((ref) {
  return ReceivingWizardNotifier(ref);
});
