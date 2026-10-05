import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';
import 'transaction_form_screen.dart';

// Tab "Giao dịch": hiển thị TOÀN BỘ danh sách (khác Dashboard chỉ lấy 5 mục).
// Bấm vào 1 dòng -> mở TransactionFormScreen ở chế độ SỬA.
class TransactionListScreen extends StatelessWidget {
  final List<Expense> transactions;
  final VoidCallback onChanged;

  const TransactionListScreen({
    super.key,
    required this.transactions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Giao dịch',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: transactions.isEmpty
          ? const Center(
        child: Text(
          'Chưa có giao dịch nào.',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final expense = transactions[index];
          final info = categoryInfoFor(expense.type, expense.category);
          final isIncome = expense.type == TransactionType.income;

          return InkWell(
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TransactionFormScreen(existingExpense: expense),
                ),
              );
              if (result == true) onChanged();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: info.color,
                    child: Icon(info.icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${expense.category} · ${formatDateDisplay(expense.date)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${formatCurrency(expense.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isIncome
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFEB5757),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
