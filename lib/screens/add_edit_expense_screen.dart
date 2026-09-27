import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddEditExpenseScreen({super.key, this.existingExpense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  // Form and field controllers for the expense form.
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _category;
  late DateTime _date;
  bool _isSaving = false;

  // Used to switch between add and edit modes.
  bool get _isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form when editing an existing expense.
    final expense = widget.existingExpense;
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(text: expense != null ? expense.amount.toString() : '');
    _noteController = TextEditingController(text: expense?.note ?? '');
    _category = expense?.category ?? AppCategories.list.first;
    _date = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    // Free resources used by the form fields.
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Allows the user to choose a date for the expense.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  // Saves the submitted expense to the provider and closes the screen on success.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<ExpenseProvider>();
    final amount = double.parse(_amountController.text.trim());

    try {
      if (_isEditing) {
        final updated = widget.existingExpense!.copyWith(
          title: _titleController.text,
          amount: amount,
          category: _category,
          date: _date,
          note: _noteController.text,
        );
        await provider.updateExpense(updated);
      } else {
        await provider.addExpense(
          title: _titleController.text,
          amount: amount,
          category: _category,
          date: _date,
          note: _noteController.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: $e'), backgroundColor: Colors.red.shade400),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the add/edit form UI for expense details.
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Groceries',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: Validators.title,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: AppCategories.list.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(AppCategories.iconFor(cat), size: 18, color: AppCategories.colorFor(cat)),
                          const SizedBox(width: 8),
                          Text(cat),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppDims.radius),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text('${_date.day}/${_date.month}/${_date.year}'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'Any extra details…',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: Validators.note,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Update Expense' : 'Save Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
