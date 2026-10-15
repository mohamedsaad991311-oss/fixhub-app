// lib/shared/widgets/searchable_dropdown.dart

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// ═══════════════════════════════════════════════════════════
/// SearchableDropdown — Dropdown مع بحث + إدخال يدوي
/// ═══════════════════════════════════════════════════════════
///
/// المميزات:
/// - بحث بالكتابة (Autocomplete)
/// - إدخال يدوي لو القيمة مش في القائمة
/// - عرض الأيقونات/الأوصاف (اختياري)
/// - RTL-friendly
/// - Validator support
///
class SearchableDropdown<T> extends StatefulWidget {
  /// القائمة الكاملة
  final List<T> items;

  /// القيمة الحالية
  final T? value;

  /// لما القيمة تتغير
  final ValueChanged<T?>? onChanged;

  /// النص المعروض لكل item
  final String Function(T item) displayString;

  /// نص البحث (اختياري — يرجع الـ query)
  final String? Function(T item)? searchString;

  /// وصف إضافي (اختياري)
  final String? Function(T item)? subtitleString;

  /// أيقونة (اختياري)
  final IconData? Function(T item)? iconBuilder;

  /// Label الحقل
  final String label;

  /// Hint
  final String? hint;

  /// Validator
  final String? Function(T?)? validator;

  /// هل الحقل مطلوب؟
  final bool isRequired;

  /// تفعيل الإدخال اليدوي
  final bool allowManualInput;

  /// نص رسالة "قيمة جديدة"
  final String newValueLabel;

  /// Icon prefix
  final IconData? prefixIcon;

  /// تفعيل
  final bool enabled;

  /// لما المستخدم يدخل قيمة يدوية (يرجع النص)
  final ValueChanged<String>? onManualInput;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.displayString,
    required this.label,
    this.onChanged,
    this.searchString,
    this.subtitleString,
    this.iconBuilder,
    this.hint,
    this.validator,
    this.isRequired = false,
    this.allowManualInput = true,
    this.newValueLabel = 'إضافة قيمة جديدة',
    this.prefixIcon,
    this.enabled = true,
    this.onManualInput,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _closeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // تأخير بسيط للسماح بالـ tap على overlay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _closeOverlay();
        }
      });
    }
  }

  /// القائمة المفلترة
  List<T> get _filteredItems {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return widget.items;

    return widget.items.where((item) {
      final display = widget.displayString(item).toLowerCase();
      if (display.contains(q)) return true;
      if (widget.searchString != null) {
        final search = (widget.searchString!(item) ?? '').toLowerCase();
        if (search.contains(q)) return true;
      }
      return false;
    }).toList();
  }

  void _openOverlay() {
    if (_isOpen || !widget.enabled) return;
    _isOpen = true;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final availableBelow = screenHeight - offset.dy - size.height - 20;
    final maxHeight = availableBelow.clamp(150.0, 320.0);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildOverlayContent(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isOpen) {
      _isOpen = false;
      if (mounted) setState(() {});
    }
  }

  Widget _buildOverlayContent() {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filteredItems;
    final hasExactMatch = filtered.any(
      (item) =>
          widget.displayString(item).toLowerCase() ==
          _searchController.text.trim().toLowerCase(),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── القائمة ───
        Flexible(
          child: filtered.isEmpty && !widget.allowManualInput
              ? Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceMd),
                  child: Text(
                    'مفيش نتائج',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected = item == widget.value;
                    return _DropdownItem<T>(
                      item: item,
                      isSelected: isSelected,
                      displayString: widget.displayString,
                      subtitleString: widget.subtitleString,
                      iconBuilder: widget.iconBuilder,
                      onTap: () => _selectItem(item),
                      scheme: scheme,
                    );
                  },
                ),
        ),

        // ─── زر "إضافة قيمة جديدة" ───
        if (widget.allowManualInput &&
            _searchController.text.trim().isNotEmpty &&
            !hasExactMatch)
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: ListTile(
              dense: true,
              leading: Icon(Icons.add, size: 18, color: scheme.primary),
              title: Text(
                '${widget.newValueLabel}: "${_searchController.text.trim()}"',
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _submitManualInput(_searchController.text.trim()),
            ),
          ),
      ],
    );
  }

  void _selectItem(T item) {
    _searchController.clear();
    widget.onChanged?.call(item);
    _closeOverlay();
    _focusNode.unfocus();
  }

  void _submitManualInput(String value) {
    widget.onManualInput?.call(value);
    _searchController.clear();
    _closeOverlay();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _searchController,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onTap: _openOverlay,
          onChanged: (_) {
            if (!_isOpen) _openOverlay();
            setState(() {}); // إعادة بناء الـ overlay
            _overlayEntry?.markNeedsBuild();
          },
          validator: (_) {
            if (widget.validator == null) return null;
            return widget.validator!(widget.value);
          },
          decoration: InputDecoration(
            labelText: widget.isRequired ? '${widget.label} *' : widget.label,
            hintText: widget.value != null
                ? null
                : (widget.hint ?? 'اختر أو اكتب...'),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: AppSizes.iconSm)
                : null,
            suffixIcon: widget.value != null
                ? IconButton(
                    tooltip: 'مسح',
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: widget.enabled
                        ? () {
                            widget.onChanged?.call(null);
                            _searchController.clear();
                          }
                        : null,
                  )
                : Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: BorderSide(
                color: scheme.primary,
                width: AppSizes.borderMedium,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: BorderSide(color: scheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              borderSide: BorderSide(
                color: scheme.error,
                width: AppSizes.borderMedium,
              ),
            ),
          ),
        ),

        // ─── القيمة المختارة ───
        if (widget.value != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.iconBuilder?.call(widget.value as T) != null) ...[
                  Icon(
                    widget.iconBuilder!(widget.value as T),
                    size: 14,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  widget.displayString(widget.value as T),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  DROPDOWN ITEM
// ═══════════════════════════════════════════════════════════

class _DropdownItem<T> extends StatelessWidget {
  const _DropdownItem({
    required this.item,
    required this.isSelected,
    required this.displayString,
    required this.onTap,
    required this.scheme,
    this.subtitleString,
    this.iconBuilder,
  });

  final T item;
  final bool isSelected;
  final String Function(T) displayString;
  final String? Function(T)? subtitleString;
  final IconData? Function(T)? iconBuilder;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final subtitle = subtitleString?.call(item);
    final icon = iconBuilder?.call(item);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: AppSizes.spaceSm,
        ),
        color: isSelected
            ? scheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSizes.spaceSm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayString(item),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check, size: 18, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
