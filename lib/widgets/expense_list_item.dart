import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

// Displays a single expense row with a delete swipe action and tap behavior.
class ExpenseListItem extends StatelessWidget {
  // The expense data to render.
  final Expense expense;
  // Called when the item is tapped.
  final VoidCallback onTap;
  // Called after the item is dismissed and deleted.
  final VoidCallback onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Apply the category-specific accent color to the item.
    final color = AppCategories.colorFor(expense.category);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      // Background shown while swiping to delete.
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(AppDims.radius),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      // Confirm before deleting the expense from the list.
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete expense?'),
                content: Text('This will permanently delete "${expense.title}".'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDims.radius)),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Category icon and color-coded indicator.
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(AppCategories.iconFor(expense.category), color: color),
          ),
          title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          // Shows category, date, and optional note in a compact format.
          subtitle: Text(
            '${expense.category} • ${Formatters.shortDate(expense.date)}'
            '${expense.note != null ? '\n${expense.note}' : ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: expense.note != null,
          trailing: Text(
            Formatters.currency(expense.amount),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
