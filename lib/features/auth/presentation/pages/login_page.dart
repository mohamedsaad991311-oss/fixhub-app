// lib/features/auth/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/pin_lock_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/identifier_field.dart';

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

  /// آخر قيمة identifier (إيميل أو تليفون E.164)
  IdentifierValue? _identifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
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

    final password = _passwordController.text;

    final identifier = _identifier?.value ?? _identifierController.text.trim();

    if (identifier.isEmpty) return;

    final success = await ref.read(authProvider.notifier).signIn(
          identifier: identifier,
          password: password,
        );

    if (!mounted) return;

    if (success) {
      final pin = ref.read(pinLockServiceProvider);
      await pin.resetAttempts();

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) context.go(RouteNames.home);
    }
  }

  Future<void> _handleBiometric() async {
    final l10n = context.l10n;
    setState(() => _isBiometricLoading = true);

    try {
      final biometric = ref.read(biometricServiceProvider);
      final result = await biometric.authenticate(reason: l10n.appTitle);

      if (!mounted) return;

      if (result.isSuccess) {
        final auth = ref.read(authProvider.notifier);
        await auth.refresh();

        if (!mounted) return;

        final current = ref.read(authProvider).valueOrNull;
        if (current?.isAuthenticated ?? false) {
          context.go(RouteNames.home);
        } else {
          _showError(l10n.sessionExpired);
        }
      } else if (result != BiometricResult.cancelled) {
        _showError(result.messageAr);
      }
    } catch (e) {
      if (mounted) _showError(context.l10n.biometricFailed);
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
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authProvider);
    final state = authState.valueOrNull;
    final isLoading = state?.isLoading ?? false;
    final errorMessage = state?.errorMessage;
    final deviceBlocked = state?.deviceBlockedInfo;

    final settingsAsync = ref.watch(appSettingsProvider);
    final shopName = settingsAsync.valueOrNull?.shopName ?? l10n.appTitle;
    final shopLogo = settingsAsync.valueOrNull?.shopLogoUrl;

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
            // ─── Language Toggle ───
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _LanguageButton(enabled: !isLoading),
            ),
            const SizedBox(height: AppSizes.spaceSm),

            // ─── Header ───
            AuthHeader(
              title: shopName,
              subtitle: l10n.loginSubtitle,
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

            // ─── Identifier (Email OR Phone Toggle) ───
            IdentifierField(
              controller: _identifierController,
              initialType: IdentifierType.phone,
              enabled: !isLoading,
              onChanged: (v) => setState(() => _identifier = v),
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // ─── Password ───
            AuthTextField(
              controller: _passwordController,
              label: l10n.password,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              enabled: !isLoading,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _handleLogin(),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.enterPassword;
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
                          Flexible(
                            child: Text(
                              l10n.rememberMe,
                              style: const TextStyle(fontSize: 13),
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
                  child: Text(
                    l10n.forgotPassword,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceLg),

            // ─── Login Button ───
            AuthButton(
              label: l10n.login,
              onPressed: _handleLogin,
              isLoading: isLoading,
            ),

            // ─── Biometric + PIN ───
            if (_biometricAvailable || _pinAvailable) ...[
              const SizedBox(height: AppSizes.spaceLg),
              AuthDivider(label: l10n.or),
              const SizedBox(height: AppSizes.spaceLg),
              Row(
                children: [
                  if (_biometricAvailable)
                    Expanded(
                      child: AuthIconButton(
                        icon: Icons.fingerprint,
                        label: l10n.biometric,
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
                        label: l10n.pinCode,
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
              question: l10n.noAccount,
              actionText: l10n.signupNow,
              onTap: isLoading ? () {} : _handleSignup,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LANGUAGE TOGGLE BUTTON
// ═══════════════════════════════════════════════════════════════

class _LanguageButton extends ConsumerWidget {
  const _LanguageButton({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Tooltip(
      message: l10n.language,
      child: TextButton.icon(
        onPressed: enabled
            ? () => ref.read(localeProvider.notifier).toggleLocale()
            : null,
        icon: Icon(
          Icons.translate,
          size: AppSizes.iconSm,
        ),
        label: Text(
          isArabic ? l10n.english : l10n.arabic,
          style: const TextStyle(fontSize: 13),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceSm,
            vertical: AppSizes.spaceXs,
          ),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DEVICE BLOCKED PAGE
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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Text(
            l10n.deviceBlockedTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text(
            l10n.deviceBlockedMessage,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.spaceXl),
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
                      l10n.currentDevice,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceSmMd),
                _InfoRow(
                  label: l10n.device,
                  value: info.blockedByName ?? l10n.unknownDevice,
                ),
                if (info.blockedByPlatform != null)
                  _InfoRow(
                    label: l10n.platform,
                    value: info.blockedByPlatform!.toUpperCase(),
                  ),
                if (info.blockedByLastSeen != null)
                  _InfoRow(
                    label: l10n.lastSeen,
                    value: _formatDate(context, info.blockedByLastSeen!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spaceXl),
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
                    l10n.contactAdminHint,
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
          AuthButton(
            label: l10n.contactAdmin,
            icon: Icons.chat_outlined,
            variant: AuthButtonVariant.outlined,
            onPressed: () => _contactAdmin(context, l10n),
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          AuthButton(
            label: l10n.tryAgain,
            icon: Icons.refresh,
            onPressed: onTryAgain,
          ),
        ],
      ),
    );
  }

  void _contactAdmin(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.contactAdminHint),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
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
