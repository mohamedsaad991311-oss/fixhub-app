// lib/shared/widgets/responsive_layout.dart

import 'package:flutter/material.dart';

import '../../core/constants/app_breakpoints.dart';

/// ═══════════════════════════════════════════════════════════
/// ResponsiveLayout — يختار Widget حسب حجم الشاشة
/// ═══════════════════════════════════════════════════════════
///
/// الاستخدام:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileView(),
///   tablet: TabletView(),
///   desktop: DesktopView(),
/// )
/// ```
///
/// - لو mobile مش موجود → يستخدم tablet أو desktop
/// - لو desktop مش موجود → يستخدم tablet أو mobile
///
class ResponsiveLayout extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? wide;
  final Widget? ultraWide;

  const ResponsiveLayout({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
    this.ultraWide,
  }) : assert(
          mobile != null || tablet != null || desktop != null,
          'لازم تحدد widget واحد على الأقل',
        );

  @override
  Widget build(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);

    switch (device) {
      case DeviceType.mobile:
        return mobile ?? tablet ?? desktop ?? wide ?? ultraWide!;
      case DeviceType.tablet:
        return tablet ?? mobile ?? desktop ?? wide ?? ultraWide!;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? wide ?? ultraWide!;
      case DeviceType.wide:
        return wide ?? desktop ?? tablet ?? mobile ?? ultraWide!;
      case DeviceType.ultraWide:
        return ultraWide ?? wide ?? desktop ?? tablet ?? mobile!;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ResponsiveBuilder — builder مع deviceType في الـ callback
/// ═══════════════════════════════════════════════════════════
///
/// الاستخدام:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, device) {
///     if (device == DeviceType.mobile) {
///       return MobileView();
///     }
///     return DesktopView();
///   },
/// )
/// ```
///
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType device) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, AppBreakpoints.getDeviceType(context));
  }
}

/// ═══════════════════════════════════════════════════════════
/// ResponsiveValue — يختار قيمة حسب حجم الشاشة
/// (generic type: T)
/// ═══════════════════════════════════════════════════════════
///
/// الاستخدام:
/// ```dart
/// final padding = ResponsiveValue<double>(
///   context,
///   mobile: 16,
///   tablet: 24,
///   desktop: 32,
/// ).value;
/// ```
///
class ResponsiveValue<T> {
  final T mobile;
  final T tablet;
  final T desktop;
  final T? wide;
  final T? ultraWide;

  const ResponsiveValue(
    BuildContext context, {
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.wide,
    this.ultraWide,
  });

  /// القيمة الحالية حسب الجهاز
  T get value {
    // مش محتاجين context هنا لأن القيم مخزنة
    // (لكن الـ constructor بياخد context للتوافق)
    throw UnimplementedError(
      'استخدم valueOf(context) بدل value',
    );
  }

  /// إرجاع القيمة حسب الجهاز
  T valueOf(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);

    switch (device) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.wide:
        return wide ?? desktop;
      case DeviceType.ultraWide:
        return ultraWide ?? wide ?? desktop;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ResponsivePadding — padding متغير حسب الجهاز
/// ═══════════════════════════════════════════════════════════
///
/// الاستخدام:
/// ```dart
/// Padding(
///   padding: ResponsivePadding.of(context),
///   child: ...,
/// )
/// ```
///
class ResponsivePadding {
  ResponsivePadding._();

  /// padding أفقي للـ screen
  static EdgeInsets of(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32);
      case DeviceType.wide:
        return const EdgeInsets.symmetric(horizontal: 48);
      case DeviceType.ultraWide:
        return const EdgeInsets.symmetric(horizontal: 64);
    }
  }

  /// padding كامل
  static EdgeInsets all(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
      case DeviceType.wide:
        return const EdgeInsets.all(32);
      case DeviceType.ultraWide:
        return const EdgeInsets.all(40);
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ResponsiveContainer — يحط المحتوى في وسط الشاشة بحد أقصى
/// ═══════════════════════════════════════════════════════════
///
/// مفيد جداً لصفحات الويب — المحتوى مش يتمدد على كل الشاشة.
///
/// الاستخدام:
/// ```dart
/// ResponsiveContainer(
///   child: MyContent(),
/// )
/// ```
///
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);
    final effectiveMaxWidth = maxWidth ?? _defaultMaxWidth(device);
    final effectivePadding = padding ?? ResponsivePadding.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }

  double _defaultMaxWidth(DeviceType device) {
    switch (device) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 700;
      case DeviceType.desktop:
        return 1000;
      case DeviceType.wide:
        return 1200;
      case DeviceType.ultraWide:
        return 1400;
    }
  }
}
