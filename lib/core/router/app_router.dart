// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pin_lock_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/receiving/presentation/pages/receiving_wizard_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/receipts/presentation/pages/receipt_detail_page.dart';
import '../../features/receipts/presentation/pages/receipts_list_page.dart';
import '../providers/onboarding_provider.dart';
import 'app_placeholder_pages.dart';
import 'main_shell.dart';
import 'route_names.dart';

/// ═══════════════════════════════════════════════════════════
/// AppRouter — الـ Router الرئيسي (GoRouter)
/// ═══════════════════════════════════════════════════════════
///
/// يستخدم StatefulShellRoute.indexedStack للحفاظ على حالة كل تاب.
/// + redirect للتحقق من auth + onboarding
///
class AppRouter {
  AppRouter._();

  /// مفتاح الـ root navigator (للـ dialogs فوق كل حاجة)
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// إنشاء الـ GoRouter (يحتاج ref من ProviderScope)
  static GoRouter create({
    required Ref ref,
    String initialLocation = RouteNames.splash,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      debugLogDiagnostics: true,
      routes: _routes,
      errorBuilder: (context, state) => const NotFoundPlaceholderPage(),
      refreshListenable: _RouterRefresh(ref),
      redirect: (context, state) {
        final location = state.matchedLocation;

        // ─── 1) Splash → ما نعملش حاجة (الصفحة نفسها بتقرر) ───
        if (location == RouteNames.splash) return null;

        // ─── 2) قراءة الحالة ───
        final onboardingDone = ref.read(onboardingProvider);
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
        final isAuthLoading =
            authState.isLoading || (authState.valueOrNull?.isLoading ?? false);

        // ─── 3) Onboarding ───
        if (!onboardingDone) {
          if (location != RouteNames.onboarding) {
            return RouteNames.onboarding;
          }
          return null;
        }

        // لو خلّص onboarding وبيحاول يدخل onboarding تاني
        if (location == RouteNames.onboarding) {
          return isLoggedIn ? RouteNames.home : RouteNames.login;
        }

        // ─── 4) أثناء تحميل الـ auth → ما نعملش redirect ───
        if (isAuthLoading) return null;

        // ─── 4.b) لو رايح home والـ auth state لسه unknown → نسيبه يتحمّل ───
        if (location == RouteNames.home &&
            (authState.valueOrNull == null ||
                authState.valueOrNull?.status == AuthStatus.unknown)) {
          return null;
        }
        // ─── 5) Auth pages ───
        const authRoutes = <String>{
          RouteNames.login,
          RouteNames.signup,
          RouteNames.forgotPassword,
          RouteNames.resetPassword,
        };
        final isAuthRoute = authRoutes.contains(location);
        final isPinLock = location == RouteNames.pinLock;

        // ─── 6) Not logged in ───
        if (!isLoggedIn) {
          // PIN lock صفحة مش محتاجة login (بتستخدم PIN محلي)
          if (isPinLock) return null;
          // أي صفحة تانية غير auth → روح login
          if (!isAuthRoute) return RouteNames.login;
          return null;
        }

        // ─── 7) Logged in + في auth page → روح home ───
        if (isLoggedIn && isAuthRoute) {
          return RouteNames.home;
        }

        return null;
      },
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
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.resetPassword,
      name: 'resetPassword',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.pinLock,
      name: 'pinLock',
      builder: (context, state) => const PinLockPage(),
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
              builder: (context, state) => const HomeDashboardPage(),
            ),
          ],
        ),

        // ─── Branch 2: Receipts ───
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.receipts,
              name: 'receipts',
              builder: (context, state) => const ReceiptsListPage(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'receiptCreate',
                  builder: (context, state) =>
                      const ReceiptCreatePlaceholderPage(),
                ),
                // ⭐ Receiving Wizard
                GoRoute(
                  path: 'receiving',
                  name: 'receivingWizard',
                  builder: (context, state) => const ReceivingWizardPage(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'receiptDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ReceiptDetailPage(receiptId: id);
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
// Router Refresh — لربط Riverpod بـ GoRouter
// ═══════════════════════════════════════════════════════════

/// يُخبر GoRouter إنه يعيد تقييم الـ redirect لما الـ providers تتغير
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    // راقب authProvider
    ref.listen(
      authProvider,
      (_, __) => notifyListeners(),
    );
    // راقب onboardingProvider
    ref.listen(
      onboardingProvider,
      (_, __) => notifyListeners(),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Router Provider — يُبنى مرة واحدة
// ═══════════════════════════════════════════════════════════

/// Provider للـ GoRouter — يُبنى مرة واحدة ويُخزَّن
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.create(ref: ref);
});
