// lib/features/settings/presentation/pages/theme_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_model.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_tokens.dart';

/// ═══════════════════════════════════════════════════════════
/// Theme Settings Page — تبديل الثيمات مع معاينة حية
/// ═══════════════════════════════════════════════════════════
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المظهر'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'إعادة للافتراضي',
            onPressed: () => _confirmReset(context, notifier),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(ThemeTokens.spaceMd),
        children: [
          // ─── 1) Color Schemes ───
          _SectionTitle(title: 'مجموعة الألوان'),
          _ColorSchemesGrid(
            selected: settings.colorScheme,
            onSelect: notifier.setColorScheme,
          ),

          const SizedBox(height: ThemeTokens.spaceLg),

          // ─── 2) Theme Mode ───
          _SectionTitle(title: 'وضع العرض'),
          _ThemeModeSelector(
            selected: settings.mode,
            onSelect: notifier.setMode,
          ),

          const SizedBox(height: ThemeTokens.spaceLg),

          // ─── 3) Theme Style ───
          _SectionTitle(title: 'نمط التصميم'),
          _ThemeStyleGrid(
            selected: settings.style,
            onSelect: notifier.setStyle,
          ),

          const SizedBox(height: ThemeTokens.spaceLg),

          // ─── 4) Font Scale ───
          _SectionTitle(title: 'حجم الخط'),
          _FontScaleSelector(
            selected: settings.fontScale,
            onSelect: notifier.setFontScale,
          ),

          const SizedBox(height: ThemeTokens.spaceLg),

          // ─── 5) Corner Style ───
          _SectionTitle(title: 'شكل الحواف'),
          _CornerStyleSelector(
            selected: settings.cornerStyle,
            onSelect: notifier.setCornerStyle,
          ),

          // ─── 6) Glass Intensity (يظهر فقط لو Glass مختار) ───
          if (settings.style == ThemeStyle.glass) ...[
            const SizedBox(height: ThemeTokens.spaceLg),
            _SectionTitle(title: 'شدة الزجاج'),
            _GlassIntensitySelector(
              selected: settings.glassIntensity,
              onSelect: notifier.setGlassIntensity,
            ),
          ],

          const SizedBox(height: ThemeTokens.spaceXl),

          // ─── 7) Live Preview ───
          _SectionTitle(title: 'معاينة حية'),
          const _LivePreview(),

          const SizedBox(height: ThemeTokens.spaceXl),
        ],
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    ThemeNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة للافتراضي'),
        content:
            const Text('هل أنت متأكد من إعادة كل إعدادات المظهر للافتراضي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إعادة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      notifier.resetToDefaults();
    }
  }
}

// ═══════════════════════════════════════════════════════════
// Widgets مساعدة
// ═══════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeTokens.spaceSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 1) Color Schemes Grid
// ─────────────────────────────────────────────────────────

class _ColorSchemesGrid extends StatelessWidget {
  final ColorSchemeType selected;
  final ValueChanged<ColorSchemeType> onSelect;

  const _ColorSchemesGrid({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: ThemeTokens.spaceSm,
        mainAxisSpacing: ThemeTokens.spaceSm,
        childAspectRatio: 1.6,
      ),
      itemCount: ColorSchemeType.values.length,
      itemBuilder: (context, index) {
        final type = ColorSchemeType.values[index];
        final isSelected = type == selected;

        return InkWell(
          onTap: () => onSelect(type),
          borderRadius: ThemeTokens.radiusFrom(CornerStyle.rounded),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  type.seedColor,
                  type.seedColor.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: ThemeTokens.radiusFrom(CornerStyle.rounded),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(ThemeTokens.spaceSm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSelected)
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.check_circle, color: Colors.white),
                  ),
                Text(
                  type.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// 2) Theme Mode Selector
// ─────────────────────────────────────────────────────────

class _ThemeModeSelector extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onSelect;

  const _ThemeModeSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppThemeMode>(
      segments: const [
        ButtonSegment(
          value: AppThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text('فاتح'),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text('داكن'),
        ),
        ButtonSegment(
          value: AppThemeMode.system,
          icon: Icon(Icons.settings_suggest),
          label: Text('النظام'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onSelect(set.first),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 3) Theme Style Grid
// ─────────────────────────────────────────────────────────

class _ThemeStyleGrid extends StatelessWidget {
  final ThemeStyle selected;
  final ValueChanged<ThemeStyle> onSelect;

  const _ThemeStyleGrid({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ThemeStyle.values.map((style) {
        final isSelected = style == selected;
        final scheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.only(bottom: ThemeTokens.spaceSm),
          child: InkWell(
            onTap: () => onSelect(style),
            borderRadius: ThemeTokens.radiusFrom(CornerStyle.rounded),
            child: Container(
              padding: const EdgeInsets.all(ThemeTokens.spaceMd),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainer,
                borderRadius: ThemeTokens.radiusFrom(CornerStyle.rounded),
                border: Border.all(
                  color: isSelected ? scheme.primary : scheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color:
                        isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: ThemeTokens.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          style.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 4) Font Scale Selector
// ─────────────────────────────────────────────────────────

class _FontScaleSelector extends StatelessWidget {
  final FontScale selected;
  final ValueChanged<FontScale> onSelect;

  const _FontScaleSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<FontScale>(
      segments: FontScale.values
          .map(
            (s) => ButtonSegment(
              value: s,
              label: Text(s.label),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onSelect(set.first),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 5) Corner Style Selector
// ─────────────────────────────────────────────────────────

class _CornerStyleSelector extends StatelessWidget {
  final CornerStyle selected;
  final ValueChanged<CornerStyle> onSelect;

  const _CornerStyleSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CornerStyle.values.map((corner) {
        final isSelected = corner == selected;
        final scheme = Theme.of(context).colorScheme;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelect(corner),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: ThemeTokens.spaceMd),
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primaryContainer
                      : scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(corner.radius),
                  border: Border.all(
                    color: isSelected ? scheme.primary : scheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        borderRadius: BorderRadius.circular(corner.radius),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      corner.label,
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 6) Glass Intensity Selector
// ─────────────────────────────────────────────────────────

class _GlassIntensitySelector extends StatelessWidget {
  final GlassIntensity selected;
  final ValueChanged<GlassIntensity> onSelect;

  const _GlassIntensitySelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<GlassIntensity>(
      segments: GlassIntensity.values
          .map(
            (g) => ButtonSegment(
              value: g,
              label: Text(g.label),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onSelect(set.first),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 7) Live Preview
// ─────────────────────────────────────────────────────────

class _LivePreview extends ConsumerWidget {
  const _LivePreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(ThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: ThemeTokens.radiusFrom(settings.cornerStyle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(ThemeTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اسم العميل',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'iPhone 13 — شاشة مكسورة',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: ThemeTokens.spaceSm),
                  Row(
                    children: [
                      Chip(
                        label: const Text('قيد الإصلاح'),
                        avatar: Icon(
                          Icons.build,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: ThemeTokens.spaceSm),
                      Chip(
                        label: const Text('عاجل'),
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ThemeTokens.spaceSm),

          // Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('حفظ'),
                ),
              ),
              const SizedBox(width: ThemeTokens.spaceSm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('إلغاء'),
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeTokens.spaceSm),

          // TextField
          TextField(
            decoration: const InputDecoration(
              labelText: 'اسم العميل',
              hintText: 'أدخل الاسم...',
              prefixIcon: Icon(Icons.person),
            ),
          ),

          const SizedBox(height: ThemeTokens.spaceSm),

          // Switches
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('تفعيل الإشعارات'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
