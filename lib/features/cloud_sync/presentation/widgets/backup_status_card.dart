// lib/features/cloud_sync/presentation/widgets/backup_status_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../providers/cloud_sync_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// BackupStatusCard — كارت حالة النسخ الاحتياطي
/// ═══════════════════════════════════════════════════════════════
///
/// - آخر نسخة (اسم، تاريخ، حجم)
/// - زر "إنشاء نسخة الآن" (سحابية)
/// - زر "نسخة محلية"
/// - إحصائيات (عدد النسخ + الإجمالي)
///
class BackupStatusCard extends ConsumerWidget {
  const BackupStatusCard({
    super.key,
    required this.onCreateCloud,
    required this.onCreateLocal,
  });

  final VoidCallback onCreateCloud;
  final VoidCallback onCreateLocal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudSyncProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    final lastBackup = state.lastBackup;
    final totalSize = state.backups.fold<int>(
      0,
      (sum, b) => sum + b.sizeBytes,
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            scheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ──── Header ────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(
                  Icons.cloud_done_outlined,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'النسخ الاحتياطي السحابي',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.backups.isEmpty
                          ? 'لا توجد نسخ بعد'
                          : '${state.backups.length} نسخة • ${_formatBytes(totalSize)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // ──── Last Backup Info ────
          if (lastBackup != null)
            _buildLastBackupInfo(context, scheme, lastBackup)
          else
            _buildEmptyState(context, scheme),

          const SizedBox(height: AppSizes.spaceMd),

          // ──── Actions ────
          if (isNarrow)
            Column(
              children: [
                _buildCloudButton(context, scheme, state.isCreating),
                const SizedBox(height: AppSizes.spaceSm),
                _buildLocalButton(context, scheme, state.isCreating),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildCloudButton(
                    context,
                    scheme,
                    state.isCreating,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: _buildLocalButton(
                    context,
                    scheme,
                    state.isCreating,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LAST BACKUP INFO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLastBackupInfo(
    BuildContext context,
    ColorScheme scheme,
    BackupFile backup,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: AppSizes.iconSm,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آخر نسخة',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(backup.createdAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSizes.spaceSm,
              vertical: AppSizes.spaceXs,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Text(
              backup.sizeFormatted,
              style: TextStyle(
                fontSize: 11,
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: AppSizes.iconSm,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'أنشئ أول نسخة احتياطية لحماية بياناتك',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUTTONS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCloudButton(
    BuildContext context,
    ColorScheme scheme,
    bool isLoading,
  ) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onCreateCloud,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
              ),
            )
          : const Icon(Icons.cloud_upload_outlined, size: 18),
      label: Text(isLoading ? 'جارٍ الإنشاء...' : 'نسخة سحابية'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeightMd),
      ),
    );
  }

  Widget _buildLocalButton(
    BuildContext context,
    ColorScheme scheme,
    bool isLoading,
  ) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onCreateLocal,
      icon: const Icon(Icons.phone_android, size: 18),
      label: const Text('نسخة محلية'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSizes.buttonHeightMd),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    return '${d.day}/${d.month}/${d.year}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
