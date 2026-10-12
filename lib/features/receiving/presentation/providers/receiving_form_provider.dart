// lib/features/receiving/presentation/providers/receiving_form_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceivingFormState — حالة النموذج
/// ═══════════════════════════════════════════════════════════
class ReceivingFormState {
  // ─── Customer ───
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? customerNotes;

  // ─── Device ───
  final String? deviceType;
  final String? deviceBrand;
  final String? deviceModel;
  final String? deviceImei;
  final String? deviceSerial;
  final String? deviceColor;
  final String? devicePassword;
  final String? conditionNotes;

  // ─── Issues + Accessories ───
  final List<ReceiptIssue> issues;
  final List<ReceiptAccessory> accessories;

  // ─── Pricing + Priority ───
  final ReceiptPriority priority;
  final double estimatedCost;
  final double deposit;
  final double discount;
  final int warrantyDays;
  final String? notes;
  final DateTime? expectedDeliveryDate;

  const ReceivingFormState({
    this.customerName = '',
    this.customerPhone = '',
    this.customerEmail,
    this.customerNotes,
    this.deviceType,
    this.deviceBrand,
    this.deviceModel,
    this.deviceImei,
    this.deviceSerial,
    this.deviceColor,
    this.devicePassword,
    this.conditionNotes,
    this.issues = const [],
    this.accessories = const [],
    this.priority = ReceiptPriority.normal,
    this.estimatedCost = 0,
    this.deposit = 0,
    this.discount = 0,
    this.warrantyDays = 0,
    this.notes,
    this.expectedDeliveryDate,
  });

  /// صافي الإجمالي = (التقديري - خصم) + ضريبة (0 مؤقتاً)
  double get total => estimatedCost - discount;

  /// المتبقي = total - deposit
  double get remainingAmount => total - deposit;

  /// جهاز كامل الاسم
  String get deviceFullName {
    final parts = [deviceBrand, deviceModel]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'جهاز غير محدد' : parts.join(' ');
  }

  /// هل الخطوة 1 صالحة؟ (بيانات العميل)
  bool get isStep1Valid {
    return customerName.trim().isNotEmpty && customerPhone.trim().isNotEmpty;
  }

  /// هل الخطوة 2 صالحة؟ (الجهاز + عطل واحد على الأقل)
  bool get isStep2Valid {
    return (deviceType?.trim().isNotEmpty ?? false) && issues.isNotEmpty;
  }

  /// هل كل شيء صالح؟
  bool get isComplete => isStep1Valid && isStep2Valid;

  ReceivingFormState copyWith({
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    bool clearCustomerEmail = false,
    String? customerNotes,
    bool clearCustomerNotes = false,
    String? deviceType,
    bool clearDeviceType = false,
    String? deviceBrand,
    bool clearDeviceBrand = false,
    String? deviceModel,
    bool clearDeviceModel = false,
    String? deviceImei,
    bool clearDeviceImei = false,
    String? deviceSerial,
    bool clearDeviceSerial = false,
    String? deviceColor,
    bool clearDeviceColor = false,
    String? devicePassword,
    bool clearDevicePassword = false,
    String? conditionNotes,
    bool clearConditionNotes = false,
    List<ReceiptIssue>? issues,
    List<ReceiptAccessory>? accessories,
    ReceiptPriority? priority,
    double? estimatedCost,
    double? deposit,
    double? discount,
    int? warrantyDays,
    String? notes,
    bool clearNotes = false,
    DateTime? expectedDeliveryDate,
    bool clearExpectedDelivery = false,
  }) {
    return ReceivingFormState(
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail:
          clearCustomerEmail ? null : (customerEmail ?? this.customerEmail),
      customerNotes:
          clearCustomerNotes ? null : (customerNotes ?? this.customerNotes),
      deviceType: clearDeviceType ? null : (deviceType ?? this.deviceType),
      deviceBrand: clearDeviceBrand ? null : (deviceBrand ?? this.deviceBrand),
      deviceModel: clearDeviceModel ? null : (deviceModel ?? this.deviceModel),
      deviceImei: clearDeviceImei ? null : (deviceImei ?? this.deviceImei),
      deviceSerial:
          clearDeviceSerial ? null : (deviceSerial ?? this.deviceSerial),
      deviceColor: clearDeviceColor ? null : (deviceColor ?? this.deviceColor),
      devicePassword:
          clearDevicePassword ? null : (devicePassword ?? this.devicePassword),
      conditionNotes:
          clearConditionNotes ? null : (conditionNotes ?? this.conditionNotes),
      issues: issues ?? this.issues,
      accessories: accessories ?? this.accessories,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      deposit: deposit ?? this.deposit,
      discount: discount ?? this.discount,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      notes: clearNotes ? null : (notes ?? this.notes),
      expectedDeliveryDate: clearExpectedDelivery
          ? null
          : (expectedDeliveryDate ?? this.expectedDeliveryDate),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReceivingFormNotifier — إدارة النموذج
/// ═══════════════════════════════════════════════════════════
class ReceivingFormNotifier extends StateNotifier<ReceivingFormState> {
  ReceivingFormNotifier() : super(const ReceivingFormState());

  // ─── Customer ───

  void setCustomerName(String v) => state = state.copyWith(customerName: v);

  void setCustomerPhone(String v) => state = state.copyWith(customerPhone: v);

  void setCustomerEmail(String? v) {
    state = v == null
        ? state.copyWith(clearCustomerEmail: true)
        : state.copyWith(customerEmail: v);
  }

  void setCustomerNotes(String? v) {
    state = v == null
        ? state.copyWith(clearCustomerNotes: true)
        : state.copyWith(customerNotes: v);
  }

  // ─── Device ───

  void setDeviceType(String? v) {
    state = v == null
        ? state.copyWith(clearDeviceType: true)
        : state.copyWith(deviceType: v);
  }

  void setDeviceBrand(String? v) {
    state = v == null
        ? state.copyWith(clearDeviceBrand: true)
        : state.copyWith(deviceBrand: v);
  }

  void setDeviceModel(String? v) {
    state = v == null
        ? state.copyWith(clearDeviceModel: true)
        : state.copyWith(deviceModel: v);
  }

  void setDeviceImei(String? v) {
    state = v == null
        ? state.copyWith(clearDeviceImei: true)
        : state.copyWith(deviceImei: v);
  }

  void setDeviceSerial(String? v) {
    state = v == null
        ? state.copyWith(clearDeviceSerial: true)
        : state.copyWith(deviceSerial: v);
  }

  void setDeviceColor(String? v) {
    state = v == null
        ? state.copyWith(clearDeviceColor: true)
        : state.copyWith(deviceColor: v);
  }

  void setDevicePassword(String? v) {
    state = v == null
        ? state.copyWith(clearDevicePassword: true)
        : state.copyWith(devicePassword: v);
  }

  void setConditionNotes(String? v) {
    state = v == null
        ? state.copyWith(clearConditionNotes: true)
        : state.copyWith(conditionNotes: v);
  }

  // ─── Issues ───

  void addIssue(ReceiptIssue issue) {
    state = state.copyWith(issues: [...state.issues, issue]);
  }

  void removeIssue(int index) {
    if (index < 0 || index >= state.issues.length) return;
    final copy = [...state.issues]..removeAt(index);
    state = state.copyWith(issues: copy);
  }

  void updateIssue(int index, ReceiptIssue issue) {
    if (index < 0 || index >= state.issues.length) return;
    final copy = [...state.issues];
    copy[index] = issue;
    state = state.copyWith(issues: copy);
  }

  // ─── Accessories ───

  void addAccessory(ReceiptAccessory acc) {
    state = state.copyWith(accessories: [...state.accessories, acc]);
  }

  void removeAccessory(int index) {
    if (index < 0 || index >= state.accessories.length) return;
    final copy = [...state.accessories]..removeAt(index);
    state = state.copyWith(accessories: copy);
  }

  void toggleAccessory(int index) {
    if (index < 0 || index >= state.accessories.length) return;
    final copy = [...state.accessories];
    final old = copy[index];
    copy[index] = ReceiptAccessory(
      name: old.name,
      isIncluded: !old.isIncluded,
      notes: old.notes,
    );
    state = state.copyWith(accessories: copy);
  }

  // ─── Pricing + Priority ───

  void setPriority(ReceiptPriority p) => state = state.copyWith(priority: p);

  void setEstimatedCost(double v) => state = state.copyWith(estimatedCost: v);

  void setDeposit(double v) => state = state.copyWith(deposit: v);

  void setDiscount(double v) => state = state.copyWith(discount: v);

  void setWarrantyDays(int v) => state = state.copyWith(warrantyDays: v);

  void setNotes(String? v) {
    state =
        v == null ? state.copyWith(clearNotes: true) : state.copyWith(notes: v);
  }

  void setExpectedDeliveryDate(DateTime? d) {
    state = d == null
        ? state.copyWith(clearExpectedDelivery: true)
        : state.copyWith(expectedDeliveryDate: d);
  }

  // ─── Reset ───

  void reset() {
    state = const ReceivingFormState();
  }

  // ─── Build Receipt ───

  /// تحويل النموذج لـ `Receipt` (draft) جاهز للإرسال لـ service
  Receipt toReceiptDraft() {
    return Receipt(
      id: '',
      tenantId: '',
      receiptNumber: '', // هيتم توليده في ReceiptService
      customerName: state.customerName.trim(),
      customerPhone: state.customerPhone.trim().isEmpty
          ? null
          : state.customerPhone.trim(),
      customerEmail: state.customerEmail?.trim().isEmpty ?? true
          ? null
          : state.customerEmail?.trim(),
      customerNotes: state.customerNotes?.trim().isEmpty ?? true
          ? null
          : state.customerNotes?.trim(),
      deviceType: state.deviceType?.trim().isEmpty ?? true
          ? null
          : state.deviceType?.trim(),
      deviceBrand: state.deviceBrand?.trim().isEmpty ?? true
          ? null
          : state.deviceBrand?.trim(),
      deviceModel: state.deviceModel?.trim().isEmpty ?? true
          ? null
          : state.deviceModel?.trim(),
      deviceImei: state.deviceImei?.trim().isEmpty ?? true
          ? null
          : state.deviceImei?.trim(),
      deviceSerial: state.deviceSerial?.trim().isEmpty ?? true
          ? null
          : state.deviceSerial?.trim(),
      deviceColor: state.deviceColor?.trim().isEmpty ?? true
          ? null
          : state.deviceColor?.trim(),
      devicePassword: state.devicePassword?.trim().isEmpty ?? true
          ? null
          : state.devicePassword?.trim(),
      conditionNotes: state.conditionNotes?.trim().isEmpty ?? true
          ? null
          : state.conditionNotes?.trim(),
      issues: state.issues,
      accessories: state.accessories,
      priority: state.priority,
      estimatedCost: state.estimatedCost,
      deposit: state.deposit,
      discount: state.discount,
      total: state.total,
      warrantyDays: state.warrantyDays,
      notes: state.notes?.trim().isEmpty ?? true ? null : state.notes?.trim(),
      expectedDeliveryDate: state.expectedDeliveryDate,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════

/// الـ form state
final receivingFormProvider =
    StateNotifierProvider<ReceivingFormNotifier, ReceivingFormState>((ref) {
  return ReceivingFormNotifier();
});
