import 'package:flutter/material.dart';

import '../models/expense.dart';

// Buổi 3 — màn hình dùng chung cho cả "Thêm giao dịch" và "Sửa giao dịch",
// đúng theo 2 mockup trong đề bài (chỉ khác tiêu đề + có sẵn dữ liệu hay không).
//
// existingExpense == null  -> đang ở chế độ THÊM.
// existingExpense != null  -> đang ở chế độ SỬA (các ô tự điền sẵn).
//
// Buổi 3: lưu tạm vào bộ nhớ (trả kết quả Expense về qua Navigator.pop).
// Buổi 6 mới nối thật vào SQLite qua Repository.
class TransactionFormScreen extends StatefulWidget {
  final Expense? existingExpense;

  const TransactionFormScreen({super.key, this.existingExpense});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late TransactionType _type;
  late String _category;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;

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

  List<CategoryOption> get _categories =>
      _type == TransactionType.expense ? expenseCategories : incomeCategories;

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

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final result = Expense(
      id: widget.existingExpense?.id ?? DateTime.now().toIso8601String(),
      title: _category,
      amount: amount,
      category: _category,
      note: _noteController.text,
      date: _selectedDate,
      type: _type,
    );

    // Buổi 3: chỉ trả dữ liệu về màn trước qua Navigator.pop.
    // Buổi 6 sẽ thay bằng gọi TransactionRepository để lưu vào SQLite.
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _categories.firstWhere(
          (c) => c.name == _category,
      orElse: () => _categories.first,
    );

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Chi tiêu / Thu nhập
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Chi tiêu',
                    selected: _type == TransactionType.expense,
                    color: const Color(0xFFE8617A),
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
                    color: const Color(0xFFE8617A),
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
                  items: _categories
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
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1769E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Demo nhỏ: chỉ để tiện xem màn "Sửa giao dịch" trong lúc chưa
            // có danh sách giao dịch thật (sẽ có ở các buổi sau).
            if (!isEditing && selected.name.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionFormScreen(
                          existingExpense: Expense(
                            id: 'demo',
                            title: 'Ăn uống',
                            amount: 100000,
                            category: 'Ăn uống',
                            note: 'Ăn trưa',
                            date: DateTime(2025, 4, 12),
                            type: TransactionType.expense,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Xem thử màn hình Sửa giao dịch (demo)'),
                ),
              ),
            ],
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
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
