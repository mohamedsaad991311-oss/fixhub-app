// lib/core/router/nav_tabs.dart

import 'package:flutter/material.dart';
import 'route_names.dart';

/// ═══════════════════════════════════════════════════════════
/// NavTab — نموذج تاب واحد
/// ═══════════════════════════════════════════════════════════
///
/// بيُستخدم في:
/// - AdaptiveNavBar (Bottom + Rail)
/// - AppSidebar (Desktop)
/// - MainShell (للتنقل)
///
class NavTab {
  /// المفتاح (للـ identification)
  final String key;

  /// الاسم بالعربي
  final String labelAr;

  /// الاسم بالإنجليزي
  final String labelEn;

  /// الأيقونة (غير مفعّلة)
  final IconData icon;

  /// الأيقونة (مفعّلة)
  final IconData activeIcon;

  /// المسار
  final String route;

  /// Badge (اختياري — للـ notifications)
  final int? badgeCount;

  const NavTab({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.badgeCount,
  });

  /// إرجاع الاسم حسب اللغة
  String label(String languageCode) {
    return languageCode == 'ar' ? labelAr : labelEn;
  }

  NavTab copyWith({int? badgeCount}) {
    return NavTab(
      key: key,
      labelAr: labelAr,
      labelEn: labelEn,
      icon: icon,
      activeIcon: activeIcon,
      route: route,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// NavTabs — قائمة التابات الرئيسية (5 تابات)
/// ═══════════════════════════════════════════════════════════
///
/// الترتيب مهم! بيتطابق مع:
/// - BottomNavigationBar
/// - NavigationRail
/// - Sidebar
///
class NavTabs {
  NavTabs._(); // منع الإنشاء

  /// التابات الرئيسية
  static const List<NavTab> main = [
    // ─── 1. الرئيسية ───
    NavTab(
      key: 'home',
      labelAr: 'الرئيسية',
      labelEn: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: RouteNames.home,
    ),

    // ─── 2. الإيصالات ───
    NavTab(
      key: 'receipts',
      labelAr: 'الإيصالات',
      labelEn: 'Receipts',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      route: RouteNames.receipts,
    ),

    // ─── 3. المخزون ───
    NavTab(
      key: 'inventory',
      labelAr: 'المخزون',
      labelEn: 'Inventory',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      route: RouteNames.inventory,
    ),

    // ─── 4. التقارير ───
    NavTab(
      key: 'reports',
      labelAr: 'التقارير',
      labelEn: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      route: RouteNames.reports,
    ),

    // ─── 5. الإعدادات ───
    NavTab(
      key: 'settings',
      labelAr: 'الإعدادات',
      labelEn: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      route: RouteNames.settings,
    ),
  ];

  /// إرجاع التاب حسب الـ key
  static NavTab? byKey(String key) {
    for (final tab in main) {
      if (tab.key == key) return tab;
    }
    return null;
  }

  /// إرجاع التاب حسب المسار
  static NavTab? byRoute(String route) {
    for (final tab in main) {
      if (tab.route == route) return tab;
    }
    return null;
  }

  /// إرجاع index التاب حسب المسار
  static int indexOfRoute(String route) {
    for (var i = 0; i < main.length; i++) {
      if (main[i].route == route) return i;
    }
    return -1;
  }
}