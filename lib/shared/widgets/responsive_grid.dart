// lib/shared/widgets/responsive_grid.dart

import 'package:flutter/material.dart';

import '../../core/constants/app_breakpoints.dart';
import '../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════
/// ResponsiveGrid — Grid ذكي حسب حجم الشاشة
/// ═══════════════════════════════════════════════════════════
///
/// - Mobile  : 2 أعمدة (افتراضي)
/// - Tablet  : 3 أعمدة
/// - Desktop : 4 أعمدة
/// - Wide    : 5 أعمدة
///
/// الاستخدام:
/// ```dart
/// ResponsiveGrid(
///   children: [Card1, Card2, Card3],
/// )
/// ```
///
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  /// عدد الأعمدة (اختياري — لو مش محدد، بيتحدد تلقائياً)
  final int? crossAxisCount;

  /// عدد الأعمدة حسب كل جهاز
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int wideColumns;
  final int ultraWideColumns;

  /// نسبة العرض للارتفاع
  final double? childAspectRatio;

  /// spacing بين العناصر
  final double? spacing;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  /// padding
  final EdgeInsets? padding;

  /// scroll direction
  final Axis scrollDirection;

  /// shrinkWrap (لو جوه ListView)
  final bool shrinkWrap;

  /// physics
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.wideColumns = 5,
    this.ultraWideColumns = 6,
    this.childAspectRatio,
    this.spacing,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColumns =
        crossAxisCount ?? _getColumnsForDevice(context);

    return GridView.builder(
      padding: padding,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumns,
        mainAxisSpacing: mainAxisSpacing ?? spacing ?? AppSizes.spaceMd,
        crossAxisSpacing: crossAxisSpacing ?? spacing ?? AppSizes.spaceMd,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  int _getColumnsForDevice(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return mobileColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.desktop:
        return desktopColumns;
      case DeviceType.wide:
        return wideColumns;
      case DeviceType.ultraWide:
        return ultraWideColumns;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ResponsiveSliverGrid — نسخة Sliver (جوه CustomScrollView)
/// ═══════════════════════════════════════════════════════════
///
/// الاستخدام:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverAppBar(...),
///     ResponsiveSliverGrid(
///       children: [Card1, Card2],
///     ),
///   ],
/// )
/// ```
///
class ResponsiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int wideColumns;
  final int ultraWideColumns;
  final double? childAspectRatio;
  final double? spacing;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const ResponsiveSliverGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.wideColumns = 5,
    this.ultraWideColumns = 6,
    this.childAspectRatio,
    this.spacing,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColumns =
        crossAxisCount ?? _getColumnsForDevice(context);

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumns,
        mainAxisSpacing: mainAxisSpacing ?? spacing ?? AppSizes.spaceMd,
        crossAxisSpacing: crossAxisSpacing ?? spacing ?? AppSizes.spaceMd,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  int _getColumnsForDevice(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return mobileColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.desktop:
        return desktopColumns;
      case DeviceType.wide:
        return wideColumns;
      case DeviceType.ultraWide:
        return ultraWideColumns;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ResponsiveCardGrid — Grid مخصص للبطاقات
/// ═══════════════════════════════════════════════════════════
///
/// بيستخدم aspect ratio مناسب للبطاقات (16:9 أو 1:1).
///
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double spacing;
  final EdgeInsets? padding;

  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.5,
    this.spacing = AppSizes.spaceMd,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      padding: padding,
      childAspectRatio: childAspectRatio,
      spacing: spacing,
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 3,
      wideColumns: 4,
      ultraWideColumns: 4,
      children: children,
    );
  }
}