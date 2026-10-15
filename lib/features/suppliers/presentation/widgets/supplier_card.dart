// lib/features/suppliers/presentation/widgets/supplier_card.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierCard — كارت مورد في قائمة الموردين
/// ═══════════════════════════════════════════════════════════
class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onLongPress,
  });

  final Supplier supplier;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balanceColor = _balanceColor(scheme);

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
              color: supplier.balance.abs() > 0
                  ? balanceColor.withValues(alpha: 0.3)
                  : scheme.outlineVariant.withValues(alpha: 0.5),
              width: supplier.balance.abs() > 0 ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: avatar + name + status ───
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials(supplier.name),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),

                    // Name + company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  supplier.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              if (!supplier.isActive)
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
                          if (supplier.contactPerson != null &&
                              supplier.contactPerson!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              supplier.contactPerson!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
                    if (supplier.phone != null && supplier.phone!.isNotEmpty)
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        value: supplier.phone!,
                        ltr: true,
                        scheme: scheme,
                      ),
                    if (supplier.email != null &&
                        supplier.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _ContactRow(
                        icon: Icons.email_outlined,
                        value: supplier.email!,
                        ltr: true,
                        scheme: scheme,
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Footer: balance ───
              if (supplier.balance.abs() > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceSmMd,
                    vertical: AppSizes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    border: Border(
                      top: BorderSide(
                        color: balanceColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        supplier.balance > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 14,
                        color: balanceColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.balance > 0 ? 'مستحق للمورد' : 'دفعة مقدمة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: balanceColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.format(supplier.balance.abs()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: balanceColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceSmMd,
                    vertical: AppSizes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'لا يوجد رصيد',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// لون الرصيد
  Color _balanceColor(ColorScheme scheme) {
    if (supplier.balance > 0) {
      // مدين (مستحق للمورد)
      return const Color(0xFFEF4444);
    }
    if (supplier.balance < 0) {
      // دائن (دفعة مقدمة)
      return const Color(0xFF10B981);
    }
    return scheme.onSurfaceVariant;
  }

  /// الأحرف الأولى من الاسم
  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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
