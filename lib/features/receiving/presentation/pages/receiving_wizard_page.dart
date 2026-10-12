// lib/features/receiving/presentation/pages/receiving_wizard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../providers/receiving_form_provider.dart';
import '../providers/receiving_wizard_provider.dart';
import '../widgets/step_1_customer.dart';
import '../widgets/step_2_device.dart';
import '../widgets/step_3_review.dart';
import '../widgets/wizard_nav_buttons.dart';
import '../widgets/wizard_stepper.dart';

/// ═══════════════════════════════════════════════════════════
/// ReceivingWizardPage — استلام جهاز جديد (3 خطوات)
/// ═══════════════════════════════════════════════════════════
class ReceivingWizardPage extends ConsumerStatefulWidget {
  const ReceivingWizardPage({super.key});

  @override
  ConsumerState<ReceivingWizardPage> createState() =>
      _ReceivingWizardPageState();
}

class _ReceivingWizardPageState extends ConsumerState<ReceivingWizardPage> {
  @override
  void initState() {
    super.initState();
    // reset عند فتح الصفحة من الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receivingWizardProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wizard = ref.watch(receivingWizardProvider);
    final form = ref.watch(receivingFormProvider);

    // ─── Success screen ───
    if (wizard.isSuccess && wizard.createdReceipt != null) {
      return _SuccessScreen(
        receiptNumber: wizard.createdReceipt!.receiptNumber,
        receiptId: wizard.createdReceipt!.id,
        onViewReceipt: () {
          ref.read(receivingWizardProvider.notifier).reset();
          context.pushReplacement(
            RouteNames.receiptDetailOf(wizard.createdReceipt!.id),
          );
        },
        onNewReceipt: () {
          ref.read(receivingWizardProvider.notifier).reset();
        },
        onGoHome: () {
          ref.read(receivingWizardProvider.notifier).reset();
          context.go(RouteNames.home);
        },
      );
    }

    // ─── الخطوات المكتملة ───
    final completed = <WizardStep>{};
    if (form.isStep1Valid) completed.add(WizardStep.customer);
    if (form.isStep2Valid) completed.add(WizardStep.device);

    // ─── هل نقدر ننتقل من الخطوة الحالية؟ ───
    final canProceed = _canProceed(wizard.currentStep, form);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(context, wizard.currentStep),
          tooltip: 'إغلاق',
        ),
        title: const Text(
          'استلام جهاز جديد',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Stepper ───
          WizardStepper(
            currentStep: wizard.currentStep,
            completedSteps: completed,
            onTapStep: (step) =>
                ref.read(receivingWizardProvider.notifier).goTo(step),
          ),

          // ─── Error banner ───
          if (wizard.hasError) ...[
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceMd),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: scheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: scheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    Expanded(
                      child: Text(
                        wizard.errorMessage!,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => ref
                          .read(receivingWizardProvider.notifier)
                          .clearError(),
                      icon: const Icon(Icons.close, size: 18),
                      color: scheme.onErrorContainer,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ─── الخطوة الحالية ───
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(wizard.currentStep),
                child: _buildStep(wizard.currentStep),
              ),
            ),
          ),

          // ─── Navigation buttons ───
          WizardNavButtons(
            currentStep: wizard.currentStep,
            canProceed: canProceed,
            isSubmitting: wizard.isSubmitting,
            onBack: () => ref.read(receivingWizardProvider.notifier).back(),
            onNext: () => ref.read(receivingWizardProvider.notifier).next(),
            onSubmit: _handleSubmit,
          ),
        ],
      ),
    );
  }

  // ─── Step builder ───

  Widget _buildStep(WizardStep step) {
    switch (step) {
      case WizardStep.customer:
        return const Step1Customer();
      case WizardStep.device:
        return const Step2Device();
      case WizardStep.review:
        return const Step3Review();
    }
  }

  // ─── Can proceed ───

  bool _canProceed(WizardStep step, ReceivingFormState form) {
    switch (step) {
      case WizardStep.customer:
        return form.isStep1Valid;
      case WizardStep.device:
        return form.isStep2Valid;
      case WizardStep.review:
        return form.isComplete;
    }
  }

  // ─── Submit ───

  Future<void> _handleSubmit() async {
    final ok = await ref.read(receivingWizardProvider.notifier).submit();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(receivingWizardProvider).errorMessage ?? 'فشل حفظ الإيصال',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Close ───

  Future<void> _handleClose(BuildContext context, WizardStep step) async {
    final form = ref.read(receivingFormProvider);

    // لو الخطوة 1 ومفيش بيانات → أغلق عادي
    if (step == WizardStep.customer &&
        form.customerName.isEmpty &&
        form.customerPhone.isEmpty) {
      _popOrGoHome(context);
      return;
    }

    // أكّد الإغلاق لو فيه بيانات
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الاستلام؟'),
        content: const Text(
          'لو خرجت دلوقتي، كل البيانات اللي دخلتها هتضيع. متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لا، كمّل'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (shouldClose == true) {
      ref.read(receivingWizardProvider.notifier).reset();
      if (context.mounted) _popOrGoHome(context);
    }
  }

  void _popOrGoHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  SUCCESS SCREEN
// ═══════════════════════════════════════════════════════════

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({
    required this.receiptNumber,
    required this.receiptId,
    required this.onViewReceipt,
    required this.onNewReceipt,
    required this.onGoHome,
  });

  final String receiptNumber;
  final String receiptId;
  final VoidCallback onViewReceipt;
  final VoidCallback onNewReceipt;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Icon ───
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceLg),

              // ─── Title ───
              Text(
                'تم حفظ الإيصال بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.spaceSm),

              // ─── Receipt number ───
              Text(
                receiptNumber,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              Text(
                'تقدر تطبع الإيصال أو تشاركه مع العميل عبر واتساب.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: AppSizes.spaceXl),

              // ─── View receipt ───
              FilledButton.icon(
                onPressed: onViewReceipt,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('عرض الإيصال'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceSmMd),

              // ─── New receipt ───
              OutlinedButton.icon(
                onPressed: onNewReceipt,
                icon: const Icon(Icons.add),
                label: const Text('استلام جهاز آخر'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.buttonHeightLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceSmMd),

              // ─── Go home ───
              TextButton(
                onPressed: onGoHome,
                child: const Text('الرجوع للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
