import 'package:flutter/material.dart';

import '../data/sample_transactions.dart';
import 'dashboard_screen.dart';

// Khung chứa BottomNavigationBar + FloatingActionButton, bọc quanh
// DashboardScreen. Buổi 4 mới chỉ có tab "Trang chủ" hoạt động đầy đủ,
// 2 tab còn lại để placeholder (Buổi 6 sẽ hoàn thiện).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(transactions: sampleTransactions),
      const Center(child: Text('Giao dịch (sẽ hoàn thiện ở Buổi 6)')),
      const Center(child: Text('Thống kê (sẽ hoàn thiện ở Buổi 6)')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(child: pages[_currentIndex]),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1769E0),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Màn hình Thêm giao dịch sẽ nối vào đây ở Buổi 6'),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1769E0),
        unselectedItemColor: const Color(0xFF9AA2B1),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Thống kê'),
        ],
      ),
    );
  }
}
