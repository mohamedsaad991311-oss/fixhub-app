// lib/features/receiving/presentation/widgets/wizard_stepper.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/receiving_wizard_provider.dart';

/// ═══════════════════════════════════════════════════════════
/// WizardStepper — مؤشر خطوات الـ Wizard
/// ═══════════════════════════════════════════════════════════
///
/// - 3 دوائر (1, 2, 3)
/// - كل دائرة فيها label + ✓ للخطوات المكتملة
/// - خط بين الدوائر (يتملأ حسب التقدم)
/// - يدعم RTL تلقائياً
/// - قابل للضغط (لو الخطوة مكتملة)
///
class WizardStepper extends StatelessWidget {
  const WizardStepper({
    super.key,
    required this.currentStep,
    required this.completedSteps,
    this.onTapStep,
  });

  /// الخطوة الحالية
  final WizardStep currentStep;

  /// الخطوات المكتملة (لتمييزها بـ ✓)
  final Set<WizardStep> completedSteps;

  /// لما المستخدم يضغط على خطوة (للرجوع)
  final ValueChanged<WizardStep>? onTapStep;

  static const List<WizardStep> _steps = [
    WizardStep.customer,
    WizardStep.device,
    WizardStep.review,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMd,
        vertical: AppSizes.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: _ConnectorLine(
                  isCompleted: _isConnectorCompleted(i),
                  scheme: scheme,
                ),
              ),
            _StepCircle(
              step: _steps[i],
              isActive: _steps[i] == currentStep,
              isCompleted: completedSteps.contains(_steps[i]),
              onTap: onTapStep == null ? null : () => onTapStep!(_steps[i]),
            ),
          ],
        ],
      ),
    );
  }

  /// الخط بين الخطوة i-1 و i — يكون مكتمل لو الخطوة اللي قبل الأخيرة مكتملة
  bool _isConnectorCompleted(int index) {
    if (index <= 0 || index >= _steps.length) return false;
    return completedSteps.contains(_steps[index - 1]);
  }
}

// ═══════════════════════════════════════════════════════════
//  STEP CIRCLE
// ═══════════════════════════════════════════════════════════

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.step,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
  });

  final WizardStep step;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // ─── الحالة ───
    final Color bgColor;
    final Color fgColor;
    final Color borderColor;

    if (isCompleted && !isActive) {
      bgColor = const Color(0xFF10B981); // أخضر
      fgColor = Colors.white;
      borderColor = const Color(0xFF10B981);
    } else if (isActive) {
      bgColor = scheme.primary;
      fgColor = scheme.onPrimary;
      borderColor = scheme.primary;
    } else {
      bgColor = scheme.surfaceContainerHighest;
      fgColor = scheme.onSurfaceVariant;
      borderColor = scheme.outlineVariant;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              alignment: Alignment.center,
              child: isCompleted && !isActive
                  ? Icon(Icons.check, color: fgColor, size: 20)
                  : Text(
                      '${step.index + 1}',
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.labelAr,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CONNECTOR LINE
// ═══════════════════════════════════════════════════════════

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine({
    required this.isCompleted,
    required this.scheme,
  });

  final bool isCompleted;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10), // لفوق شوية عشان يبقى مع الدايرة
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF10B981)
              : scheme.outlineVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
