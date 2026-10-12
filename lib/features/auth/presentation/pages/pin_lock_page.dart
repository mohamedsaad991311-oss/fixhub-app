// lib/features/auth/presentation/pages/pin_lock_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/pin_lock_service.dart';
import '../providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════════
//  PIN LOCK PAGE
// ═══════════════════════════════════════════════════════════════

class PinLockPage extends ConsumerStatefulWidget {
  const PinLockPage({super.key});

  @override
  ConsumerState<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends ConsumerState<PinLockPage> {
  // ─── State ───
  String _pin = '';
  bool _isVerifying = false;
  bool _isLocked = false;
  int _remainingSeconds = 0;
  String? _errorMessage;
  bool _biometricAvailable = false;

  static const int _pinLength = 6;

  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────────────────────

  Future<void> _initState() async {
    // فحص القفل الحالي
    await _checkLockStatus();

    // فحص البصمة
    try {
      final biometric = ref.read(biometricServiceProvider);
      final ready = await biometric.isReady();
      if (mounted) setState(() => _biometricAvailable = ready);
    } catch (_) {}
  }

  Future<void> _checkLockStatus() async {
    final service = ref.read(pinLockServiceProvider);
    final locked = await service.isLocked();

    if (locked) {
      final seconds = await service.getRemainingLockSeconds();
      if (mounted) {
        setState(() {
          _isLocked = true;
          _remainingSeconds = seconds;
        });
        _startLockTimer();
      }
    } else {
      if (mounted) setState(() => _isLocked = false);
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _remainingSeconds = 0;
        });
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  PIN INPUT
  // ─────────────────────────────────────────────────────────────

  void _onKeyPress(String digit) {
    if (_isVerifying || _isLocked) return;
    if (_pin.length >= _pinLength) return;

    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit;
      _errorMessage = null;
    });

    if (_pin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_isVerifying || _isLocked) return;
    if (_pin.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onClear() {
    if (_isVerifying || _isLocked) return;
    setState(() {
      _pin = '';
      _errorMessage = null;
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  VERIFY
  // ─────────────────────────────────────────────────────────────

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);

    final service = ref.read(pinLockServiceProvider);
    final result = await service.verifyPin(_pin);

    if (!mounted) return;

    if (result.isSuccess) {
      HapticFeedback.mediumImpact();
      // نجح → ارجع لآخر شاشة أو home
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.home);
      }
      return;
    }

    // فشل
    HapticFeedback.heavyImpact();

    // حدّث المحاولات
    final remaining = await service.getRemainingAttempts();
    final locked = await service.isLocked();

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
      _pin = '';

      if (locked) {
        _isLocked = true;
      } else if (result == PinResult.locked) {
        _isLocked = true;
      } else {
        _errorMessage = _getErrorMessage(result, remaining);
      }
    });

    if (_isLocked) {
      final seconds = await service.getRemainingLockSeconds();
      if (mounted) {
        setState(() => _remainingSeconds = seconds);
        _startLockTimer();
      }
    }
  }

  String _getErrorMessage(PinResult result, int remaining) {
    if (result == PinResult.wrongPin) {
      if (remaining <= 1) {
        return 'رمز غير صحيح — محاولة واحدة متبقية!';
      }
      return 'رمز غير صحيح — $remaining محاولات متبقية';
    }
    return result.messageAr;
  }

  // ─────────────────────────────────────────────────────────────
  //  BIOMETRIC
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleBiometric() async {
    if (_isLocked) return;

    try {
      final biometric = ref.read(biometricServiceProvider);
      final result = await biometric.authenticate(reason: 'افتح FixHub');

      if (!mounted) return;

      if (result.isSuccess) {
        final service = ref.read(pinLockServiceProvider);
        await service.resetAttempts();
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.home);
        }
      } else if (result != BiometricResult.cancelled) {
        setState(() => _errorMessage = result.messageAr);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'فشل التحقق بالبصمة');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  FALLBACK — استخدم كلمة المرور
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleUsePassword() async {
    // سجّل خروج وأرجع للـ login
    await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  // ─────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceLg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // ─── Icon ───
                      _buildIcon(scheme),

                      const SizedBox(height: AppSizes.spaceLg),

                      // ─── Title ───
                      Text(
                        'أدخل رمز PIN',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spaceSm),

                      Text(
                        _isLocked
                            ? 'القفل مؤقت'
                            : 'رمزك المكوّن من $_pinLength أرقام',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: AppSizes.spaceXl),

                      // ─── PIN Dots ───
                      _buildPinDots(scheme),

                      const SizedBox(height: AppSizes.spaceMd),

                      // ─── Error / Lock message ───
                      _buildMessage(scheme),

                      const SizedBox(height: AppSizes.spaceLg),

                      // ─── Keypad ───
                      _buildKeypad(scheme),

                      const SizedBox(height: AppSizes.spaceMd),

                      // ─── Actions ───
                      _buildActions(scheme),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Icon ───
  Widget _buildIcon(ColorScheme scheme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: (_isLocked ? scheme.errorContainer : scheme.primaryContainer)
            .withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isLocked ? Icons.lock_clock : Icons.lock_outline,
        size: 40,
        color: _isLocked ? scheme.error : scheme.primary,
      ),
    );
  }

  // ─── PIN Dots ───
  Widget _buildPinDots(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _pin.length;
        final isActive = index == _pin.length && !_isLocked;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? scheme.primary : scheme.surfaceContainerHighest,
            border: Border.all(
              color: isActive ? scheme.primary : scheme.outlineVariant,
              width: isActive ? 2 : 1,
            ),
          ),
        );
      }),
    );
  }

  // ─── Message ───
  Widget _buildMessage(ColorScheme scheme) {
    if (_isLocked) {
      return Column(
        children: [
          Text(
            'الحساب مقفول مؤقتاً',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.error,
            ),
          ),
          const SizedBox(height: AppSizes.spaceXs),
          Text(
            'حاول بعد $_remainingSeconds ثانية',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceSm,
        ),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 18, color: scheme.error),
            const SizedBox(width: AppSizes.spaceSm),
            Flexible(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(height: 36);
  }

  // ─── Keypad ───
  Widget _buildKeypad(ColorScheme scheme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        children: [
          // 1 2 3
          Row(
            children: [
              _digitKey('1', scheme),
              _digitKey('2', scheme),
              _digitKey('3', scheme),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          // 4 5 6
          Row(
            children: [
              _digitKey('4', scheme),
              _digitKey('5', scheme),
              _digitKey('6', scheme),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          // 7 8 9
          Row(
            children: [
              _digitKey('7', scheme),
              _digitKey('8', scheme),
              _digitKey('9', scheme),
            ],
          ),
          const SizedBox(height: AppSizes.spaceSmMd),
          // biometric / 0 / backspace
          Row(
            children: [
              Expanded(
                child: _biometricAvailable
                    ? _iconKey(
                        Icons.fingerprint,
                        _handleBiometric,
                        scheme,
                      )
                    : const SizedBox(height: 60),
              ),
              _digitKey('0', scheme),
              Expanded(
                child: _iconKey(
                  Icons.backspace_outlined,
                  _onBackspace,
                  scheme,
                  onLongPress: _onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _digitKey(String digit, ColorScheme scheme) {
    final enabled = !_isVerifying && !_isLocked;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: _KeyButton(
          onTap: enabled ? () => _onKeyPress(digit) : null,
          scheme: scheme,
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: enabled ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconKey(
    IconData icon,
    VoidCallback? onTap,
    ColorScheme scheme, {
    VoidCallback? onLongPress,
  }) {
    final enabled = !_isVerifying && !_isLocked && onTap != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _KeyButton(
        onTap: enabled ? onTap : null,
        onLongPress: onLongPress,
        scheme: scheme,
        child: Icon(
          icon,
          size: 24,
          color: enabled ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // ─── Actions ───
  Widget _buildActions(ColorScheme scheme) {
    return Column(
      children: [
        // Biometric (لو مش في keypad)
        if (!_biometricAvailable)
          TextButton.icon(
            onPressed: _isLocked ? null : _handleBiometric,
            icon: const Icon(Icons.fingerprint, size: 20),
            label: const Text('استخدم البصمة'),
          ),

        // Forgot
        TextButton.icon(
          onPressed: _isLocked ? null : _handleUsePassword,
          icon: const Icon(Icons.lock_reset, size: 18),
          label: const Text(
            'استخدم كلمة المرور',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  KEY BUTTON
// ═══════════════════════════════════════════════════════════════

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.child,
    required this.scheme,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final ColorScheme scheme;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? scheme.surfaceContainerHighest.withValues(alpha: 0.4)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: child,
        ),
      ),
    );
  }
}
