// lib/core/theme/theme_tokens.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_model.dart';

/// ═══════════════════════════════════════════════════════════
/// Theme Tokens — القيم اللي بتفرّق بين الـ 5 أنماط
/// ═══════════════════════════════════════════════════════════
///
/// كل نمط (ThemeStyle) له:
/// - Spacing system
/// - Elevation values
/// - Border values
/// - Typography (font family + weights)
/// - Animation durations
/// - Glass / Neumorphic settings
///
class ThemeTokens {
  // ═══════════════════════════════════════════════════════════
  // 1) SPACING — موحّد لكل الأنماط
  // ═══════════════════════════════════════════════════════════

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double spaceXxl = 48;

  /// EdgeInsets جاهزة
  static const EdgeInsets paddingXs = EdgeInsets.all(spaceXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spaceSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spaceMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spaceLg);
  static const EdgeInsets paddingXl = EdgeInsets.all(spaceXl);

  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: spaceMd);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: spaceMd);

  // ═══════════════════════════════════════════════════════════
  // 2) ELEVATION — يختلف حسب النمط
  // ═══════════════════════════════════════════════════════════

  /// elevation للـ Card حسب النمط
  static double cardElevation(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.minimal:
        return 0;
      case ThemeStyle.glass:
        return 0; // بيستخدم blur بدل elevation
      case ThemeStyle.neumorphic:
        return 0; // بيستخدم ظلال مخصصة
      case ThemeStyle.material3:
        return 1;
      case ThemeStyle.elegant:
        return 4;
    }
  }

  /// elevation للـ AppBar حسب النمط
  static double appBarElevation(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.minimal:
        return 0;
      case ThemeStyle.glass:
        return 0;
      case ThemeStyle.neumorphic:
        return 0;
      case ThemeStyle.material3:
        return 0; // M3 uses surface tint
      case ThemeStyle.elegant:
        return 2;
    }
  }

  /// elevation للأزرار
  static double buttonElevation(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.minimal:
        return 0;
      case ThemeStyle.glass:
        return 0;
      case ThemeStyle.neumorphic:
        return 0;
      case ThemeStyle.material3:
        return 1;
      case ThemeStyle.elegant:
        return 3;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 3) BORDER — يختلف حسب النمط
  // ═══════════════════════════════════════════════════════════

  /// سماكة الحدود
  static double borderWidth(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.minimal:
        return 1.0;
      case ThemeStyle.glass:
        return 1.5;
      case ThemeStyle.neumorphic:
        return 0; // بدون حدود
      case ThemeStyle.material3:
        return 0;
      case ThemeStyle.elegant:
        return 1.5;
    }
  }

  /// لون الحدود
  static Color? borderColor(
    ThemeStyle style,
    ColorScheme scheme,
  ) {
    switch (style) {
      case ThemeStyle.minimal:
        return scheme.outlineVariant;
      case ThemeStyle.glass:
        return scheme.onSurface.withValues(alpha: 0.15);
      case ThemeStyle.neumorphic:
        return null;
      case ThemeStyle.material3:
        return null;
      case ThemeStyle.elegant:
        return scheme.primary.withValues(alpha: 0.4);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 4) TYPOGRAPHY — الخطوط حسب النمط
  // ═══════════════════════════════════════════════════════════

  /// الخط الأساسي (عربي + إنجليزي)
  ///
  /// - Cairo: حديث، واضح، ممتاز للعربي
  /// - Amiri: للـ Elegant (Serif عربي كلاسيكي)
  static TextTheme textTheme({
    required ThemeStyle style,
    required ColorScheme scheme,
    required FontScale fontScale,
    required bool isArabic,
  }) {
    // اختيار الخط حسب النمط
    final TextTheme baseTheme;
    if (style == ThemeStyle.elegant) {
      // Elegant: خط Serif (Amiri للعربي، Playfair للإنجليزي)
      baseTheme = isArabic
          ? GoogleFonts.amiriTextTheme()
          : GoogleFonts.playfairDisplayTextTheme();
    } else {
      // باقي الأنماط: Cairo (يدعم عربي + إنجليزي بشكل ممتاز)
      baseTheme = GoogleFonts.cairoTextTheme();
    }

    // تطبيق fontScale
    return _applyFontScale(baseTheme, scheme, fontScale);
  }

  /// تطبيق FontScale على TextTheme
  static TextTheme _applyFontScale(
    TextTheme base,
    ColorScheme scheme,
    FontScale scale,
  ) {
    double s(double? size) => (size ?? 14) * scale.factor;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: s(base.displayLarge?.fontSize),
        color: scheme.onSurface,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: s(base.displayMedium?.fontSize),
        color: scheme.onSurface,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: s(base.displaySmall?.fontSize),
        color: scheme.onSurface,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: s(base.headlineLarge?.fontSize),
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: s(base.headlineMedium?.fontSize),
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: s(base.headlineSmall?.fontSize),
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: s(base.titleLarge?.fontSize),
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: s(base.titleMedium?.fontSize),
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: s(base.titleSmall?.fontSize),
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: s(base.bodyLarge?.fontSize),
        color: scheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: s(base.bodyMedium?.fontSize),
        color: scheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: s(base.bodySmall?.fontSize),
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: s(base.labelLarge?.fontSize),
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: s(base.labelMedium?.fontSize),
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: s(base.labelSmall?.fontSize),
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 5) ANIMATION — مدة الحركات
  // ═══════════════════════════════════════════════════════════

  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);

  /// مدة الحركة حسب النمط (Elegant أبطأ شوية = فخامة)
  static Duration animByStyle(ThemeStyle style) {
    switch (style) {
      case ThemeStyle.minimal:
        return animFast;
      case ThemeStyle.glass:
        return animNormal;
      case ThemeStyle.neumorphic:
        return animNormal;
      case ThemeStyle.material3:
        return animNormal;
      case ThemeStyle.elegant:
        return animSlow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 6) GLASS — إعدادات الزجاج (للـ Glass style)
  // ═══════════════════════════════════════════════════════════

  /// blur sigma للـ Glass
  static double glassBlur(GlassIntensity intensity) => intensity.blurSigma;

  /// شفافية خلفية الزجاج
  static double glassOpacity(GlassIntensity intensity) => intensity.opacity;

  /// لون خلفية الزجاج (يعتمد على الـ scheme)
  static Color glassBackground(
    ColorScheme scheme,
    GlassIntensity intensity,
  ) {
    final isDark = scheme.brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.white;
    return base.withValues(alpha: intensity.opacity);
  }

  /// حدود الزجاج (لمعة خفيفة)
  static Color glassBorder(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.5);
  }

  // ═══════════════════════════════════════════════════════════
  // 7) NEUMORPHIC — ظلال داخلية/خارجية
  // ═══════════════════════════════════════════════════════════

  /// لون الظل الفاتح (Highlight)
  static Color neumorphicLightShadow(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.9);
  }

  /// لون الظل الغامق
  static Color neumorphicDarkShadow(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return isDark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.15);
  }

  /// إزاحة الظل (offset) بالبكسل
  static const double neumorphicOffset = 4;

  /// blur radius للظل الناعم
  static const double neumorphicBlur = 8;

  /// ظل Neumorphic جاهز (خارجي)
  static List<BoxShadow> neumorphicOuterShadow(ColorScheme scheme) {
    return [
      BoxShadow(
        color: neumorphicLightShadow(scheme),
        offset: const Offset(-neumorphicOffset, -neumorphicOffset),
        blurRadius: neumorphicBlur,
      ),
      BoxShadow(
        color: neumorphicDarkShadow(scheme),
        offset: const Offset(neumorphicOffset, neumorphicOffset),
        blurRadius: neumorphicBlur,
      ),
    ];
  }

  /// ظل Neumorphic جاهز (داخلي — للحقول المضغوطة)
  static List<BoxShadow> neumorphicInnerShadow(ColorScheme scheme) {
    return [
      BoxShadow(
        color: neumorphicDarkShadow(scheme),
        offset: const Offset(neumorphicOffset / 2, neumorphicOffset / 2),
        blurRadius: neumorphicBlur / 2,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: neumorphicLightShadow(scheme),
        offset: const Offset(-neumorphicOffset / 2, -neumorphicOffset / 2),
        blurRadius: neumorphicBlur / 2,
        spreadRadius: -2,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // 8) ICON SIZES
  // ═══════════════════════════════════════════════════════════

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconXxl = 48;

  // ═══════════════════════════════════════════════════════════
  // 9) BREAKPOINTS — نقاط الانكسار (للـ responsive)
  // ═══════════════════════════════════════════════════════════

  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;
  static const double breakpointWide = 1600;

  // ═══════════════════════════════════════════════════════════
  // 10) RADIUS — حواف جاهزة (تعتمد على CornerStyle)
  // ═══════════════════════════════════════════════════════════

  static BorderRadius radiusFrom(CornerStyle style) => style.borderRadius;

  /// نصف قطر أصغر (للعناصر الصغيرة)
  static BorderRadius radiusSmallFrom(CornerStyle style) {
    return BorderRadius.circular(style.radius * 0.5);
  }

  /// نصف قطر أكبر (للحاويات الكبيرة)
  static BorderRadius radiusLargeFrom(CornerStyle style) {
    return BorderRadius.circular(style.radius * 1.5);
  }

  // ═══════════════════════════════════════════════════════════
  // 11) SHADOWS — ظلال مختلفة حسب النمط
  // ═══════════════════════════════════════════════════════════

  /// ظل البطاقة حسب النمط
  static List<BoxShadow> cardShadow(
    ThemeStyle style,
    ColorScheme scheme,
  ) {
    final isDark = scheme.brightness == Brightness.dark;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.08);

    switch (style) {
      case ThemeStyle.minimal:
        return [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ];
      case ThemeStyle.glass:
        return [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ];
      case ThemeStyle.neumorphic:
        return neumorphicOuterShadow(scheme);
      case ThemeStyle.material3:
        return [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ];
      case ThemeStyle.elegant:
        return [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ];
    }
  }
}