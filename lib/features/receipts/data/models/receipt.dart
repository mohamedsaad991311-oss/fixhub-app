// lib/features/receipts/data/models/receipt.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// Helper Functions — دوال مساعدة عامة
/// ═══════════════════════════════════════════════════════════

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

List<T> _parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (value == null) return [];
  if (value is List) {
    return value
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return [];
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

/// ═══════════════════════════════════════════════════════════
/// ReceiptStatus — حالات الإيصال (5 حالات + رفض)
/// ═══════════════════════════════════════════════════════════
enum ReceiptStatus {
  received,
  inProgress,
  waitingParts,
  ready,
  delivered,
  rejected,
}

extension ReceiptStatusX on ReceiptStatus {
  String get labelAr {
    switch (this) {
      case ReceiptStatus.received:
        return 'تم الاستلام';
      case ReceiptStatus.inProgress:
        return 'قيد الإصلاح';
      case ReceiptStatus.waitingParts:
        return 'في انتظار قطعة';
      case ReceiptStatus.ready:
        return 'جاهز للاستلام';
      case ReceiptStatus.delivered:
        return 'تم التسليم';
      case ReceiptStatus.rejected:
        return 'مرفوض';
    }
  }

  String get labelEn {
    switch (this) {
      case ReceiptStatus.received:
        return 'Received';
      case ReceiptStatus.inProgress:
        return 'In Progress';
      case ReceiptStatus.waitingParts:
        return 'Waiting for Parts';
      case ReceiptStatus.ready:
        return 'Ready';
      case ReceiptStatus.delivered:
        return 'Delivered';
      case ReceiptStatus.rejected:
        return 'Rejected';
    }
  }

  IconData get icon {
    switch (this) {
      case ReceiptStatus.received:
        return Icons.inbox;
      case ReceiptStatus.inProgress:
        return Icons.build;
      case ReceiptStatus.waitingParts:
        return Icons.hourglass_empty;
      case ReceiptStatus.ready:
        return Icons.check_circle;
      case ReceiptStatus.delivered:
        return Icons.local_shipping;
      case ReceiptStatus.rejected:
        return Icons.cancel;
    }
  }

  Color get color {
    switch (this) {
      case ReceiptStatus.received:
        return const Color(0xFF3B82F6);
      case ReceiptStatus.inProgress:
        return const Color(0xFFF59E0B);
      case ReceiptStatus.waitingParts:
        return const Color(0xFF8B5CF6);
      case ReceiptStatus.ready:
        return const Color(0xFF10B981);
      case ReceiptStatus.delivered:
        return const Color(0xFF6B7280);
      case ReceiptStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  bool get isFinal =>
      this == ReceiptStatus.delivered || this == ReceiptStatus.rejected;

  bool get isActive => !isFinal;

  int get order {
    switch (this) {
      case ReceiptStatus.received:
        return 0;
      case ReceiptStatus.inProgress:
        return 1;
      case ReceiptStatus.waitingParts:
        return 2;
      case ReceiptStatus.ready:
        return 3;
      case ReceiptStatus.delivered:
        return 4;
      case ReceiptStatus.rejected:
        return 5;
    }
  }

  static ReceiptStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'received':
        return ReceiptStatus.received;
      case 'in_progress':
      case 'inprogress':
        return ReceiptStatus.inProgress;
      case 'waiting_parts':
      case 'waitingparts':
        return ReceiptStatus.waitingParts;
      case 'ready':
        return ReceiptStatus.ready;
      case 'delivered':
        return ReceiptStatus.delivered;
      case 'rejected':
        return ReceiptStatus.rejected;
      default:
        return ReceiptStatus.received;
    }
  }

  ReceiptStatus? get next {
    switch (this) {
      case ReceiptStatus.received:
        return ReceiptStatus.inProgress;
      case ReceiptStatus.inProgress:
        return ReceiptStatus.ready;
      case ReceiptStatus.waitingParts:
        return ReceiptStatus.inProgress;
      case ReceiptStatus.ready:
        return ReceiptStatus.delivered;
      case ReceiptStatus.delivered:
      case ReceiptStatus.rejected:
        return null;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReceiptPriority — الأولوية
/// ═══════════════════════════════════════════════════════════
enum ReceiptPriority {
  low,
  normal,
  high,
  urgent,
}

extension ReceiptPriorityX on ReceiptPriority {
  String get labelAr {
    switch (this) {
      case ReceiptPriority.low:
        return 'منخفضة';
      case ReceiptPriority.normal:
        return 'عادية';
      case ReceiptPriority.high:
        return 'عالية';
      case ReceiptPriority.urgent:
        return 'عاجلة';
    }
  }

  String get labelEn {
    switch (this) {
      case ReceiptPriority.low:
        return 'Low';
      case ReceiptPriority.normal:
        return 'Normal';
      case ReceiptPriority.high:
        return 'High';
      case ReceiptPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case ReceiptPriority.low:
        return const Color(0xFF6B7280);
      case ReceiptPriority.normal:
        return const Color(0xFF3B82F6);
      case ReceiptPriority.high:
        return const Color(0xFFF59E0B);
      case ReceiptPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }

  static ReceiptPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
        return ReceiptPriority.low;
      case 'high':
        return ReceiptPriority.high;
      case 'urgent':
        return ReceiptPriority.urgent;
      default:
        return ReceiptPriority.normal;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReceiptIssue — مشكلة واحدة
/// ═══════════════════════════════════════════════════════════
class ReceiptIssue {
  final String title;
  final String? description;
  final double? cost;
  final bool isResolved;

  const ReceiptIssue({
    required this.title,
    this.description,
    this.cost,
    this.isResolved = false,
  });

  ReceiptIssue copyWith({
    String? title,
    String? description,
    double? cost,
    bool? isResolved,
  }) {
    return ReceiptIssue(
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'cost': cost,
        'is_resolved': isResolved,
      };

  factory ReceiptIssue.fromJson(Map<String, dynamic> json) {
    return ReceiptIssue(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      isResolved: json['is_resolved'] as bool? ?? false,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// ReceiptAccessory — ملحق واحد
/// ═══════════════════════════════════════════════════════════
class ReceiptAccessory {
  final String name;
  final bool isIncluded;
  final String? notes;

  const ReceiptAccessory({
    required this.name,
    this.isIncluded = true,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'is_included': isIncluded,
        'notes': notes,
      };

  factory ReceiptAccessory.fromJson(Map<String, dynamic> json) {
    return ReceiptAccessory(
      name: json['name'] as String? ?? '',
      isIncluded: json['is_included'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// StatusChange — تغيير حالة
/// ═══════════════════════════════════════════════════════════
class StatusChange {
  final ReceiptStatus status;
  final DateTime changedAt;
  final String? note;
  final String? changedBy;

  const StatusChange({
    required this.status,
    required this.changedAt,
    this.note,
    this.changedBy,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'changed_at': changedAt.toIso8601String(),
        'note': note,
        'changed_by': changedBy,
      };

  factory StatusChange.fromJson(Map<String, dynamic> json) {
    return StatusChange(
      status: ReceiptStatusX.fromString(json['status'] as String?),
      changedAt: _parseDate(json['changed_at']) ?? DateTime.now(),
      note: json['note'] as String?,
      changedBy: json['changed_by'] as String?,
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// Receipt — النموذج الرئيسي
/// ═══════════════════════════════════════════════════════════
class Receipt {
  final String id;
  final String tenantId;
  final String receiptNumber;

  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerNotes;

  final String? deviceType;
  final String? deviceBrand;
  final String? deviceModel;
  final String? deviceImei;
  final String? deviceSerial;
  final String? deviceColor;
  final String? devicePassword;
  final String? conditionNotes;

  final List<ReceiptIssue> issues;
  final List<ReceiptAccessory> accessories;
  final List<String> images;

  final ReceiptStatus status;
  final List<StatusChange> statusHistory;
  final ReceiptPriority priority;

  final double estimatedCost;
  final double finalCost;
  final double deposit;
  final double discount;
  final double tax;
  final double total;

  final String? trackingToken;
  final String? technicianId;
  final int warrantyDays;

  final String? notes;
  final String? internalNotes;

  final DateTime? expectedDeliveryDate;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const Receipt({
    required this.id,
    required this.tenantId,
    required this.receiptNumber,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerNotes,
    this.deviceType,
    this.deviceBrand,
    this.deviceModel,
    this.deviceImei,
    this.deviceSerial,
    this.deviceColor,
    this.devicePassword,
    this.conditionNotes,
    this.issues = const [],
    this.accessories = const [],
    this.images = const [],
    this.status = ReceiptStatus.received,
    this.statusHistory = const [],
    this.priority = ReceiptPriority.normal,
    this.estimatedCost = 0,
    this.finalCost = 0,
    this.deposit = 0,
    this.discount = 0,
    this.tax = 0,
    this.total = 0,
    this.trackingToken,
    this.technicianId,
    this.warrantyDays = 0,
    this.notes,
    this.internalNotes,
    this.expectedDeliveryDate,
    this.deliveredAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  static const Receipt empty = Receipt(
    id: '',
    tenantId: '',
    receiptNumber: '',
    customerName: '',
  );

  Receipt copyWith({
    String? id,
    String? tenantId,
    String? receiptNumber,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerNotes,
    String? deviceType,
    String? deviceBrand,
    String? deviceModel,
    String? deviceImei,
    String? deviceSerial,
    String? deviceColor,
    String? devicePassword,
    String? conditionNotes,
    List<ReceiptIssue>? issues,
    List<ReceiptAccessory>? accessories,
    List<String>? images,
    ReceiptStatus? status,
    List<StatusChange>? statusHistory,
    ReceiptPriority? priority,
    double? estimatedCost,
    double? finalCost,
    double? deposit,
    double? discount,
    double? tax,
    double? total,
    String? trackingToken,
    String? technicianId,
    int? warrantyDays,
    String? notes,
    String? internalNotes,
    DateTime? expectedDeliveryDate,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Receipt(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerNotes: customerNotes ?? this.customerNotes,
      deviceType: deviceType ?? this.deviceType,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceImei: deviceImei ?? this.deviceImei,
      deviceSerial: deviceSerial ?? this.deviceSerial,
      deviceColor: deviceColor ?? this.deviceColor,
      devicePassword: devicePassword ?? this.devicePassword,
      conditionNotes: conditionNotes ?? this.conditionNotes,
      issues: issues ?? this.issues,
      accessories: accessories ?? this.accessories,
      images: images ?? this.images,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      deposit: deposit ?? this.deposit,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      trackingToken: trackingToken ?? this.trackingToken,
      technicianId: technicianId ?? this.technicianId,
      warrantyDays: warrantyDays ?? this.warrantyDays,
      notes: notes ?? this.notes,
      internalNotes: internalNotes ?? this.internalNotes,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      receiptNumber: json['receipt_number'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String?,
      customerNotes: json['customer_notes'] as String?,
      deviceType: json['device_type'] as String?,
      deviceBrand: json['device_brand'] as String?,
      deviceModel: json['device_model'] as String?,
      deviceImei: json['device_imei'] as String?,
      deviceSerial: json['device_serial'] as String?,
      deviceColor: json['device_color'] as String?,
      devicePassword: json['device_password'] as String?,
      conditionNotes: json['condition_notes'] as String?,
      issues: _parseList(json['issues'], ReceiptIssue.fromJson),
      accessories: _parseList(
        json['accessories'],
        ReceiptAccessory.fromJson,
      ),
      images: _parseStringList(json['images']),
      status: ReceiptStatusX.fromString(json['status'] as String?),
      statusHistory: _parseList(
        json['status_history'],
        StatusChange.fromJson,
      ),
      priority: ReceiptPriorityX.fromString(json['priority'] as String?),
      estimatedCost: _parseDouble(json['estimated_cost']),
      finalCost: _parseDouble(json['final_cost']),
      deposit: _parseDouble(json['deposit']),
      discount: _parseDouble(json['discount']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      trackingToken: json['tracking_token'] as String?,
      technicianId: json['technician_id'] as String?,
      warrantyDays: (json['warranty_days'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      internalNotes: json['internal_notes'] as String?,
      expectedDeliveryDate: _parseDate(json['expected_delivery_date']),
      deliveredAt: _parseDate(json['delivered_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'receipt_number': receiptNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'customer_notes': customerNotes,
      'device_type': deviceType,
      'device_brand': deviceBrand,
      'device_model': deviceModel,
      'device_imei': deviceImei,
      'device_serial': deviceSerial,
      'device_color': deviceColor,
      'device_password': devicePassword,
      'condition_notes': conditionNotes,
      'issues': issues.map((e) => e.toJson()).toList(),
      'accessories': accessories.map((e) => e.toJson()).toList(),
      'images': images,
      'status': status.name,
      'status_history': statusHistory.map((e) => e.toJson()).toList(),
      'priority': priority.name,
      'estimated_cost': estimatedCost,
      'final_cost': finalCost,
      'deposit': deposit,
      'discount': discount,
      'tax': tax,
      'total': total,
      'tracking_token': trackingToken,
      'technician_id': technicianId,
      'warranty_days': warrantyDays,
      'notes': notes,
      'internal_notes': internalNotes,
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_by': createdBy,
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

  factory Receipt.fromMap(Map<dynamic, dynamic> map) {
    return Receipt.fromJson(Map<String, dynamic>.from(map));
  }

  // ─── Getters ───

  String get deviceFullName {
    final parts = [deviceBrand, deviceModel]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'جهاز غير محدد';
    return parts.join(' ');
  }

  double get remainingAmount => total - deposit;

  double get issuesTotalCost {
    return issues.fold(0.0, (sum, issue) => sum + (issue.cost ?? 0));
  }

  int get issuesCount => issues.length;
  int get accessoriesCount => accessories.length;
  bool get isFinal => status.isFinal;
  bool get isReady => status == ReceiptStatus.ready;

  bool get isDelayed {
    if (expectedDeliveryDate == null) return false;
    if (isFinal) return false;
    return DateTime.now().isAfter(expectedDeliveryDate!);
  }

  bool get isDelivered => status == ReceiptStatus.delivered;

  bool get hasActiveWarranty {
    if (deliveredAt == null || warrantyDays <= 0) return false;
    final warrantyEnd = deliveredAt!.add(Duration(days: warrantyDays));
    return DateTime.now().isBefore(warrantyEnd);
  }

  DateTime? get warrantyEndDate {
    if (deliveredAt == null || warrantyDays <= 0) return null;
    return deliveredAt!.add(Duration(days: warrantyDays));
  }

  int get daysWaiting {
    if (createdAt == null) return 0;
    final end = deliveredAt ?? DateTime.now();
    return end.difference(createdAt!).inDays;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Receipt &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.receiptNumber == receiptNumber &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, tenantId, receiptNumber, status);

  @override
  String toString() {
    return 'Receipt($receiptNumber, customer: $customerName, status: ${status.name})';
  }
}
