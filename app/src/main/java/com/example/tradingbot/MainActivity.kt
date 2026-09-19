package com.example.tradingbot

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.tradingbot.ui.MainScaffold
import com.example.tradingbot.ui.theme.TradingBotTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            TradingBotTheme {
                MainScaffold()
            }
        }
    }
}
