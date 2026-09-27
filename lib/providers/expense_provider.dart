import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

enum ExpenseStatus { loading, loaded, empty, error }

/// Holds the full list of expenses (live from Firestore) plus all filter
/// state, and exposes derived/computed data (totals, filtered lists, etc.)
/// to the UI.
class ExpenseProvider with ChangeNotifier {
  // Firestore client and a unique ID generator used when creating new expenses.
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  // Active Firestore subscription for the current user.
  StreamSubscription<List<Expense>>? _sub;
  String? _uid;

  // All expenses fetched from Firestore and the current provider state.
  List<Expense> _expenses = [];
  ExpenseStatus _status = ExpenseStatus.loading;
  String? _errorMessage;

  // Filters used by the UI to narrow down the expense list.
  String _selectedCategory = AppCategories.all;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _searchQuery = '';
  bool _filterByMonth = true;

  // Public getters for read-only access to the current provider state.
  ExpenseStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  DateTime get selectedMonth => _selectedMonth;
  String get searchQuery => _searchQuery;
  bool get filterByMonth => _filterByMonth;

  /// Starts listening to the given user's expenses. Call on login.
  void start(String uid) {
    _uid = uid;
    _status = ExpenseStatus.loading;
    notifyListeners();
    _sub?.cancel();
    _sub = _firestoreService.streamExpenses(uid).listen(
      (data) {
        // Replace local cache with the latest Firestore snapshot.
        _expenses = data;
        _status = _expenses.isEmpty ? ExpenseStatus.empty : ExpenseStatus.loaded;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object e) {
        // Surface a user-friendly error when the stream fails.
        _status = ExpenseStatus.error;
        _errorMessage = 'Failed to load expenses. Please check your connection.';
        notifyListeners();
      },
    );
  }

  /// Stops listening. Call on logout.
  void stop() {
    _sub?.cancel();
    _expenses = [];
    _uid = null;
    _status = ExpenseStatus.loading;
    notifyListeners();
  }

  // ---------- Filters ----------

  // Update the selected category and refresh dependent UI widgets.
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Use the selected month as the active time filter.
  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  // Move to the next month in the date navigator.
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  // Move to the previous month in the date navigator.
  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  // Search by expense title or note text.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Toggle whether the month filter is active.
  void toggleMonthFilter(bool value) {
    _filterByMonth = value;
    notifyListeners();
  }

  // Reset all filters back to their default values.
  void clearFilters() {
    _selectedCategory = AppCategories.all;
    _searchQuery = '';
    _filterByMonth = false;
    notifyListeners();
  }

  // ---------- Derived data ----------

  // Return an immutable snapshot of the raw expenses list.
  List<Expense> get allExpenses => List.unmodifiable(_expenses);

  /// Expenses after applying category, month, and search filters.
  List<Expense> get filteredExpenses {
    return _expenses.where((e) {
      final matchesCategory =
          _selectedCategory == AppCategories.all || e.category == _selectedCategory;
      final matchesMonth = !_filterByMonth || Formatters.isSameMonth(e.date, _selectedMonth);
      final matchesSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesMonth && matchesSearch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Total spend for the currently selected month (ignores category/search
  /// filters so it always reflects the true monthly total).
  double get currentMonthTotal {
    return _expenses
        .where((e) => Formatters.isSameMonth(e.date, _selectedMonth))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Sum of the currently filtered list (respects all active filters).
  double get filteredTotal => filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Category -> total spend map, scoped to the selected month, used for
  /// the pie chart and category breakdown.
  Map<String, double> get categoryTotalsForMonth {
    final Map<String, double> totals = {};
    for (final e in _expenses.where((e) => Formatters.isSameMonth(e.date, _selectedMonth))) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  /// Last 6 months of totals, oldest first — used for the bar chart trend.
  List<MapEntry<DateTime, double>> get last6MonthsTotals {
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i)));
    return months.map((month) {
      final total = _expenses
          .where((e) => Formatters.isSameMonth(e.date, month))
          .fold(0.0, (sum, e) => sum + e.amount);
      return MapEntry(month, total);
    }).toList();
  }

  // ---------- CRUD ----------

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    if (_uid == null) return;
    final expense = Expense(
      id: _uuid.v4(),
      title: title.trim(),
      amount: amount,
      category: category,
      date: date,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      createdAt: DateTime.now(),
    );
    await _firestoreService.addExpense(_uid!, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    if (_uid == null) return;
    await _firestoreService.updateExpense(_uid!, expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    if (_uid == null) return;
    await _firestoreService.deleteExpense(_uid!, expenseId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
