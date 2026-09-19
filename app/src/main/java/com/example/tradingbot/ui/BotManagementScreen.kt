package com.example.tradingbot.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.tradingbot.ui.theme.TradingBotTheme

// --- Data Models ---

enum class BotStatus(val label: String, val color: Color) {
    RUNNING("Running", Color(0xFF4CAF50)),
    PAUSED("Paused", Color(0xFFFFC107)),
    STOPPED("Stopped", Color(0xFF9E9E9E)),
    ERROR("Error", Color(0xFFF44336)),
    WAITING("Waiting", Color(0xFF2196F3))
}

data class BotData(
    val name: String,
    val id: String,
    val strategy: String,
    val market: String,
    val instrument: String,
    val timeframe: String,
    val status: BotStatus,
    val allocatedCapital: String,
    val riskPerTrade: String,
    val todayPnl: String,
    val totalPnl: String,
    val winRate: String,
    val drawdown: String,
    val tradesToday: Int,
    val lastSignal: String,
    val signalConfidence: String,
    val version: String,
    val lastUpdated: String
)

// --- Mock Data ---

val mockBots = listOf(
    BotData(
        "Alpha Trend Follower", "BOT-001", "Trend Following", "Crypto", "BTC/USDT", "1h",
        BotStatus.RUNNING, "$25,000", "1.0%", "+$450.20", "+$4,200", "62%", "4.2%", 5, "BUY", "85%", "v2.4.1", "2 mins ago"
    ),
    BotData(
        "Mean Reversion Pro", "BOT-002", "Mean Reversion", "Forex", "EUR/USD", "15m",
        BotStatus.PAUSED, "$10,000", "0.5%", "-$12.40", "+$850", "58%", "2.1%", 2, "NEUTRAL", "40%", "v1.2.0", "15 mins ago"
    ),
    BotData(
        "Scalper Suite", "BOT-003", "Scalping", "Stocks", "AAPL", "1m",
        BotStatus.ERROR, "$50,000", "0.2%", "$0.00", "-$120", "45%", "0.5%", 0, "NONE", "0%", "v3.0.0", "1 hour ago"
    ),
    BotData(
        "Ether Arbitrage", "BOT-004", "Arbitrage", "Crypto", "ETH/USDT", "Tick",
        BotStatus.RUNNING, "$100,000", "0.1%", "+$1,200", "+$12,450", "94%", "1.2%", 42, "BUY", "98%", "v4.2.2", "Just now"
    ),
    BotData(
        "Gold Miner", "BOT-005", "Commodity Flow", "Metals", "XAU/USD", "4h",
        BotStatus.WAITING, "$15,000", "1.5%", "$0.00", "$0.00", "0%", "0%", 0, "NONE", "0%", "v1.0.1", "5 hours ago"
    )
)

// --- UI Components ---

@Composable
fun BotManagementScreen() {
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            BotManagementHeader()
            Spacer(modifier = Modifier.height(16.dp))
            FilterSection()
            Spacer(modifier = Modifier.height(16.dp))
            BotList()
        }
    }
}

@Composable
fun BotManagementHeader() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "Bot Fleet Management",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Manage and monitor your automated trading strategies",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.outline
            )
        }
        
        Row {
            Button(
                onClick = { /* New Bot */ },
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Deploy New Bot")
            }
            Spacer(modifier = Modifier.width(12.dp))
            Button(
                onClick = { 
                    com.example.tradingbot.backend.TradingSystem.triggerEmergencyStop()
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
            ) {
                Icon(Icons.Default.Warning, contentDescription = null) // Using Warning instead of Dangerous for safety in standard icons
                Spacer(modifier = Modifier.width(8.dp))
                Text("HALT ALL BOTS")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterSection() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        FilterChip(selected = true, onClick = {}, label = { Text("All Bots (5)") })
        FilterChip(selected = false, onClick = {}, label = { Text("Market: Crypto") })
        FilterChip(selected = false, onClick = {}, label = { Text("Strategy: Scalping") })
        FilterChip(selected = false, onClick = {}, label = { Text("Status: Running") })
        FilterChip(selected = false, onClick = {}, label = { Text("Risk: Low") })
        
        Spacer(modifier = Modifier.weight(1f))
        
        OutlinedTextField(
            value = "",
            onValueChange = {},
            placeholder = { Text("Search bots by ID or Name...") },
            modifier = Modifier.width(300.dp),
            leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
            singleLine = true
        )
    }
}

@Composable
fun BotList() {
    LazyColumn(
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(mockBots) { bot ->
            BotCard(bot)
        }
    }
}

@Composable
fun BotCard(bot: BotData) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            // Top Row: Header Info
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = bot.name,
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.width(12.dp))
                        StatusBadge(bot.status)
                    }
                    Text(
                        text = "${bot.id} | ${bot.strategy} | ${bot.market} | ${bot.instrument} | ${bot.timeframe}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.outline
                    )
                }
                
                BotActionButtons(bot.status)
            }
            
            HorizontalDivider(modifier = Modifier.padding(vertical = 16.dp))
            
            // Middle Section: Performance and Config Metrics
            Row(modifier = Modifier.fillMaxWidth()) {
                MetricItem("Allocated Capital", bot.allocatedCapital, Modifier.weight(1f))
                MetricItem("Risk per Trade", bot.riskPerTrade, Modifier.weight(1f))
                MetricItem("Today's P&L", bot.todayPnl, Modifier.weight(1f), isPnL = true)
                MetricItem("Total P&L", bot.totalPnl, Modifier.weight(1f), isPnL = true)
                MetricItem("Win Rate", bot.winRate, Modifier.weight(1f))
                MetricItem("Drawdown", bot.drawdown, Modifier.weight(1f), isNegative = true)
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Bottom Section: Signals and metadata
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    InfoTag(Icons.Default.Info, "Trades Today: ${bot.tradesToday}") // Using Info as proxy for speed/hub
                    Spacer(modifier = Modifier.width(16.dp))
                    InfoTag(Icons.Default.Notifications, "Last Signal: ${bot.lastSignal} (${bot.signalConfidence})")
                    Spacer(modifier = Modifier.width(16.dp))
                    InfoTag(Icons.Default.Refresh, "Updated: ${bot.lastUpdated}")
                }
                
                Text(
                    text = "Version ${bot.version}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.outline
                )
            }
        }
    }
}

@Composable
fun StatusBadge(status: BotStatus) {
    Surface(
        color = status.color.copy(alpha = 0.1f),
        shape = RoundedCornerShape(4.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, status.color)
    ) {
        Text(
            text = status.label.uppercase(),
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
            style = MaterialTheme.typography.labelSmall,
            color = status.color,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun MetricItem(label: String, value: String, modifier: Modifier = Modifier, isPnL: Boolean = false, isNegative: Boolean = false) {
    val color = when {
        isPnL && value.startsWith("+") -> Color(0xFF4CAF50)
        isPnL && value.startsWith("-") -> Color(0xFFF44336)
        isNegative -> Color(0xFFF44336)
        else -> MaterialTheme.colorScheme.onSurface
    }
    
    Column(modifier = modifier) {
        Text(text = label, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.outline)
        Text(text = value, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Bold, color = color)
    }
}

@Composable
fun InfoTag(icon: ImageVector, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, contentDescription = null, modifier = Modifier.size(14.dp), tint = MaterialTheme.colorScheme.outline)
        Spacer(modifier = Modifier.width(4.dp))
        Text(text = text, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.outline)
    }
}

@Composable
fun BotActionButtons(status: BotStatus) {
    Row {
        if (status == BotStatus.RUNNING) {
            IconButton(onClick = { /* Pause */ }) {
                Icon(Icons.Default.Pause, contentDescription = "Pause", tint = Color(0xFFFFC107))
            }
        } else if (status == BotStatus.PAUSED || status == BotStatus.STOPPED) {
            IconButton(onClick = { /* Start */ }) {
                Icon(Icons.Default.PlayArrow, contentDescription = "Start", tint = Color(0xFF4CAF50))
            }
        }
        
        IconButton(onClick = { /* Stop */ }) {
            Icon(Icons.Default.Stop, contentDescription = "Stop", tint = Color(0xFFF44336))
        }
        
        IconButton(onClick = { /* Edit */ }) {
            Icon(Icons.Default.Edit, contentDescription = "Edit")
        }
        
        IconButton(onClick = { /* More */ }) {
            Icon(Icons.Default.MoreVert, contentDescription = "More")
        }
    }
}

@Preview(showBackground = true, widthDp = 1200, heightDp = 800)
@Composable
fun BotManagementPreview() {
    TradingBotTheme {
        BotManagementScreen()
    }
}
