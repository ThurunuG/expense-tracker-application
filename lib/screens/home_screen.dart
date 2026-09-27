import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/state_views.dart';
import '../widgets/summary_card.dart';
import 'add_edit_expense_screen.dart';
import 'summary_screen.dart';

// Main dashboard screen that shows the user's monthly summary,
// filters, search, and a list of expenses.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tracks whether the search field is visible in the app bar.
  bool _isSearching = false;

  // Controller for the inline search input.
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final expenses = context.read<ExpenseProvider>();

    // Load the current user's expense data as soon as the screen opens.
    if (auth.user != null) {
      expenses.start(auth.user!.uid);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search expenses…',
                  border: InputBorder.none,
                ),
                onChanged: expenseProvider.setSearchQuery,
              )
            : const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  expenseProvider.setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SummaryScreen()),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'theme') themeProvider.toggleTheme();
              if (value == 'logout') context.read<AuthProvider>().signOut();
              if (value == 'clear_filters') expenseProvider.clearFilters();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    const SizedBox(width: 8),
                    Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_filters',
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_off_rounded),
                    SizedBox(width: 8),
                    Text('Clear Filters'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: 8),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = context.read<AuthProvider>();
          if (auth.user != null) expenseProvider.start(auth.user!.uid);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SummaryCard(
              month: expenseProvider.selectedMonth,
              total: expenseProvider.currentMonthTotal,
              onPrevious: expenseProvider.previousMonth,
              onNext: expenseProvider.nextMonth,
              expenseCount: expenseProvider.allExpenses
                  .where((e) =>
                      e.date.year == expenseProvider.selectedMonth.year &&
                      e.date.month == expenseProvider.selectedMonth.month)
                  .length,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CategoryFilterBar(
                    selected: expenseProvider.selectedCategory,
                    onSelected: expenseProvider.setCategory,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('This month'),
                  selected: expenseProvider.filterByMonth,
                  onSelected: expenseProvider.toggleMonthFilter,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildExpenseList(context, expenseProvider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, ExpenseProvider provider) {
    switch (provider.status) {
      case ExpenseStatus.loading:
        return const Padding(
          padding: EdgeInsets.only(top: 48),
          child: LoadingView(),
        );
      case ExpenseStatus.error:
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: ErrorStateView(
            message: provider.errorMessage ?? 'Something went wrong.',
            onRetry: () {
              final auth = context.read<AuthProvider>();
              if (auth.user != null) provider.start(auth.user!.uid);
            },
          ),
        );
      case ExpenseStatus.empty:
        return const Padding(
          padding: EdgeInsets.only(top: 24),
          child: EmptyStateView(),
        );
      case ExpenseStatus.loaded:
        final filtered = provider.filteredExpenses;
        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 24),
            child: EmptyStateView(
              message: 'No matching expenses',
              subMessage: 'Try adjusting your filters or search.',
              icon: Icons.filter_alt_off_rounded,
            ),
          );
        }
        return Column(
          children: filtered
              .map((expense) => ExpenseListItem(
                    expense: expense,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditExpenseScreen(existingExpense: expense),
                      ),
                    ),
                    onDelete: () => provider.deleteExpense(expense.id),
                  ))
              .toList(),
        );
    }
  }
}
