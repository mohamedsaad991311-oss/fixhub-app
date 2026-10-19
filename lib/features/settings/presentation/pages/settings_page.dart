// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/settings_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/app_settings.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

/// ═══════════════════════════════════════════════════════════════
/// SettingsPage — صفحة الإعدادات الرئيسية
/// ═══════════════════════════════════════════════════════════════
///
/// أقسام:
/// - الورشة (معلومات + واتساب)
/// - المظهر (ثيم + لغة)
/// - الأمان (PIN + بصمة)
/// - البيانات (نسخ + مزامنة)
/// - الحساب (اشتراك + حول)
/// - تسجيل الخروج
///
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: false,
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
                  // ──── Header ────
                  settingsAsync.when(
                    data: (settings) => _buildHeader(context, settings, scheme),
                    loading: () => _buildHeaderSkeleton(scheme),
                    error: (_, __) => _buildHeaderSkeleton(scheme),
                  ),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ═══ قسم الورشة ═══
                  SettingsSection(
                    title: 'الورشة',
                    icon: Icons.store_outlined,
                    children: [
                      SettingsTile(
                        icon: Icons.mail_outline,
                        title: 'دعوات الموظفين',
                        subtitle: 'إدارة دعوات الانضمام للورشة',
                        onTap: () => context.push('/invitations'),
                      ),
                      SettingsTile(
                        icon: Icons.store,
                        title: 'معلومات الورشة',
                        subtitle: 'الاسم، العنوان، الشعار',
                        onTap: () => context.push(RouteNames.shopInfo),
                      ),
                      SettingsTile(
                        icon: Icons.chat,
                        title: 'إعدادات الواتساب',
                        subtitle: 'الرقم وقوالب الرسائل',
                        onTap: () => context.push(RouteNames.whatsappSettings),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spaceMdLg),

                  // ═══ قسم المظهر ═══
                  SettingsSection(
                    title: 'المظهر',
                    icon: Icons.palette_outlined,
                    children: [
                      SettingsTile(
                        icon: Icons.color_lens_outlined,
                        title: 'الثيم والمظهر',
                        subtitle: '5 ثيمات، وضع فاتح/داكن',
                        onTap: () => context.push(RouteNames.themeSettings),
                      ),
                      SettingsTile(
                        icon: Icons.language,
                        title: 'اللغة',
                        subtitle: 'العربية / English',
                        onTap: () => context.push(RouteNames.languageSettings),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spaceMdLg),

                  // ═══ قسم الأمان ═══
                  SettingsSection(
                    title: 'الأمان',
                    icon: Icons.shield_outlined,
                    children: [
                      SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'الأمان والخصوصية',
                        subtitle: 'قفل PIN، البصمة',
                        onTap: () => context.push(RouteNames.securitySettings),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spaceMdLg),

                  // ═══ قسم البيانات ═══
                  SettingsSection(
                    title: 'البيانات',
                    icon: Icons.cloud_outlined,
                    children: [
                      SettingsTile(
                        icon: Icons.backup_outlined,
                        title: 'النسخ الاحتياطي',
                        subtitle: 'نسخ سحابية ومحلية',
                        onTap: () => context.push(RouteNames.backupSettings),
                      ),
                      SettingsTile(
                        icon: Icons.cloud_sync_outlined,
                        title: 'المزامنة السحابية',
                        onTap: () => context.push(RouteNames.cloudSync),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.spaceMdLg),

                  // ═══ قسم الأدمن (يظهر بس لو المستخدم أدمن) ═══
                  if (user?.isAdmin ?? false)
                    Column(
                      children: [
                        SettingsSection(
                          title: 'الأدمن',
                          icon: Icons.admin_panel_settings,
                          children: [
                            SettingsTile(
                              icon: Icons.dashboard,
                              title: 'لوحة التحكم',
                              subtitle: 'إدارة الورش والطلبات',
                              onTap: () => context.push('/admin'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.spaceMdLg),
                      ],
                    ),

                  const SizedBox(height: AppSizes.spaceMdLg),

                  // ═══ تسجيل الخروج ═══
                  SettingsSection(
                    showDividers: false,
                    children: [
                      SettingsTile(
                        icon: Icons.logout,
                        title: 'تسجيل الخروج',
                        isDestructive: true,
                        showChevron: false,
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ],
                  ),

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
  //  HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(
    BuildContext context,
    AppSettings settings,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shopName = settings.shopName?.trim();
    final shopPhone = settings.shopPhone?.trim();

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            scheme.primaryContainer.withValues(
              alpha: isDark ? 0.15 : 0.08,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Row(
        children: [
          // ──── Logo / Icon ────
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.3),
                width: AppSizes.borderNormal,
              ),
            ),
            child: Center(
              child: settings.shopLogoUrl != null &&
                      settings.shopLogoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: Image.network(
                        settings.shopLogoUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.store,
                          size: 28,
                          color: scheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.store,
                      size: 28,
                      color: scheme.primary,
                    ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),
          // ──── Info ────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shopName?.isNotEmpty == true
                      ? shopName!
                      : 'اسم الورشة غير محدد',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shopPhone?.isNotEmpty == true
                      ? shopPhone!
                      : 'اضغط لتحديث بيانات الورشة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // ──── Edit ────
          IconButton(
            icon: Icon(Icons.edit_outlined, color: scheme.primary),
            tooltip: 'تعديل',
            onPressed: () => context.push(RouteNames.shopInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(ColorScheme scheme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LOGOUT
  // ═══════════════════════════════════════════════════════════════

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.logout,
          color: Theme.of(ctx).colorScheme.error,
          size: 40,
        ),
        title: const Text('تسجيل الخروج'),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟\n'
          'ستحتاج لتسجيل الدخول مرة أخرى للوصول لبياناتك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(authProvider.notifier).signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسجيل الخروج: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
