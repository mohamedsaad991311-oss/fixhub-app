// lib/features/cloud_sync/presentation/pages/cloud_sync_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../providers/cloud_sync_provider.dart';
import '../widgets/backup_list_tile.dart';
import '../widgets/backup_status_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// CloudSyncPage — صفحة المزامنة السحابية والنسخ الاحتياطي
/// ═══════════════════════════════════════════════════════════════
///
/// - كارت الحالة (آخر نسخة + أزرار الإنشاء)
/// - قائمة النسخ السحابية
/// - إجراءات: تحميل، استرجاع، حذف
///
class CloudSyncPage extends ConsumerStatefulWidget {
  const CloudSyncPage({super.key});

  @override
  ConsumerState<CloudSyncPage> createState() => _CloudSyncPageState();
}

class _CloudSyncPageState extends ConsumerState<CloudSyncPage> {
  @override
  void initState() {
    super.initState();
    // تحميل قائمة النسخ عند الدخول
    Future.microtask(() {
      ref.read(cloudSyncProvider.notifier).loadBackups();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  CREATE BACKUP (Cloud)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleCreateCloud() async {
    final notifier = ref.read(cloudSyncProvider.notifier);
    final success = await notifier.createBackup();
    if (!mounted) return;
    _showSnackFromState(success);
  }

  // ═══════════════════════════════════════════════════════════════
  //  CREATE LOCAL BACKUP
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleCreateLocal() async {
    final notifier = ref.read(cloudSyncProvider.notifier);
    final file = await notifier.createLocalBackup();
    if (!mounted) return;

    if (file != null) {
      _showSnack('تم حفظ نسخة محلية في:\n${file.path}', isError: false);
    } else {
      _showSnack('فشل إنشاء النسخة المحلية', isError: true);
    }
    notifier.clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  DOWNLOAD
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleDownload(BackupFile backup) async {
    final notifier = ref.read(cloudSyncProvider.notifier);
    final bytes = await notifier.downloadBackup(backup.path);
    if (!mounted) return;

    if (bytes == null) {
      _showSnack('فشل تحميل النسخة', isError: true);
      notifier.clearMessages();
      return;
    }

    _showSnack(
      'تم تحميل النسخة (${backup.sizeFormatted}) — جاهزة للمشاركة',
      isError: false,
    );
    notifier.clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESTORE (with confirmation)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleRestore(BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFF59E0B),
          size: 40,
        ),
        title: const Text('تأكيد الاسترجاع'),
        content: const Text(
          'سيتم استرجاع البيانات من النسخة المحددة.\n\n'
          '⚠️ هذه العملية قد تُحدِّث أو تستبدل بياناتك الحالية.\n'
          'ننصح بأخذ نسخة جديدة قبل الاسترجاع.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.restore),
            label: const Text('استرجاع'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final notifier = ref.read(cloudSyncProvider.notifier);
    final success = await notifier.restoreBackup(backup.path);
    if (!mounted) return;
    _showSnackFromState(success);
  }

  // ═══════════════════════════════════════════════════════════════
  //  DELETE (with confirmation)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _handleDelete(BackupFile backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(ctx).colorScheme.error,
          size: 40,
        ),
        title: const Text('حذف النسخة'),
        content: Text(
          'هل تريد حذف النسخة "${backup.name}"؟\n\n'
          'هذه العملية لا يمكن التراجع عنها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('حذف'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final notifier = ref.read(cloudSyncProvider.notifier);
    final success = await notifier.deleteBackup(backup.path);
    if (!mounted) return;
    _showSnackFromState(success);
  }

  // ═══════════════════════════════════════════════════════════════
  //  SNACKBARS
  // ═══════════════════════════════════════════════════════════════

  void _showSnackFromState(bool success) {
    final state = ref.read(cloudSyncProvider);
    final msg = success
        ? (state.successMessage ?? 'تمت العملية')
        : (state.errorMessage ?? 'حدث خطأ');
    _showSnack(msg, isError: !success);
    ref.read(cloudSyncProvider.notifier).clearMessages();
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? scheme.error : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudSyncProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(cloudSyncProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(cloudSyncProvider.notifier).refresh(),
        child: _buildBody(context, state, scheme),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CloudSyncState state,
    ColorScheme scheme,
  ) {
    // Loading أولي
    if (state.isLoading && state.backups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ──── Status Card ────
                BackupStatusCard(
                  onCreateCloud: state.isCreating ? () {} : _handleCreateCloud,
                  onCreateLocal: state.isCreating ? () {} : _handleCreateLocal,
                ),

                const SizedBox(height: AppSizes.spaceLg),

                // ──── Section Header ────
                Row(
                  children: [
                    Icon(
                      Icons.cloud_queue,
                      size: AppSizes.iconSm,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    Text(
                      'النسخ السحابية',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (state.backups.isNotEmpty)
                      Text(
                        '${state.backups.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // ──── Backups List ────
                if (state.backups.isEmpty)
                  _buildEmptyList(scheme)
                else
                  ...state.backups.map(
                    (backup) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSizes.spaceSm,
                      ),
                      child: BackupListTile(
                        backup: backup,
                        isRestoring: state.isRestoring,
                        isDeleting: state.isDeleting,
                        onDownload: () => _handleDownload(backup),
                        onRestore: () => _handleRestore(backup),
                        onDelete: () => _handleDelete(backup),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSizes.spaceXl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyList(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spaceXl,
        horizontal: AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: AppSizes.iconXl,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            'لا توجد نسخ احتياطية بعد',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ابدأ بإنشاء أول نسخة سحابية الآن',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
