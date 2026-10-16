// lib/features/settings/presentation/pages/whatsapp_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/settings_service.dart';
import '../../data/models/app_settings.dart';

/// ═══════════════════════════════════════════════════════════════
/// WhatsappSettingsPage — إعدادات الواتساب + قوالب الرسائل
/// ═══════════════════════════════════════════════════════════════
///
/// - رقم الواتساب الأساسي
/// - 6 قوالب رسائل قابلة للتعديل
/// - معاينة + استرجاع الافتراضي
///
class WhatsappSettingsPage extends ConsumerStatefulWidget {
  const WhatsappSettingsPage({super.key});

  @override
  ConsumerState<WhatsappSettingsPage> createState() =>
      _WhatsappSettingsPageState();
}

class _WhatsappSettingsPageState extends ConsumerState<WhatsappSettingsPage> {
  final _whatsappCtrl = TextEditingController();
  late Map<String, TextEditingController> _templateCtrls;

  bool _initialized = false;
  bool _isSaving = false;

  /// المتغيرات المتاحة في كل قالب
  static const Map<String, List<String>> _templatePlaceholders = {
    'welcome': [
      '{customer_name}',
      '{shop_name}',
      '{device_name}',
      '{receipt_number}',
      '{tracking_url}',
    ],
    'statusUpdate': [
      '{customer_name}',
      '{device_name}',
      '{status}',
      '{receipt_number}',
      '{notes}',
    ],
    'ready': [
      '{customer_name}',
      '{device_name}',
      '{amount}',
      '{receipt_number}',
      '{shop_name}',
    ],
    'delivered': [
      '{customer_name}',
      '{device_name}',
    ],
    'reminder': [
      '{customer_name}',
      '{device_name}',
      '{receipt_number}',
      '{shop_name}',
    ],
    'warranty': [
      '{customer_name}',
      '{device_name}',
      '{warranty_end}',
      '{receipt_number}',
    ],
  };

  static const Map<String, String> _templateLabels = {
    'welcome': 'رسالة الترحيب',
    'statusUpdate': 'تحديث الحالة',
    'ready': 'الجهاز جاهز',
    'delivered': 'تم التسليم',
    'reminder': 'تذكير',
    'warranty': 'الضمان',
  };

  @override
  void initState() {
    super.initState();
    _templateCtrls = {
      for (final key in _templateLabels.keys) key: TextEditingController(),
    };
  }

  @override
  void dispose() {
    _whatsappCtrl.dispose();
    for (final c in _templateCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  INIT FROM SETTINGS
  // ═══════════════════════════════════════════════════════════════

  void _initFromSettings(AppSettings settings) {
    if (_initialized) return;
    _initialized = true;

    _whatsappCtrl.text = settings.shopWhatsapp ?? '';

    final t = settings.whatsappTemplates;
    _templateCtrls['welcome']?.text = t.welcome;
    _templateCtrls['statusUpdate']?.text = t.statusUpdate;
    _templateCtrls['ready']?.text = t.ready;
    _templateCtrls['delivered']?.text = t.delivered;
    _templateCtrls['reminder']?.text = t.reminder;
    _templateCtrls['warranty']?.text = t.warranty;
  }

  // ═══════════════════════════════════════════════════════════════
  //  SAVE
  // ═══════════════════════════════════════════════════════════════

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final newTemplates = WhatsappTemplates(
      welcome: _templateCtrls['welcome']!.text,
      statusUpdate: _templateCtrls['statusUpdate']!.text,
      ready: _templateCtrls['ready']!.text,
      delivered: _templateCtrls['delivered']!.text,
      reminder: _templateCtrls['reminder']!.text,
      warranty: _templateCtrls['warranty']!.text,
    );

    final notifier = ref.read(appSettingsNotifierProvider.notifier);
    final success = await notifier.patch(
      (s) => s.copyWith(
        shopWhatsapp: _whatsappCtrl.text.trim().isEmpty
            ? null
            : _whatsappCtrl.text.trim(),
        whatsappTemplates: newTemplates,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      _showSnack('تم حفظ إعدادات الواتساب ✅', isError: false);
    } else {
      _showSnack('فشل الحفظ. حاول مرة أخرى.', isError: true);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  RESET TEMPLATE
  // ═══════════════════════════════════════════════════════════════

  void _resetTemplate(String key) {
    switch (key) {
      case 'welcome':
        _templateCtrls['welcome']!.text = WhatsappTemplates.defaultWelcome;
        break;
      case 'statusUpdate':
        _templateCtrls['statusUpdate']!.text =
            WhatsappTemplates.defaultStatusUpdate;
        break;
      case 'ready':
        _templateCtrls['ready']!.text = WhatsappTemplates.defaultReady;
        break;
      case 'delivered':
        _templateCtrls['delivered']!.text = WhatsappTemplates.defaultDelivered;
        break;
      case 'reminder':
        _templateCtrls['reminder']!.text = WhatsappTemplates.defaultReminder;
        break;
      case 'warranty':
        _templateCtrls['warranty']!.text = WhatsappTemplates.defaultWarranty;
        break;
    }
    _showSnack('تم استرجاع القالب الافتراضي', isError: false);
  }

  // ═══════════════════════════════════════════════════════════════
  //  PREVIEW
  // ═══════════════════════════════════════════════════════════════

  void _showPreview(String key) {
    final raw = _templateCtrls[key]!.text;
    final example = _fillExample(raw);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_templateLabels[key] ?? ''),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spaceSmMd),
            decoration: BoxDecoration(
              color: Theme.of(ctx)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              example,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _fillExample(String template) {
    var result = template;
    const examples = {
      '{customer_name}': 'أحمد محمد',
      '{shop_name}': 'ورشة النور',
      '{device_name}': 'iPhone 13 Pro',
      '{receipt_number}': 'RCP-20261017-0001',
      '{tracking_url}': 'https://fixhub.app/track/abc123',
      '{status}': 'قيد الإصلاح',
      '{notes}': 'تم استبدال الشاشة',
      '{amount}': '1,500 ج.م',
      '{warranty_end}': '17/01/2027',
    };
    examples.forEach((k, v) {
      result = result.replaceAll(k, v);
    });
    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  //  SNACK
  // ═══════════════════════════════════════════════════════════════

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
        title: const Text('إعدادات الواتساب'),
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
          return _buildBody(context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('فشل التحميل: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxFormWidth * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ═══ Info Card ═══
                _buildInfoCard(context),
                const SizedBox(height: AppSizes.spaceLg),

                // ═══ رقم الواتساب ═══
                _sectionTitle(context, 'رقم الواتساب', Icons.chat),
                const SizedBox(height: AppSizes.spaceSm),
                TextField(
                  controller: _whatsappCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم واتساب الورشة',
                    hintText: '01xxxxxxxxx',
                    helperText: 'يُستخدم في زر "إرسال واتساب" من صفحة الإيصال',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceLg),

                // ═══ القوالب ═══
                _sectionTitle(
                  context,
                  'قوالب الرسائل',
                  Icons.text_snippet_outlined,
                ),
                const SizedBox(height: AppSizes.spaceSm),
                ..._templateLabels.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSizes.spaceSm,
                    ),
                    child: _buildTemplateTile(e.key, e.value),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceXl),

                // ═══ Save Button ═══
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
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  TEMPLATE TILE (ExpansionTile)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTemplateTile(String key, String label) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholders = _templatePlaceholders[key] ?? [];

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          child: Icon(
            _iconForTemplate(key),
            size: AppSizes.iconSm,
            color: scheme.primary,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.all(AppSizes.spaceSmMd),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ──── Placeholders chips ────
          Wrap(
            spacing: AppSizes.spaceXs,
            runSpacing: AppSizes.spaceXs,
            children: placeholders
                .map(
                  (p) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spaceSm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSizes.spaceSmMd),

          // ──── Template editor ────
          TextField(
            controller: _templateCtrls[key],
            maxLines: 6,
            minLines: 4,
            style: const TextStyle(fontSize: 13, height: 1.5),
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              contentPadding: const EdgeInsets.all(AppSizes.spaceSmMd),
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),

          // ──── Actions ────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _resetTemplate(key),
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('استرجاع الافتراضي'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeightMd),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _showPreview(key),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('معاينة'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeightMd),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForTemplate(String key) {
    switch (key) {
      case 'welcome':
        return Icons.waving_hand_outlined;
      case 'statusUpdate':
        return Icons.update;
      case 'ready':
        return Icons.check_circle_outline;
      case 'delivered':
        return Icons.local_shipping_outlined;
      case 'reminder':
        return Icons.notifications_none;
      case 'warranty':
        return Icons.verified_outlined;
      default:
        return Icons.message_outlined;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconXs, color: scheme.primary),
        const SizedBox(width: AppSizes.spaceXs),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

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
              'النصوص بين { } يتم استبدالها تلقائياً ببيانات العميل والجهاز',
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
}
