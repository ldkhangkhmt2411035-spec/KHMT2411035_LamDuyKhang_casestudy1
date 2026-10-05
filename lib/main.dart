import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

// Buổi 4: luyện tập riêng màn hình Dashboard (dữ liệu mẫu),
// nên vào thẳng HomeShell để xem ngay giao diện.
void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      home: const HomeShell(),
    );
  }
}
