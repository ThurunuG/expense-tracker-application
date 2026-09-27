import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyBarChart extends StatelessWidget {
  // Holds the month and its corresponding total amount for that month.
  final List<MapEntry<DateTime, double>> monthlyTotals;

  const MonthlyBarChart({super.key, required this.monthlyTotals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find the largest monthly total to scale the chart y-axis properly.
    final maxY = monthlyTotals
        .map((e) => e.value)
        .fold(0.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          // Ensure the chart has a visible y-axis range even when totals are zero.
          maxY: maxY == 0 ? 100 : maxY * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Display abbreviated month names below each bar.
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= monthlyTotals.length) return const SizedBox();

                  final month = monthlyTotals[index].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM').format(month),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),

          // Build one bar for each month using the total as its height.
          barGroups: monthlyTotals.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: theme.colorScheme.primary,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
