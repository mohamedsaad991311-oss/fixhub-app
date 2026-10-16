// lib/features/settings/presentation/pages/backup_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../cloud_sync/presentation/providers/cloud_sync_provider.dart';
import '../../../cloud_sync/presentation/widgets/backup_status_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// BackupSettingsPage — إعدادات النسخ الاحتياطي
/// ═══════════════════════════════════════════════════════════════
///
/// - كارت الحالة (آخر نسخة + إنشاء)
/// - إعدادات المزامنة التلقائية
/// - روابط سريعة (عرض كل النسخ، استرجاع)
///
class BackupSettingsPage extends ConsumerStatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  ConsumerState<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends ConsumerState<BackupSettingsPage> {
  // إعدادات محلية (مؤقتة — Phase 11 هتحفظها في SharedPreferences)
  bool _autoBackupEnabled = false;
  bool _wifiOnly = true;
  String _autoBackupFrequency = 'weekly'; // daily / weekly / monthly

  @override
  void initState() {
    super.initState();
    // تحميل قائمة النسخ
    Future.microtask(() {
      ref.read(cloudSyncProvider.notifier).loadBackups();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  ACTIONS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _createCloud() async {
    final notifier = ref.read(cloudSyncProvider.notifier);
    final ok = await notifier.createBackup();
    if (!mounted) return;
    _showSnack(
      ok ? 'تم إنشاء النسخة السحابية ✅' : 'فشل إنشاء النسخة',
      isError: !ok,
    );
    notifier.clearMessages();
  }

  Future<void> _createLocal() async {
    final notifier = ref.read(cloudSyncProvider.notifier);
    final file = await notifier.createLocalBackup();
    if (!mounted) return;

    if (file != null) {
      _showSnack('تم إنشاء نسخة محلية', isError: false);
    } else {
      _showSnack('فشل إنشاء النسخة المحلية', isError: true);
    }
    notifier.clearMessages();
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: isError ? scheme.error : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 3),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ═══ Status Card ═══
                  BackupStatusCard(
                    onCreateCloud: state.isCreating ? () {} : _createCloud,
                    onCreateLocal: state.isCreating ? () {} : _createLocal,
                  ),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ Auto Backup Settings ═══
                  _buildSectionTitle(
                    context,
                    'المزامنة التلقائية',
                    Icons.sync_outlined,
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  _buildAutoBackupCard(context, scheme),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ Quick Links ═══
                  _buildSectionTitle(
                    context,
                    'إجراءات سريعة',
                    Icons.flash_on_outlined,
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  _buildQuickLinksCard(context, scheme),

                  const SizedBox(height: AppSizes.spaceXl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  AUTO BACKUP CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAutoBackupCard(BuildContext context, ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _autoBackupEnabled,
            onChanged: (v) => setState(() => _autoBackupEnabled = v),
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                Icons.sync,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
            ),
            title: const Text(
              'تفعيل النسخ التلقائي',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'إنشاء نسخة تلقائياً حسب الجدول',
              style: TextStyle(fontSize: 12),
            ),
          ),
          if (_autoBackupEnabled) ...[
            Divider(
              height: 1,
              indent: AppSizes.spaceLg + AppSizes.spaceMd,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            // Frequency
            ListTile(
              leading: const SizedBox(width: 40),
              title: const Text(
                'التكرار',
                style: TextStyle(fontSize: 14),
              ),
              trailing: DropdownButton<String>(
                value: _autoBackupFrequency,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text('يومياً'),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text('أسبوعياً'),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text('شهرياً'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _autoBackupFrequency = v);
                  }
                },
              ),
            ),
            Divider(
              height: 1,
              indent: AppSizes.spaceLg + AppSizes.spaceMd,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            // WiFi only
            SwitchListTile(
              value: _wifiOnly,
              onChanged: (v) => setState(() => _wifiOnly = v),
              secondary: const SizedBox(width: 40),
              title: const Text(
                'WiFi فقط',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                'لتوفير بيانات الجوال',
                style: TextStyle(fontSize: 12),
              ),
            ),
            // Note
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSizes.spaceSmMd,
                0,
                AppSizes.spaceSmMd,
                AppSizes.spaceSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSizes.spaceXs),
                  Expanded(
                    child: Text(
                      'المزامنة التلقائية ميزة قادمة في تحديث قريب',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  QUICK LINKS CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuickLinksCard(BuildContext context, ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Icon(
                Icons.cloud_queue,
                size: AppSizes.iconSm,
                color: scheme.primary,
              ),
            ),
            title: const Text(
              'عرض كل النسخ السحابية',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'إدارة، تحميل، استرجاع، حذف',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(
              Icons.chevron_left,
              color: scheme.onSurfaceVariant,
            ),
            onTap: () => context.push(RouteNames.cloudSync),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconXs, color: scheme.primary),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
