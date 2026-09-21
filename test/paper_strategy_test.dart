import 'package:flutter_test/flutter_test.dart';
import 'package:trading_bot/domain/moving_average_strategy.dart';
import 'package:trading_bot/domain/paper_trading_models.dart';

void main() {
  test('moving-average strategy emits only on actual crossovers', () {
    final strategy = MovingAverageCrossoverStrategy();
    final snapshot = TradingSnapshot.initial()
      ..bot = const PaperBotConfiguration(
        fastWindow: 2,
        slowWindow: 3,
        orderQuantity: 1,
      );
    final prices = [3.0, 2.0, 1.0, 4.0, 5.0, 4.0, 1.0];
    final signals = <TradeSignal>[];

    for (var index = 0; index < prices.length; index++) {
      final signal = strategy.evaluate(
        MarketTick(
          eventId: 'tick-$index',
          symbol: 'BTC/USDT',
          price: prices[index],
          timestamp: DateTime.utc(2026, 1, 1, 0, index),
        ),
        snapshot,
      );
      if (signal != null) signals.add(signal);
    }

    expect(signals.map((signal) => signal.side), [
      TradeSide.buy,
      TradeSide.sell,
    ]);
    expect(signals.length, lessThan(prices.length));
    expect(signals.first.id, contains('tick-3'));
    expect(signals.last.id, contains('tick-6'));
  });
}
