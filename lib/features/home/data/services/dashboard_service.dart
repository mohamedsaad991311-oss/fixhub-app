// lib/features/home/data/services/dashboard_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/expense_service.dart';
import '../../../../core/services/inventory_service.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../inventory/data/models/inventory_item.dart';
import '../../../receipts/data/models/receipt.dart';
import '../models/dashboard_stats.dart';

/// ═══════════════════════════════════════════════════════════
/// DashboardService — تجميع بيانات الـ Home Dashboard
/// ═══════════════════════════════════════════════════════════
///
/// بيجمع من 3 services:
/// - ReceiptService
/// - InventoryService
/// - ExpenseService
///
/// ويرجّع DashboardStats واحدة كاملة.
///
class DashboardService {
  DashboardService({
    required ReceiptService receiptService,
    required InventoryService inventoryService,
    required ExpenseService expenseService,
  })  : _receiptService = receiptService,
        _inventoryService = inventoryService,
        _expenseService = expenseService;

  final ReceiptService _receiptService;
  final InventoryService _inventoryService;
  final ExpenseService _expenseService;

  // ═══════════════════════════════════════════════════════════
  //  LOAD ALL
  // ═══════════════════════════════════════════════════════════

  /// تحميل كل الإحصائيات (parallel)
  Future<DashboardStats> loadStats() async {
    try {
      // 1. كل الـ futures مرة واحدة (parallel)
      final results = await Future.wait([
        _receiptStats(),
        _inventoryStats(),
        _expenseStats(),
        _recentReceipts(),
        _lowStockItems(),
      ]);

      final receiptStats = results[0] as _ReceiptStatsBundle;
      final inventoryStats = results[1] as InventoryStats;
      final expenseStats = results[2] as _ExpenseStatsBundle;
      final recentReceipts = results[3] as List<Receipt>;
      final lowStockItems = results[4] as List<InventoryItem>;

      return DashboardStats(
        // ─── Receipts ───
        totalReceipts: receiptStats.total,
        activeReceipts: receiptStats.active,
        readyReceipts: receiptStats.ready,
        todayReceivedReceipts: receiptStats.todayReceived,
        todayDeliveredReceipts: receiptStats.todayDelivered,
        delayedReceipts: receiptStats.delayed,

        // ─── Revenue ───
        todayRevenue: receiptStats.todayRevenue,
        monthRevenue: receiptStats.monthRevenue,
        pendingAmount: receiptStats.pending,

        // ─── Expenses ───
        monthExpenses: expenseStats.month,
        todayExpenses: expenseStats.today,

        // ─── Inventory ───
        totalItems: inventoryStats.totalItems,
        lowStockCount: inventoryStats.lowStockCount,
        outOfStockCount: inventoryStats.outOfStockCount,
        stockValue: inventoryStats.totalStockValue,

        // ─── Lists ───
        recentReceipts: recentReceipts,
        lowStockItems: lowStockItems,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DashboardService.loadStats error: $e');
      }
      return DashboardStats.empty;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  RECEIPT STATS (اليوم + الشهر + الكل)
  // ═══════════════════════════════════════════════════════════

  Future<_ReceiptStatsBundle> _receiptStats() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      // كل الإحصائيات (بلا فلتر تاريخي)
      final allStats = await _receiptService.getStats();

      // إحصائيات اليوم
      final todayStats = await _receiptService.getStats(
        fromDate: todayStart,
      );

      // إحصائيات الشهر
      final monthStats = await _receiptService.getStats(
        fromDate: monthStart,
      );

      return _ReceiptStatsBundle(
        total: allStats.total,
        active: allStats.activeCount,
        ready: allStats.countOf(ReceiptStatus.ready),
        todayReceived: todayStats.countOf(ReceiptStatus.received),
        todayDelivered: todayStats.countOf(ReceiptStatus.delivered),
        delayed: allStats.countOf(ReceiptStatus.waitingParts),
        todayRevenue: todayStats.totalRevenue,
        monthRevenue: monthStats.totalRevenue,
        pending: allStats.pendingAmount,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_receiptStats error: $e');
      }
      return const _ReceiptStatsBundle();
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  INVENTORY STATS
  // ═══════════════════════════════════════════════════════════

  Future<InventoryStats> _inventoryStats() async {
    try {
      return await _inventoryService.getStats();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_inventoryStats error: $e');
      }
      return InventoryStats.empty;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  EXPENSE STATS (اليوم + الشهر)
  // ═══════════════════════════════════════════════════════════

  Future<_ExpenseStatsBundle> _expenseStats() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // الشهر الحالي (from service)
      final monthSummary = await _expenseService.getCurrentMonthSummary();

      // اليوم
      final todaySummary = await _expenseService.getSummary(
        fromDate: todayStart,
      );

      return _ExpenseStatsBundle(
        month: monthSummary.total,
        today: todaySummary.total,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_expenseStats error: $e');
      }
      return const _ExpenseStatsBundle();
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  RECENT RECEIPTS (آخر 5)
  // ═══════════════════════════════════════════════════════════

  Future<List<Receipt>> _recentReceipts() async {
    try {
      return await _receiptService.list(
        const ReceiptFilter(
          sortBy: ReceiptSortBy.createdAt,
          sortAscending: false,
          limit: 5,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_recentReceipts error: $e');
      }
      return const [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  LOW STOCK ITEMS (أول 5)
  // ═══════════════════════════════════════════════════════════

  Future<List<InventoryItem>> _lowStockItems() async {
    try {
      final items = await _inventoryService.getLowStockItems(limit: 5);
      return items;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_lowStockItems error: $e');
      }
      return const [];
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  INTERNAL BUNDLES
// ═══════════════════════════════════════════════════════════════

/// Bundle لإحصائيات الإيصالات (مجمّعة)
class _ReceiptStatsBundle {
  const _ReceiptStatsBundle({
    this.total = 0,
    this.active = 0,
    this.ready = 0,
    this.todayReceived = 0,
    this.todayDelivered = 0,
    this.delayed = 0,
    this.todayRevenue = 0,
    this.monthRevenue = 0,
    this.pending = 0,
  });

  final int total;
  final int active;
  final int ready;
  final int todayReceived;
  final int todayDelivered;
  final int delayed;
  final double todayRevenue;
  final double monthRevenue;
  final double pending;
}

/// Bundle لإحصائيات المصروفات
class _ExpenseStatsBundle {
  const _ExpenseStatsBundle({
    this.month = 0,
    this.today = 0,
  });

  final double month;
  final double today;
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDER
// ═══════════════════════════════════════════════════════════════

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(
    receiptService: ref.watch(receiptServiceProvider),
    inventoryService: ref.watch(inventoryServiceProvider),
    expenseService: ref.watch(expenseServiceProvider),
  );
});
