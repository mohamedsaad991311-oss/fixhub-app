// lib/features/home/data/models/dashboard_stats.dart

import '../../../inventory/data/models/inventory_item.dart';
import '../../../receipts/data/models/receipt.dart';

/// ═══════════════════════════════════════════════════════════
/// DashboardStats — إحصائيات شاملة للـ Home Dashboard
/// ═══════════════════════════════════════════════════════════
///
/// بيجمع بيانات من:
/// - ReceiptService.getStats()
/// - InventoryService.getStats()
/// - ExpenseService.getCurrentMonthSummary()
///
class DashboardStats {
  // ─── Receipts ───
  final int totalReceipts;
  final int activeReceipts; // قيد العمل
  final int readyReceipts; // جاهز للتسليم
  final int todayReceivedReceipts; // مستلمة اليوم
  final int todayDeliveredReceipts; // مسلّمة اليوم
  final int delayedReceipts; // متأخرة

  // ─── Revenue ───
  final double todayRevenue; // مبيعات اليوم
  final double monthRevenue; // مبيعات الشهر
  final double pendingAmount; // مبالغ معلقة

  // ─── Expenses ───
  final double monthExpenses; // مصروفات الشهر
  final double todayExpenses; // مصروفات اليوم

  // ─── Inventory ───
  final int totalItems;
  final int lowStockCount; // قاربت تخلص
  final int outOfStockCount; // خلصت
  final double stockValue; // قيمة المخزون

  // ─── Lists للعرض ───
  final List<Receipt> recentReceipts; // آخر 5
  final List<InventoryItem> lowStockItems; // أول 5

  const DashboardStats({
    this.totalReceipts = 0,
    this.activeReceipts = 0,
    this.readyReceipts = 0,
    this.todayReceivedReceipts = 0,
    this.todayDeliveredReceipts = 0,
    this.delayedReceipts = 0,
    this.todayRevenue = 0,
    this.monthRevenue = 0,
    this.pendingAmount = 0,
    this.monthExpenses = 0,
    this.todayExpenses = 0,
    this.totalItems = 0,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.stockValue = 0,
    this.recentReceipts = const [],
    this.lowStockItems = const [],
  });

  /// نسخة فاضية (initial)
  static const DashboardStats empty = DashboardStats();

  /// صافي الربح (تقريبي — المبيعات - المصروفات)
  double get netProfit => monthRevenue - monthExpenses;

  /// هل فيه تنبيهات مخزون؟
  bool get hasStockAlerts => lowStockCount > 0 || outOfStockCount > 0;

  /// هل فيه إيصالات جاهزة للتسليم؟
  bool get hasReadyReceipts => readyReceipts > 0;

  DashboardStats copyWith({
    int? totalReceipts,
    int? activeReceipts,
    int? readyReceipts,
    int? todayReceivedReceipts,
    int? todayDeliveredReceipts,
    int? delayedReceipts,
    double? todayRevenue,
    double? monthRevenue,
    double? pendingAmount,
    double? monthExpenses,
    double? todayExpenses,
    int? totalItems,
    int? lowStockCount,
    int? outOfStockCount,
    double? stockValue,
    List<Receipt>? recentReceipts,
    List<InventoryItem>? lowStockItems,
  }) {
    return DashboardStats(
      totalReceipts: totalReceipts ?? this.totalReceipts,
      activeReceipts: activeReceipts ?? this.activeReceipts,
      readyReceipts: readyReceipts ?? this.readyReceipts,
      todayReceivedReceipts:
          todayReceivedReceipts ?? this.todayReceivedReceipts,
      todayDeliveredReceipts:
          todayDeliveredReceipts ?? this.todayDeliveredReceipts,
      delayedReceipts: delayedReceipts ?? this.delayedReceipts,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      monthRevenue: monthRevenue ?? this.monthRevenue,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      monthExpenses: monthExpenses ?? this.monthExpenses,
      todayExpenses: todayExpenses ?? this.todayExpenses,
      totalItems: totalItems ?? this.totalItems,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      stockValue: stockValue ?? this.stockValue,
      recentReceipts: recentReceipts ?? this.recentReceipts,
      lowStockItems: lowStockItems ?? this.lowStockItems,
    );
  }

  @override
  String toString() => 'DashboardStats('
      'receipts: $totalReceipts, '
      'active: $activeReceipts, '
      'revenue: $monthRevenue, '
      'expenses: $monthExpenses)';
}
