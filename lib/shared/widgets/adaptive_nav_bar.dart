// lib/shared/widgets/adaptive_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/locale_provider.dart';
import '../../core/router/nav_tabs.dart';
import '../../core/constants/app_breakpoints.dart';
import '../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════
/// AdaptiveNavBar — شريط تنقل ذكي حسب حجم الشاشة
/// ═══════════════════════════════════════════════════════════
///
/// - Mobile (< 600)   : BottomNavigationBar
/// - Tablet (600-900) : NavigationRail (compact)
/// - Desktop (> 900)  : NavigationRail (extended)
///
/// الاستخدام:
/// ```dart
/// AdaptiveNavBar(
///   currentIndex: 0,
///   onTabSelected: (index) { ... },
/// )
/// ```
///
class AdaptiveNavBar extends ConsumerWidget {
  /// الـ index الحالي
  final int currentIndex;

  /// callback عند اختيار تاب
  final ValueChanged<int> onTabSelected;

  /// Badges (اختياري — عدد الإشعارات لكل تاب)
  final Map<String, int>? badges;

  const AdaptiveNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.badges,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = AppBreakpoints.getDeviceType(context);

    switch (device) {
      case DeviceType.mobile:
        return _buildBottomBar(context, ref);
      case DeviceType.tablet:
        return _buildRail(context, ref, extended: false);
      case DeviceType.desktop:
      case DeviceType.wide:
      case DeviceType.ultraWide:
        return _buildRail(context, ref, extended: true);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 1) Bottom Navigation Bar (Mobile)
  // ═══════════════════════════════════════════════════════════

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabSelected,
      destinations: NavTabs.main.map((tab) {
        final badge = badges?[tab.key];
        return NavigationDestination(
          icon: _withBadge(
            Icon(tab.icon),
            badge,
            context,
          ),
          selectedIcon: _withBadge(
            Icon(tab.activeIcon),
            badge,
            context,
          ),
          label: tab.label(langCode),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 2) Navigation Rail (Tablet + Desktop)
  // ═══════════════════════════════════════════════════════════

  Widget _buildRail(
    BuildContext context,
    WidgetRef ref, {
    required bool extended,
  }) {
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;
    final scheme = Theme.of(context).colorScheme;
   
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabSelected,
      extended: extended,
      minWidth: extended ? null : AppSizes.navRailWidth,
      minExtendedWidth: extended ? AppSizes.sidebarWidth : null,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: extended
          ? Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.build_circle,
                    color: scheme.primary,
                    size: AppSizes.iconLg,
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Text(
                    'FixHub',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spaceMd,
              ),
              child: Icon(
                Icons.build_circle,
                color: scheme.primary,
                size: AppSizes.iconLg,
              ),
            ),
      trailing: extended
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceMd),
              child: IconButton(
                icon: const Icon(Icons.language),
                tooltip: 'تغيير اللغة',
                onPressed: () {
                  ref.read(localeProvider.notifier).toggleLocale();
                },
              ),
            ),
      destinations: NavTabs.main.map((tab) {
        final badge = badges?[tab.key];
        return NavigationRailDestination(
          icon: _withBadge(
            Icon(tab.icon),
            badge,
            context,
          ),
          selectedIcon: _withBadge(
            Icon(tab.activeIcon),
            badge,
            context,
            isSelected: true,
          ),
          label: Text(tab.label(langCode)),
          padding: extended
              ? const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceMd,
                  vertical: AppSizes.spaceXs,
                )
              : null,
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 3) Badge Helper
  // ═══════════════════════════════════════════════════════════

  Widget _withBadge(
    Widget icon,
    int? count,
    BuildContext context, {
    bool isSelected = false,
  }) {
    if (count == null || count <= 0) return icon;

    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.onError,
      child: icon,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// AdaptiveNavBarWrapper — نسخة wrapper للاستخدام المباشر
/// ═══════════════════════════════════════════════════════════
///
/// بتغلّف الـ Scaffold تلقائياً:
/// - Mobile: BottomNavigationBar
/// - Tablet/Desktop: Row (Rail + Body)
///
/// الاستخدام:
/// ```dart
/// AdaptiveNavBarWrapper(
///   currentIndex: 0,
///   onTabSelected: (i) {},
///   body: MyPage(),
/// )
/// ```
///
class AdaptiveNavBarWrapper extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final Widget body;
  final Map<String, int>? badges;
  final PreferredSizeWidget? appBar;

  const AdaptiveNavBarWrapper({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.body,
    this.badges,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final device = AppBreakpoints.getDeviceType(context);
    final isMobile = device == DeviceType.mobile;

    if (isMobile) {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: AdaptiveNavBar(
          currentIndex: currentIndex,
          onTabSelected: onTabSelected,
          badges: badges,
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          AdaptiveNavBar(
            currentIndex: currentIndex,
            onTabSelected: onTabSelected,
            badges: badges,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}