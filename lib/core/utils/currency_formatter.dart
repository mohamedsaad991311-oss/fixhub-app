// lib/core/utils/currency_formatter.dart

import 'package:intl/intl.dart';
import '../config/app_config.dart';

/// ═══════════════════════════════════════════════════════════
/// CurrencyFormatter — تنسيق العملة والأرقام المالية
/// ═══════════════════════════════════════════════════════════
///
/// بيستخدم إعدادات العملة من AppConfig.
/// لو حبيت تغير العملة، عدّل AppConfig.currencySymbol.
///
class CurrencyFormatter {
  CurrencyFormatter._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) FORMAT — تنسيق العملة
  // ═══════════════════════════════════════════════════════════

  /// تنسيق المبلغ مع رمز العملة
  ///
  /// مثال: 1234.5 → "1,234.50 ج.م"
  static String format(num? amount, {
    String? symbol,
    bool showSymbol = true,
    int? decimals,
  }) {
    if (amount == null) return '0';

    final dec = decimals ?? AppConfig.currencyDecimals;
    final sym = symbol ?? AppConfig.currencySymbol;

    final formatter = NumberFormat.currency(
      symbol: showSymbol ? sym : '',
      decimalDigits: dec,
    );

    final formatted = formatter.format(amount).trim();

    // لو العملة بعد الرقم (مصر)
    if (!AppConfig.currencySymbolBefore && showSymbol) {
      // formatter بيلزق الرمز قبل الرقم
      // عشان نغيره، نشيل الرمز من الأول ونضيفه في الآخر
      final numberOnly = NumberFormat('#,##0.${'0' * dec}').format(amount);
      return '$numberOnly $sym';
    }

    return formatted;
  }

  /// تنسيق المبلغ (الرمز في الأول) — للاستخدام مع الدولار
  ///
  /// مثال: $1,234.50
  static String formatPrefix(num? amount, {
    String? symbol,
    int? decimals,
  }) {
    if (amount == null) return '0';
    final dec = decimals ?? AppConfig.currencyDecimals;
    final sym = symbol ?? AppConfig.currencySymbol;
    final formatter = NumberFormat('#,##0.${'0' * dec}');
    return '$sym${formatter.format(amount)}';
  }

  /// تنسيق رقم بدون رمز العملة
  ///
  /// مثال: 1234.5 → "1,234.50"
  static String formatNumber(num? amount, {int? decimals}) {
    if (amount == null) return '0';
    final dec = decimals ?? AppConfig.currencyDecimals;
    final formatter = NumberFormat('#,##0.${'0' * dec}');
    return formatter.format(amount);
  }

  /// تنسيق رقم صحيح (بدون خانات عشرية)
  ///
  /// مثال: 1234.5 → "1,235"
  static String formatInteger(num? amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat('#,##0');
    return formatter.format(amount.round());
  }

  /// تنسيق مختصر للأرقام الكبيرة
  ///
  /// مثال: 1234567 → "1.23M ج.م"
  static String formatCompact(num? amount, {String? symbol}) {
    if (amount == null) return '0';

    final sym = symbol ?? AppConfig.currencySymbol;
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1)}M $sym';
    } else if (abs >= 1000) {
      return '$sign${(abs / 1000).toStringAsFixed(1)}K $sym';
    }
    return '$sign${formatNumber(abs, decimals: 0)} $sym';
  }

  // ═══════════════════════════════════════════════════════════
  // 2) PARSE — قراءة المبلغ من نص
  // ═══════════════════════════════════════════════════════════

  /// تحويل نص لمبلغ (يتم تجاهل كل الرموز والفَواصِل)
  ///
  /// مثال: "1,234.50 ج.م" → 1234.5
  static double? parse(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    // إزالة كل حاجة مش رقم أو نقطة أو سالب
    final cleaned = text
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^\d.\-]'), '');

    return double.tryParse(cleaned);
  }

  /// تحويل نص لـ num (int أو double)
  static num? parseFlexible(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    final cleaned = text.replaceAll(',', '').replaceAll(RegExp(r'[^\d.\-]'), '');

    return num.tryParse(cleaned);
  }

  // ═══════════════════════════════════════════════════════════
  // 3) FORMATTERS — للاستخدام مع TextFormField
  // ═══════════════════════════════════════════════════════════

  /// تنسيق أثناء الكتابة (Live Formatter)
  ///
  /// مثال: المستخدم بيكتب "1234567" → "1,234,567"
  static String formatWhileTyping(String input) {
    if (input.isEmpty) return input;

    // شيل الفواصل الموجودة
    final cleaned = input.replaceAll(',', '');

    // لو فيه نقطة، اقسم
    final parts = cleaned.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // ضيف فواصل
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return '$buffer$decimalPart';
  }

  // ═══════════════════════════════════════════════════════════
  // 4) CALCULATIONS — حسابات مالية
  // ═══════════════════════════════════════════════════════════

  /// حساب الضريبة
  static double calculateTax(
    num amount, {
    double? taxRate,
  }) {
    final rate = taxRate ?? AppConfig.defaultTaxRate;
    return amount * rate;
  }

  /// حساب الإجمالي مع الضريبة
  static double calculateTotal(
    num amount, {
    double? taxRate,
    double discount = 0,
  }) {
    final afterDiscount = amount - discount;
    final tax = calculateTax(afterDiscount, taxRate: taxRate);
    return afterDiscount + tax;
  }

  /// حساب الخصم بنسبة مئوية
  static double calculateDiscountPercent(num amount, double percent) {
    return amount * (percent / 100);
  }

  /// حساب النسبة المئوية
  static double calculatePercent(num amount, double percent) {
    return amount * (percent / 100);
  }

  /// حساب الإجمالي الفرعي (مجموع الأرقام)
  static double sum(Iterable<num> amounts) {
    return amounts.fold(0.0, (sum, val) => sum + val);
  }

  /// حساب المتوسط
  static double average(Iterable<num> amounts) {
    if (amounts.isEmpty) return 0;
    return sum(amounts) / amounts.length;
  }

  // ═══════════════════════════════════════════════════════════
  // 5) DISPLAY — عرض مختصر
  // ═══════════════════════════════════════════════════════════

  /// تنسيق مختصر جداً (بدون خانات عشرية)
  ///
  /// مثال: 1234.5 → "1,235 ج.م"
  static String formatShort(num? amount, {String? symbol}) {
    if (amount == null) return '0';
    final sym = symbol ?? AppConfig.currencySymbol;
    final rounded = amount.round();
    final formatted = NumberFormat('#,##0').format(rounded);
    return AppConfig.currencySymbolBefore
        ? '$sym$formatted'
        : '$formatted $sym';
  }

  /// تنسيق مع إشارة (+/-)
  ///
  /// مثال: 100 → "+100 ج.م" ، -50 → "-50 ج.م"
  static String formatSigned(num? amount, {String? symbol}) {
    if (amount == null) return '0';
    final formatted = format(amount.abs(), symbol: symbol);
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }

  // ═══════════════════════════════════════════════════════════
  // 6) ARABIC — تنسيق بالأرقام العربية
  // ═══════════════════════════════════════════════════════════

  /// تحويل الأرقام الإنجليزية لعربية (٠١٢٣٤٥٦٧٨٩)
  static String toArabicDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = text;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// تنسيق المبلغ بالأرقام العربية
  static String formatArabic(num? amount, {String? symbol}) {
    final formatted = format(amount, symbol: symbol);
    return toArabicDigits(formatted);
  }
}