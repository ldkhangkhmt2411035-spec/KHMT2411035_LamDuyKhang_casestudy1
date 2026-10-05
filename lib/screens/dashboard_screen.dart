import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

// Buổi 4 — màn hình Dashboard, đúng theo mockup "Quản lý thu chi".
// Dữ liệu ở Buổi 4 là dữ liệu MẪU (sampleTransactions) để dựng giao diện.
// Buổi 6 sẽ thay bằng dữ liệu thật đọc từ SQLite qua Repository.
class DashboardScreen extends StatelessWidget {
  final List<Expense> transactions;

  const DashboardScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;

    final recent = transactions.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(),
          const SizedBox(height: 20),
          _BalanceCard(balance: balance),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'TỔNG THU NHẬP',
                  amount: totalIncome,
                  color: const Color(0xFF27AE60),
                  backgroundColor: const Color(0xFFE8F8EE),
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SummaryCard(
                  title: 'TỔNG CHI TIÊU',
                  amount: totalExpense,
                  color: const Color(0xFFE05261),
                  backgroundColor: const Color(0xFFFCEAEC),
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Chưa có giao dịch nào')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _TransactionTile(recent[index]),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, size: 26),
        const Text(
          'Quản lý thu chi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, size: 26),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: const Text(
                  '3',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5FCC), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'SỐ DƯ HIỆN TẠI',
                    style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.visibility_outlined, color: Colors.white70, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                formatCurrency(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: List.generate(4, (i) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: i == 0 ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == 0 ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF667085), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(amount),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;
  const _TransactionTile(this.expense);

  @override
  Widget build(BuildContext context) {
    final info = categoryInfoFor(expense.type, expense.category);
    final isIncome = expense.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: info.color,
            child: Icon(info.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.category} · ${formatDateDisplay(expense.date)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${formatCurrency(expense.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? const Color(0xFF27AE60) : const Color(0xFFE05261),
            ),
          ),
        ],
      ),
    );
  }
}
