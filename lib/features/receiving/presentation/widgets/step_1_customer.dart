// lib/features/receiving/presentation/widgets/step_1_customer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../core/utils/validators.dart';
import '../providers/receiving_form_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// Step1Customer — الخطوة 1: بيانات العميل
/// ═══════════════════════════════════════════════════════════
///
/// - الاسم (مطلوب)
/// - رقم التليفون (مطلوب) مع اختيار الدولة
/// - الإيميل (اختياري)
/// - ملاحظات العميل (اختياري)
///
class Step1Customer extends ConsumerStatefulWidget {
  const Step1Customer({super.key});

  @override
  ConsumerState<Step1Customer> createState() => _Step1CustomerState();
}

class _Step1CustomerState extends ConsumerState<Step1Customer> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  CountryCode _country = countryCodes.first;

  @override
  void initState() {
    super.initState();
    final form = ref.read(receivingFormProvider);
    _nameController = TextEditingController(text: form.customerName);
    _phoneController = TextEditingController(text: form.customerPhone);
    _emailController = TextEditingController(text: form.customerEmail ?? '');
    _notesController = TextEditingController(text: form.customerNotes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Section Header ───
          _SectionHeader(
            icon: Icons.person_outline,
            title: 'بيانات العميل',
            subtitle: 'الاسم ورقم التليفون مطلوبان',
            scheme: scheme,
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── الاسم ───
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            onChanged: (v) =>
                ref.read(receivingFormProvider.notifier).setCustomerName(v),
            decoration: _inputDecoration(
              scheme: scheme,
              isDark: isDark,
              label: 'اسم العميل',
              hint: 'مثال: أحمد محمود',
              prefixIcon: Icons.person_outline,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── رقم التليفون مع اختيار الدولة ───
          _PhoneInput(
            controller: _phoneController,
            country: _country,
            onCountryChanged: (c) {
              setState(() => _country = c);
              _updatePhone();
            },
            onChanged: (_) => _updatePhone(),
            scheme: scheme,
            isDark: isDark,
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── الإيميل (اختياري) ───
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            onChanged: (v) {
              final notifier = ref.read(receivingFormProvider.notifier);
              if (v.trim().isEmpty) {
                notifier.setCustomerEmail(null);
              } else {
                notifier.setCustomerEmail(v);
              }
            },
            decoration: _inputDecoration(
              scheme: scheme,
              isDark: isDark,
              label: 'البريد الإلكتروني (اختياري)',
              hint: 'example@mail.com',
              prefixIcon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── ملاحظات ───
          TextField(
            controller: _notesController,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onChanged: (v) {
              final notifier = ref.read(receivingFormProvider.notifier);
              if (v.trim().isEmpty) {
                notifier.setCustomerNotes(null);
              } else {
                notifier.setCustomerNotes(v);
              }
            },
            decoration: _inputDecoration(
              scheme: scheme,
              isDark: isDark,
              label: 'ملاحظات العميل (اختياري)',
              hint: 'أي ملاحظات إضافية',
              prefixIcon: Icons.notes_outlined,
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: AppSizes.spaceLg),

          // ─── Tip ───
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: AppSizes.iconSm,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    'لو العميل ده جه قبل كده، رقم التليفون هيساعدك تربط الإيصالات القديمة.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  void _updatePhone() {
    final text = _phoneController.text.trim();
    final notifier = ref.read(receivingFormProvider.notifier);

    if (text.isEmpty) {
      notifier.setCustomerPhone('');
      return;
    }

    // لو المستخدم بدأ بـ + → استخدمه كما هو
    if (text.startsWith('+')) {
      notifier.setCustomerPhone(text);
    } else {
      // حوّله لـ E.164
      final e164 = Validators.normalizePhone(text, _country);
      notifier.setCustomerPhone(e164);
    }
  }

  InputDecoration _inputDecoration({
    required ColorScheme scheme,
    required bool isDark,
    required String label,
    String? hint,
    IconData? prefixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, size: AppSizes.iconSm) : null,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceSmMd,
      ),
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final ColorScheme scheme;

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
                  fontSize: 16,
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
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PHONE INPUT WITH COUNTRY
// ═══════════════════════════════════════════════════════════

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    required this.onChanged,
    required this.scheme,
    required this.isDark,
  });

  final TextEditingController controller;
  final CountryCode country;
  final ValueChanged<CountryCode> onCountryChanged;
  final ValueChanged<String> onChanged;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      textDirection: TextDirection.ltr,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+]')),
        LengthLimitingTextInputFormatter(15),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'رقم التليفون',
        hintText: '1X XXXX XXXX',
        prefixIcon: const Icon(Icons.phone_outlined, size: AppSizes.iconSm),
        prefix: Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: _CountryPrefix(
            country: country,
            onChanged: onCountryChanged,
            scheme: scheme,
          ),
        ),
        filled: true,
        fillColor:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceSmMd,
        ),
      ),
    );
  }
}

// ─── Country Prefix ───
class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix({
    required this.country,
    required this.onChanged,
    required this.scheme,
  });

  final CountryCode country;
  final ValueChanged<CountryCode> onChanged;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return PopupMenuButton<CountryCode>(
      tooltip: '',
      onSelected: onChanged,
      offset: const Offset(0, 40),
      itemBuilder: (context) {
        return countryCodes.map((c) {
          final isSelected = c.isoCode == country.isoCode;
          return PopupMenuItem<CountryCode>(
            value: c,
            child: Row(
              children: [
                Text(c.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.name(langCode),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  c.fullDialCode,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            country.fullDialCode,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: 18),
          const SizedBox(width: 6),
          Container(
            width: 1,
            height: 20,
            color: scheme.outlineVariant,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
