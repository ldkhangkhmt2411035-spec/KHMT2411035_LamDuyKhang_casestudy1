// Model Expense — Buổi 3 (bản khớp đúng mockup "Thêm/Sửa giao dịch").
// Bổ sung so với bản trước: category có icon riêng, có "note" (ghi chú),
// và "type" (Chi tiêu / Thu nhập) theo đúng 2 nút chọn trên mockup.
// CHƯA có toMap()/fromMap() vì chưa cần lưu vào SQLite (phần đó ở Buổi 5-6).
import 'package:flutter/material.dart';

enum TransactionType { expense, income } // Chi tiêu / Thu nhập

class CategoryOption {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryOption({
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Danh sách danh mục mẫu, khớp icon trong mockup (Ăn uống = icon cái nĩa).
const List<CategoryOption> expenseCategories = [
  CategoryOption(name: 'Ăn uống', icon: Icons.restaurant, color: Color(0xFFE8734A)),
  CategoryOption(name: 'Di chuyển', icon: Icons.directions_bus, color: Color(0xFF4A90E2)),
  CategoryOption(name: 'Mua sắm', icon: Icons.shopping_bag, color: Color(0xFF9B59B6)),
  CategoryOption(name: 'Học tập', icon: Icons.menu_book, color: Color(0xFF2ECC71)),
  CategoryOption(name: 'Khác', icon: Icons.more_horiz, color: Color(0xFF95A5A6)),
];

const List<CategoryOption> incomeCategories = [
  CategoryOption(name: 'Lương', icon: Icons.account_balance_wallet, color: Color(0xFF2ECC71)),
  CategoryOption(name: 'Thưởng', icon: Icons.card_giftcard, color: Color(0xFFF1C40F)),
  CategoryOption(name: 'Khác', icon: Icons.more_horiz, color: Color(0xFF95A5A6)),
];

class Expense {
  final String id;
  final String title; // dùng tên danh mục làm tiêu đề hiển thị khi cần
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final TransactionType type;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.type,
  });

  // Buổi 6, mục "copyWith": tiện cho việc Sửa giao dịch mà không cần
  // tạo lại toàn bộ object từ đầu.
  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    TransactionType? type,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}
