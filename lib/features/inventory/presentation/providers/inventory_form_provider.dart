// lib/features/inventory/presentation/providers/inventory_form_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/inventory_service.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/inventory_variants.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryFormState — حالة نموذج الصنف (إضافة/تعديل)
/// ═══════════════════════════════════════════════════════════
class InventoryFormState {
  /// لو null → وضع الإضافة، لو موجود → وضع التعديل
  final String? editingId;

  // الحقول الأساسية
  final String name;
  final String? nameAr;
  final String? sku;
  final String? barcode;
  final InventoryCategory category;
  final InventoryVariant variant;
  final String? description;

  // المخزون
  final int quantity;
  final int minQuantity;

  // التسعير
  final double costPrice;
  final double sellingPrice;

  // إضافي
  final String? supplierId;
  final String? location;
  final String? imageUrl;

  // حالة
  final bool isSaving;
  final String? errorMessage;

  const InventoryFormState({
    this.editingId,
    this.name = '',
    this.nameAr,
    this.sku,
    this.barcode,
    this.category = InventoryCategory.other,
    this.variant = InventoryVariant.aftermarket,
    this.description,
    this.quantity = 0,
    this.minQuantity = 5,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.supplierId,
    this.location,
    this.imageUrl,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isEditing => editingId != null;
  bool get isAdd => editingId == null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isValid {
    return name.trim().isNotEmpty &&
        quantity >= 0 &&
        minQuantity >= 0 &&
        costPrice >= 0 &&
        sellingPrice >= 0;
  }

  InventoryFormState copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? name,
    String? nameAr,
    bool clearNameAr = false,
    String? sku,
    bool clearSku = false,
    String? barcode,
    bool clearBarcode = false,
    InventoryCategory? category,
    InventoryVariant? variant,
    String? description,
    bool clearDescription = false,
    int? quantity,
    int? minQuantity,
    double? costPrice,
    double? sellingPrice,
    String? supplierId,
    bool clearSupplierId = false,
    String? location,
    bool clearLocation = false,
    String? imageUrl,
    bool clearImageUrl = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventoryFormState(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      name: name ?? this.name,
      nameAr: clearNameAr ? null : (nameAr ?? this.nameAr),
      sku: clearSku ? null : (sku ?? this.sku),
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      category: category ?? this.category,
      variant: variant ?? this.variant,
      description: clearDescription ? null : (description ?? this.description),
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplierId: clearSupplierId ? null : (supplierId ?? this.supplierId),
      location: clearLocation ? null : (location ?? this.location),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// InventoryFormNotifier
/// ═══════════════════════════════════════════════════════════
class InventoryFormNotifier extends StateNotifier<InventoryFormState> {
  InventoryFormNotifier(this._ref) : super(const InventoryFormState());

  final Ref _ref;

  InventoryService get _service => _ref.read(inventoryServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────

  /// تحميل صنف للتعديل
  Future<void> loadForEdit(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final item = await _service.getById(id);
      if (item == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'الصنف غير موجود',
        );
        return;
      }
      state = InventoryFormState(
        editingId: item.id,
        name: item.name,
        nameAr: item.nameAr,
        sku: item.sku,
        barcode: item.barcode,
        category: item.category,
        variant: item.variant,
        description: item.description,
        quantity: item.quantity,
        minQuantity: item.minQuantity,
        costPrice: item.costPrice,
        sellingPrice: item.sellingPrice,
        supplierId: item.supplierId,
        location: item.location,
        imageUrl: item.imageUrl,
      );
    } catch (e) {
      debugPrint('InventoryFormNotifier.loadForEdit error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'فشل تحميل الصنف',
      );
    }
  }

  /// إعادة تعيين النموذج (لوضع الإضافة)
  void reset() {
    state = const InventoryFormState();
  }

  // ─────────────────────────────────────────────────────────
  //  SETTERS
  // ─────────────────────────────────────────────────────────

  void setName(String v) => state = state.copyWith(name: v);

  void setNameAr(String? v) => state =
      v == null ? state.copyWith(clearNameAr: true) : state.copyWith(nameAr: v);

  void setSku(String? v) => state =
      v == null ? state.copyWith(clearSku: true) : state.copyWith(sku: v);

  void setBarcode(String? v) => state = v == null
      ? state.copyWith(clearBarcode: true)
      : state.copyWith(barcode: v);

  void setCategory(InventoryCategory c) => state = state.copyWith(category: c);

  void setVariant(InventoryVariant v) => state = state.copyWith(variant: v);

  void setDescription(String? v) => state = v == null
      ? state.copyWith(clearDescription: true)
      : state.copyWith(description: v);

  void setQuantity(int v) => state = state.copyWith(quantity: v);

  void setMinQuantity(int v) => state = state.copyWith(minQuantity: v);

  void setCostPrice(double v) => state = state.copyWith(costPrice: v);

  void setSellingPrice(double v) => state = state.copyWith(sellingPrice: v);

  void setSupplierId(String? v) => state = v == null
      ? state.copyWith(clearSupplierId: true)
      : state.copyWith(supplierId: v);

  void setLocation(String? v) => state = v == null
      ? state.copyWith(clearLocation: true)
      : state.copyWith(location: v);

  void setImageUrl(String? v) => state = v == null
      ? state.copyWith(clearImageUrl: true)
      : state.copyWith(imageUrl: v);

  // ─────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────

  /// حفظ (إضافة أو تعديل)
  Future<InventoryItem?> save() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'الرجاء إكمال البيانات المطلوبة');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final item = InventoryItem(
        id: state.editingId ?? '',
        tenantId: '',
        name: state.name.trim(),
        nameAr: _nullIfEmpty(state.nameAr),
        sku: _nullIfEmpty(state.sku),
        barcode: _nullIfEmpty(state.barcode),
        category: state.category,
        variant: state.variant,
        description: _nullIfEmpty(state.description),
        quantity: state.quantity,
        minQuantity: state.minQuantity,
        costPrice: state.costPrice,
        sellingPrice: state.sellingPrice,
        supplierId: _nullIfEmpty(state.supplierId),
        location: _nullIfEmpty(state.location),
        imageUrl: _nullIfEmpty(state.imageUrl),
        isActive: true,
      );

      final saved = state.isEditing
          ? await _service.update(item)
          : await _service.create(item);

      if (saved == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'فشل الحفظ — حاول تاني',
        );
        return null;
      }

      state = state.copyWith(isSaving: false);
      return saved;
    } catch (e) {
      debugPrint('InventoryFormNotifier.save error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'حدث خطأ غير متوقع',
      );
      return null;
    }
  }

  /// حفظ مع variant مخصص
  Future<InventoryItem?> saveWithVariant(InventoryVariant variant) async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: 'الرجاء إكمال البيانات المطلوبة');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final item = InventoryItem(
        id: state.editingId ?? '',
        tenantId: '',
        name: state.name.trim(),
        nameAr: _nullIfEmpty(state.nameAr),
        sku: _nullIfEmpty(state.sku),
        barcode: _nullIfEmpty(state.barcode),
        category: state.category,
        variant: variant,
        description: _nullIfEmpty(state.description),
        quantity: state.quantity,
        minQuantity: state.minQuantity,
        costPrice: state.costPrice,
        sellingPrice: state.sellingPrice,
        supplierId: _nullIfEmpty(state.supplierId),
        location: _nullIfEmpty(state.location),
        imageUrl: _nullIfEmpty(state.imageUrl),
        isActive: true,
      );

      final saved = state.isEditing
          ? await _service.update(item)
          : await _service.create(item);

      if (saved == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'فشل الحفظ — حاول تاني',
        );
        return null;
      }

      state = state.copyWith(isSaving: false);
      return saved;
    } catch (e) {
      debugPrint('InventoryFormNotifier.saveWithVariant error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'حدث خطأ غير متوقع',
      );
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────

  String? _nullIfEmpty(String? v) {
    if (v == null) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final inventoryFormProvider =
    StateNotifierProvider<InventoryFormNotifier, InventoryFormState>((ref) {
  return InventoryFormNotifier(ref);
});

/// هل في وضع التعديل؟
final inventoryFormIsEditingProvider = Provider<bool>((ref) {
  return ref.watch(inventoryFormProvider).isEditing;
});

/// هل الحفظ جاري؟
final inventoryFormSavingProvider = Provider<bool>((ref) {
  return ref.watch(inventoryFormProvider).isSaving;
});

/// هل النموذج صالح؟
final inventoryFormValidProvider = Provider<bool>((ref) {
  return ref.watch(inventoryFormProvider).isValid;
});
