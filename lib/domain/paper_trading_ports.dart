import 'paper_trading_models.dart';

abstract interface class MarketDataSource {
  Stream<MarketTick> ticks();
}

abstract interface class TradingRepository {
  Future<TradingSnapshot?> load();
  Future<void> save(TradingSnapshot snapshot);
  Future<void> clear();
}

abstract interface class TradingClock {
  DateTime now();
}

class SystemTradingClock implements TradingClock {
  const SystemTradingClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

class ExecutionQuote {
  final double price;
  final double fee;

  const ExecutionQuote({required this.price, required this.fee});
}

abstract interface class PaperOrderExecutor {
  ExecutionQuote quote({
    required TradeSide side,
    required double quantity,
    required double referencePrice,
    required double feeRate,
    required double slippageRate,
  });
}
