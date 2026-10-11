import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/suppliers/data/models/supplier.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  SUPPLIER FILTER
// ═══════════════════════════════════════════════════════════════

class SupplierFilter {
  const SupplierFilter({
    this.search,
    this.onlyActive = true,
    this.onlyWithDebt = false,
    this.sortBy = SupplierSortBy.name,
    this.sortAscending = true,
    this.limit = 100,
    this.offset = 0,
  });

  final String? search;
  final bool onlyActive;
  final bool onlyWithDebt;
  final SupplierSortBy sortBy;
  final bool sortAscending;
  final int limit;
  final int offset;

  SupplierFilter copyWith({
    String? search,
    bool? onlyActive,
    bool? onlyWithDebt,
    SupplierSortBy? sortBy,
    bool? sortAscending,
    int? limit,
    int? offset,
  }) {
    return SupplierFilter(
      search: search ?? this.search,
      onlyActive: onlyActive ?? this.onlyActive,
      onlyWithDebt: onlyWithDebt ?? this.onlyWithDebt,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

enum SupplierSortBy { name, balance, createdAt }

// ═══════════════════════════════════════════════════════════════
//  SUPPLIER STATS
// ═══════════════════════════════════════════════════════════════

class SupplierStats {
  const SupplierStats({
    required this.totalSuppliers,
    required this.activeSuppliers,
    required this.totalDebt,
    required this.totalOwed,
    required this.unpaidInvoices,
    required this.overdueInvoices,
  });

  final int totalSuppliers;
  final int activeSuppliers;
  final double totalDebt; // إجمالي اللي إحنا مدينين بيه
  final double totalOwed; // إجمالي اللي ليهم عندنا
  final int unpaidInvoices;
  final int overdueInvoices;

  static const SupplierStats empty = SupplierStats(
    totalSuppliers: 0,
    activeSuppliers: 0,
    totalDebt: 0,
    totalOwed: 0,
    unpaidInvoices: 0,
    overdueInvoices: 0,
  );
}

// ═══════════════════════════════════════════════════════════════
//  SUPPLIER SERVICE
// ═══════════════════════════════════════════════════════════════

class SupplierService {
  SupplierService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'suppliers';
  static const String _invoicesTable = 'supplier_invoices';
  static const String _paymentsTable = 'supplier_payments';
  static const String _returnsTable = 'supplier_returns';

  // ═════════════════════════════════════════════════════════════
  //  SUPPLIERS — READ
  // ═════════════════════════════════════════════════════════════

  Future<List<Supplier>> list([
    SupplierFilter filter = const SupplierFilter(),
  ]) async {
    try {
      var query = _client.from(_table).select();

      if (filter.onlyActive) {
        query = query.eq('is_active', true);
      }

      if (filter.onlyWithDebt) {
        query = query.gt('balance', 0);
      }

      if (filter.search != null && filter.search!.trim().isNotEmpty) {
        final s = filter.search!.trim();
        query = query.or(
          'name.ilike.%$s%,'
          'phone.ilike.%$s%,'
          'email.ilike.%$s%,'
          'contact_person.ilike.%$s%',
        );
      }

      final column = _supplierSortColumn(filter.sortBy);
      final data = await query
          .order(column, ascending: filter.sortAscending)
          .range(filter.offset, filter.offset + filter.limit - 1);

      return (data as List)
          .map((e) => Supplier.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.list error: $e');
      }
      return const [];
    }
  }

  Future<Supplier?> getById(String id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Supplier.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.getById error: $e');
      }
      return null;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  SUPPLIERS — CRUD
  // ═════════════════════════════════════════════════════════════

  Future<Supplier?> create(Supplier supplier) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) return null;

      final payload = supplier.toInsertJson()..['tenant_id'] = tenantId;

      final inserted =
          await _client.from(_table).insert(payload).select().single();

      return Supplier.fromJson(Map<String, dynamic>.from(inserted));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.create error: $e');
      }
      return null;
    }
  }

  Future<Supplier?> update(Supplier supplier) async {
    try {
      final payload = supplier.toJson()
        ..remove('id')
        ..remove('tenant_id')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('balance'); // الرصيد بيتغير تلقائياً عبر الفواتير/الدفعات

      final updated = await _client
          .from(_table)
          .update(payload)
          .eq('id', supplier.id)
          .select()
          .single();

      return Supplier.fromJson(Map<String, dynamic>.from(updated));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.update error: $e');
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
        print('SupplierService.delete error: $e');
      }
      return false;
    }
  }

  Future<bool> setActive(String id, {required bool isActive}) async {
    try {
      await _client.from(_table).update({'is_active': isActive}).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  INVOICES
  // ═════════════════════════════════════════════════════════════

  Future<List<SupplierInvoice>> listInvoices({
    String? supplierId,
    InvoiceStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      var query = _client.from(_invoicesTable).select();

      if (supplierId != null) {
        query = query.eq('supplier_id', supplierId);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (fromDate != null) {
        query = query.gte('invoice_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('invoice_date', toDate.toIso8601String());
      }

      final data = await query
          .order('invoice_date', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List)
          .map((e) => SupplierInvoice.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.listInvoices error: $e');
      }
      return const [];
    }
  }

  Future<SupplierInvoice?> getInvoiceById(String id) async {
    try {
      final data = await _client
          .from(_invoicesTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return null;
      return SupplierInvoice.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  /// إنشاء فاتورة + تحديث رصيد المورد تلقائياً
  Future<SupplierInvoice?> createInvoice(SupplierInvoice invoice) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return null;

      // احسب remaining + total تلقائياً من items
      final computedTotal = invoice.items.isEmpty
          ? invoice.total
          : invoice.items.fold<double>(0, (s, e) => s + e.total);
      final remaining = computedTotal - invoice.paid;

      // حدد الحالة تلقائياً
      final status = _computeInvoiceStatus(
        total: computedTotal,
        paid: invoice.paid,
        dueDate: invoice.dueDate,
        currentStatus: invoice.status,
      );

      final payload = invoice.toInsertJson()
        ..['tenant_id'] = tenantId
        ..['created_by'] = userId
        ..['total'] = computedTotal
        ..['remaining'] = remaining
        ..['status'] = status.name;

      final inserted =
          await _client.from(_invoicesTable).insert(payload).select().single();

      final created =
          SupplierInvoice.fromJson(Map<String, dynamic>.from(inserted));

      // حدّث رصيد المورد (يزيد بالـ remaining)
      await _adjustSupplierBalance(
        supplierId: invoice.supplierId,
        delta: remaining,
      );

      return created;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.createInvoice error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteInvoice(String id) async {
    try {
      // اجلب الفاتورة الأول لحساب التأثير
      final invoice = await getInvoiceById(id);
      if (invoice == null) return false;

      await _client.from(_invoicesTable).delete().eq('id', id);

      // ارجع الرصيد
      await _adjustSupplierBalance(
        supplierId: invoice.supplierId,
        delta: -invoice.remaining,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.deleteInvoice error: $e');
      }
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  PAYMENTS
  // ═════════════════════════════════════════════════════════════

  Future<List<SupplierPayment>> listPayments({
    String? supplierId,
    String? invoiceId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      var query = _client.from(_paymentsTable).select();

      if (supplierId != null) {
        query = query.eq('supplier_id', supplierId);
      }
      if (invoiceId != null) {
        query = query.eq('invoice_id', invoiceId);
      }
      if (fromDate != null) {
        query = query.gte('payment_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('payment_date', toDate.toIso8601String());
      }

      final data =
          await query.order('payment_date', ascending: false).limit(limit);

      return (data as List)
          .map((e) => SupplierPayment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// تسجيل دفعة + تحديث رصيد المورد (والفاتورة لو مربوطة)
  Future<SupplierPayment?> recordPayment(SupplierPayment payment) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return null;

      final payload = payment.toInsertJson()
        ..['tenant_id'] = tenantId
        ..['created_by'] = userId;

      final inserted =
          await _client.from(_paymentsTable).insert(payload).select().single();

      final created =
          SupplierPayment.fromJson(Map<String, dynamic>.from(inserted));

      // قلل رصيد المورد
      await _adjustSupplierBalance(
        supplierId: payment.supplierId,
        delta: -payment.amount,
      );

      // لو مربوطة بفاتورة → حدّثها
      if (payment.invoiceId != null) {
        await _applyPaymentToInvoice(
          invoiceId: payment.invoiceId!,
          amount: payment.amount,
        );
      }

      return created;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.recordPayment error: $e');
      }
      return null;
    }
  }

  Future<bool> deletePayment(String id) async {
    try {
      final data = await _client
          .from(_paymentsTable)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (data == null) return false;
      final payment = SupplierPayment.fromJson(Map<String, dynamic>.from(data));

      await _client.from(_paymentsTable).delete().eq('id', id);

      // ارجع الرصيد
      await _adjustSupplierBalance(
        supplierId: payment.supplierId,
        delta: payment.amount,
      );

      // ارجع تأثير الفاتورة
      if (payment.invoiceId != null) {
        await _applyPaymentToInvoice(
          invoiceId: payment.invoiceId!,
          amount: -payment.amount,
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.deletePayment error: $e');
      }
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  RETURNS
  // ═════════════════════════════════════════════════════════════

  Future<List<SupplierReturn>> listReturns({
    String? supplierId,
    ReturnStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      var query = _client.from(_returnsTable).select();

      if (supplierId != null) {
        query = query.eq('supplier_id', supplierId);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }
      if (fromDate != null) {
        query = query.gte('return_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('return_date', toDate.toIso8601String());
      }

      final data =
          await query.order('return_date', ascending: false).limit(limit);

      return (data as List)
          .map((e) => SupplierReturn.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<SupplierReturn?> createReturn(SupplierReturn ret) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return null;

      final computedTotal = ret.items.isEmpty
          ? ret.total
          : ret.items.fold<double>(0, (s, e) => s + e.total);

      final payload = ret.toInsertJson()
        ..['tenant_id'] = tenantId
        ..['created_by'] = userId
        ..['total'] = computedTotal
        ..['return_number'] = ret.returnNumber ?? await _generateReturnNumber();

      final inserted =
          await _client.from(_returnsTable).insert(payload).select().single();

      return SupplierReturn.fromJson(Map<String, dynamic>.from(inserted));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.createReturn error: $e');
      }
      return null;
    }
  }

  /// تغيير حالة المرتجع — لما يوصل completed → يقلل رصيد المورد
  Future<SupplierReturn?> changeReturnStatus({
    required String returnId,
    required ReturnStatus newStatus,
    String? note,
  }) async {
    try {
      final data = await _client
          .from(_returnsTable)
          .select()
          .eq('id', returnId)
          .maybeSingle();
      if (data == null) return null;
      final current = SupplierReturn.fromJson(Map<String, dynamic>.from(data));

      if (current.status == newStatus) return current;

      final updates = <String, dynamic>{
        'status': newStatus.name,
      };
      if (note != null) updates['notes'] = note;

      final updated = await _client
          .from(_returnsTable)
          .update(updates)
          .eq('id', returnId)
          .select()
          .single();

      final result =
          SupplierReturn.fromJson(Map<String, dynamic>.from(updated));

      // لو completed → قلل رصيد المورد
      if (newStatus == ReturnStatus.completed &&
          current.status != ReturnStatus.completed) {
        await _adjustSupplierBalance(
          supplierId: current.supplierId,
          delta: -current.total,
        );
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.changeReturnStatus error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteReturn(String id) async {
    try {
      await _client.from(_returnsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  STATS
  // ═════════════════════════════════════════════════════════════

  Future<SupplierStats> getStats() async {
    try {
      final suppliersData = await _client
          .from(_table)
          .select('balance, is_active')
          .eq('is_active', true);

      final suppliers = (suppliersData as List).cast<Map<String, dynamic>>();

      double totalDebt = 0;
      double totalOwed = 0;
      for (final s in suppliers) {
        final b = _toDouble(s['balance']);
        if (b > 0) {
          totalDebt += b;
        } else {
          totalOwed += -b;
        }
      }

      // الفواتير غير المدفوعة
      final invoicesData = await _client
          .from(_invoicesTable)
          .select('status, due_date, remaining')
          .neq('status', InvoiceStatus.paid.name)
          .neq('status', InvoiceStatus.cancelled.name);

      final invoices = (invoicesData as List).cast<Map<String, dynamic>>();

      int unpaid = 0;
      int overdue = 0;
      final now = DateTime.now();
      for (final inv in invoices) {
        unpaid++;
        final due = _parseDate(inv['due_date']);
        if (due != null && now.isAfter(due)) overdue++;
      }

      return SupplierStats(
        totalSuppliers: suppliers.length,
        activeSuppliers: suppliers.length,
        totalDebt: totalDebt,
        totalOwed: totalOwed,
        unpaidInvoices: unpaid,
        overdueInvoices: overdue,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('SupplierService.getStats error: $e');
      }
      return SupplierStats.empty;
    }
  }

  // ═════════════════════════════════════════════════════════════
  //  INTERNAL HELPERS
  // ═════════════════════════════════════════════════════════════

  /// عدّل رصيد المورد (delta موجب يزيد، سالب ينقص)
  Future<void> _adjustSupplierBalance({
    required String supplierId,
    required double delta,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .select('balance')
          .eq('id', supplierId)
          .maybeSingle();
      if (data == null) return;

      final current = _toDouble(data['balance']);
      final newBalance = current + delta;

      await _client
          .from(_table)
          .update({'balance': newBalance}).eq('id', supplierId);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_adjustSupplierBalance warning: $e');
      }
    }
  }

  /// طبّق دفعة على فاتورة (amount موجب = دفع، سالب = إلغاء دفع)
  Future<void> _applyPaymentToInvoice({
    required String invoiceId,
    required double amount,
  }) async {
    try {
      final data = await _client
          .from(_invoicesTable)
          .select('total, paid, due_date')
          .eq('id', invoiceId)
          .maybeSingle();
      if (data == null) return;

      final total = _toDouble(data['total']);
      final currentPaid = _toDouble(data['paid']);
      final newPaid = currentPaid + amount;
      final remaining = total - newPaid;
      final dueDate = _parseDate(data['due_date']);

      final status = _computeInvoiceStatus(
        total: total,
        paid: newPaid,
        dueDate: dueDate,
        currentStatus: InvoiceStatus.pending,
      );

      await _client.from(_invoicesTable).update({
        'paid': newPaid,
        'remaining': remaining < 0 ? 0 : remaining,
        'status': status.name,
      }).eq('id', invoiceId);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('_applyPaymentToInvoice warning: $e');
      }
    }
  }

  /// حساب حالة الفاتورة تلقائياً
  InvoiceStatus _computeInvoiceStatus({
    required double total,
    required double paid,
    required DateTime? dueDate,
    required InvoiceStatus currentStatus,
  }) {
    if (currentStatus == InvoiceStatus.cancelled) {
      return InvoiceStatus.cancelled;
    }
    if (paid >= total && total > 0) return InvoiceStatus.paid;
    if (paid > 0) {
      // لو متأخرة
      if (dueDate != null && DateTime.now().isAfter(dueDate)) {
        return InvoiceStatus.overdue;
      }
      return InvoiceStatus.partial;
    }
    // paid == 0
    if (dueDate != null && DateTime.now().isAfter(dueDate)) {
      return InvoiceStatus.overdue;
    }
    return InvoiceStatus.pending;
  }

  /// توليد رقم مرتجع: RET-YYYYMMDD-XXXX
  Future<String> _generateReturnNumber() async {
    final now = DateTime.now();
    final datePart = '${now.year}${_pad(now.month)}${_pad(now.day)}';

    try {
      final startOfDay =
          DateTime(now.year, now.month, now.day).toIso8601String();
      final count = await _client
          .from(_returnsTable)
          .select('id')
          .gte('created_at', startOfDay)
          .count(CountOption.exact);

      final seq = (count.count + 1).toString().padLeft(4, '0');
      return 'RET-$datePart-$seq';
    } catch (_) {
      final seq =
          (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
      return 'RET-$datePart-$seq';
    }
  }

  String _supplierSortColumn(SupplierSortBy s) {
    switch (s) {
      case SupplierSortBy.name:
        return 'name';
      case SupplierSortBy.balance:
        return 'balance';
      case SupplierSortBy.createdAt:
        return 'created_at';
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final supplierServiceProvider = Provider<SupplierService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return SupplierService(client: client, authService: authService);
});

/// Stream لقائمة الموردين (auto-refresh كل 30 ثانية)
final suppliersStreamProvider = StreamProvider.autoDispose
    .family<List<Supplier>, SupplierFilter>((ref, filter) async* {
  final service = ref.watch(supplierServiceProvider);

  yield await service.list(filter);

  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    yield await service.list(filter);
  }
});
