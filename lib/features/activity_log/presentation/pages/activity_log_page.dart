// lib/features/activity_log/presentation/pages/activity_log_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/activity_log_service.dart';
import '../providers/activity_log_provider.dart';
import '../widgets/activity_log_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// ActivityLogPage — صفحة سجل النشاط
/// ═══════════════════════════════════════════════════════════════
///
/// - عرض كل الأنشطة
/// - فلترة: إجراء + نوع كيان + فترة
/// - بحث في الوصف
/// - Pagination
///
class ActivityLogPage extends ConsumerStatefulWidget {
  const ActivityLogPage({super.key});

  @override
  ConsumerState<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends ConsumerState<ActivityLogPage> {
  late final TextEditingController _searchCtrl;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    Future.microtask(() {
      ref.read(activityLogProvider.notifier).load();
    });

    // تحميل تلقائي عند الوصول لآخر القائمة
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// تحميل المزيد عند الوصول لآخر القائمة
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(activityLogProvider.notifier).loadMore();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  بناء الصفحة
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityLogProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل النشاط'),
        centerTitle: false,
        actions: [
          // زر مسح الفلاتر
          if (state.hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'مسح الفلاتر',
              onPressed: () {
                _searchCtrl.clear();
                ref.read(activityLogProvider.notifier).clearFilters();
              },
            ),
          // زر التحديث
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(activityLogProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(activityLogProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final padding = isWide ? AppSizes.spaceLg : AppSizes.spaceMd;

            return CustomScrollView(
              controller: _scrollCtrl,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ─── الفلاتر + البحث ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding,
                      padding,
                      padding,
                      AppSizes.spaceSm,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFiltersBar(context, state, scheme),
                          const SizedBox(height: AppSizes.spaceSmMd),
                          _buildSearchBar(state, scheme),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── المحتوى ───
                if (state.isLoading && state.logs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.logs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, scheme, state),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    sliver: SliverList.separated(
                      itemCount: state.logs.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSizes.spaceSm),
                      itemBuilder: (context, index) {
                        // زر "تحميل المزيد"
                        if (index == state.logs.length) {
                          return _buildLoadMore(context, state, scheme);
                        }

                        final log = state.logs[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppSizes.maxContentWidth,
                            ),
                            child: ActivityLogCard(
                              log: log,
                              onTap: log.metadata.isNotEmpty
                                  ? () => _showDetails(context, log)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // مسافة سفلية
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.spaceXl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  شريط الفلاتر
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFiltersBar(
    BuildContext context,
    ActivityLogState state,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceSm),
      decoration: BoxDecoration(
        color:
            isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderNormal,
        ),
      ),
      child: Wrap(
        spacing: AppSizes.spaceSm,
        runSpacing: AppSizes.spaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // ─── فلتر الإجراء ───
          _buildDropdown<String>(
            context,
            scheme,
            icon: Icons.flash_on_outlined,
            hint: 'كل الإجراءات',
            value: state.filter.action,
            items: ActivityAction.all
                .map((a) => DropdownMenuItem(
                      value: a,
                      child: Text(ActivityAction.labelAr(a)),
                    ))
                .toList(),
            onChanged: (v) =>
                ref.read(activityLogProvider.notifier).setAction(v),
          ),

          // ─── فلتر نوع الكيان ───
          _buildDropdown<String>(
            context,
            scheme,
            icon: Icons.category_outlined,
            hint: 'كل الأنواع',
            value: state.filter.entityType,
            items: EntityType.all
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(EntityType.labelAr(e)),
                    ))
                .toList(),
            onChanged: (v) =>
                ref.read(activityLogProvider.notifier).setEntityType(v),
          ),

          // ─── فلتر الفترة ───
          _buildDateRangeButton(context, scheme, state),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context,
    ColorScheme scheme, {
    required IconData icon,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXs, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSizes.spaceXs),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              icon: Icon(
                Icons.expand_more,
                size: AppSizes.iconXs,
                color: scheme.onSurfaceVariant,
              ),
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ...items,
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeButton(
    BuildContext context,
    ColorScheme scheme,
    ActivityLogState state,
  ) {
    final hasRange =
        state.filter.fromDate != null || state.filter.toDate != null;

    final label = hasRange
        ? '${_fmt(state.filter.fromDate)} - ${_fmt(state.filter.toDate)}'
        : 'كل الفترات';

    return InkWell(
      onTap: () => _pickDateRange(context, state),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: AppSizes.spaceSm,
        ),
        decoration: BoxDecoration(
          color:
              hasRange ? scheme.primary.withValues(alpha: 0.1) : scheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: hasRange
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_outlined,
              size: AppSizes.iconXs,
              color: hasRange ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSizes.spaceXs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: hasRange ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: hasRange ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (hasRange) ...[
              const SizedBox(width: AppSizes.spaceXs),
              GestureDetector(
                onTap: () => ref
                    .read(activityLogProvider.notifier)
                    .setDateRange(null, null),
                child: Icon(
                  Icons.close,
                  size: AppSizes.iconXs,
                  color: scheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ActivityLogState state, ColorScheme scheme) {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => ref.read(activityLogProvider.notifier).setSearch(v),
      decoration: InputDecoration(
        hintText: 'بحث في الوصف...',
        hintStyle: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurfaceVariant,
          size: AppSizes.iconSm,
        ),
        suffixIcon:
            state.filter.search != null && state.filter.search!.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref.read(activityLogProvider.notifier).setSearch('');
                    },
                  )
                : null,
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: scheme.primary,
            width: AppSizes.borderMedium,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceSmMd,
          vertical: AppSizes.spaceSm,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  زر "تحميل المزيد"
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadMore(
    BuildContext context,
    ActivityLogState state,
    ColorScheme scheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMd),
        child: state.isLoadingMore
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : TextButton.icon(
                onPressed: () =>
                    ref.read(activityLogProvider.notifier).loadMore(),
                icon: const Icon(Icons.expand_more),
                label: const Text('تحميل المزيد'),
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  حالة فارغة
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme scheme,
    ActivityLogState state,
  ) {
    final hasFilters = state.hasActiveFilters;
    final hasSearch =
        state.filter.search != null && state.filter.search!.isNotEmpty;
    final isFiltered = hasFilters || hasSearch;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.history_toggle_off,
              size: AppSizes.iconHuge,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              isFiltered ? 'لا توجد نتائج للفلتر الحالي' : 'لا يوجد نشاط بعد',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isFiltered
                  ? 'جرّب تعديل الفلاتر أو مسحها'
                  : 'ستظهر هنا كل الأنشطة التي تتم في النظام',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (isFiltered) ...[
              const SizedBox(height: AppSizes.spaceMd),
              OutlinedButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  ref.read(activityLogProvider.notifier).clearFilters();
                },
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('مسح الفلاتر'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  التفاصيل
  // ═══════════════════════════════════════════════════════════════

  void _showDetails(BuildContext context, ActivityLog log) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXxl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLg),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // المقبض
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              Text(
                'تفاصيل النشاط',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSizes.spaceMd),

              // الوصف
              if (log.description != null && log.description!.isNotEmpty) ...[
                _detailRow('الوصف', log.description!, scheme),
                const SizedBox(height: AppSizes.spaceSm),
              ],
              _detailRow('الإجراء', log.actionLabelAr, scheme),
              if (log.entityLabelAr.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceSm),
                _detailRow('نوع الكيان', log.entityLabelAr, scheme),
              ],
              if (log.createdAt != null) ...[
                const SizedBox(height: AppSizes.spaceSm),
                _detailRow(
                  'التاريخ',
                  '${log.createdAt!.day}/${log.createdAt!.month}/${log.createdAt!.year} '
                      '${log.createdAt!.hour}:${log.createdAt!.minute.toString().padLeft(2, '0')}',
                  scheme,
                ),
              ],

              const SizedBox(height: AppSizes.spaceMd),

              // Metadata
              if (log.metadata.isNotEmpty) ...[
                Text(
                  'بيانات إضافية:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceSmMd),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: log.metadata.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key}: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: AppSizes.spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ColorScheme scheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  منتقي الفترة
  // ═══════════════════════════════════════════════════════════════

  Future<void> _pickDateRange(
    BuildContext context,
    ActivityLogState state,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange:
          state.filter.fromDate != null && state.filter.toDate != null
              ? DateTimeRange(
                  start: state.filter.fromDate!,
                  end: state.filter.toDate!,
                )
              : null,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    await ref.read(activityLogProvider.notifier).setDateRange(
          DateTime(picked.start.year, picked.start.month, picked.start.day),
          DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
  }

  // ═══════════════════════════════════════════════════════════════
  //  تنسيق التاريخ
  // ═══════════════════════════════════════════════════════════════

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.day}/${d.month}';
  }
}
