// lib/features/auth/presentation/widgets/auth_widgets.dart

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

// ═══════════════════════════════════════════════════════════════
//  AUTH SCAFFOLD — غلاف موحّد لكل صفحات Auth
// ═══════════════════════════════════════════════════════════════

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    this.showBackButton = false,
    this.onBack,
    super.key,
  });

  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // ─── خلفية زخرفية ───
          Positioned(
            top: -100,
            right: -100,
            child: _DecorativeCircle(
              size: 300,
              color: scheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: _DecorativeCircle(
              size: 350,
              color: scheme.secondary.withValues(alpha: isDark ? 0.10 : 0.06),
            ),
          ),

          // ─── المحتوى ───
          SafeArea(
            child: Stack(
              children: [
                if (showBackButton)
                  Positioned(
                    top: AppSizes.spaceSm,
                    left: AppSizes.spaceSm,
                    child: IconButton(
                      onPressed: onBack ?? () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spaceLg,
                      vertical: AppSizes.spaceLg,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.maxFormWidth,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH HEADER — Logo + Title + Subtitle
// ═══════════════════════════════════════════════════════════════

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    this.subtitle,
    this.logo,
    this.logoUrl,
    this.icon = Icons.lock_outline,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? logo;
  final String? logoUrl;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _buildLogo(context, scheme),
        const SizedBox(height: AppSizes.spaceLg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.spaceSm),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: AppSizes.spaceXl),
      ],
    );
  }

  Widget _buildLogo(BuildContext context, ColorScheme scheme) {
    if (logo != null) return logo!;

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: Image.network(
          logoUrl!,
          width: AppSizes.avatarXl,
          height: AppSizes.avatarXl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultLogo(scheme),
        ),
      );
    }

    return _defaultLogo(scheme);
  }

  Widget _defaultLogo(ColorScheme scheme) {
    return Container(
      width: AppSizes.avatarXl,
      height: AppSizes.avatarXl,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: AppSizes.iconXl,
        color: scheme.onPrimary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH TEXT FIELD
// ═══════════════════════════════════════════════════════════════

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.autofillHints,
    this.maxLength,
    this.textDirection,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      enabled: enabled,
      autofillHints: autofillHints,
      maxLength: maxLength,
      textDirection: textDirection,
      style: TextStyle(
        fontSize: 15,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, size: AppSizes.iconSm) : null,
        suffixIcon: suffixIcon,
        counterText: '',
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: AppSizes.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: AppSizes.borderNormal,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: AppSizes.borderMedium,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceMd,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH BUTTON — Filled / Outlined
// ═══════════════════════════════════════════════════════════════

class AuthButton extends StatelessWidget {
  const AuthButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AuthButtonVariant.filled,
    this.width,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AuthButtonVariant variant;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm),
                const SizedBox(width: AppSizes.spaceSm),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final borderRadius = BorderRadius.circular(AppSizes.radiusLg);
    const height = AppSizes.buttonHeightLg;

    if (variant == AuthButtonVariant.filled) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(
            color: scheme.primary.withValues(alpha: 0.4),
            width: AppSizes.borderNormal,
          ),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}

enum AuthButtonVariant { filled, outlined }

// ═══════════════════════════════════════════════════════════════
//  AUTH DIVIDER
// ═══════════════════════════════════════════════════════════════

class AuthDivider extends StatelessWidget {
  const AuthDivider({this.label = 'أو', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final divider = Expanded(
      child: Divider(
        color: scheme.outlineVariant,
        thickness: AppSizes.dividerThickness,
      ),
    );

    return Row(
      children: [
        divider,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMd),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        divider,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH ERROR BANNER
// ═══════════════════════════════════════════════════════════════

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    required this.message,
    this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSmMd),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.3),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: scheme.error,
            size: AppSizes.iconSm,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 18),
              color: scheme.onErrorContainer,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH FOOTER LINK
// ═══════════════════════════════════════════════════════════════

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.question,
    required this.actionText,
    required this.onTap,
    super.key,
  });

  final String question;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSizes.spaceXs),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AUTH ICON BUTTON (Biometric / PIN)
// ═══════════════════════════════════════════════════════════════

class AuthIconButton extends StatelessWidget {
  const AuthIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMd,
          vertical: AppSizes.spaceSmMd,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            else
              Icon(icon, size: AppSizes.iconMd, color: scheme.primary),
            const SizedBox(width: AppSizes.spaceSm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
