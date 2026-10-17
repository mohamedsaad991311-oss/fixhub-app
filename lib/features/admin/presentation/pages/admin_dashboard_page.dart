// lib/features/admin/presentation/pages/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../../core/services/admin_service.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_tenant_card.dart';
import '../widgets/device_reset_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// AdminDashboardPage — لوحة الأدمن
/// ═══════════════════════════════════════════════════════════════
///
/// - إحصائيات عامة (ورش، موظفين، طلبات)
/// - 3 تابات: الورش، الطلبات المعلقة، الموظفين
///
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(adminProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  أفعال
  // ═══════════════════════════════════════════════════════════════

  Future<void> _toggleTenant(String tenantId, bool active) async {
    setState(() => _processingId = tenantId);

    final ok = await ref
        .read(adminProvider.notifier)
        .toggleTenantActive(tenantId, active);

    if (!mounted) return;
    setState(() => _processingId = null);

    _showSnack(
      ok
          ? (active ? 'تم تفعيل الورشة' : 'تم تعطيل الورشة')
          : 'فشل تحديث حالة الورشة',
      isError: !ok,
    );
    ref.read(adminProvider.notifier).clearMessages();
  }

  Future<void> _approveReset(DeviceResetRequest request) async {
    final confirmed = await _confirmDialog(
      title: 'الموافقة على إعادة التعيين',
      message:
          'سيتم حذف الأجهزة المرتبطة بالمستخدم، ويمكنه تسجيل الدخول من جهاز جديد.',
      confirmText: 'موافقة',
      isDestructive: false,
    );
    if (confirmed != true) return;

    setState(() => _processingId = request.id);

    final ok = await ref.read(adminProvider.notifier).approveReset(request.id);

    if (!mounted) return;
    setState(() => _processingId = null);

    _showSnack(
      ok ? 'تمت الموافقة' : 'فشل الموافقة',
      isError: !ok,
    );
    ref.read(adminProvider.notifier).clearMessages();
  }

  Future<void> _rejectReset(DeviceResetRequest request) async {
    final confirmed = await _confirmDialog(
      title: 'رفض الطلب',
      message: 'هل أنت متأكد من رفض طلب إعادة تعيين الجهاز؟',
      confirmText: 'رفض',
      isDestructive: true,
    );
    if (confirmed != true) return;

    setState(() => _processingId = request.id);

    final ok = await ref.read(adminProvider.notifier).rejectReset(request.id);

    if (!mounted) return;
    setState(() => _processingId = null);

    _showSnack(
      ok ? 'تم الرفض' : 'فشل الرفض',
      isError: !ok,
    );
    ref.read(adminProvider.notifier).clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  بناء الصفحة
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الأدمن'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(adminProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(
              text: 'الورش',
              icon: Icon(Icons.store, size: 18),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pending_actions, size: 18),
                  const SizedBox(width: 4),
                  const Text('الطلبات'),
                  if (state.pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${state.pendingCount}',
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(
              text: 'الموظفين',
              icon: Icon(Icons.people_outline, size: 18),
            ),
          ],
        ),
      ),
      body: state.isLoading && state.tenants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ─── الإحصائيات ───
                Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceMd),
                  child: _buildStatsRow(context, state, scheme),
                ),

                // ─── التابات ───
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTenantsTab(state, scheme),
                      _buildRequestsTab(state, scheme),
                      _buildStaffTab(state, scheme),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  بطاقات الإحصائيات
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsRow(
    BuildContext context,
    AdminState state,
    ColorScheme scheme,
  ) {
    final stats = state.stats;

    final items = [
      _StatItem(
        icon: Icons.store,
        label: 'إجمالي الورش',
        value: '${stats.totalTenants}',
        color: scheme.primary,
      ),
      _StatItem(
        icon: Icons.check_circle_outline,
        label: 'الورش النشطة',
        value: '${stats.activeTenants}',
        color: const Color(0xFF10B981),
      ),
      _StatItem(
        icon: Icons.people_outline,
        label: 'الموظفين',
        value: '${stats.totalStaff}',
        color: const Color(0xFF3B82F6),
      ),
      _StatItem(
        icon: Icons.pending_actions,
        label: 'طلبات معلقة',
        value: '${stats.pendingDeviceResets}',
        color: const Color(0xFFF59E0B),
      ),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildStatCard(item, scheme),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatCard(_StatItem item, ColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: item.color.withValues(alpha: 0.3),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        children: [
          Icon(item.icon, color: item.color, size: AppSizes.iconSm),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: item.color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  تاب الورش
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTenantsTab(AdminState state, ColorScheme scheme) {
    if (state.tenants.isEmpty) {
      return _buildEmpty(
        icon: Icons.store_outlined,
        title: 'لا توجد ورش',
        subtitle: 'لم يتم تسجيل أي ورشة بعد',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        itemCount: state.tenants.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, index) {
          final tenant = state.tenants[index];
          final staffCount =
              state.allStaff.where((s) => s.tenantId == tenant.id).length;

          return AdminTenantCard(
            tenant: tenant,
            staffCount: staffCount,
            isBusy: _processingId == tenant.id,
            onToggleActive: (v) => _toggleTenant(tenant.id, v),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  تاب الطلبات
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRequestsTab(AdminState state, ColorScheme scheme) {
    if (state.requests.isEmpty) {
      return _buildEmpty(
        icon: Icons.inbox_outlined,
        title: 'لا توجد طلبات',
        subtitle: 'ستظهر هنا طلبات إعادة تعيين الأجهزة',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        itemCount: state.requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, index) {
          final request = state.requests[index];

          // ابحث عن اسم المستخدم والورشة
          final user = state.allStaff
              .where((s) => s.userId == request.userId)
              .firstOrNull;
          final tenant =
              state.tenants.where((t) => t.id == request.tenantId).firstOrNull;

          return DeviceResetCard(
            request: request,
            userName: user?.fullName,
            tenantName: tenant?.name,
            isBusy: _processingId == request.id,
            onApprove: request.isPending ? () => _approveReset(request) : null,
            onReject: request.isPending ? () => _rejectReset(request) : null,
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  تاب الموظفين
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStaffTab(AdminState state, ColorScheme scheme) {
    if (state.allStaff.isEmpty) {
      return _buildEmpty(
        icon: Icons.people_outline,
        title: 'لا يوجد موظفين',
        subtitle: 'لم يسجل أي مستخدم بعد',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        itemCount: state.allStaff.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, index) {
          final staff = state.allStaff[index];
          final tenant =
              state.tenants.where((t) => t.id == staff.tenantId).firstOrNull;

          return Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: isDark
                  ? scheme.surfaceContainerHigh
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
                width: AppSizes.borderNormal,
              ),
            ),
            child: Row(
              children: [
                // الأفاتار
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (staff.isAdmin
                            ? const Color(0xFF8B5CF6)
                            : scheme.primary)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      staff.initials,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: staff.isAdmin
                            ? const Color(0xFF8B5CF6)
                            : scheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSmMd),

                // الاسم + الإيميل + الورشة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              staff.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          if (staff.isAdmin) ...[
                            const SizedBox(width: AppSizes.spaceXs),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                              ),
                              child: const Text(
                                'أدمن',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        staff.phone ?? staff.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (tenant != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${tenant.name} • ${staff.role.labelAr}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  حالة فارغة
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSizes.iconHuge,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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

// ═══════════════════════════════════════════════════════════════
//  عنصر إحصائية
// ═══════════════════════════════════════════════════════════════

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}
