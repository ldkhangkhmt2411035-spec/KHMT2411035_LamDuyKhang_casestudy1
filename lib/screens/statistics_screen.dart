import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Expense> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final expenses =
    transactions.where((e) => e.type == TransactionType.expense).toList();
    final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final Map<String, double> totalsByCategory = {};
    for (final e in expenses) {
      totalsByCategory[e.category] =
          (totalsByCategory[e.category] ?? 0) + e.amount;
    }

    final sortedEntries = totalsByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Thống kê',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: expenses.isEmpty
          ? const Center(
        child: Text(
          'Chưa có khoản chi nào để thống kê.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5FCC), Color(0xFF4A90E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TỔNG CHI TIÊU',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(totalExpense),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Theo danh mục',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...sortedEntries.map((entry) {
            final percent =
            totalExpense == 0 ? 0.0 : entry.value / totalExpense;
            final info = categoryInfoFor(TransactionType.expense, entry.key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: info.color,
                          child: Icon(info.icon, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          formatCurrency(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0F1F5),
                        color: info.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(percent * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}