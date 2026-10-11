import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/filter_options.dart';

// Màn hình "Bộ lọc dữ liệu": chọn Loại giao dịch, Danh mục, Khoảng thời gian
// rồi bấm "Áp dụng" để trả FilterOptions về cho TransactionListScreen.
class FilterScreen extends StatefulWidget {
  final FilterOptions initial;
  const FilterScreen({super.key, required this.initial});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  TransactionType? _type;
  String? _category;
  DateRangeOption _dateRange = DateRangeOption.all;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _category = widget.initial.category;
    _dateRange = widget.initial.dateRange;
    _customStart = widget.initial.customStart;
    _customEnd = widget.initial.customEnd;
  }

  List<String> get _allCategoryNames => [
    ...expenseCategories.map((c) => c.name),
    ...incomeCategories.map((c) => c.name),
  ];

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : null,
    );
    if (result != null) {
      setState(() {
        _dateRange = DateRangeOption.custom;
        _customStart = result.start;
        _customEnd = result.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bộ lọc dữ liệu',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Loại giao dịch',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          _CheckRow(
            label: 'Tất cả',
            selected: _type == null,
            onTap: () => setState(() => _type = null),
          ),
          _CheckRow(
            label: 'Thu nhập',
            selected: _type == TransactionType.income,
            onTap: () => setState(() => _type = TransactionType.income),
          ),
          _CheckRow(
            label: 'Chi tiêu',
            selected: _type == TransactionType.expense,
            onTap: () => setState(() => _type = TransactionType.expense),
          ),
          const SizedBox(height: 24),
          const Text(
            'Danh mục',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _category,
                isExpanded: true,
                hint: const Text('Tất cả danh mục'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tất cả danh mục'),
                  ),
                  ..._allCategoryNames.map(
                        (name) => DropdownMenuItem<String?>(
                      value: name,
                      child: Text(name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Khoảng thời gian',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          _RadioRow(
            label: 'Tất cả',
            selected: _dateRange == DateRangeOption.all,
            onTap: () => setState(() => _dateRange = DateRangeOption.all),
          ),
          _RadioRow(
            label: 'Hôm nay',
            selected: _dateRange == DateRangeOption.today,
            onTap: () => setState(() => _dateRange = DateRangeOption.today),
          ),
          _RadioRow(
            label: '7 ngày qua',
            selected: _dateRange == DateRangeOption.last7Days,
            onTap: () => setState(() => _dateRange = DateRangeOption.last7Days),
          ),
          _RadioRow(
            label: 'Tháng này',
            selected: _dateRange == DateRangeOption.thisMonth,
            onTap: () => setState(() => _dateRange = DateRangeOption.thisMonth),
          ),
          _RadioRow(
            label: _customStart != null && _customEnd != null
                ? 'Tùy chỉnh (${_customStart!.day}/${_customStart!.month} - ${_customEnd!.day}/${_customEnd!.month})'
                : 'Tùy chỉnh',
            selected: _dateRange == DateRangeOption.custom,
            onTap: _pickCustomRange,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1769E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  FilterOptions(
                    type: _type,
                    category: _category,
                    dateRange: _dateRange,
                    customStart: _customStart,
                    customEnd: _customEnd,
                  ),
                );
              },
              child: const Text(
                'Áp dụng',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CheckRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: selected ? const Color(0xFF1769E0) : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFF1769E0) : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}