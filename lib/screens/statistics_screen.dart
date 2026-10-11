import 'dart:math';
import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/formatters.dart';

enum _Period { thisMonth, lastMonth, today }

class StatisticsScreen extends StatelessWidget {
  final List<Expense> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return _StatisticsBody(transactions: transactions);
  }
}

class _StatisticsBody extends StatefulWidget {
  final List<Expense> transactions;
  const _StatisticsBody({required this.transactions});

  @override
  State<_StatisticsBody> createState() => _StatisticsBodyState();
}

class _StatisticsBodyState extends State<_StatisticsBody> {
  _Period _period = _Period.thisMonth;

  List<Expense> get _filtered {
    final now = DateTime.now();
    return widget.transactions.where((e) {
      if (e.type != TransactionType.expense) return false;
      switch (_period) {
        case _Period.thisMonth:
          return e.date.year == now.year && e.date.month == now.month;
        case _Period.lastMonth:
          final lastMonthDate = DateTime(now.year, now.month - 1, 1);
          return e.date.year == lastMonthDate.year &&
              e.date.month == lastMonthDate.month;
        case _Period.today:
          return e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day;
      }
    }).toList();
  }

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final e in _filtered) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = _byCategory;
    final total = byCategory.values.fold<double>(0, (sum, v) => sum + v);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PeriodChip(
                  label: 'Tháng này',
                  selected: _period == _Period.thisMonth,
                  onTap: () => setState(() => _period = _Period.thisMonth),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PeriodChip(
                  label: 'Tháng trước',
                  selected: _period == _Period.lastMonth,
                  onTap: () => setState(() => _period = _Period.lastMonth),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PeriodChip(
                  label: 'Hôm nay',
                  selected: _period == _Period.today,
                  onTap: () => setState(() => _period = _Period.today),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (total == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'Chưa có chi tiêu nào trong khoảng thời gian này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: _PieChartPainter(byCategory, total),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TỔNG CHI',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatCurrency(total),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Theo danh mục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...byCategory.entries.map((entry) {
              final info = categoryInfoFor(TransactionType.expense, entry.key);
              final percent = (entry.value / total) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: info.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatCurrency(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
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

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final double total;

  _PieChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(14);
    double startAngle = -pi / 2;

    for (final entry in data.entries) {
      final info = categoryInfoFor(TransactionType.expense, entry.key);
      final sweep = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..color = info.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}