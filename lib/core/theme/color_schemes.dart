// lib/core/theme/color_schemes.dart

import 'package:flutter/material.dart';
import 'theme_model.dart';

/// ═══════════════════════════════════════════════════════════
/// Color Schemes — 5 مجموعات × (Light + Dark) = 10 ColorSchemes
/// ═══════════════════════════════════════════════════════════
///
/// المنهجية: هجين
/// - نبدأ بـ ColorScheme.fromSeed
/// - نخصص الألوان الحرجة (primary, secondary, surface, error)
/// - نضمن إن الـ Dark mode يبان حلو مش باهت
///
class AppColorSchemes {
  AppColorSchemes._(); // منع الإنشاء

  // ─────────────────────────────────────────────────────────
  // نقطة الدخول الرئيسية
  // ─────────────────────────────────────────────────────────

  /// إرجاع ColorScheme بناءً على النوع + الـ Brightness
  static ColorScheme get({
    required ColorSchemeType type,
    required Brightness brightness,
  }) {
    switch (type) {
      case ColorSchemeType.tealCoral:
        return brightness == Brightness.light
            ? tealCoralLight
            : tealCoralDark;
      case ColorSchemeType.indigoAmber:
        return brightness == Brightness.light
            ? indigoAmberLight
            : indigoAmberDark;
      case ColorSchemeType.emeraldRose:
        return brightness == Brightness.light
            ? emeraldRoseLight
            : emeraldRoseDark;
      case ColorSchemeType.violetCyan:
        return brightness == Brightness.light
            ? violetCyanLight
            : violetCyanDark;
      case ColorSchemeType.slateOrange:
        return brightness == Brightness.light
            ? slateOrangeLight
            : slateOrangeDark;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 1) TEAL + CORAL
  // ═══════════════════════════════════════════════════════════

  /// Teal + Coral — Light
  static final ColorScheme tealCoralLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF14B8A6), // Teal 500
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF0F766E),        // Teal 700
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCCFBF1), // Teal 100
    onPrimaryContainer: const Color(0xFF042F2E), // Teal 950
    secondary: const Color(0xFFE85D3A),      // Coral مشبع
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFFE4DB),
    onSecondaryContainer: const Color(0xFF4A1206),
    tertiary: const Color(0xFFFFB088),
    surface: const Color(0xFFF8FAFA),
    onSurface: const Color(0xFF1A1C1C),
    surfaceContainer: const Color(0xFFEEF2F2),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  /// Teal + Coral — Dark
  static final ColorScheme tealCoralDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF14B8A6),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF5EEAD4),        // Teal 300
    onPrimary: const Color(0xFF003731),
    primaryContainer: const Color(0xFF115E59), // Teal 800
    onPrimaryContainer: const Color(0xFFA7F3D0),
    secondary: const Color(0xFFFF8A65),      // Coral فاتح
    onSecondary: const Color(0xFF561B0A),
    secondaryContainer: const Color(0xFF7C2D12),
    onSecondaryContainer: const Color(0xFFFFDAD0),
    tertiary: const Color(0xFFFFCFA8),
    surface: const Color(0xFF0E1414),
    onSurface: const Color(0xFFE0E3E2),
    surfaceContainer: const Color(0xFF1A2020),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 2) INDIGO + AMBER
  // ═══════════════════════════════════════════════════════════

  /// Indigo + Amber — Light
  static final ColorScheme indigoAmberLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1), // Indigo 500
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF4338CA),        // Indigo 700
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE0E7FF), // Indigo 100
    onPrimaryContainer: const Color(0xFF1E1B4B), // Indigo 950
    secondary: const Color(0xFFF59E0B),      // Amber 500
    onSecondary: const Color(0xFF451A03),
    secondaryContainer: const Color(0xFFFEF3C7),
    onSecondaryContainer: const Color(0xFF451A03),
    tertiary: const Color(0xFFFFD54F),
    surface: const Color(0xFFFAFAFC),
    onSurface: const Color(0xFF1B1B1F),
    surfaceContainer: const Color(0xFFEEEEF4),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  /// Indigo + Amber — Dark
  static final ColorScheme indigoAmberDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFA5B4FC),        // Indigo 300
    onPrimary: const Color(0xFF1E1B4B),
    primaryContainer: const Color(0xFF3730A3), // Indigo 800
    onPrimaryContainer: const Color(0xFFE0E7FF),
    secondary: const Color(0xFFFCD34D),      // Amber 300
    onSecondary: const Color(0xFF451A03),
    secondaryContainer: const Color(0xFF78350F),
    onSecondaryContainer: const Color(0xFFFEF3C7),
    tertiary: const Color(0xFFFFE082),
    surface: const Color(0xFF121218),
    onSurface: const Color(0xFFE4E1E6),
    surfaceContainer: const Color(0xFF1E1E26),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 3) EMERALD + ROSE
  // ═══════════════════════════════════════════════════════════

  /// Emerald + Rose — Light
  static final ColorScheme emeraldRoseLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981), // Emerald 500
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF047857),        // Emerald 700
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFD1FAE5), // Emerald 100
    onPrimaryContainer: const Color(0xFF022C22), // Emerald 950
    secondary: const Color(0xFFE11D48),      // Rose 600
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFFE4E6),
    onSecondaryContainer: const Color(0xFF4C0519),
    tertiary: const Color(0xFFFDA4AF),
    surface: const Color(0xFFF8FAF9),
    onSurface: const Color(0xFF1A1C1B),
    surfaceContainer: const Color(0xFFEDF2F0),
    error: const Color(0xFFB91C1C),
    onError: Colors.white,
  );

  /// Emerald + Rose — Dark
  static final ColorScheme emeraldRoseDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF6EE7B7),        // Emerald 300
    onPrimary: const Color(0xFF00382B),
    primaryContainer: const Color(0xFF065F46), // Emerald 800
    onPrimaryContainer: const Color(0xFFD1FAE5),
    secondary: const Color(0xFFFB7185),      // Rose 400
    onSecondary: const Color(0xFF4C0519),
    secondaryContainer: const Color(0xFF881337),
    onSecondaryContainer: const Color(0xFFFFE4E6),
    tertiary: const Color(0xFFFECDD3),
    surface: const Color(0xFF0E1412),
    onSurface: const Color(0xFFE1E3E1),
    surfaceContainer: const Color(0xFF1A201E),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 4) VIOLET + CYAN
  // ═══════════════════════════════════════════════════════════

  /// Violet + Cyan — Light
  static final ColorScheme violetCyanLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8B5CF6), // Violet 500
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF6D28D9),        // Violet 700
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFEDE9FE), // Violet 100
    onPrimaryContainer: const Color(0xFF2E1065), // Violet 950
    secondary: const Color(0xFF0891B2),      // Cyan 600
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFCFFAFE),
    onSecondaryContainer: const Color(0xFF083344),
    tertiary: const Color(0xFF67E8F9),
    surface: const Color(0xFFFAF9FC),
    onSurface: const Color(0xFF1B1B1F),
    surfaceContainer: const Color(0xFFEFEDF5),
    error: const Color(0xFFDC2626),
    onError: Colors.white,
  );

  /// Violet + Cyan — Dark
  static final ColorScheme violetCyanDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF8B5CF6),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFC4B5FD),        // Violet 300
    onPrimary: const Color(0xFF2E1065),
    primaryContainer: const Color(0xFF5B21B6), // Violet 800
    onPrimaryContainer: const Color(0xFFEDE9FE),
    secondary: const Color(0xFF67E8F9),      // Cyan 300
    onSecondary: const Color(0xFF083344),
    secondaryContainer: const Color(0xFF155E75),
    onSecondaryContainer: const Color(0xFFCFFAFE),
    tertiary: const Color(0xFFA5F3FC),
    surface: const Color(0xFF131218),
    onSurface: const Color(0xFFE4E1E9),
    surfaceContainer: const Color(0xFF1F1E26),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );

  // ═══════════════════════════════════════════════════════════
  // 5) SLATE + ORANGE
  // ═══════════════════════════════════════════════════════════

  /// Slate + Orange — Light
  static final ColorScheme slateOrangeLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF64748B), // Slate 500
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF334155),        // Slate 700
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE2E8F0), // Slate 200
    onPrimaryContainer: const Color(0xFF0F172A), // Slate 900
    secondary: const Color(0xFFEA580C),      // Orange 600
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFFEDD5),
    onSecondaryContainer: const Color(0xFF431407),
    tertiary: const Color(0xFFFDBA74),
    surface: const Color(0xFFF8FAFC),
    onSurface: const Color(0xFF1E293B),
    surfaceContainer: const Color(0xFFEEF2F6),
    error: const Color(0xFFB91C1C),
    onError: Colors.white,
  );

  /// Slate + Orange — Dark
  static final ColorScheme slateOrangeDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF64748B),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFFCBD5E1),        // Slate 300
    onPrimary: const Color(0xFF0F172A),
    primaryContainer: const Color(0xFF334155), // Slate 700
    onPrimaryContainer: const Color(0xFFE2E8F0),
    secondary: const Color(0xFFFB923C),      // Orange 400
    onSecondary: const Color(0xFF431407),
    secondaryContainer: const Color(0xFF9A3412),
    onSecondaryContainer: const Color(0xFFFFEDD5),
    tertiary: const Color(0xFFFDBA74),
    surface: const Color(0xFF0F1419),
    onSurface: const Color(0xFFE2E8F0),
    surfaceContainer: const Color(0xFF1B2027),
    error: const Color(0xFFF87171),
    onError: const Color(0xFF450A0A),
  );
}