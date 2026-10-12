// lib/features/receiving/presentation/widgets/wizard_nav_buttons.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/receiving_wizard_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// WizardNavButtons — أزرار التنقل بين الخطوات
/// ═══════════════════════════════════════════════════════════
///
/// - زر "السابق" (يظهر من الخطوة 2)
/// - زر "التالي" (يظهر في الخطوات 1-2)
/// - زر "حفظ الإيصال" (يظهر في الخطوة 3)
/// - Loading state أثناء الحفظ
/// - Disabled state لو الخطوة الحالية غير صالحة
///
class WizardNavButtons extends StatelessWidget {
  const WizardNavButtons({
    super.key,
    required this.currentStep,
    required this.canProceed,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  final WizardStep currentStep;

  /// هل الخطوة الحالية صالحة للـ next؟
  final bool canProceed;

  /// هل بنحفظ حالياً؟
  final bool isSubmitting;

  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFirst = currentStep == WizardStep.customer;
    final isLast = currentStep == WizardStep.review;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spaceMd,
        AppSizes.spaceSmMd,
        AppSizes.spaceMd,
        MediaQuery.of(context).padding.bottom + AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // ─── زر السابق ───
          if (!isFirst) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('السابق'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  side: BorderSide(
                    color: scheme.outlineVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spaceSmMd),
          ],

          // ─── زر التالي أو حفظ ───
          Expanded(
            flex: isFirst ? 1 : 3,
            child: FilledButton.icon(
              onPressed: isSubmitting
                  ? null
                  : (!isLast && !canProceed)
                      ? null
                      : (isLast ? onSubmit : onNext),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      isLast ? Icons.check : Icons.arrow_forward,
                      size: 18,
                    ),
              label: Text(
                isSubmitting
                    ? 'جاري الحفظ...'
                    : (isLast ? 'حفظ الإيصال' : 'التالي'),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonHeightLg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
