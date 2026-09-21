import '../domain/moving_average_strategy.dart';
import '../domain/paper_trading_models.dart';
import '../domain/paper_trading_ports.dart';
import '../domain/risk_gate.dart';
import '../domain/simulated_order_executor.dart';

class ProcessTickResult {
  final TradeSignal? signal;
  final PaperOrder? order;
  final TradeFill? fill;
  final bool duplicateEvent;

  const ProcessTickResult({
    this.signal,
    this.order,
    this.fill,
    this.duplicateEvent = false,
  });
}

class PaperTradingEngine {
  final TradingRepository repository;
  final TradingClock clock;
  final PaperOrderExecutor executor;
  final CentralRiskGate riskGate;
  final MovingAverageCrossoverStrategy strategy;
  TradingSnapshot snapshot;

  PaperTradingEngine({
    required this.repository,
    required this.snapshot,
    this.clock = const SystemTradingClock(),
    this.executor = const SimulatedOrderExecutor(),
    this.riskGate = const CentralRiskGate(),
    this.strategy = const MovingAverageCrossoverStrategy(),
  });

  static Future<PaperTradingEngine> load({
    required TradingRepository repository,
    TradingClock clock = const SystemTradingClock(),
  }) async {
    final stored = await repository.load();
    final snapshot = stored ?? TradingSnapshot.initial();
    snapshot.bot = snapshot.bot.copyWith(status: EngineStatus.stopped);
    return PaperTradingEngine(
      repository: repository,
      snapshot: snapshot,
      clock: clock,
    );
  }

  Future<void> persist() => repository.save(snapshot);

  Future<ProcessTickResult> processTick(MarketTick tick) async {
    if (snapshot.processedEventIds.contains(tick.eventId)) {
      return const ProcessTickResult(duplicateEvent: true);
    }
    snapshot.processedEventIds.add(tick.eventId);
    snapshot.lastPrices[tick.symbol] = tick.price;
    _markPositions(tick.symbol, tick.price);

    final signal = strategy.evaluate(tick, snapshot);
    if (signal == null) {
      await persist();
      return const ProcessTickResult();
    }

    return executeSignal(signal);
  }

  /// Executes a deterministic strategy signal through the same mandatory risk
  /// gate used by market-tick processing. This is also the seam used by tests
  /// and future application strategies; it never bypasses risk validation.
  Future<ProcessTickResult> executeSignal(TradeSignal signal) async {
    final decision = riskGate.validate(
      signal: signal,
      snapshot: snapshot,
      executor: executor,
    );
    if (!decision.approved) {
      final order = PaperOrder(
        id: snapshot.nextId('order'),
        signalId: signal.id,
        symbol: signal.symbol,
        side: signal.side,
        quantity: signal.quantity,
        requestedPrice: signal.referencePrice,
        status: PaperOrderStatus.rejected,
        rejectionReason: decision.reason,
        createdAt: signal.timestamp,
      );
      snapshot.orders.insert(0, order);
      snapshot.processedSignalIds.add(signal.id);
      _record(
        'ORDER_REJECTED',
        '${order.id}: ${decision.reason}',
        signal.timestamp,
      );
      await persist();
      return ProcessTickResult(signal: signal, order: order);
    }

    final order = PaperOrder(
      id: snapshot.nextId('order'),
      signalId: signal.id,
      symbol: signal.symbol,
      side: signal.side,
      quantity: signal.quantity,
      requestedPrice: signal.referencePrice,
      status: PaperOrderStatus.filled,
      createdAt: signal.timestamp,
    );
    final quote = executor.quote(
      side: signal.side,
      quantity: signal.quantity,
      referencePrice: signal.referencePrice,
      feeRate: snapshot.bot.feeRate,
      slippageRate: snapshot.bot.slippageRate,
    );
    final fill = TradeFill(
      id: snapshot.nextId('fill'),
      orderId: order.id,
      symbol: order.symbol,
      side: order.side,
      quantity: order.quantity,
      price: quote.price,
      fee: quote.fee,
      timestamp: signal.timestamp,
    );
    snapshot.orders.insert(0, order);
    snapshot.fills.insert(0, fill);
    snapshot.processedSignalIds.add(signal.id);
    _applyFill(fill);
    _record(
      'FILL',
      '${fill.side.name.toUpperCase()} ${fill.quantity} ${fill.symbol} at '
          '${fill.price.toStringAsFixed(4)}; fee ${fill.fee.toStringAsFixed(4)}',
      signal.timestamp,
    );
    await persist();
    return ProcessTickResult(signal: signal, order: order, fill: fill);
  }

  Future<void> setRunning(bool running) async {
    if (running && snapshot.emergencyStop.active) return;
    snapshot.bot = snapshot.bot.copyWith(
      status: running ? EngineStatus.running : EngineStatus.stopped,
    );
    _record(
      running ? 'ENGINE_STARTED' : 'ENGINE_STOPPED',
      running ? 'Paper engine started' : 'Paper engine stopped',
      clock.now(),
    );
    await persist();
  }

  Future<void> activateEmergencyStop(String reason) async {
    final now = clock.now();
    snapshot.emergencyStop = EmergencyStopState(
      active: true,
      reason: reason,
      activatedAt: now,
    );
    snapshot.bot = snapshot.bot.copyWith(status: EngineStatus.stopped);
    _record('EMERGENCY_STOP', reason, now);
    await persist();
  }

  Future<void> resetEmergencyStop() async {
    if (!snapshot.emergencyStop.active) return;
    snapshot.emergencyStop = const EmergencyStopState();
    _record('EMERGENCY_RESET', 'Emergency stop reset by user', clock.now());
    await persist();
  }

  Future<void> resetPaperAccount() async {
    final definitions = snapshot.strategyDefinitions;
    final versions = snapshot.strategyVersions;
    final risk = snapshot.riskSettings;
    final emergency = snapshot.emergencyStop;
    final startingCash = snapshot.account.startingCash;
    snapshot = TradingSnapshot.initial(startingCash: startingCash)
      ..strategyDefinitions = definitions
      ..strategyVersions = versions
      ..riskSettings = risk
      ..emergencyStop = emergency;
    _record('ACCOUNT_RESET', 'Paper account reset by user', clock.now());
    await persist();
  }

  void _markPositions(String symbol, double price) {
    for (var index = 0; index < snapshot.openPositions.length; index++) {
      final position = snapshot.openPositions[index];
      if (position.symbol == symbol) {
        snapshot.openPositions[index] = position.copyWith(markPrice: price);
      }
    }
  }

  void _applyFill(TradeFill fill) {
    final signedTrade = fill.side == TradeSide.buy
        ? fill.quantity
        : -fill.quantity;
    final cashDelta = fill.side == TradeSide.buy
        ? -(fill.notional + fill.fee)
        : fill.notional - fill.fee;
    var realizedDelta = -fill.fee;
    snapshot.account = snapshot.account.copyWith(
      cash: snapshot.account.cash + cashDelta,
    );

    final index = snapshot.openPositions.indexWhere(
      (position) => position.symbol == fill.symbol,
    );
    if (index == -1) {
      snapshot.openPositions.add(
        PaperPosition(
          id: snapshot.nextId('position'),
          symbol: fill.symbol,
          openingSide: fill.side,
          quantity: signedTrade,
          averageEntryPrice: fill.price,
          markPrice: fill.price,
          realizedPnl: -fill.fee,
          openedAt: fill.timestamp,
        ),
      );
      snapshot.account = snapshot.account.copyWith(
        realizedPnl: snapshot.account.realizedPnl + realizedDelta,
      );
      return;
    }

    final existing = snapshot.openPositions[index];
    final sameDirection = existing.quantity.sign == signedTrade.sign;
    if (sameDirection) {
      final combinedQuantity = existing.quantity + signedTrade;
      final weightedEntry =
          ((existing.averageEntryPrice * existing.quantity.abs()) +
              (fill.price * signedTrade.abs())) /
          combinedQuantity.abs();
      snapshot.openPositions[index] = existing.copyWith(
        quantity: combinedQuantity,
        averageEntryPrice: weightedEntry,
        markPrice: fill.price,
        realizedPnl: existing.realizedPnl - fill.fee,
      );
      snapshot.account = snapshot.account.copyWith(
        realizedPnl: snapshot.account.realizedPnl + realizedDelta,
      );
      return;
    }

    final closingQuantity = existing.quantity.abs() < signedTrade.abs()
        ? existing.quantity.abs()
        : signedTrade.abs();
    final grossRealized =
        (fill.price - existing.averageEntryPrice) *
        closingQuantity *
        existing.quantity.sign;
    realizedDelta += grossRealized;
    final remaining = existing.quantity + signedTrade;
    final positionRealized = existing.realizedPnl + grossRealized - fill.fee;

    if (remaining.abs() < 1e-9 || remaining.sign != existing.quantity.sign) {
      snapshot.closedPositions.insert(
        0,
        existing.copyWith(
          quantity: 0,
          markPrice: fill.price,
          realizedPnl: positionRealized,
          closedAt: fill.timestamp,
        ),
      );
      snapshot.openPositions.removeAt(index);
      if (remaining.abs() >= 1e-9) {
        snapshot.openPositions.add(
          PaperPosition(
            id: snapshot.nextId('position'),
            symbol: fill.symbol,
            openingSide: remaining > 0 ? TradeSide.buy : TradeSide.sell,
            quantity: remaining,
            averageEntryPrice: fill.price,
            markPrice: fill.price,
            realizedPnl: 0,
            openedAt: fill.timestamp,
          ),
        );
      }
    } else {
      snapshot.openPositions[index] = existing.copyWith(
        quantity: remaining,
        markPrice: fill.price,
        realizedPnl: positionRealized,
      );
    }
    snapshot.account = snapshot.account.copyWith(
      realizedPnl: snapshot.account.realizedPnl + realizedDelta,
    );
  }

  void _record(String type, String message, DateTime timestamp) {
    snapshot.events.insert(
      0,
      AuditEvent(
        id: snapshot.nextId('event'),
        type: type,
        message: message,
        timestamp: timestamp,
      ),
    );
  }
}
