import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/receipts/data/models/receipt.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  RECEIPT FILTER — فلترة وبحث
// ═══════════════════════════════════════════════════════════════

class ReceiptFilter {
  const ReceiptFilter({
    this.status,
    this.priority,
    this.technicianId,
    this.customerSearch,
    this.fromDate,
    this.toDate,
    this.onlyActive = false,
    this.onlyDelayed = false,
    this.sortBy = ReceiptSortBy.createdAt,
    this.sortAscending = false,
    this.limit = 50,
    this.offset = 0,
  });

  final ReceiptStatus? status;
  final ReceiptPriority? priority;
  final String? technicianId;
  final String? customerSearch;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool onlyActive;
  final bool onlyDelayed;
  final ReceiptSortBy sortBy;
  final bool sortAscending;
  final int limit;
  final int offset;

  ReceiptFilter copyWith({
    ReceiptStatus? status,
    bool clearStatus = false,
    ReceiptPriority? priority,
    bool clearPriority = false,
    String? technicianId,
    bool clearTechnician = false,
    String? customerSearch,
    DateTime? fromDate,
    DateTime? toDate,
    bool? onlyActive,
    bool? onlyDelayed,
    ReceiptSortBy? sortBy,
    bool? sortAscending,
    int? limit,
    int? offset,
  }) {
    return ReceiptFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      technicianId:
          clearTechnician ? null : (technicianId ?? this.technicianId),
      customerSearch: customerSearch ?? this.customerSearch,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      onlyActive: onlyActive ?? this.onlyActive,
      onlyDelayed: onlyDelayed ?? this.onlyDelayed,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

enum ReceiptSortBy { createdAt, updatedAt, deliveredAt, total, priority }

// ═══════════════════════════════════════════════════════════════
//  RECEIPT STATS — إحصائيات
// ═══════════════════════════════════════════════════════════════

class ReceiptStats {
  const ReceiptStats({
    required this.total,
    required this.byStatus,
    required this.totalRevenue,
    required this.totalDeposits,
    required this.pendingAmount,
  });

  final int total;
  final Map<ReceiptStatus, int> byStatus;
  final double totalRevenue;
  final double totalDeposits;
  final double pendingAmount;

  int countOf(ReceiptStatus s) => byStatus[s] ?? 0;

  int get activeCount =>
      total -
      (byStatus[ReceiptStatus.delivered] ?? 0) -
      (byStatus[ReceiptStatus.rejected] ?? 0);

  static const ReceiptStats empty = ReceiptStats(
    total: 0,
    byStatus: {},
    totalRevenue: 0,
    totalDeposits: 0,
    pendingAmount: 0,
  );
}

// ═══════════════════════════════════════════════════════════════
//  RECEIPT SERVICE
// ═══════════════════════════════════════════════════════════════

class ReceiptService {
  ReceiptService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'receipts';
  static const String _historyTable = 'receipt_status_history';

  // ─────────────────────────────────────────────────────────────
  //  READ
  // ─────────────────────────────────────────────────────────────

  /// جلب الإيصالات مع فلترة كاملة
  Future<List<Receipt>> list([
    ReceiptFilter filter = const ReceiptFilter(),
  ]) async {
    try {
      var query = _client.from(_table).select();

      // status
      if (filter.status != null) {
        query = query.eq('status', filter.status!.name);
      } else if (filter.onlyActive) {
        query = query.not('status', 'in', '("delivered","rejected")');
      }

      // priority
      if (filter.priority != null) {
        query = query.eq('priority', filter.priority!.name);
      }

      // technician
      if (filter.technicianId != null) {
        query = query.eq('technician_id', filter.technicianId!);
      }

      // search
      if (filter.customerSearch != null &&
          filter.customerSearch!.trim().isNotEmpty) {
        final s = filter.customerSearch!.trim();
        query = query.or(
          'customer_name.ilike.%$s%,'
          'customer_phone.ilike.%$s%,'
          'device_imei.ilike.%$s%,'
          'receipt_number.ilike.%$s%',
        );
      }

      // dates
      if (filter.fromDate != null) {
        query = query.gte('created_at', filter.fromDate!.toIso8601String());
      }
      if (filter.toDate != null) {
        query = query.lte('created_at', filter.toDate!.toIso8601String());
      }

      // sort + pagination (معاً بدون reassign)
      final column = _sortColumn(filter.sortBy);
      final data = await query
          .order(column, ascending: filter.sortAscending)
          .range(filter.offset, filter.offset + filter.limit - 1);

      var list = (data as List)
          .map((e) => Receipt.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // فلتر متأخر (client-side لأن بيحتاج حساب تواريخ)
      if (filter.onlyDelayed) {
        list = list.where((r) => r.isDelayed).toList();
      }

      return list;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.list error: $e');
      }
      return const [];
    }
  }

  /// جلب إيصال واحد بالـ id
  Future<Receipt?> getById(String id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Receipt.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.getById error: $e');
      }
      return null;
    }
  }

  /// جلب إيصال بالـ tracking token (للعميل — من صفحة الويب)
  Future<Receipt?> getByTrackingToken(String token) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('tracking_token', token)
          .maybeSingle();
      if (data == null) return null;
      return Receipt.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.getByTrackingToken error: $e');
      }
      return null;
    }
  }

  /// جلب إيصال برقم الإيصال (unique داخل tenant)
  Future<Receipt?> getByNumber(String receiptNumber) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('receipt_number', receiptNumber)
          .maybeSingle();
      if (data == null) return null;
      return Receipt.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  CREATE
  // ─────────────────────────────────────────────────────────────

  /// إنشاء إيصال جديد (auto: توليد رقم + token + ربط tenant/user)
  Future<Receipt?> create({
    required Receipt draft,
    bool generateTracking = true,
  }) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      if (tenantId == null) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('ReceiptService.create: no tenant');
        }
        return null;
      }

      final userId = _authService.currentUser?.id;
      final now = DateTime.now();

      // رقم الإيصال
      final receiptNumber = draft.receiptNumber.trim().isNotEmpty
          ? draft.receiptNumber.trim()
          : await generateReceiptNumber();

      // Tracking token
      final trackingToken =
          generateTracking ? (draft.trackingToken ?? _generateToken()) : null;

      // التاريخ الأولي في statusHistory
      final initialHistory = draft.statusHistory.isNotEmpty
          ? draft.statusHistory
          : [
              StatusChange(
                status: ReceiptStatus.received,
                changedAt: now,
                note: 'تم استلام الجهاز',
                changedBy: userId,
              ),
            ];

      final payload = <String, dynamic>{
        'tenant_id': tenantId,
        'receipt_number': receiptNumber,
        'customer_name': draft.customerName,
        'customer_phone': draft.customerPhone,
        'customer_email': draft.customerEmail,
        'customer_notes': draft.customerNotes,
        'device_type': draft.deviceType,
        'device_brand': draft.deviceBrand,
        'device_model': draft.deviceModel,
        'device_imei': draft.deviceImei,
        'device_serial': draft.deviceSerial,
        'device_color': draft.deviceColor,
        'device_password': draft.devicePassword,
        'condition_notes': draft.conditionNotes,
        'issues': draft.issues.map((e) => e.toJson()).toList(),
        'accessories': draft.accessories.map((e) => e.toJson()).toList(),
        'images': draft.images,
        'status': ReceiptStatus.received.name,
        'status_history': initialHistory.map((e) => e.toJson()).toList(),
        'priority': draft.priority.name,
        'estimated_cost': draft.estimatedCost,
        'final_cost': draft.finalCost,
        'deposit': draft.deposit,
        'discount': draft.discount,
        'tax': draft.tax,
        'total': draft.total,
        'tracking_token': trackingToken,
        'technician_id': draft.technicianId,
        'warranty_days': draft.warrantyDays,
        'notes': draft.notes,
        'internal_notes': draft.internalNotes,
        'expected_delivery_date': draft.expectedDeliveryDate?.toIso8601String(),
        'created_by': userId,
      };

      final inserted =
          await _client.from(_table).insert(payload).select().single();

      final receipt = Receipt.fromJson(Map<String, dynamic>.from(inserted));

      // سجّل في جدول status_history (منفصل — للأرشيف)
      await _logStatusChange(
        receiptId: receipt.id,
        status: ReceiptStatus.received,
        note: 'تم استلام الجهاز',
        userId: userId,
      );
      return receipt;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.create error: $e');
      }
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  UPDATE
  // ─────────────────────────────────────────────────────────────

  /// تحديث بيانات إيصال (بدون تغيير الحالة)
  Future<Receipt?> update(Receipt receipt) async {
    try {
      final payload = receipt.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('tenant_id')
        ..remove('receipt_number') // الرقم ثابت
        ..remove('created_by');

      final updated = await _client
          .from(_table)
          .update(payload)
          .eq('id', receipt.id)
          .select()
          .single();

      return Receipt.fromJson(Map<String, dynamic>.from(updated));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.update error: $e');
      }
      return null;
    }
  }

  /// تحديث جزئي (patch) — للاستخدام السريع
  Future<bool> patch(String id, Map<String, dynamic> data) async {
    try {
      await _client.from(_table).update(data).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.patch error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  STATUS WORKFLOW
  // ─────────────────────────────────────────────────────────────

  /// تغيير حالة الإيصال + تسجيل في التاريخ
  Future<Receipt?> changeStatus({
    required String receiptId,
    required ReceiptStatus newStatus,
    String? note,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      final now = DateTime.now();

      // 1. اجلب الإيصال الحالي
      final current = await getById(receiptId);
      if (current == null) return null;

      // 2. لا تعمل تحديث لو نفس الحالة
      if (current.status == newStatus) return current;

      // 3. حدّث الـ status + history array
      final newHistory = [
        ...current.statusHistory,
        StatusChange(
          status: newStatus,
          changedAt: now,
          note: note,
          changedBy: userId,
        ),
      ];

      final updates = <String, dynamic>{
        'status': newStatus.name,
        'status_history': newHistory.map((e) => e.toJson()).toList(),
      };

      // لو delivered → سجّل delivered_at
      if (newStatus == ReceiptStatus.delivered) {
        updates['delivered_at'] = now.toIso8601String();
        updates['final_cost'] =
            current.finalCost > 0 ? current.finalCost : current.estimatedCost;
        updates['total'] = current.total > 0
            ? current.total
            : current.finalCost > 0
                ? current.finalCost
                : current.estimatedCost;
      }

      await _client.from(_table).update(updates).eq('id', receiptId);

      // 4. سجّل في جدول التاريخ المنفصل (للأرشيف)
      await _logStatusChange(
        receiptId: receiptId,
        status: newStatus,
        fromStatus: current.status,
        note: note,
        userId: userId,
      );

      // 5. رجّع الإيصال المحدّث
      return await getById(receiptId);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.changeStatus error: $e');
      }
      return null;
    }
  }

  /// تقدّم للحالة التالية مباشرة
  Future<Receipt?> advanceStatus(String receiptId, {String? note}) async {
    final current = await getById(receiptId);
    if (current == null) return null;
    final next = current.status.next;
    if (next == null) return current;
    return changeStatus(
      receiptId: receiptId,
      newStatus: next,
      note: note,
    );
  }

  /// جلب تاريخ تغييرات الحالة من الجدول المنفصل
  Future<List<Map<String, dynamic>>> getStatusHistory(
    String receiptId,
  ) async {
    try {
      final data = await _client
          .from(_historyTable)
          .select()
          .eq('receipt_id', receiptId)
          .order('changed_at', ascending: true);
      return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return const [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  DELETE
  // ─────────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.delete error: $e');
      }
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  TRACKING
  // ─────────────────────────────────────────────────────────────

  /// توليد/تجديد tracking token لإيصال
  Future<String?> refreshTrackingToken(String receiptId) async {
    try {
      final token = _generateToken();
      await _client
          .from(_table)
          .update({'tracking_token': token}).eq('id', receiptId);
      return token;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('refreshTrackingToken error: $e');
      }
      return null;
    }
  }

  /// إلغاء tracking token
  Future<bool> revokeTrackingToken(String receiptId) async {
    try {
      await _client
          .from(_table)
          .update({'tracking_token': null}).eq('id', receiptId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  STATS
  // ─────────────────────────────────────────────────────────────

  /// إحصائيات شاملة (للـ Dashboard)
  Future<ReceiptStats> getStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query =
          _client.from(_table).select('status, total, deposit, final_cost');

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final data = await query;
      final rows = (data as List).cast<Map<String, dynamic>>();

      final byStatus = <ReceiptStatus, int>{};
      double revenue = 0;
      double deposits = 0;
      double pending = 0;

      for (final r in rows) {
        final s = ReceiptStatusX.fromString(r['status'] as String?);
        byStatus[s] = (byStatus[s] ?? 0) + 1;

        final total = _toDouble(r['total']);
        final dep = _toDouble(r['deposit']);
        final finalCost = _toDouble(r['final_cost']);

        if (s == ReceiptStatus.delivered) {
          revenue += total > 0 ? total : finalCost;
        } else if (s != ReceiptStatus.rejected) {
          deposits += dep;
          pending += (total > 0 ? total : finalCost) - dep;
        }
      }

      return ReceiptStats(
        total: rows.length,
        byStatus: byStatus,
        totalRevenue: revenue,
        totalDeposits: deposits,
        pendingAmount: pending < 0 ? 0 : pending,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.getStats error: $e');
      }
      return ReceiptStats.empty;
    }
  }

  /// سلسلة زمنية للإيرادات اليومية (delivered receipts only)
  /// ترجّع: `Map<DateTime (بداية اليوم), double totalRevenue>`
  Future<Map<DateTime, double>> getRevenueTimeSeries({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .select('delivered_at, total, final_cost')
          .eq('status', ReceiptStatus.delivered.name)
          .gte('delivered_at', fromDate.toIso8601String())
          .lte('delivered_at', toDate.toIso8601String())
          .order('delivered_at', ascending: true);

      final rows = (data as List).cast<Map<String, dynamic>>();
      final series = <DateTime, double>{};

      for (final r in rows) {
        final deliveredAt = r['delivered_at'];
        if (deliveredAt == null) continue;

        final dt = DateTime.tryParse(deliveredAt.toString());
        if (dt == null) continue;

        // بداية اليوم (نطبع الساعات)
        final dayKey = DateTime(dt.year, dt.month, dt.day);

        final total = _toDouble(r['total']);
        final finalCost = _toDouble(r['final_cost']);
        final amount = total > 0 ? total : finalCost;

        series[dayKey] = (series[dayKey] ?? 0) + amount;
      }

      return series;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('ReceiptService.getRevenueTimeSeries error: $e');
      }
      return const {};
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  RECEIPT NUMBER GENERATION
  // ─────────────────────────────────────────────────────────────

  /// توليد رقم إيصال فريد بصيغة: RCP-YYYYMMDD-XXXX
  Future<String> generateReceiptNumber() async {
    final now = DateTime.now();
    final datePart = '${now.year}${_pad(now.month)}${_pad(now.day)}';

    try {
      final startOfDay =
          DateTime(now.year, now.month, now.day).toIso8601String();

      // 1) اجلب آخر رقم إيصال لليوم
      final lastReceipt = await _client
          .from(_table)
          .select('receipt_number')
          .gte('created_at', startOfDay)
          .order('receipt_number', ascending: false)
          .limit(1)
          .maybeSingle();

      int nextSeq = 1;
      if (lastReceipt != null) {
        final lastNumber = lastReceipt['receipt_number'] as String?;
        if (lastNumber != null) {
          final parts = lastNumber.split('-');
          if (parts.length == 3) {
            final lastSeq = int.tryParse(parts[2]) ?? 0;
            nextSeq = lastSeq + 1;
          }
        }
      }

      // 2) تأكد إن الرقم مش مكرر — لو مكرر زوّد
      String candidate;
      int attempts = 0;
      do {
        candidate = 'RCP-$datePart-${nextSeq.toString().padLeft(4, '0')}';
        final existing = await _client
            .from(_table)
            .select('id')
            .eq('receipt_number', candidate)
            .maybeSingle();
        if (existing == null) break;
        nextSeq++;
        attempts++;
      } while (attempts < 100);

      return candidate;
    } catch (_) {
      // fallback: timestamp كأمان أخير
      final seq =
          (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0');
      return 'RCP-$datePart-$seq';
    }
  }
  // ─────────────────────────────────────────────────────────────
  //  INTERNAL HELPERS
  // ─────────────────────────────────────────────────────────────

  Future<void> _logStatusChange({
    required String receiptId,
    required ReceiptStatus status,
    ReceiptStatus? fromStatus,
    String? note,
    String? userId,
  }) async {
    try {
      await _client.from(_historyTable).insert({
        'receipt_id': receiptId,
        'from_status': (fromStatus ?? ReceiptStatus.received).name,
        'to_status': status.name,
        'notes': note,
        'changed_by': userId,
        'changed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('_logStatusChange warning: $e');
    }
  }

  String _sortColumn(ReceiptSortBy s) {
    switch (s) {
      case ReceiptSortBy.createdAt:
        return 'created_at';
      case ReceiptSortBy.updatedAt:
        return 'updated_at';
      case ReceiptSortBy.deliveredAt:
        return 'delivered_at';
      case ReceiptSortBy.total:
        return 'total';
      case ReceiptSortBy.priority:
        return 'priority';
    }
  }

  String _generateToken() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(32, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

// ═══════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ═══════════════════════════════════════════════════════════════

final receiptServiceProvider = Provider<ReceiptService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return ReceiptService(client: client, authService: authService);
});

/// Stream لمراقبة تغييرات الـ receipts (auto-refresh كل 30 ثانية)
final receiptsStreamProvider = StreamProvider.autoDispose
    .family<List<Receipt>, ReceiptFilter>((ref, filter) async* {
  final service = ref.watch(receiptServiceProvider);

  // initial fetch
  yield await service.list(filter);

  // periodic refresh
  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    yield await service.list(filter);
  }
});
