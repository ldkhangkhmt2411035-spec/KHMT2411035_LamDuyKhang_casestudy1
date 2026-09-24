package com.example.myapplication

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.example.myapplication.ui.theme.MyApplicationTheme

// Các màn hình "toàn trang" của ứng dụng
sealed interface Screen {
    object Welcome : Screen                              // 1. Chào mừng
    object Main : Screen                                 // 2, 3, 6, 7: có thanh điều hướng dưới
    object Add : Screen                                  // 4. Thêm giao dịch
    data class Edit(val transactionId: Int) : Screen     // 5. Sửa giao dịch
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.White
                ) {
                    ExpenseApp()
                }
            }
        }
    }
}

@Composable
fun ExpenseApp() {
    var screen by remember { mutableStateOf<Screen>(Screen.Welcome) }
    var tab by remember { mutableStateOf(Tab.HOME) }
    var nextId by remember { mutableIntStateOf(100) }
    val transactions = remember {
        mutableStateListOf<Transaction>().apply { addAll(sampleTransactions()) }
    }

    when (val current = screen) {
        Screen.Welcome -> OnboardingScreen(
            onStartClick = { screen = Screen.Main }
        )

        Screen.Main -> MainScaffold(
            tab = tab,
            onTabChange = { tab = it },
            transactions = transactions,
            onAddClick = { screen = Screen.Add },
            onTransactionClick = { screen = Screen.Edit(it.id) }
        )

        Screen.Add -> {
            BackHandler { screen = Screen.Main }
            AddTransactionScreen(
                onBack = { screen = Screen.Main },
                onSave = { newTransaction ->
                    transactions.add(newTransaction.copy(id = nextId))
                    nextId++
                    screen = Screen.Main
                }
            )
        }

        is Screen.Edit -> {
            BackHandler { screen = Screen.Main }
            val target = transactions.firstOrNull { it.id == current.transactionId }
            if (target != null) {
                EditTransactionScreen(
                    transaction = target,
                    onBack = { screen = Screen.Main },
                    onSave = { updated ->
                        val index = transactions.indexOfFirst { it.id == updated.id }
                        if (index >= 0) transactions[index] = updated
                        screen = Screen.Main
                    }
                )
            }
        }
    }
}
