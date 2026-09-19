package com.example.tradingbot.backend

import java.math.BigDecimal

/**
 * Base class for all trading strategies.
 * Strategies generate signals but cannot execute orders directly.
 */
abstract class Strategy(val name: String, val id: String) {
    abstract fun onMarketData(symbol: String, price: BigDecimal)
}

class MeanReversionStrategy(
    id: String,
    private val executionEngine: ExecutionEngine
) : Strategy("Mean Reversion", id) {

    override fun onMarketData(symbol: String, price: BigDecimal) {
        // Conceptually, if price < mean - 2*stdDev -> BUY
        val mockOrder = RiskManager.OrderRequest(
            symbol = symbol,
            side = "BUY",
            quantity = BigDecimal("0.1"),
            price = price,
            type = "MARKET"
        )
        
        executionEngine.executeOrder(mockOrder)
    }
}
