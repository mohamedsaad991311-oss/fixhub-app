// lib/features/suppliers/presentation/providers/supplier_invoices_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/supplier_service.dart';
import '../../data/models/supplier.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierInvoicesState — حالة قائمة فواتير مورد
/// ═══════════════════════════════════════════════════════════
class SupplierInvoicesState {
  final String supplierId;
  final List<SupplierInvoice> invoices;
  final InvoiceStatus? statusFilter;
  final String? search;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const SupplierInvoicesState({
    required this.supplierId,
    this.invoices = const [],
    this.statusFilter,
    this.search,
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && invoices.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// إحصائيات محلية
  double get totalAmount =>
      invoices.fold<double>(0, (sum, inv) => sum + inv.total);
  double get totalPaid =>
      invoices.fold<double>(0, (sum, inv) => sum + inv.paid);
  double get totalRemaining =>
      invoices.fold<double>(0, (sum, inv) => sum + inv.remaining);

  int get unpaidCount => invoices
      .where((inv) =>
          inv.status != InvoiceStatus.paid &&
          inv.status != InvoiceStatus.cancelled)
      .length;
  int get overdueCount => invoices
      .where((inv) =>
          inv.status != InvoiceStatus.paid &&
          inv.status != InvoiceStatus.cancelled &&
          inv.dueDate != null &&
          DateTime.now().isAfter(inv.dueDate!))
      .length;

  /// الفواتير المفلترة
  List<SupplierInvoice> get filteredInvoices {
    var list = invoices;

    if (statusFilter != null) {
      list = list.where((inv) => inv.status == statusFilter).toList();
    }

    if (search != null && search!.trim().isNotEmpty) {
      final q = search!.toLowerCase().trim();
      list = list
          .where((inv) =>
              inv.invoiceNumber.toLowerCase().contains(q) ||
              (inv.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  SupplierInvoicesState copyWith({
    String? supplierId,
    List<SupplierInvoice>? invoices,
    InvoiceStatus? statusFilter,
    bool clearStatusFilter = false,
    String? search,
    bool clearSearch = false,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupplierInvoicesState(
      supplierId: supplierId ?? this.supplierId,
      invoices: invoices ?? this.invoices,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      search: clearSearch ? null : (search ?? this.search),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// SupplierInvoicesNotifier
/// ═══════════════════════════════════════════════════════════
class SupplierInvoicesNotifier extends StateNotifier<SupplierInvoicesState> {
  SupplierInvoicesNotifier(this._ref, String supplierId)
      : super(SupplierInvoicesState(supplierId: supplierId)) {
    load();
  }

  final Ref _ref;

  SupplierService get _service => _ref.read(supplierServiceProvider);

  // ─────────────────────────────────────────────────────────
  //  LOAD
  // ─────────────────────────────────────────────────────────

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final invoices = await _service.listInvoices(
        supplierId: state.supplierId,
      );
      state = state.copyWith(invoices: invoices, isLoading: false);
    } catch (e) {
      debugPrint('SupplierInvoicesNotifier.load error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الفواتير',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final invoices = await _service.listInvoices(
        supplierId: state.supplierId,
      );
      state = state.copyWith(invoices: invoices, clearError: true);
    } catch (e) {
      debugPrint('SupplierInvoicesNotifier.refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  //  FILTERS
  // ─────────────────────────────────────────────────────────

  void filterByStatus(InvoiceStatus? status) {
    state = status == null
        ? state.copyWith(clearStatusFilter: true)
        : state.copyWith(statusFilter: status);
  }

  void search(String? query) {
    final trimmed = query?.trim();
    state = (trimmed == null || trimmed.isEmpty)
        ? state.copyWith(clearSearch: true)
        : state.copyWith(search: trimmed);
  }

  void clearFilters() {
    state = state.copyWith(clearStatusFilter: true, clearSearch: true);
  }

  // ─────────────────────────────────────────────────────────
  //  CREATE
  // ─────────────────────────────────────────────────────────

  Future<bool> createInvoice(SupplierInvoice invoice) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final created = await _service.createInvoice(invoice);
      if (created == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل إنشاء الفاتورة',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierInvoicesNotifier.createInvoice error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل إنشاء الفاتورة',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────

  Future<bool> deleteInvoice(String id) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final ok = await _service.deleteInvoice(id);
      if (ok) {
        state = state.copyWith(
          invoices: state.invoices.where((inv) => inv.id != id).toList(),
        );
      }
      state = state.copyWith(isUpdating: false);
      return ok;
    } catch (e) {
      debugPrint('SupplierInvoicesNotifier.deleteInvoice error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل حذف الفاتورة',
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  PAYMENT SHORTCUT (من الفاتورة)
  // ─────────────────────────────────────────────────────────

  Future<bool> payInvoice({
    required SupplierInvoice invoice,
    required double amount,
    required PaymentMethod method,
    String? notes,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final payment = SupplierPayment(
        id: '',
        tenantId: '',
        supplierId: state.supplierId,
        invoiceId: invoice.id,
        amount: amount,
        paymentMethod: method,
        paymentDate: DateTime.now(),
        notes: notes,
      );

      final created = await _service.recordPayment(payment);
      if (created == null) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: 'فشل تسجيل الدفعة',
        );
        return false;
      }
      await refresh();
      state = state.copyWith(isUpdating: false);
      return true;
    } catch (e) {
      debugPrint('SupplierInvoicesNotifier.payInvoice error: $e');
      state = state.copyWith(
        isUpdating: false,
        errorMessage: 'فشل تسجيل الدفعة',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ═══════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════

/// Family provider — كل مورد له قائمة فواتيره
final supplierInvoicesListProvider = StateNotifierProvider.family<
    SupplierInvoicesNotifier, SupplierInvoicesState, String>((ref, id) {
  return SupplierInvoicesNotifier(ref, id);
});

/// الفواتير المفلترة
final supplierInvoicesFilteredProvider =
    Provider.family<List<SupplierInvoice>, String>((ref, id) {
  return ref.watch(supplierInvoicesListProvider(id)).filteredInvoices;
});

/// إحصائيات الفواتير
final supplierInvoicesStatsProvider =
    Provider.family<Map<String, dynamic>, String>((ref, id) {
  final s = ref.watch(supplierInvoicesListProvider(id));
  return {
    'total': s.totalAmount,
    'paid': s.totalPaid,
    'remaining': s.totalRemaining,
    'unpaid_count': s.unpaidCount,
    'overdue_count': s.overdueCount,
  };
});

/// فلتر الحالة الحالي
final supplierInvoicesFilterProvider =
    Provider.family<InvoiceStatus?, String>((ref, id) {
  return ref.watch(supplierInvoicesListProvider(id)).statusFilter;
});
