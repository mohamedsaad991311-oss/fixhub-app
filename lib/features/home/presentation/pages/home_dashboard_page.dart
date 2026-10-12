// lib/features/home/presentation/pages/home_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/low_stock_alert_card.dart';
import '../widgets/quick_actions_bar.dart';
import '../widgets/recent_receipts_card.dart';
import '../widgets/revenue_chart_card.dart';
import '../widgets/stats_grid.dart';

/// ═══════════════════════════════════════════════════════════
/// HomeDashboardPage — الشاشة الرئيسية
/// ═══════════════════════════════════════════════════════════
///
/// مكونات:
/// - Welcome header (اسم المستخدم + الورشة)
/// - Stats Grid (4 كروت)
/// - Quick Actions (4 أزرار)
/// - Revenue Chart (7 أيام)
/// - Low Stock Alert Card
/// - Recent Receipts Card
///
class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final statsAsync = ref.watch(dashboardProvider);
    final stats = statsAsync.valueOrNull ?? DashboardStats.empty;
    final isLoading = statsAsync.isLoading;

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── Header ───
          SliverToBoxAdapter(
            child: _WelcomeHeader(
              fullName: authState?.user?.fullName ?? 'مرحباً',
              tenantName: authState?.tenant?.name ?? '',
            ),
          ),

          // ─── Content ───
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceMd,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSizes.spaceSm),

                // Stats Grid
                StatsGrid(
                  stats: stats,
                  onTapActive: () => _goToReceipts(context, onlyActive: true),
                  onTapReady: () => _goToReceipts(
                    context,
                    status: 'ready',
                  ),
                ),

                const SizedBox(height: AppSizes.spaceMd),

                // Quick Actions
                const _SectionTitle(title: 'إجراءات سريعة'),
                const SizedBox(height: AppSizes.spaceSm),
                QuickActionsBar(
                  onNewReceipt: () => _goToNewReceipt(context),
                  onAddInventory: () => context.push(RouteNames.inventory),
                  onAddExpense: () => context.push(RouteNames.expenses),
                  onSupplierInvoice: () => context.push(RouteNames.suppliers),
                ),

                const SizedBox(height: AppSizes.spaceMd),

                // Revenue Chart
                RevenueChartCard(
                  dailyRevenue: _mockDailyRevenue(stats.monthRevenue),
                ),

                const SizedBox(height: AppSizes.spaceMd),

                // Low Stock
                LowStockAlertCard(
                  items: stats.lowStockItems,
                  totalLowStock: stats.lowStockCount,
                  totalOutOfStock: stats.outOfStockCount,
                  onViewAll: () => context.push(RouteNames.inventory),
                ),

                const SizedBox(height: AppSizes.spaceMd),

                // Recent Receipts
                RecentReceiptsCard(
                  receipts: stats.recentReceipts,
                  onViewAll: () => context.push(RouteNames.receipts),
                  onTapReceipt: (r) => context.push(
                    '${RouteNames.receipts}/${r.id}',
                  ),
                ),

                const SizedBox(height: AppSizes.spaceXl),

                // Loading indicator في الأسفل لو بيحدث
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSizes.spaceLg),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTIONS
  // ═══════════════════════════════════════════════════════════

  void _goToNewReceipt(BuildContext context) {
    // TODO: افتح Receiving Wizard
    // context.push(RouteNames.receivingWizard);
    context.push(RouteNames.receipts);
  }

  void _goToReceipts(
    BuildContext context, {
    String? status,
    bool onlyActive = false,
  }) {
    // TODO: عدّل الـ route params
    context.push(RouteNames.receipts);
  }

  // ═══════════════════════════════════════════════════════════
  //  MOCK DATA (مؤقت لحد ما نضيف إيرادات حقيقية يومية)
  // ═══════════════════════════════════════════════════════════

  /// توليد 7 قيم إيرادات من total الشهري (توزيع عشوائي موزون)
  List<double> _mockDailyRevenue(double monthRevenue) {
    if (monthRevenue <= 0) return List.filled(7, 0);

    final avg = monthRevenue / 30;
    // توزيع بسيط: قيم حول المتوسط مع تباين بسيط
    return [
      avg * 0.7,
      avg * 1.1,
      avg * 0.9,
      avg * 1.3,
      avg * 0.6,
      avg * 1.4,
      avg * 1.0,
    ];
  }
}

// ═══════════════════════════════════════════════════════════════
//  WELCOME HEADER
// ═══════════════════════════════════════════════════════════════

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.fullName,
    required this.tenantName,
  });

  final String fullName;
  final String tenantName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spaceMd,
        AppSizes.spaceLg,
        AppSizes.spaceMd,
        AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: isDark ? 0.25 : 0.15),
            scheme.primary.withValues(alpha: isDark ? 0.05 : 0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(now),
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          if (tenantName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.store_outlined,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    tenantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'صباح الخير 👋';
    if (hour < 17) return 'نهارك سعيد 👋';
    return 'مساء الخير 👋';
  }
}

// ═══════════════════════════════════════════════════════════════
//  SECTION TITLE
// ═══════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
