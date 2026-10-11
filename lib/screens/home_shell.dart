import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../repository/expense_repository.dart';
import 'dashboard_screen.dart';
import 'transaction_form_screen.dart';
import 'transaction_list_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

// HomeShell tải dữ liệu THẬT từ ExpenseRepository (SQLite) khi mở app,
// và load lại mỗi khi có thay đổi (thêm / sửa / xóa) ở bất kỳ màn hình con nào.
// Có 4 tab: Trang chủ / Giao dịch / Thống kê / Cá nhân.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final ExpenseRepository _repository = ExpenseRepository();

  int _currentIndex = 0;
  List<Expense> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _repository.getExpenses();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _loading = false;
    });
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );
    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(transactions: _transactions, onChanged: _loadData),
      TransactionListScreen(transactions: _transactions, onChanged: _loadData),
      StatisticsScreen(transactions: _transactions),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(child: pages[_currentIndex]),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1769E0),
        onPressed: _openAddScreen,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1769E0),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}