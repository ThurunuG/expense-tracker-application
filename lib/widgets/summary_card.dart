import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

// Displays the monthly spending summary with month navigation and total amount.
class SummaryCard extends StatelessWidget {
  // The month being summarized.
  final DateTime month;
  // The total expense amount for the selected month.
  final double total;
  // Called when the user navigates to the previous month.
  final VoidCallback onPrevious;
  // Called when the user navigates to the next month.
  final VoidCallback onNext;
  // Total number of expenses recorded for the month.
  final int expenseCount;

  const SummaryCard({
    super.key,
    required this.month,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      // Add spacing inside the card.
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDims.radius + 4),
        // Highlight the selected month with a gradient background.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.75)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Navigate to the previous month.
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                onPressed: onPrevious,
              ),
              // Show the active month label.
              Text(
                Formatters.monthYear(month),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              // Navigate to the next month.
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Section title for the total amount.
          Text(
            'Total Spent',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
          ),
          const SizedBox(height: 4),
          // Formatted total amount.
          Text(
            Formatters.currency(total),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Summary line with number of expenses for the month.
          Text(
            '$expenseCount expense${expenseCount == 1 ? '' : 's'} this month',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
