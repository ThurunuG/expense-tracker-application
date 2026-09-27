import 'package:flutter/material.dart';

/// Central place for category metadata, so the whole app stays consistent
/// when displaying icons/colors for a given category name.
/// Central place for category metadata, so the whole app stays consistent
/// when displaying icons and colors for a given category name.
class AppCategories {
  AppCategories._();

  /// Special category used to represent all categories together.
  static const String all = 'All';

  /// List of available expense categories shown throughout the app.
  static const List<String> list = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Bills',
    'Education',
    'Other',
  ];

  /// Returns the icon associated with the provided category.
  static IconData iconFor(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Returns the color associated with the provided category.
  static Color colorFor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF7A59);
      case 'Transport':
        return const Color(0xFF4C9AFF);
      case 'Shopping':
        return const Color(0xFFB07AFF);
      case 'Entertainment':
        return const Color(0xFFFFB020);
      case 'Health':
        return const Color(0xFFFF5C7A);
      case 'Bills':
        return const Color(0xFF2ED8B6);
      case 'Education':
        return const Color(0xFF5C7CFA);
      default:
        return const Color(0xFF9AA5B1);
    }
  }
}

/// Shared spacing and radius constants for consistent UI styling.
class AppDims {
  AppDims._();

  /// Default corner radius used across cards and containers.
  static const double radius = 16.0;

  /// Default padding used across screens and components.
  static const double padding = 16.0;
}
