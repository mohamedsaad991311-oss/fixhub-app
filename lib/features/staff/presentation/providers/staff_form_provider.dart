// lib/features/staff/presentation/providers/staff_form_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/staff_service.dart';
import '../../../auth/data/models/app_user.dart' show UserRole;
import '../../data/models/staff_member.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffFormState — حالة نموذج الموظف (إضافة/تعديل)
/// ═══════════════════════════════════════════════════════════
class StaffFormState {
  /// لو null → وضع الإضافة، لو موجود → وضع التعديل
  final String? editingId;

  // الحقول الأساسية
  final String fullName;
  final String? fullNameAr;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  // الدور والصلاحيات
  final UserRole role;
  final StaffPermissions permissions;

  // معلومات الوظيفة
  final DateTime? hireDate;
  final double? salary;

  // الحالة
  final bool isActive;
  final String? notes;

  // حالة الحفظ
  final bool isSaving;
  final String? errorMessage;

  const StaffFormState({
    this.editingId,
    this.fullName = '',
    this.fullNameAr,
    this.email,
    this.phone,
    this.avatarUrl,
    this.role = UserRole.technician,
    this.permissions = StaffPermissions.none,
    this.hireDate,
    this.salary,
    this.isActive = true,
    this.notes,
    this.isSaving = false,
    this.errorMessage,
  });

  bool get isEditing => editingId != null;
  bool get isAdd => editingId == null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get isValid {
    final hasName = fullName.trim().isNotEmpty;
    final hasContact = (phone?.trim().isNotEmpty ?? false) ||
        (email?.trim().isNotEmpty ?? false);
    return hasName && hasContact;
  }

  StaffFormState copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? fullName,
    String? fullNameAr,
    bool clearFullNameAr = false,
    String? email,
    bool clearEmail = false,
    String? phone,
    bool clearPhone = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
    UserRole? role,
    StaffPermissions? permissions,
    DateTime? hireDate,
    bool clearHireDate = false,
    double? salary,
    bool clearSalary = false,
    bool? isActive,
    String? notes,
    bool clearNotes = false,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaffFormState(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      fullName: fullName ?? this.fullName,
      fullNameAr: clearFullNameAr ? null : (fullNameAr ?? this.fullNameAr),
      email: clearEmail ? null : (email ?? this.email),
      phone: clearPhone ? null : (phone ?? this.phone),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      hireDate: clearHireDate ? null : (hireDate ?? this.hireDate),
      salary: clearSalary ? null : (salary ?? this.salary),
      isActive: isActive ?? this.isActive,
      notes: clearNotes ? null : (notes ?? this.notes),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// StaffFormNotifier
/// ═══════════════════════════════════════════════════════════
class StaffFormNotifier extends StateNotifier<StaffFormState> {
  StaffFormNotifier(this._ref) : super(const StaffFormState());

  final Ref _ref;

  StaffService get _service => _ref.read(staffServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────

  Future<void> loadForEdit(String id) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final member = await _service.getById(id);
      if (member == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'الموظف غير موجود',
        );
        return;
      }
      state = StaffFormState(
        editingId: member.id,
        fullName: member.fullName,
        fullNameAr: member.fullNameAr,
        email: member.email,
        phone: member.phone,
        avatarUrl: member.avatarUrl,
        role: member.role,
        permissions: member.permissions,
        hireDate: member.hireDate,
        salary: member.salary,
        isActive: member.isActive,
        notes: member.notes,
      );
    } catch (e) {
      debugPrint('StaffFormNotifier.loadForEdit error: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'فشل تحميل الموظف',
      );
    }
  }

  void reset() {
    state = const StaffFormState();
  }

  // ─────────────────────────────────────────────────────────
  //  SETTERS
  // ─────────────────────────────────────────────────────────

  void setFullName(String v) => state = state.copyWith(fullName: v);

  void setFullNameAr(String? v) => state = v == null
      ? state.copyWith(clearFullNameAr: true)
      : state.copyWith(fullNameAr: v);

  void setEmail(String? v) => state =
      v == null ? state.copyWith(clearEmail: true) : state.copyWith(email: v);

  void setPhone(String? v) => state =
      v == null ? state.copyWith(clearPhone: true) : state.copyWith(phone: v);

  void setAvatarUrl(String? v) => state = v == null
      ? state.copyWith(clearAvatarUrl: true)
      : state.copyWith(avatarUrl: v);

  /// تغيير الدور — بيحدّث الصلاحيات تلقائياً
  void setRole(UserRole role) {
    final permissions = _defaultPermissionsForRole(role);
    state = state.copyWith(role: role, permissions: permissions);
  }

  void setPermissions(StaffPermissions permissions) =>
      state = state.copyWith(permissions: permissions);

  void setHireDate(DateTime? d) => state = d == null
      ? state.copyWith(clearHireDate: true)
      : state.copyWith(hireDate: d);

  void setSalary(double? v) => state =
      v == null ? state.copyWith(clearSalary: true) : state.copyWith(salary: v);

  void setActive(bool v) => state = state.copyWith(isActive: v);

  void setNotes(String? v) => state =
      v == null ? state.copyWith(clearNotes: true) : state.copyWith(notes: v);

  // ─────────────────────────────────────────────────────────
  //  SAVE
  // ─────────────────────────────────────────────────────────

  Future<StaffMember?> save() async {
    if (!state.isValid) {
      state = state.copyWith(
        errorMessage: 'الرجاء إدخال الاسم + (رقم أو إيميل)',
      );
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final member = StaffMember(
        id: state.editingId ?? '',
        tenantId: '',
        fullName: state.fullName.trim(),
        fullNameAr: _nullIfEmpty(state.fullNameAr),
        email: _nullIfEmpty(state.email),
        phone: _nullIfEmpty(state.phone),
        avatarUrl: _nullIfEmpty(state.avatarUrl),
        role: state.role,
        permissions: state.permissions,
        hireDate: state.hireDate,
        salary: state.salary,
        isActive: state.isActive,
        notes: _nullIfEmpty(state.notes),
      );

      final saved = state.isEditing
          ? await _service.update(member)
          : await _service.create(member);

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
      debugPrint('StaffFormNotifier.save error: $e');
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

  StaffPermissions _defaultPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return StaffPermissions.all;
      case UserRole.manager:
        return StaffPermissions.manager;
      case UserRole.technician:
        return StaffPermissions.technician;
      case UserRole.receptionist:
        return StaffPermissions.receptionist;
      case UserRole.accountant:
        return const StaffPermissions(
          canViewReports: true,
          canManageExpenses: true,
        );
    }
  }

  String? _nullIfEmpty(String? v) {
    if (v == null) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final staffFormProvider =
    StateNotifierProvider<StaffFormNotifier, StaffFormState>((ref) {
  return StaffFormNotifier(ref);
});

/// هل في وضع التعديل؟
final staffFormIsEditingProvider = Provider<bool>((ref) {
  return ref.watch(staffFormProvider).isEditing;
});

/// هل الحفظ جاري؟
final staffFormSavingProvider = Provider<bool>((ref) {
  return ref.watch(staffFormProvider).isSaving;
});

/// هل النموذج صالح؟
final staffFormValidProvider = Provider<bool>((ref) {
  return ref.watch(staffFormProvider).isValid;
});
