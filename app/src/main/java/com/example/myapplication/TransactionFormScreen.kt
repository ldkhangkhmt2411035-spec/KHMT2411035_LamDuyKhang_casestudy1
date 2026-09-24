package com.example.myapplication

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.OffsetMapping
import androidx.compose.ui.text.input.TransformedText
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.myapplication.ui.theme.MyApplicationTheme

// ================= Màn hình 4: Thêm giao dịch =================
@Composable
fun AddTransactionScreen(
    onBack: () -> Unit,
    onSave: (Transaction) -> Unit,
    modifier: Modifier = Modifier
) {
    TransactionFormScreen(
        title = "Thêm giao dịch",
        initial = null,
        onBack = onBack,
        onSave = onSave,
        modifier = modifier
    )
}

// ================= Màn hình 5: Sửa giao dịch =================
@Composable
fun EditTransactionScreen(
    transaction: Transaction,
    onBack: () -> Unit,
    onSave: (Transaction) -> Unit,
    modifier: Modifier = Modifier
) {
    TransactionFormScreen(
        title = "Sửa giao dịch",
        initial = transaction,
        onBack = onBack,
        onSave = onSave,
        modifier = modifier
    )
}

// Form dùng chung: initial == null -> thêm mới, khác null -> điền sẵn dữ liệu để sửa
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TransactionFormScreen(
    title: String,
    initial: Transaction?,
    onBack: () -> Unit,
    onSave: (Transaction) -> Unit,
    modifier: Modifier = Modifier
) {
    var type by remember { mutableStateOf(initial?.type ?: TransactionType.EXPENSE) }
    var category by remember { mutableStateOf(initial?.category ?: Categories.expense.first()) }
    var amountDigits by remember { mutableStateOf(initial?.amount?.toString() ?: "") }
    var dateMillis by remember { mutableStateOf(initial?.dateMillis ?: todayUtcMillis()) }
    var note by remember { mutableStateOf(initial?.note ?: "") }
    var showDatePicker by remember { mutableStateOf(false) }
    var showError by remember { mutableStateOf(false) }

    val amountValue = amountDigits.toLongOrNull() ?: 0L
    val amountError = showError && amountValue <= 0L

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color.White)
            .statusBarsPadding()
            .navigationBarsPadding()
            .imePadding()
    ) {
        FormTopBar(title = title, onBack = onBack)

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
        ) {
            Spacer(modifier = Modifier.height(8.dp))

            // Chi tiêu / Thu nhập
            TypeToggle(
                selected = type,
                onSelected = { newType ->
                    if (newType != type) {
                        type = newType
                        category = Categories.of(newType).first()
                    }
                }
            )

            Spacer(modifier = Modifier.height(20.dp))

            // Danh mục
            FieldLabel("Danh mục")
            CategoryDropdown(
                type = type,
                selected = category,
                onSelected = { category = it }
            )

            Spacer(modifier = Modifier.height(18.dp))

            // Số tiền
            FieldLabel("Số tiền")
            OutlinedTextField(
                value = amountDigits,
                onValueChange = { input ->
                    amountDigits = input
                        .filter { it in '0'..'9' }
                        .trimStart('0')
                        .take(12)
                },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("Nhập số tiền", color = AppColors.Grey) },
                trailingIcon = {
                    Text("đ", color = AppColors.Grey, modifier = Modifier.padding(end = 4.dp))
                },
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                visualTransformation = ThousandsTransformation,
                isError = amountError,
                supportingText = {
                    if (amountError) Text("Vui lòng nhập số tiền hợp lệ")
                },
                shape = RoundedCornerShape(12.dp),
                colors = fieldColors()
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Ngày giao dịch
            FieldLabel("Ngày giao dịch")
            ClickableField(onClick = { showDatePicker = true }) {
                Text(
                    text = formatDate(dateMillis),
                    modifier = Modifier.weight(1f),
                    color = AppColors.Ink,
                    fontSize = 15.sp
                )
                Icon(
                    imageVector = Icons.Filled.DateRange,
                    contentDescription = "Chọn ngày",
                    tint = AppColors.Grey
                )
            }

            Spacer(modifier = Modifier.height(18.dp))

            // Ghi chú
            FieldLabel("Ghi chú")
            OutlinedTextField(
                value = note,
                onValueChange = { note = it.take(200) },
                modifier = Modifier.fillMaxWidth(),
                placeholder = { Text("Nhập ghi chú (tùy chọn)", color = AppColors.Grey) },
                minLines = 3,
                maxLines = 5,
                shape = RoundedCornerShape(12.dp),
                colors = fieldColors()
            )

            Spacer(modifier = Modifier.height(16.dp))
        }

        // Nút Lưu
        Button(
            onClick = {
                if (amountValue <= 0L) {
                    showError = true
                } else {
                    onSave(
                        Transaction(
                            id = initial?.id ?: 0,
                            type = type,
                            category = category,
                            amount = amountValue,
                            dateMillis = dateMillis,
                            note = note.trim()
                        )
                    )
                }
            },
            modifier = Modifier
                .padding(horizontal = 20.dp, vertical = 16.dp)
                .fillMaxWidth()
                .height(52.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = AppColors.Blue)
        ) {
            Text(
                text = "Lưu",
                color = Color.White,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }

    // Hộp thoại chọn ngày
    if (showDatePicker) {
        val pickerState = rememberDatePickerState(initialSelectedDateMillis = dateMillis)
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    pickerState.selectedDateMillis?.let { dateMillis = it }
                    showDatePicker = false
                }) { Text("Chọn") }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("Hủy") }
            }
        ) {
            DatePicker(state = pickerState)
        }
    }
}

// ---------- Các thành phần nhỏ ----------

@Composable
private fun FormTopBar(title: String, onBack: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp),
        contentAlignment = Alignment.Center
    ) {
        IconButton(
            onClick = onBack,
            modifier = Modifier.align(Alignment.CenterStart)
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Quay lại",
                tint = AppColors.Ink
            )
        }
        Text(
            text = title,
            fontSize = 17.sp,
            fontWeight = FontWeight.SemiBold,
            color = AppColors.Ink
        )
    }
}

@Composable
private fun TypeToggle(
    selected: TransactionType,
    onSelected: (TransactionType) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(AppColors.ToggleBg)
            .padding(4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        ToggleItem(
            text = "Chi tiêu",
            selected = selected == TransactionType.EXPENSE,
            activeColor = AppColors.Red,
            modifier = Modifier.weight(1f),
            onClick = { onSelected(TransactionType.EXPENSE) }
        )
        ToggleItem(
            text = "Thu nhập",
            selected = selected == TransactionType.INCOME,
            activeColor = AppColors.Green,
            modifier = Modifier.weight(1f),
            onClick = { onSelected(TransactionType.INCOME) }
        )
    }
}

@Composable
private fun ToggleItem(
    text: String,
    selected: Boolean,
    activeColor: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .height(44.dp)
            .clip(RoundedCornerShape(10.dp))
            .background(if (selected) activeColor else Color.Transparent)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            color = if (selected) Color.White else AppColors.Grey,
            fontWeight = FontWeight.Bold,
            fontSize = 14.sp
        )
    }
}

@Composable
private fun FieldLabel(text: String) {
    Text(
        text = text,
        fontSize = 13.sp,
        fontWeight = FontWeight.SemiBold,
        color = AppColors.Ink,
        modifier = Modifier.padding(bottom = 8.dp)
    )
}

// Ô bấm được (dùng cho Danh mục và Ngày) - giống giao diện ô nhập
@Composable
private fun ClickableField(
    onClick: () -> Unit,
    content: @Composable RowScope.() -> Unit
) {
    val shape = RoundedCornerShape(12.dp)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(shape)
            .background(AppColors.FieldBg)
            .border(1.dp, AppColors.Border, shape)
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        content = content
    )
}

@Composable
private fun CategoryDropdown(
    type: TransactionType,
    selected: Category,
    onSelected: (Category) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    Box {
        ClickableField(onClick = { expanded = true }) {
            CategoryBadge(category = selected, size = 30.dp)
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                text = selected.name,
                modifier = Modifier.weight(1f),
                color = AppColors.Ink,
                fontSize = 15.sp
            )
            Icon(
                imageVector = Icons.Filled.KeyboardArrowDown,
                contentDescription = null,
                tint = AppColors.Grey
            )
        }

        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            Categories.of(type).forEach { item ->
                DropdownMenuItem(
                    text = { Text(item.name) },
                    leadingIcon = { CategoryBadge(category = item, size = 30.dp) },
                    onClick = {
                        onSelected(item)
                        expanded = false
                    }
                )
            }
        }
    }
}

// Ô vuông bo góc chứa biểu tượng danh mục (dùng lại ở danh sách giao dịch)
@Composable
fun CategoryBadge(category: Category, size: Dp = 44.dp) {
    Box(
        modifier = Modifier
            .size(size)
            .clip(RoundedCornerShape(size * 0.3f))
            .background(category.color.copy(alpha = 0.15f)),
        contentAlignment = Alignment.Center
    ) {
        Text(text = category.emoji, fontSize = (size.value * 0.5f).sp)
    }
}

@Composable
private fun fieldColors() = OutlinedTextFieldDefaults.colors(
    focusedContainerColor = AppColors.FieldBg,
    unfocusedContainerColor = AppColors.FieldBg,
    focusedBorderColor = AppColors.Blue,
    unfocusedBorderColor = AppColors.Border,
    focusedTextColor = AppColors.Ink,
    unfocusedTextColor = AppColors.Ink,
    cursorColor = AppColors.Blue
)

// Hiển thị "1500000" thành "1.500.000" ngay khi gõ (giá trị lưu vẫn là chuỗi số thuần)
object ThousandsTransformation : VisualTransformation {
    override fun filter(text: AnnotatedString): TransformedText {
        val digits = text.text
        val formatted = buildString {
            digits.forEachIndexed { index, c ->
                if (index > 0 && (digits.length - index) % 3 == 0) append('.')
                append(c)
            }
        }

        val mapping = object : OffsetMapping {
            override fun originalToTransformed(offset: Int): Int {
                val separatorsBefore = (0 until offset).count { i ->
                    i > 0 && (digits.length - i) % 3 == 0
                }
                return offset + separatorsBefore
            }

            override fun transformedToOriginal(offset: Int): Int {
                return formatted.take(offset).count { it != '.' }
            }
        }

        return TransformedText(AnnotatedString(formatted), mapping)
    }
}

// ---------- Preview ----------
@Preview(showBackground = true)
@Composable
fun AddTransactionScreenPreview() {
    MyApplicationTheme {
        AddTransactionScreen(onBack = {}, onSave = {})
    }
}

@Preview(showBackground = true)
@Composable
fun EditTransactionScreenPreview() {
    MyApplicationTheme {
        EditTransactionScreen(
            transaction = sampleTransactions().first(),
            onBack = {},
            onSave = {}
        )
    }
}
