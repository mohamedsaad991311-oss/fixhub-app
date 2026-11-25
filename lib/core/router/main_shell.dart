// lib/core/router/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../constants/app_breakpoints.dart';
import '../localization/locale_provider.dart';
import '../../shared/widgets/adaptive_nav_bar.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _shouldShowBottomNav(context)
          ? _buildBottomNav(context, currentIndex)
          : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  bool _shouldShowBottomNav(BuildContext context) {
    return AppBreakpoints.isMobile(context);
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return AdaptiveNavBar(
      currentIndex: currentIndex,
      onTabSelected: (index) => _onTabSelected(index),
    );
  }

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class MainShellRailWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellRailWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = AppBreakpoints.getDeviceType(context);
    final isMobile = device == DeviceType.mobile;

    // Mobile: Bottom Nav
    if (isMobile) {
      return Scaffold(
        appBar: _buildAppBar(context, ref),
        body: navigationShell,
        bottomNavigationBar: AdaptiveNavBar(
          currentIndex: navigationShell.currentIndex,
          onTabSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      );
    }

    // Tablet/Desktop: Row (Rail + Content)
    return Scaffold(
      body: Row(
        children: [
          AdaptiveNavBar(
            currentIndex: navigationShell.currentIndex,
            onTabSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, ref),
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final currentIndex = navigationShell.currentIndex;

    // ✅ الترتيب الجديد (8 تابات): أضفنا "المحل" في المركز الثاني
    final titles = [
      'الرئيسية', // 0
      'المحل', // 1  <- القسم الجديد
      'الإيصالات', // 2
      'المخزون', // 3
      'المصاريف', // 4
      'التسليم', // 5
      'التقارير', // 6
      'الإعدادات', // 7
    ];

    final title =
        currentIndex < titles.length ? titles[currentIndex] : 'FixHub';

    return AppBar(
      title: Text(title),
      backgroundColor: scheme.surfaceContainer,
      actions: [
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          tooltip: 'إعدادات المظهر',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ThemeSettingsPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.language),
          tooltip: 'تغيير اللغة',
          onPressed: () {
            ref.read(localeProvider.notifier).toggleLocale();
          },
        ),
      ],
    );
  }
}

class AppBarBuilder {
  AppBarBuilder._();

  static PreferredSizeWidget? build(
    BuildContext context, {
    required String location,
    List<Widget>? extraActions,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final title = _titleForLocation(location);

    return AppBar(
      title: Text(title),
      backgroundColor: scheme.surfaceContainer,
      actions: [
        if (extraActions != null) ...extraActions,
      ],
    );
  }

  static String _titleForLocation(String location) {
    if (location.contains('/shop')) return 'المحل';
    if (location.contains('/receipts')) return 'الإيصالات';
    if (location.contains('/inventory')) return 'المخزون';
    if (location.contains('/expenses')) return 'المصاريف';
    if (location.contains('/delivery')) return 'التسليم';
    if (location.contains('/reports')) return 'التقارير';
    if (location.contains('/settings')) return 'الإعدادات';
    return 'FixHub';
  }
}
