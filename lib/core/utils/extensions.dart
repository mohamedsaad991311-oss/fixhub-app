// lib/core/utils/extensions.dart

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════
/// Extensions — إضافات مفيدة على الأنواع الأساسية
/// ═══════════════════════════════════════════════════════════
///
/// - String: capitalize, isEmail, truncate, ...
/// - BuildContext: theme, colors, size, ...
/// - num: toArabic, currency, ...
/// - List: separated, ...
/// - DateTime: (مغطة في date_utils)
///

// ═══════════════════════════════════════════════════════════
// 1) String Extensions
// ═══════════════════════════════════════════════════════════

extension StringX on String {
  /// أول حرف كابيتال
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// كل كلمة كابيتال
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((w) => w.capitalize).join(' ');
  }

  /// حذف المسافات الزيادة
  String get trimmed => trim();

  /// هل فاضي (بعد trim)؟
  bool get isBlank => trim().isEmpty;

  /// هل مش فاضي (بعد trim)؟
  bool get isNotBlank => trim().isNotEmpty;

  /// هل بريد إلكتروني؟
  bool get isEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }

  /// هل رقم موبايل مصري؟
  bool get isEgyptPhone {
    final regex = RegExp(r'^(010|011|012|015)\d{8}$');
    return regex.hasMatch(this);
  }

  /// هل رقم فقط؟
  bool get isNumeric => double.tryParse(this) != null;

  /// هل رقم صحيح فقط؟
  bool get isInteger => int.tryParse(this) != null;

  /// هل يحتوي على عربي؟
  bool get hasArabic {
    final regex = RegExp(r'[\u0600-\u06FF]');
    return regex.hasMatch(this);
  }

  /// هل يحتوي على إنجليزي؟
  bool get hasEnglish {
    final regex = RegExp(r'[a-zA-Z]');
    return regex.hasMatch(this);
  }

  /// تحويل لـ int (أو 0)
  int get toInt => int.tryParse(this) ?? 0;

  /// تحويل لـ double (أو 0.0)
  double get toDouble => double.tryParse(this) ?? 0.0;

  /// تقصير النص مع ...
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// حذف أول N حرف
  String removeFirst(int n) {
    if (n >= length) return '';
    return substring(n);
  }

  /// حذف آخر N حرف
  String removeLast(int n) {
    if (n >= length) return '';
    return substring(0, length - n);
  }

  /// إخفاء جزء (للبيانات الحساسة)
  String mask({int visibleStart = 0, int visibleEnd = 0, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;
    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final masked = maskChar * (length - visibleStart - visibleEnd);
    return '$start$masked$end';
  }

  /// إزالة التشكيل من العربي
  String get removeArabicDiacritics {
    return replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  }
}

// ═══════════════════════════════════════════════════════════
// 2) num / int / double Extensions
// ═══════════════════════════════════════════════════════════

extension NumX on num {
  /// هل الرقم موجب؟
  bool get isPositive => this > 0;

  /// هل الرقم سالب؟
  bool get isNegative => this < 0;

  /// هل الرقم صفر؟
  bool get isZero => this == 0;

  /// هل بين رقمين (شامل)؟
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// تحديد الرقم بين حدين
  num clampBetween(num min, num max) => clamp(min, max);

  /// تحويل لأرقام عربية (٠١٢٣٤٥٦٧٨٩)
  String get toArabicDigits {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = toString();
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// إضافة فواصل الآلاف (1,234,567)
  String get withCommas {
    final str = toString();
    final parts = str.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }
    return '$buffer$decimalPart';
  }

  /// اختصار الأرقام الكبيرة (1.2K, 3.4M)
  String get compact {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// تحويل لـ Duration (كـ ثواني)
  Duration get seconds => Duration(seconds: toInt());

  /// تحويل لـ Duration (كـ دقائق)
  Duration get minutes => Duration(minutes: toInt());

  /// تحويل لـ Duration (كـ ساعات)
  Duration get hours => Duration(hours: toInt());

  /// تحويل لـ Duration (كـ أيام)
  Duration get days => Duration(days: toInt());
}

// ═══════════════════════════════════════════════════════════
// 3) BuildContext Extensions
// ═══════════════════════════════════════════════════════════

extension BuildContextX on BuildContext {
  // ─── Theme ───
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;

  // ─── MediaQuery ───
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  double get bottomInset => viewInsets.bottom;
  bool get isKeyboardOpen => bottomInset > 0;

  // ─── Navigation ───
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  // ─── SnackBar ───
  void showSnack(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showSuccessSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─── Dialog ───
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: confirmColor != null
                ? FilledButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ─── Direction ───
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  bool get isLtr => Directionality.of(this) == TextDirection.ltr;

  // ─── Safe Area ───
  double get topSafeArea => mediaQuery.padding.top;
  double get bottomSafeArea => mediaQuery.padding.bottom;
}

// ═══════════════════════════════════════════════════════════
// 4) List Extensions
// ═══════════════════════════════════════════════════════════

extension ListX<T> on List<T> {
  /// هل القائمة فاضية؟
  bool get isEmptyOrNull => isEmpty;

  /// هل القائمة مش فاضية؟
  bool get isNotEmptyOrNull => isNotEmpty;

  /// أول عنصر أو null
  T? get firstOrNull => isEmpty ? null : first;

  /// آخر عنصر أو null
  T? get lastOrNull => isEmpty ? null : last;

  /// عنصر بأمان (index)
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// إضافة فواصل بين العناصر
  List<T> separated(T separator) {
    if (isEmpty) return [];
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════
// 5) Map Extensions
// ═══════════════════════════════════════════════════════════

extension MapX<K, V> on Map<K, V> {
  /// هل الماب فاضي؟
  bool get isEmptyOrNull => isEmpty;

  /// هل الماب مش فاضي؟
  bool get isNotEmptyOrNull => isNotEmpty;

  /// إرجاع قيمة بأمان
  V? getOrNull(K key) => this[key];

  /// فلترة الماب
  Map<K, V> where(bool Function(K key, V value) test) {
    final result = <K, V>{};
    forEach((k, v) {
      if (test(k, v)) result[k] = v;
    });
    return result;
  }
}

// ═══════════════════════════════════════════════════════════
// 6) DateTime Extensions (إضافات سريعة)
// ═══════════════════════════════════════════════════════════

extension DateTimeX on DateTime {
  /// هل النهارده؟
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// هل امبارح؟
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// هل بكرة؟
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// هل في المستقبل؟
  bool get isFuture => isAfter(DateTime.now());

  /// هل في الماضي؟
  bool get isPast => isBefore(DateTime.now());

  /// بداية اليوم
  DateTime get startOfDay => DateTime(year, month, day);

  /// نهاية اليوم
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// بداية الشهر
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// نهاية الشهر
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// إضافة أيام
  DateTime operator +(Duration duration) => add(duration);

  /// طرح أيام
  DateTime operator -(Duration duration) => subtract(duration);
}

// ═══════════════════════════════════════════════════════════
// 7) Duration Extensions
// ═══════════════════════════════════════════════════════════

extension DurationX on Duration {
  /// هل مرت المدة؟
  bool get isPast => this < Duration.zero;

  /// هل المدة قادمة؟
  bool get isFuture => this > Duration.zero;

    /// تنسيق المدة كـ "1:23:45"
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final h = hours.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$h:$m:$s';
    }
    return '$m:$s';
  }

      /// تنسيق مختصر "2س 30د"
  String get short {
    if (inDays > 0) return '$inDays' 'ي';
    if (inHours > 0) return '$inHours' 'س';
    if (inMinutes > 0) return '$inMinutes' 'د';
    return '$inSeconds' 'ث';
  }
}

// ═══════════════════════════════════════════════════════════
// 8) Color Extensions
// ═══════════════════════════════════════════════════════════

extension ColorX on Color {
  /// تحويل اللون لـ hex string
    String get toHex {
    final rgb = toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
  /// هل اللون فاتح؟
  bool get isLight {
    return computeLuminance() > 0.5;
  }

  /// هل اللون غامق؟
  bool get isDark => !isLight;

  /// لون النص المناسب (أبيض أو أسود)
  Color get contrastText {
    return isLight ? Colors.black : Colors.white;
  }

  /// نسخة أفتح
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// نسخة أغمق
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

// ═══════════════════════════════════════════════════════════
// 9) Widget Extensions
// ═══════════════════════════════════════════════════════════

extension WidgetX on Widget {
  /// إضافة padding
  Widget padding(EdgeInsets padding) {
    return Padding(padding: padding, child: this);
  }

  /// إضافة padding متساوي
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  /// إضافة margin
  Widget margin(EdgeInsets margin) {
    return Container(margin: margin, child: this);
  }

  /// توسيط
  Widget center() => Center(child: this);

  /// توسيع
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// إخفاء لو شرط
  Widget visible(bool visible) {
    return visible ? this : const SizedBox.shrink();
  }

  /// إضافة onTap
  Widget onTap(VoidCallback? onTap, {BorderRadius? borderRadius}) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: this,
    );
  }
}