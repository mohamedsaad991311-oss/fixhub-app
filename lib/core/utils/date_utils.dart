// lib/core/utils/date_utils.dart

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:intl/intl.dart';
/// ═══════════════════════════════════════════════════════════
/// AppDateUtils — أدوات التواريخ
/// ═══════════════════════════════════════════════════════════
///
/// ⚠️ ملاحظة: في `flutter/material.dart` فيه `DateUtils`.
/// عشان كده سمّينا الكلاس ده `AppDateUtils` لتجنب التعارض.
///
class AppDateUtils {
  AppDateUtils._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) FORMATTERS — صيغ جاهزة
  // ═══════════════════════════════════════════════════════════

  /// 2026-10-09
  static final DateFormat isoDate = DateFormat('yyyy-MM-dd');

  /// 2026-10-09 14:30
  static final DateFormat isoDateTime = DateFormat('yyyy-MM-dd HH:mm');

  /// 09/10/2026
  static final DateFormat shortDate = DateFormat('dd/MM/yyyy');

  /// 09/10/2026 02:30 م
  static final DateFormat shortDateTime = DateFormat('dd/MM/yyyy hh:mm a');

  /// 9 أكتوبر 2026
  static final DateFormat longDate = DateFormat('d MMMM yyyy', 'ar');

  /// 9 أكتوبر 2026، 2:30 م
  static final DateFormat longDateTime =
      DateFormat('d MMMM yyyy، h:mm a', 'ar');

  /// 02:30 م
  static final DateFormat timeOnly = DateFormat('h:mm a', 'ar');

  /// 14:30
  static final DateFormat timeOnly24 = DateFormat('HH:mm');

  /// أكتوبر 2026
  static final DateFormat monthYear = DateFormat('MMMM yyyy', 'ar');

  /// أكتوبر
  static final DateFormat monthOnly = DateFormat('MMMM', 'ar');

  /// الجمعة
  static final DateFormat weekdayOnly = DateFormat('EEEE', 'ar');

  // ═══════════════════════════════════════════════════════════
  // 2) FORMAT — تنسيق التواريخ
  // ═══════════════════════════════════════════════════════════

  /// تنسيق التاريخ بصيغة ISO
  static String toIso(DateTime? date) {
    if (date == null) return '';
    return isoDate.format(date);
  }

  /// تنسيق التاريخ والوقت بصيغة ISO
  static String toIsoDateTime(DateTime? date) {
    if (date == null) return '';
    return isoDateTime.format(date);
  }

  /// تنسيق تاريخ قصير
  static String toShortDate(DateTime? date) {
    if (date == null) return '';
    return shortDate.format(date);
  }

  /// تنسيق تاريخ ووقت قصير
  static String toShortDateTime(DateTime? date) {
    if (date == null) return '';
    return shortDateTime.format(date);
  }

  /// تنسيق تاريخ طويل (بالعربي)
  static String toLongDate(DateTime? date) {
    if (date == null) return '';
    return longDate.format(date);
  }

  /// تنسيق تاريخ ووقت طويل (بالعربي)
  static String toLongDateTime(DateTime? date) {
    if (date == null) return '';
    return longDateTime.format(date);
  }

  /// تنسيق الوقت فقط
  static String toTime(DateTime? date, {bool use24Hour = false}) {
    if (date == null) return '';
    return use24Hour ? timeOnly24.format(date) : timeOnly.format(date);
  }

  /// تنسيق الشهر والسنة
  static String toMonthYear(DateTime? date) {
    if (date == null) return '';
    return monthYear.format(date);
  }

  // ═══════════════════════════════════════════════════════════
  // 3) RELATIVE — الوقت النسبي ("منذ 3 ساعات")
  // ═══════════════════════════════════════════════════════════

  /// إرجاع الوقت النسبي بالعربي
  static String toRelative(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return mins == 1 ? 'منذ دقيقة' : 'منذ $mins دقيقة';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return hours == 1 ? 'منذ ساعة' : 'منذ $hours ساعة';
    } else if (diff.inDays < 7) {
      final days = diff.inDays;
      return days == 1 ? 'أمس' : 'منذ $days أيام';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return weeks == 1 ? 'منذ أسبوع' : 'منذ $weeks أسابيع';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return months == 1 ? 'منذ شهر' : 'منذ $months أشهر';
    } else {
      final years = (diff.inDays / 365).floor();
      return years == 1 ? 'منذ سنة' : 'منذ $years سنوات';
    }
  }

  /// إرجاع الوقت النسبي المختصر
  static String toRelativeShort(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return '${diff.inMinutes}د';
    if (diff.inHours < 24) return '${diff.inHours}س';
    if (diff.inDays < 30) return '${diff.inDays}ي';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}ش';
    return '${(diff.inDays / 365).floor()}ع';
  }

  // ═══════════════════════════════════════════════════════════
  // 4) RANGE — نطاقات التواريخ
  // ═══════════════════════════════════════════════════════════

  /// بداية اليوم (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// نهاية اليوم (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// بداية الشهر
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// نهاية الشهر
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// بداية السنة
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// نهاية السنة
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// بداية الأسبوع (السبت في مصر)
  static DateTime startOfWeek(DateTime date, {int startDay = DateTime.saturday}) {
    final diff = (date.weekday - startDay + 7) % 7;
    return startOfDay(date.subtract(Duration(days: diff)));
  }

  /// نهاية الأسبوع
  static DateTime endOfWeek(DateTime date, {int startDay = DateTime.saturday}) {
    return endOfDay(startOfWeek(date, startDay: startDay).add(const Duration(days: 6)));
  }

  // ═══════════════════════════════════════════════════════════
  // 5) DIFFERENCE — الفروق
  // ═══════════════════════════════════════════════════════════

  /// الفرق بالأيام (بدون وقت)
  static int daysBetween(DateTime from, DateTime to) {
    final a = startOfDay(from);
    final b = startOfDay(to);
    return b.difference(a).inDays.abs();
  }

  /// الفرق بالساعات
  static int hoursBetween(DateTime from, DateTime to) {
    return to.difference(from).inHours.abs();
  }

  /// الفرق بالدقائق
  static int minutesBetween(DateTime from, DateTime to) {
    return to.difference(from).inMinutes.abs();
  }

  /// هل التاريخين في نفس اليوم؟
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// هل التاريخين في نفس الشهر؟
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// هل التاريخين في نفس السنة؟
  static bool isSameYear(DateTime a, DateTime b) {
    return a.year == b.year;
  }

  // ═══════════════════════════════════════════════════════════
  // 6) CHECKS — فحوصات
  // ═══════════════════════════════════════════════════════════

  /// هل التاريخ النهارده؟
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// هل التاريخ امبارح؟
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// هل التاريخ بكرة؟
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// هل التاريخ في المستقبل؟
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// هل التاريخ في الماضي؟
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// هل التاريخ في عطلة الأسبوع؟ (الجمعة/السبت)
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
  }

  // ═══════════════════════════════════════════════════════════
  // 7) GREETING — تحيات حسب الوقت
  // ═══════════════════════════════════════════════════════════

  /// تحية حسب وقت اليوم
  static String greeting([DateTime? date]) {
    final hour = (date ?? DateTime.now()).hour;

    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }

  /// اسم اليوم
  static String weekdayName(DateTime date) {
    return weekdayOnly.format(date);
  }

  // ═══════════════════════════════════════════════════════════
  // 8) HELPERS — دوال مساعدة
  // ═══════════════════════════════════════════════════════════

  /// تحويل String إلى DateTime (بأمان)
  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// إضافة أيام مع تجاهل الوقت
  static DateTime addDays(DateTime date, int days) {
    return startOfDay(date).add(Duration(days: days));
  }

  /// إضافة أشهر
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }

  /// بداية الشهر السابق
  static DateTime previousMonthStart(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  /// بداية الشهر القادم
  static DateTime nextMonthStart(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  /// نطاق اليوم الحالي
  static DateTimeRange todayRange() {
    final now = DateTime.now();
    return DateTimeRange(start: startOfDay(now), end: endOfDay(now));
  }

  /// نطاق الأسبوع الحالي
  static DateTimeRange thisWeekRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: startOfWeek(now),
      end: endOfWeek(now),
    );
  }

  /// نطاق الشهر الحالي
  static DateTimeRange thisMonthRange() {
    final now = DateTime.now();
    return DateTimeRange(start: startOfMonth(now), end: endOfMonth(now));
  }

  /// نطاق السنة الحالية
  static DateTimeRange thisYearRange() {
    final now = DateTime.now();
    return DateTimeRange(start: startOfYear(now), end: endOfYear(now));
  }

  /// نطاق آخر 7 أيام
  static DateTimeRange last7DaysRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: startOfDay(now.subtract(const Duration(days: 6))),
      end: endOfDay(now),
    );
  }

  /// نطاق آخر 30 يوم
  static DateTimeRange last30DaysRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: startOfDay(now.subtract(const Duration(days: 29))),
      end: endOfDay(now),
    );
  }

  /// نطاق آخر 3 أشهر
  static DateTimeRange last90DaysRange() {
    final now = DateTime.now();
    return DateTimeRange(
      start: startOfDay(now.subtract(const Duration(days: 89))),
      end: endOfDay(now),
    );
  }
}