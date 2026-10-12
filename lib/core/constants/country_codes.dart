// lib/core/constants/country_codes.dart

/// Model يمثل دولة واحدة مع كود الهاتف الخاص بها
class CountryCode {
  /// الاسم بالعربي
  final String nameAr;

  /// الاسم بالإنجليزي
  final String nameEn;

  /// كود الدولة (ISO 2 letters) - مثال: EG
  final String isoCode;

  /// كود الاتصال الدولي بدون + - مثال: 20
  final String dialCode;

  /// رمز العلم (Emoji)
  final String flag;

  /// طول الرقم المحلي المتوقع (بدون كود الدولة)
  final int phoneLength;

  /// regex للتحقق من الرقم المحلي (بدون كود الدولة وبدون 0 في الأول)
  final RegExp localRegex;

  CountryCode({
    required this.nameAr,
    required this.nameEn,
    required this.isoCode,
    required this.dialCode,
    required this.flag,
    required this.phoneLength,
    required this.localRegex,
  });

  /// الاسم حسب اللغة الحالية
  String name(String langCode) {
    return langCode == 'ar' ? nameAr : nameEn;
  }

  /// الكود بصيغة E.164 - مثال: +20
  String get fullDialCode => '+$dialCode';

  /// تحويل الرقم المحلي لصيغة E.164
  /// مثال: ('01038084846', Egypt) -> '+201038084846'
  String toE164(String localNumber) {
    var digits = localNumber.replaceAll(RegExp(r'[^\d]'), '');
    // شيل الصفر اللي في الأول (زي مصر: 010... -> 10...)
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return '+$dialCode$digits';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode &&
          runtimeType == other.runtimeType &&
          isoCode == other.isoCode;

  @override
  int get hashCode => isoCode.hashCode;
}

// ═══════════════════════════════════════════
// Regex Patterns
// ═══════════════════════════════════════════

/// مصر: أرقام الموبايل تبدأ بـ 1 والطول 9 (بدون صفر)
final RegExp _egRegex = RegExp(r'^1[0125]\d{8}$');

/// السعودية: تبدأ بـ 5 والطول 9
final RegExp _saRegex = RegExp(r'^5\d{8}$');

/// regex عام لأي رقم (يتم التحقق من الطول في الـ validator)
final RegExp _genericRegex = RegExp(r'^\d+$');

// ═══════════════════════════════════════════
// قائمة الدول المدعومة - مصر الأولى (افتراضي)
// ═══════════════════════════════════════════

final List<CountryCode> countryCodes = [
  // 🇪🇬 مصر - الافتراضي
  CountryCode(
    nameAr: 'مصر',
    nameEn: 'Egypt',
    isoCode: 'EG',
    dialCode: '20',
    flag: '🇪🇬',
    phoneLength: 10,
    localRegex: _egRegex,
  ),
  // 🇸🇦 السعودية
  CountryCode(
    nameAr: 'السعودية',
    nameEn: 'Saudi Arabia',
    isoCode: 'SA',
    dialCode: '966',
    flag: '🇸🇦',
    phoneLength: 9,
    localRegex: _saRegex,
  ),
  // 🇦🇪 الإمارات
  CountryCode(
    nameAr: 'الإمارات',
    nameEn: 'UAE',
    isoCode: 'AE',
    dialCode: '971',
    flag: '🇦🇪',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇰🇼 الكويت
  CountryCode(
    nameAr: 'الكويت',
    nameEn: 'Kuwait',
    isoCode: 'KW',
    dialCode: '965',
    flag: '🇰🇼',
    phoneLength: 8,
    localRegex: _genericRegex,
  ),
  // 🇶🇦 قطر
  CountryCode(
    nameAr: 'قطر',
    nameEn: 'Qatar',
    isoCode: 'QA',
    dialCode: '974',
    flag: '🇶🇦',
    phoneLength: 8,
    localRegex: _genericRegex,
  ),
  // 🇧🇭 البحرين
  CountryCode(
    nameAr: 'البحرين',
    nameEn: 'Bahrain',
    isoCode: 'BH',
    dialCode: '973',
    flag: '🇧🇭',
    phoneLength: 8,
    localRegex: _genericRegex,
  ),
  // 🇴🇲 عمان
  CountryCode(
    nameAr: 'عمان',
    nameEn: 'Oman',
    isoCode: 'OM',
    dialCode: '968',
    flag: '🇴🇲',
    phoneLength: 8,
    localRegex: _genericRegex,
  ),
  // 🇯🇴 الأردن
  CountryCode(
    nameAr: 'الأردن',
    nameEn: 'Jordan',
    isoCode: 'JO',
    dialCode: '962',
    flag: '🇯🇴',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇲🇦 المغرب
  CountryCode(
    nameAr: 'المغرب',
    nameEn: 'Morocco',
    isoCode: 'MA',
    dialCode: '212',
    flag: '🇲🇦',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇩🇿 الجزائر
  CountryCode(
    nameAr: 'الجزائر',
    nameEn: 'Algeria',
    isoCode: 'DZ',
    dialCode: '213',
    flag: '🇩🇿',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇹🇳 تونس
  CountryCode(
    nameAr: 'تونس',
    nameEn: 'Tunisia',
    isoCode: 'TN',
    dialCode: '216',
    flag: '🇹🇳',
    phoneLength: 8,
    localRegex: _genericRegex,
  ),
  // 🇱🇾 ليبيا
  CountryCode(
    nameAr: 'ليبيا',
    nameEn: 'Libya',
    isoCode: 'LY',
    dialCode: '218',
    flag: '🇱🇾',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇮🇶 العراق
  CountryCode(
    nameAr: 'العراق',
    nameEn: 'Iraq',
    isoCode: 'IQ',
    dialCode: '964',
    flag: '🇮🇶',
    phoneLength: 10,
    localRegex: _genericRegex,
  ),
  // 🇸🇾 سوريا
  CountryCode(
    nameAr: 'سوريا',
    nameEn: 'Syria',
    isoCode: 'SY',
    dialCode: '963',
    flag: '🇸🇾',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇱🇧 لبنان
  CountryCode(
    nameAr: 'لبنان',
    nameEn: 'Lebanon',
    isoCode: 'LB',
    dialCode: '961',
    flag: '🇱🇧',
    phoneLength: 8,
    localRegex: _genericRegex,
  ),
  // 🇵🇸 فلسطين
  CountryCode(
    nameAr: 'فلسطين',
    nameEn: 'Palestine',
    isoCode: 'PS',
    dialCode: '970',
    flag: '🇵🇸',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇸🇩 السودان
  CountryCode(
    nameAr: 'السودان',
    nameEn: 'Sudan',
    isoCode: 'SD',
    dialCode: '249',
    flag: '🇸🇩',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
  // 🇾🇪 اليمن
  CountryCode(
    nameAr: 'اليمن',
    nameEn: 'Yemen',
    isoCode: 'YE',
    dialCode: '967',
    flag: '🇾🇪',
    phoneLength: 9,
    localRegex: _genericRegex,
  ),
];

/// الدولة الافتراضية - مصر
final CountryCode defaultCountry = countryCodes.first;

// ═══════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════

/// بحث عن دولة بالـ ISO code
CountryCode? countryByIso(String iso) {
  for (final c in countryCodes) {
    if (c.isoCode == iso) return c;
  }
  return null;
}

/// بحث عن دولة بالـ dial code
CountryCode? countryByDialCode(String dial) {
  final clean = dial.replaceAll('+', '').trim();
  for (final c in countryCodes) {
    if (c.dialCode == clean) return c;
  }
  return null;
}
