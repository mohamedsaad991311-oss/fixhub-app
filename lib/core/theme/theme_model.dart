// lib/core/theme/theme_model.dart

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// 1) ColorSchemeType — 5 مجموعات ألوان
// ═══════════════════════════════════════════════════════════

/// المجموعات الخمس للألوان (كل مجموعة × Light+Dark = 10 ColorSchemes)
enum ColorSchemeType {
  /// Teal + Coral — الأخضر المائل للأزرق + المرجاني
  tealCoral,

  /// Indigo + Amber — النيلي + العنبري
  indigoAmber,

  /// Emerald + Rose — الزمردي + الوردي
  emeraldRose,

  /// Violet + Cyan — البنفسجي + السماوي
  violetCyan,

  /// Slate + Orange — الرمادي المائل للأزرق + البرتقالي
  slateOrange,
}

extension ColorSchemeTypeX on ColorSchemeType {
  /// الاسم المعروض (للـ UI)
  String get label {
    switch (this) {
      case ColorSchemeType.tealCoral:
        return 'Teal + Coral';
      case ColorSchemeType.indigoAmber:
        return 'Indigo + Amber';
      case ColorSchemeType.emeraldRose:
        return 'Emerald + Rose';
      case ColorSchemeType.violetCyan:
        return 'Violet + Cyan';
      case ColorSchemeType.slateOrange:
        return 'Slate + Orange';
    }
  }

  /// اللون الأساسي (Seed) — يُستخدم للعرض في معاينة الثيم
  Color get seedColor {
    switch (this) {
      case ColorSchemeType.tealCoral:
        return const Color(0xFF14B8A6); // Teal 500
      case ColorSchemeType.indigoAmber:
        return const Color(0xFF6366F1); // Indigo 500
      case ColorSchemeType.emeraldRose:
        return const Color(0xFF10B981); // Emerald 500
      case ColorSchemeType.violetCyan:
        return const Color(0xFF8B5CF6); // Violet 500
      case ColorSchemeType.slateOrange:
        return const Color(0xFF64748B); // Slate 500
    }
  }

  /// اللون الثانوي (Accent) — للعرض في المعاينة
  Color get accentColor {
    switch (this) {
      case ColorSchemeType.tealCoral:
        return const Color(0xFFFF7F50); // Coral
      case ColorSchemeType.indigoAmber:
        return const Color(0xFFFFC107); // Amber
      case ColorSchemeType.emeraldRose:
        return const Color(0xFFF43F5E); // Rose
      case ColorSchemeType.violetCyan:
        return const Color(0xFF06B6D4); // Cyan
      case ColorSchemeType.slateOrange:
        return const Color(0xFFF97316); // Orange
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 2) AppThemeMode — Light / Dark / System
// ═══════════════════════════════════════════════════════════

enum AppThemeMode {
  light,
  dark,
  system,
}

extension AppThemeModeX on AppThemeMode {
  String get label {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// تحويل إلى ThemeMode الخاص بـ Flutter
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 3) ThemeStyle — 5 أنماط تصميم
// ═══════════════════════════════════════════════════════════

enum ThemeStyle {
  /// بسيط، مسطح، بدون ظلال تقريباً
  minimal,

  /// زجاجي شفاف (Glassmorphism)
  glass,

  /// ناعم مع ظلال داخلية/خارجية (Neumorphism)
  neumorphic,

  /// نمط Google Material 3 الحديث
  material3,

  /// أنيق بخطوط Serif وتفاصيل ذهبية
  elegant,
}

extension ThemeStyleX on ThemeStyle {
  String get label {
    switch (this) {
      case ThemeStyle.minimal:
        return 'Minimal';
      case ThemeStyle.glass:
        return 'Glass';
      case ThemeStyle.neumorphic:
        return 'Neumorphic';
      case ThemeStyle.material3:
        return 'Material 3';
      case ThemeStyle.elegant:
        return 'Elegant';
    }
  }

  /// وصف مختصر (للـ UI)
  String get description {
    switch (this) {
      case ThemeStyle.minimal:
        return 'Simple, flat, clean';
      case ThemeStyle.glass:
        return 'Frosted glass effect';
      case ThemeStyle.neumorphic:
        return 'Soft, subtle shadows';
      case ThemeStyle.material3:
        return 'Google Material 3';
      case ThemeStyle.elegant:
        return 'Serif fonts, gold accents';
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 4) FontScale — 4 مستويات
// ═══════════════════════════════════════════════════════════

enum FontScale {
  small,
  normal,
  large,
  extraLarge,
}

extension FontScaleX on FontScale {
  String get label {
    switch (this) {
      case FontScale.small:
        return 'Small';
      case FontScale.normal:
        return 'Normal';
      case FontScale.large:
        return 'Large';
      case FontScale.extraLarge:
        return 'Extra Large';
    }
  }

  /// معامل الضرب لحجم الخط
  double get factor {
    switch (this) {
      case FontScale.small:
        return 0.85;
      case FontScale.normal:
        return 1.00;
      case FontScale.large:
        return 1.15;
      case FontScale.extraLarge:
        return 1.30;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 5) CornerStyle — 3 مستويات
// ═══════════════════════════════════════════════════════════

enum CornerStyle {
  sharp,
  rounded,
  extraRounded,
}

extension CornerStyleX on CornerStyle {
  String get label {
    switch (this) {
      case CornerStyle.sharp:
        return 'Sharp';
      case CornerStyle.rounded:
        return 'Rounded';
      case CornerStyle.extraRounded:
        return 'Extra Rounded';
    }
  }

  /// قيمة نصف قطر الحواف بالبكسل
  double get radius {
    switch (this) {
      case CornerStyle.sharp:
        return 0;
      case CornerStyle.rounded:
        return 12;
      case CornerStyle.extraRounded:
        return 24;
    }
  }

  /// BorderRadius جاهز للاستخدام
  BorderRadius get borderRadius => BorderRadius.circular(radius);
}

// ═══════════════════════════════════════════════════════════
// 6) GlassIntensity — 3 مستويات
// ═══════════════════════════════════════════════════════════

enum GlassIntensity {
  subtle,
  medium,
  strong,
}

extension GlassIntensityX on GlassIntensity {
  String get label {
    switch (this) {
      case GlassIntensity.subtle:
        return 'Subtle';
      case GlassIntensity.medium:
        return 'Medium';
      case GlassIntensity.strong:
        return 'Strong';
    }
  }

  /// شدة الـ blur بالبكسل
  double get blurSigma {
    switch (this) {
      case GlassIntensity.subtle:
        return 8;
      case GlassIntensity.medium:
        return 16;
      case GlassIntensity.strong:
        return 24;
    }
  }

  /// شفافية الخلفية (0 = شفاف تماماً، 1 = معتم)
  double get opacity {
    switch (this) {
      case GlassIntensity.subtle:
        return 0.85;
      case GlassIntensity.medium:
        return 0.70;
      case GlassIntensity.strong:
        return 0.55;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// 7) ThemeSettings — الكلاس الرئيسي اللي يجمع كل الإعدادات
// ═══════════════════════════════════════════════════════════

class ThemeSettings {
  final ColorSchemeType colorScheme;
  final AppThemeMode mode;
  final ThemeStyle style;
  final FontScale fontScale;
  final CornerStyle cornerStyle;
  final GlassIntensity glassIntensity;

  const ThemeSettings({
    this.colorScheme = ColorSchemeType.tealCoral,
    this.mode = AppThemeMode.system,
    this.style = ThemeStyle.material3,
    this.fontScale = FontScale.normal,
    this.cornerStyle = CornerStyle.rounded,
    this.glassIntensity = GlassIntensity.medium,
  });

  /// نسخة افتراضية
  static const ThemeSettings defaults = ThemeSettings();

  /// copyWith — لإنشاء نسخة معدّلة
  ThemeSettings copyWith({
    ColorSchemeType? colorScheme,
    AppThemeMode? mode,
    ThemeStyle? style,
    FontScale? fontScale,
    CornerStyle? cornerStyle,
    GlassIntensity? glassIntensity,
  }) {
    return ThemeSettings(
      colorScheme: colorScheme ?? this.colorScheme,
      mode: mode ?? this.mode,
      style: style ?? this.style,
      fontScale: fontScale ?? this.fontScale,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      glassIntensity: glassIntensity ?? this.glassIntensity,
    );
  }

  /// toMap — للتخزين في Hive
  Map<String, dynamic> toMap() {
    return {
      'colorScheme': colorScheme.name,
      'mode': mode.name,
      'style': style.name,
      'fontScale': fontScale.name,
      'cornerStyle': cornerStyle.name,
      'glassIntensity': glassIntensity.name,
    };
  }

  /// fromMap — للقراءة من Hive
  factory ThemeSettings.fromMap(Map<dynamic, dynamic> map) {
    return ThemeSettings(
      colorScheme: ColorSchemeType.values.firstWhere(
        (e) => e.name == map['colorScheme'],
        orElse: () => ColorSchemeType.tealCoral,
      ),
      mode: AppThemeMode.values.firstWhere(
        (e) => e.name == map['mode'],
        orElse: () => AppThemeMode.system,
      ),
      style: ThemeStyle.values.firstWhere(
        (e) => e.name == map['style'],
        orElse: () => ThemeStyle.material3,
      ),
      fontScale: FontScale.values.firstWhere(
        (e) => e.name == map['fontScale'],
        orElse: () => FontScale.normal,
      ),
      cornerStyle: CornerStyle.values.firstWhere(
        (e) => e.name == map['cornerStyle'],
        orElse: () => CornerStyle.rounded,
      ),
      glassIntensity: GlassIntensity.values.firstWhere(
        (e) => e.name == map['glassIntensity'],
        orElse: () => GlassIntensity.medium,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.colorScheme == colorScheme &&
        other.mode == mode &&
        other.style == style &&
        other.fontScale == fontScale &&
        other.cornerStyle == cornerStyle &&
        other.glassIntensity == glassIntensity;
  }

  @override
  int get hashCode => Object.hash(
        colorScheme,
        mode,
        style,
        fontScale,
        cornerStyle,
        glassIntensity,
      );
}