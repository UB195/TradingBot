import 'package:flutter_test/flutter_test.dart';
import 'package:trading_bot/application/paper_trading_engine.dart';
import 'package:trading_bot/data/replay_market_data_source.dart';
import 'package:trading_bot/data/trading_repositories.dart';
import 'package:trading_bot/domain/paper_trading_models.dart';
import 'package:trading_bot/domain/paper_trading_ports.dart';

class FixedClock implements TradingClock {
  final DateTime value;
  const FixedClock(this.value);

  @override
  DateTime now() => value;
}

TradeSignal signal(int id, TradeSide side, double quantity, double price) =>
    TradeSignal(
      id: 'signal-$id',
      eventId: 'event-$id',
      strategyId: 'test',
      symbol: 'BTC/USDT',
      side: side,
      quantity: quantity,
      referencePrice: price,
      timestamp: DateTime.utc(2026, 1, 1, 0, id),
    );

PaperTradingEngine engineWith(
  TradingRepository repository,
  TradingSnapshot snapshot,
) => PaperTradingEngine(
  repository: repository,
  snapshot: snapshot,
  clock: FixedClock(DateTime.utc(2026, 1, 1)),
);

void main() {
  test(
    'replay ticks flow through strategy, risk, fills, and account',
    () async {
      final snapshot = TradingSnapshot.initial()
        ..bot = const PaperBotConfiguration(feeRate: 0, slippageRate: 0);
      final engine = engineWith(InMemoryTradingRepository(), snapshot);
      final ticks = ReplayMarketDataSource.sampleTicks();

      for (final tick in ticks) {
        await engine.processTick(tick);
      }

      expect(snapshot.processedEventIds, hasLength(ticks.length));
      expect(snapshot.orders, isNotEmpty);
      expect(snapshot.orders.length, lessThan(ticks.length));
      expect(snapshot.fills.length, snapshot.orders.length);
      expect(
        snapshot.events.where((event) => event.type == 'FILL'),
        isNotEmpty,
      );
      expect(snapshot.equity, greaterThan(0));
    },
  );

  test('positions open, increase, reduce, close, and reverse', () async {
    final snapshot = TradingSnapshot.initial()
      ..bot = const PaperBotConfiguration(feeRate: 0, slippageRate: 0);
    final engine = engineWith(InMemoryTradingRepository(), snapshot);

    await engine.executeSignal(signal(1, TradeSide.buy, 10, 100));
    expect(snapshot.openPositions.single.quantity, 10);
    expect(snapshot.openPositions.single.averageEntryPrice, 100);

    await engine.executeSignal(signal(2, TradeSide.buy, 5, 110));
    expect(snapshot.openPositions.single.quantity, 15);
    expect(
      snapshot.openPositions.single.averageEntryPrice,
      closeTo(103.3333, 0.001),
    );

    await engine.executeSignal(signal(3, TradeSide.sell, 4, 120));
    expect(snapshot.openPositions.single.quantity, 11);
    expect(snapshot.account.realizedPnl, closeTo(66.6667, 0.001));

    await engine.executeSignal(signal(4, TradeSide.sell, 11, 90));
    expect(snapshot.openPositions, isEmpty);
    expect(snapshot.closedPositions, hasLength(1));
    expect(snapshot.account.realizedPnl, closeTo(-80, 0.001));

    await engine.executeSignal(signal(5, TradeSide.sell, 5, 80));
    expect(snapshot.openPositions.single.quantity, -5);
    await engine.executeSignal(signal(6, TradeSide.buy, 8, 70));
    expect(snapshot.closedPositions, hasLength(2));
    expect(snapshot.openPositions.single.quantity, 3);
    expect(snapshot.openPositions.single.averageEntryPrice, 70);
    expect(snapshot.account.realizedPnl, closeTo(-30, 0.001));
  });

  test('realized, unrealized P&L, fees, and cash are accounted', () async {
    final snapshot = TradingSnapshot.initial()
      ..bot = const PaperBotConfiguration(feeRate: 0.01, slippageRate: 0);
    final engine = engineWith(InMemoryTradingRepository(), snapshot);

    await engine.executeSignal(signal(1, TradeSide.buy, 2, 100));
    expect(snapshot.account.cash, 99798);
    expect(snapshot.account.realizedPnl, -2);
    expect(snapshot.equity, 99998);

    await engine.processTick(
      MarketTick(
        eventId: 'mark-1',
        symbol: 'BTC/USDT',
        price: 110,
        timestamp: DateTime.utc(2026, 1, 2),
      ),
    );
    expect(snapshot.unrealizedPnl, 20);
    expect(snapshot.equity, 100018);
  });

  test('duplicate market event is processed only once', () async {
    final snapshot = TradingSnapshot.initial();
    final engine = engineWith(InMemoryTradingRepository(), snapshot);
    final tick = MarketTick(
      eventId: 'same-event',
      symbol: 'BTC/USDT',
      price: 100,
      timestamp: DateTime.utc(2026),
    );

    expect((await engine.processTick(tick)).duplicateEvent, isFalse);
    final pricesAfterFirst = snapshot.strategyPrices.length;
    expect((await engine.processTick(tick)).duplicateEvent, isTrue);
    expect(snapshot.strategyPrices.length, pricesAfterFirst);
  });

  test('emergency stop blocks orders and survives reload', () async {
    final store = InMemoryTradingStore();
    final repository = InMemoryTradingRepository(null, store);
    final engine = engineWith(repository, TradingSnapshot.initial());
    await engine.activateEmergencyStop('operator test');

    final result = await engine.executeSignal(signal(1, TradeSide.buy, 1, 100));
    expect(result.order?.status, PaperOrderStatus.rejected);
    expect(result.order?.rejectionReason, contains('Emergency'));

    final reloaded = await PaperTradingEngine.load(
      repository: InMemoryTradingRepository(null, store),
    );
    expect(reloaded.snapshot.emergencyStop.active, isTrue);
    expect(reloaded.snapshot.emergencyStop.reason, 'operator test');
    expect(reloaded.snapshot.bot.status, EngineStatus.stopped);
    expect(reloaded.snapshot.orders.single.status, PaperOrderStatus.rejected);

    await reloaded.resetPaperAccount();
    expect(reloaded.snapshot.emergencyStop.active, isTrue);
  });

  test(
    'orders, fills, positions, account, and audit survive repository recreation',
    () async {
      final store = InMemoryTradingStore();
      final firstRepository = InMemoryTradingRepository(null, store);
      final snapshot = TradingSnapshot.initial()
        ..bot = const PaperBotConfiguration(feeRate: 0, slippageRate: 0);
      final first = engineWith(firstRepository, snapshot);
      await first.executeSignal(signal(1, TradeSide.buy, 2, 100));

      final second = await PaperTradingEngine.load(
        repository: InMemoryTradingRepository(null, store),
      );
      expect(second.snapshot.orders, hasLength(1));
      expect(second.snapshot.fills, hasLength(1));
      expect(second.snapshot.openPositions.single.quantity, 2);
      expect(second.snapshot.account.cash, 99800);
      expect(second.snapshot.events, isNotEmpty);
      expect(second.snapshot.bot.feeRate, 0);
      expect(second.snapshot.bot.slippageRate, 0);
    },
  );
}
