// lib/features/reports/presentation/providers/reports_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/expense_service.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../../core/services/supplier_service.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../expenses/data/models/expense.dart';

/// ═══════════════════════════════════════════════════════════
/// ReportsPeriod — الفترة الزمنية للتقارير
/// ═══════════════════════════════════════════════════════════
enum ReportsPeriod {
  today,
  week,
  month,
  year,
  custom,
}

extension ReportsPeriodX on ReportsPeriod {
  String get labelAr {
    switch (this) {
      case ReportsPeriod.today:
        return 'اليوم';
      case ReportsPeriod.week:
        return 'آخر 7 أيام';
      case ReportsPeriod.month:
        return 'هذا الشهر';
      case ReportsPeriod.year:
        return 'هذه السنة';
      case ReportsPeriod.custom:
        return 'مخصص';
    }
  }

  /// حساب تواريخ البداية والنهاية
  (DateTime from, DateTime to) range(
      {DateTime? customFrom, DateTime? customTo}) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (this) {
      case ReportsPeriod.today:
        return (todayStart, todayEnd);
      case ReportsPeriod.week:
        return (todayStart.subtract(const Duration(days: 6)), todayEnd);
      case ReportsPeriod.month:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case ReportsPeriod.year:
        return (
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
        );
      case ReportsPeriod.custom:
        return (
          customFrom ?? todayStart,
          customTo ?? todayEnd,
        );
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReportsStats — الإحصائيات المجمّعة
/// ═══════════════════════════════════════════════════════════
class ReportsStats {
  // ─── Receipts ───
  final int totalReceipts;
  final int deliveredReceipts;
  final int rejectedReceipts;
  final int activeReceipts;
  final Map<ReceiptStatus, int> byStatus;

  // ─── Revenue ───
  final double totalRevenue;
  final double totalDeposits;
  final double pendingAmount;

  // ─── Expenses ───
  final double totalExpenses;

  // ─── Inventory ───
  final int totalItems;
  final int lowStockCount;
  final int outOfStockCount;
  final double stockValue;

  // ─── Suppliers ───
  final int totalSuppliers;
  final double totalDebt; // مستحق للموردين
  final double totalOwed; // دفعات مقدمة

  // ─── Additional ───
  // ═══ Time Series (للرسوم البيانية) ═══
  final Map<DateTime, double> revenueSeries;
  final Map<DateTime, double> expenseSeries;
  final Map<ExpenseCategory, double> expensesByCategory;
  final List<Receipt> topReceipts; // أعلى 5 إيصالات

  const ReportsStats({
    this.totalReceipts = 0,
    this.deliveredReceipts = 0,
    this.rejectedReceipts = 0,
    this.activeReceipts = 0,
    this.byStatus = const {},
    this.totalRevenue = 0,
    this.totalDeposits = 0,
    this.pendingAmount = 0,
    this.totalExpenses = 0,
    this.totalItems = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.stockValue = 0,
    this.totalSuppliers = 0,
    this.totalDebt = 0,
    this.totalOwed = 0,
    this.revenueSeries = const {},
    this.expenseSeries = const {},
    this.expensesByCategory = const {},
    this.topReceipts = const [],
  });

  static const ReportsStats empty = ReportsStats();

  /// صافي الربح
  double get netProfit => totalRevenue - totalExpenses;

  /// هامش الربح %
  double get profitMargin {
    if (totalRevenue <= 0) return 0;
    return (netProfit / totalRevenue) * 100;
  }

  /// متوسط الإيراد لكل إيصال
  double get avgRevenuePerReceipt {
    if (deliveredReceipts <= 0) return 0;
    return totalRevenue / deliveredReceipts;
  }

  /// نسبة الإيصالات المسلّمة
  double get deliveryRate {
    if (totalReceipts <= 0) return 0;
    return (deliveredReceipts / totalReceipts) * 100;
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReportsState
/// ═══════════════════════════════════════════════════════════
class ReportsState {
  final ReportsPeriod period;
  final DateTime? customFrom;
  final DateTime? customTo;
  final ReportsStats stats;
  final bool isLoading;
  final String? errorMessage;

  const ReportsState({
    this.period = ReportsPeriod.month,
    this.customFrom,
    this.customTo,
    this.stats = ReportsStats.empty,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// التواريخ الحالية
  (DateTime, DateTime) get dateRange =>
      period.range(customFrom: customFrom, customTo: customTo);

  ReportsState copyWith({
    ReportsPeriod? period,
    DateTime? customFrom,
    DateTime? customTo,
    ReportsStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportsState(
      period: period ?? this.period,
      customFrom: customFrom ?? this.customFrom,
      customTo: customTo ?? this.customTo,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReportsNotifier
/// ═══════════════════════════════════════════════════════════
class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier(this._ref) : super(const ReportsState()) {
    load();
  }

  final Ref _ref;

  ReceiptService get _receiptService => _ref.read(receiptServiceProvider);
  InventoryService get _inventoryService => _ref.read(inventoryServiceProvider);
  SupplierService get _supplierService => _ref.read(supplierServiceProvider);
  ExpenseService get _expenseService => _ref.read(expenseServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final (from, to) = state.dateRange;

      // ═══ Receipts stats ═══
      final receiptStats = await _receiptService.getStats(
        fromDate: from,
        toDate: to,
      );

      // ═══ Inventory stats ═══
      final inventoryStats = await _inventoryService.getStats();

      // ═══ Supplier stats ═══
      final supplierStats = await _supplierService.getStats();

      // ═══ Expense summary ═══
      final expenseSummary = await _expenseService.getSummary(
        fromDate: from,
        toDate: to,
      );

      final expensesByCategory = await _expenseService.getByCategory(
        fromDate: from,
        toDate: to,
      );
      // ═══ Top receipts ═══
      final topReceipts = await _receiptService.list(
        ReceiptFilter(
          status: ReceiptStatus.delivered,
          fromDate: from,
          toDate: to,
          sortBy: ReceiptSortBy.total,
          sortAscending: false,
          limit: 5,
        ),
      );

      // ═══ Time Series (للرسوم البيانية) ═══
      final revenueSeries = await _receiptService.getRevenueTimeSeries(
        fromDate: from,
        toDate: to,
      );

      final expenseSeries = await _expenseService.getExpensesTimeSeries(
        fromDate: from,
        toDate: to,
      );
      final stats = ReportsStats(
        totalReceipts: receiptStats.total,
        deliveredReceipts: receiptStats.countOf(ReceiptStatus.delivered),
        rejectedReceipts: receiptStats.countOf(ReceiptStatus.rejected),
        activeReceipts: receiptStats.activeCount,
        byStatus: receiptStats.byStatus,
        totalRevenue: receiptStats.totalRevenue,
        totalDeposits: receiptStats.totalDeposits,
        pendingAmount: receiptStats.pendingAmount,
        totalExpenses: expenseSummary.total,
        totalItems: inventoryStats.totalItems,
        lowStockCount: inventoryStats.lowStockCount,
        outOfStockCount: inventoryStats.outOfStockCount,
        stockValue: inventoryStats.totalStockValue,
        totalSuppliers: supplierStats.totalSuppliers,
        totalDebt: supplierStats.totalDebt,
        totalOwed: supplierStats.totalOwed,
        revenueSeries: revenueSeries,
        expenseSeries: expenseSeries,
        expensesByCategory: expensesByCategory,
        topReceipts: topReceipts,
      );

      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      debugPrint('ReportsNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل التقارير',
      );
    }
  }

  Future<void> refresh() async {
    await load();
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  Future<void> setPeriod(ReportsPeriod period) async {
    state = state.copyWith(period: period, isLoading: true);
    await load();
  }

  Future<void> setCustomRange(DateTime from, DateTime to) async {
    state = state.copyWith(
      period: ReportsPeriod.custom,
      customFrom: from,
      customTo: to,
      isLoading: true,
    );
    await load();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ref);
});

/// اختصار: الإحصائيات
final reportsStatsProvider = Provider<ReportsStats>((ref) {
  return ref.watch(reportsProvider).stats;
});

/// اختصار: هل التحميل جاري؟
final reportsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(reportsProvider).isLoading;
});

/// اختصار: الفترة الحالية
final reportsPeriodProvider = Provider<ReportsPeriod>((ref) {
  return ref.watch(reportsProvider).period;
});

/// اختصار: الإيرادات
final reportsRevenueProvider = Provider<double>((ref) {
  return ref.watch(reportsStatsProvider).totalRevenue;
});

/// اختصار: المصروفات
final reportsExpensesProvider = Provider<double>((ref) {
  return ref.watch(reportsStatsProvider).totalExpenses;
});

/// اختصار: صافي الربح
final reportsNetProfitProvider = Provider<double>((ref) {
  return ref.watch(reportsStatsProvider).netProfit;
});

/// اختصار: الإيصالات حسب الحالة
final reportsReceiptsByStatusProvider =
    Provider<Map<ReceiptStatus, int>>((ref) {
  return ref.watch(reportsStatsProvider).byStatus;
});
