// lib/features/auth/presentation/pages/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

// ═══════════════════════════════════════════════════════════════
//  FORGOT PASSWORD PAGE
// ═══════════════════════════════════════════════════════════════

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // ─── Local State ───
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  HANDLERS
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleSendReset() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(authProvider.notifier)
        .resetPassword(_emailController.text.trim());

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _emailSent = success;
      if (!success) {
        _errorMessage = 'فشل إرسال الرابط. تحقق من الإيميل وحاول مرة أخرى.';
      }
    });
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.login);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      onBack: _handleBack,
      child: _emailSent ? _buildSuccessState() : _buildFormState(),
    );
  }

  // ─── Success State ───
  Widget _buildSuccessState() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Success Icon ───
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 56,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.spaceLg),

        // ─── Title ───
        Text(
          'راجع إيميلك',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.spaceMd),

        // ─── Description ───
        Text(
          'أرسلنا رابط استعادة كلمة المرور إلى:',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.spaceSm),

        // ─── Email ───
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceMd,
            vertical: AppSizes.spaceSmMd,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Text(
            _emailController.text.trim(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: AppSizes.spaceMd),

        Text(
          'افتح الرابط في الإيميل لتعيين كلمة مرور جديدة.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),

        const SizedBox(height: AppSizes.spaceXl),

        // ─── Resend Button ───
        AuthButton(
          label: 'إعادة الإرسال',
          icon: Icons.refresh,
          variant: AuthButtonVariant.outlined,
          onPressed: _isLoading ? null : _handleSendReset,
          isLoading: _isLoading,
        ),
        const SizedBox(height: AppSizes.spaceSmMd),

        // ─── Back to Login ───
        AuthButton(
          label: 'العودة لتسجيل الدخول',
          icon: Icons.arrow_back,
          onPressed: _handleBack,
        ),
      ],
    );
  }

  // ─── Form State ───
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───
          const AuthHeader(
            title: 'نسيت كلمة المرور؟',
            subtitle: 'أدخل بريدك الإلكتروني وسنرسل لك رابط للاستعادة',
            icon: Icons.lock_reset_outlined,
          ),

          // ─── Error Banner ───
          if (_errorMessage != null) ...[
            AuthErrorBanner(
              message: _errorMessage!,
              onDismiss: () => setState(() => _errorMessage = null),
            ),
            const SizedBox(height: AppSizes.spaceMd),
          ],

          // ─── Email ───
          AuthTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            hint: 'example@mail.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            enabled: !_isLoading,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
            onSubmitted: (_) => _handleSendReset(),
          ),

          const SizedBox(height: AppSizes.spaceLg),

          // ─── Send Button ───
          AuthButton(
            label: 'إرسال رابط الاستعادة',
            icon: Icons.send_outlined,
            onPressed: _handleSendReset,
            isLoading: _isLoading,
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // ─── Back to Login ───
          AuthFooterLink(
            question: 'تتذكر كلمة المرور؟',
            actionText: 'سجّل دخولك',
            onTap: _isLoading ? () {} : _handleBack,
          ),
        ],
      ),
    );
  }
}
