import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../repository/expense_repository.dart';

// Màn hình "Thêm giao dịch" / "Sửa giao dịch" — đúng mockup Buổi 3,
// Buổi 6 nối thật vào SQLite qua ExpenseRepository thay vì chỉ trả dữ liệu.
//
// existingExpense == null  -> chế độ THÊM.
// existingExpense != null  -> chế độ SỬA (có thêm nút Xóa trên AppBar).
class TransactionFormScreen extends StatefulWidget {
  final Expense? existingExpense;

  const TransactionFormScreen({super.key, this.existingExpense});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final ExpenseRepository _repository = ExpenseRepository();

  late TransactionType _type;
  late String _category;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get isEditing => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingExpense;
    if (existing != null) {
      _type = existing.type;
      _category = existing.category;
      _amountController.text = existing.amount.toStringAsFixed(0);
      _noteController.text = existing.note;
      _selectedDate = existing.date;
    } else {
      _type = TransactionType.expense;
      _category = expenseCategories.first.name;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      id: widget.existingExpense?.id ?? DateTime.now().toIso8601String(),
      title: _category,
      amount: amount,
      category: _category,
      note: _noteController.text,
      date: _selectedDate,
      type: _type,
    );

    if (isEditing) {
      await _repository.updateExpense(expense);
    } else {
      await _repository.insertExpense(expense);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final existing = widget.existingExpense;
    if (existing == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Giao dịch này sẽ bị xóa khỏi database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteExpense(existing.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoriesForType(_type);
    if (!categories.any((c) => c.name == _category)) {
      _category = categories.first.name;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: Text(
          isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.black87),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Chi tiêu',
                    selected: _type == TransactionType.expense,
                    onTap: () {
                      setState(() {
                        _type = TransactionType.expense;
                        _category = expenseCategories.first.name;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeChip(
                    label: 'Thu nhập',
                    selected: _type == TransactionType.income,
                    onTap: () {
                      setState(() {
                        _type = TransactionType.income;
                        _category = incomeCategories.first.name;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _FieldLabel('Danh mục'),
            const SizedBox(height: 8),
            _BoxField(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                      value: c.name,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: c.color,
                            child: Icon(c.icon, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(c.name),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('Số tiền'),
            const SizedBox(height: 8),
            _BoxField(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nhập số tiền',
                  suffixText: 'đ',
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('Ngày giao dịch'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: _BoxField(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate.year}',
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('Ghi chú'),
            const SizedBox(height: 8),
            _BoxField(
              child: TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nhập ghi chú (tùy chọn)',
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1769E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isSaving ? 'Đang lưu...' : 'Lưu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF667085),
      ),
    );
  }
}

class _BoxField extends StatelessWidget {
  final Widget child;
  const _BoxField({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFE8617A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? color : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
