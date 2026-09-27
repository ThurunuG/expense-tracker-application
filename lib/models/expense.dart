import 'package:cloud_firestore/cloud_firestore.dart';

/// Core data model representing a single expense entry.
class Expense {
  // Unique identifier for this expense record.
  final String id;

  // Short label describing the expense.
  final String title;

  // Monetary value of the expense.
  final double amount;

  // Category used to group expenses.
  final String category;

  // Date when the expense occurred.
  final DateTime date;

  // Optional note or description for extra context.
  final String? note;

  // Date when the expense record was first created.
  final DateTime createdAt;

  /// Creates a new [Expense] instance.
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Creates an [Expense] from a Firestore document snapshot.
  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Other',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this [Expense] into a map suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Returns a copy of this expense with any provided fields replaced.
  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}
