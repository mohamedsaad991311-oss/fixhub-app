import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/inventory/data/models/inventory_item.dart';
import 'auth_service.dart';
import 'supabase_service.dart';

// ═══════════════════════════════════════════════════════════════
//  INVENTORY FILTER
// ═══════════════════════════════════════════════════════════════

class InventoryFilter {
  const InventoryFilter({
    this.category,
    this.supplierId,
    this.brandName,
    this.search,
    this.onlyLowStock = false,
    this.onlyOutOfStock = false,
    this.onlyActive = true,
    this.sortBy = InventorySortBy.name,
    this.sortAscending = true,
    this.limit = 100,
    this.offset = 0,
  });

  final InventoryCategory? category;
  final String? supplierId;
  final String? brandName;
  final String? search;
  final bool onlyLowStock;
  final bool onlyOutOfStock;
  final bool onlyActive;
  final InventorySortBy sortBy;
  final bool sortAscending;
  final int limit;
  final int offset;

  InventoryFilter copyWith({
    InventoryCategory? category,
    bool clearCategory = false,
    String? supplierId,
    bool clearSupplier = false,
    String? brandName,
    bool clearBrand = false,
    String? search,
    bool? onlyLowStock,
    bool? onlyOutOfStock,
    bool? onlyActive,
    InventorySortBy? sortBy,
    bool? sortAscending,
    int? limit,
    int? offset,
  }) {
    return InventoryFilter(
      category: clearCategory ? null : (category ?? this.category),
      supplierId: clearSupplier ? null : (supplierId ?? this.supplierId),
      brandName: clearBrand ? null : (brandName ?? this.brandName),
      search: search ?? this.search,
      onlyLowStock: onlyLowStock ?? this.onlyLowStock,
      onlyOutOfStock: onlyOutOfStock ?? this.onlyOutOfStock,
      onlyActive: onlyActive ?? this.onlyActive,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

enum InventorySortBy { name, quantity, costPrice, sellingPrice, createdAt }

// ═══════════════════════════════════════════════════════════════
//  INVENTORY STATS
// ═══════════════════════════════════════════════════════════════

class InventoryStats {
  const InventoryStats({
    required this.totalItems,
    required this.totalQuantity,
    required this.totalStockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.byCategory,
  });

  final int totalItems;
  final int totalQuantity;
  final double totalStockValue;
  final int lowStockCount;
  final int outOfStockCount;
  final Map<InventoryCategory, int> byCategory;

  int countOf(InventoryCategory c) => byCategory[c] ?? 0;

  static const InventoryStats empty = InventoryStats(
    totalItems: 0,
    totalQuantity: 0,
    totalStockValue: 0,
    lowStockCount: 0,
    outOfStockCount: 0,
    byCategory: {},
  );
}

// ═══════════════════════════════════════════════════════════════
//  INVENTORY SERVICE
// ═══════════════════════════════════════════════════════════════

class InventoryService {
  InventoryService({
    required SupabaseClient client,
    required AuthService authService,
  })  : _client = client,
        _authService = authService;

  final SupabaseClient _client;
  final AuthService _authService;

  static const String _table = 'inventory';
  static const String _movementsTable = 'inventory_movements';

  // ─────────────────────────────────────────────────────────────
  //  READ
  // ─────────────────────────────────────────────────────────────

  Future<List<InventoryItem>> list([
    InventoryFilter filter = const InventoryFilter(),
  ]) async {
    try {
      var query = _client.from(_table).select().isFilter('deleted_at', null);
      if (filter.onlyActive) {
        query = query.eq('is_active', true);
      }

      if (filter.category != null) {
        query = query.eq('category', filter.category!.name);
      }

      if (filter.supplierId != null) {
        query = query.eq('supplier_id', filter.supplierId!);
      }

      if (filter.brandName != null && filter.brandName!.isNotEmpty) {
        final brand = filter.brandName!;
        query = query.or('name.ilike.%$brand%,name_ar.ilike.%$brand%');
      }

      if (filter.search != null && filter.search!.trim().isNotEmpty) {
        final s = filter.search!.trim();
        query = query.or(
          'name.ilike.%$s%,'
          'name_ar.ilike.%$s%,'
          'sku.ilike.%$s%,'
          'barcode.ilike.%$s%',
        );
      }

      if (filter.onlyLowStock) {
        // client-side
      } else if (filter.onlyOutOfStock) {
        query = query.lte('quantity', 0);
      }

      final column = _sortColumn(filter.sortBy);
      final data = await query
          .order(column, ascending: filter.sortAscending)
          .range(filter.offset, filter.offset + filter.limit - 1);

      var items = (data as List)
          .map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (filter.onlyLowStock) {
        items = items.where((i) => i.isLowStock).toList();
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('InventoryService.list error: $e');
      }
      return const [];
    }
  }

  Future<InventoryItem?> getById(String id) async {
    try {
      final data =
          await _client.from(_table).select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return InventoryItem.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      if (kDebugMode) print('InventoryService.getById error: $e');
      return null;
    }
  }

  Future<InventoryItem?> getByBarcode(String barcode) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('barcode', barcode)
          .maybeSingle();
      if (data == null) return null;
      return InventoryItem.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<InventoryItem?> getBySku(String sku) async {
    try {
      final data =
          await _client.from(_table).select().eq('sku', sku).maybeSingle();
      if (data == null) return null;
      return InventoryItem.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<List<InventoryItem>> getLowStockItems({int limit = 50}) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('is_active', true)
          .gt('quantity', 0)
          .order('quantity', ascending: true)
          .limit(limit);

      final items = (data as List)
          .map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return items.where((i) => i.isLowStock).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<InventoryItem>> getOutOfStockItems({int limit = 50}) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('is_active', true)
          .lte('quantity', 0)
          .order('name', ascending: true)
          .limit(limit);
      return (data as List)
          .map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  CREATE / UPDATE / DELETE
  // ─────────────────────────────────────────────────────────────

  Future<InventoryItem?> create(InventoryItem item) async {
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return null;

      final payload = item.toInsertJson()
        ..['tenant_id'] = tenantId
        ..['created_by'] = userId;

      try {
        final inserted =
            await _client.from(_table).insert(payload).select().single();
        return InventoryItem.fromJson(Map<String, dynamic>.from(inserted));
      } catch (e) {
        if (e.toString().contains('variant') ||
            e.toString().contains('custom_category')) {
          payload.remove('variant');
          payload.remove('custom_category');
          final inserted =
              await _client.from(_table).insert(payload).select().single();
          return InventoryItem.fromJson(Map<String, dynamic>.from(inserted));
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) print('InventoryService.create error: $e');
      return null;
    }
  }

  Future<InventoryItem?> update(InventoryItem item) async {
    try {
      final payload = item.toJson()
        ..remove('id')
        ..remove('tenant_id')
        ..remove('created_at')
        ..remove('updated_at')
        ..remove('quantity');

      final updated = await _client
          .from(_table)
          .update(payload)
          .eq('id', item.id)
          .select()
          .single();

      return InventoryItem.fromJson(Map<String, dynamic>.from(updated));
    } catch (e) {
      if (kDebugMode) print('InventoryService.update error: $e');
      return null;
    }
  }

  Future<bool> delete(String id, {String? reason}) async {
    try {
      final result = await _client.rpc(
        'soft_delete_row',
        params: {
          'p_table': _table,
          'p_id': id,
          'p_reason': reason ?? 'تم حذف القطعة من التطبيق',
        },
      );
      return result == true;
    } catch (e) {
      if (kDebugMode) print('InventoryService.delete error: $e');
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

  // ─────────────────────────────────────────────────────────────
  //  STOCK MOVEMENTS
  // ─────────────────────────────────────────────────────────────

  Future<InventoryItem?> stockIn({
    required String inventoryId,
    required int quantity,
    MovementType type = MovementType.purchase,
    double? unitCost,
    String? referenceId,
    String? referenceType,
    String? notes,
  }) async {
    if (quantity <= 0) throw Exception('الكمية يجب أن تكون أكبر من صفر');
    if (!type.isIncrease) {
      throw Exception('نوع الحركة (${type.labelAr}) لا يصلح للإدخال');
    }
    return await _applyMovement(
      inventoryId: inventoryId,
      type: type,
      quantity: quantity,
      unitCost: unitCost,
      referenceId: referenceId,
      referenceType: referenceType,
      notes: notes,
    );
  }

  Future<InventoryItem?> stockOut({
    required String inventoryId,
    required int quantity,
    MovementType type = MovementType.usage,
    String? referenceId,
    String? referenceType,
    String? notes,
  }) async {
    if (quantity <= 0) throw Exception('الكمية يجب أن تكون أكبر من صفر');
    if (!type.isDecrease) {
      throw Exception('نوع الحركة (${type.labelAr}) لا يصلح للإخراج');
    }
    return await _applyMovement(
      inventoryId: inventoryId,
      type: type,
      quantity: quantity,
      referenceId: referenceId,
      referenceType: referenceType,
      notes: notes,
    );
  }

  Future<InventoryItem?> adjustStock({
    required String inventoryId,
    required int newQuantity,
    String? notes,
  }) async {
    try {
      final current = await getById(inventoryId);
      if (current == null) return null;
      if (current.quantity == newQuantity) return current;

      final diff = newQuantity - current.quantity;

      return await _applyMovement(
        inventoryId: inventoryId,
        type: MovementType.adjustment,
        quantity: diff,
        notes: notes ?? 'تسوية: ${current.quantity} → $newQuantity',
      );
    } catch (e) {
      if (kDebugMode) print('adjustStock error: $e');
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// تطبيق حركة مخزون (Atomic Transaction)
  /// ═══════════════════════════════════════════════════════════════
  /// كل عملية (تسجيل الحركة + تحديث الكمية + تسجيل النشاط) بتتم
  /// في RPC واحد على Supabase، فإما تنجح كلها أو تفشل كلها.
  /// ═══════════════════════════════════════════════════════════════
  Future<InventoryItem?> _applyMovement({
    required String inventoryId,
    required MovementType type,
    required int quantity,
    double? unitCost,
    String? referenceId,
    String? referenceType,
    String? notes,
  }) async {
    try {
      final result = await _client.rpc(
        'process_stock_movement',
        params: {
          'p_inventory_id': inventoryId,
          'p_movement_type': type.name,
          'p_quantity': type == MovementType.adjustment
              ? quantity // adjustment: احترم الإشارة (موجب أو سالب)
              : quantity.abs(), // باقي الأنواع: دايماً موجب
          'p_unit_cost': unitCost,
          'p_reference_id': referenceId,
          'p_reference_type': referenceType,
          'p_notes': notes,
        },
      );

      if (result == null || result['success'] != true) {
        throw Exception('فشل تسجيل حركة المخزون');
      }

      return await getById(inventoryId);
    } catch (e) {
      if (kDebugMode) print('_applyMovement error: $e');
      rethrow;
    }
  }

  Future<List<InventoryMovement>> getMovements({
    String? inventoryId,
    MovementType? type,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
  }) async {
    try {
      var query = _client.from(_movementsTable).select();

      if (inventoryId != null) query = query.eq('inventory_id', inventoryId);
      if (type != null) query = query.eq('movement_type', type.name);
      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final data =
          await query.order('created_at', ascending: false).limit(limit);

      return (data as List)
          .map((e) => InventoryMovement.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      if (kDebugMode) print('InventoryService.getMovements error: $e');
      return const [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  STATS
  // ─────────────────────────────────────────────────────────────

  Future<InventoryStats> getStats() async {
    try {
      final data = await _client
          .from(_table)
          .select('category, quantity, min_quantity, cost_price')
          .eq('is_active', true);

      final rows = (data as List).cast<Map<String, dynamic>>();

      int totalQty = 0;
      double totalValue = 0;
      int lowCount = 0;
      int outCount = 0;
      final byCategory = <InventoryCategory, int>{};

      for (final r in rows) {
        final qty = _toInt(r['quantity']);
        final minQty = _toInt(r['min_quantity'], fallback: 1);
        final cost = _toDouble(r['cost_price']);
        final cat = InventoryCategoryX.fromString(r['category'] as String?);

        totalQty += qty;
        totalValue += cost * qty;
        byCategory[cat] = (byCategory[cat] ?? 0) + 1;

        if (qty <= 0) {
          outCount++;
        } else if (qty <= minQty) {
          lowCount++;
        }
      }

      return InventoryStats(
        totalItems: rows.length,
        totalQuantity: totalQty,
        totalStockValue: totalValue,
        lowStockCount: lowCount,
        outOfStockCount: outCount,
        byCategory: byCategory,
      );
    } catch (e) {
      if (kDebugMode) print('InventoryService.getStats error: $e');
      return InventoryStats.empty;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  BULK OPERATIONS
  // ─────────────────────────────────────────────────────────────

  Future<int> bulkImport(List<InventoryItem> items) async {
    if (items.isEmpty) return 0;
    try {
      final tenantId = await _authService.getUserTenantId();
      final userId = _authService.currentUser?.id;
      if (tenantId == null) return 0;

      final payloads = items
          .map((i) => i.toInsertJson()
            ..['tenant_id'] = tenantId
            ..['created_by'] = userId)
          .toList();

      final inserted = await _client.from(_table).insert(payloads).select('id');

      return (inserted as List).length;
    } catch (e) {
      if (kDebugMode) print('InventoryService.bulkImport error: $e');
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────

  String _sortColumn(InventorySortBy s) {
    switch (s) {
      case InventorySortBy.name:
        return 'name';
      case InventorySortBy.quantity:
        return 'quantity';
      case InventorySortBy.costPrice:
        return 'cost_price';
      case InventorySortBy.sellingPrice:
        return 'selling_price';
      case InventorySortBy.createdAt:
        return 'created_at';
    }
  }

  int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

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

final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final authService = ref.watch(authServiceProvider);
  return InventoryService(client: client, authService: authService);
});

final inventoryStreamProvider = StreamProvider.autoDispose
    .family<List<InventoryItem>, InventoryFilter>((ref, filter) async* {
  final service = ref.watch(inventoryServiceProvider);

  yield await service.list(filter);

  await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
    yield await service.list(filter);
  }
});