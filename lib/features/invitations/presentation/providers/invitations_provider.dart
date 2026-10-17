// lib/features/invitations/presentation/providers/invitations_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/invitations_service.dart';
import '../../data/models/invitation.dart';

/// ═══════════════════════════════════════════════════════════════
/// حالة الدعوات
/// ═══════════════════════════════════════════════════════════════

class InvitationsState {
  const InvitationsState({
    this.invitations = const [],
    this.filterStatus,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<Invitation> invitations;
  final String? filterStatus;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final String? successMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;
  bool get isEmpty => invitations.isEmpty && !isLoading;

  /// الدعوات المعلقة فقط
  List<Invitation> get pendingInvitations =>
      invitations.where((i) => i.isPending).toList();

  /// عدد الدعوات المعلقة
  int get pendingCount => pendingInvitations.length;

  /// الدعوات المفلترة حسب الحالة
  List<Invitation> get filteredInvitations {
    if (filterStatus == null || filterStatus == 'all') {
      return invitations;
    }
    return invitations.where((i) => i.status == filterStatus).toList();
  }

  InvitationsState copyWith({
    List<Invitation>? invitations,
    String? filterStatus,
    bool clearFilter = false,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return InvitationsState(
      invitations: invitations ?? this.invitations,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// مزوّد الدعوات
/// ═══════════════════════════════════════════════════════════════

class InvitationsNotifier extends StateNotifier<InvitationsState> {
  InvitationsNotifier(this._service) : super(const InvitationsState()) {
    load();
  }

  final InvitationsService _service;

  // ─────────────────────────────────────────────────────────────
  //  تحميل
  // ─────────────────────────────────────────────────────────────

  /// تحميل قائمة الدعوات
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final invitations = await _service.list();
      state = state.copyWith(
        invitations: invitations,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsNotifier.load error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الدعوات',
      );
    }
  }

  /// تحديث
  Future<void> refresh() => load();

  // ─────────────────────────────────────────────────────────────
  //  إنشاء دعوة
  // ─────────────────────────────────────────────────────────────

  /// إنشاء دعوة جديدة
  Future<Invitation?> createInvitation({
    required String role,
    String? email,
    String? phone,
    String? fullName,
  }) async {
    if (state.isProcessing) return null;

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final invitation = await _service.create(
        role: role,
        email: email,
        phone: phone,
        fullName: fullName,
      );

      if (invitation == null) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'فشل إنشاء الدعوة',
        );
        return null;
      }

      // أضف في بداية القائمة
      state = state.copyWith(
        invitations: [invitation, ...state.invitations],
        isProcessing: false,
        successMessage: 'تم إنشاء الدعوة بنجاح',
      );
      return invitation;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsNotifier.createInvitation error: $e');
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء الإنشاء',
      );
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  إلغاء دعوة
  // ─────────────────────────────────────────────────────────────

  /// إلغاء دعوة
  Future<bool> cancelInvitation(String invitationId) async {
    if (state.isProcessing) return false;

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final ok = await _service.cancel(invitationId);

      if (!ok) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'فشل إلغاء الدعوة',
        );
        return false;
      }

      // تحديث محلي
      final updated = state.invitations.map((i) {
        if (i.id == invitationId) {
          return i.copyWith(
            status: 'cancelled',
            cancelledAt: DateTime.now(),
          );
        }
        return i;
      }).toList();

      state = state.copyWith(
        invitations: updated,
        isProcessing: false,
        successMessage: 'تم إلغاء الدعوة',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsNotifier.cancelInvitation error: $e');
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء الإلغاء',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  حذف دعوة
  // ─────────────────────────────────────────────────────────────

  /// حذف دعوة نهائياً
  Future<bool> deleteInvitation(String invitationId) async {
    if (state.isProcessing) return false;

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final ok = await _service.delete(invitationId);

      if (!ok) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: 'فشل حذف الدعوة',
        );
        return false;
      }

      // احذف من القائمة محلياً
      final updated =
          state.invitations.where((i) => i.id != invitationId).toList();

      state = state.copyWith(
        invitations: updated,
        isProcessing: false,
        successMessage: 'تم حذف الدعوة',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('InvitationsNotifier.deleteInvitation error: $e');
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'حدث خطأ أثناء الحذف',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  فلترة
  // ─────────────────────────────────────────────────────────────

  /// تعيين فلتر الحالة
  void setFilter(String? status) {
    if (status == null || status == 'all') {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterStatus: status);
    }
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

final invitationsProvider =
    StateNotifierProvider<InvitationsNotifier, InvitationsState>((ref) {
  final service = ref.watch(invitationsServiceProvider);
  return InvitationsNotifier(service);
});

/// قائمة الدعوات المفلترة
final filteredInvitationsProvider = Provider<List<Invitation>>((ref) {
  return ref.watch(invitationsProvider).filteredInvitations;
});

/// عدد الدعوات المعلقة (للـ badge)
final pendingInvitationsCountProvider = Provider<int>((ref) {
  return ref.watch(invitationsProvider).pendingCount;
});

/// الدعوات المعلقة فقط
final pendingInvitationsProvider = Provider<List<Invitation>>((ref) {
  return ref.watch(invitationsProvider).pendingInvitations;
});
