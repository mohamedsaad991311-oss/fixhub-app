// lib/features/home/presentation/providers/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dashboard_stats.dart';
import '../../data/services/dashboard_service.dart';

/// ═══════════════════════════════════════════════════════════
/// DashboardProvider — حالة الـ Home Dashboard
/// ═══════════════════════════════════════════════════════════
///
/// - `dashboardStatsProvider`: `AsyncValue<DashboardStats>`
/// - `refreshDashboardProvider`: دالة لإعادة التحميل
///
class DashboardNotifier extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    final service = ref.watch(dashboardServiceProvider);
    return service.loadStats();
  }

  /// إعادة تحميل الإحصائيات يدوياً
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final service = ref.read(dashboardServiceProvider);
    final stats = await service.loadStats();
    state = AsyncValue.data(stats);
  }
}

/// ═══════════════════════════════════════════════════════════
/// PROVIDERS
/// ═══════════════════════════════════════════════════════════

/// الـ provider الرئيسي — `AsyncValue<DashboardStats>`
final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardStats>(
  DashboardNotifier.new,
);

/// اختصار: الحالة الجاهزة (DashboardStats)
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  return ref.watch(dashboardProvider).valueOrNull ?? DashboardStats.empty;
});

/// اختصار: هل التحميل جاري؟
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isLoading;
});

/// اختصار: هل فيه خطأ؟
final dashboardErrorProvider = Provider<Object?>((ref) {
  return ref.watch(dashboardProvider).error;
});

/// اختصار: هل البيانات فاضية تماماً؟ (لأول استخدام)
final dashboardEmptyProvider = Provider<bool>((ref) {
  final stats = ref.watch(dashboardStatsProvider);
  return stats.totalReceipts == 0 &&
      stats.totalItems == 0 &&
      stats.monthExpenses == 0;
});
