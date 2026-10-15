// lib/features/staff/presentation/pages/staff_form_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../auth/data/models/app_user.dart' show UserRole;
import '../../data/models/staff_member.dart';
import '../providers/staff_form_provider.dart';
import '../providers/staff_list_provider.dart';
import '../widgets/role_badge.dart';

/// ═══════════════════════════════════════════════════════════
/// StaffFormPage — صفحة إضافة/تعديل موظف
/// ═══════════════════════════════════════════════════════════
class StaffFormPage extends ConsumerStatefulWidget {
  const StaffFormPage({super.key, this.editingMember});

  /// لو null → وضع الإضافة، لو موجود → وضع التعديل
  final StaffMember? editingMember;

  @override
  ConsumerState<StaffFormPage> createState() => _StaffFormPageState();
}

class _StaffFormPageState extends ConsumerState<StaffFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _fullNameArController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _hireDate;

  bool get _isEditing => widget.editingMember != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        ref
            .read(staffFormProvider.notifier)
            .loadForEdit(widget.editingMember!.id);
      } else {
        ref.read(staffFormProvider.notifier).reset();
      }
      _hydrateFromProvider();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameArController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _hydrateFromProvider() {
    final s = ref.read(staffFormProvider);
    _fullNameController.text = s.fullName;
    _fullNameArController.text = s.fullNameAr ?? '';
    _phoneController.text = s.phone ?? '';
    _emailController.text = s.email ?? '';
    _salaryController.text =
        (s.salary != null && s.salary! > 0) ? s.salary!.toStringAsFixed(0) : '';
    _notesController.text = s.notes ?? '';
    _hireDate = s.hireDate;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formState = ref.watch(staffFormProvider);
    final isSaving = formState.isSaving;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          _isEditing ? 'تعديل الموظف' : 'موظف جديد',
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
                controller: _fullNameController,
                label: 'الاسم الكامل *',
                hint: 'مثال: أحمد محمود',
                prefixIcon: Icons.person_outline,
                onChanged: (v) =>
                    ref.read(staffFormProvider.notifier).setFullName(v),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _fullNameArController,
                label: 'الاسم بالعربي (اختياري)',
                hint: 'مثال: أحمد محمود',
                prefixIcon: Icons.person_outline,
                onChanged: (v) => ref
                    .read(staffFormProvider.notifier)
                    .setFullNameAr(v.isEmpty ? null : v),
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
                    .read(staffFormProvider.notifier)
                    .setPhone(v.isEmpty ? null : v),
              ),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'staff@mail.com',
                prefixIcon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress,
                ltr: true,
                onChanged: (v) => ref
                    .read(staffFormProvider.notifier)
                    .setEmail(v.isEmpty ? null : v),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ الدور ═══
              _SectionTitle(title: 'الدور الوظيفي *', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              RolePicker(
                selected: formState.role,
                onChanged: (role) =>
                    ref.read(staffFormProvider.notifier).setRole(role),
                excludedRoles: const [UserRole.owner],
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ معلومات الوظيفة ═══
              _SectionTitle(title: 'معلومات الوظيفة', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              // ─── تاريخ التعيين ───
              _DateField(
                label: 'تاريخ التعيين (اختياري)',
                date: _hireDate,
                onChanged: (d) {
                  setState(() => _hireDate = d);
                  ref.read(staffFormProvider.notifier).setHireDate(d);
                },
                scheme: scheme,
              ),
              const SizedBox(height: AppSizes.spaceSm),

              // ─── الراتب ───
              _text(
                controller: _salaryController,
                label: 'الراتب الشهري (اختياري)',
                hint: 'مثال: 5000',
                prefixIcon: Icons.attach_money,
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                ltr: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                onChanged: (v) =>
                    ref.read(staffFormProvider.notifier).setSalary(
                          v.trim().isEmpty ? null : double.tryParse(v),
                        ),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ ملاحظات ═══
              _SectionTitle(title: 'ملاحظات', scheme: scheme),
              const SizedBox(height: AppSizes.spaceSm),

              _text(
                controller: _notesController,
                label: 'ملاحظات (اختياري)',
                hint: 'أي تفاصيل إضافية',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
                onChanged: (v) => ref
                    .read(staffFormProvider.notifier)
                    .setNotes(v.isEmpty ? null : v),
              ),

              const SizedBox(height: AppSizes.spaceLg),

              // ═══ الحالة ═══
              _ActiveToggle(
                value: formState.isActive,
                onChanged: (v) =>
                    ref.read(staffFormProvider.notifier).setActive(v),
                scheme: scheme,
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
                      : (_isEditing ? 'حفظ التعديلات' : 'إضافة الموظف'),
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

    final result = await ref.read(staffFormProvider.notifier).save();

    if (!mounted) return;

    if (result != null) {
      ref.read(staffListProvider.notifier).refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم تعديل الموظف' : 'تم إضافة الموظف'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(staffFormProvider).errorMessage;
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
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      textDirection: ltr ? TextDirection.ltr : null,
      inputFormatters: inputFormatters,
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

// ═══════════════════════════════════════════════════════════
//  DATE FIELD
// ═══════════════════════════════════════════════════════════

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onChanged,
    required this.scheme,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: DateTime(2000),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceSmMd,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.spaceSm),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : '${date!.year}/${date!.month.toString().padLeft(2, '0')}/${date!.day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      date == null ? scheme.onSurfaceVariant : scheme.onSurface,
                ),
              ),
            ),
            if (date != null)
              IconButton(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close, size: 18),
                color: scheme.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ACTIVE TOGGLE
// ═══════════════════════════════════════════════════════════

class _ActiveToggle extends StatelessWidget {
  const _ActiveToggle({
    required this.value,
    required this.onChanged,
    required this.scheme,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_outline : Icons.block_outlined,
            size: 20,
            color: value ? const Color(0xFF10B981) : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الحالة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  value ? 'الموظف نشط' : 'الموظف معطّل',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
