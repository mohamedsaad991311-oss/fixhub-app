// lib/features/auth/presentation/pages/signup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

// ═══════════════════════════════════════════════════════════════
//  SIGNUP PAGE
// ═══════════════════════════════════════════════════════════════

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  // ─── Form ───
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ─── Local State ───
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  HANDLERS
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_agreeToTerms) {
      _showError('يجب الموافقة على الشروط والأحكام');
      return;
    }

    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          tenantName: _shopNameController.text.trim(),
          createTenant: true, // دايماً ورشة جديدة
        );

    if (!mounted) return;

    if (success) {
      // امسح cache الإعدادات عشان يقرأ من Supabase
      ref.read(settingsServiceProvider).clearCache();
      context.go(RouteNames.home);
    }
    // لو فشل → الخطأ في الـ state
  }

  void _handleLogin() {
    context.push(RouteNames.login);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final state = authState.valueOrNull;
    final isLoading = state?.isLoading ?? false;
    final errorMessage = state?.errorMessage;

    return AuthScaffold(
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header ───
            const AuthHeader(
              title: 'أنشئ حسابك',
              subtitle: 'ابدأ إدارة ورشتك في دقائق',
              icon: Icons.person_add_alt_1_outlined,
            ),

            // ─── Error Banner ───
            if (errorMessage != null && errorMessage.isNotEmpty) ...[
              AuthErrorBanner(
                message: errorMessage,
                onDismiss: () => ref.read(authProvider.notifier).clearError(),
              ),
              const SizedBox(height: AppSizes.spaceMd),
            ],

            // ─── Shop Name ───
            AuthTextField(
              controller: _shopNameController,
              label: 'اسم الورشة',
              hint: 'مثال: ورشة النور',
              prefixIcon: Icons.store_outlined,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              validator: (v) => Validators.required(v, fieldName: 'اسم الورشة'),
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Full Name ───
            AuthTextField(
              controller: _fullNameController,
              label: 'الاسم الكامل',
              hint: 'مثال: أحمد محمود',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
              autofillHints: const [AutofillHints.name],
              validator: Validators.name,
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Email ───
            AuthTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'example@mail.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Phone ───
            AuthTextField(
              controller: _phoneController,
              label: 'رقم التليفون',
              hint: '01012345678',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: Validators.phone,
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Password ───
            AuthTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: AppSizes.iconSm,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Confirm Password ───
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              prefixIcon: Icons.lock_reset_outlined,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              onSubmitted: (_) => _handleSignup(),
              validator: (v) => Validators.confirmPassword(
                v,
                _passwordController.text,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: AppSizes.iconSm,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // ─── Terms Checkbox ───
            InkWell(
              onTap: isLoading
                  ? null
                  : () => setState(() => _agreeToTerms = !_agreeToTerms),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spaceXs,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _agreeToTerms = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    const Expanded(
                      child: Text(
                        'أوافق على الشروط والأحكام وسياسة الخصوصية',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceLg),

            // ─── Signup Button ───
            AuthButton(
              label: 'إنشاء الحساب',
              onPressed: _handleSignup,
              isLoading: isLoading,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // ─── Login Link ───
            AuthFooterLink(
              question: 'لديك حساب بالفعل؟',
              actionText: 'تسجيل الدخول',
              onTap: isLoading ? () {} : _handleLogin,
            ),
          ],
        ),
      ),
    );
  }
}
