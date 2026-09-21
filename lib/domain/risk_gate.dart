import 'paper_trading_models.dart';
import 'paper_trading_ports.dart';

class RiskDecision {
  final bool approved;
  final String? reason;

  const RiskDecision.approved() : approved = true, reason = null;
  const RiskDecision.rejected(this.reason) : approved = false;
}

class CentralRiskGate {
  const CentralRiskGate();

  RiskDecision validate({
    required TradeSignal signal,
    required TradingSnapshot snapshot,
    required PaperOrderExecutor executor,
  }) {
    if (snapshot.emergencyStop.active) {
      return const RiskDecision.rejected('Emergency stop is active');
    }
    if (!signal.quantity.isFinite || signal.quantity <= 0) {
      return const RiskDecision.rejected(
        'Quantity must be positive and finite',
      );
    }
    if (!signal.referencePrice.isFinite || signal.referencePrice <= 0) {
      return const RiskDecision.rejected('Price must be positive and finite');
    }
    if (snapshot.processedSignalIds.contains(signal.id) ||
        snapshot.orders.any((order) => order.signalId == signal.id)) {
      return const RiskDecision.rejected('Duplicate signal or order');
    }

    final bot = snapshot.bot;
    final quote = executor.quote(
      side: signal.side,
      quantity: signal.quantity,
      referencePrice: signal.referencePrice,
      feeRate: bot.feeRate,
      slippageRate: bot.slippageRate,
    );
    final orderValue = signal.quantity * quote.price;
    final limits = snapshot.riskSettings;
    if (orderValue > limits.maxOrderValue) {
      return RiskDecision.rejected(
        'Order value exceeds ${limits.maxOrderValue.toStringAsFixed(2)}',
      );
    }
    if (signal.side == TradeSide.buy &&
        orderValue + quote.fee > snapshot.account.cash) {
      return const RiskDecision.rejected('Insufficient paper cash balance');
    }

    final existing = snapshot.openPositions
        .where((position) => position.symbol == signal.symbol)
        .firstOrNull;
    final signedQuantity = signal.side == TradeSide.buy
        ? signal.quantity
        : -signal.quantity;
    final projectedQuantity = (existing?.quantity ?? 0) + signedQuantity;
    final projectedPositionValue =
        projectedQuantity.abs() * signal.referencePrice;
    if (projectedPositionValue > limits.maxPositionValue) {
      return RiskDecision.rejected('Maximum position value would be exceeded');
    }

    final otherExposure = snapshot.openPositions
        .where((position) => position.symbol != signal.symbol)
        .fold<double>(0, (total, position) => total + position.exposure);
    if (otherExposure + projectedPositionValue > limits.maxTotalExposure) {
      return const RiskDecision.rejected('Maximum total exposure exceeded');
    }
    return const RiskDecision.approved();
  }
}
