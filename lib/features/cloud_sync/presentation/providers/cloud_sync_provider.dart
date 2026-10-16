// lib/features/cloud_sync/presentation/providers/cloud_sync_provider.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/cloud_sync_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// CLOUD SYNC STATE
/// ═══════════════════════════════════════════════════════════════

class CloudSyncState {
  const CloudSyncState({
    this.backups = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isRestoring = false,
    this.isDeleting = false,
    this.errorMessage,
    this.successMessage,
    this.lastSyncAt,
  });

  /// قائمة النسخ الاحتياطية
  final List<BackupFile> backups;

  /// تحميل أولي لقائمة النسخ
  final bool isLoading;

  /// إنشاء نسخة جديدة
  final bool isCreating;

  /// استرجاع من نسخة
  final bool isRestoring;

  /// حذف نسخة
  final bool isDeleting;

  final String? errorMessage;
  final String? successMessage;

  /// آخر مزامنة ناجحة
  final DateTime? lastSyncAt;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get hasSuccess => successMessage != null && successMessage!.isNotEmpty;
  bool get isBusy => isLoading || isCreating || isRestoring || isDeleting;

  BackupFile? get lastBackup => backups.isNotEmpty ? backups.first : null;

  CloudSyncState copyWith({
    List<BackupFile>? backups,
    bool? isLoading,
    bool? isCreating,
    bool? isRestoring,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    DateTime? lastSyncAt,
  }) {
    return CloudSyncState(
      backups: backups ?? this.backups,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isRestoring: isRestoring ?? this.isRestoring,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// CLOUD SYNC NOTIFIER
/// ═══════════════════════════════════════════════════════════════

class CloudSyncNotifier extends StateNotifier<CloudSyncState> {
  CloudSyncNotifier(this._service) : super(const CloudSyncState()) {
    loadBackups();
  }

  final CloudSyncService _service;

  // ═══════════════════════════════════════════════════════════════
  //  LOAD — تحميل قائمة النسخ
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadBackups() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final backups = await _service.listCloudBackups();
      state = state.copyWith(
        backups: backups,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncNotifier.loadBackups error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل قائمة النسخ',
      );
    }
  }

  Future<void> refresh() => loadBackups();

  // ═══════════════════════════════════════════════════════════════
  //  CREATE — إنشاء نسخة سحابية
  // ═══════════════════════════════════════════════════════════════

  Future<bool> createBackup() async {
    if (state.isCreating) return false;

    state = state.copyWith(
      isCreating: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final result = await _service.createBackup();

      if (!result.success) {
        state = state.copyWith(
          isCreating: false,
          errorMessage: result.error ?? 'فشل إنشاء النسخة',
        );
        return false;
      }

      // أضف النسخة الجديدة للقائمة
      final newList = [
        if (result.file != null) result.file!,
        ...state.backups,
      ];

      state = state.copyWith(
        backups: newList,
        isCreating: false,
        successMessage: 'تم إنشاء النسخة بنجاح',
        lastSyncAt: DateTime.now(),
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncNotifier.createBackup error: $e');
      }
      state = state.copyWith(
        isCreating: false,
        errorMessage: 'حدث خطأ أثناء الإنشاء',
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  LOCAL BACKUP — نسخة محلية
  // ═══════════════════════════════════════════════════════════════

  Future<File?> createLocalBackup() async {
    if (state.isCreating) return null;

    state = state.copyWith(
      isCreating: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final file = await _service.createLocalBackup();

      if (file == null) {
        state = state.copyWith(
          isCreating: false,
          errorMessage: 'فشل إنشاء نسخة محلية',
        );
        return null;
      }

      state = state.copyWith(
        isCreating: false,
        successMessage: 'تم إنشاء نسخة محلية: ${file.path.split('/').last}',
      );
      return file;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncNotifier.createLocalBackup error: $e');
      }
      state = state.copyWith(
        isCreating: false,
        errorMessage: 'حدث خطأ أثناء إنشاء النسخة المحلية',
      );
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  DOWNLOAD — تحميل نسخة (للحفظ/المشاركة)
  // ═══════════════════════════════════════════════════════════════

  Future<Uint8List?> downloadBackup(String path) async {
    try {
      final bytes = await _service.downloadBackup(path);
      if (bytes == null) {
        state = state.copyWith(errorMessage: 'فشل تحميل النسخة');
        return null;
      }
      return bytes;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncNotifier.downloadBackup error: $e');
      }
      state = state.copyWith(errorMessage: 'حدث خطأ أثناء التحميل');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  DELETE — حذف نسخة
  // ═══════════════════════════════════════════════════════════════

  Future<bool> deleteBackup(String path) async {
    if (state.isDeleting) return false;

    state = state.copyWith(
      isDeleting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final success = await _service.deleteCloudBackup(path);

      if (!success) {
        state = state.copyWith(
          isDeleting: false,
          errorMessage: 'فشل حذف النسخة',
        );
        return false;
      }

      // احذف من القائمة
      final newList = state.backups.where((b) => b.path != path).toList();

      state = state.copyWith(
        backups: newList,
        isDeleting: false,
        successMessage: 'تم حذف النسخة',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncNotifier.deleteBackup error: $e');
      }
      state = state.copyWith(
        isDeleting: false,
        errorMessage: 'حدث خطأ أثناء الحذف',
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESTORE — استرجاع (خطر)
  // ═══════════════════════════════════════════════════════════════

  Future<bool> restoreBackup(String path) async {
    if (state.isRestoring) return false;

    state = state.copyWith(
      isRestoring: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final result = await _service.restoreBackup(path);

      if (!result.success) {
        state = state.copyWith(
          isRestoring: false,
          errorMessage: result.error ?? 'فشل الاسترجاع',
        );
        return false;
      }

      state = state.copyWith(
        isRestoring: false,
        successMessage: 'تم الاسترجاع بنجاح — يُفضل إعادة تشغيل التطبيق',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('CloudSyncNotifier.restoreBackup error: $e');
      }
      state = state.copyWith(
        isRestoring: false,
        errorMessage: 'حدث خطأ أثناء الاسترجاع',
      );
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESET MESSAGES — لمسح رسائل النجاح/الخطأ
  // ═══════════════════════════════════════════════════════════════

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final cloudSyncProvider =
    StateNotifierProvider<CloudSyncNotifier, CloudSyncState>((ref) {
  final service = ref.watch(cloudSyncServiceProvider);
  return CloudSyncNotifier(service);
});

/// provider مشتق: قائمة النسخ
final cloudBackupsListProvider = Provider<List<BackupFile>>((ref) {
  return ref.watch(cloudSyncProvider).backups;
});

/// provider مشتق: هل النظام مشغول؟
final cloudSyncBusyProvider = Provider<bool>((ref) {
  return ref.watch(cloudSyncProvider).isBusy;
});

/// provider مشتق: آخر نسخة
final lastCloudBackupProvider = Provider<BackupFile?>((ref) {
  return ref.watch(cloudSyncProvider).lastBackup;
});
