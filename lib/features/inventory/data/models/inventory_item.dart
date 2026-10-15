// lib/features/inventory/data/models/inventory_item.dart

import 'package:flutter/material.dart';
import 'inventory_variants.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryItem — قطعة مخزون
/// ═══════════════════════════════════════════════════════════

/// فئة القطعة
enum InventoryCategory {
  screen, // شاشة
  battery, // بطارية
  chargingPort, // منفذ شحن
  camera, // كاميرا
  speaker, // سماعة
  microphone, // مايك
  backCover, // ظهر
  flex, // فلاتة
  motherboard, // بوردة
  ic, // IC
  accessory, // ملحق
  tool, // أداة
  other, // أخرى
}

extension InventoryCategoryX on InventoryCategory {
  String get labelAr {
    switch (this) {
      case InventoryCategory.screen:
        return 'شاشة';
      case InventoryCategory.battery:
        return 'بطارية';
      case InventoryCategory.chargingPort:
        return 'منفذ شحن';
      case InventoryCategory.camera:
        return 'كاميرا';
      case InventoryCategory.speaker:
        return 'سماعة';
      case InventoryCategory.microphone:
        return 'مايك';
      case InventoryCategory.backCover:
        return 'ظهر';
      case InventoryCategory.flex:
        return 'فلاتة';
      case InventoryCategory.motherboard:
        return 'بوردة';
      case InventoryCategory.ic:
        return 'IC';
      case InventoryCategory.accessory:
        return 'ملحق';
      case InventoryCategory.tool:
        return 'أداة';
      case InventoryCategory.other:
        return 'أخرى';
    }
  }

  String get labelEn {
    switch (this) {
      case InventoryCategory.screen:
        return 'Screen';
      case InventoryCategory.battery:
        return 'Battery';
      case InventoryCategory.chargingPort:
        return 'Charging Port';
      case InventoryCategory.camera:
        return 'Camera';
      case InventoryCategory.speaker:
        return 'Speaker';
      case InventoryCategory.microphone:
        return 'Microphone';
      case InventoryCategory.backCover:
        return 'Back Cover';
      case InventoryCategory.flex:
        return 'Flex';
      case InventoryCategory.motherboard:
        return 'Motherboard';
      case InventoryCategory.ic:
        return 'IC';
      case InventoryCategory.accessory:
        return 'Accessory';
      case InventoryCategory.tool:
        return 'Tool';
      case InventoryCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case InventoryCategory.screen:
        return Icons.smartphone;
      case InventoryCategory.battery:
        return Icons.battery_full;
      case InventoryCategory.chargingPort:
        return Icons.power;
      case InventoryCategory.camera:
        return Icons.camera_alt;
      case InventoryCategory.speaker:
        return Icons.volume_up;
      case InventoryCategory.microphone:
        return Icons.mic;
      case InventoryCategory.backCover:
        return Icons.phone_iphone;
      case InventoryCategory.flex:
        return Icons.cable;
      case InventoryCategory.motherboard:
        return Icons.memory;
      case InventoryCategory.ic:
        return Icons.developer_board;
      case InventoryCategory.accessory:
        return Icons.headphones;
      case InventoryCategory.tool:
        return Icons.handyman;
      case InventoryCategory.other:
        return Icons.category;
    }
  }

  static InventoryCategory fromString(String? value) {
    return InventoryCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => InventoryCategory.other,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// MovementType — نوع حركة المخزون
/// ═══════════════════════════════════════════════════════════
enum MovementType {
  purchase, // شراء
  sale, // بيع
  usage, // استخدام في إصلاح
  returnIn, // مرتجع داخل
  returnOut, // مرتجع خارج
  adjustment, // تسوية
  damaged, // تالف
  lost, // مفقود
  transfer, // نقل
}

extension MovementTypeX on MovementType {
  String get labelAr {
    switch (this) {
      case MovementType.purchase:
        return 'شراء';
      case MovementType.sale:
        return 'بيع';
      case MovementType.usage:
        return 'استخدام';
      case MovementType.returnIn:
        return 'مرتجع داخل';
      case MovementType.returnOut:
        return 'مرتجع خارج';
      case MovementType.adjustment:
        return 'تسوية';
      case MovementType.damaged:
        return 'تالف';
      case MovementType.lost:
        return 'مفقود';
      case MovementType.transfer:
        return 'نقل';
    }
  }

  bool get isIncrease {
    return this == MovementType.purchase ||
        this == MovementType.returnIn ||
        this == MovementType.adjustment;
  }

  bool get isDecrease => !isIncrease;

  static MovementType fromString(String? value) {
    return MovementType.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => MovementType.adjustment,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// InventoryMovement — حركة مخزون
/// ═══════════════════════════════════════════════════════════
class InventoryMovement {
  final String id;
  final String tenantId;
  final String inventoryId;
  final MovementType type;
  final int quantity;
  final int? previousQuantity;
  final int? newQuantity;
  final double? unitCost;
  final String? referenceId;
  final String? referenceType;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  const InventoryMovement({
    required this.id,
    required this.tenantId,
    required this.inventoryId,
    required this.type,
    required this.quantity,
    this.previousQuantity,
    this.newQuantity,
    this.unitCost,
    this.referenceId,
    this.referenceType,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenant_id': tenantId,
        'inventory_id': inventoryId,
        'movement_type': type.name,
        'quantity': quantity,
        'previous_quantity': previousQuantity,
        'new_quantity': newQuantity,
        'unit_cost': unitCost,
        'reference_id': referenceId,
        'reference_type': referenceType,
        'notes': notes,
        'created_by': createdBy,
        'created_at': createdAt?.toIso8601String(),
      };

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      inventoryId: json['inventory_id'] as String? ?? '',
      type: MovementTypeX.fromString(json['movement_type'] as String?),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      previousQuantity: (json['previous_quantity'] as num?)?.toInt(),
      newQuantity: (json['new_quantity'] as num?)?.toInt(),
      unitCost: (json['unit_cost'] as num?)?.toDouble(),
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// InventoryItem — النموذج الرئيسي
/// ═══════════════════════════════════════════════════════════
class InventoryItem {
  final String id;
  final String tenantId;
  final String name;
  final String? nameAr;
  final String? sku;
  final String? barcode;
  final InventoryCategory category;
  final InventoryVariant variant;
  final String? description;
  // ─── الكميات ───
  final int quantity;
  final int minQuantity;

  // ─── الأسعار ───
  final double costPrice;
  final double sellingPrice;

  // ─── المورد ───
  final String? supplierId;

  // ─── الموقع ───
  final String? location;
  final String? imageUrl;

  // ─── الحالة ───
  final bool isActive;

  // ─── التواريخ ───
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryItem({
    required this.id,
    required this.tenantId,
    required this.name,
    this.nameAr,
    this.sku,
    this.barcode,
    this.category = InventoryCategory.other,
    this.variant = InventoryVariant.aftermarket,
    this.description,
    this.quantity = 0,
    this.minQuantity = 5,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.supplierId,
    this.location,
    this.imageUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  static const InventoryItem empty = InventoryItem(
    id: '',
    tenantId: '',
    name: '',
  );

  InventoryItem copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? nameAr,
    String? sku,
    String? barcode,
    InventoryCategory? category,
    InventoryVariant? variant,
    String? description,
    int? quantity,
    int? minQuantity,
    double? costPrice,
    double? sellingPrice,
    String? supplierId,
    String? location,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      variant: variant ?? this.variant,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplierId: supplierId ?? this.supplierId,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      category: InventoryCategoryX.fromString(json['category'] as String?),
      variant: InventoryVariantX.fromString(json['variant'] as String?),
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      minQuantity: (json['min_quantity'] as num?)?.toInt() ?? 5,
      costPrice: _parseDouble(json['cost_price']),
      sellingPrice: _parseDouble(json['selling_price']),
      supplierId: json['supplier_id'] as String?,
      location: json['location'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'name_ar': nameAr,
      'sku': sku,
      'barcode': barcode,
      'category': category.name,
      'variant': variant.name,
      'description': description,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'supplier_id': supplierId,
      'location': location,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  Map<String, dynamic> toMap() => toJson();

  factory InventoryItem.fromMap(Map<dynamic, dynamic> map) {
    return InventoryItem.fromJson(Map<String, dynamic>.from(map));
  }

  // ─── Getters ───

  String displayName({bool isArabic = true}) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  /// هل الكمية منخفضة؟
  bool get isLowStock => quantity <= minQuantity && quantity > 0;

  /// هل خلصت؟
  bool get isOutOfStock => quantity <= 0;

  /// هل متوفرة؟
  bool get isInStock => quantity > 0;

  /// الربح للقطعة
  double get profit => sellingPrice - costPrice;

  /// هامش الربح (%)
  double get profitMargin {
    if (costPrice <= 0) return 0;
    return ((sellingPrice - costPrice) / costPrice) * 100;
  }

  /// قيمة المخزون (بسعر التكلفة)
  double get stockValue => costPrice * quantity;

  /// حالة المخزون (نص + لون)
  String get stockStatusAr {
    if (isOutOfStock) return 'خلص';
    if (isLowStock) return 'منخفض';
    return 'متوفر';
  }

  Color get stockStatusColor {
    if (isOutOfStock) return const Color(0xFFEF4444);
    if (isLowStock) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItem &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.name == name &&
        other.quantity == quantity &&
        other.costPrice == costPrice &&
        other.sellingPrice == sellingPrice;
  }

  @override
  int get hashCode => Object.hash(
        id,
        tenantId,
        name,
        quantity,
        costPrice,
        sellingPrice,
      );

  @override
  String toString() {
    return 'InventoryItem($name, qty: $quantity, price: $sellingPrice)';
  }
}

// ═══════════════════════════════════════════════════════════
// Helper Functions
// ═══════════════════════════════════════════════════════════

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
