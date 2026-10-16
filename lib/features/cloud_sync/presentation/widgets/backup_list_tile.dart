// lib/features/cloud_sync/presentation/widgets/backup_list_tile.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/cloud_sync_service.dart';

/// ═══════════════════════════════════════════════════════════════
/// BackupListTile — عنصر في قائمة النسخ الاحتياطية
/// ═══════════════════════════════════════════════════════════════
///
/// - أيقونة سحابية + اسم النسخة + الحجم + الوقت
/// - قائمة إجراءات: تحميل، استرجاع، حذف
///
class BackupListTile extends StatelessWidget {
  const BackupListTile({
    super.key,
    required this.backup,
    required this.onDownload,
    required this.onRestore,
    required this.onDelete,
    this.isRestoring = false,
    this.isDeleting = false,
  });

  final BackupFile backup;
  final VoidCallback onDownload;
  final VoidCallback onRestore;
  final VoidCallback onDelete;
  final bool isRestoring;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBusy = isRestoring || isDeleting;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          // ──── Icon ────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(
              Icons.cloud_done_outlined,
              color: scheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),

          // ──── Info ────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم الملف (تاريخ فقط — شيلن prefix)
                Text(
                  _displayName(backup.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                // الحجم + الوقت
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatRelativeTime(backup.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    Text(
                      backup.sizeFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSizes.spaceXs),

          // ──── Actions ────
          if (isBusy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: scheme.onSurfaceVariant,
              ),
              tooltip: 'خيارات',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'download':
                    onDownload();
                    break;
                  case 'restore':
                    onRestore();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                // ──── Download / Share ────
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: AppSizes.iconSm,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: AppSizes.spaceSm),
                      const Text('تحميل / مشاركة'),
                    ],
                  ),
                ),
                // ──── Restore ────
                PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(
                        Icons.restore,
                        size: AppSizes.iconSm,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: AppSizes.spaceSm),
                      const Text('استرجاع'),
                    ],
                  ),
                ),
                // ──── Divider ────
                const PopupMenuDivider(),
                // ──── Delete ────
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: AppSizes.iconSm,
                        color: scheme.error,
                      ),
                      const SizedBox(width: AppSizes.spaceSm),
                      Text(
                        'حذف',
                        style: TextStyle(color: scheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// "fixhub_backup_20261017_143022.json"
  /// → "17/10/2026 - 14:30"
  String _displayName(String fileName) {
    try {
      // احذف prefix و .json
      final base = fileName
          .replaceAll('.json', '')
          .replaceFirst('fixhub_backup_', '')
          .replaceFirst('fixhub_local_', '');

      // 20261017_143022
      final parts = base.split('_');
      if (parts.length < 2) return fileName;

      final dateStr = parts[0]; // 20261017
      final timeStr = parts[1]; // 143022

      if (dateStr.length != 8 || timeStr.length < 4) return fileName;

      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(4, 6);
      final day = dateStr.substring(6, 8);
      final hour = timeStr.substring(0, 2);
      final minute = timeStr.substring(2, 4);

      return '$day/$month/$year - $hour:$minute';
    } catch (_) {
      return fileName;
    }
  }

  String _formatRelativeTime(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';

    return '${d.day}/${d.month}/${d.year}';
  }
}
