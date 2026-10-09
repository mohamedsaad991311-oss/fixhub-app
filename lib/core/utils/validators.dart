// lib/core/utils/validators.dart

import '../constants/app_constants.dart';

/// ═══════════════════════════════════════════════════════════
/// Validators — مدققات الحقول (للـ Forms)
/// ═══════════════════════════════════════════════════════════
///
/// كل دالة بترجع:
/// - `null` لو القيمة صحيحة
/// - `String` (رسالة الخطأ) لو القيمة غلط
///
/// الاستخدام مع TextFormField:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
/// )
/// ```
///
class Validators {
  Validators._(); // منع الإنشاء

  // ═══════════════════════════════════════════════════════════
  // 1) REQUIRED — الحقول المطلوبة
  // ═══════════════════════════════════════════════════════════

  /// التحقق من إن الحقل مش فاضي
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'حقل $fieldName مطلوب'
          : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// التحقق من إن الحقل مش فاضي (باسم مخصص)
  static String? Function(String?) requiredWithName(String fieldName) {
    return (value) => required(value, fieldName: fieldName);
  }

  // ═══════════════════════════════════════════════════════════
  // 2) EMAIL — البريد الإلكتروني
  // ═══════════════════════════════════════════════════════════

  /// التحقق من البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final regex = RegExp(AppConstants.emailPattern);
    if (!regex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 3) PHONE — رقم الموبايل
  // ═══════════════════════════════════════════════════════════

  /// التحقق من رقم موبايل مصري
  static String? egyptPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الموبايل مطلوب';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(AppConstants.egyptPhonePattern);
    if (!regex.hasMatch(cleaned)) {
      return 'رقم الموبايل غير صحيح (مثال: 01012345678)';
    }
    return null;
  }

  /// التحقق من رقم موبايل دولي
  static String? intlPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الموبايل مطلوب';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    final regex = RegExp(AppConstants.intlPhonePattern);
    if (!regex.hasMatch(cleaned)) {
      return 'رقم الموبايل الدولي غير صحيح';
    }
    return null;
  }

  /// التحقق من رقم موبايل (مصري أو دولي)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الموبايل مطلوب';
    }
    return egyptPhone(value) ?? intlPhone(value);
  }

  // ═══════════════════════════════════════════════════════════
  // 4) PASSWORD — كلمة المرور
  // ═══════════════════════════════════════════════════════════

  /// التحقق من كلمة المرور
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'كلمة المرور طويلة جداً (الحد الأقصى ${AppConstants.maxPasswordLength})';
    }
    return null;
  }

  /// التحقق من كلمة مرور قوية
  static String? strongPassword(String? value) {
    final basicError = password(value);
    if (basicError != null) return basicError;

    final hasUppercase = value!.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecial) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير وحرف صغير ورقم ورمز';
    }
    return null;
  }

  /// التحقق من تأكيد كلمة المرور
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != original) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 5) PIN — رمز PIN
  // ═══════════════════════════════════════════════════════════

  /// التحقق من PIN
  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرمز السري مطلوب';
    }
    final regex = RegExp(AppConstants.pinPattern);
    if (!regex.hasMatch(value)) {
      return 'الرمز يجب أن يكون ${AppConstants.pinLength} أرقام';
    }
    return null;
  }

  /// التحقق من تأكيد PIN
  static String? confirmPin(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'تأكيد الرمز مطلوب';
    }
    if (value != original) {
      return 'الرمزان غير متطابقين';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 6) NUMBERS — الأرقام
  // ═══════════════════════════════════════════════════════════

  /// التحقق من رقم صحيح
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'حقل $fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    final regex = RegExp(AppConstants.digitsOnlyPattern);
    if (!regex.hasMatch(value.trim())) {
      return 'يجب إدخال رقم صحيح';
    }
    return null;
  }

  /// التحقق من رقم عشري
  static String? decimal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final regex = RegExp(AppConstants.decimalPattern);
    if (!regex.hasMatch(value.trim())) {
      return 'يجب إدخال رقم صحيح';
    }
    return null;
  }

  /// التحقق من رقم موجب (أكبر من صفر)
  static String? positiveNumber(String? value, {String? fieldName}) {
    final basicError = decimal(value);
    if (basicError != null) {
      return fieldName != null ? 'حقل $fieldName مطلوب' : basicError;
    }
    final num = double.tryParse(value!.trim());
    if (num == null || num <= 0) {
      return 'يجب أن يكون الرقم أكبر من صفر';
    }
    return null;
  }

  /// التحقق من رقم في نطاق معين
  static String? numberInRange(
    String? value, {
    required double min,
    required double max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'يجب إدخال رقم صحيح';
    }
    if (num < min || num > max) {
      return 'يجب أن يكون الرقم بين $min و $max';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 7) LENGTH — الأطوال
  // ═══════════════════════════════════════════════════════════

  /// الحد الأدنى للطول
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? 'حقل $fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    if (value.length < min) {
      return 'يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  /// الحد الأقصى للطول
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? 'حقل $fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    if (value.length > max) {
      return 'يجب ألا يتجاوز $max حرف';
    }
    return null;
  }

  /// طول محدد بالضبط
  static String? exactLength(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (value.length != length) {
      return 'يجب أن يكون $length أحرف بالضبط';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 8) SPECIAL — حالات خاصة
  // ═══════════════════════════════════════════════════════════

  /// التحقق من IMEI (15 رقم)
  static String? imei(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IMEI مطلوب';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length != 15 || !RegExp(r'^\d{15}$').hasMatch(cleaned)) {
      return 'IMEI يجب أن يكون 15 رقم';
    }
    return null;
  }

  /// التحقق من الرقم التسلسلي (Serial Number)
  static String? serialNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرقم التسلسلي مطلوب';
    }
    if (value.trim().length < 5) {
      return 'الرقم التسلسلي قصير جداً';
    }
    return null;
  }

  /// التحقق من اسم (2 → 50 حرف)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 2) {
      return 'الاسم قصير جداً';
    }
    if (value.trim().length > 50) {
      return 'الاسم طويل جداً';
    }
    return null;
  }

  /// التحقق من عنوان (5 → 200 حرف)
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }
    if (value.trim().length < 5) {
      return 'العنوان قصير جداً';
    }
    if (value.trim().length > 200) {
      return 'العنوان طويل جداً';
    }
    return null;
  }

  /// التحقق من ملاحظة (0 → 500 حرف) — اختياري
  static String? note(String? value) {
    if (value != null && value.length > 500) {
      return 'الملاحظة طويلة جداً (الحد الأقصى 500 حرف)';
    }
    return null;
  }

  /// التحقق من تاريخ (مش في المستقبل)
  static String? notFutureDate(DateTime? date) {
    if (date == null) {
      return 'التاريخ مطلوب';
    }
    if (date.isAfter(DateTime.now())) {
      return 'التاريخ لا يمكن أن يكون في المستقبل';
    }
    return null;
  }

  /// التحقق من تاريخ (في الماضي)
  static String? pastDate(DateTime? date) {
    if (date == null) {
      return 'التاريخ مطلوب';
    }
    if (date.isAfter(DateTime.now())) {
      return 'التاريخ يجب أن يكون في الماضي';
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // 9) COMPOSITE — مدققات مركّبة
  // ═══════════════════════════════════════════════════════════

  /// دمج عدة مدققات مع بعض
  ///
  /// مثال:
  /// ```dart
  /// validator: Validators.compose([
  ///   Validators.required,
  ///   Validators.email,
  /// ]),
  /// ```
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}