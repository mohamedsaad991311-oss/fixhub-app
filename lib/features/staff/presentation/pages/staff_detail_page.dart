// lib/features/staff/presentation/pages/staff_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/data/models/app_user.dart' show UserRoleX;
import '../../data/models/staff_member.dart';
import '../providers/staff_detail_provider.dart';
import '../widgets/role_badge.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffDetailPage — صفحة تفاصيل موظف
/// ═══════════════════════════════════════════════════════════
class StaffDetailPage extends ConsumerWidget {
  const StaffDetailPage({super.key, required this.staffId});

  final String staffId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(staffDetailProvider(staffId));

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          state.member?.displayName() ?? 'تفاصيل الموظف',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (state.member != null)
            IconButton(
              tooltip: 'تعديل',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                RouteNames.staffEdit,
                extra: state.member,
              ),
            ),
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(staffDetailProvider(staffId).notifier).refresh(),
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    StaffDetailState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasMember) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: scheme.error),
              const SizedBox(height: AppSizes.spaceMd),
              Text(
                state.errorMessage ?? 'خطأ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.onSurface),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(staffDetailProvider(staffId).notifier).load(),
                icon: const Icon(Icons.refresh),
                label: const Text('حاول تاني'),
              ),
            ],
          ),
        ),
      );
    }

    final member = state.member;
    if (member == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(staffDetailProvider(staffId).notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Hero card ───
            _HeroCard(member: member),

            const SizedBox(height: AppSizes.spaceMd),

            // ─── Contact info ───
            _Section(
              icon: Icons.contact_phone_outlined,
              title: 'معلومات التواصل',
              rows: [
                if (member.phone != null)
                  _Row(
                    label: 'التليفون',
                    value: member.phone!,
                    ltr: true,
                  ),
                if (member.email != null)
                  _Row(
                    label: 'الإيميل',
                    value: member.email!,
                    ltr: true,
                  ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── Job info ───
            _Section(
              icon: Icons.work_outline,
              title: 'معلومات الوظيفة',
              rows: [
                _Row(label: 'الدور', value: member.role.labelAr),
                if (member.hireDate != null)
                  _Row(
                    label: 'تاريخ التعيين',
                    value: _fmtDate(member.hireDate!),
                  ),
                _Row(
                  label: 'سنوات الخدمة',
                  value: '${member.yearsOfService} سنة',
                ),
                if (member.salary != null && member.salary! > 0)
                  _Row(
                    label: 'الراتب',
                    value: CurrencyFormatter.format(member.salary),
                  ),
                _Row(
                  label: 'الحالة',
                  value: member.isActive ? 'نشط' : 'معطّل',
                ),
                _Row(
                  label: 'الحساب',
                  value: member.hasAccount ? 'مرتبط بحساب ✓' : 'بدون حساب',
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── Permissions ───
            _PermissionsSection(member: member),

            // ─── Notes ───
            if (member.notes != null && member.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spaceSmMd),
              _Section(
                icon: Icons.notes_outlined,
                title: 'ملاحظات',
                rows: [
                  _Row(label: 'ملاحظات', value: member.notes!),
                ],
              ),
            ],

            const SizedBox(height: AppSizes.spaceLg),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════
//  HERO CARD
// ═══════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.member});

  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            alignment: Alignment.center,
            child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    child: Image.network(
                      member.avatarUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        member.initials,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  )
                : Text(
                    member.initials,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
          ),
          const SizedBox(width: AppSizes.spaceSmMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  member.displayName(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                RoleBadge(role: member.role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SECTION
// ═══════════════════════════════════════════════════════════

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              value,
              textDirection: ltr ? TextDirection.ltr : null,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PERMISSIONS SECTION
// ═══════════════════════════════════════════════════════════

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({required this.member});

  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = member.permissions;

    final items = <_PermissionItem>[
      _PermissionItem('إدارة الإيصالات', p.canManageReceipts),
      _PermissionItem('إدارة المخزون', p.canManageInventory),
      _PermissionItem('إدارة الموردين', p.canManageSuppliers),
      _PermissionItem('إدارة المصروفات', p.canManageExpenses),
      _PermissionItem('عرض التقارير', p.canViewReports),
      _PermissionItem('إدارة الموظفين', p.canManageStaff),
      _PermissionItem('إدارة الإعدادات', p.canManageSettings),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_outlined,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                'الصلاحيات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              final color = item.enabled
                  ? const Color(0xFF10B981)
                  : scheme.onSurfaceVariant;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.enabled
                          ? Icons.check_circle
                          : Icons.remove_circle_outline,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem {
  final String label;
  final bool enabled;
  const _PermissionItem(this.label, this.enabled);
}
