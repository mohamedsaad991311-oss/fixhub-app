// lib/features/suppliers/presentation/pages/supplier_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../data/models/supplier.dart';
import '../providers/supplier_form_provider.dart';
import '../providers/suppliers_list_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// SupplierFormPage — صفحة إضافة/تعديل مورد
/// ═══════════════════════════════════════════════════════════
class SupplierFormPage extends ConsumerStatefulWidget {
  const SupplierFormPage({super.key, this.editingSupplier});

  /// لو null → وضع الإضافة، لو موجود → وضع التعديل
  final Supplier? editingSupplier;

  @override
  ConsumerState<SupplierFormPage> createState() => _SupplierFormPageState();
}

class _SupplierFormPageState extends ConsumerState<SupplierFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool get _isEditing => widget.editingSupplier != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        ref
            .read(supplierFormProvider.notifier)
            .loadForEdit(widget.editingSupplier!.id);
      } else {
        ref.read(supplierFormProvider.notifier).reset();
      }
      _hydrateFromProvider();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _hydrateFromProvider() {
    final s = ref.read(supplierFormProvider);
    _nameController.text = s.name;
    _contactPersonController.text = s.contactPerson ?? '';
    _phoneController.text = s.phone ?? '';
    _emailController.text = s.email ?? '';
    _addressController.text = s.address ?? '';
    _notesController.text = s.notes ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formState = ref.watch(supplierFormProvider);
    final isSaving = formState.isSaving;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          _isEditing ? 'تعديل المورد' : 'مورد جديد',
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
              // ═══ المعلومات الأساسية ═══
              _SectionTitle(title: 'المعلومات الأساسية', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _nameController,
                label: 'اسم المورد *',
                hint: 'مثال: شركة النور للقطع',
                prefixIcon: Icons.store_outlined,
                onChanged: (v) =>
                    ref.read(supplierFormProvider.notifier).setName(v),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _contactPersonController,
                label: 'اسم المسؤول (اختياري)',
                hint: 'مثال: أحمد محمود',
                prefixIcon: Icons.person_outline,
                onChanged: (v) => ref
                    .read(supplierFormProvider.notifier)
                    .setContactPerson(v.isEmpty ? null : v),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ بيانات التواصل ═══
              _SectionTitle(title: 'بيانات التواصل', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _phoneController,
                label: 'رقم التليفون',
                hint: '01012345678',
                prefixIcon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                ltr: true,
                onChanged: (v) => ref
                    .read(supplierFormProvider.notifier)
                    .setPhone(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'supplier@mail.com',
                prefixIcon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                ltr: true,
                onChanged: (v) => ref
                    .read(supplierFormProvider.notifier)
                    .setEmail(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _addressController,
                label: 'العنوان (اختياري)',
                hint: 'مثال: شارع الجمهورية، القاهرة',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                onChanged: (v) => ref
                    .read(supplierFormProvider.notifier)
                    .setAddress(v.isEmpty ? null : v),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ ملاحظات ═══
              _SectionTitle(title: 'ملاحظات', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _notesController,
                label: 'ملاحظات (اختياري)',
                hint: 'أي تفاصيل إضافية عن المورد',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
                onChanged: (v) => ref
                    .read(supplierFormProvider.notifier)
                    .setNotes(v.isEmpty ? null : v),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ Save Button ═══
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
                      : (_isEditing ? 'حفظ التعديلات' : 'إضافة المورد'),
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

    final result = await ref.read(supplierFormProvider.notifier).save();

    if (!mounted) return;

    if (result != null) {
      // حدّث قائمة الموردين
      ref.read(suppliersListProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تعديل المورد' : 'تم إضافة المورد'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(supplierFormProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'فشل الحفظ'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Helpers ───

  Widget _text({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool ltr = false,
    IconData? prefixIcon,
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, size: AppSizes.iconSm) : null,
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
