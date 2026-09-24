package com.example.myapplication

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalContentColor
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.myapplication.ui.theme.MyApplicationTheme

enum class Tab(val label: String) {
    HOME("Trang chủ"),
    TRANSACTIONS("Giao dịch"),
    STATS("Thống kê"),
    PROFILE("Cá nhân")
}

// Khung chính: nội dung theo tab + thanh điều hướng phía dưới
@Composable
fun MainScaffold(
    tab: Tab,
    onTabChange: (Tab) -> Unit,
    transactions: List<Transaction>,
    onAddClick: () -> Unit,
    onTransactionClick: (Transaction) -> Unit,
    modifier: Modifier = Modifier
) {
    Scaffold(
        modifier = modifier,
        containerColor = Color.White,
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        bottomBar = { AppBottomBar(selected = tab, onTabChange = onTabChange) },
        floatingActionButton = {
            if (tab == Tab.HOME || tab == Tab.TRANSACTIONS) {
                FloatingActionButton(
                    onClick = onAddClick,
                    containerColor = AppColors.Blue,
                    contentColor = Color.White,
                    shape = CircleShape
                ) {
                    Icon(Icons.Filled.Add, contentDescription = "Thêm giao dịch")
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize()
        ) {
            when (tab) {
                Tab.HOME -> HomeTab(transactions, onTransactionClick)
                Tab.TRANSACTIONS -> TransactionsTab(transactions, onTransactionClick)
                Tab.STATS -> PlaceholderTab("Thống kê")
                Tab.PROFILE -> PlaceholderTab("Cá nhân")
            }
        }
    }
}

// ---------- Thanh điều hướng dưới ----------
@Composable
private fun AppBottomBar(selected: Tab, onTabChange: (Tab) -> Unit) {
    NavigationBar(containerColor = Color.White) {
        Tab.values().forEach { item ->
            NavigationBarItem(
                selected = selected == item,
                onClick = { onTabChange(item) },
                icon = { TabIcon(item) },
                label = { Text(item.label, fontSize = 11.sp) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = AppColors.Blue,
                    selectedTextColor = AppColors.Blue,
                    unselectedIconColor = AppColors.Grey,
                    unselectedTextColor = AppColors.Grey,
                    indicatorColor = Color.Transparent
                )
            )
        }
    }
}

// Vẽ icon bằng Canvas cho các icon không có sẵn trong bộ icon cơ bản
// (màu lấy từ LocalContentColor nên tự đổi theo tab được chọn)
@Composable
private fun TabIcon(tab: Tab) {
    val color = LocalContentColor.current
    when (tab) {
        Tab.HOME -> Icon(Icons.Filled.Home, contentDescription = null)
        Tab.PROFILE -> Icon(Icons.Filled.Person, contentDescription = null)

        Tab.TRANSACTIONS -> Canvas(modifier = Modifier.size(24.dp)) {
            for (i in 0..2) {
                val y = size.height * (0.25f + 0.25f * i)
                drawCircle(
                    color = color,
                    radius = size.width * 0.06f,
                    center = Offset(size.width * 0.15f, y)
                )
                drawLine(
                    color = color,
                    start = Offset(size.width * 0.34f, y),
                    end = Offset(size.width * 0.9f, y),
                    strokeWidth = size.width * 0.09f,
                    cap = StrokeCap.Round
                )
            }
        }

        Tab.STATS -> Canvas(modifier = Modifier.size(24.dp)) {
            val barWidth = size.width * 0.2f
            val bottom = size.height * 0.88f
            val bars = listOf(0.12f to 0.40f, 0.40f to 0.72f, 0.68f to 0.55f)
            bars.forEach { (x, heightRatio) ->
                val barHeight = size.height * heightRatio
                drawRoundRect(
                    color = color,
                    topLeft = Offset(size.width * x, bottom - barHeight),
                    size = Size(barWidth, barHeight),
                    cornerRadius = CornerRadius(barWidth * 0.25f)
                )
            }
        }
    }
}

// ---------- Tab Trang chủ (bản rút gọn của màn hình 2) ----------
@Composable
private fun HomeTab(
    transactions: List<Transaction>,
    onTransactionClick: (Transaction) -> Unit
) {
    val income = transactions.filter { it.type == TransactionType.INCOME }.sumOf { it.amount }
    val expense = transactions.filter { it.type == TransactionType.EXPENSE }.sumOf { it.amount }
    val recent = transactions.sortedByNewest().take(4)

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding(),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 16.dp, bottom = 96.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Column {
                Text(
                    text = "Xin chào!",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = AppColors.Ink
                )
                Text(
                    text = "Chúc bạn một ngày quản lý chi tiêu hiệu quả",
                    fontSize = 14.sp,
                    color = AppColors.Grey
                )
            }
        }

        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(20.dp))
                    .background(AppColors.Blue)
                    .padding(20.dp)
            ) {
                Text(
                    text = "Số dư hiện tại",
                    color = Color.White.copy(alpha = 0.8f),
                    fontSize = 13.sp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "${formatMoney(income - expense)} đ",
                    color = Color.White,
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }

        item {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SummaryCard(
                    label = "↑ Thu nhập",
                    amount = income,
                    accent = AppColors.Green,
                    background = Color(0xFFE6F6EC),
                    modifier = Modifier.weight(1f)
                )
                SummaryCard(
                    label = "↓ Chi tiêu",
                    amount = expense,
                    accent = AppColors.Red,
                    background = Color(0xFFFDE8EB),
                    modifier = Modifier.weight(1f)
                )
            }
        }

        item {
            Text(
                text = "Chi tiêu gần đây",
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = AppColors.Ink,
                modifier = Modifier.padding(top = 8.dp)
            )
        }

        items(recent, key = { it.id }) { transaction ->
            TransactionRow(transaction) { onTransactionClick(transaction) }
        }
    }
}

@Composable
private fun SummaryCard(
    label: String,
    amount: Long,
    accent: Color,
    background: Color,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(background)
            .padding(14.dp)
    ) {
        Text(text = label, color = accent, fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "${formatMoney(amount)} đ",
            color = AppColors.Ink,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

// ---------- Tab Giao dịch (bản rút gọn của màn hình 3) ----------
@Composable
private fun TransactionsTab(
    transactions: List<Transaction>,
    onTransactionClick: (Transaction) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        Text(
            text = "Giao dịch",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = AppColors.Ink,
            modifier = Modifier.padding(start = 20.dp, top = 16.dp, bottom = 12.dp)
        )

        if (transactions.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Chưa có giao dịch nào", color = AppColors.Grey)
            }
        } else {
            LazyColumn(
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 96.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(transactions.sortedByNewest(), key = { it.id }) { transaction ->
                    TransactionRow(transaction) { onTransactionClick(transaction) }
                }
            }
        }
    }
}

// Một dòng giao dịch (bấm vào để mở màn hình Sửa giao dịch)
@Composable
fun TransactionRow(transaction: Transaction, onClick: () -> Unit) {
    val isExpense = transaction.type == TransactionType.EXPENSE

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(AppColors.FieldBg)
            .clickable(onClick = onClick)
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        CategoryBadge(category = transaction.category)
        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = transaction.category.name,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                color = AppColors.Ink
            )
            Text(
                text = buildString {
                    append(formatDate(transaction.dateMillis))
                    if (transaction.note.isNotBlank()) append(" · ${transaction.note}")
                },
                fontSize = 12.sp,
                color = AppColors.Grey,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }

        Spacer(modifier = Modifier.width(8.dp))

        Text(
            text = (if (isExpense) "-" else "+") + formatMoney(transaction.amount) + " đ",
            color = if (isExpense) AppColors.Red else AppColors.Green,
            fontSize = 14.sp,
            fontWeight = FontWeight.Bold
        )
    }
}

// ---------- Tab chưa hoàn thiện (Thống kê, Cá nhân) ----------
@Composable
private fun PlaceholderTab(title: String) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = title,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = AppColors.Ink
            )
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = "Màn hình này sẽ được hoàn thiện sau",
                fontSize = 14.sp,
                color = AppColors.Grey,
                textAlign = TextAlign.Center
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun MainScaffoldPreview() {
    MyApplicationTheme {
        MainScaffold(
            tab = Tab.HOME,
            onTabChange = {},
            transactions = sampleTransactions(),
            onAddClick = {},
            onTransactionClick = {}
        )
    }
}
