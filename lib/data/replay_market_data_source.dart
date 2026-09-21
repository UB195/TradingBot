import '../domain/paper_trading_models.dart';
import '../domain/paper_trading_ports.dart';

class ReplayMarketDataSource implements MarketDataSource {
  final List<MarketTick> _ticks;
  final Duration interval;

  const ReplayMarketDataSource(this._ticks, {this.interval = Duration.zero});

  @override
  Stream<MarketTick> ticks() async* {
    for (final tick in _ticks) {
      if (interval > Duration.zero) await Future<void>.delayed(interval);
      yield tick;
    }
  }

  static List<MarketTick> sampleTicks() {
    final start = DateTime.utc(2026, 1, 1, 9, 30);
    const prices = [
      100.0,
      99.0,
      98.0,
      97.0,
      96.0,
      101.0,
      106.0,
      108.0,
      104.0,
      99.0,
      94.0,
      92.0,
      97.0,
      103.0,
      109.0,
    ];
    return List.generate(
      prices.length,
      (index) => MarketTick(
        eventId: 'sample-${index.toString().padLeft(3, '0')}',
        symbol: 'BTC/USDT',
        price: prices[index],
        timestamp: start.add(Duration(minutes: index)),
      ),
    );
  }
}
