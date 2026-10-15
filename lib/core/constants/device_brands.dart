// lib/core/constants/device_brands.dart

/// ═══════════════════════════════════════════════════════════
/// DeviceBrand — شركة/ماركة جهاز
/// ═══════════════════════════════════════════════════════════
class DeviceBrand {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<DeviceCategory> categories;

  const DeviceBrand({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.categories = const [DeviceCategory.phone],
  });

  /// الاسم حسب اللغة
  String name(String langCode) => langCode == 'ar' ? nameAr : nameEn;

  /// هل الشركة دي بتعمل النوع ده؟
  bool supports(DeviceCategory category) => categories.contains(category);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceBrand &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// ═══════════════════════════════════════════════════════════
/// DeviceCategory — نوع الجهاز (للفلترة)
/// ═══════════════════════════════════════════════════════════
enum DeviceCategory { phone, tablet, laptop, smartwatch, other }

extension DeviceCategoryX on DeviceCategory {
  String get labelAr {
    switch (this) {
      case DeviceCategory.phone:
        return 'موبايل';
      case DeviceCategory.tablet:
        return 'تابلت';
      case DeviceCategory.laptop:
        return 'لابتوب';
      case DeviceCategory.smartwatch:
        return 'ساعة';
      case DeviceCategory.other:
        return 'أخرى';
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// قائمة الشركات
/// ═══════════════════════════════════════════════════════════
const List<DeviceBrand> deviceBrands = [
  // ═══ Apple ═══
  DeviceBrand(
    id: 'apple',
    nameEn: 'Apple',
    nameAr: 'أبل',
    categories: [
      DeviceCategory.phone,
      DeviceCategory.tablet,
      DeviceCategory.laptop,
      DeviceCategory.smartwatch,
    ],
  ),

  // ═══ Samsung ═══
  DeviceBrand(
    id: 'samsung',
    nameEn: 'Samsung',
    nameAr: 'سامسونج',
    categories: [
      DeviceCategory.phone,
      DeviceCategory.tablet,
      DeviceCategory.smartwatch,
    ],
  ),

  // ═══ Xiaomi ═══
  DeviceBrand(
    id: 'xiaomi',
    nameEn: 'Xiaomi',
    nameAr: 'شاومي',
    categories: [
      DeviceCategory.phone,
      DeviceCategory.tablet,
    ],
  ),

  // ═══ Redmi ═══
  DeviceBrand(
    id: 'redmi',
    nameEn: 'Redmi',
    nameAr: 'ريدمي',
    categories: [
      DeviceCategory.phone,
      DeviceCategory.tablet,
    ],
  ),

  // ═══ Poco ═══
  DeviceBrand(
    id: 'poco',
    nameEn: 'Poco',
    nameAr: 'بوكو',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Oppo ═══
  DeviceBrand(
    id: 'oppo',
    nameEn: 'Oppo',
    nameAr: 'أوبو',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Honor ═══
  DeviceBrand(
    id: 'honor',
    nameEn: 'Honor',
    nameAr: 'هونر',
    categories: [
      DeviceCategory.phone,
      DeviceCategory.tablet,
    ],
  ),

  // ═══ Realme ═══
  DeviceBrand(
    id: 'realme',
    nameEn: 'Realme',
    nameAr: 'ريلمي',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Vivo ═══
  DeviceBrand(
    id: 'vivo',
    nameEn: 'Vivo',
    nameAr: 'فيفو',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Infinix ═══
  DeviceBrand(
    id: 'infinix',
    nameEn: 'Infinix',
    nameAr: 'إنفينيكس',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Tecno ═══
  DeviceBrand(
    id: 'tecno',
    nameEn: 'Tecno',
    nameAr: 'تكنو',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Itel ═══
  DeviceBrand(
    id: 'itel',
    nameEn: 'Itel',
    nameAr: 'آيتل',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Nokia ═══
  DeviceBrand(
    id: 'nokia',
    nameEn: 'Nokia',
    nameAr: 'نوكيا',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Huawei ═══
  DeviceBrand(
    id: 'huawei',
    nameEn: 'Huawei',
    nameAr: 'هواوي',
    categories: [
      DeviceCategory.phone,
      DeviceCategory.tablet,
      DeviceCategory.smartwatch,
    ],
  ),

  // ═══ OnePlus ═══
  DeviceBrand(
    id: 'oneplus',
    nameEn: 'OnePlus',
    nameAr: 'ون بلس',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Motorola ═══
  DeviceBrand(
    id: 'motorola',
    nameEn: 'Motorola',
    nameAr: 'موتورولا',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Google ═══
  DeviceBrand(
    id: 'google',
    nameEn: 'Google',
    nameAr: 'جوجل',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Nothing ═══
  DeviceBrand(
    id: 'nothing',
    nameEn: 'Nothing',
    nameAr: 'ناثينج',
    categories: [DeviceCategory.phone],
  ),

  // ═══ Lenovo (Tablets + Laptops) ═══
  DeviceBrand(
    id: 'lenovo',
    nameEn: 'Lenovo',
    nameAr: 'لينوفو',
    categories: [
      DeviceCategory.tablet,
      DeviceCategory.laptop,
    ],
  ),

  // ═══ HP ═══
  DeviceBrand(
    id: 'hp',
    nameEn: 'HP',
    nameAr: 'إتش بي',
    categories: [DeviceCategory.laptop],
  ),

  // ═══ Dell ═══
  DeviceBrand(
    id: 'dell',
    nameEn: 'Dell',
    nameAr: 'ديل',
    categories: [DeviceCategory.laptop],
  ),

  // ═══ Asus ═══
  DeviceBrand(
    id: 'asus',
    nameEn: 'Asus',
    nameAr: 'أسوس',
    categories: [DeviceCategory.laptop],
  ),

  // ═══ Acer ═══
  DeviceBrand(
    id: 'acer',
    nameEn: 'Acer',
    nameAr: 'أيسر',
    categories: [DeviceCategory.laptop],
  ),

  // ═══ MSI ═══
  DeviceBrand(
    id: 'msi',
    nameEn: 'MSI',
    nameAr: 'إم إس آي',
    categories: [DeviceCategory.laptop],
  ),

  // ═══ Toshiba ═══
  DeviceBrand(
    id: 'toshiba',
    nameEn: 'Toshiba',
    nameAr: 'توشيبا',
    categories: [DeviceCategory.laptop],
  ),

  // ═══ Microsoft (Surface) ═══
  DeviceBrand(
    id: 'microsoft',
    nameEn: 'Microsoft',
    nameAr: 'مايكروسوفت',
    categories: [
      DeviceCategory.tablet,
      DeviceCategory.laptop,
    ],
  ),
];

// ═══════════════════════════════════════════════════════════
//  Helpers
// ═══════════════════════════════════════════════════════════

/// بحث عن شركة بالـ id
DeviceBrand? brandById(String id) {
  for (final b in deviceBrands) {
    if (b.id == id) return b;
  }
  return null;
}

/// بحث عن شركة بالاسم (EN أو AR)
DeviceBrand? brandByName(String name) {
  final lower = name.toLowerCase().trim();
  for (final b in deviceBrands) {
    if (b.nameEn.toLowerCase() == lower || b.nameAr == name.trim()) {
      return b;
    }
  }
  return null;
}

/// فلترة الشركات حسب نوع الجهاز
List<DeviceBrand> brandsByCategory(DeviceCategory category) {
  return deviceBrands.where((b) => b.supports(category)).toList();
}

/// قائمة الأسماء فقط (للاستخدام في Dropdown)
List<String> brandNames({String langCode = 'ar'}) {
  return deviceBrands.map((b) => b.name(langCode)).toList()..sort();
}

/// بحث بالاسم (Autocomplete) — يرجّع قائمة أسماء
List<String> searchBrands(
  String query, {
  String langCode = 'ar',
  DeviceCategory? category,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return category != null
        ? brandsByCategory(category).map((b) => b.name(langCode)).toList()
        : brandNames(langCode: langCode);
  }

  final list = category != null ? brandsByCategory(category) : deviceBrands;

  return list
      .where((b) => b.nameEn.toLowerCase().contains(q) || b.nameAr.contains(q))
      .map((b) => b.name(langCode))
      .toList();
}
