// lib/features/staff/presentation/widgets/role_badge.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../auth/data/models/app_user.dart' show UserRole, UserRoleX;

/// ═══════════════════════════════════════════════════════════
/// RoleBadge — badge للدور الوظيفي
/// ═══════════════════════════════════════════════════════════
class RoleBadge extends StatelessWidget {
  const RoleBadge({
    super.key,
    required this.role,
    this.size = RoleBadgeSize.medium,
    this.showIcon = true,
  });

  final UserRole role;
  final RoleBadgeSize size;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = _colors(role);

    final (double fontSize, double iconSize, double padH, double padV) =
        switch (size) {
      RoleBadgeSize.small => (10, 12, 6, 2),
      RoleBadgeSize.medium => (11, 14, 8, 4),
      RoleBadgeSize.large => (13, 18, 12, 6),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_icon(role), size: iconSize, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            role.labelAr,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colors(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return (
          const Color(0xFFF59E0B).withValues(alpha: 0.15),
          const Color(0xFFF59E0B),
        );
      case UserRole.manager:
        return (
          const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          const Color(0xFF8B5CF6),
        );
      case UserRole.technician:
        return (
          const Color(0xFF3B82F6).withValues(alpha: 0.15),
          const Color(0xFF3B82F6),
        );
      case UserRole.receptionist:
        return (
          const Color(0xFF10B981).withValues(alpha: 0.15),
          const Color(0xFF10B981),
        );
      case UserRole.accountant:
        return (
          const Color(0xFF06B6D4).withValues(alpha: 0.15),
          const Color(0xFF06B6D4),
        );
    }
  }

  IconData _icon(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Icons.workspace_premium;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.technician:
        return Icons.build;
      case UserRole.receptionist:
        return Icons.support_agent;
      case UserRole.accountant:
        return Icons.calculate;
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  ENUM
// ═══════════════════════════════════════════════════════════

enum RoleBadgeSize { small, medium, large }

// ═══════════════════════════════════════════════════════════
//  ROLE PICKER (chips)
// ═══════════════════════════════════════════════════════════

/// Picker لاختيار الدور (chips)
class RolePicker extends StatelessWidget {
  const RolePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.excludedRoles = const [],
  });

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  final List<UserRole> excludedRoles;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final roles =
        UserRole.values.where((r) => !excludedRoles.contains(r)).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: roles.map((role) {
        final isSelected = role == selected;
        final (bg, fg) = _colors(role);

        return InkWell(
          onTap: () => onChanged(role),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? bg : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              border: Border.all(
                color: isSelected
                    ? fg
                    : scheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon(role),
                  size: 14,
                  color: isSelected ? fg : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  role.labelAr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? fg : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  (Color, Color) _colors(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return (
          const Color(0xFFF59E0B).withValues(alpha: 0.15),
          const Color(0xFFF59E0B),
        );
      case UserRole.manager:
        return (
          const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          const Color(0xFF8B5CF6),
        );
      case UserRole.technician:
        return (
          const Color(0xFF3B82F6).withValues(alpha: 0.15),
          const Color(0xFF3B82F6),
        );
      case UserRole.receptionist:
        return (
          const Color(0xFF10B981).withValues(alpha: 0.15),
          const Color(0xFF10B981),
        );
      case UserRole.accountant:
        return (
          const Color(0xFF06B6D4).withValues(alpha: 0.15),
          const Color(0xFF06B6D4),
        );
    }
  }

  IconData _icon(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Icons.workspace_premium;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.technician:
        return Icons.build;
      case UserRole.receptionist:
        return Icons.support_agent;
      case UserRole.accountant:
        return Icons.calculate;
    }
  }
}
