// lib/features/receiving/presentation/providers/receiving_form_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../inventory/data/models/inventory_item.dart';
import '../../../receipts/data/models/receipt.dart';

// ═══════════════════════════════════════════════════════════
//  UsedInventoryItem — قطعة غيار مستخدمة
// ═══════════════════════════════════════════════════════════
class UsedInventoryItem {
  final String inventoryId;
  final String itemName;
  final int quantity;
  final double unitCost;
  final double sellingPrice; // ✅ جديد: سعر البيع للعميل

  const UsedInventoryItem({
    required this.inventoryId,
    required this.itemName,
    required this.quantity,
    this.unitCost = 0,
    this.sellingPrice = 0, // ✅ جديد
  });

  // حسابات جاهزة
  double get itemProfit => (sellingPrice - unitCost) * quantity;
  double get customerPartTotal => sellingPrice * quantity;
  double get totalUnitCost => unitCost * quantity;

  UsedInventoryItem copyWith({
    String? inventoryId,
    String? itemName,
    int? quantity,
    double? unitCost,
    double? sellingPrice, // ✅ جديد
  }) {
    return UsedInventoryItem(
      inventoryId: inventoryId ?? this.inventoryId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      sellingPrice: sellingPrice ?? this.sellingPrice, // ✅ جديد
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ReceivingFormState — حالة النموذج
// ═══════════════════════════════════════════════════════════
class ReceivingFormState {
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? customerNotes;

  final String? deviceType;
  final String? deviceBrand;
  final String? deviceModel;
  final String? deviceImei;
  final String? deviceSerial;
  final String? deviceColor;
  final String? devicePassword;
  
  // ✅ الحقول الجديدة
  final String? lockType;              
  final String? lockPatternImage;      
  final String? conditionNotes;
  final List<String> conditionPhotos;  

  final List<ReceiptIssue> issues;
  final List<ReceiptAccessory> accessories;
  final List<UsedInventoryItem> usedItems;

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
    this.lockType,
    this.lockPatternImage,
    this.conditionNotes,
    this.conditionPhotos = const [],
    this.issues = const [],
    this.accessories = const [],
    this.usedItems = const [],
    this.priority = ReceiptPriority.normal,
    this.estimatedCost = 0,
    this.deposit = 0,
    this.discount = 0,
    this.warrantyDays = 0,
    this.notes,
    this.expectedDeliveryDate,
  });

  // ✅ الحسابات الجديدة
  double get customerPartsTotal =>
      usedItems.fold(0.0, (sum, item) => sum + item.customerPartTotal);

  double get totalPartsCost =>
      usedItems.fold(0.0, (sum, item) => sum + item.totalUnitCost);

  double get total => estimatedCost + customerPartsTotal - discount;

  double get totalProfit => estimatedCost - discount +
      usedItems.fold(0.0, (sum, item) => sum + item.itemProfit);

  double get remainingAmount => total - deposit;

  String get deviceFullName {
    final parts = [deviceBrand, deviceModel]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'جهاز غير محدد' : parts.join(' ');
  }

  bool get isStep1Valid {
    return customerName.trim().isNotEmpty && customerPhone.trim().isNotEmpty;
  }

  bool get isStep2Valid {
    return (deviceType?.trim().isNotEmpty ?? false) && issues.isNotEmpty;
  }

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
    String? lockType,
    bool clearLockType = false,
    String? lockPatternImage,
    bool clearLockPatternImage = false,
    String? conditionNotes,
    bool clearConditionNotes = false,
    List<String>? conditionPhotos,
    List<ReceiptIssue>? issues,
    List<ReceiptAccessory>? accessories,
    List<UsedInventoryItem>? usedItems,
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
      lockType: clearLockType ? null : (lockType ?? this.lockType),
      lockPatternImage: clearLockPatternImage ? null : (lockPatternImage ?? this.lockPatternImage),
      conditionNotes:
          clearConditionNotes ? null : (conditionNotes ?? this.conditionNotes),
      conditionPhotos: conditionPhotos ?? this.conditionPhotos,
      issues: issues ?? this.issues,
      accessories: accessories ?? this.accessories,
      usedItems: usedItems ?? this.usedItems,
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

// ═══════════════════════════════════════════════════════════
//  ReceivingFormNotifier — إدارة النموذج
// ═══════════════════════════════════════════════════════════
class ReceivingFormNotifier extends StateNotifier<ReceivingFormState> {
  ReceivingFormNotifier() : super(const ReceivingFormState());

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

  // ✅ دوال الحقول الجديدة
  void setLockType(String? v) {
    state = v == null
        ? state.copyWith(clearLockType: true)
        : state.copyWith(lockType: v);
  }

  void setLockPatternImage(String? v) {
    state = v == null
        ? state.copyWith(clearLockPatternImage: true)
        : state.copyWith(lockPatternImage: v);
  }

  void setConditionNotes(String? v) {
    state = v == null
        ? state.copyWith(clearConditionNotes: true)
        : state.copyWith(conditionNotes: v);
  }

  void addConditionPhoto(String path) {
    state = state.copyWith(conditionPhotos: [...state.conditionPhotos, path]);
  }

  void removeConditionPhoto(int index) {
    if (index < 0 || index >= state.conditionPhotos.length) return;
    final copy = [...state.conditionPhotos]..removeAt(index);
    state = state.copyWith(conditionPhotos: copy);
  }

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

  // ✅ قطع الغيار المستخدمة
  void addUsedItem(UsedInventoryItem item) {
    state = state.copyWith(usedItems: [...state.usedItems, item]);
  }

  void removeUsedItem(int index) {
    if (index < 0 || index >= state.usedItems.length) return;
    final copy = [...state.usedItems]..removeAt(index);
    state = state.copyWith(usedItems: copy);
  }

  void updateUsedItemQuantity(int index, int newQuantity) {
    if (index < 0 || index >= state.usedItems.length) return;
    final copy = [...state.usedItems];
    copy[index] = copy[index].copyWith(quantity: newQuantity);
    state = state.copyWith(usedItems: copy);
  }

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

  void reset() {
    state = const ReceivingFormState();
  }

  Receipt toReceiptDraft() {
    return Receipt(
      id: '',
      tenantId: '',
      receiptNumber: '',
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

final receivingFormProvider =
    StateNotifierProvider<ReceivingFormNotifier, ReceivingFormState>((ref) {
  return ReceivingFormNotifier();
});