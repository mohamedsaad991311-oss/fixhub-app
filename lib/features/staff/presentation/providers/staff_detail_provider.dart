// lib/features/staff/presentation/providers/staff_detail_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/staff_service.dart';
import '../../../auth/data/models/app_user.dart' show UserRole;
import '../../data/models/staff_member.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffDetailState — حالة تفاصيل موظف
/// ═══════════════════════════════════════════════════════════
class StaffDetailState {
  final String staffId;
  final StaffMember? member;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const StaffDetailState({
    required this.staffId,
    this.member,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get hasMember => member != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  StaffDetailState copyWith({
    String? staffId,
    StaffMember? member,
    bool clearMember = false,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaffDetailState(
      staffId: staffId ?? this.staffId,
      member: clearMember ? null : (member ?? this.member),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// StaffDetailNotifier
/// ═══════════════════════════════════════════════════════════
class StaffDetailNotifier extends StateNotifier<StaffDetailState> {
  StaffDetailNotifier(this._ref, String staffId)
      : super(StaffDetailState(staffId: staffId)) {
    load();
  }

  final Ref _ref;

  StaffService get _service => _ref.read(staffServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final member = await _service.getById(state.staffId);
      if (member == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'الموظف غير موجود',
        );
        return;
      }
      state = state.copyWith(member: member, isLoading: false);
    } catch (e) {
      debugPrint('StaffDetailNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الموظف',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final member = await _service.getById(state.staffId);
      if (member == null) return;
      state = state.copyWith(member: member, clearError: true);
    } catch (e) {
      debugPrint('StaffDetailNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE
  // ─────────────────────────────────────────────────────────

  Future<bool> update(StaffMember member) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final updated = await _service.update(member);
      if (updated == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث الموظف',
        );
        return false;
      }
      state = state.copyWith(member: updated, isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('StaffDetailNotifier.update error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث الموظف',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  STATUS
  // ─────────────────────────────────────────────────────────

  Future<bool> setActive({required bool isActive}) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.setActive(state.staffId, isActive: isActive);
      if (!ok) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث الحالة',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('StaffDetailNotifier.setActive error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث الحالة',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  ROLE
  // ─────────────────────────────────────────────────────────

  Future<bool> changeRole(UserRole newRole) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.changeRole(state.staffId, newRole);
      if (!ok) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تغيير الدور',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('StaffDetailNotifier.changeRole error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تغيير الدور',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  PERMISSIONS
  // ─────────────────────────────────────────────────────────

  Future<bool> updatePermissions(StaffPermissions permissions) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.updatePermissions(
        state.staffId,
        permissions,
      );
      if (!ok) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تحديث الصلاحيات',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('StaffDetailNotifier.updatePermissions error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تحديث الصلاحيات',
      );
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

final staffDetailProvider =
    StateNotifierProvider.family<StaffDetailNotifier, StaffDetailState, String>(
        (ref, id) {
  return StaffDetailNotifier(ref, id);
});

/// اختصار: الموظف
final staffMemberByIdProvider =
    Provider.family<StaffMember?, String>((ref, id) {
  return ref.watch(staffDetailProvider(id)).member;
});

/// اختصار: هل التحميل جاري؟
final staffDetailLoadingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(staffDetailProvider(id)).isLoading;
});

/// اختصار: هل التحديث جاري؟
final staffDetailUpdatingProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(staffDetailProvider(id)).isUpdating;
});
