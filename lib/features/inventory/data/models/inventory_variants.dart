// lib/features/inventory/data/models/inventory_variants.dart

/// ═══════════════════════════════════════════════════════════
/// InventoryVariant — نوع القطعة (أصلي توكيل / أصلي / تجاري / خلع / مجددة)
/// ═══════════════════════════════════════════════════════════
enum InventoryVariant {
  originalOem, // أصلي توكيل
  original, // أصلي
  aftermarket, // تجاري
  used, // خلع
  refurbished, // مجددة
}

extension InventoryVariantX on InventoryVariant {
  /// الاسم بالعربي
  String get labelAr {
    switch (this) {
      case InventoryVariant.originalOem:
        return 'أصلي توكيل';
      case InventoryVariant.original:
        return 'أصلي';
      case InventoryVariant.aftermarket:
        return 'تجاري';
      case InventoryVariant.used:
        return 'خلع';
      case InventoryVariant.refurbished:
        return 'مجددة';
    }
  }

  /// الاسم بالإنجليزي
  String get labelEn {
    switch (this) {
      case InventoryVariant.originalOem:
        return 'Original OEM';
      case InventoryVariant.original:
        return 'Original';
      case InventoryVariant.aftermarket:
        return 'Aftermarket';
      case InventoryVariant.used:
        return 'Used / Pulled';
      case InventoryVariant.refurbished:
        return 'Refurbished';
    }
  }

  /// الوصف
  String get description {
    switch (this) {
      case InventoryVariant.originalOem:
        return 'قطعة أصلية من التوكيل مباشرة';
      case InventoryVariant.original:
        return 'قطعة أصلية من السوق';
      case InventoryVariant.aftermarket:
        return 'قطعة تجارية / تقليد';
      case InventoryVariant.used:
        return 'قطعة خلع من جهاز آخر';
      case InventoryVariant.refurbished:
        return 'قطعة مجددة / مُعاد تصنيعها';
    }
  }

  /// لون مميّز
  int get colorValue {
    switch (this) {
      case InventoryVariant.originalOem:
        return 0xFF10B981; // أخضر
      case InventoryVariant.original:
        return 0xFF3B82F6; // أزرق
      case InventoryVariant.aftermarket:
        return 0xFFF59E0B; // برتقالي
      case InventoryVariant.used:
        return 0xFF8B5CF6; // بنفسجي
      case InventoryVariant.refurbished:
        return 0xFF06B6D4; // سماوي
    }
  }

  /// أيقونة
  int get iconCode {
    switch (this) {
      case InventoryVariant.originalOem:
        return 0xe5ca; // Icons.verified
      case InventoryVariant.original:
        return 0xe86c; // Icons.verified_outlined
      case InventoryVariant.aftermarket:
        return 0xe5c9; // Icons.star_outline
      case InventoryVariant.used:
        return 0xe5c5; // Icons.recycling
      case InventoryVariant.refurbished:
        return 0xe8b0; // Icons.build_circle
    }
  }

  /// من string
  static InventoryVariant fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'originaloem':
      case 'original_oem':
      case 'oem':
        return InventoryVariant.originalOem;
      case 'original':
        return InventoryVariant.original;
      case 'aftermarket':
      case 'commercial':
        return InventoryVariant.aftermarket;
      case 'used':
      case 'pulled':
      case 'khala':
        return InventoryVariant.used;
      case 'refurbished':
      case 'refurb':
        return InventoryVariant.refurbished;
      default:
        return InventoryVariant.aftermarket;
    }
  }
}

/// ═══════════════════════════════════════════════════════════
/// Helper functions
/// ═══════════════════════════════════════════════════════════

/// كل الـ variants
List<InventoryVariant> get allVariants => InventoryVariant.values;

/// أسماء الـ variants بالعربي
List<String> get variantLabelsAr =>
    InventoryVariant.values.map((v) => v.labelAr).toList();

/// بحث بالاسم
InventoryVariant? variantByLabel(String label) {
  for (final v in InventoryVariant.values) {
    if (v.labelAr == label || v.labelEn == label) return v;
  }
  return null;
}