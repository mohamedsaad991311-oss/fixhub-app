// lib/core/constants/app_breakpoints.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// AppBreakpoints — نقاط الانكسار للـ Responsive Design
/// ═══════════════════════════════════════════════════════════
///
/// بتحدد نوع الجهاز بناءً على عرض الشاشة:
///
/// Mobile    : < 600
/// Tablet    : 600 → 900
/// Desktop   : 900 → 1200
/// Wide      : 1200 → 1600
/// UltraWide : > 1600
///
/// الاستخدام:
/// ```dart
/// final device = AppBreakpoints.getDeviceType(context);
/// if (device == DeviceType.mobile) {
///   return MobileLayout();
/// } else {
///   return DesktopLayout();
/// }
/// ```
///
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wide,
  ultraWide,
}

class AppBreakpoints {
  AppBreakpoints._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) نقاط الانكسار (Breakpoints)
  // ═══════════════════════════════════════════════════════════

  /// 0 → 600 : موبايل
  static const double mobile = 0;

  /// 600 → 900 : تابلت
  static const double tablet = 600;

  /// 900 → 1200 : ديسكتوب
  static const double desktop = 900;

  /// 1200 → 1600 : شاشة عريضة
  static const double wide = 1200;

  /// > 1600 : شاشة عملاقة
  static const double ultraWide = 1600;

  // ═══════════════════════════════════════════════════════════
  // 2) getDeviceType — تحديد نوع الجهاز من الـ context
  // ═══════════════════════════════════════════════════════════

  /// إرجاع نوع الجهاز بناءً على عرض الشاشة
  static DeviceType getDeviceType(BuildContext context) {
    return getDeviceTypeFromWidth(MediaQuery.of(context).size.width);
  }

  /// إرجاع نوع الجهاز من العرض مباشرة (بدون context)
  static DeviceType getDeviceTypeFromWidth(double width) {
    if (width < tablet) {
      return DeviceType.mobile;
    } else if (width < desktop) {
      return DeviceType.tablet;
    } else if (width < wide) {
      return DeviceType.desktop;
    } else if (width < ultraWide) {
      return DeviceType.wide;
    } else {
      return DeviceType.ultraWide;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 3) دوال فحص سريعة (من الـ context)
  // ═══════════════════════════════════════════════════════════

  /// هل الجهاز موبايل؟
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// هل الجهاز تابلت؟
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// هل الجهاز ديسكتوب؟
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// هل الجهاز عريض؟
  static bool isWide(BuildContext context) {
    return getDeviceType(context) == DeviceType.wide;
  }

  /// هل الجهاز عملاق؟
  static bool isUltraWide(BuildContext context) {
    return getDeviceType(context) == DeviceType.ultraWide;
  }

  // ═══════════════════════════════════════════════════════════
  // 4) دوال فحص مركّبة
  // ═══════════════════════════════════════════════════════════

  /// هل الجهاز صغير؟ (موبايل فقط)
  static bool isSmall(BuildContext context) => isMobile(context);

  /// هل الجهاز متوسط؟ (تابلت + ديسكتوب)
  static bool isMedium(BuildContext context) {
    final device = getDeviceType(context);
    return device == DeviceType.tablet || device == DeviceType.desktop;
  }

  /// هل الجهاز كبير؟ (wide + ultraWide)
  static bool isLarge(BuildContext context) {
    final device = getDeviceType(context);
    return device == DeviceType.wide || device == DeviceType.ultraWide;
  }

  /// هل الجهاز موبايل أو تابلت؟ (للـ mobile-first)
  static bool isMobileOrTablet(BuildContext context) {
    final device = getDeviceType(context);
    return device == DeviceType.mobile || device == DeviceType.tablet;
  }

  /// هل الجهاز ديسكتوب أو أكبر؟ (للـ desktop-first)
  static bool isDesktopOrLarger(BuildContext context) {
    return !isMobileOrTablet(context);
  }

  // ═══════════════════════════════════════════════════════════
  // 5) قيم مناسبة لكل نوع جهاز
  // ═══════════════════════════════════════════════════════════

  /// عدد الأعمدة المناسب للـ Grid
  static int gridColumns(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int wide = 4,
    int ultraWide = 5,
  }) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.wide:
        return wide;
      case DeviceType.ultraWide:
        return ultraWide;
    }
  }

  /// padding مناسب حسب الجهاز
  static double horizontalPadding(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
      case DeviceType.wide:
        return 48;
      case DeviceType.ultraWide:
        return 64;
    }
  }

  /// أقصى عرض للمحتوى حسب الجهاز (للقراءة المريحة)
  static double maxContentWidth(BuildContext context) {
    final device = getDeviceType(context);
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

  /// حجم الخط الأساسي حسب الجهاز (للتكبير على الشاشات الكبيرة)
  static double baseFontSize(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 15;
      case DeviceType.desktop:
        return 16;
      case DeviceType.wide:
        return 16;
      case DeviceType.ultraWide:
        return 17;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 6) Extension على BuildContext (اختصار)
// ═══════════════════════════════════════════════════════════

extension BreakpointContextX on BuildContext {
  /// نوع الجهاز
  DeviceType get deviceType => AppBreakpoints.getDeviceType(this);

  /// فحوصات سريعة
  bool get isMobile => AppBreakpoints.isMobile(this);
  bool get isTablet => AppBreakpoints.isTablet(this);
  bool get isDesktop => AppBreakpoints.isDesktop(this);
  bool get isWide => AppBreakpoints.isWide(this);
  bool get isUltraWide => AppBreakpoints.isUltraWide(this);

  /// فحوصات مركّبة
  bool get isSmallScreen => AppBreakpoints.isSmall(this);
  bool get isMediumScreen => AppBreakpoints.isMedium(this);
  bool get isLargeScreen => AppBreakpoints.isLarge(this);

  /// قيم مناسبة
  int gridColumns({
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int wide = 4,
    int ultraWide = 5,
  }) =>
      AppBreakpoints.gridColumns(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
        wide: wide,
        ultraWide: ultraWide,
      );

  double get horizontalPadding => AppBreakpoints.horizontalPadding(this);
  double get maxContentWidth => AppBreakpoints.maxContentWidth(this);
  double get baseFontSize => AppBreakpoints.baseFontSize(this);
}