// lib/features/auth/presentation/widgets/identifier_field.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/country_codes.dart';
import '../../../../core/utils/validators.dart';
import 'auth_widgets.dart';
import 'phone_field.dart';

/// ═══════════════════════════════════════════════════════════
/// IdentifierField — إيميل أو تليفون (Toggle)
/// ═══════════════════════════════════════════════════════════
///
/// بيتكوّن من:
/// - Toggle (SegmentedButton) في الأعلى: [ الإيميل | التليفون ]
/// - لما "إيميل" → AuthTextField عادي
/// - لما "تليفون" → PhoneField مع اختيار الدولة
///
/// المميزات:
/// - Validator ديناميكي حسب الوضع المختار
/// - Callback `onChanged` بـ `IdentifierValue` جاهزة للـ signIn
/// - سهل الاستخدام: `IdentifierField(controller: ..., onChanged: ...)`
///
enum IdentifierType { email, phone }

/// القيمة النهائية بعد الاختيار
class IdentifierValue {
  /// النوع المختار
  final IdentifierType type;

  /// القيمة النهائية:
  /// - للإيميل: الإيميل كامل (`user@example.com`)
  /// - للتليفون: E.164 كامل (`+201038084846`)
  final String value;

  const IdentifierValue({required this.type, required this.value});

  /// هل القيمة صالحة؟
  bool get isValid => value.trim().isNotEmpty;

  @override
  String toString() => 'IdentifierValue($type, $value)';
}

class IdentifierField extends StatefulWidget {
  /// controller للقيمة الحالية
  final TextEditingController controller;

  /// النوع الافتراضي
  final IdentifierType initialType;

  /// الدولة الافتراضية (للتليفون)
  final CountryCode? initialCountry;

  /// Label الإيميل
  final String emailLabel;

  /// Label التليفون
  final String phoneLabel;

  /// نص زر التبديل — إيميل
  final String emailTabLabel;

  /// نص زر التبديل — تليفون
  final String phoneTabLabel;

  /// تفعيل
  final bool enabled;

  /// لما القيمة تتغير (type + value)
  final ValueChanged<IdentifierValue>? onChanged;

  const IdentifierField({
    super.key,
    required this.controller,
    this.initialType = IdentifierType.email,
    this.initialCountry,
    this.emailLabel = 'البريد الإلكتروني',
    this.phoneLabel = 'رقم التليفون',
    this.emailTabLabel = 'الإيميل',
    this.phoneTabLabel = 'التليفون',
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<IdentifierField> createState() => _IdentifierFieldState();
}

class _IdentifierFieldState extends State<IdentifierField> {
  late IdentifierType _type;
  late CountryCode _country;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _country = widget.initialCountry ?? countryCodes.first;
  }

  /// لما المستخدم يغيّر النوع
  void _onTypeChanged(IdentifierType type) {
    if (type == _type) return;
    // امسح الـ controller عشان مفيش نص قديم يلغبط
    widget.controller.clear();
    setState(() => _type = type);
    _notify();
  }

  /// لما الدولة تتغير
  void _onCountryChanged(CountryCode country) {
    setState(() => _country = country);
    _notify();
  }

  /// إرسال القيمة الحالية للأب
  void _notify() {
    final cb = widget.onChanged;
    if (cb == null) return;
    cb(_currentValue());
  }

  /// حساب القيمة الحالية
  IdentifierValue _currentValue() {
    final raw = widget.controller.text.trim();
    if (_type == IdentifierType.email) {
      return IdentifierValue(type: _type, value: raw);
    }
    // تليفون → E.164
    final e164 = Validators.normalizePhone(raw, _country);
    return IdentifierValue(type: _type, value: e164);
  }

  /// الـ Validator حسب النوع
  String? _validate(String? value) {
    if (_type == IdentifierType.email) {
      return Validators.email(value);
    }
    // تليفون
    if (value != null && value.trim().startsWith('+')) {
      return Validators.intlPhone(value);
    }
    return Validators.phoneWithCountry(value, _country);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Toggle ───
        _TypeToggle(
          type: _type,
          emailLabel: widget.emailTabLabel,
          phoneLabel: widget.phoneTabLabel,
          enabled: widget.enabled,
          onChanged: _onTypeChanged,
        ),
        const SizedBox(height: AppSizes.spaceSmMd),

        // ─── الحقل حسب النوع ───
        if (_type == IdentifierType.email)
          AuthTextField(
            key: const ValueKey('identifier_email_field'),
            controller: widget.controller,
            label: widget.emailLabel,
            hint: 'example@mail.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            enabled: widget.enabled,
            autofillHints: const [AutofillHints.email],
            validator: _validate,
            onChanged: (_) => _notify(),
          )
        else
          PhoneField(
            key: const ValueKey('identifier_phone_field'),
            controller: widget.controller,
            initialCountry: _country,
            onCountryChanged: _onCountryChanged,
            labelText: widget.phoneLabel,
            hintText: '1X XXXX XXXX',
            isRequired: true,
            prefixIcon: Icons.phone_outlined,
            enabled: widget.enabled,
            textInputAction: TextInputAction.next,
          ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// Toggle داخلي — [ الإيميل | التليفون ]
/// ═══════════════════════════════════════════════════════════
class _TypeToggle extends StatelessWidget {
  final IdentifierType type;
  final String emailLabel;
  final String phoneLabel;
  final bool enabled;
  final ValueChanged<IdentifierType> onChanged;

  const _TypeToggle({
    required this.type,
    required this.emailLabel,
    required this.phoneLabel,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              icon: Icons.email_outlined,
              label: emailLabel,
              isSelected: type == IdentifierType.email,
              enabled: enabled,
              onTap: () => onChanged(IdentifierType.email),
            ),
          ),
          Expanded(
            child: _ToggleItem(
              icon: Icons.phone_outlined,
              label: phoneLabel,
              isSelected: type == IdentifierType.phone,
              enabled: enabled,
              onTap: () => onChanged(IdentifierType.phone),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? scheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceSm,
            vertical: AppSizes.spaceSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
