import 'package:flutter_test/flutter_test.dart';
import 'package:trading_bot/domain/paper_trading_models.dart';
import 'package:trading_bot/domain/risk_gate.dart';
import 'package:trading_bot/domain/simulated_order_executor.dart';

TradeSignal signal({
  String id = 'signal-1',
  TradeSide side = TradeSide.buy,
  double quantity = 1,
  double price = 100,
}) => TradeSignal(
  id: id,
  eventId: 'event-$id',
  strategyId: 'test-strategy',
  symbol: 'BTC/USDT',
  side: side,
  quantity: quantity,
  referencePrice: price,
  timestamp: DateTime.utc(2026),
);

void main() {
  const gate = CentralRiskGate();
  const executor = SimulatedOrderExecutor();

  test('fees and directional slippage are deterministic', () {
    final buy = executor.quote(
      side: TradeSide.buy,
      quantity: 2,
      referencePrice: 100,
      feeRate: 0.01,
      slippageRate: 0.02,
    );
    final sell = executor.quote(
      side: TradeSide.sell,
      quantity: 2,
      referencePrice: 100,
      feeRate: 0.01,
      slippageRate: 0.02,
    );

    expect(buy.price, 102);
    expect(buy.fee, 2.04);
    expect(sell.price, 98);
    expect(sell.fee, 1.96);
  });

  test('risk gate accepts valid order and enforces all core limits', () {
    final snapshot = TradingSnapshot.initial()
      ..riskSettings = const RiskSettings(
        maxPositionValue: 1000,
        maxOrderValue: 500,
        maxTotalExposure: 1200,
      )
      ..bot = const PaperBotConfiguration(feeRate: 0, slippageRate: 0);

    expect(
      gate
          .validate(signal: signal(), snapshot: snapshot, executor: executor)
          .approved,
      isTrue,
    );
    expect(
      gate
          .validate(
            signal: signal(id: 'large-order', quantity: 6),
            snapshot: snapshot,
            executor: executor,
          )
          .reason,
      contains('Order value'),
    );
    expect(
      gate
          .validate(
            signal: signal(id: 'invalid', quantity: 0),
            snapshot: snapshot,
            executor: executor,
          )
          .reason,
      contains('Quantity'),
    );

    snapshot.account = const PaperAccount(
      startingCash: 100,
      cash: 50,
      realizedPnl: 0,
    );
    expect(
      gate
          .validate(
            signal: signal(id: 'no-cash'),
            snapshot: snapshot,
            executor: executor,
          )
          .reason,
      contains('Insufficient'),
    );
  });

  test(
    'risk gate rejects duplicates, position, exposure, and emergency stop',
    () {
      final snapshot = TradingSnapshot.initial()
        ..bot = const PaperBotConfiguration(feeRate: 0, slippageRate: 0)
        ..riskSettings = const RiskSettings(
          maxPositionValue: 150,
          maxOrderValue: 1000,
          maxTotalExposure: 180,
        );
      snapshot.processedSignalIds.add('duplicate');
      expect(
        gate
            .validate(
              signal: signal(id: 'duplicate'),
              snapshot: snapshot,
              executor: executor,
            )
            .reason,
        contains('Duplicate'),
      );
      expect(
        gate
            .validate(
              signal: signal(id: 'position', quantity: 2),
              snapshot: snapshot,
              executor: executor,
            )
            .reason,
        contains('position'),
      );

      snapshot.riskSettings = const RiskSettings(
        maxPositionValue: 1000,
        maxOrderValue: 1000,
        maxTotalExposure: 150,
      );
      snapshot.openPositions.add(
        PaperPosition(
          id: 'other',
          symbol: 'ETH/USDT',
          openingSide: TradeSide.buy,
          quantity: 1,
          averageEntryPrice: 100,
          markPrice: 100,
          realizedPnl: 0,
          openedAt: DateTime.utc(2026),
        ),
      );
      expect(
        gate
            .validate(
              signal: signal(id: 'exposure'),
              snapshot: snapshot,
              executor: executor,
            )
            .reason,
        contains('exposure'),
      );

      snapshot.emergencyStop = EmergencyStopState(
        active: true,
        reason: 'test',
        activatedAt: DateTime.utc(2026),
      );
      expect(
        gate
            .validate(
              signal: signal(id: 'halted'),
              snapshot: snapshot,
              executor: executor,
            )
            .reason,
        contains('Emergency'),
      );
    },
  );
}
