package com.example.tradingbot.ui

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.tradingbot.ui.theme.TradingBotTheme

// --- Data Models ---

enum class RiskLevel(val label: String, val color: Color, val containerColor: Color) {
    SAFE("SAFE", Color(0xFF4CAF50), Color(0xFFE8F5E9)),
    WARNING("WARNING", Color(0xFFFFC107), Color(0xFFFFFDE7)),
    CRITICAL("CRITICAL", Color(0xFFF44336), Color(0xFFFFEBEE))
}

data class RiskLimit(
    val name: String,
    val currentValue: String,
    val limitValue: String,
    val progress: Float,
    val level: RiskLevel
)

// --- Mock Data ---

val mockRiskLimits = listOf(
    RiskLimit("Max Risk per Trade", "0.8%", "1.0%", 0.8f, RiskLevel.SAFE),
    RiskLimit("Max Daily Loss", "$1,200", "$2,000", 0.6f, RiskLevel.SAFE),
    RiskLimit("Max Weekly Loss", "$4,500", "$5,000", 0.9f, RiskLevel.WARNING),
    RiskLimit("Max Drawdown", "4.2%", "5.0%", 0.84f, RiskLevel.WARNING),
    RiskLimit("Max Position Size", "$45,000", "$50,000", 0.9f, RiskLevel.WARNING),
    RiskLimit("Max Open Positions", "8", "10", 0.8f, RiskLevel.SAFE),
    RiskLimit("Max Leverage", "4.2x", "5.0x", 0.84f, RiskLevel.SAFE),
    RiskLimit("Max Sector Exposure", "28%", "30%", 0.93f, RiskLevel.CRITICAL),
    RiskLimit("Max Instrument Exposure", "$22,000", "$25,000", 0.88f, RiskLevel.WARNING),
    RiskLimit("Max Trades per Day", "42", "100", 0.42f, RiskLevel.SAFE),
    RiskLimit("Max Consecutive Losses", "3", "5", 0.6f, RiskLevel.SAFE),
    RiskLimit("Max Slippage", "0.15%", "0.20%", 0.75f, RiskLevel.SAFE)
)

// --- UI Components ---

@Composable
fun RiskControlScreen() {
    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        Row(modifier = Modifier.fillMaxSize().padding(16.dp)) {
            // Main Content: Risk Limits Configuration
            Column(modifier = Modifier.weight(2.5f)) {
                RiskHeader()
                Spacer(modifier = Modifier.height(24.dp))
                RiskLimitsGrid()
                Spacer(modifier = Modifier.height(24.dp))
                RiskSettingsFooter()
            }
            
            Spacer(modifier = Modifier.width(24.dp))
            
            // Sidebar: Live Monitoring & Alerts
            Column(modifier = Modifier.weight(1f)) {
                RiskStatusPanel()
                Spacer(modifier = Modifier.height(16.dp))
                RiskAlertsPanel()
                Spacer(modifier = Modifier.height(16.dp))
                EmergencyKillPanel()
            }
        }
    }
}

@Composable
fun RiskHeader() {
    Column {
        Text(
            text = "Risk Control Center",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = "Pre-Execution Risk Firewall | Active Gatekeeper",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.outline
        )
    }
}

@Composable
fun RiskLimitsGrid() {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 300.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        items(mockRiskLimits) { limit ->
            RiskLimitCard(limit)
        }
    }
}

@Composable
fun RiskLimitCard(limit: RiskLimit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(text = limit.name, style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold)
                StatusChip(limit.level)
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(text = "Current: ${limit.currentValue}", style = MaterialTheme.typography.bodySmall)
                Text(text = "Limit: ${limit.limitValue}", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.outline)
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            LinearProgressIndicator(
                progress = { limit.progress },
                modifier = Modifier.fillMaxWidth().height(8.dp),
                color = limit.level.color,
                trackColor = limit.level.color.copy(alpha = 0.2f),
                strokeCap = StrokeCap.Round
            )
        }
    }
}

@Composable
fun StatusChip(level: RiskLevel) {
    Surface(
        color = level.containerColor,
        shape = RoundedCornerShape(4.dp),
        modifier = Modifier.border(1.dp, level.color, RoundedCornerShape(4.dp))
    ) {
        Text(
            text = level.label,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
            style = MaterialTheme.typography.labelSmall,
            color = level.color,
            fontWeight = FontWeight.Bold
        )
    }
}

@Composable
fun RiskStatusPanel() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "Exposure Monitoring", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(16.dp))
            
            MonitoringRow("Total Exposure", "$142,500", RiskLevel.SAFE)
            MonitoringRow("Risk Used Today", "$1,240", RiskLevel.SAFE)
            MonitoringRow("Remaining Risk", "$760", RiskLevel.WARNING)
            MonitoringRow("Margin Utilization", "22%", RiskLevel.SAFE)
            MonitoringRow("Current Leverage", "3.4x", RiskLevel.SAFE)
            MonitoringRow("Open Positions", "8 / 10", RiskLevel.WARNING)
        }
    }
}

@Composable
fun MonitoringRow(label: String, value: String, level: RiskLevel) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label, style = MaterialTheme.typography.bodyMedium)
        Text(value, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Bold, color = level.color)
    }
}

@Composable
fun RiskAlertsPanel() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "Risk Alerts Log", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            Spacer(modifier = Modifier.height(8.dp))
            
            AlertItem("Sector Limit: TECH exposure reached 28%", RiskLevel.CRITICAL)
            AlertItem("Weekly Loss threshold (90%) reached", RiskLevel.WARNING)
            AlertItem("Slippage detected on ETH/USDT: 0.12%", RiskLevel.SAFE)
        }
    }
}

@Composable
fun AlertItem(message: String, level: RiskLevel) {
    Row(modifier = Modifier.padding(vertical = 4.dp), verticalAlignment = Alignment.Top) {
        Icon(Icons.Default.Warning, contentDescription = null, tint = level.color, modifier = Modifier.size(16.dp))
        Spacer(modifier = Modifier.width(8.dp))
        Text(message, style = MaterialTheme.typography.bodySmall)
    }
}

@Composable
fun EmergencyKillPanel() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFB71C1C)),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(Icons.Default.Close, contentDescription = null, tint = Color.White, modifier = Modifier.size(48.dp))
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                "EMERGENCY KILL SWITCH",
                color = Color.White,
                fontWeight = FontWeight.ExtraBold,
                fontSize = 18.sp
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                "Immediately closes all positions & halts all bots.",
                color = Color.White.copy(alpha = 0.8f),
                style = MaterialTheme.typography.bodySmall
            )
            Spacer(modifier = Modifier.height(16.dp))
            Button(
                onClick = { 
                    com.example.tradingbot.backend.TradingSystem.triggerEmergencyStop()
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color.White),
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("ACTIVATE NOW", color = Color(0xFFB71C1C), fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun RiskSettingsFooter() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.2f))
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(Icons.Default.Lock, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
            Spacer(modifier = Modifier.width(16.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text("Global Risk Safeguard Active", fontWeight = FontWeight.Bold)
                Text("Manual override requires Multi-Factor Authentication.", style = MaterialTheme.typography.bodySmall)
            }
            Button(onClick = { /* Configure */ }) {
                Text("Edit Risk Profile")
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 1400, heightDp = 900)
@Composable
fun RiskControlPreview() {
    TradingBotTheme {
        RiskControlScreen()
    }
}
