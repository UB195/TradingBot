import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_bot/main.dart';
import 'package:trading_bot/state/trading_state.dart';

void main() {
  testWidgets('Strategy Builder: create, save, duplicate and version history', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1920, 1080));
    final state = TradingState();
    await tester.pumpWidget(TradingBotApp(state: state));
    await tester.pumpAndSettle();

    // Navigate to the Strategies section via the side navigation.
    await tester.tap(find.text('Strategies'));
    await tester.pumpAndSettle();
    expect(find.text('Algorithmic Strategies Core'), findsOneWidget);
    expect(find.text('Alpha Mean Reversion'), findsOneWidget);

    // Open the Strategy Builder.
    await tester.tap(find.text('Build New Strategy'));
    await tester.pumpAndSettle();
    expect(find.text('Strategy Builder — New Strategy'), findsOneWidget);
    expect(find.text('Strategy Information'), findsOneWidget);
    expect(find.text('Entry Rules'), findsOneWidget);
    expect(find.text('Exit Rules'), findsOneWidget);
    // The Advanced section is further down the scrollable builder body.
    await tester.scrollUntilVisible(
      find.text('Advanced Risk Management'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Advanced Risk Management'), findsOneWidget);

    // Saving without a name or conditions should be rejected with a toast.
    await tester.tap(find.text('Save Strategy'));
    await tester.pump();
    expect(
      state.activeToasts,
      contains('Strategy name is required before saving.'),
    );

    // Load the example template (RSI > 60 AND Price > VWAP AND Volume AND Market Regime).
    await tester.scrollUntilVisible(
      find.text('Load Example Template'),
      -400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView), const Offset(0, 120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load Example Template'));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<String>), findsWidgets);

    // The live logic preview should contain the NOT-capable AND-chain.
    expect(
      find.textContaining(
        'ENTER WHEN: RSI(14) > 60 AND Price > VWAP AND Volume > 1.5 × Average Volume AND Market Regime = Bullish',
      ),
      findsOneWidget,
    );

    // Save the strategy and land back on the strategies grid.
    await tester.tap(find.text('Save Strategy'));
    await tester.pumpAndSettle();
    expect(find.text('Algorithmic Strategies Core'), findsOneWidget);
    expect(find.text('Momentum Breakout Prototype'), findsOneWidget);

    // Duplicate it from the grid.
    final dupButtons = find.text('Duplicate');
    await tester.tap(dupButtons.first);
    await tester.pumpAndSettle();
    expect(find.text('Momentum Breakout Prototype (Copy)'), findsOneWidget);

    // Re-open the original in the builder and check Version History restores a snapshot.
    await tester.tap(find.text('Edit').at(1));
    await tester.pumpAndSettle();
    expect(
      find.text('Strategy Builder — Momentum Breakout Prototype'),
      findsOneWidget,
    );

    await tester.tap(find.text('Version History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Version History — Momentum Breakout Prototype'),
      findsOneWidget,
    );
    expect(find.text('Initial strategy definition created'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Let the 4-second toast timers fire so no timers are pending at test end.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.binding.setSurfaceSize(null);
  });

  test('State layer: save, update, duplicate and version tracking', () {
    final state = TradingState();

    expect(state.strategies.length, 3);
    expect(state.versionHistory['STR-001']!.length, 3);

    // Duplicate an existing strategy.
    state.duplicateStrategy(state.strategies.first);
    expect(state.strategies.length, 4);
    expect(state.strategies.first.name, 'Alpha Mean Reversion (Copy)');
    expect(state.strategies.first.status, 'DRAFT');
    expect(state.strategies.first.id, isNot('STR-001'));

    // Update an existing strategy and confirm a new version entry is recorded.
    final updated = state.strategies[1].copyWith(
      status: 'BACKTESTING',
      version: 'v1.4.3',
    );
    state.updateStrategy(updated, 'test revision');
    expect(state.strategies[1].status, 'BACKTESTING');
    expect(state.versionHistory[updated.id]!.first.version, 'v1.4.3');
    expect(state.versionHistory[updated.id]!.first.changeNote, 'test revision');

    // Save a brand new strategy.
    state.saveNewStrategy(
      updated.copyWith(id: 'STR-999', name: 'Brand New', version: 'v1.0'),
    );
    expect(state.strategies.first.name, 'Brand New');
    expect(state.versionHistory['STR-999']!.length, 1);

    state.dispose();
  });
}
