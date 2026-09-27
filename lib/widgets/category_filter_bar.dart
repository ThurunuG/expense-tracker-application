import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Horizontal list of category chips used to filter transactions.
class CategoryFilterBar extends StatelessWidget {
  // Currently active category.
  final String selected;
  // Called when a different category chip is tapped.
  final ValueChanged<String> onSelected;

  const CategoryFilterBar({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Include the "All" option before the available category list.
    final categories = [AppCategories.all, ...AppCategories.list];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        // Spacing between chips.
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          final color = category == AppCategories.all
              ? Theme.of(context).colorScheme.primary
              : AppCategories.colorFor(category);

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            // Soft background for the selected chip.
            selectedColor: color.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? color : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            // Show the category icon, except for the "All" option.
            avatar: category != AppCategories.all
                ? Icon(AppCategories.iconFor(category), size: 16, color: color)
                : null,
            // Highlight the selected chip border.
            side: BorderSide(color: isSelected ? color : Colors.transparent),
          );
        },
      ),
    );
  }
}
