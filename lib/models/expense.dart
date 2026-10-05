// Model Expense — dùng chung từ Buổi 3 trở đi.
// Danh mục khớp đúng mockup Dashboard (Buổi 4): Ăn uống, Di chuyển,
// Mua sắm, Giáo dục, Khác (chi tiêu) và Thu nhập (thu nhập).
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

const List<CategoryOption> expenseCategories = [
  CategoryOption(name: 'Ăn uống', icon: Icons.restaurant, color: Color(0xFFF2994A)),
  CategoryOption(name: 'Di chuyển', icon: Icons.directions_car, color: Color(0xFF2F80ED)),
  CategoryOption(name: 'Mua sắm', icon: Icons.shopping_cart, color: Color(0xFF9B51E0)),
  CategoryOption(name: 'Giáo dục', icon: Icons.school, color: Color(0xFF27AE94)),
  CategoryOption(name: 'Khác', icon: Icons.more_horiz, color: Color(0xFF95A5A6)),
];

const List<CategoryOption> incomeCategories = [
  CategoryOption(name: 'Thu nhập', icon: Icons.attach_money, color: Color(0xFF27AE60)),
];

CategoryOption categoryInfoFor(TransactionType type, String name) {
  final list = type == TransactionType.expense ? expenseCategories : incomeCategories;
  return list.firstWhere((c) => c.name == name, orElse: () => list.first);
}

class Expense {
  final String id;
  final String title;
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
