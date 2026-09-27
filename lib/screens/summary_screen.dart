import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';

// Displays monthly spending insights and category totals for the selected month.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the expense provider so the summary updates when data changes.
    final provider = context.watch<ExpenseProvider>();

    // Current category totals for the selected month.
    final categoryTotals = provider.categoryTotalsForMonth;

    // Sort categories by amount so the largest spending categories appear first.
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Summary & Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview header for current month's category spending.
          Text(
            'Spending by category — ${Formatters.monthYear(provider.selectedMonth)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Pie chart showing distribution across categories.
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDims.radius)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CategoryPieChart(categoryTotals: categoryTotals),
            ),
          ),
          const SizedBox(height: 24),

          // Trend of spending over the last six months.
          Text(
            'Last 6 months trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Bar chart for recent month-to-month comparison.
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDims.radius)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MonthlyBarChart(monthlyTotals: provider.last6MonthsTotals),
            ),
          ),
          const SizedBox(height: 24),

          // Detailed breakdown for each category, ordered by largest spend first.
          if (sortedEntries.isNotEmpty) ...[
            Text(
              'Category breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...sortedEntries.map((entry) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDims.radius)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppCategories.colorFor(entry.key).withOpacity(0.15),
                      child: Icon(AppCategories.iconFor(entry.key), color: AppCategories.colorFor(entry.key)),
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      Formatters.currency(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
