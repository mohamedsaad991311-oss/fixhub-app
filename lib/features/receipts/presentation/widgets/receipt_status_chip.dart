// lib/features/receipts/presentation/widgets/receipt_status_chip.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceiptStatusChip — Badge للحالة
/// ═══════════════════════════════════════════════════════════
///
/// - Variants: filled (default), outlined, soft
/// - Sizes: small, medium, large
/// - Optional: icon
///
class ReceiptStatusChip extends StatelessWidget {
  const ReceiptStatusChip({
    super.key,
    required this.status,
    this.variant = StatusChipVariant.soft,
    this.size = StatusChipSize.medium,
    this.showIcon = true,
    this.onTap,
  });

  final ReceiptStatus status;
  final StatusChipVariant variant;
  final StatusChipSize size;
  final bool showIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final label = status.labelAr;

    // حجم
    final (double fontSize, double iconSize, double padH, double padV) =
        switch (size) {
      StatusChipSize.small => (10, 12, 6, 2),
      StatusChipSize.medium => (11, 14, 8, 4),
      StatusChipSize.large => (13, 18, 12, 6),
    };

    // ألوان حسب الـ variant
    final (Color bg, Color fg, Color? border) = switch (variant) {
      StatusChipVariant.filled => (color, Colors.white, null),
      StatusChipVariant.outlined => (Colors.transparent, color, color),
      StatusChipVariant.soft => (
          color.withValues(alpha: 0.15),
          color,
          null,
        ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: padH,
            vertical: padV,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            border: border != null ? Border.all(color: border, width: 1) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  status.icon,
                  size: iconSize,
                  color: fg,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1.2,
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
//  PRIORITY CHIP
// ═══════════════════════════════════════════════════════════

/// Chip للأولوية
class ReceiptPriorityChip extends StatelessWidget {
  const ReceiptPriorityChip({
    super.key,
    required this.priority,
    this.size = StatusChipSize.medium,
  });

  final ReceiptPriority priority;
  final StatusChipSize size;

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    final label = priority.labelAr;

    final (double fontSize, double padH, double padV) = switch (size) {
      StatusChipSize.small => (10, 6, 2),
      StatusChipSize.medium => (11, 8, 4),
      StatusChipSize.large => (13, 12, 6),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ENUMS
// ═══════════════════════════════════════════════════════════

enum StatusChipVariant { filled, outlined, soft }

enum StatusChipSize { small, medium, large }
