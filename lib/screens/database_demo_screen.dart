import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

class DatabaseDemoScreen extends StatefulWidget {
  const DatabaseDemoScreen({super.key});

  @override
  State<DatabaseDemoScreen> createState() => _DatabaseDemoScreenState();
}

class _DatabaseDemoScreenState extends State<DatabaseDemoScreen> {
  List<Expense> _expenses = [];
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    final maps = await DatabaseHelper.instance.getExpenses();
    setState(() {
      _expenses = maps.map((m) => Expense.fromMap(m)).toList();
    });
  }

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (_titleController.text.isEmpty || amount == null) return;

    final expense = Expense(
      id: DateTime.now().toIso8601String(),
      title: _titleController.text,
      amount: amount,
      category: 'Khác',
      note: '',
      date: DateTime.now(),
      type: TransactionType.expense,
    );

    await DatabaseHelper.instance.insertExpense(expense.toMap());
    _titleController.clear();
    _amountController.clear();
    _loadExpenses();
  }

  Future<void> _deleteExpense(String id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buổi 5 — Demo SQLite')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên khoản chi'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExpense,
                child: const Text('Lưu vào SQLite'),
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: _expenses.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu trong database'))
                  : ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final e = _expenses[index];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text(formatDateDisplay(e.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatCurrency(e.amount)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteExpense(e.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}