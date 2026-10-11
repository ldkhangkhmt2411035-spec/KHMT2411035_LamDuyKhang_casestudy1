import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/filter_options.dart';
import '../utils/formatters.dart';
import 'filter_screen.dart';
import 'transaction_form_screen.dart';

// Tab "Giao dịch": thanh tìm kiếm + nút lọc, tab nhanh Tất cả/Thu nhập/Chi
// tiêu, và danh sách TOÀN BỘ giao dịch (khác Dashboard chỉ lấy 5 mục).
// Bấm vào 1 dòng -> mở TransactionFormScreen ở chế độ SỬA.
class TransactionListScreen extends StatefulWidget {
  final List<Expense> transactions;
  final VoidCallback onChanged;

  const TransactionListScreen({
    super.key,
    required this.transactions,
    required this.onChanged,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _tabType;
  FilterOptions _filter = const FilterOptions();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.push<FilterOptions>(
      context,
      MaterialPageRoute(builder: (_) => FilterScreen(initial: _filter)),
    );
    if (result != null) setState(() => _filter = result);
  }

  List<Expense> get _visible {
    return widget.transactions.where((e) {
      if (_tabType != null && e.type != _tabType) return false;
      if (!_filter.matches(e)) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final matchTitle = e.title.toLowerCase().contains(q);
        final matchCategory = e.category.toLowerCase().contains(q);
        final matchNote = e.note.toLowerCase().contains(q);
        if (!matchTitle && !matchCategory && !matchNote) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Giao dịch',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        hintText: 'Tìm giao dịch...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _openFilter,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _filter.isActive
                          ? const Color(0xFF1769E0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _filter.isActive
                            ? const Color(0xFF1769E0)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: _filter.isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'Tất cả',
                    selected: _tabType == null,
                    onTap: () => setState(() => _tabType = null),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabChip(
                    label: 'Thu nhập',
                    selected: _tabType == TransactionType.income,
                    onTap: () =>
                        setState(() => _tabType = TransactionType.income),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabChip(
                    label: 'Chi tiêu',
                    selected: _tabType == TransactionType.expense,
                    onTap: () =>
                        setState(() => _tabType = TransactionType.expense),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: visible.isEmpty
                ? const Center(
              child: Text(
                'Không có giao dịch phù hợp.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final expense = visible[index];
                final info =
                categoryInfoFor(expense.type, expense.category);
                final isIncome = expense.type == TransactionType.income;

                return InkWell(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionFormScreen(
                          existingExpense: expense,
                        ),
                      ),
                    );
                    if (result == true) widget.onChanged();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                      Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: info.color,
                          child: Icon(info.icon,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${expense.category} · ${formatDateDisplay(expense.date)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? '+' : '-'}${formatCurrency(expense.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome
                                ? const Color(0xFF27AE60)
                                : const Color(0xFFEB5757),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1769E0) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF1769E0) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}