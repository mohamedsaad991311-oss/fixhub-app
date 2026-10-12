// lib/features/receiving/presentation/widgets/step_2_device.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../receipts/data/models/receipt.dart';
import '../providers/receiving_form_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// Step2Device — الخطوة 2: بيانات الجهاز + الأعطال
/// ═══════════════════════════════════════════════════════════
class Step2Device extends ConsumerStatefulWidget {
  const Step2Device({super.key});

  @override
  ConsumerState<Step2Device> createState() => _Step2DeviceState();
}

class _Step2DeviceState extends ConsumerState<Step2Device> {
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _imeiController;
  late final TextEditingController _serialController;
  late final TextEditingController _colorController;
  late final TextEditingController _passwordController;
  late final TextEditingController _conditionController;

  String? _deviceType; // نوع الجهاز المختار

  /// أنواع الأجهزة الشائعة
  static const List<_DeviceType> _deviceTypes = [
    _DeviceType(id: 'smartphone', label: 'موبايل', icon: Icons.smartphone),
    _DeviceType(id: 'tablet', label: 'تابلت', icon: Icons.tablet_mac),
    _DeviceType(id: 'laptop', label: 'لابتوب', icon: Icons.laptop_mac),
    _DeviceType(id: 'smartwatch', label: 'ساعة', icon: Icons.watch),
    _DeviceType(id: 'accessory', label: 'ملحق', icon: Icons.headphones),
    _DeviceType(id: 'other', label: 'أخرى', icon: Icons.devices_other),
  ];

  @override
  void initState() {
    super.initState();
    final form = ref.read(receivingFormProvider);
    _deviceType = form.deviceType;
    _brandController = TextEditingController(text: form.deviceBrand ?? '');
    _modelController = TextEditingController(text: form.deviceModel ?? '');
    _imeiController = TextEditingController(text: form.deviceImei ?? '');
    _serialController = TextEditingController(text: form.deviceSerial ?? '');
    _colorController = TextEditingController(text: form.deviceColor ?? '');
    _passwordController =
        TextEditingController(text: form.devicePassword ?? '');
    _conditionController =
        TextEditingController(text: form.conditionNotes ?? '');
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _imeiController.dispose();
    _serialController.dispose();
    _colorController.dispose();
    _passwordController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final form = ref.watch(receivingFormProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══ 1) نوع الجهاز ═══
          _SectionHeader(
            icon: Icons.devices_outlined,
            title: 'نوع الجهاز',
            subtitle: 'اختر نوع الجهاز (مطلوب)',
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          _DeviceTypeGrid(
            types: _deviceTypes,
            selectedId: _deviceType,
            onSelect: (id) {
              setState(() => _deviceType = id);
              ref.read(receivingFormProvider.notifier).setDeviceType(id);
            },
            scheme: scheme,
            isDark: isDark,
          ),

          const SizedBox(height: AppSizes.spaceLg),

          // ═══ 2) تفاصيل الجهاز ═══
          _SectionHeader(
            icon: Icons.info_outline,
            title: 'تفاصيل الجهاز',
            subtitle: 'الماركة والموديل (اختياري)',
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _brandController,
                  label: 'الماركة',
                  hint: 'Apple, Samsung...',
                  icon: Icons.branding_watermark_outlined,
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) => _setNullable(
                    v,
                    ref.read(receivingFormProvider.notifier).setDeviceBrand,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: _textField(
                  controller: _modelController,
                  label: 'الموديل',
                  hint: 'iPhone 15, S24...',
                  icon: Icons.phone_iphone_outlined,
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) => _setNullable(
                    v,
                    ref.read(receivingFormProvider.notifier).setDeviceModel,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),

          _textField(
            controller: _imeiController,
            label: 'IMEI',
            hint: '15 رقم (اختياري)',
            icon: Icons.qr_code_outlined,
            scheme: scheme,
            isDark: isDark,
            keyboardType: TextInputType.number,
            onChanged: (v) => _setNullable(
              v,
              ref.read(receivingFormProvider.notifier).setDeviceImei,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _serialController,
                  label: 'السيريال',
                  hint: 'Serial (اختياري)',
                  icon: Icons.confirmation_number_outlined,
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) => _setNullable(
                    v,
                    ref.read(receivingFormProvider.notifier).setDeviceSerial,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),
              Expanded(
                child: _textField(
                  controller: _colorController,
                  label: 'اللون',
                  hint: 'Black, White...',
                  icon: Icons.palette_outlined,
                  scheme: scheme,
                  isDark: isDark,
                  onChanged: (v) => _setNullable(
                    v,
                    ref.read(receivingFormProvider.notifier).setDeviceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceMd),

          _textField(
            controller: _passwordController,
            label: 'كلمة سر الجهاز (اختياري)',
            hint: 'PIN / Pattern / Password',
            icon: Icons.lock_outline,
            scheme: scheme,
            isDark: isDark,
            onChanged: (v) => _setNullable(
              v,
              ref.read(receivingFormProvider.notifier).setDevicePassword,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          _textField(
            controller: _conditionController,
            label: 'حالة الجهاز الظاهرية (اختياري)',
            hint: 'خدوش، كسر شاشة، انبعاج...',
            icon: Icons.visibility_outlined,
            scheme: scheme,
            isDark: isDark,
            maxLines: 2,
            onChanged: (v) => _setNullable(
              v,
              ref.read(receivingFormProvider.notifier).setConditionNotes,
            ),
          ),

          const SizedBox(height: AppSizes.spaceLg),

          // ═══ 3) الأعطال ═══
          _SectionHeader(
            icon: Icons.build_outlined,
            title: 'الأعطال',
            subtitle: 'أضف عطل واحد على الأقل (مطلوب)',
            scheme: scheme,
            trailing: _AddButton(
              label: 'إضافة عطل',
              onTap: () => _openIssueDialog(context),
              scheme: scheme,
            ),
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          if (form.issues.isEmpty)
            _EmptyIssues(scheme: scheme)
          else
            ...List.generate(
              form.issues.length,
              (i) => _IssueTile(
                issue: form.issues[i],
                index: i,
                onDelete: () =>
                    ref.read(receivingFormProvider.notifier).removeIssue(i),
                onEdit: () => _openIssueDialog(context, editIndex: i),
                scheme: scheme,
                isDark: isDark,
              ),
            ),

          const SizedBox(height: AppSizes.spaceLg),

          // ═══ 4) الملحقات ═══
          _SectionHeader(
            icon: Icons.inventory_2_outlined,
            title: 'الملحقات',
            subtitle: 'اللي العميل سلّمه مع الجهاز (اختياري)',
            scheme: scheme,
            trailing: _AddButton(
              label: 'إضافة ملحق',
              onTap: () => _openAccessoryDialog(context),
              scheme: scheme,
            ),
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          if (form.accessories.isEmpty)
            _EmptyAccessories(scheme: scheme)
          else
            Wrap(
              spacing: AppSizes.spaceSm,
              runSpacing: AppSizes.spaceSm,
              children: List.generate(
                form.accessories.length,
                (i) => _AccessoryChip(
                  accessory: form.accessories[i],
                  onToggle: () => ref
                      .read(receivingFormProvider.notifier)
                      .toggleAccessory(i),
                  onDelete: () => ref
                      .read(receivingFormProvider.notifier)
                      .removeAccessory(i),
                  scheme: scheme,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  void _setNullable(String v, void Function(String?) setter) {
    if (v.trim().isEmpty) {
      setter(null);
    } else {
      setter(v);
    }
  }

  InputDecoration _inputDeco({
    required ColorScheme scheme,
    required bool isDark,
    required String label,
    String? hint,
    IconData? icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: AppSizes.iconSm) : null,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor:
          isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide:
            BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        borderSide:
            BorderSide(color: scheme.primary, width: AppSizes.borderMedium),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSmMd,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme scheme,
    required bool isDark,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: _inputDeco(
        scheme: scheme,
        isDark: isDark,
        label: label,
        hint: hint,
        icon: icon,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  // ─── Issue Dialog ───

  Future<void> _openIssueDialog(BuildContext context, {int? editIndex}) async {
    final existing = editIndex != null
        ? ref.read(receivingFormProvider).issues[editIndex]
        : null;

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final costCtrl = TextEditingController(
      text: existing?.cost != null ? existing!.cost!.toStringAsFixed(0) : '',
    );

    final result = await showDialog<ReceiptIssue>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editIndex == null ? 'إضافة عطل' : 'تعديل العطل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'وصف العطل',
                  hintText: 'مثال: شاشة مكسورة',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'تفاصيل (اختياري)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'التكلفة التقديرية (اختياري)',
                  hintText: '0',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final cost = double.tryParse(costCtrl.text.trim());
              final issue = ReceiptIssue(
                title: title,
                description:
                    descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                cost: cost,
              );
              Navigator.pop(ctx, issue);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == null) return;
    final notifier = ref.read(receivingFormProvider.notifier);
    if (editIndex == null) {
      notifier.addIssue(result);
    } else {
      notifier.updateIssue(editIndex, result);
    }
  }

  // ─── Accessory Dialog ───

  Future<void> _openAccessoryDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ملحق'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'اسم الملحق',
            hintText: 'مثال: شاحن، سماعة، جراب',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx, name);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == null) return;
    ref.read(receivingFormProvider.notifier).addAccessory(
          ReceiptAccessory(name: result),
        );
  }
}

// ═══════════════════════════════════════════════════════════
//  DEVICE TYPE GRID
// ═══════════════════════════════════════════════════════════

class _DeviceType {
  const _DeviceType({
    required this.id,
    required this.label,
    required this.icon,
  });
  final String id;
  final String label;
  final IconData icon;
}

class _DeviceTypeGrid extends StatelessWidget {
  const _DeviceTypeGrid({
    required this.types,
    required this.selectedId,
    required this.onSelect,
    required this.scheme,
    required this.isDark,
  });

  final List<_DeviceType> types;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth < 500 ? 3 : 6;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: AppSizes.spaceSm,
          mainAxisSpacing: AppSizes.spaceSm,
          childAspectRatio: 1,
          children: types.map((t) {
            final selected = t.id == selectedId;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(t.id),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary.withValues(alpha: 0.15)
                        : (isDark
                            ? scheme.surfaceContainerHigh
                            : scheme.surfaceContainerLow),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: selected
                          ? scheme.primary
                          : scheme.outlineVariant.withValues(alpha: 0.5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t.icon,
                        size: 26,
                        color:
                            selected ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SECTION HEADER
// ═══════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.scheme,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final ColorScheme scheme;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: scheme.primary, size: 22),
        ),
        const SizedBox(width: AppSizes.spaceSmMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ADD BUTTON
// ═══════════════════════════════════════════════════════════

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.label,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.add, size: 18, color: scheme.primary),
      label: Text(
        label,
        style: TextStyle(fontSize: 13, color: scheme.primary),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ISSUE TILE
// ═══════════════════════════════════════════════════════════

class _IssueTile extends StatelessWidget {
  const _IssueTile({
    required this.issue,
    required this.index,
    required this.onDelete,
    required this.onEdit,
    required this.scheme,
    required this.isDark,
  });

  final ReceiptIssue issue;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceSm),
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (issue.description != null &&
                    issue.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    issue.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (issue.cost != null && issue.cost! > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(issue.cost),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: scheme.onSurfaceVariant,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18),
            color: scheme.error,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  EMPTY STATES
// ═══════════════════════════════════════════════════════════

class _EmptyIssues extends StatelessWidget {
  const _EmptyIssues({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.build_outlined,
            size: 32,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'لم تُضف أي أعطال بعد',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAccessories extends StatelessWidget {
  const _EmptyAccessories({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
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
            Icons.inventory_2_outlined,
            size: 24,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'لا توجد ملحقات مسجّلة',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ACCESSORY CHIP
// ═══════════════════════════════════════════════════════════

class _AccessoryChip extends StatelessWidget {
  const _AccessoryChip({
    required this.accessory,
    required this.onToggle,
    required this.onDelete,
    required this.scheme,
  });

  final ReceiptAccessory accessory;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final included = accessory.isIncluded;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSmMd,
        vertical: AppSizes.spaceSm,
      ),
      decoration: BoxDecoration(
        color: included
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(
          color: included
              ? scheme.primary.withValues(alpha: 0.4)
              : scheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Icon(
              included ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: included ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            accessory.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: included ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
