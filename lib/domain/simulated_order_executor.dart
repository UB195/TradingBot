import 'paper_trading_models.dart';
import 'paper_trading_ports.dart';

class SimulatedOrderExecutor implements PaperOrderExecutor {
  const SimulatedOrderExecutor();

  @override
  ExecutionQuote quote({
    required TradeSide side,
    required double quantity,
    required double referencePrice,
    required double feeRate,
    required double slippageRate,
  }) {
    final multiplier = side == TradeSide.buy
        ? 1 + slippageRate
        : 1 - slippageRate;
    final executionPrice = referencePrice * multiplier;
    return ExecutionQuote(
      price: executionPrice,
      fee: quantity * executionPrice * feeRate,
    );
  }
}
