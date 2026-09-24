package com.example.myapplication

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.myapplication.ui.theme.MyApplicationTheme

// Màn hình 1: Chào mừng
@Composable
fun OnboardingScreen(modifier: Modifier = Modifier, onStartClick: () -> Unit = {}) {
    Box(modifier = modifier.fillMaxSize()) {

        Column(
            modifier = Modifier
                .align(Alignment.Center)
                .padding(horizontal = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            WalletIcon()

            Spacer(modifier = Modifier.height(24.dp))

            Text(
                text = "Expense Manager",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = AppColors.Ink
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = "Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả",
                fontSize = 15.sp,
                color = AppColors.Grey,
                textAlign = TextAlign.Center,
                lineHeight = 22.sp
            )
        }

        Button(
            onClick = onStartClick,
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(horizontal = 24.dp)
                .padding(bottom = 40.dp)
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(28.dp),
            colors = ButtonDefaults.buttonColors(containerColor = AppColors.Blue)
        ) {
            Text(
                text = "Bắt đầu",
                color = Color.White,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun WalletIcon(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier.size(120.dp)) {
        val w = size.width
        val h = size.height

        // Thẻ xanh lá phía sau
        drawRoundRect(
            color = Color(0xFF6FCF97),
            topLeft = Offset(w * 0.18f, h * 0.20f),
            size = Size(w * 0.5f, h * 0.5f),
            cornerRadius = CornerRadius(w * 0.06f)
        )

        // Thân ví xanh dương
        drawRoundRect(
            color = AppColors.Blue,
            topLeft = Offset(w * 0.06f, h * 0.35f),
            size = Size(w * 0.72f, h * 0.45f),
            cornerRadius = CornerRadius(w * 0.09f)
        )

        // Nút tròn trắng (khóa ví)
        drawCircle(
            color = Color.White,
            radius = w * 0.10f,
            center = Offset(w * 0.66f, h * 0.58f)
        )

        // Chấm xanh bên trong nút
        drawCircle(
            color = AppColors.Blue,
            radius = w * 0.045f,
            center = Offset(w * 0.66f, h * 0.58f)
        )
    }
}

@Preview(showBackground = true)
@Composable
fun OnboardingScreenPreview() {
    MyApplicationTheme {
        OnboardingScreen()
    }
}

