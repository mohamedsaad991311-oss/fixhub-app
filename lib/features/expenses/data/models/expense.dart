// lib/features/expenses/data/models/expense.dart

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
// ExpenseCategory — فئات المصروفات
// ═══════════════════════════════════════════════════════════

enum ExpenseCategory {
  rent, // إيجار
  salaries, // رواتب
  utilities, // مرافق (كهرباء، ماء، غاز)
  internet, // إنترنت
  phone, // تليفون
  supplies, // مستلزمات
  tools, // أدوات
  maintenance, // صيانة
  marketing, // تسويق
  transportation, // مواصلات
  taxes, // ضرائب
  insurance, // تأمين
  training, // تدريب
  subscriptions, // اشتراكات
  charity, // صدقات
  other, // أخرى
}

extension ExpenseCategoryX on ExpenseCategory {
  String get labelAr {
    switch (this) {
      case ExpenseCategory.rent:
        return 'إيجار';
      case ExpenseCategory.salaries:
        return 'رواتب';
      case ExpenseCategory.utilities:
        return 'مرافق';
      case ExpenseCategory.internet:
        return 'إنترنت';
      case ExpenseCategory.phone:
        return 'تليفون';
      case ExpenseCategory.supplies:
        return 'مستلزمات';
      case ExpenseCategory.tools:
        return 'أدوات';
      case ExpenseCategory.maintenance:
        return 'صيانة';
      case ExpenseCategory.marketing:
        return 'تسويق';
      case ExpenseCategory.transportation:
        return 'مواصلات';
      case ExpenseCategory.taxes:
        return 'ضرائب';
      case ExpenseCategory.insurance:
        return 'تأمين';
      case ExpenseCategory.training:
        return 'تدريب';
      case ExpenseCategory.subscriptions:
        return 'اشتراكات';
      case ExpenseCategory.charity:
        return 'صدقات';
      case ExpenseCategory.other:
        return 'أخرى';
    }
  }

  String get labelEn {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.salaries:
        return 'Salaries';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.internet:
        return 'Internet';
      case ExpenseCategory.phone:
        return 'Phone';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.tools:
        return 'Tools';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.taxes:
        return 'Taxes';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.training:
        return 'Training';
      case ExpenseCategory.subscriptions:
        return 'Subscriptions';
      case ExpenseCategory.charity:
        return 'Charity';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.rent:
        return Icons.home_work;
      case ExpenseCategory.salaries:
        return Icons.people;
      case ExpenseCategory.utilities:
        return Icons.electric_bolt;
      case ExpenseCategory.internet:
        return Icons.wifi;
      case ExpenseCategory.phone:
        return Icons.phone;
      case ExpenseCategory.supplies:
        return Icons.inventory;
      case ExpenseCategory.tools:
        return Icons.handyman;
      case ExpenseCategory.maintenance:
        return Icons.build;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.transportation:
        return Icons.local_shipping;
      case ExpenseCategory.taxes:
        return Icons.account_balance;
      case ExpenseCategory.insurance:
        return Icons.shield;
      case ExpenseCategory.training:
        return Icons.school;
      case ExpenseCategory.subscriptions:
        return Icons.card_membership;
      case ExpenseCategory.charity:
        return Icons.volunteer_activism;
      case ExpenseCategory.other:
        return Icons.receipt_long;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.rent:
        return const Color(0xFF3B82F6);
      case ExpenseCategory.salaries:
        return const Color(0xFF8B5CF6);
      case ExpenseCategory.utilities:
        return const Color(0xFFF59E0B);
      case ExpenseCategory.internet:
        return const Color(0xFF06B6D4);
      case ExpenseCategory.phone:
        return const Color(0xFF10B981);
      case ExpenseCategory.supplies:
        return const Color(0xFF6366F1);
      case ExpenseCategory.tools:
        return const Color(0xFF64748B);
      case ExpenseCategory.maintenance:
        return const Color(0xFFF97316);
      case ExpenseCategory.marketing:
        return const Color(0xFFEC4899);
      case ExpenseCategory.transportation:
        return const Color(0xFF14B8A6);
      case ExpenseCategory.taxes:
        return const Color(0xFFEF4444);
      case ExpenseCategory.insurance:
        return const Color(0xFF0EA5E9);
      case ExpenseCategory.training:
        return const Color(0xFF84CC16);
      case ExpenseCategory.subscriptions:
        return const Color(0xFFA855F7);
      case ExpenseCategory.charity:
        return const Color(0xFF22C55E);
      case ExpenseCategory.other:
        return const Color(0xFF6B7280);
    }
  }

  /// هل هي فئة ثابتة (شهرية)؟
  bool get isRecurring {
    return this == ExpenseCategory.rent ||
        this == ExpenseCategory.salaries ||
        this == ExpenseCategory.utilities ||
        this == ExpenseCategory.internet ||
        this == ExpenseCategory.phone ||
        this == ExpenseCategory.insurance ||
        this == ExpenseCategory.subscriptions;
  }

  static ExpenseCategory fromString(String? value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PaymentMethod (مبسط للمصروفات)
// ═══════════════════════════════════════════════════════════

enum ExpensePaymentMethod {
  cash,
  bankTransfer,
  creditCard,
  mobileWallet,
  check,
  other,
}

extension ExpensePaymentMethodX on ExpensePaymentMethod {
  String get labelAr {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return 'نقداً';
      case ExpensePaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case ExpensePaymentMethod.creditCard:
        return 'بطاقة ائتمانية';
      case ExpensePaymentMethod.mobileWallet:
        return 'محفظة إلكترونية';
      case ExpensePaymentMethod.check:
        return 'شيك';
      case ExpensePaymentMethod.other:
        return 'أخرى';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return Icons.money;
      case ExpensePaymentMethod.bankTransfer:
        return Icons.account_balance;
      case ExpensePaymentMethod.creditCard:
        return Icons.credit_card;
      case ExpensePaymentMethod.mobileWallet:
        return Icons.account_balance_wallet;
      case ExpensePaymentMethod.check:
        return Icons.receipt;
      case ExpensePaymentMethod.other:
        return Icons.payment;
    }
  }

  static ExpensePaymentMethod fromString(String? value) {
    return ExpensePaymentMethod.values.firstWhere(
      (e) => e.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => ExpensePaymentMethod.cash,
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Expense — النموذج الرئيسي
// ═══════════════════════════════════════════════════════════

class Expense {
  final String id;
  final String tenantId;
  final ExpenseCategory category;
  final String? description;
  final double amount;
  final DateTime expenseDate;
  final ExpensePaymentMethod paymentMethod;
  final String? receiptUrl;
  final String? vendor;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;

  const Expense({
    required this.id,
    required this.tenantId,
    required this.category,
    this.description,
    required this.amount,
    required this.expenseDate,
    this.paymentMethod = ExpensePaymentMethod.cash,
    this.receiptUrl,
    this.vendor,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  static Expense empty() => Expense(
        id: '',
        tenantId: '',
        category: ExpenseCategory.other,
        amount: 0,
        expenseDate: DateTime.now(),
      );

  Expense copyWith({
    String? id,
    String? tenantId,
    ExpenseCategory? category,
    String? description,
    double? amount,
    DateTime? expenseDate,
    ExpensePaymentMethod? paymentMethod,
    String? receiptUrl,
    String? vendor,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      vendor: vendor ?? this.vendor,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      tenantId: json['tenant_id'] as String? ?? '',
      category: ExpenseCategoryX.fromString(json['category'] as String?),
      description: json['description'] as String?,
      amount: _parseDouble(json['amount']),
      expenseDate: _parseDate(json['expense_date']) ?? DateTime.now(),
      paymentMethod: ExpensePaymentMethodX.fromString(
        json['payment_method'] as String?,
      ),
      receiptUrl: json['receipt_url'] as String?,
      vendor: json['vendor'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'category': category.name,
      'description': description,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T').first,
      'payment_method': paymentMethod.name,
      'receipt_url': receiptUrl,
      'vendor': vendor,
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

  factory Expense.fromMap(Map<dynamic, dynamic> map) {
    return Expense.fromJson(Map<String, dynamic>.from(map));
  }

  // ─── Getters ───

  /// الوصف المعروض (وصف أو اسم الفئة)
  String displayDescription({bool isArabic = true}) {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return isArabic ? category.labelAr : category.labelEn;
  }

  /// هل هي نفس الشهر؟
  bool isSameMonth(DateTime date) {
    return expenseDate.year == date.year && expenseDate.month == date.month;
  }

  /// هل هي نفس السنة؟
  bool isSameYear(DateTime date) {
    return expenseDate.year == date.year;
  }

  /// هل هي فئة ثابتة؟
  bool get isRecurring => category.isRecurring;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.category == category &&
        other.amount == amount &&
        other.expenseDate == expenseDate;
  }

  @override
  int get hashCode => Object.hash(id, tenantId, category, amount, expenseDate);

  @override
  String toString() {
    return 'Expense(${category.name}, amount: $amount, date: $expenseDate)';
  }
}

// ═══════════════════════════════════════════════════════════
// ExpenseSummary — ملخص مصروفات (للتقارير)
// ═══════════════════════════════════════════════════════════

class ExpenseSummary {
  final double total;
  final double average;
  final int count;
  final Map<ExpenseCategory, double> byCategory;
  final double? largestExpense;

  const ExpenseSummary({
    this.total = 0,
    this.average = 0,
    this.count = 0,
    this.byCategory = const {},
    this.largestExpense,
  });

  /// حساب الملخص من قائمة مصروفات
  factory ExpenseSummary.fromExpenses(List<Expense> expenses) {
    if (expenses.isEmpty) return const ExpenseSummary();

    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final byCategory = <ExpenseCategory, double>{};

    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    final largest =
        expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return ExpenseSummary(
      total: total,
      average: total / expenses.length,
      count: expenses.length,
      byCategory: byCategory,
      largestExpense: largest,
    );
  }

  /// أعلى فئة
  MapEntry<ExpenseCategory, double>? get topCategory {
    if (byCategory.isEmpty) return null;
    return byCategory.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
  }

  /// نسبة كل فئة
  Map<ExpenseCategory, double> get categoryPercentages {
    if (total <= 0) return {};
    return byCategory.map(
      (key, value) => MapEntry(key, (value / total) * 100),
    );
  }
}
