// lib/features/settings/presentation/pages/language_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/locale_provider.dart';

/// ═══════════════════════════════════════════════════════════════
/// LanguageSettingsPage — إعدادات اللغة
/// ═══════════════════════════════════════════════════════════════
///
/// - العربية (RTL) — افتراضي
/// - English (LTR)
/// - حسب النظام (System)
///
/// التبديل فوري (Live) — بفضل Riverpod
///
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اللغة'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.maxFormWidth * 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ──── Info Card ────
                  _buildInfoCard(context),
                  const SizedBox(height: AppSizes.spaceLg),

                  // ──── Language Options ────
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? scheme.surfaceContainerHigh
                          : scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                        width: AppSizes.borderNormal,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildLanguageTile(
                          context,
                          ref,
                          localeCode: 'ar',
                          title: 'العربية',
                          subtitle: 'اللغة العربية (RTL)',
                          flag: '🇪🇬',
                          isSelected: currentLocale.languageCode == 'ar',
                          isFirst: true,
                        ),
                        Divider(
                          height: 1,
                          indent: AppSizes.spaceLg + AppSizes.spaceMd,
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                        _buildLanguageTile(
                          context,
                          ref,
                          localeCode: 'en',
                          title: 'English',
                          subtitle: 'English language (LTR)',
                          flag: '🇬🇧',
                          isSelected: currentLocale.languageCode == 'en',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceLg),

                  // ──── Preview ────
                  _buildPreview(context, currentLocale),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  LANGUAGE TILE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref, {
    required String localeCode,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSelected
            ? null
            : () {
                ref.read(localeProvider.notifier).setLocale(Locale(localeCode));
                _showSnack(
                  context,
                  localeCode == 'ar'
                      ? 'تم التحويل إلى العربية'
                      : 'Language switched to English',
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceSmMd,
            vertical: AppSizes.spaceSmMd,
          ),
          child: Row(
            children: [
              // ──── Flag ────
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: scheme.primary
                        .withValues(alpha: isSelected ? 0.5 : 0.15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSmMd),

              // ──── Text ────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? scheme.primary : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ──── Check ────
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: scheme.onPrimary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PREVIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPreview(BuildContext context, Locale locale) {
    final scheme = Theme.of(context).colorScheme;
    final isArabic = locale.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.25),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: AppSizes.iconXs,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSizes.spaceXs),
              Text(
                'معاينة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  isArabic ? 'RTL' : 'LTR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          // ──── Sample Card ────
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'مرحباً بك في FixHub' : 'Welcome to FixHub',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'نظام إدارة ورش صيانة الموبايل'
                      : 'Repair shop management system',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSizes.spaceSmMd,
                        ),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: Text(isArabic ? 'حفظ' : 'Save'),
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSizes.spaceSmMd,
                        ),
                        textStyle: const TextStyle(fontSize: 11),
                      ),
                      child: Text(isArabic ? 'إلغاء' : 'Cancel'),
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

  // ═══════════════════════════════════════════════════════════════
  //  INFO CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildInfoCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.3),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: scheme.primary,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              'التغيير يتم فوراً — بدون الحاجة لإعادة تشغيل التطبيق',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SNACK
  // ═══════════════════════════════════════════════════════════════

  void _showSnack(BuildContext context, String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: scheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
