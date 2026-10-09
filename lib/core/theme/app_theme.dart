// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'theme_model.dart';
import 'theme_tokens.dart';

/// ═══════════════════════════════════════════════════════════
/// AppTheme — بناء ThemeData كاملة من ThemeSettings
/// ═══════════════════════════════════════════════════════════
///
/// المدخلات: ThemeSettings
/// المخرجات: ThemeData جاهزة للـ MaterialApp
///
/// كل الـ components بتاخد قيمها من:
/// - ColorScheme (color_schemes.dart)
/// - Tokens (theme_tokens.dart)
///
class AppTheme {
  AppTheme._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // نقاط الدخول الرئيسية
  // ═══════════════════════════════════════════════════════════

  /// بناء ThemeData للوضع الفاتح
    static ThemeData light(ThemeSettings settings, {bool isArabic = true}) {
    return _build(settings, Brightness.light, isArabic: isArabic);
  }

  /// بناء ThemeData للوضع الداكن
    static ThemeData dark(ThemeSettings settings, {bool isArabic = true}) {
    return _build(settings, Brightness.dark, isArabic: isArabic);
  }

  /// موحّد — يختار حسب Brightness
   static ThemeData build(
    ThemeSettings settings,
    Brightness brightness, {
    bool isArabic = true,
  }) {
    return _build(settings, brightness, isArabic: isArabic);
  }
  /// تحويل AppThemeMode → ThemeMode (اللي بيستخدمه MaterialApp)
  static ThemeMode themeMode(AppThemeMode mode) => mode.themeMode;

  // ═══════════════════════════════════════════════════════════
  // البناء الرئيسي
  // ═══════════════════════════════════════════════════════════

    static ThemeData _build(
    ThemeSettings settings,
    Brightness brightness, {
    required bool isArabic,
  }) {
    final scheme = AppColorSchemes.get(
      type: settings.colorScheme,
      brightness: brightness,
    );

       final textTheme = ThemeTokens.textTheme(
      style: settings.style,
      scheme: scheme,
      fontScale: settings.fontScale,
      isArabic: isArabic,
    );

    final radius = settings.cornerStyle.borderRadius;
    final radiusSmall = ThemeTokens.radiusSmallFrom(settings.cornerStyle);
    final radiusLarge = ThemeTokens.radiusLargeFrom(settings.cornerStyle);
    final style = settings.style;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,

      // ─── الخلفية العامة ───
      scaffoldBackgroundColor: scheme.surface,

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        elevation: ThemeTokens.appBarElevation(style),
        scrolledUnderElevation: style == ThemeStyle.minimal ? 0 : 1,
        centerTitle: false,
        backgroundColor: _appBarBackground(style, scheme),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: style == ThemeStyle.material3
            ? scheme.surfaceTint
            : Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(
          color: scheme.onSurface,
          size: ThemeTokens.iconLg,
        ),
        actionsIconTheme: IconThemeData(
          color: scheme.onSurface,
          size: ThemeTokens.iconLg,
        ),
      ),

      // ─── Card ───
      cardTheme: CardThemeData(
        elevation: ThemeTokens.cardElevation(style),
        color: _cardBackground(style, scheme),
        surfaceTintColor: style == ThemeStyle.material3
            ? scheme.surfaceTint
            : Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.1),
               shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: _cardBorder(style, scheme),
        ),
        margin: const EdgeInsets.all(ThemeTokens.spaceSm),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── FilledButton ───
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: ThemeTokens.buttonElevation(style),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeTokens.spaceLg,
            vertical: ThemeTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── ElevatedButton ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.surfaceContainer,
          foregroundColor: scheme.onSurface,
          elevation: ThemeTokens.buttonElevation(style),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeTokens.spaceLg,
            vertical: ThemeTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── OutlinedButton ───
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeTokens.spaceLg,
            vertical: ThemeTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusSmall),
          side: BorderSide(
            color: scheme.primary.withValues(alpha: 0.5),
            width: 1.2,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── TextButton ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeTokens.spaceMd,
            vertical: ThemeTokens.spaceSm,
          ),
          shape: RoundedRectangleBorder(borderRadius: radiusSmall),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── InputDecoration ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _inputFill(style, scheme),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeTokens.spaceMd,
          vertical: ThemeTokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: BorderSide(
            color: ThemeTokens.borderColor(style, scheme) ??
                scheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: BorderSide(
            color: ThemeTokens.borderColor(style, scheme) ??
                scheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: BorderSide(
            color: scheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radiusSmall,
          borderSide: BorderSide(
            color: scheme.error,
            width: 2,
          ),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: _dialogBackground(style, scheme),
        elevation: style == ThemeStyle.minimal ? 0 : 6,
        shape: RoundedRectangleBorder(borderRadius: radiusLarge),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ─── BottomNavigationBar ───
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _navBackground(style, scheme),
        elevation: style == ThemeStyle.minimal ? 0 : 3,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      // ─── NavigationRail ───
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _navBackground(style, scheme),
        elevation: style == ThemeStyle.minimal ? 0 : 2,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium,
        indicatorColor: scheme.primaryContainer,
        useIndicator: true,
      ),

      // ─── NavigationBar (M3) ───
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _navBackground(style, scheme),
        elevation: style == ThemeStyle.minimal ? 0 : 3,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimaryContainer);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainer.withValues(alpha: 0.5),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeTokens.spaceSm,
          vertical: ThemeTokens.spaceXs,
        ),
        shape: RoundedRectangleBorder(borderRadius: radiusSmall),
        side: BorderSide(
          color: ThemeTokens.borderColor(style, scheme) ?? Colors.transparent,
        ),
      ),

      // ─── Divider ───
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      // ─── SnackBar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radiusSmall),
        elevation: 4,
      ),

      // ─── Tooltip ───
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: radiusSmall,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeTokens.spaceSm,
          vertical: ThemeTokens.spaceXs,
        ),
      ),

      // ─── IconTheme ───
      iconTheme: IconThemeData(
        color: scheme.onSurface,
        size: ThemeTokens.iconLg,
      ),

      // ─── ListTile ───
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        selectedColor: scheme.primary,
        selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeTokens.spaceMd,
          vertical: ThemeTokens.spaceSm,
        ),
        shape: RoundedRectangleBorder(borderRadius: radiusSmall),
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),

      // ─── Switch ───
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.all(
          scheme.outline.withValues(alpha: 0.5),
        ),
      ),

      // ─── Checkbox ───
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(scheme.onPrimary),
        side: BorderSide(
          color: scheme.outline,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ─── Radio ───
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.outline;
        }),
      ),

      // ─── Slider ───
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.15),
        valueIndicatorColor: scheme.primary,
        trackHeight: 4,
      ),

      // ─── ProgressIndicator ───
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),

      // ─── Scrollbar ───
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          scheme.onSurface.withValues(alpha: 0.3),
        ),
        radius: Radius.circular(settings.cornerStyle.radius / 2),
        thickness: WidgetStateProperty.all(6),
      ),

      // ─── TabBar ───
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant.withValues(alpha: 0.5),
      ),

      // ─── ExpansionTile ───
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        collapsedIconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radiusSmall),
        collapsedShape: RoundedRectangleBorder(borderRadius: radiusSmall),
      ),

      // ─── PopupMenu ───
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainer,
        elevation: style == ThemeStyle.minimal ? 0 : 4,
        shape: RoundedRectangleBorder(borderRadius: radiusSmall),
        textStyle: textTheme.bodyMedium,
      ),

      // ─── BottomSheet ───
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        modalBackgroundColor: scheme.surfaceContainer,
        elevation: style == ThemeStyle.minimal ? 0 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(settings.cornerStyle.radius * 1.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── SegmentedButton ───
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: radiusSmall),
          ),
          textStyle: WidgetStateProperty.all(textTheme.labelLarge),
        ),
      ),

      // ─── Splash / Highlight ───
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: scheme.primary.withValues(alpha: 0.04),
      hoverColor: scheme.primary.withValues(alpha: 0.05),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // دوال مساعدة (تختار الخلفية حسب النمط)
  // ═══════════════════════════════════════════════════════════

  static Color _appBarBackground(ThemeStyle style, ColorScheme scheme) {
    switch (style) {
      case ThemeStyle.minimal:
        return scheme.surface;
      case ThemeStyle.glass:
        return scheme.surface.withValues(alpha: 0.7);
      case ThemeStyle.neumorphic:
        return scheme.surface;
      case ThemeStyle.material3:
        return scheme.surface;
      case ThemeStyle.elegant:
        return scheme.surfaceContainer;
    }
  }

  static Color _cardBackground(ThemeStyle style, ColorScheme scheme) {
    switch (style) {
      case ThemeStyle.minimal:
        return scheme.surface;
      case ThemeStyle.glass:
        return scheme.surface.withValues(alpha: 0.6);
      case ThemeStyle.neumorphic:
        return scheme.surface;
      case ThemeStyle.material3:
        return scheme.surfaceContainerLow;
      case ThemeStyle.elegant:
        return scheme.surfaceContainer;
    }
  }

    static BorderSide _cardBorder(ThemeStyle style, ColorScheme scheme) {
    final color = ThemeTokens.borderColor(style, scheme);
    if (color == null) return BorderSide.none;
    return BorderSide(
      color: color,
      width: ThemeTokens.borderWidth(style),
    );
  }

  static Color _inputFill(ThemeStyle style, ColorScheme scheme) {
    switch (style) {
      case ThemeStyle.minimal:
        return scheme.surface;
      case ThemeStyle.glass:
        return scheme.surface.withValues(alpha: 0.4);
      case ThemeStyle.neumorphic:
        return scheme.surfaceContainer;
      case ThemeStyle.material3:
        return scheme.surfaceContainerHighest.withValues(alpha: 0.5);
      case ThemeStyle.elegant:
        return scheme.surfaceContainer;
    }
  }

  static Color _dialogBackground(ThemeStyle style, ColorScheme scheme) {
    switch (style) {
      case ThemeStyle.minimal:
        return scheme.surface;
      case ThemeStyle.glass:
        return scheme.surface.withValues(alpha: 0.9);
      case ThemeStyle.neumorphic:
        return scheme.surface;
      case ThemeStyle.material3:
        return scheme.surfaceContainerHigh;
      case ThemeStyle.elegant:
        return scheme.surfaceContainer;
    }
  }

  static Color _navBackground(ThemeStyle style, ColorScheme scheme) {
    switch (style) {
      case ThemeStyle.minimal:
        return scheme.surface;
      case ThemeStyle.glass:
        return scheme.surface.withValues(alpha: 0.7);
      case ThemeStyle.neumorphic:
        return scheme.surface;
      case ThemeStyle.material3:
        return scheme.surfaceContainer;
      case ThemeStyle.elegant:
        return scheme.surfaceContainer;
    }
  }
}