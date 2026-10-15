// lib/features/staff/presentation/widgets/staff_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/staff_member.dart';
import 'role_badge.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffCard — كارت موظف في قائمة الموظفين
/// ═══════════════════════════════════════════════════════════
class StaffCard extends StatelessWidget {
  const StaffCard({
    super.key,
    required this.member,
    this.onTap,
    this.onLongPress,
  });

  final StaffMember member;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: !member.isActive
                  ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: !member.isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: avatar + name + role ───
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spaceSmMd,
                  AppSizes.spaceSm,
                  AppSizes.spaceSmMd,
                  AppSizes.spaceSm,
                ),
                child: Row(
                  children: [
                    // Avatar
                    _Avatar(member: member, scheme: scheme),
                    const SizedBox(width: AppSizes.spaceSm),

                    // Name + role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  member.displayName(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              if (!member.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSm,
                                    ),
                                  ),
                                  child: const Text(
                                    'معطّل',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              RoleBadge(
                                role: member.role,
                                size: RoleBadgeSize.small,
                              ),
                              if (member.hasAccount) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.verified_user,
                                  size: 12,
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Divider ───
              Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),

              // ─── Body: contact info ───
              Padding(
                padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (member.phone != null && member.phone!.isNotEmpty)
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        value: member.phone!,
                        ltr: true,
                        scheme: scheme,
                      ),
                    if (member.email != null && member.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _ContactRow(
                        icon: Icons.email_outlined,
                        value: member.email!,
                        ltr: true,
                        scheme: scheme,
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Footer: hire info ───
              if (member.hireDate != null || member.salary != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceSmMd,
                    vertical: AppSizes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: Border(
                      top: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (member.hireDate != null) ...[
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'منذ ${member.yearsOfService} سنة',
                          style: TextStyle(
                            fontSize: 10,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (member.salary != null && member.salary! > 0) ...[
                        Icon(
                          Icons.attach_money,
                          size: 12,
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          CurrencyFormatter.format(member.salary),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  AVATAR
// ═══════════════════════════════════════════════════════════

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member, required this.scheme});

  final StaffMember member;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (member.avatarUrl != null && member.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Image.network(
          member.avatarUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text(
        member.initials,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CONTACT ROW
// ═══════════════════════════════════════════════════════════

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    required this.scheme,
    this.ltr = false,
  });

  final IconData icon;
  final String value;
  final ColorScheme scheme;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: ltr ? TextDirection.ltr : null,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
