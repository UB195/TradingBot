package com.example.tradingbot.backend

import java.math.BigDecimal

/**
 * Orchestrator that wires up the backend modules.
 */
object TradingSystem {
    private val riskManager = RiskManager()
    private val executionEngine = ExecutionEngine(riskManager)
    
    private val activeStrategies = mutableListOf<Strategy>()

    init {
        // Initialize with one bot
        activeStrategies.add(MeanReversionStrategy("BOT-001", executionEngine))
    }

    fun handlePriceTick(symbol: String, price: BigDecimal) {
        activeStrategies.forEach { it.onMarketData(symbol, price) }
    }

    fun triggerEmergencyStop() {
        riskManager.emergencyHalt()
    }
}
