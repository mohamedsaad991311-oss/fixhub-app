// lib/features/settings/presentation/pages/shop_info_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/settings_service.dart';
import '../../data/models/app_settings.dart';

/// ═══════════════════════════════════════════════════════════════
/// ShopInfoPage — معلومات الورشة
/// ═══════════════════════════════════════════════════════════════
///
/// - اسم الورشة (إلزامي)
/// - تليفون الورشة
/// - واتساب الورشة
/// - عنوان الورشة
/// - رابط الشعار (URL)
///
class ShopInfoPage extends ConsumerStatefulWidget {
  const ShopInfoPage({super.key});

  @override
  ConsumerState<ShopInfoPage> createState() => _ShopInfoPageState();
}

class _ShopInfoPageState extends ConsumerState<ShopInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _logoCtrl;

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _whatsappCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _logoCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _addressCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  INIT FROM SETTINGS
  // ═══════════════════════════════════════════════════════════════

  void _initFromSettings(AppSettings settings) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = settings.shopName ?? '';
    _phoneCtrl.text = settings.shopPhone ?? '';
    _whatsappCtrl.text = settings.shopWhatsapp ?? '';
    _addressCtrl.text = settings.shopAddress ?? '';
    _logoCtrl.text = settings.shopLogoUrl ?? '';
  }

  // ═══════════════════════════════════════════════════════════════
  //  SAVE
  // ═══════════════════════════════════════════════════════════════

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final notifier = ref.read(appSettingsNotifierProvider.notifier);
    final success = await notifier.patch(
      (s) => s.copyWith(
        shopName: _nameCtrl.text.trim(),
        shopPhone:
            _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        shopWhatsapp: _whatsappCtrl.text.trim().isEmpty
            ? null
            : _whatsappCtrl.text.trim(),
        shopAddress:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        shopLogoUrl:
            _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      _showSnack('تم حفظ معلومات الورشة بنجاح ✅', isError: false);
    } else {
      _showSnack('فشل الحفظ. حاول مرة أخرى.', isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: isError ? scheme.error : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ═══════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات الورشة'),
        centerTitle: false,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(AppSizes.spaceSmMd),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'حفظ',
              onPressed: _save,
            ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          _initFromSettings(settings);
          return _buildForm(context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLg),
            child: Text(
              'فشل تحميل البيانات: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
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

                  // ──── اسم الورشة ────
                  _buildField(
                    controller: _nameCtrl,
                    label: 'اسم الورشة',
                    hint: 'مثال: ورشة النور للصيانة',
                    icon: Icons.store_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'اسم الورشة مطلوب'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.spaceSmMd),

                  // ──── تليفون ────
                  _buildField(
                    controller: _phoneCtrl,
                    label: 'تليفون الورشة',
                    hint: '01xxxxxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.spaceSmMd),

                  // ──── واتساب ────
                  _buildField(
                    controller: _whatsappCtrl,
                    label: 'واتساب الورشة',
                    hint: '01xxxxxxxxx',
                    icon: Icons.chat_outlined,
                    keyboardType: TextInputType.phone,
                    helper: 'الرقم المستخدم في رسائل الواتساب للعملاء',
                  ),
                  const SizedBox(height: AppSizes.spaceSmMd),

                  // ──── عنوان ────
                  _buildField(
                    controller: _addressCtrl,
                    label: 'عنوان الورشة',
                    hint: 'المحافظة، المدينة، الشارع...',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSizes.spaceSmMd),

                  // ──── رابط الشعار ────
                  _buildField(
                    controller: _logoCtrl,
                    label: 'رابط الشعار (URL)',
                    hint: 'https://...',
                    icon: Icons.image_outlined,
                    keyboardType: TextInputType.url,
                    helper: 'رفع صورة مباشر قادم قريباً — استخدم رابط مؤقتاً',
                  ),

                  const SizedBox(height: AppSizes.spaceXl),

                  // ──── Save Button ────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeightLg,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spaceXl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  WIDGETS
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
              'هذه البيانات تظهر في الفواتير ورسائل الواتساب للعملاء',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? helper,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        prefixIcon: Icon(icon),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }
}
