// lib/core/router/nav_tabs.dart

import 'package:flutter/material.dart';
import 'route_names.dart';

class NavTab {
  final String key;
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final IconData activeIcon;
  final String route;
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

class NavTabs {
  NavTabs._();

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
    // ─── 4. المصاريف ───
    NavTab(
      key: 'expenses',
      labelAr: 'المصاريف',
      labelEn: 'Expenses',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      route: RouteNames.expenses,
    ),
    // ─── 5. التسليم (جديد) ───
    NavTab(
      key: 'delivery',
      labelAr: 'التسليم',
      labelEn: 'Delivery',
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      route: RouteNames.delivery,
    ),
    // ─── 6. التقارير ───
    NavTab(
      key: 'reports',
      labelAr: 'التقارير',
      labelEn: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      route: RouteNames.reports,
    ),
    // ─── 7. الإعدادات ───
    NavTab(
      key: 'settings',
      labelAr: 'الإعدادات',
      labelEn: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      route: RouteNames.settings,
    ),
  ];

  static NavTab? byKey(String key) {
    for (final tab in main) {
      if (tab.key == key) return tab;
    }
    return null;
  }

  static NavTab? byRoute(String route) {
    for (final tab in main) {
      if (tab.route == route) return tab;
    }
    return null;
  }

  static int indexOfRoute(String route) {
    for (var i = 0; i < main.length; i++) {
      if (main[i].route == route) return i;
    }
    return -1;
  }
}