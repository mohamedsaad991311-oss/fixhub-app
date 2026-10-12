// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
//
import 'app_placeholder_pages.dart';
import 'main_shell.dart';
import 'route_names.dart';

/// ═══════════════════════════════════════════════════════════
/// AppRouter — الـ Router الرئيسي (GoRouter)
/// ═══════════════════════════════════════════════════════════
///
/// يستخدم StatefulShellRoute.indexedStack للحفاظ على حالة كل تاب.
///
class AppRouter {
  AppRouter._();

  /// مفتاح الـ root navigator (للـ dialogs فوق كل حاجة)
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// إنشاء الـ GoRouter
  static GoRouter create({
    String initialLocation = RouteNames.splash,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => const NotFoundPlaceholderPage(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // قائمة الـ Routes
  // ═══════════════════════════════════════════════════════════

  static final List<RouteBase> _routes = [
    // ─── Splash (root) ───
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // ─── Onboarding ───
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // ─── Auth (بدون Shell) ───
    // ─── Auth (بدون Shell) ───
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.signup,
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordPlaceholderPage(),
    ),
    GoRoute(
      path: RouteNames.resetPassword,
      name: 'resetPassword',
      builder: (context, state) => const ResetPasswordPlaceholderPage(),
    ),
    GoRoute(
      path: RouteNames.pinLock,
      name: 'pinLock',
      builder: (context, state) => const PinLockPlaceholderPage(),
    ),

    // ═══════════════════════════════════════════════════════
    // Main Shell (StatefulShellRoute — 5 branches)
    // ═══════════════════════════════════════════════════════

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellRailWrapper(navigationShell: navigationShell);
      },
      branches: [
        // ─── Branch 1: Home ───
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (context, state) => const _HomePlaceholder(),
            ),
          ],
        ),

        // ─── Branch 2: Receipts ───
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.receipts,
              name: 'receipts',
              builder: (context, state) => const ReceiptsPlaceholderPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'receiptCreate',
                  builder: (context, state) =>
                      const ReceiptCreatePlaceholderPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'receiptDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ReceiptDetailPlaceholderPage(id: id);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'receiptEdit',
                      builder: (context, state) {
                        final id = state.pathParameters['id'] ?? '';
                        return ReceiptEditPlaceholderPage(id: id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ─── Branch 3: Inventory ───
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.inventory,
              name: 'inventory',
              builder: (context, state) => const InventoryPlaceholderPage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'inventoryEdit',
                  builder: (context, state) =>
                      const InventoryEditPlaceholderPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'inventoryDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return InventoryDetailPlaceholderPage(id: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // ─── Branch 4: Reports ───
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.reports,
              name: 'reports',
              builder: (context, state) => const ReportsPlaceholderPage(),
            ),
          ],
        ),

        // ─── Branch 5: Settings ───
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.settings,
              name: 'settings',
              builder: (context, state) => const SettingsPlaceholderPage(),
              routes: [
                GoRoute(
                  path: 'shop-info',
                  name: 'shopInfo',
                  builder: (context, state) => const ShopInfoPlaceholderPage(),
                ),
                GoRoute(
                  path: 'whatsapp',
                  name: 'whatsappSettings',
                  builder: (context, state) =>
                      const WhatsappSettingsPlaceholderPage(),
                ),
                GoRoute(
                  path: 'language',
                  name: 'languageSettings',
                  builder: (context, state) =>
                      const LanguageSettingsPlaceholderPage(),
                ),
                GoRoute(
                  path: 'security',
                  name: 'securitySettings',
                  builder: (context, state) =>
                      const SecuritySettingsPlaceholderPage(),
                ),
                GoRoute(
                  path: 'about',
                  name: 'about',
                  builder: (context, state) => const AboutPlaceholderPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════
    // Routes خارج الـ Shell
    // ═══════════════════════════════════════════════════════

    // ─── Suppliers ───
    GoRoute(
      path: RouteNames.suppliers,
      name: 'suppliers',
      builder: (context, state) => const SuppliersPlaceholderPage(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'supplierEdit',
          builder: (context, state) => const SupplierEditPlaceholderPage(),
        ),
        GoRoute(
          path: ':id',
          name: 'supplierDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return SupplierDetailPlaceholderPage(id: id);
          },
          routes: [
            GoRoute(
              path: 'invoices',
              name: 'supplierInvoices',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return SupplierInvoicesPlaceholderPage(id: id);
              },
            ),
            GoRoute(
              path: 'payments',
              name: 'supplierPayments',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return SupplierPaymentsPlaceholderPage(id: id);
              },
            ),
            GoRoute(
              path: 'returns',
              name: 'supplierReturns',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                return SupplierReturnsPlaceholderPage(id: id);
              },
            ),
          ],
        ),
      ],
    ),

    // ─── Staff ───
    GoRoute(
      path: RouteNames.staff,
      name: 'staff',
      builder: (context, state) => const StaffPlaceholderPage(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'staffEdit',
          builder: (context, state) => const StaffEditPlaceholderPage(),
        ),
        GoRoute(
          path: ':id',
          name: 'staffDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return StaffDetailPlaceholderPage(id: id);
          },
        ),
      ],
    ),

    // ─── Expenses ───
    GoRoute(
      path: RouteNames.expenses,
      name: 'expenses',
      builder: (context, state) => const ExpensesPlaceholderPage(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'expenseEdit',
          builder: (context, state) => const ExpenseEditPlaceholderPage(),
        ),
        GoRoute(
          path: ':id',
          name: 'expenseDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return ExpenseDetailPlaceholderPage(id: id);
          },
        ),
      ],
    ),

    // ─── Delivery ───
    GoRoute(
      path: RouteNames.delivery,
      name: 'delivery',
      builder: (context, state) => const DeliveryPlaceholderPage(),
    ),

    // ─── Scanner ───
    GoRoute(
      path: RouteNames.scanner,
      name: 'scanner',
      builder: (context, state) => const ScannerPlaceholderPage(),
    ),

    // ─── Tracking ───
    GoRoute(
      path: RouteNames.tracking,
      name: 'tracking',
      builder: (context, state) => const TrackingPlaceholderPage(),
      routes: [
        GoRoute(
          path: ':token',
          name: 'trackingDetail',
          builder: (context, state) {
            final token = state.pathParameters['token'] ?? '';
            return TrackingDetailPlaceholderPage(token: token);
          },
        ),
      ],
    ),

    // ─── Cloud Sync ───
    GoRoute(
      path: RouteNames.cloudSync,
      name: 'cloudSync',
      builder: (context, state) => const CloudSyncPlaceholderPage(),
    ),

    // ─── Backup ───
    GoRoute(
      path: RouteNames.backup,
      name: 'backup',
      builder: (context, state) => const BackupPlaceholderPage(),
    ),

    // ─── Activity Log ───
    GoRoute(
      path: RouteNames.activityLog,
      name: 'activityLog',
      builder: (context, state) => const ActivityLogPlaceholderPage(),
    ),

    // ─── Subscription ───
    GoRoute(
      path: RouteNames.subscription,
      name: 'subscription',
      builder: (context, state) => const SubscriptionPlaceholderPage(),
    ),
  ];
}

// ═══════════════════════════════════════════════════════════
// Home Placeholder (مؤقت — هنستبدله في المرحلة 9)
// ═══════════════════════════════════════════════════════════

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        backgroundColor: scheme.surfaceContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard,
                size: 80,
                color: scheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'الصفحة الرئيسية',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'قيد التطوير — المرحلة 9',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
