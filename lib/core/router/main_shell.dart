// lib/core/router/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../constants/app_breakpoints.dart';
import '../localization/locale_provider.dart';
import '../../shared/widgets/adaptive_nav_bar.dart';

/// ═══════════════════════════════════════════════════════════
/// MainShell — الهيكل العام للتطبيق (Navigation + Content)
/// ═══════════════════════════════════════════════════════════
class MainShell extends ConsumerWidget {
  /// الـ navigation shell اللي جاي من GoRouter
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

/// ═══════════════════════════════════════════════════════════
/// MainShellRailWrapper — wrapper للـ Tablet/Desktop
/// ═══════════════════════════════════════════════════════════
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
                // ─── AppBar موحّد ───
                _buildAppBar(context, ref),
                // ─── المحتوى ───
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AppBar موحّد مع أزرار الثيم واللغة
  // ═══════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final currentIndex = navigationShell.currentIndex;

    // ✅ الترتيب الجديد للتابات (7 تابات)
    final titles = [
      'الرئيسية',    // 0
      'الإيصالات',   // 1
      'المخزون',     // 2
      'المصاريف',    // 3
      'التسليم',     // 4 (جديد)
      'التقارير',    // 5
      'الإعدادات',   // 6
    ];

    // حماية بسيطة لو الـ index خرج عن النطاق
    final title = currentIndex < titles.length ? titles[currentIndex] : 'FixHub';

    return AppBar(
      title: Text(title),
      backgroundColor: scheme.surfaceContainer,
      actions: [
        // ─── زر الثيم 🎨 ───
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
        // ─── زر اللغة 🌍 ───
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

/// ═══════════════════════════════════════════════════════════
/// AppBarBuilder — بناء AppBar ديناميكي حسب المسار
/// ═══════════════════════════════════════════════════════════
class AppBarBuilder {
  AppBarBuilder._();

  /// إرجاع AppBar حسب المسار
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
    if (location.contains('/receipts')) return 'الإيصالات';
    if (location.contains('/inventory')) return 'المخزون';
    if (location.contains('/expenses')) return 'المصاريف';
    if (location.contains('/delivery')) return 'التسليم'; // ✅ جديد
    if (location.contains('/reports')) return 'التقارير';
    if (location.contains('/settings')) return 'الإعدادات';
    return 'FixHub';
  }
}