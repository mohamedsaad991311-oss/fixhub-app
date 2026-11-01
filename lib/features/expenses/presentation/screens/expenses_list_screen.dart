// lib/features/expenses/presentation/screens/expenses_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/expense.dart';
import '../providers/expenses_list_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expenses_filter_sheet.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() =>
      _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(expensesListProvider);
    final notifier = ref.read(expensesListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المصاريف'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'الفلاتر',
            onPressed: () => _openFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SummaryHeader(
            summary: state.monthSummary,
            totalShown: state.totalShown,
            scheme: scheme,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spaceMd,
              vertical: AppSizes.spaceSm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => notifier.search(v),
              decoration: InputDecoration(
                hintText: 'بحث في المصاريف...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(state, notifier)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/new'),
        icon: const Icon(Icons.add),
        label: const Text('مصروف جديد'),
      ),
    );
  }

  Widget _buildBody(ExpensesListState state, ExpensesListNotifier notifier) {
    if (state.isLoading && state.expenses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.isEmpty) {
      return const Center(child: Text('لا توجد مصاريف'));
    }
    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        itemCount: state.expenses.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSm),
        itemBuilder: (context, i) {
          final expense = state.expenses[i];
          return ExpenseCard(
            expense: expense,
            onTap: () => context.push('/expenses/${expense.id}'),
            onDelete: () async {
              await notifier.delete(expense.id);
            },
          );
        },
      ),
    );
  }

  void _openFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExpensesFilterSheet(),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.summary,
    required this.totalShown,
    required this.scheme,
  });

  final ExpenseSummary summary;
  final double totalShown;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.spaceMd),
      padding: const EdgeInsets.all(AppSizes.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مصروفات الشهر الحالي',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(summary.total),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          Row(
            children: [
              _MiniStat(
                label: 'العدد',
                value: '${summary.count}',
                scheme: scheme,
              ),
              const SizedBox(width: AppSizes.spaceLg),
              _MiniStat(
                label: 'المعروض',
                value: CurrencyFormatter.format(totalShown),
                scheme: scheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.scheme,
  });

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onPrimary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scheme.onPrimary,
          ),
        ),
      ],
    );
  }
}