package com.example.tradingbot.backend

import android.util.Log
import java.math.BigDecimal

/**
 * The RiskManager is the final gatekeeper in the system.
 * It conceptually sits between the Strategy modules and the Order Execution Engine.
 */
class RiskManager {
    
    data class OrderRequest(
        val symbol: String,
        val side: String, // BUY, SELL
        val quantity: BigDecimal,
        val price: BigDecimal,
        val type: String // MARKET, LIMIT
    )

    data class RiskCheckResult(
        val isAllowed: Boolean,
        val reason: String? = null
    )

    // Hardcoded mock limits for now
    private val maxDailyLoss = BigDecimal("2000.00")
    private var currentDailyLoss = BigDecimal("0.00")
    
    private val maxPositionSize = BigDecimal("50000.00")
    private var currentOpenPositionsValue = BigDecimal("142500.00") // From mock data

    private val maxLeverage = BigDecimal("5.0")
    private val currentLeverage = BigDecimal("3.4")

    /**
     * Validates an order request against all active risk limits.
     * This method must be called before any order is sent to the broker.
     */
    fun validateOrder(request: OrderRequest): RiskCheckResult {
        Log.d("RiskManager", "Validating order: $request")

        // 1. Check Max Position Size
        val orderValue = request.quantity.multiply(request.price)
        if (orderValue > maxPositionSize) {
            return RiskCheckResult(false, "Order value ($orderValue) exceeds max position size ($maxPositionSize)")
        }

        // 2. Check Daily Loss Limit
        if (currentDailyLoss >= maxDailyLoss) {
            return RiskCheckResult(false, "Daily loss limit reached ($maxDailyLoss). Trading halted.")
        }

        // 3. Check Leverage
        if (currentLeverage >= maxLeverage) {
            return RiskCheckResult(false, "Max leverage reached ($maxLeverage). Reduce exposure first.")
        }

        // 4. Check Symbol Exposure (Conceptual)
        // ...

        Log.i("RiskManager", "Order approved by Risk Firewall")
        return RiskCheckResult(true)
    }

    /**
     * Emergency method to halt all activity.
     */
    fun emergencyHalt() {
        Log.e("RiskManager", "EMERGENCY HALT TRIGGERED. Killing all active orders and bots.")
        // In a real system, this would broadcast a signal to all components
    }
}
