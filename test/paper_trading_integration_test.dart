import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_bot/application/paper_trading_controller.dart';
import 'package:trading_bot/application/paper_trading_engine.dart';
import 'package:trading_bot/data/trading_repositories.dart';
import 'package:trading_bot/domain/paper_trading_models.dart';
import 'package:trading_bot/main.dart';
import 'package:trading_bot/state/trading_state.dart';

void main() {
  test('strategy definitions and versions survive state recreation', () async {
    final store = InMemoryTradingStore();
    final firstRepository = InMemoryTradingRepository(null, store);
    final firstEngine = await PaperTradingEngine.load(
      repository: firstRepository,
    );
    final firstState = TradingState(
      paperController: PaperTradingController(firstEngine),
    );
    firstState.strategies[0] = firstState.strategies[0].copyWith(
      name: 'Persisted Strategy',
    );
    await firstState.persistNow();

    final secondEngine = await PaperTradingEngine.load(
      repository: InMemoryTradingRepository(null, store),
    );
    final secondState = TradingState(
      paperController: PaperTradingController(secondEngine),
    );

    expect(secondState.strategies.first.name, 'Persisted Strategy');
    expect(secondState.versionHistory['STR-001'], isNotEmpty);
  });

  testWidgets('dashboard reflects real paper state and safety labels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final snapshot = TradingSnapshot.initial()
      ..bot = const PaperBotConfiguration(feeRate: 0, slippageRate: 0);
    final engine = PaperTradingEngine(
      repository: InMemoryTradingRepository(),
      snapshot: snapshot,
    );
    await engine.executeSignal(
      TradeSignal(
        id: 'dashboard-signal',
        eventId: 'dashboard-event',
        strategyId: 'test',
        symbol: 'BTC/USDT',
        side: TradeSide.buy,
        quantity: 1,
        referencePrice: 100,
        timestamp: DateTime.utc(2026),
      ),
    );
    final state = TradingState(paperController: PaperTradingController(engine));

    await tester.pumpWidget(TradingBotApp(state: state));
    await tester.pumpAndSettle();

    expect(find.text('Paper Trading Command Center'), findsOneWidget);
    expect(find.textContaining('SIMULATED ONLY'), findsOneWidget);
    expect(find.text('PAPER CASH'), findsOneWidget);
    expect(find.text('TOTAL EQUITY'), findsOneWidget);
    expect(find.text('Open Positions'), findsOneWidget);
    expect(find.text('Recent Simulated Orders'), findsOneWidget);
    expect(find.text('PAPER ONLY'), findsNothing);
  });
}
