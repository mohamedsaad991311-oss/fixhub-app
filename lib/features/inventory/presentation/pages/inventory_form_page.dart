// lib/features/inventory/presentation/pages/inventory_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/device_brands.dart';
import '../../../../core/constants/device_models.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/searchable_dropdown.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/inventory_variants.dart';
import '../providers/inventory_form_provider.dart';
import '../providers/inventory_list_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// InventoryFormPage — إضافة/تعديل صنف
/// ═══════════════════════════════════════════════════════════
class InventoryFormPage extends ConsumerStatefulWidget {
  const InventoryFormPage({super.key, this.editingItem});

  final InventoryItem? editingItem;

  @override
  ConsumerState<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends ConsumerState<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minQtyController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _locationController = TextEditingController();

  DeviceBrand? _selectedBrand;
  String? _selectedModel;
  InventoryVariant _selectedVariant = InventoryVariant.aftermarket;
  InventoryCategory _selectedCategory = InventoryCategory.other;

  bool get _isEditing => widget.editingItem != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        ref
            .read(inventoryFormProvider.notifier)
            .loadForEdit(widget.editingItem!.id);
      } else {
        ref.read(inventoryFormProvider.notifier).reset();
      }
      _hydrateFromProvider();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _minQtyController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _hydrateFromProvider() {
    final s = ref.read(inventoryFormProvider);
    _nameController.text = s.name;
    _nameArController.text = s.nameAr ?? '';
    _skuController.text = s.sku ?? '';
    _barcodeController.text = s.barcode ?? '';
    _descriptionController.text = s.description ?? '';
    _quantityController.text = s.quantity > 0 ? s.quantity.toString() : '';
    _minQtyController.text = s.minQuantity > 0 ? s.minQuantity.toString() : '';
    _costPriceController.text = s.costPrice > 0 ? s.costPrice.toString() : '';
    _sellingPriceController.text =
        s.sellingPrice > 0 ? s.sellingPrice.toString() : '';
    _locationController.text = s.location ?? '';

    setState(() {
      _selectedCategory = s.category;
      _selectedVariant = s.variant;
      final brand = brandByName(s.name);
      if (brand != null) {
        _selectedBrand = brand;
        _selectedModel = s.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formState = ref.watch(inventoryFormProvider);
    final isSaving = formState.isSaving;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          _isEditing ? 'تعديل الصنف' : 'صنف جديد',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionTitle(title: 'المعلومات الأساسية', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              SearchableDropdown<DeviceBrand>(
                items: deviceBrands,
                value: _selectedBrand,
                label: 'الماركة',
                hint: 'اختر أو اكتب الماركة',
                prefixIcon: Icons.business_outlined,
                displayString: (b) => b.nameAr,
                searchString: (b) => '${b.nameEn} ${b.nameAr}',
                subtitleString: (b) => b.nameEn,
                onChanged: (brand) {
                  setState(() {
                    _selectedBrand = brand;
                    _selectedModel = null;
                  });
                  _nameController.clear();
                },
                onManualInput: (value) {
                  ref.read(inventoryFormProvider.notifier).setName(value);
                  _nameController.text = value;
                },
              ),
              const SizedBox(height: AppSizes.spaceSm),
              SearchableDropdown<String>(
                items: _selectedBrand != null
                    ? modelNamesByBrand(_selectedBrand!.id)
                    : deviceModels.map((m) => m.name).toList(),
                value: _selectedModel,
                label: 'الموديل / اسم القطعة',
                hint: _selectedBrand != null
                    ? 'اختر موديل ${_selectedBrand!.nameAr}'
                    : 'اختر الماركة الأول',
                prefixIcon: Icons.phone_iphone,
                isRequired: true,
                displayString: (s) => s,
                onChanged: (model) {
                  setState(() => _selectedModel = model);
                  if (model != null) {
                    _nameController.text = model;
                    ref.read(inventoryFormProvider.notifier).setName(model);
                  }
                },
                onManualInput: (value) {
                  setState(() => _selectedModel = value);
                  _nameController.text = value;
                  ref.read(inventoryFormProvider.notifier).setName(value);
                },
                validator: (v) {
                  if (v == null || v.isEmpty) return 'الاسم مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceSm),
              _text(
                controller: _nameArController,
                label: 'الاسم بالعربي (اختياري)',
                hint: 'مثال: شاشة آيفون 13',
                onChanged: (v) => ref
                    .read(inventoryFormProvider.notifier)
                    .setNameAr(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceSm),
              _CategoryPicker(
                selected: _selectedCategory,
                onChanged: (c) {
                  setState(() => _selectedCategory = c);
                  ref.read(inventoryFormProvider.notifier).setCategory(c);
                },
                scheme: scheme,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              _VariantPicker(
                selected: _selectedVariant,
                onChanged: (v) {
                  setState(() => _selectedVariant = v);
                },
                scheme: scheme,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: _text(
                      controller: _skuController,
                      label: 'SKU (اختياري)',
                      hint: 'SKU-001',
                      ltr: true,
                      onChanged: (v) => ref
                          .read(inventoryFormProvider.notifier)
                          .setSku(v.isEmpty ? null : v),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: _text(
                      controller: _barcodeController,
                      label: 'الباركود (اختياري)',
                      hint: '1234567890',
                      ltr: true,
                      keyboard: TextInputType.number,
                      onChanged: (v) => ref
                          .read(inventoryFormProvider.notifier)
                          .setBarcode(v.isEmpty ? null : v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceSm),
              _text(
                controller: _descriptionController,
                label: 'الوصف (اختياري)',
                maxLines: 2,
                onChanged: (v) => ref
                    .read(inventoryFormProvider.notifier)
                    .setDescription(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              _SectionTitle(title: 'المخزون', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: _number(
                      controller: _quantityController,
                      label: 'الكمية *',
                      hint: 'أدخل الكمية',
                      onChanged: (v) => ref
                          .read(inventoryFormProvider.notifier)
                          .setQuantity(int.tryParse(v) ?? 0),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'الكمية مطلوبة';
                        }
                        final n = int.tryParse(v);
                        if (n == null || n < 0) return 'رقم غير صحيح';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: _number(
                      controller: _minQtyController,
                      label: 'الحد الأدنى',
                      hint: 'مثال: 5',
                      onChanged: (v) => ref
                          .read(inventoryFormProvider.notifier)
                          .setMinQuantity(int.tryParse(v) ?? 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceSm),
              _text(
                controller: _locationController,
                label: 'الموقع (اختياري)',
                hint: 'مثال: رف A3',
                onChanged: (v) => ref
                    .read(inventoryFormProvider.notifier)
                    .setLocation(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceLg),
              _SectionTitle(title: 'التسعير', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: _number(
                      controller: _costPriceController,
                      label: 'سعر التكلفة *',
                      hint: '0',
                      decimal: true,
                      onChanged: (v) => ref
                          .read(inventoryFormProvider.notifier)
                          .setCostPrice(double.tryParse(v) ?? 0),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'مطلوب';
                        }
                        final n = double.tryParse(v);
                        if (n == null || n < 0) return 'رقم غير صحيح';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  Expanded(
                    child: _number(
                      controller: _sellingPriceController,
                      label: 'سعر البيع *',
                      hint: '0',
                      decimal: true,
                      onChanged: (v) => ref
                          .read(inventoryFormProvider.notifier)
                          .setSellingPrice(double.tryParse(v) ?? 0),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'مطلوب';
                        }
                        final n = double.tryParse(v);
                        if (n == null || n < 0) return 'رقم غير صحيح';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMd),
              _ProfitPreview(
                costPrice: formState.costPrice,
                sellingPrice: formState.sellingPrice,
                scheme: scheme,
              ),
              const SizedBox(height: AppSizes.spaceLg),
              FilledButton.icon(
                onPressed: isSaving ? null : _handleSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  isSaving
                      ? 'جاري الحفظ...'
                      : (_isEditing ? 'حفظ التعديلات' : 'إضافة الصنف'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(inventoryFormProvider.notifier);
    final result = await notifier.saveWithVariant(_selectedVariant);

    if (!mounted) return;

    if (result != null) {
      ref.read(inventoryListProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تعديل الصنف' : 'تم إضافة الصنف'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(inventoryFormProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل الحفظ'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _text({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool ltr = false,
    TextInputType? keyboard,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      textDirection: ltr ? TextDirection.ltr : null,
      onChanged: onChanged,
      validator: validator,
      decoration: _deco(scheme, label: label, hint: hint),
    );
  }

  Widget _number({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool decimal = false,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: onChanged,
      validator: validator,
      decoration: _deco(scheme, label: label, hint: hint),
    );
  }

  InputDecoration _deco(
    ColorScheme scheme, {
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(
          color: scheme.primary,
          width: AppSizes.borderMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide(
          color: scheme.error,
          width: AppSizes.borderMedium,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SECTION TITLE
// ═══════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.scheme});
  final String title;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSizes.spaceSm),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CATEGORY PICKER
// ═══════════════════════════════════════════════════════════

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.onChanged,
    required this.scheme,
  });
  final InventoryCategory selected;
  final ValueChanged<InventoryCategory> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
          child: Text(
            'الفئة *',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: InventoryCategory.values.map((c) {
            final isSelected = c == selected;
            return InkWell(
              onTap: () => onChanged(c),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.15)
                      : scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  border: Border.all(
                    color: isSelected
                        ? scheme.primary
                        : scheme.outlineVariant.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      c.icon,
                      size: 14,
                      color:
                          isSelected ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      c.labelAr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  VARIANT PICKER
// ═══════════════════════════════════════════════════════════

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({
    required this.selected,
    required this.onChanged,
    required this.scheme,
  });
  final InventoryVariant selected;
  final ValueChanged<InventoryVariant> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
          child: Text(
            'النوع *',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
        Row(
          children: InventoryVariant.values.map((v) {
            final isSelected = v == selected;
            final color = Color(v.colorValue);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => onChanged(v),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : scheme.outlineVariant.withValues(alpha: 0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.labelAr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? color : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PROFIT PREVIEW
// ═══════════════════════════════════════════════════════════

class _ProfitPreview extends StatelessWidget {
  const _ProfitPreview({
    required this.costPrice,
    required this.sellingPrice,
    required this.scheme,
  });
  final double costPrice;
  final double sellingPrice;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    if (costPrice <= 0 || sellingPrice <= 0) {
      return const SizedBox.shrink();
    }

    final profit = sellingPrice - costPrice;
    final margin = sellingPrice > 0 ? (profit / sellingPrice) * 100 : 0.0;
    final isPositive = profit >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color:
              (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                  .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_outlined
                : Icons.trending_down_outlined,
            color:
                isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 22,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الربح المتوقع للوحدة',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(profit),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Text(
                        '${margin.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
