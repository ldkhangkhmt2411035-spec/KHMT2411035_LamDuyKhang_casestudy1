import '../models/expense.dart';

// Dữ liệu mẫu — Buổi 4 chỉ dựng giao diện Dashboard, chưa nối SQLite.
final List<Expense> sampleTransactions = [
  Expense(
    id: '1',
    title: 'Ăn trưa',
    amount: 50000,
    category: 'Ăn uống',
    note: '',
    date: DateTime(2024, 9, 3),
    type: TransactionType.expense,
  ),
  Expense(
    id: '2',
    title: 'Xăng xe',
    amount: 100000,
    category: 'Di chuyển',
    note: '',
    date: DateTime(2024, 9, 3),
    type: TransactionType.expense,
  ),
  Expense(
    id: '3',
    title: 'Lương tháng 9',
    amount: 8000000,
    category: 'Thu nhập',
    note: '',
    date: DateTime(2024, 9, 1),
    type: TransactionType.income,
  ),
  Expense(
    id: '4',
    title: 'Mua sắm',
    amount: 300000,
    category: 'Mua sắm',
    note: '',
    date: DateTime(2024, 8, 31),
    type: TransactionType.expense,
  ),
  Expense(
    id: '5',
    title: 'Học phí',
    amount: 500000,
    category: 'Giáo dục',
    note: '',
    date: DateTime(2024, 8, 30),
    type: TransactionType.expense,
  ),
];
