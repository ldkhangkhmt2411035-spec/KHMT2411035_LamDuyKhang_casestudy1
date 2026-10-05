// Hàm định dạng dùng chung cho các màn hình.

// 50000 -> "50.000 đ"
String formatCurrency(num value) {
  final isNegative = value < 0;
  final intValue = value.abs().round();
  final digits = intValue.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${isNegative ? '-' : ''}${buffer.toString()} đ';
}

// DateTime -> 'dd/MM/yyyy'
String formatDateDisplay(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$d/$m/$y';
}
