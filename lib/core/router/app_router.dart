// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/inventory/data/models/inventory_item.dart';
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
import '../../features/inventory/presentation/pages/inventory_detail_page.dart';
import '../../features/inventory/presentation/pages/inventory_form_page.dart';
import '../../features/inventory/presentation/pages/inventory_list_page.dart';
import '../../features/suppliers/data/models/supplier.dart';
import '../../features/suppliers/presentation/pages/supplier_detail_page.dart';
import '../../features/suppliers/presentation/pages/supplier_form_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_list_page.dart';
import '../../features/staff/data/models/staff_member.dart';
import '../../features/staff/presentation/pages/staff_detail_page.dart';
import '../../features/staff/presentation/pages/staff_form_page.dart';
import '../../features/staff/presentation/pages/staff_list_page.dart';

// ✅ Expenses (Screens جديدة)
import '../../features/expenses/presentation/screens/expenses_list_screen.dart';
import '../../features/expenses/presentation/screens/expense_form_screen.dart';

import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/shop_info_page.dart';
import '../../features/settings/presentation/pages/whatsapp_settings_page.dart';
import '../../features/settings/presentation/pages/language_settings_page.dart';
import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../../features/settings/presentation/pages/security_settings_page.dart';
import '../../features/settings/presentation/pages/backup_settings_page.dart';
import '../../features/settings/presentation/pages/subscription_settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/activity_log/presentation/pages/activity_log_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/device_reset_request_page.dart';
import '../../features/devices/presentation/pages/devices_page.dart';
import '../../features/invitations/presentation/pages/invitations_page.dart';
import '../../features/tracking/presentation/pages/tracking_page.dart';
import '../../features/tracking/presentation/pages/tracking_detail_page.dart';
import '../../features/cloud_sync/presentation/pages/cloud_sync_page.dart';
import '../../features/delivery/presentation/pages/delivery_page.dart';
import '../providers/onboarding_provider.dart';
import 'app_placeholder_pages.dart';
import 'main_shell.dart';
import 'route_names.dart';

/// ═══════════════════════════════════════════════════════════
/// AppRouter — الـ Router الرئيسي (GoRouter)
/// ═══════════════════════════════════════════════════════════
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

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

        if (location == RouteNames.splash) return null;

        final onboardingDone = ref.read(onboardingProvider);
        final authState = ref.read(authProvider);
        final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
        final isAuthLoading =
            authState.isLoading || (authState.valueOrNull?.isLoading ?? false);

        if (!onboardingDone) {
          if (location != RouteNames.onboarding) {
            return RouteNames.onboarding;
          }
          return null;
        }

        if (location == RouteNames.onboarding) {
          return isLoggedIn ? RouteNames.home : RouteNames.login;
        }

        if (isAuthLoading) return null;

        if (location == RouteNames.home &&
            (authState.valueOrNull == null ||
                authState.valueOrNull?.status == AuthStatus.unknown)) {
          return null;
        }

        const authRoutes = <String>{
          RouteNames.login,
          RouteNames.signup,
          RouteNames.forgotPassword,
          RouteNames.resetPassword,
        };
        final isAuthRoute = authRoutes.contains(location);
        final isPinLock = location == RouteNames.pinLock;

        if (!isLoggedIn) {
          if (isPinLock) return null;
          if (!isAuthRoute) return RouteNames.login;
          return null;
        }

        if (isLoggedIn && isAuthRoute) {
          return RouteNames.home;
        }

        return null;
      },
    );
  }

  static final List<RouteBase> _routes = [
    // ─── Splash ───
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

    // ─── Auth ───
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
    // Main Shell (التابات الستة)
    // ═══════════════════════════════════════════════════════
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellRailWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (context, state) => const HomeDashboardPage(),
            ),
          ],
        ),

        // Branch 1: Receipts
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

        // Branch 2: Inventory
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.inventory,
              name: 'inventory',
              builder: (context, state) => const InventoryListPage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'inventoryEdit',
                  builder: (context, state) {
                    final item = state.extra;
                    return InventoryFormPage(
                      editingItem: item is InventoryItem ? item : null,
                    );
                  },
                ),
                GoRoute(
                  path: ':id',
                  name: 'inventoryDetail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return InventoryDetailPage(itemId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 3: Expenses (تم نقله هنا)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.expenses,
              name: 'expenses',
              builder: (context, state) => const ExpensesListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'expenseNew',
                  builder: (context, state) => const ExpenseFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  name: 'expenseEdit',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ExpenseFormScreen(expenseId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 4: Reports
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.reports,
              name: 'reports',
              builder: (context, state) => const ReportsPage(),
            ),
          ],
        ),

        // Branch 5: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RouteNames.settings,
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'shop-info',
                  name: 'shopInfo',
                  builder: (context, state) => const ShopInfoPage(),
                ),
                GoRoute(
                  path: 'whatsapp',
                  name: 'whatsappSettings',
                  builder: (context, state) => const WhatsappSettingsPage(),
                ),
                GoRoute(
                  path: 'theme',
                  name: 'themeSettings',
                  builder: (context, state) => const ThemeSettingsPage(),
                ),
                GoRoute(
                  path: 'language',
                  name: 'languageSettings',
                  builder: (context, state) => const LanguageSettingsPage(),
                ),
                GoRoute(
                  path: 'security',
                  name: 'securitySettings',
                  builder: (context, state) => const SecuritySettingsPage(),
                ),
                GoRoute(
                  path: 'backup',
                  name: 'backupSettings',
                  builder: (context, state) => const BackupSettingsPage(),
                ),
                GoRoute(
                  path: 'subscription',
                  name: 'subscriptionSettings',
                  builder: (context, state) =>
                      const SubscriptionSettingsPage(),
                ),
                GoRoute(
                  path: 'about',
                  name: 'about',
                  builder: (context, state) => const AboutPage(),
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
      builder: (context, state) => const SuppliersListPage(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'supplierEdit',
          builder: (context, state) {
            final supplier = state.extra;
            return SupplierFormPage(
              editingSupplier: supplier is Supplier ? supplier : null,
            );
          },
        ),
        GoRoute(
          path: ':id',
          name: 'supplierDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return SupplierDetailPage(supplierId: id);
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
      builder: (context, state) => const StaffListPage(),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'staffEdit',
          builder: (context, state) {
            final member = state.extra;
            return StaffFormPage(
              editingMember: member is StaffMember ? member : null,
            );
          },
        ),
        GoRoute(
          path: ':id',
          name: 'staffDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return StaffDetailPage(staffId: id);
          },
        ),
      ],
    ),

    // ─── Delivery ───
    GoRoute(
      path: RouteNames.delivery,
      name: 'delivery',
      builder: (context, state) => const DeliveryPage(),
    ),

    // ─── Scanner ───
    GoRoute(
      path: RouteNames.scanner,
      name: 'scanner',
      builder: (context, state) {
        final popOnDetect = state.uri.queryParameters['popOnDetect'] == 'true';
        return ScannerPage(popOnDetect: popOnDetect);
      },
    ),

    // ─── Tracking ───
    GoRoute(
      path: RouteNames.tracking,
      name: 'tracking',
      builder: (context, state) => const TrackingPage(),
      routes: [
        GoRoute(
          path: ':token',
          name: 'trackingDetail',
          builder: (context, state) {
            final token = state.pathParameters['token'] ?? '';
            return TrackingDetailPage(token: token);
          },
        ),
      ],
    ),

    // ─── Cloud Sync ───
    GoRoute(
      path: RouteNames.cloudSync,
      name: 'cloudSync',
      builder: (context, state) => const CloudSyncPage(),
    ),

    // ─── Backup ───
    GoRoute(
      path: RouteNames.backup,
      name: 'backup',
      builder: (context, state) => const BackupSettingsPage(),
    ),

    // ─── Activity Log ───
    GoRoute(
      path: RouteNames.activityLog,
      name: 'activityLog',
      builder: (context, state) => const ActivityLogPage(),
    ),

    // ─── Subscription ───
    GoRoute(
      path: RouteNames.subscription,
      name: 'subscription',
      builder: (context, state) => const SubscriptionSettingsPage(),
    ),

    // ─── Admin Dashboard ───
    GoRoute(
      path: '/admin',
      name: 'adminDashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),

    // ─── Device Reset Request ───
    GoRoute(
      path: '/device-reset-request',
      name: 'deviceResetRequest',
      builder: (context, state) => const DeviceResetRequestPage(),
    ),

    // ─── Devices ───
    GoRoute(
      path: '/devices',
      name: 'devices',
      builder: (context, state) => const DevicesPage(),
    ),

    // ─── Invitations ───
    GoRoute(
      path: '/invitations',
      name: 'invitations',
      builder: (context, state) => const InvitationsPage(),
    ),
  ];
}

// ═══════════════════════════════════════════════════════════
// Router Refresh
// ═══════════════════════════════════════════════════════════
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(onboardingProvider, (_, __) => notifyListeners());
  }
}

// ═══════════════════════════════════════════════════════════
// Router Provider
// ═══════════════════════════════════════════════════════════
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.create(ref: ref);
});