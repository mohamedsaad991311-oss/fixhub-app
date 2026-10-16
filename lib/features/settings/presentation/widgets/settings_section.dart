// lib/features/settings/presentation/widgets/settings_section.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════════
/// SettingsSection — قسم من الإعدادات
/// ═══════════════════════════════════════════════════════════════
///
/// - عنوان القسم (اختياري)
/// - Card يغلّف مجموعة من SettingsTile
/// - فواصل بين العناصر (اختياري)
///
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    this.title,
    this.icon,
    this.children = const [],
    this.showDividers = true,
    this.padding,
  });

  /// عنوان القسم
  final String? title;

  /// أيقونة صغيرة بجانب العنوان
  final IconData? icon;

  /// الـ tiles داخل القسم
  final List<Widget> children;

  /// إظهار فواصل بين الـ tiles
  final bool showDividers;

  /// padding مخصص للـ Card
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ──── Title ────
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSizes.spaceSm,
              end: AppSizes.spaceSm,
              bottom: AppSizes.spaceSm,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: AppSizes.iconXs,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSizes.spaceXs),
                ],
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

        // ──── Card ────
        Container(
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
          padding: padding ?? const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(scheme),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren(ColorScheme scheme) {
    if (!showDividers) return children;

    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: AppSizes.spaceLg + AppSizes.spaceSmMd,
            endIndent: AppSizes.spaceSmMd,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        );
      }
    }
    return result;
  }
}
