// lib/features/inventory/data/models/inventory_variants.dart

/// ═══════════════════════════════════════════════════════════
/// InventoryVariant — نوع القطعة (أصلي توكيل / أصلي / تجاري)
/// ═══════════════════════════════════════════════════════════
enum InventoryVariant {
  originalOem, // أصلي توكيل
  original, // أصلي
  aftermarket, // تجاري
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
