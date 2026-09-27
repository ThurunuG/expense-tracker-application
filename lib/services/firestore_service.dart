import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// Handles all reads and writes to Firestore for the currently signed-in user.
/// Each user has their own collection under:
/// users/{uid}/expenses/{expenseId}
class FirestoreService {
  // Shared Firestore instance for the app.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the expenses collection reference for a specific user.
  CollectionReference<Map<String, dynamic>> _expensesRef(String uid) {
    return _db.collection('users').doc(uid).collection('expenses');
  }

  /// Streams all expenses for [uid] in descending date order (newest first).
  Stream<List<Expense>> streamExpenses(String uid) {
    return _expensesRef(uid).orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Adds a new expense document for [uid].
  Future<void> addExpense(String uid, Expense expense) {
    return _expensesRef(uid).doc(expense.id).set(expense.toMap());
  }

  /// Updates an existing expense document for [uid].
  Future<void> updateExpense(String uid, Expense expense) {
    return _expensesRef(uid).doc(expense.id).update(expense.toMap());
  }

  /// Deletes an expense by [expenseId] for [uid].
  Future<void> deleteExpense(String uid, String expenseId) {
    return _expensesRef(uid).doc(expenseId).delete();
  }
}
