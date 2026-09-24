package com.example.myapplication

import androidx.compose.ui.graphics.Color
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

// ---------- Màu sắc dùng chung ----------
object AppColors {
    val Blue = Color(0xFF1B5FCC)
    val Ink = Color(0xFF0F1B33)
    val Grey = Color(0xFF8A94A6)
    val Red = Color(0xFFEB3B4F)
    val Green = Color(0xFF27AE60)
    val FieldBg = Color(0xFFF7F8FA)
    val Border = Color(0xFFE3E7EE)
    val ToggleBg = Color(0xFFF1F3F7)
}

// ---------- Mô hình dữ liệu ----------
enum class TransactionType { EXPENSE, INCOME }

data class Category(
    val name: String,
    val emoji: String,
    val color: Color,
    val type: TransactionType
)

data class Transaction(
    val id: Int,
    val type: TransactionType,
    val category: Category,
    val amount: Long,        // số tiền (VNĐ), luôn dương
    val dateMillis: Long,    // 00:00 UTC của ngày giao dịch (đúng định dạng của DatePicker)
    val note: String
)

object Categories {
    val expense = listOf(
        Category("Ăn uống", "🍽️", Color(0xFFEB3B4F), TransactionType.EXPENSE),
        Category("Mua sắm", "🛒", Color(0xFF1FA8D6), TransactionType.EXPENSE),
        Category("Đi lại", "🚗", Color(0xFF8B5CF6), TransactionType.EXPENSE),
        Category("Học tập", "📚", Color(0xFF3B6FE0), TransactionType.EXPENSE),
        Category("Khác", "📦", Color(0xFF9AA3B2), TransactionType.EXPENSE)
    )

    val income = listOf(
        Category("Lương", "💼", Color(0xFF27AE60), TransactionType.INCOME),
        Category("Thưởng", "🎁", Color(0xFFF59E0B), TransactionType.INCOME),
        Category("Khác", "💰", Color(0xFF9AA3B2), TransactionType.INCOME)
    )

    fun of(type: TransactionType): List<Category> =
        if (type == TransactionType.EXPENSE) expense else income
}

// Dữ liệu mẫu (giống mockup) để có gì đó hiển thị
fun sampleTransactions(): List<Transaction> = listOf(
    Transaction(1, TransactionType.EXPENSE, Categories.expense[0], 100_000, utcMillis(2025, 4, 12), "Ăn trưa"),
    Transaction(2, TransactionType.EXPENSE, Categories.expense[1], 500_000, utcMillis(2025, 4, 10), ""),
    Transaction(3, TransactionType.INCOME, Categories.income[0], 10_000_000, utcMillis(2025, 4, 5), "Lương tháng 4"),
    Transaction(4, TransactionType.EXPENSE, Categories.expense[2], 200_000, utcMillis(2025, 4, 3), ""),
    Transaction(5, TransactionType.EXPENSE, Categories.expense[3], 300_000, utcMillis(2025, 4, 1), "")
)

fun List<Transaction>.sortedByNewest(): List<Transaction> =
    sortedWith(compareByDescending<Transaction> { it.dateMillis }.thenByDescending { it.id })

// ---------- Hàm định dạng ----------

// 1500000 -> "1.500.000"
fun formatMoney(value: Long): String {
    val digits = kotlin.math.abs(value).toString()
    val grouped = digits.reversed().chunked(3).joinToString(".").reversed()
    return if (value < 0) "-$grouped" else grouped
}

// millis (UTC) -> "12/04/2025"
fun formatDate(millis: Long): String {
    val fmt = SimpleDateFormat("dd/MM/yyyy", Locale.US)
    fmt.timeZone = TimeZone.getTimeZone("UTC")
    return fmt.format(Date(millis))
}

// Tạo mốc 00:00 UTC của một ngày (month: 1..12)
fun utcMillis(year: Int, month: Int, day: Int): Long {
    val cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
    cal.clear()
    cal.set(year, month - 1, day)
    return cal.timeInMillis
}

// Ngày hôm nay (theo giờ máy) quy về 00:00 UTC
fun todayUtcMillis(): Long {
    val now = Calendar.getInstance()
    return utcMillis(
        now.get(Calendar.YEAR),
        now.get(Calendar.MONTH) + 1,
        now.get(Calendar.DAY_OF_MONTH)
    )
}
