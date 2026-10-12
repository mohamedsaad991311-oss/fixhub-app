// lib/features/auth/presentation/widgets/phone_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/country_codes.dart';
import '../../../../core/utils/validators.dart';

/// ═══════════════════════════════════════════════════════════
/// PhoneField — حقل موبايل مع اختيار الدولة
/// ═══════════════════════════════════════════════════════════
///
/// بيتكوّن من:
/// - Dropdown للدولة (علم + كود)
/// - TextField للرقم المحلي
///
/// المميزات:
/// - Validator ديناميكي حسب الدولة المختارة
/// - بيدعم E.164 normalization عبر `Validators.normalizePhone`
/// - RTL-friendly
///
class PhoneField extends StatefulWidget {
  /// الـ controller للرقم المحلي
  final TextEditingController controller;

  /// الدولة المختارة (خارجياً) — لو null يستخدم مصر
  final CountryCode? initialCountry;

  /// لما الدولة تتغير
  final ValueChanged<CountryCode>? onCountryChanged;

  /// Label الحقل
  final String labelText;

  /// Hint text
  final String hintText;

  /// هل الحقل مطلوب؟
  final bool isRequired;

  /// Icon جوه الحقل
  final IconData? prefixIcon;

  /// تفعيل/تعطيل
  final bool enabled;

  /// FocusNode خارجي (اختياري)
  final FocusNode? focusNode;

  /// textInputAction
  final TextInputAction? textInputAction;

  /// onFieldSubmitted
  final ValueChanged<String>? onFieldSubmitted;

  const PhoneField({
    super.key,
    required this.controller,
    this.initialCountry,
    this.onCountryChanged,
    this.labelText = 'رقم الموبايل',
    this.hintText = '1X XXXX XXXX',
    this.isRequired = true,
    this.prefixIcon = Icons.phone_outlined,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late CountryCode _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? countryCodes.first;
  }

  @override
  void didUpdateWidget(covariant PhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الدولة الافتراضية اتغيرت من بره
    if (oldWidget.initialCountry != widget.initialCountry &&
        widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry!;
    }
  }

  /// تغيير الدولة
  void _onCountryChanged(CountryCode? country) {
    if (country == null) return;
    setState(() => _selectedCountry = country);
    widget.onCountryChanged?.call(country);
  }

  /// الـ Validator
  String? _validate(String? value) {
    // لو الحقل اختياري وفاضي
    if (!widget.isRequired && (value == null || value.trim().isEmpty)) {
      return null;
    }

    // لو المستخدم كتب + في الأول → يبقى رقم دولي كامل
    if (value != null && value.trim().startsWith('+')) {
      return Validators.intlPhone(value);
    }

    // غير كده → تحقق حسب الدولة المختارة
    return Validators.phoneWithCountry(value, _selectedCountry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+]')),
        LengthLimitingTextInputFormatter(15),
      ],
      validator: _validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        // الـ Dropdown بيظهر جوه الـ prefix
        prefix: _CountryPrefix(
          country: _selectedCountry,
          enabled: widget.enabled,
          isRtl: isRtl,
          onChanged: _onCountryChanged,
          theme: theme,
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════
/// Widget داخلي: يعرض العلم + الكود + سهم للاختيار
/// ═══════════════════════════════════════════════════════════
class _CountryPrefix extends StatelessWidget {
  final CountryCode country;
  final bool enabled;
  final bool isRtl;
  final ValueChanged<CountryCode?> onChanged;
  final ThemeData theme;

  const _CountryPrefix({
    required this.country,
    required this.enabled,
    required this.isRtl,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return PopupMenuButton<CountryCode>(
      enabled: enabled,
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
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              country.fullDialCode,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 20,
              color: theme.dividerColor,
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
