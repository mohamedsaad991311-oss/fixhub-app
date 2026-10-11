// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/pin_lock_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

// ═══════════════════════════════════════════════════════════════
//  LOGIN PAGE
// ═══════════════════════════════════════════════════════════════

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // ─── Form ───
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  // ─── Local State ───
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _biometricAvailable = false;
  bool _pinAvailable = false;
  bool _isBiometricLoading = false;
  bool _isPinLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthOptions();
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  INIT CHECKS
  // ─────────────────────────────────────────────────────────────

  Future<void> _checkAuthOptions() async {
    try {
      final biometric = ref.read(biometricServiceProvider);
      final pin = ref.read(pinLockServiceProvider);

      final bioReady = await biometric.isReady();
      final pinSet = await pin.hasPin();
      final pinEnabled = await pin.isEnabled();

      if (mounted) {
        setState(() {
          _biometricAvailable = bioReady;
          _pinAvailable = pinSet && pinEnabled;
        });
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  //  HANDLERS
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    // ملاحظة: signIn بيدعم إيميل أو تليفون
    final success = await ref.read(authProvider.notifier).signIn(
          email: identifier,
          password: password,
        );

    if (!mounted) return;

    if (success) {
      final pin = ref.read(pinLockServiceProvider);
      await pin.resetAttempts();
      if (mounted) context.go(RouteNames.home);
    }
  }

  Future<void> _handleBiometric() async {
    setState(() => _isBiometricLoading = true);

    try {
      final biometric = ref.read(biometricServiceProvider);
      final result = await biometric.authenticate(reason: 'افتح FixHub');

      if (!mounted) return;

      if (result.isSuccess) {
        final auth = ref.read(authProvider.notifier);
        await auth.refresh();

        if (!mounted) return;

        final current = ref.read(authProvider).valueOrNull;
        if (current?.isAuthenticated ?? false) {
          context.go(RouteNames.home);
        } else {
          _showError('انتهت الجلسة. الرجاء تسجيل الدخول بالإيميل أو التليفون.');
        }
      } else if (result != BiometricResult.cancelled) {
        _showError(result.messageAr);
      }
    } catch (e) {
      if (mounted) _showError('فشل التحقق بالبصمة');
    } finally {
      if (mounted) setState(() => _isBiometricLoading = false);
    }
  }

  Future<void> _handlePin() async {
    setState(() => _isPinLoading = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _isPinLoading = false);
    context.push(RouteNames.pinLock);
  }

  void _handleForgotPassword() {
    context.push(RouteNames.forgotPassword);
  }

  void _handleSignup() {
    context.push(RouteNames.signup);
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
  //─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final state = authState.valueOrNull;
    final isLoading = state?.isLoading ?? false;
    final errorMessage = state?.errorMessage;
    final deviceBlocked = state?.deviceBlockedInfo;

    // بيانات الورشة
    final settingsAsync = ref.watch(appSettingsProvider);
    final shopName = settingsAsync.valueOrNull?.shopName ?? 'FixHub';
    final shopLogo = settingsAsync.valueOrNull?.shopLogoUrl;

    // ─── لو الجهاز ممنوع → شاشة تحذير ───
    if (deviceBlocked != null) {
      return _DeviceBlockedPage(
        info: deviceBlocked,
        onTryAgain: () {
          ref.read(authProvider.notifier).clearError();
        },
      );
    }

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header ───
            AuthHeader(
              title: shopName,
              subtitle: 'سجّل دخولك للمتابعة',
              logoUrl: shopLogo,
              icon: Icons.build_circle_outlined,
            ),

            // ─── Error Banner ───
            if (errorMessage != null && errorMessage.isNotEmpty) ...[
              AuthErrorBanner(
                message: errorMessage,
                onDismiss: () => ref.read(authProvider.notifier).clearError(),
              ),
              const SizedBox(height: AppSizes.spaceMd),
            ],

            // ─── Identifier (Email or Phone) ───
            AuthTextField(
              controller: _identifierController,
              label: 'البريد الإلكتروني أو رقم التليفون',
              hint: 'example@mail.com أو 01012345678',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.telephoneNumber,
              ],
              validator: _validateIdentifier,
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Password ───
            AuthTextField(
              controller: _passwordController,
              label: 'كلمة المرور',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _handleLogin(),
              validator: (v) {
                if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                return null;
              },
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

            const SizedBox(height: AppSizes.spaceSm),

            // ─── Remember + Forgot ───
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isLoading
                        ? null
                        : () => setState(() => _rememberMe = !_rememberMe),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.spaceXs,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: isLoading
                                  ? null
                                  : (v) => setState(
                                        () => _rememberMe = v ?? false,
                                      ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceXs),
                          const Flexible(
                            child: Text(
                              'تذكرني',
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : _handleForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceLg),

            // ─── Login Button ───
            AuthButton(
              label: 'تسجيل الدخول',
              onPressed: _handleLogin,
              isLoading: isLoading,
            ),

            // ─── Biometric + PIN ───
            if (_biometricAvailable || _pinAvailable) ...[
              const SizedBox(height: AppSizes.spaceLg),
              const AuthDivider(label: 'أو'),
              const SizedBox(height: AppSizes.spaceLg),
              Row(
                children: [
                  if (_biometricAvailable)
                    Expanded(
                      child: AuthIconButton(
                        icon: Icons.fingerprint,
                        label: 'البصمة',
                        onPressed: _handleBiometric,
                        isLoading: _isBiometricLoading,
                      ),
                    ),
                  if (_biometricAvailable && _pinAvailable)
                    const SizedBox(width: AppSizes.spaceSmMd),
                  if (_pinAvailable)
                    Expanded(
                      child: AuthIconButton(
                        icon: Icons.dialpad,
                        label: 'رمز PIN',
                        onPressed: _handlePin,
                        isLoading: _isPinLoading,
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: AppSizes.spaceXl),

            // ─── Signup Link ───
            AuthFooterLink(
              question: 'ليس لديك حساب؟',
              actionText: 'سجّل الآن',
              onTap: isLoading ? () {} : _handleSignup,
            ),
          ],
        ),
      ),
    );
  }

  /// Validation للـ identifier (إيميل أو تليفون)
  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل البريد الإلكتروني أو رقم التليفون';
    }

    final trimmed = value.trim();

    // إيميل
    if (trimmed.contains('@')) {
      return Validators.email(trimmed);
    }

    // تليفون
    final cleaned = trimmed.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^[\+]?\d{8,15}$').hasMatch(cleaned)) {
      return 'أدخل بريد إلكتروني أو رقم تليفون صحيح';
    }

    return null;
  }
}

// ═══════════════════════════════════════════════════════════════
//  DEVICE BLOCKED PAGE — شاشة الجهاز المحجوب
// ═══════════════════════════════════════════════════════════════

class _DeviceBlockedPage extends StatelessWidget {
  const _DeviceBlockedPage({
    required this.info,
    required this.onTryAgain,
  });

  final DeviceBlockedInfo info;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Icon ───
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phonelink_lock_outlined,
                size: 56,
                color: scheme.error,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceLg),

          // ─── Title ───
          Text(
            'الحساب مرتبط بجهاز آخر',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),

          // ─── Description ───
          Text(
            'هذا الحساب نشط على جهاز آخر. لحماية حسابك، يُسمح بالدخول من جهاز واحد فقط.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: AppSizes.spaceXl),

          // ─── Device Info Card ───
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceMd),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: scheme.outlineVariant,
                width: AppSizes.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: AppSizes.iconSm,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSizes.spaceSm),
                    Text(
                      'الجهاز المسجّل حالياً',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceSmMd),
                _InfoRow(
                  label: 'الجهاز',
                  value: info.blockedByName ?? 'غير معروف',
                ),
                if (info.blockedByPlatform != null)
                  _InfoRow(
                    label: 'المنصة',
                    value: info.blockedByPlatform!.toUpperCase(),
                  ),
                if (info.blockedByLastSeen != null)
                  _InfoRow(
                    label: 'آخر ظهور',
                    value: _formatDate(info.blockedByLastSeen!),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spaceXl),

          // ─── Tip ───
          Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: AppSizes.iconSm,
                  color: scheme.primary,
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    'تواصل مع مدير الورشة لإلغاء تفعيل الجهاز القديم.',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.spaceXl),

          // ─── Contact Admin Button ───
          AuthButton(
            label: 'تواصل مع المدير',
            icon: Icons.chat_outlined,
            variant: AuthButtonVariant.outlined,
            onPressed: () => _contactAdmin(context),
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          // ─── Try Again Button ───
          AuthButton(
            label: 'محاولة الدخول مرة أخرى',
            icon: Icons.refresh,
            onPressed: onTryAgain,
          ),
        ],
      ),
    );
  }

  void _contactAdmin(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تواصل مع مدير الورشة على الرقم المسجّل في الإعدادات'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${dt.year}/${dt.month}/${dt.day}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
