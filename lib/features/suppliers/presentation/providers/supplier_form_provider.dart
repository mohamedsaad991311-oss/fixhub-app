// lib/features/suppliers/presentation/providers/supplier_form_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supplier_service.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierFormState — حالة نموذج المورد (إضافة/تعديل)
/// ═══════════════════════════════════════════════════════════
class SupplierFormState {
  /// لو null → وضع الإضافة، لو موجود → وضع التعديل
  final String? editingId;

  // الحقول الأساسية
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;

  // بيانات إضافية

  final String? company;
  final String? website;

  // حالة
  final bool isSaving;
  final String? errorMessage;

  const SupplierFormState({
    this.editingId,
    this.name = '',
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.company,
    this.website,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isEditing => editingId != null;
  bool get isAdd => editingId == null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// التحقق
  bool get isValid {
    final hasName = name.trim().isNotEmpty;
    final hasContact = (phone?.trim().isNotEmpty ?? false) ||
        (email?.trim().isNotEmpty ?? false);
    return hasName && hasContact;
  }

  SupplierFormState copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? name,
    String? contactPerson,
    bool clearContactPerson = false,
    String? phone,
    bool clearPhone = false,
    String? email,
    bool clearEmail = false,
    String? address,
    bool clearAddress = false,
    String? notes,
    bool clearNotes = false,
    String? company,
    bool clearCompany = false,
    String? website,
    bool clearWebsite = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierFormState(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      name: name ?? this.name,
      contactPerson:
          clearContactPerson ? null : (contactPerson ?? this.contactPerson),
      phone: clearPhone ? null : (phone ?? this.phone),
      email: clearEmail ? null : (email ?? this.email),
      address: clearAddress ? null : (address ?? this.address),
      notes: clearNotes ? null : (notes ?? this.notes),
      company: clearCompany ? null : (company ?? this.company),
      website: clearWebsite ? null : (website ?? this.website),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// SupplierFormNotifier
/// ═══════════════════════════════════════════════════════════
class SupplierFormNotifier extends StateNotifier<SupplierFormState> {
  SupplierFormNotifier(this._ref) : super(const SupplierFormState());

  final Ref _ref;

  SupplierService get _service => _ref.read(supplierServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────

  /// تحميل مورد للتعديل
  Future<void> loadForEdit(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final supplier = await _service.getById(id);
      if (supplier == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'المورد غير موجود',
        );
        return;
      }
      state = SupplierFormState(
        editingId: supplier.id,
        name: supplier.name,
        contactPerson: supplier.contactPerson,
        phone: supplier.phone,
        email: supplier.email,
        address: supplier.address,
        notes: supplier.notes,
      );
    } catch (e) {
      debugPrint('SupplierFormNotifier.loadForEdit error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'فشل تحميل المورد',
      );
    }
  }

  /// إعادة تعيين
  void reset() {
    state = const SupplierFormState();
  }

  // ─────────────────────────────────────────────────────────
  //  SETTERS
  // ─────────────────────────────────────────────────────────

  void setName(String v) => state = state.copyWith(name: v);

  void setContactPerson(String? v) => state = v == null
      ? state.copyWith(clearContactPerson: true)
      : state.copyWith(contactPerson: v);

  void setPhone(String? v) => state =
      v == null ? state.copyWith(clearPhone: true) : state.copyWith(phone: v);

  void setEmail(String? v) => state =
      v == null ? state.copyWith(clearEmail: true) : state.copyWith(email: v);

  void setAddress(String? v) => state = v == null
      ? state.copyWith(clearAddress: true)
      : state.copyWith(address: v);

  void setNotes(String? v) => state =
      v == null ? state.copyWith(clearNotes: true) : state.copyWith(notes: v);

  void setCompany(String? v) => state = v == null
      ? state.copyWith(clearCompany: true)
      : state.copyWith(company: v);

  void setWebsite(String? v) => state = v == null
      ? state.copyWith(clearWebsite: true)
      : state.copyWith(website: v);

  // ─────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────

  Future<Supplier?> save() async {
    if (!state.isValid) {
      state = state.copyWith(
        errorMessage: 'الرجاء إدخال الاسم + (رقم أو إيميل)',
      );
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final supplier = Supplier(
        id: state.editingId ?? '',
        tenantId: '',
        name: state.name.trim(),
        contactPerson: _nullIfEmpty(state.contactPerson),
        phone: _nullIfEmpty(state.phone),
        email: _nullIfEmpty(state.email),
        address: _nullIfEmpty(state.address),
        notes: _nullIfEmpty(state.notes),
        isActive: true,
      );

      final saved = state.isEditing
          ? await _service.update(supplier)
          : await _service.create(supplier);

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
      debugPrint('SupplierFormNotifier.save error: $e');
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

final supplierFormProvider =
    StateNotifierProvider<SupplierFormNotifier, SupplierFormState>((ref) {
  return SupplierFormNotifier(ref);
});

/// هل في وضع التعديل؟
final supplierFormIsEditingProvider = Provider<bool>((ref) {
  return ref.watch(supplierFormProvider).isEditing;
});

/// هل الحفظ جاري؟
final supplierFormSavingProvider = Provider<bool>((ref) {
  return ref.watch(supplierFormProvider).isSaving;
});

/// هل النموذج صالح؟
final supplierFormValidProvider = Provider<bool>((ref) {
  return ref.watch(supplierFormProvider).isValid;
});
