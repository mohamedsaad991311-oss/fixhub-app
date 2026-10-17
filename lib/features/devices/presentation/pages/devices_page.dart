// lib/features/devices/presentation/pages/devices_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/active_device.dart';
import '../providers/devices_provider.dart';
import '../widgets/device_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// DevicesPage — إدارة الأجهزة المرتبطة بالحساب
/// ═══════════════════════════════════════════════════════════════
///
/// - عرض كل الأجهزة (أجهزة الورشة لو أدمن، أو أجهزة المستخدم)
/// - الجهاز الحالي معلّم
/// - إلغاء تفعيل الأجهزة الأخرى (للأدمن)
/// - زر "طلب إعادة تعيين" لو المستخدم عايز يغير الجهاز
///
class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  String? _revokingId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(devicesProvider.notifier).load();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  أفعال
  // ═══════════════════════════════════════════════════════════════

  Future<void> _revoke(ActiveDevice device) async {
    final confirmed = await _confirmDialog(
      title: 'إلغاء تفعيل الجهاز',
      message: 'هل تريد إلغاء تفعيل "${device.displayName}"؟\n\n'
          'لن يتمكن المستخدم من تسجيل الدخول من هذا الجهاز بعد الآن.',
      confirmText: 'إلغاء التفعيل',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _revokingId = device.id);

    final ok = await ref.read(devicesProvider.notifier).revokeDevice(device.id);

    if (!mounted) return;
    setState(() => _revokingId = null);

    _showSnack(
      ok ? 'تم إلغاء تفعيل الجهاز' : 'فشل إلغاء التفعيل',
      isError: !ok,
    );
    ref.read(devicesProvider.notifier).clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  بناء الصفحة
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(devicesProvider);
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;
    final scheme = Theme.of(context).colorScheme;

    // هل المستخدم أدمن (owner/manager)؟
    final isTenantAdmin = user?.isTenantAdmin == true || user?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأجهزة المرتبطة'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(devicesProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(devicesProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

            // حالة التحميل الأولي
            if (state.isLoading && state.devices.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

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
                    // ─── إحصائيات سريعة ───
                    _buildStatsCard(context, state, scheme),

                    const SizedBox(height: AppSizes.spaceLg),

                    // ─── زر "طلب إعادة تعيين" ───
                    _buildResetRequestButton(context, scheme),

                    const SizedBox(height: AppSizes.spaceLg),

                    // ─── قائمة الأجهزة ───
                    if (state.devices.isEmpty)
                      _buildEmptyState(context, scheme)
                    else
                      ...state.devices.map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.spaceSmMd,
                          ),
                          child: DeviceCard(
                            device: device,
                            isCurrent: device.isCurrentDevice(
                              state.currentDeviceId ?? '',
                            ),
                            canRevoke: isTenantAdmin,
                            isBusy: _revokingId == device.id,
                            onRevoke: () => _revoke(device),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSizes.spaceXl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  إحصائيات
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsCard(
    BuildContext context,
    DevicesState state,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
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
          // إجمالي
          Expanded(
            child: _statItem(
              context,
              icon: Icons.devices_other,
              label: 'إجمالي',
              value: '${state.devices.length}',
              color: scheme.primary,
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          // نشط
          Expanded(
            child: _statItem(
              context,
              icon: Icons.check_circle_outline,
              label: 'نشط',
              value: '${state.activeCount}',
              color: const Color(0xFF10B981),
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          // موقوف
          Expanded(
            child: _statItem(
              context,
              icon: Icons.block,
              label: 'موقوف',
              value: '${state.devices.length - state.activeCount}',
              color: const Color(0xFFEF4444),
              scheme: scheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ColorScheme scheme,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSizes.iconSm),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  زر طلب إعادة تعيين
  // ═══════════════════════════════════════════════════════════════

  Widget _buildResetRequestButton(
    BuildContext context,
    ColorScheme scheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: scheme.primary,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'تغيير الجهاز؟ اطلب إعادة تعيين',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () => context.push(RouteNames.deviceResetRequest),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('اطلب الآن'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSizes.spaceSmMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  حالة فارغة
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context, ColorScheme scheme) {
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
            Icons.devices_other,
            size: AppSizes.iconHuge,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            'لا توجد أجهزة مرتبطة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سيظهر هنا أي جهاز يتم تسجيل الدخول منه',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  مساعدات
  // ═══════════════════════════════════════════════════════════════

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(
            isDestructive ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isDestructive ? scheme.error : scheme.primary,
            size: 40,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: isDestructive ? scheme.error : scheme.primary,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
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
}
