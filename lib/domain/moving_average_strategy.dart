import 'paper_trading_models.dart';

class MovingAverageCrossoverStrategy {
  const MovingAverageCrossoverStrategy();

  TradeSignal? evaluate(MarketTick tick, TradingSnapshot snapshot) {
    final bot = snapshot.bot;
    if (tick.symbol != bot.symbol) return null;

    final prices = snapshot.strategyPrices;
    final previousRelation = prices.length >= bot.slowWindow
        ? _relation(prices, bot.fastWindow, bot.slowWindow)
        : null;
    prices.add(tick.price);
    while (prices.length > bot.slowWindow) {
      prices.removeAt(0);
    }
    if (previousRelation == null || prices.length < bot.slowWindow) return null;

    final currentRelation = _relation(prices, bot.fastWindow, bot.slowWindow);
    TradeSide? side;
    if (previousRelation <= 0 && currentRelation > 0) side = TradeSide.buy;
    if (previousRelation >= 0 && currentRelation < 0) side = TradeSide.sell;
    if (side == null) return null;

    return TradeSignal(
      id: '${bot.strategyId}:${tick.eventId}:${side.name}',
      eventId: tick.eventId,
      strategyId: bot.strategyId,
      symbol: tick.symbol,
      side: side,
      quantity: bot.orderQuantity,
      referencePrice: tick.price,
      timestamp: tick.timestamp,
    );
  }

  int _relation(List<double> prices, int fastWindow, int slowWindow) {
    final fast = _average(prices.sublist(prices.length - fastWindow));
    final slow = _average(prices.sublist(prices.length - slowWindow));
    final difference = fast - slow;
    if (difference.abs() < 1e-9) return 0;
    return difference > 0 ? 1 : -1;
  }

  double _average(List<double> values) =>
      values.reduce((left, right) => left + right) / values.length;
}
