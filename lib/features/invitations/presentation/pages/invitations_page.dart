// lib/features/invitations/presentation/pages/invitations_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/invitations_service.dart';
import '../../data/models/invitation.dart';
import '../providers/invitations_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// InvitationsPage — إدارة دعوات الموظفين
/// ═══════════════════════════════════════════════════════════════
///
/// - عرض قائمة الدعوات مع فلترة حسب الحالة
/// - إنشاء دعوة جديدة (Bottom Sheet)
/// - نسخ رابط الدعوة / إلغاء / حذف
///
class InvitationsPage extends ConsumerStatefulWidget {
  const InvitationsPage({super.key});

  @override
  ConsumerState<InvitationsPage> createState() => _InvitationsPageState();
}

class _InvitationsPageState extends ConsumerState<InvitationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(invitationsProvider.notifier).load();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  إنشاء دعوة
  // ═══════════════════════════════════════════════════════════════

  Future<void> _openCreateSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const _CreateInvitationSheet(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  أفعال الدعوة
  // ═══════════════════════════════════════════════════════════════

  Future<void> _copyLink(Invitation invitation) async {
    final service = ref.read(invitationsServiceProvider);
    final link = service.buildInviteLink(invitation.token);

    await Clipboard.setData(ClipboardData(text: link));

    if (!mounted) return;
    _showSnack('تم نسخ رابط الدعوة', isError: false);
  }

  Future<void> _cancelInvitation(Invitation invitation) async {
    final confirmed = await _confirmDialog(
      title: 'إلغاء الدعوة',
      message: 'هل تريد إلغاء الدعوة إلى "${invitation.target}"؟',
      confirmText: 'إلغاء الدعوة',
      isDestructive: true,
    );
    if (confirmed != true) return;

    final ok = await ref
        .read(invitationsProvider.notifier)
        .cancelInvitation(invitation.id);

    if (!mounted) return;
    _showSnack(
      ok ? 'تم إلغاء الدعوة' : 'فشل الإلغاء',
      isError: !ok,
    );
    ref.read(invitationsProvider.notifier).clearMessages();
  }

  Future<void> _deleteInvitation(Invitation invitation) async {
    final confirmed = await _confirmDialog(
      title: 'حذف الدعوة',
      message: 'هل تريد حذف الدعوة نهائياً؟\n\nلن يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      isDestructive: true,
    );
    if (confirmed != true) return;

    final ok = await ref
        .read(invitationsProvider.notifier)
        .deleteInvitation(invitation.id);

    if (!mounted) return;
    _showSnack(
      ok ? 'تم الحذف' : 'فشل الحذف',
      isError: !ok,
    );
    ref.read(invitationsProvider.notifier).clearMessages();
  }

  // ═══════════════════════════════════════════════════════════════
  //  بناء الصفحة
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invitationsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('دعوات الموظفين'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(invitationsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: state.isProcessing ? null : _openCreateSheet,
        icon: const Icon(Icons.person_add),
        label: const Text('دعوة جديدة'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(invitationsProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

            if (state.isLoading && state.invitations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                padding,
                padding,
                padding,
                padding + 80, // مساحة للـ FAB
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── إحصائيات ───
                    _buildStatsCard(context, state, scheme),
                    const SizedBox(height: AppSizes.spaceLg),

                    // ─── الفلاتر ───
                    _buildFilterChips(context, state, scheme),
                    const SizedBox(height: AppSizes.spaceMd),

                    // ─── القائمة ───
                    if (state.filteredInvitations.isEmpty)
                      _buildEmptyState(context, scheme, state)
                    else
                      ...state.filteredInvitations.map(
                        (invitation) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.spaceSmMd,
                          ),
                          child: _InvitationCard(
                            invitation: invitation,
                            onCopyLink: () => _copyLink(invitation),
                            onCancel: invitation.isPending
                                ? () => _cancelInvitation(invitation)
                                : null,
                            onDelete: () => _deleteInvitation(invitation),
                          ),
                        ),
                      ),
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
    InvitationsState state,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = state.invitations.length;
    final pending = state.invitations.where((i) => i.isPending).length;
    final accepted = state.invitations.where((i) => i.isAccepted).length;

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
          Expanded(
            child: _statItem(
              context,
              icon: Icons.mail_outline,
              label: 'إجمالي',
              value: '$total',
              color: scheme.primary,
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _statItem(
              context,
              icon: Icons.hourglass_top,
              label: 'معلقة',
              value: '$pending',
              color: const Color(0xFFF59E0B),
              scheme: scheme,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Expanded(
            child: _statItem(
              context,
              icon: Icons.check_circle_outline,
              label: 'مقبولة',
              value: '$accepted',
              color: const Color(0xFF10B981),
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
  //  الفلاتر
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterChips(
    BuildContext context,
    InvitationsState state,
    ColorScheme scheme,
  ) {
    final filters = <({String? value, String label, IconData icon})>[
      (value: null, label: 'الكل', icon: Icons.list),
      (value: 'pending', label: 'معلقة', icon: Icons.hourglass_top),
      (value: 'accepted', label: 'مقبولة', icon: Icons.check),
      (value: 'cancelled', label: 'ملغاة', icon: Icons.block),
      (value: 'expired', label: 'منتهية', icon: Icons.timer_off),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.filterStatus == f.value ||
              (f.value == null && state.filterStatus == null);
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              end: AppSizes.spaceXs,
            ),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f.icon,
                    size: 14,
                    color:
                        isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(f.label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                ref.read(invitationsProvider.notifier).setFilter(f.value);
              },
              selectedColor: scheme.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  حالة فارغة
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme scheme,
    InvitationsState state,
  ) {
    final hasFilter = state.filterStatus != null;

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
            hasFilter ? Icons.filter_alt_off : Icons.mail_outline,
            size: AppSizes.iconHuge,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            hasFilter ? 'لا توجد دعوات بهذه الحالة' : 'لا توجد دعوات بعد',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasFilter
                ? 'جرّب فلتراً آخر'
                : 'ابدأ بدعوة أول موظف للانضمام للورشة',
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
  //  حوارات و SnackBar
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
//  كارت الدعوة
// ═══════════════════════════════════════════════════════════════

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.onCopyLink,
    this.onCancel,
    required this.onDelete,
  });

  final Invitation invitation;
  final VoidCallback onCopyLink;
  final VoidCallback? onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون وأيقونة حسب الحالة
    final (statusColor, statusIcon) = _styleForStatus();

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: AppSizes.borderMedium,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceSmMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── الهيدر ───
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.spaceSmMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.target,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            invitation.isEmailInvite
                                ? Icons.email_outlined
                                : Icons.phone_outlined,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            invitation.isEmailInvite
                                ? 'بالبريد الإلكتروني'
                                : 'بالتليفون',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge الحالة
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSizes.spaceSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(
                    invitation.statusLabelAr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── التفاصيل ───
            Container(
              padding: const EdgeInsets.all(AppSizes.spaceSm),
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                children: [
                  _infoRow(
                    context,
                    icon: Icons.badge_outlined,
                    label: 'الدور',
                    value: invitation.roleLabelAr,
                    scheme: scheme,
                  ),
                  if (invitation.fullName != null &&
                      invitation.fullName!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.spaceXs),
                    _infoRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'الاسم',
                      value: invitation.fullName!,
                      scheme: scheme,
                    ),
                  ],
                  const SizedBox(height: AppSizes.spaceXs),
                  _infoRow(
                    context,
                    icon: Icons.access_time,
                    label: 'أُنشئت',
                    value: invitation.relativeCreatedAt,
                    scheme: scheme,
                  ),
                  if (invitation.isPending) ...[
                    const SizedBox(height: AppSizes.spaceXs),
                    _infoRow(
                      context,
                      icon: Icons.timer_outlined,
                      label: 'تنتهي في',
                      value: '${invitation.remainingDays} يوم',
                      scheme: scheme,
                      valueColor: invitation.remainingDays < 2
                          ? const Color(0xFFEF4444)
                          : statusColor,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceSmMd),

            // ─── الأزرار ───
            Row(
              children: [
                // نسخ الرابط (للـ pending فقط)
                if (invitation.isUsable)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopyLink,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('نسخ الرابط'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeightSm + 8,
                        ),
                      ),
                    ),
                  ),
                if (invitation.isUsable && onCancel != null)
                  const SizedBox(width: AppSizes.spaceSm),
                // إلغاء (للـ pending فقط)
                if (invitation.isUsable && onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF59E0B),
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeightSm + 8,
                        ),
                      ),
                    ),
                  ),
                // مساحة
                if (invitation.isUsable && onCancel != null)
                  const SizedBox(width: AppSizes.spaceSm),
                // حذف (دائماً متاح)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('حذف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      minimumSize: const Size.fromHeight(
                        AppSizes.buttonHeightSm + 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  مساعدات
  // ─────────────────────────────────────────────────────────────

  (Color, IconData) _styleForStatus() {
    if (invitation.isAccepted) {
      return (const Color(0xFF10B981), Icons.check_circle_outline);
    }
    if (invitation.isCancelled) {
      return (const Color(0xFF64748B), Icons.block);
    }
    if (invitation.isExpired || invitation.isExpiredByDate) {
      return (const Color(0xFF94A3B8), Icons.timer_off);
    }
    return (const Color(0xFFF59E0B), Icons.hourglass_top);
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme scheme,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSizes.spaceXs),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Bottom Sheet: إنشاء دعوة جديدة
// ═══════════════════════════════════════════════════════════════

class _CreateInvitationSheet extends ConsumerStatefulWidget {
  const _CreateInvitationSheet();

  @override
  ConsumerState<_CreateInvitationSheet> createState() =>
      _CreateInvitationSheetState();
}

class _CreateInvitationSheetState
    extends ConsumerState<_CreateInvitationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _role = 'technician';
  String _contactMethod = 'email'; // email | phone

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isEmail = _contactMethod == 'email';

    final invitation =
        await ref.read(invitationsProvider.notifier).createInvitation(
              role: _role,
              email: isEmail ? _emailCtrl.text.trim() : null,
              phone: !isEmail ? _phoneCtrl.text.trim() : null,
              fullName:
                  _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
            );

    if (!mounted) return;

    if (invitation != null) {
      Navigator.of(context).pop();
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'تم إنشاء الدعوة بنجاح — يمكنك نسخ الرابط',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        );
      debugPrint('Dismissed: ${scheme.primary}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'فشل إنشاء الدعوة',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    ref.read(invitationsProvider.notifier).clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invitationsProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // المقبض
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spaceMd),

                // العنوان
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: scheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSmMd),
                    Text(
                      'دعوة موظف جديد',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceMd),

                // طريقة الاتصال (Segmented)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'email',
                      label: Text('بالبريد'),
                      icon: Icon(Icons.email_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: 'phone',
                      label: Text('بالتليفون'),
                      icon: Icon(Icons.phone_outlined, size: 16),
                    ),
                  ],
                  selected: {_contactMethod},
                  onSelectionChanged: (set) {
                    setState(() => _contactMethod = set.first);
                  },
                ),
                const SizedBox(height: AppSizes.spaceSmMd),

                // الحقل حسب النوع
                if (_contactMethod == 'email')
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'example@domain.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'اكتب البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v.trim())) {
                        return 'البريد الإلكتروني غير صحيح';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم التليفون',
                      hintText: '+201234567890',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'اكتب رقم التليفون';
                      }
                      if (v.trim().length < 10) {
                        return 'رقم التليفون غير صحيح';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // الاسم (اختياري)
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'الاسم (اختياري)',
                    hintText: 'اسم الموظف',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceSmMd),

                // الدور
                DropdownButtonFormField<String>(
                                    initialValue: _role,
                  decoration: InputDecoration(
                    labelText: 'الدور',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'technician',
                      child: Text('فني'),
                    ),
                    DropdownMenuItem(
                      value: 'receptionist',
                      child: Text('موظف استقبال'),
                    ),
                    DropdownMenuItem(
                      value: 'accountant',
                      child: Text('محاسب'),
                    ),
                    DropdownMenuItem(
                      value: 'manager',
                      child: Text('مدير'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _role = v);
                  },
                ),

                const SizedBox(height: AppSizes.spaceLg),

                // زر الإرسال
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.isProcessing ? null : _submit,
                    icon: state.isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      state.isProcessing ? 'جارٍ الإنشاء...' : 'إرسال الدعوة',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        AppSizes.buttonHeightLg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
