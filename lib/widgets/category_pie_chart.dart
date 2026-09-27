import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    // Show an empty-state message when there are no spending entries.
    if (categoryTotals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data for this month yet')),
      );
    }

    // Calculate the total spend and sort categories from largest to smallest.
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        // Main pie chart visualization.
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              // Build each slice using the category value and percentage.
              sections: entries.map((entry) {
                final percent = (entry.value / total) * 100;
                return PieChartSectionData(
                  color: AppCategories.colorFor(entry.key),
                  value: entry.value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: 55,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Category legend under the chart.
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color indicator for the category.
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppCategories.colorFor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                // Show the category name alongside the formatted amount.
                Text('${entry.key} • ${Formatters.currency(entry.value)}',
                    style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
