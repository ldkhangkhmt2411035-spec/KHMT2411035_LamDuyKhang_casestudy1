import 'expense.dart';

enum DateRangeOption { all, today, last7Days, thisMonth, custom }

// Gói các điều kiện lọc của màn "Bộ lọc dữ liệu": loại giao dịch, danh mục,
// và khoảng thời gian. matches() dùng để lọc danh sách giao dịch.
class FilterOptions {
  final TransactionType? type;
  final String? category;
  final DateRangeOption dateRange;
  final DateTime? customStart;
  final DateTime? customEnd;

  const FilterOptions({
    this.type,
    this.category,
    this.dateRange = DateRangeOption.all,
    this.customStart,
    this.customEnd,
  });

  bool get isActive =>
      type != null || category != null || dateRange != DateRangeOption.all;

  bool matches(Expense e) {
    if (type != null && e.type != type) return false;
    if (category != null && e.category != category) return false;

    final now = DateTime.now();
    switch (dateRange) {
      case DateRangeOption.all:
        return true;
      case DateRangeOption.today:
        return e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day;
      case DateRangeOption.last7Days:
        return e.date.isAfter(now.subtract(const Duration(days: 7)));
      case DateRangeOption.thisMonth:
        return e.date.year == now.year && e.date.month == now.month;
      case DateRangeOption.custom:
        if (customStart == null || customEnd == null) return true;
        final endInclusive = customEnd!.add(const Duration(days: 1));
        return !e.date.isBefore(customStart!) && e.date.isBefore(endInclusive);
    }
  }
}