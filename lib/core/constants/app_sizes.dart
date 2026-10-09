// lib/core/constants/app_sizes.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// AppSizes — الأحجام الثابتة للتطبيق
/// ═══════════════════════════════════════════════════════════
///
/// ⚠️ ملاحظة: في theme_tokens.dart فيه spacing مشابه.
/// الفرق:
/// - theme_tokens: بيتغير حسب النمط (Style)
/// - app_sizes: ثابت (للـ layouts والأبعاد)
///
/// الاستخدام:
/// - Padding بين العناصر
/// - أحجام الأزرار
/// - أحجام الأيقونات
/// - أبعاد الحاويات
///
class AppSizes {
  AppSizes._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) SPACING — المسافات
  // ═══════════════════════════════════════════════════════════

  /// 2.0 — مسافة متناهية الصغر
  static const double spaceTiny = 2.0;

  /// 4.0 — مسافة صغيرة جداً
  static const double spaceXs = 4.0;

  /// 8.0 — مسافة صغيرة
  static const double spaceSm = 8.0;

  /// 12.0 — مسافة صغيرة-متوسطة
  static const double spaceSmMd = 12.0;

  /// 16.0 — مسافة متوسطة (افتراضية)
  static const double spaceMd = 16.0;

  /// 20.0 — مسافة متوسطة-كبيرة
  static const double spaceMdLg = 20.0;

  /// 24.0 — مسافة كبيرة
  static const double spaceLg = 24.0;

  /// 32.0 — مسافة كبيرة جداً
  static const double spaceXl = 32.0;

  /// 48.0 — مسافة ضخمة
  static const double spaceXxl = 48.0;

  /// 64.0 — مسافة عملاقة
  static const double spaceHuge = 64.0;

  // ═══════════════════════════════════════════════════════════
  // 2) PADDING — جاهزة للاستخدام
  // ═══════════════════════════════════════════════════════════

  static const EdgeInsets paddingTiny = EdgeInsets.all(spaceTiny);
  static const EdgeInsets paddingXs = EdgeInsets.all(spaceXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spaceSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spaceMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spaceLg);
  static const EdgeInsets paddingXl = EdgeInsets.all(spaceXl);

  /// padding أفقي فقط
  static const EdgeInsets paddingHorizontalSm =
      EdgeInsets.symmetric(horizontal: spaceSm);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: spaceMd);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: spaceLg);

  /// padding رأسي فقط
  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: spaceSm);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: spaceMd);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: spaceLg);

  /// padding للـ screen (كل الصفحة)
  static const EdgeInsets screenPadding = EdgeInsets.all(spaceMd);
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: spaceMd);

  // ═══════════════════════════════════════════════════════════
  // 3) BORDER RADIUS — نصف قطر الحواف
  // ═══════════════════════════════════════════════════════════

  /// 2.0 — حواف شبه حادة
  static const double radiusXs = 2.0;

  /// 4.0 — حواف صغيرة
  static const double radiusSm = 4.0;

  /// 8.0 — حواف متوسطة
  static const double radiusMd = 8.0;

  /// 12.0 — حواف متوسطة-كبيرة
  static const double radiusLg = 12.0;

  /// 16.0 — حواف كبيرة
  static const double radiusXl = 16.0;

  /// 24.0 — حواف كبيرة جداً
  static const double radiusXxl = 24.0;

  /// 999 — حواف دائرية كاملة (Pill)
  static const double radiusPill = 999.0;

  /// BorderRadius جاهزة
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get borderRadiusPill =>
      BorderRadius.circular(radiusPill);

  // ═══════════════════════════════════════════════════════════
  // 4) ICON SIZES — أحجام الأيقونات
  // ═══════════════════════════════════════════════════════════

  /// 12 — أيقونة متناهية الصغر
  static const double iconTiny = 12.0;

  /// 16 — أيقونة صغيرة جداً
  static const double iconXs = 16.0;

  /// 20 — أيقونة صغيرة
  static const double iconSm = 20.0;

  /// 24 — أيقونة متوسطة (افتراضية)
  static const double iconMd = 24.0;

  /// 32 — أيقونة كبيرة
  static const double iconLg = 32.0;

  /// 48 — أيقونة كبيرة جداً
  static const double iconXl = 48.0;

  /// 64 — أيقونة ضخمة
  static const double iconXxl = 64.0;

  /// 80 — أيقونة عملاقة
  static const double iconHuge = 80.0;

  // ═══════════════════════════════════════════════════════════
  // 5) BUTTON SIZES — أحجام الأزرار
  // ═══════════════════════════════════════════════════════════

  /// ارتفاع زر صغير
  static const double buttonHeightSm = 32.0;

  /// ارتفاع زر متوسط (افتراضي)
  static const double buttonHeightMd = 44.0;

  /// ارتفاع زر كبير
  static const double buttonHeightLg = 52.0;

  /// ارتفاع زر ضخم
  static const double buttonHeightXl = 60.0;

  /// عرض زر صغير
  static const double buttonWidthSm = 80.0;

  /// عرض زر متوسط
  static const double buttonWidthMd = 120.0;

  /// عرض زر كبير
  static const double buttonWidthLg = 200.0;

  /// أبعاد زر دائري صغير (FAB mini)
  static const double fabMiniSize = 40.0;

  /// أبعاد FAB عادي
  static const double fabSize = 56.0;

  /// أبعاد FAB كبير
  static const double fabLargeSize = 96.0;

  // ═══════════════════════════════════════════════════════════
  // 6) AVATAR SIZES — أحجام الصور الشخصية
  // ═══════════════════════════════════════════════════════════

  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 120.0;

  // ═══════════════════════════════════════════════════════════
  // 7) FIELD / INPUT SIZES
  // ═══════════════════════════════════════════════════════════

  /// ارتفاع حقل إدخال صغير
  static const double inputHeightSm = 40.0;

  /// ارتفاع حقل إدخال متوسط (افتراضي)
  static const double inputHeightMd = 52.0;

  /// ارتفاع حقل إدخال كبير
  static const double inputHeightLg = 64.0;

  // ═══════════════════════════════════════════════════════════
  // 8) CARD / CONTAINER SIZES
  // ═══════════════════════════════════════════════════════════

  /// ارتفاع بطاقة صغيرة
  static const double cardHeightSm = 80.0;

  /// ارتفاع بطاقة متوسطة
  static const double cardHeightMd = 120.0;

  /// ارتفاع بطاقة كبيرة
  static const double cardHeightLg = 200.0;

  // ═══════════════════════════════════════════════════════════
  // 9) APP BAR / NAVIGATION
  // ═══════════════════════════════════════════════════════════

  /// ارتفاع AppBar (Material 3)
  static const double appBarHeight = 56.0;

  /// ارتفاع AppBar كبير
  static const double appBarHeightLarge = 120.0;

  /// ارتفاع BottomNavigationBar
  static const double bottomNavHeight = 64.0;

  /// عرض Sidebar (للـ Desktop)
  static const double sidebarWidth = 260.0;

  /// عرض Sidebar مصغّر
  static const double sidebarWidthCollapsed = 72.0;

  /// عرض NavigationRail
  static const double navRailWidth = 80.0;

  // ═══════════════════════════════════════════════════════════
  // 10) DIVIDER / BORDER THICKNESS
  // ═══════════════════════════════════════════════════════════

  static const double borderThin = 0.5;
  static const double borderNormal = 1.0;
  static const double borderMedium = 1.5;
  static const double borderThick = 2.0;
  static const double borderExtraThick = 3.0;

  /// سماكة Divider
  static const double dividerThickness = 1.0;

  // ═══════════════════════════════════════════════════════════
  // 11) ELEVATION
  // ═══════════════════════════════════════════════════════════

  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // ═══════════════════════════════════════════════════════════
  // 12) CHART / GRAPH SIZES (لـ fl_chart)
  // ═══════════════════════════════════════════════════════════

  /// ارتفاع الرسم البياني الصغير
  static const double chartHeightSm = 120.0;

  /// ارتفاع الرسم البياني المتوسط
  static const double chartHeightMd = 200.0;

  /// ارتفاع الرسم البياني الكبير
  static const double chartHeightLg = 300.0;

  /// سماكة خط الرسم
  static const double chartLineWidth = 2.0;

  /// سماكة أعمدة الرسم
  static const double chartBarWidth = 16.0;

  // ═══════════════════════════════════════════════════════════
  // 13) LIMITS (للـ constraints)
  // ═══════════════════════════════════════════════════════════

  /// أقصى عرض للمحتوى (للقراءة المريحة)
  static const double maxContentWidth = 1200.0;

  /// أقصى عرض لنموذج (Form)
  static const double maxFormWidth = 500.0;

  /// أقصى عرض لبطاقة
  static const double maxCardWidth = 400.0;

  /// أقصى عرض لصورة مصغرة
  static const double maxThumbnailSize = 120.0;

  // ═══════════════════════════════════════════════════════════
  // 14) ASPECT RATIOS
  // ═══════════════════════════════════════════════════════════

  static const double aspectSquare = 1.0;
  static const double aspectVideo = 16 / 9;
  static const double aspectPhoto = 4 / 3;
  static const double aspectCard = 1.5;
  static const double aspectBanner = 3.0;
}