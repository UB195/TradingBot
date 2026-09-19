package com.example.tradingbot.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.tradingbot.ui.theme.TradingBotTheme

// --- Data Models ---

data class KPICardData(
    val title: String,
    val value: String,
    val change: String? = null,
    val isPositive: Boolean = true,
    val icon: ImageVector
)

data class Position(
    val symbol: String,
    val positionSize: String, // Renamed from size to avoid conflict with Modifier.size
    val entryPrice: String,
    val currentPrice: String,
    val pnl: String,
    val isPositive: Boolean
)

data class Order(
    val time: String,
    val symbol: String,
    val type: String,
    val side: String,
    val status: String,
    val price: String
)

data class Signal(
    val time: String,
    val symbol: String,
    val action: String,
    val reason: String
)

// --- Mock Data ---

val mockKPIs = listOf(
    KPICardData("Portfolio Value", "$124,532.80", "+2.4%", true, Icons.Default.AccountBalance),
    KPICardData("Available Capital", "$42,105.00", null, true, Icons.Default.AccountBalanceWallet),
    KPICardData("Today's P&L", "+$1,240.50", "+1.1%", true, Icons.Default.TrendingUp),
    KPICardData("Overall P&L", "+$24,532.80", "+24.5%", true, Icons.Default.ShowChart),
    KPICardData("Realized P&L", "$18,200.00", null, true, Icons.Default.MonetizationOn),
    KPICardData("Unrealized P&L", "$6,332.80", null, true, Icons.Default.PieChart),
    KPICardData("Drawdown", "-1.2%", null, false, Icons.Default.Warning),
    KPICardData("Risk Exposure", "65%", null, false, Icons.Default.GppMaybe),
    KPICardData("Margin Utilization", "22%", null, true, Icons.Default.Info),
)

val mockPositions = listOf(
    Position("BTC/USDT", "0.5", "$42,000", "$43,500", "+$750", true),
    Position("ETH/USDT", "10", "$2,200", "$2,150", "-$500", false),
    Position("SOL/USDT", "100", "$95", "$102", "+$700", true),
    Position("AAPL", "50", "$180", "$185", "+$250", true),
)

val mockOrders = listOf(
    Order("10:45:22", "BTC/USDT", "Limit", "BUY", "Filled", "$43,450"),
    Order("10:30:15", "ETH/USDT", "Market", "SELL", "Filled", "$2,155"),
    Order("09:15:00", "SOL/USDT", "Limit", "BUY", "Rejected", "$92"),
)

val mockSignals = listOf(
    Signal("11:00", "BTC/USDT", "BUY", "RSI Oversold + Support"),
    Signal("10:55", "ETH/USDT", "HOLD", "Volatility High"),
    Signal("10:40", "TSLA", "SELL", "Resistance Touch"),
)

// --- UI Components ---

@Composable
fun DashboardScreen() {
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            HeaderSection()
            Spacer(modifier = Modifier.height(16.dp))
            
            Row(modifier = Modifier.fillMaxSize()) {
                // Left Column - Main Content
                Column(modifier = Modifier.weight(3f)) {
                    KPIGrid()
                    Spacer(modifier = Modifier.height(16.dp))
                    Row(modifier = Modifier.fillMaxWidth()) {
                        ChartCard("Portfolio Equity Curve", Modifier.weight(1f))
                        Spacer(modifier = Modifier.width(16.dp))
                        ChartCard("Drawdown Chart", Modifier.weight(1f))
                    }
                    Spacer(modifier = Modifier.height(16.dp))
                    Row(modifier = Modifier.fillMaxWidth()) {
                        ActivePositionsCard(Modifier.weight(1.5f))
                        Spacer(modifier = Modifier.width(16.dp))
                        RecentOrdersCard(Modifier.weight(1f))
                    }
                }
                
                Spacer(modifier = Modifier.width(16.dp))
                
                // Right Column - Sidebar
                Column(modifier = Modifier.weight(1f)) {
                    MarketStatusCard()
                    Spacer(modifier = Modifier.height(16.dp))
                    LiveSignalsCard()
                    Spacer(modifier = Modifier.height(16.dp))
                    BotStatusCard()
                    Spacer(modifier = Modifier.height(16.dp))
                    RiskAlertsCard()
                    Spacer(modifier = Modifier.height(16.dp))
                    KillSwitchButton()
                }
            }
        }
    }
}

@Composable
fun HeaderSection() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "Trading Command Center",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = "Account: TRADER_PRO_01 | Last Update: 11:05:42 AM",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.outline
            )
        }
        
        Row(verticalAlignment = Alignment.CenterVertically) {
            StatusIndicator("Broker", true)
            Spacer(modifier = Modifier.width(16.dp))
            StatusIndicator("Data", true)
            Spacer(modifier = Modifier.width(16.dp))
            Button(onClick = { /* Refresh */ }) {
                Icon(Icons.Default.Refresh, contentDescription = "Refresh")
                Spacer(modifier = Modifier.width(8.dp))
                Text("Refresh")
            }
        }
    }
}

@Composable
fun StatusIndicator(label: String, isConnected: Boolean) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .background(if (isConnected) Color.Green else Color.Red, RoundedCornerShape(4.dp))
        )
        Spacer(modifier = Modifier.width(4.dp))
        Text(text = label, style = MaterialTheme.typography.bodySmall)
    }
}

@Composable
fun KPIGrid() {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 200.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
        modifier = Modifier.heightIn(max = 280.dp) 
    ) {
        items(mockKPIs) { kpi ->
            KPICard(kpi)
        }
    }
}

@Composable
fun KPICard(data: KPICardData) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(text = data.title, style = MaterialTheme.typography.labelMedium)
                Icon(data.icon, contentDescription = null, modifier = Modifier.size(16.dp))
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = data.value, style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
            data.change?.let {
                Text(
                    text = it,
                    style = MaterialTheme.typography.bodySmall,
                    color = if (data.isPositive) Color(0xFF4CAF50) else Color(0xFFF44336)
                )
            }
        }
    }
}

@Composable
fun ChartCard(title: String, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.height(200.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(16.dp))
            MockChart()
        }
    }
}

@Composable
fun MockChart() {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val path = Path().apply {
            moveTo(0f, size.height * 0.8f)
            lineTo(size.width * 0.2f, size.height * 0.6f)
            lineTo(size.width * 0.4f, size.height * 0.7f)
            lineTo(size.width * 0.6f, size.height * 0.4f)
            lineTo(size.width * 0.8f, size.height * 0.5f)
            lineTo(size.width, size.height * 0.2f)
        }
        drawPath(
            path = path,
            color = Color(0xFF2196F3),
            style = Stroke(width = 2.dp.toPx())
        )
    }
}

@Composable
fun ActivePositionsCard(modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.height(300.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(text = "Active Positions", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                Text(text = "Count: ${mockPositions.size}", style = MaterialTheme.typography.bodySmall)
            }
            Spacer(modifier = Modifier.height(8.dp))
            LazyColumn {
                item {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Symbol", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        Text("Size", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        Text("Entry", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        Text("Current", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        Text("PnL", fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                    }
                    HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp))
                }
                items(mockPositions) { pos ->
                    Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text(pos.symbol, modifier = Modifier.weight(1f))
                        Text(pos.positionSize, modifier = Modifier.weight(1f))
                        Text(pos.entryPrice, modifier = Modifier.weight(1f))
                        Text(pos.currentPrice, modifier = Modifier.weight(1f))
                        Text(
                            text = pos.pnl,
                            color = if (pos.isPositive) Color(0xFF4CAF50) else Color(0xFFF44336),
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun RecentOrdersCard(modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.height(300.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "Recent Orders", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            LazyColumn {
                items(mockOrders) { order ->
                    Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                        Column {
                            Text(order.symbol, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Bold)
                            Text(order.time, style = MaterialTheme.typography.bodySmall)
                        }
                        Text(order.side, color = if(order.side == "BUY") Color.Green else Color.Red)
                        Text(order.status)
                    }
                    HorizontalDivider()
                }
            }
        }
    }
}

@Composable
fun MarketStatusCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "Market Status", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            MarketStatusRow("Market Status", "OPEN", Color.Green)
            MarketStatusRow("Market Regime", "BULLISH", Color.Cyan)
            MarketStatusRow("VIX Index", "14.2", Color.White)
        }
    }
}

@Composable
fun MarketStatusRow(label: String, value: String, valueColor: Color) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, style = MaterialTheme.typography.bodySmall)
        Text(value, style = MaterialTheme.typography.bodySmall, color = valueColor, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun LiveSignalsCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "Live Trading Signals", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            mockSignals.forEach { signal ->
                Row(modifier = Modifier.padding(vertical = 4.dp)) {
                    Icon(Icons.Default.Notifications, contentDescription = null, modifier = Modifier.size(16.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Column {
                        Text("${signal.symbol}: ${signal.action}", style = MaterialTheme.typography.bodySmall, fontWeight = FontWeight.Bold)
                        Text(signal.reason, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.outline)
                    }
                }
            }
        }
    }
}

@Composable
fun BotStatusCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "System Status", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            Text("Running Bots: 3 / 5", style = MaterialTheme.typography.bodySmall)
            LinearProgressIndicator(progress = { 0.6f }, modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp))
            Spacer(modifier = Modifier.height(4.dp))
            Text("Orders Today: 124", style = MaterialTheme.typography.bodySmall)
            Text("Filled: 120 | Rejected: 4", style = MaterialTheme.typography.bodySmall)
            Spacer(modifier = Modifier.height(4.dp))
            Text("Active Tasks: Executing BTC-MeanReversion", style = MaterialTheme.typography.bodySmall)
        }
    }
}

@Composable
fun RiskAlertsCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Warning, contentDescription = null, tint = MaterialTheme.colorScheme.error)
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = "Risk Alerts", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.error)
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text("• High Slippage on ETH/USDT", style = MaterialTheme.typography.bodySmall)
            Text("• Margin usage > 20%", style = MaterialTheme.typography.bodySmall)
        }
    }
}

@Composable
fun KillSwitchButton() {
    Button(
        onClick = { 
            com.example.tradingbot.backend.TradingSystem.triggerEmergencyStop()
        },
        modifier = Modifier.fillMaxWidth().height(60.dp),
        colors = ButtonDefaults.buttonColors(containerColor = Color.Red),
        shape = RoundedCornerShape(8.dp)
    ) {
        Icon(Icons.Default.Close, contentDescription = null)
        Spacer(modifier = Modifier.width(8.dp))
        Text("EMERGENCY KILL SWITCH", fontWeight = FontWeight.ExtraBold, fontSize = 16.sp)
    }
}

@Preview(showBackground = true, widthDp = 1200, heightDp = 800)
@Composable
fun DashboardPreview() {
    TradingBotTheme {
        DashboardScreen()
    }
}
