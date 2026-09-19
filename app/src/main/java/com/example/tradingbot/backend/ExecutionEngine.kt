package com.example.tradingbot.backend

import android.util.Log
import java.math.BigDecimal

/**
 * Handles the actual routing of orders to brokers.
 * Must only be called after RiskManager approval.
 */
class ExecutionEngine(private val riskManager: RiskManager) {

    fun executeOrder(request: RiskManager.OrderRequest) {
        val riskResult = riskManager.validateOrder(request)
        
        if (riskResult.isAllowed) {
            sendToBroker(request)
        } else {
            Log.e("ExecutionEngine", "ORDER REJECTED BY RISK: ${riskResult.reason}")
        }
    }

    private fun sendToBroker(request: RiskManager.OrderRequest) {
        // Mock broker API interaction
        Log.i("ExecutionEngine", "ROUTING ORDER TO BROKER: ${request.side} ${request.quantity} ${request.symbol} @ ${request.price}")
    }
}
