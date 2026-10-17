// lib/core/theme/color_schemes.dart

import 'package:flutter/material.dart';
import 'theme_model.dart';

/// ═══════════════════════════════════════════════════════════
/// Color Schemes — 5 ألوان أساسية (Monochrome Themes)
/// ═══════════════════════════════════════════════════════════
///
/// كل ثيم معتمد على لون واحد بدرجاته (مريح للعين)
/// - بنفسجي (Violet)
/// - أزرق سماوي (Sky Blue)
/// - تركواز (Teal)
/// - أخضر (Emerald)
/// - كهرماني (Amber)
///
class AppColorSchemes {
  AppColorSchemes._();

  /// إرجاع ColorScheme بناءً على النوع + الـ Brightness
  static ColorScheme get({
    required ColorSchemeType type,
    required Brightness brightness,
  }) {
    switch (type) {
      case ColorSchemeType.violet:
        return brightness == Brightness.light ? violetLight : violetDark;
      case ColorSchemeType.skyBlue:
        return brightness == Brightness.light ? skyBlueLight : skyBlueDark;
      case ColorSchemeType.teal:
        return brightness == Brightness.light ? tealLight : tealDark;
      case ColorSchemeType.emerald:
        return brightness == Brightness.light ? emeraldLight : emeraldDark;
      case ColorSchemeType.amber:
        return brightness == Brightness.light ? amberLight : amberDark;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 1) VIOLET (بنفسجي)
  // ═══════════════════════════════════════════════════════════

  static final ColorScheme violetLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF9333EA), // بنفسجي مشبع
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF9333EA), // بنفسجي
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFF3E8FF), // بنفسجي فاتح جداً
    onPrimaryContainer: const Color(0xFF3B0764),
    secondary: const Color(0xFFEC4899), // وردي (Pink)
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFCE7F3),
    onSecondaryContainer: const Color(0xFF500724),
    surface: const Color(0xFFFAF9FC),
    onSurface: const Color(0xFF1B1B1F),
    surfaceContainer: const Color(0xFFF1EDF7),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  static final ColorScheme violetDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF9333EA),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFA855F7), // بنفسجي مضيء
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF6B21A8), // بنفسجي غامق
    onPrimaryContainer: const Color(0xFFF3E8FF),
    secondary: const Color(0xFFF472B6), // وردي مضيء
    onSecondary: const Color(0xFF500724),
    secondaryContainer: const Color(0xFF831843),
    onSecondaryContainer: const Color(0xFFFCE7F3),
    surface: const Color(0xFF100A1A), // خلفية غامقة جداً بلمسة بنفسجية
    onSurface: const Color(0xFFE9DDF2),
    surfaceContainer: const Color(0xFF1C1229),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );
  // ═══════════════════════════════════════════════════════════
  // 2) SKY BLUE (أزرق سماوي)
  // ═══════════════════════════════════════════════════════════

  static final ColorScheme skyBlueLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0EA5E9),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF0284C7), // Sky 600
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE0F2FE), // Sky 100
    onPrimaryContainer: const Color(0xFF082F49), // Sky 950
    secondary: const Color(0xFF7DD3FC), // Sky 300
    onSecondary: const Color(0xFF082F49),
    secondaryContainer: const Color(0xFFF0F9FF),
    onSecondaryContainer: const Color(0xFF082F49),
    surface: const Color(0xFFF8FAFC),
    onSurface: const Color(0xFF0F172A),
    surfaceContainer: const Color(0xFFEFF6FB),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  static final ColorScheme skyBlueDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0EA5E9),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF38BDF8), // Sky 400
    onPrimary: const Color(0xFF082F49),
    primaryContainer: const Color(0xFF0369A1), // Sky 700
    onPrimaryContainer: const Color(0xFFE0F2FE),
    secondary: const Color(0xFF7DD3FC), // Sky 300
    onSecondary: const Color(0xFF082F49),
    secondaryContainer: const Color(0xFF075985),
    onSecondaryContainer: const Color(0xFFF0F9FF),
    surface: const Color(0xFF0F1419),
    onSurface: const Color(0xFFE2E8F0),
    surfaceContainer: const Color(0xFF1B2027),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 3) TEAL (تركواز)
  // ═══════════════════════════════════════════════════════════

  static final ColorScheme tealLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF14B8A6),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF0D9488), // Teal 600
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCCFBF1), // Teal 100
    onPrimaryContainer: const Color(0xFF042F2E), // Teal 950
    secondary: const Color(0xFF5EEAD4), // Teal 300
    onSecondary: const Color(0xFF042F2E),
    secondaryContainer: const Color(0xFFF0FDFA),
    onSecondaryContainer: const Color(0xFF042F2E),
    surface: const Color(0xFFF8FAFA),
    onSurface: const Color(0xFF1A1C1C),
    surfaceContainer: const Color(0xFFEEF2F2),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  static final ColorScheme tealDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF14B8A6),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF2DD4BF), // Teal 400
    onPrimary: const Color(0xFF042F2E),
    primaryContainer: const Color(0xFF115E59), // Teal 800
    onPrimaryContainer: const Color(0xFFCCFBF1),
    secondary: const Color(0xFF5EEAD4), // Teal 300
    onSecondary: const Color(0xFF042F2E),
    secondaryContainer: const Color(0xFF134E4A),
    onSecondaryContainer: const Color(0xFFF0FDFA),
    surface: const Color(0xFF0E1414),
    onSurface: const Color(0xFFE0E3E2),
    surfaceContainer: const Color(0xFF1A2020),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 4) EMERALD (أخضر)
  // ═══════════════════════════════════════════════════════════

  static final ColorScheme emeraldLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF059669), // Emerald 600
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFD1FAE5), // Emerald 100
    onPrimaryContainer: const Color(0xFF022C22), // Emerald 950
    secondary: const Color(0xFF6EE7B7), // Emerald 300
    onSecondary: const Color(0xFF022C22),
    secondaryContainer: const Color(0xFFECFDF5),
    onSecondaryContainer: const Color(0xFF022C22),
    surface: const Color(0xFFF8FAF9),
    onSurface: const Color(0xFF1A1C1B),
    surfaceContainer: const Color(0xFFEDF2F0),
    error: const Color(0xFFB91C1C),
    onError: Colors.white,
  );

  static final ColorScheme emeraldDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF34D399), // Emerald 400
    onPrimary: const Color(0xFF022C22),
    primaryContainer: const Color(0xFF065F46), // Emerald 800
    onPrimaryContainer: const Color(0xFFD1FAE5),
    secondary: const Color(0xFF6EE7B7), // Emerald 300
    onSecondary: const Color(0xFF022C22),
    secondaryContainer: const Color(0xFF064E3B),
    onSecondaryContainer: const Color(0xFFECFDF5),
    surface: const Color(0xFF0E1412),
    onSurface: const Color(0xFFE1E3E1),
    surfaceContainer: const Color(0xFF1A201E),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 5) AMBER (كهرماني / برتقالي)
  // ═══════════════════════════════════════════════════════════

  static final ColorScheme amberLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFFF59E0B),
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFFD97706), // Amber 600
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFFEF3C7), // Amber 100
    onPrimaryContainer: const Color(0xFF451A03), // Amber 950
    secondary: const Color(0xFFFCD34D), // Amber 300
    onSecondary: const Color(0xFF451A03),
    secondaryContainer: const Color(0xFFFFFBEB),
    onSecondaryContainer: const Color(0xFF451A03),
    surface: const Color(0xFFFCFAF7),
    onSurface: const Color(0xFF1F1B16),
    surfaceContainer: const Color(0xFFF7F0E6),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  static final ColorScheme amberDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFFF59E0B),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFFBBF24), // Amber 400
    onPrimary: const Color(0xFF451A03),
    primaryContainer: const Color(0xFF92400E), // Amber 800
    onPrimaryContainer: const Color(0xFFFEF3C7),
    secondary: const Color(0xFFFCD34D), // Amber 300
    onSecondary: const Color(0xFF451A03),
    secondaryContainer: const Color(0xFF78350F),
    onSecondaryContainer: const Color(0xFFFFFBEB),
    surface: const Color(0xFF18150F),
    onSurface: const Color(0xFFE6E1DA),
    surfaceContainer: const Color(0xFF241F17),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );
}
