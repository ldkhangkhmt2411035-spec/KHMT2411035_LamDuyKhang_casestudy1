import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

// Buổi 2: MaterialApp là Widget gốc của ứng dụng (mục 9)
class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      home: const WelcomeScreen(),
    );
  }
}

// Màn hình Chào mừng — Widget Tree (Buổi 2, mục 49):
//
// Scaffold
// └── SafeArea
//     └── Padding
//         └── Column
//             ├── Expanded
//             │   └── Column (Icon, SizedBox, Text, SizedBox, Text)
//             └── SizedBox
//                 └── ElevatedButton
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo — tạm dùng Icon vì chưa có file ảnh thật.
                    // Nếu có file logo, thay bằng:
                    // Image.asset('assets/images/logo.png', width: 120),
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 100,
                      color: Color(0xFF1B5FCC),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Expense Manager',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F1B33),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Quản lý chi tiêu cá nhân\n'
                          'đơn giản và hiệu quả',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8A94A6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5FCC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    // Buổi 2 chưa xử lý điều hướng (mục 48 tài liệu:
                    // "chưa tạo ra một luồng nghiệp vụ thực sự")
                    print('Bắt đầu');
                  },
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
