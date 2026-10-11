import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/expenses/data/models/expense.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  EXPENSE FILTER
// ═══════════════════════════════════════════════════════════════

class ExpenseFilter {
  const ExpenseFilter({
    this.category,
    this.paymentMethod,
    this.search,
    this.fromDate,
    this.toDate,
    this.onlyRecurring = false,
    this.sortBy = ExpenseSortBy.date,
    this.sortAscending = false,
    this.limit = 100,
    this.offset = 0,
  });

  final ExpenseCategory? category;
  final ExpensePaymentMethod? paymentMethod;
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool onlyRecurring;
  final ExpenseSortBy sortBy;
  final bool sortAscending;
  final int limit;
  final int offset;

  ExpenseFilter copyWith({
    ExpenseCategory? category,
    bool clearCategory = false,
    ExpensePaymentMethod? paymentMethod,
    bool clearPayment = false,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    bool? onlyRecurring,
    ExpenseSortBy? sortBy,
    bool? sortAscending,
    int? limit,
    int? offset,
  }) {
    return ExpenseFilter(
      category: clearCategory ? null : (category ?? this.category),
      paymentMethod:
          clearPayment ? null : (paymentMethod ?? this.paymentMethod),
      search: search ?? this.search,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      onlyRecurring: onlyRecurring ?? this.onlyRecurring,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

enum ExpenseSortBy { date, amount, category, createdAt }

// ═══════════════════════════════════════════════════════════════
//  EXPENSE PERIOD SUMMARY
// ═══════════════════════════════════════════════════════════════

/// ملخص مصروفات لفترة (شهر/سنة/مخصص)
class PeriodExpenseSummary {
  const PeriodExpenseSummary({
    required this.summary,
    required this.from,
    required this.to,
    required this.monthlyBreakdown,
  });

  final ExpenseSummary summary;
  final DateTime from;
  final DateTime to;

  /// تفصيل شهري: مفتاح = "YYYY-MM" → مجموع
  final Map<String, double> monthlyBreakdown;

  /// نسخة فارغة (استخدم static getter بدل const)
  static PeriodExpenseSummary get empty => PeriodExpenseSummary(
        summary: const ExpenseSummary(),
        from: DateTime(1970),
        to: DateTime(1970),
        monthlyBreakdown: const {},
      );
}

// ═══════════════════════════════════════════════════════════════
//  EXPENSE SERVICE
// ═══════════════════════════════════════════════════════════════

class ExpenseService {
  ExpenseService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'expenses';

  // ─────────────────────────────────────────────────────────────
  //  READ
  // ─────────────────────────────────────────────────────────────

  /// قائمة المصروفات مع فلترة كاملة
  Future<List<Expense>> list([
    ExpenseFilter filter = const ExpenseFilter(),
  ]) async {
    try {
      var query = _client.from(_table).select();

      if (filter.category != null) {
        query = query.eq('category', filter.category!.name);
      }

      if (filter.paymentMethod != null) {
        query = query.eq('payment_method', filter.paymentMethod!.name);
      }

      if (filter.search != null && filter.search!.trim().isNotEmpty) {
        final s = filter.search!.trim();
        query = query.or(
          'description.ilike.%$s%,'
          'vendor.ilike.%$s%,'
          'notes.ilike.%$s%',
        );
      }

      if (filter.fromDate != null) {
        query = query.gte('expense_date', _dateOnly(filter.fromDate!));
      }
      if (filter.toDate != null) {
        query = query.lte('expense_date', _dateOnly(filter.toDate!));
      }

      final column = _sortColumn(filter.sortBy);
      final data = await query
          .order(column, ascending: filter.sortAscending)
          .range(filter.offset, filter.offset + filter.limit - 1);

      var items = (data as List)
          .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // client-side: onlyRecurring
      if (filter.onlyRecurring) {
        items = items.where((e) => e.isRecurring).toList();
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.list error: $e');
      }
      return const [];
    }
  }

  Future<Expense?> getById(String id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Expense.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.getById error: $e');
      }
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  CREATE / UPDATE / DELETE
  // ─────────────────────────────────────────────────────────────

  Future<Expense?> create(Expense expense) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return null;

      final payload = expense.toInsertJson()
        ..['tenant_id'] = tenantId
        ..['created_by'] = userId;

      final inserted =
          await _client.from(_table).insert(payload).select().single();

      return Expense.fromJson(Map<String, dynamic>.from(inserted));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.create error: $e');
      }
      return null;
    }
  }

  /// إنشاء مجموعة دفعة واحدة (مثلاً مصاريف ثابتة شهرية)
  Future<int> createMany(List<Expense> expenses) async {
    if (expenses.isEmpty) return 0;
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return 0;

      final payloads = expenses
          .map((e) => e.toInsertJson()
            ..['tenant_id'] = tenantId
            ..['created_by'] = userId)
          .toList();

      final inserted = await _client.from(_table).insert(payloads).select('id');

      return (inserted as List).length;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.createMany error: $e');
      }
      return 0;
    }
  }

  Future<Expense?> update(Expense expense) async {
    try {
      final payload = expense.toJson()
        ..remove('id')
        ..remove('tenant_id')
        ..remove('created_at')
        ..remove('created_by');

      final updated = await _client
          .from(_table)
          .update(payload)
          .eq('id', expense.id)
          .select()
          .single();

      return Expense.fromJson(Map<String, dynamic>.from(updated));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.update error: $e');
      }
      return null;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.delete error: $e');
      }
      return false;
    }
  }

  /// حذف مجموعة (bulk)
  Future<int> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return 0;
    try {
      await _client.from(_table).delete().inFilter('id', ids);
      return ids.length;
    } catch (_) {
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SUMMARIES (التقارير)
  // ─────────────────────────────────────────────────────────────

  /// ملخص مصروفات لفترة زمنية
  Future<ExpenseSummary> getSummary({
    DateTime? fromDate,
    DateTime? toDate,
    ExpenseCategory? category,
  }) async {
    try {
      final expenses = await _fetchForSummary(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );
      return ExpenseSummary.fromExpenses(expenses);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.getSummary error: $e');
      }
      return const ExpenseSummary();
    }
  }

  /// ملخص الشهر الحالي
  Future<ExpenseSummary> getCurrentMonthSummary() {
    final now = DateTime.now();
    return getSummary(
      fromDate: DateTime(now.year, now.month, 1),
      toDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  /// ملخص السنة الحالية
  Future<ExpenseSummary> getCurrentYearSummary() {
    final now = DateTime.now();
    return getSummary(
      fromDate: DateTime(now.year, 1, 1),
      toDate: DateTime(now.year, 12, 31, 23, 59, 59),
    );
  }

  /// ملخص شامل مع تفصيل شهري (للتقارير)
  Future<PeriodExpenseSummary> getPeriodSummary({
    required DateTime fromDate,
    required DateTime toDate,
    ExpenseCategory? category,
  }) async {
    try {
      final expenses = await _fetchForSummary(
        fromDate: fromDate,
        toDate: toDate,
        category: category,
      );

      final summary = ExpenseSummary.fromExpenses(expenses);
      final monthly = <String, double>{};

      for (final e in expenses) {
        final key = '${e.expenseDate.year}-${_pad(e.expenseDate.month)}';
        monthly[key] = (monthly[key] ?? 0) + e.amount;
      }

      return PeriodExpenseSummary(
        summary: summary,
        from: fromDate,
        to: toDate,
        monthlyBreakdown: monthly,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ExpenseService.getPeriodSummary error: $e');
      }
      return PeriodExpenseSummary.empty;
    }
  }

  /// مصاريف فئة معيّنة خلال فترة
  Future<Map<ExpenseCategory, double>> getByCategory({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final expenses = await _fetchForSummary(
        fromDate: fromDate,
        toDate: toDate,
      );

      final map = <ExpenseCategory, double>{};
      for (final e in expenses) {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// أعلى المصروفات في فترة
  Future<List<Expense>> getTopExpenses({
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 10,
  }) async {
    try {
      var query = _client.from(_table).select();

      if (fromDate != null) {
        query = query.gte('expense_date', _dateOnly(fromDate));
      }
      if (toDate != null) {
        query = query.lte('expense_date', _dateOnly(toDate));
      }

      final data = await query.order('amount', ascending: false).limit(limit);

      return (data as List)
          .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  RECURRING EXPENSES
  // ─────────────────────────────────────────────────────────────

  /// جلب المصروفات الثابتة (فئات شهرية)
  Future<List<Expense>> getRecurringExpenses() async {
    try {
      final recurringCategories = ExpenseCategory.values
          .where((c) => c.isRecurring)
          .map((c) => c.name)
          .toList();

      if (recurringCategories.isEmpty) return const [];

      final data = await _client
          .from(_table)
          .select()
          .inFilter('category', recurringCategories)
          .order('expense_date', ascending: false)
          .limit(200);

      return (data as List)
          .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// تجميع المصروفات الثابتة حسب الفئة (للعرض الشهري)
  Future<Map<ExpenseCategory, double>> getRecurringBreakdown({
    DateTime? month,
  }) async {
    try {
      final m = month ?? DateTime.now();
      final from = DateTime(m.year, m.month, 1);
      final to = DateTime(m.year, m.month + 1, 0);

      final expenses = await _fetchForSummary(fromDate: from, toDate: to);

      final map = <ExpenseCategory, double>{};
      for (final e in expenses) {
        if (e.isRecurring) {
          map[e.category] = (map[e.category] ?? 0) + e.amount;
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  INTERNAL HELPERS
  // ─────────────────────────────────────────────────────────────

  /// جلب مصروفات خام للتجميع (بدون pagination — للفترات المحدودة)
  Future<List<Expense>> _fetchForSummary({
    DateTime? fromDate,
    DateTime? toDate,
    ExpenseCategory? category,
  }) async {
    var query = _client.from(_table).select();

    if (fromDate != null) {
      query = query.gte('expense_date', _dateOnly(fromDate));
    }
    if (toDate != null) {
      query = query.lte('expense_date', _dateOnly(toDate));
    }
    if (category != null) {
      query = query.eq('category', category.name);
    }

    final data = await query.order('expense_date', ascending: false);

    return (data as List)
        .map((e) => Expense.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  String _sortColumn(ExpenseSortBy s) {
    switch (s) {
      case ExpenseSortBy.date:
        return 'expense_date';
      case ExpenseSortBy.amount:
        return 'amount';
      case ExpenseSortBy.category:
        return 'category';
      case ExpenseSortBy.createdAt:
        return 'created_at';
    }
  }

  /// YYYY-MM-DD (بدون وقت)
  String _dateOnly(DateTime d) => '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return ExpenseService(client: client, authService: authService);
});

/// Stream لقائمة المصروفات (auto-refresh كل 30 ثانية)
final expensesStreamProvider = StreamProvider.autoDispose
    .family<List<Expense>, ExpenseFilter>((ref, filter) async* {
  final service = ref.watch(expenseServiceProvider);

  yield await service.list(filter);

  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    yield await service.list(filter);
  }
});

/// Stream لملخص الشهر الحالي (للـ Dashboard)
final currentMonthExpenseSummaryProvider =
    FutureProvider.autoDispose<ExpenseSummary>((ref) async {
  final service = ref.watch(expenseServiceProvider);
  return service.getCurrentMonthSummary();
});
