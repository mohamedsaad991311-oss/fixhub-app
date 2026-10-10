// lib/features/suppliers/data/models/supplier.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// Helper Functions
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

// ═══════════════════════════════════════════════════════════
// Invoice Status
// ═══════════════════════════════════════════════════════════

enum InvoiceStatus {
  pending, // في انتظار الدفع
  partial, // مدفوع جزئياً
  paid, // مدفوع
  overdue, // متأخر
  cancelled, // ملغي
}

extension InvoiceStatusX on InvoiceStatus {
  String get labelAr {
    switch (this) {
      case InvoiceStatus.pending:
        return 'في انتظار الدفع';
      case InvoiceStatus.partial:
        return 'مدفوع جزئياً';
      case InvoiceStatus.paid:
        return 'مدفوع';
      case InvoiceStatus.overdue:
        return 'متأخر';
      case InvoiceStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case InvoiceStatus.pending:
        return const Color(0xFFF59E0B);
      case InvoiceStatus.partial:
        return const Color(0xFF3B82F6);
      case InvoiceStatus.paid:
        return const Color(0xFF10B981);
      case InvoiceStatus.overdue:
        return const Color(0xFFEF4444);
      case InvoiceStatus.cancelled:
        return const Color(0xFF6B7280);
    }
  }

  static InvoiceStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return InvoiceStatus.pending;
      case 'partial':
        return InvoiceStatus.partial;
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.pending;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// Return Status
// ═══════════════════════════════════════════════════════════

enum ReturnStatus {
  pending, // في انتظار الموافقة
  approved, // تمت الموافقة
  completed, // تم الاستلام
  rejected, // مرفوض
}

extension ReturnStatusX on ReturnStatus {
  String get labelAr {
    switch (this) {
      case ReturnStatus.pending:
        return 'في انتظار الموافقة';
      case ReturnStatus.approved:
        return 'تمت الموافقة';
      case ReturnStatus.completed:
        return 'تم الاستلام';
      case ReturnStatus.rejected:
        return 'مرفوض';
    }
  }

  Color get color {
    switch (this) {
      case ReturnStatus.pending:
        return const Color(0xFFF59E0B);
      case ReturnStatus.approved:
        return const Color(0xFF3B82F6);
      case ReturnStatus.completed:
        return const Color(0xFF10B981);
      case ReturnStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  static ReturnStatus fromString(String? value) {
    return ReturnStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ReturnStatus.pending,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Payment Method
// ═══════════════════════════════════════════════════════════

enum PaymentMethod {
  cash,
  bankTransfer,
  creditCard,
  mobileWallet,
  check,
  other,
}

extension PaymentMethodX on PaymentMethod {
  String get labelAr {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقداً';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.creditCard:
        return 'بطاقة ائتمانية';
      case PaymentMethod.mobileWallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.check:
        return 'شيك';
      case PaymentMethod.other:
        return 'أخرى';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.mobileWallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.check:
        return Icons.receipt;
      case PaymentMethod.other:
        return Icons.payment;
    }
  }

  static PaymentMethod fromString(String? value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Invoice Item — بند في الفاتورة
// ═══════════════════════════════════════════════════════════

class InvoiceItem {
  final String inventoryId;
  final String name;
  final int quantity;
  final double unitCost;
  final double total;

  const InvoiceItem({
    required this.inventoryId,
    required this.name,
    required this.quantity,
    required this.unitCost,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'inventory_id': inventoryId,
        'name': name,
        'quantity': quantity,
        'unit_cost': unitCost,
        'total': total,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      inventoryId: json['inventory_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitCost: _parseDouble(json['unit_cost']),
      total: _parseDouble(json['total']),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Supplier — المورد
// ═══════════════════════════════════════════════════════════

class Supplier {
  final String id;
  final String tenantId;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final double balance;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Supplier({
    required this.id,
    required this.tenantId,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.balance = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  static const Supplier empty = Supplier(
    id: '',
    tenantId: '',
    name: '',
  );

  Supplier copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? notes,
    double? balance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      balance: _parseDouble(json['balance']),
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
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'balance': balance,
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

  factory Supplier.fromMap(Map<dynamic, dynamic> map) {
    return Supplier.fromJson(Map<String, dynamic>.from(map));
  }

  // ─── Getters ───
  String get initials {
    final n = name.trim();
    if (n.isEmpty) return '?';
    final parts = n.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get hasDebt => balance > 0;
  bool get isOwed => balance < 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.name == name &&
        other.balance == balance &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, tenantId, name, balance, isActive);

  @override
  String toString() => 'Supplier($name, balance: $balance)';
}

// ═══════════════════════════════════════════════════════════
// SupplierInvoice — فاتورة مورد
// ═══════════════════════════════════════════════════════════

class SupplierInvoice {
  final String id;
  final String tenantId;
  final String supplierId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double total;
  final double paid;
  final double remaining;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupplierInvoice({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.dueDate,
    this.total = 0,
    this.paid = 0,
    this.remaining = 0,
    this.status = InvoiceStatus.pending,
    this.items = const [],
    this.notes,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  SupplierInvoice copyWith({
    String? id,
    String? tenantId,
    String? supplierId,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? total,
    double? paid,
    double? remaining,
    InvoiceStatus? status,
    List<InvoiceItem>? items,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierInvoice(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      supplierId: supplierId ?? this.supplierId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      total: total ?? this.total,
      paid: paid ?? this.paid,
      remaining: remaining ?? this.remaining,
      status: status ?? this.status,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SupplierInvoice.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
            ?.whereType<Map>()
            .map((e) => InvoiceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return SupplierInvoice(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      supplierId: json['supplier_id'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String? ?? '',
      invoiceDate: _parseDate(json['invoice_date']) ?? DateTime.now(),
      dueDate: _parseDate(json['due_date']),
      total: _parseDouble(json['total']),
      paid: _parseDouble(json['paid']),
      remaining: _parseDouble(json['remaining']),
      status: InvoiceStatusX.fromString(json['status'] as String?),
      items: items,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'supplier_id': supplierId,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String().split('T').first,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'total': total,
      'paid': paid,
      'remaining': remaining,
      'status': status.name,
      'items': items.map((e) => e.toJson()).toList(),
      'notes': notes,
      'created_by': createdBy,
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

  factory SupplierInvoice.fromMap(Map<dynamic, dynamic> map) {
    return SupplierInvoice.fromJson(Map<String, dynamic>.from(map));
  }

  // ─── Getters ───
  double get remainingAmount => total - paid;
  double get paidPercentage {
    if (total <= 0) return 0;
    return (paid / total) * 100;
  }

  bool get isFullyPaid => paid >= total;
  bool get isOverdue {
    if (dueDate == null) return false;
    if (isFullyPaid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  int get itemsCount => items.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierInvoice &&
        other.id == id &&
        other.invoiceNumber == invoiceNumber &&
        other.total == total &&
        other.paid == paid &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, invoiceNumber, total, paid, status);

  @override
  String toString() =>
      'SupplierInvoice($invoiceNumber, total: $total, paid: $paid)';
}

// ═══════════════════════════════════════════════════════════
// SupplierPayment — دفعة لمورد
// ═══════════════════════════════════════════════════════════

class SupplierPayment {
  final String id;
  final String tenantId;
  final String supplierId;
  final String? invoiceId;
  final double amount;
  final PaymentMethod paymentMethod;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  const SupplierPayment({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    this.invoiceId,
    required this.amount,
    this.paymentMethod = PaymentMethod.cash,
    required this.paymentDate,
    this.reference,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  factory SupplierPayment.fromJson(Map<String, dynamic> json) {
    return SupplierPayment(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      supplierId: json['supplier_id'] as String? ?? '',
      invoiceId: json['invoice_id'] as String?,
      amount: _parseDouble(json['amount']),
      paymentMethod:
          PaymentMethodX.fromString(json['payment_method'] as String?),
      paymentDate: _parseDate(json['payment_date']) ?? DateTime.now(),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'supplier_id': supplierId,
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'payment_date': paymentDate.toIso8601String().split('T').first,
      'reference': reference,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    return json;
  }

  Map<String, dynamic> toMap() => toJson();

  factory SupplierPayment.fromMap(Map<dynamic, dynamic> map) {
    return SupplierPayment.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierPayment &&
        other.id == id &&
        other.amount == amount &&
        other.paymentDate == paymentDate;
  }

  @override
  int get hashCode => Object.hash(id, amount, paymentDate);

  @override
  String toString() =>
      'SupplierPayment(amount: $amount, method: ${paymentMethod.name})';
}

// ═══════════════════════════════════════════════════════════
// SupplierReturn — مرتجع لمورد
// ═══════════════════════════════════════════════════════════

class SupplierReturn {
  final String id;
  final String tenantId;
  final String supplierId;
  final String? invoiceId;
  final String? returnNumber;
  final DateTime returnDate;
  final double total;
  final List<InvoiceItem> items;
  final String? reason;
  final ReturnStatus status;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  const SupplierReturn({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    this.invoiceId,
    this.returnNumber,
    required this.returnDate,
    this.total = 0,
    this.items = const [],
    this.reason,
    this.status = ReturnStatus.pending,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  factory SupplierReturn.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?)
            ?.whereType<Map>()
            .map((e) => InvoiceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        [];

    return SupplierReturn(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      supplierId: json['supplier_id'] as String? ?? '',
      invoiceId: json['invoice_id'] as String?,
      returnNumber: json['return_number'] as String?,
      returnDate: _parseDate(json['return_date']) ?? DateTime.now(),
      total: _parseDouble(json['total']),
      items: items,
      reason: json['reason'] as String?,
      status: ReturnStatusX.fromString(json['status'] as String?),
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'supplier_id': supplierId,
      'invoice_id': invoiceId,
      'return_number': returnNumber,
      'return_date': returnDate.toIso8601String().split('T').first,
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
      'reason': reason,
      'status': status.name,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    return json;
  }

  Map<String, dynamic> toMap() => toJson();

  factory SupplierReturn.fromMap(Map<dynamic, dynamic> map) {
    return SupplierReturn.fromJson(Map<String, dynamic>.from(map));
  }

  int get itemsCount => items.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierReturn &&
        other.id == id &&
        other.total == total &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, total, status);

  @override
  String toString() => 'SupplierReturn(total: $total, status: ${status.name})';
}
