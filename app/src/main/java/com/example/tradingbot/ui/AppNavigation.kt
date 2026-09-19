package com.example.tradingbot.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Security
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import com.example.tradingbot.ui.theme.TradingBotTheme

enum class Screen(val title: String, val icon: ImageVector) {
    DASHBOARD("Dashboard", Icons.Default.Home),
    BOT_MANAGEMENT("Bots", Icons.Default.Build),
    RISK_CONTROL("Risk", Icons.Default.Security)
}

@Composable
fun MainScaffold() {
    var currentScreen by remember { mutableStateOf(Screen.DASHBOARD) }

    Scaffold(
        bottomBar = {
            NavigationBar {
                Screen.entries.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.title) },
                        label = { Text(screen.title) },
                        selected = currentScreen == screen,
                        onClick = { currentScreen = screen }
                    )
                }
            }
        }
    ) { innerPadding ->
        Surface(modifier = Modifier.padding(innerPadding)) {
            when (currentScreen) {
                Screen.DASHBOARD -> DashboardScreen()
                Screen.BOT_MANAGEMENT -> BotManagementScreen()
                Screen.RISK_CONTROL -> RiskControlScreen()
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 1200, heightDp = 800)
@Composable
fun MainScaffoldPreview() {
    TradingBotTheme {
        MainScaffold()
    }
}
