import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/replay_market_data_source.dart';
import '../domain/paper_trading_models.dart';
import 'paper_trading_engine.dart';

class PaperTradingController extends ChangeNotifier {
  final PaperTradingEngine engine;
  StreamSubscription<MarketTick>? _subscription;

  PaperTradingController(this.engine);

  TradingSnapshot get snapshot => engine.snapshot;
  bool get isRunning => snapshot.bot.status == EngineStatus.running;
  bool get emergencyStopActive => snapshot.emergencyStop.active;
  List<PaperOrder> get rejectedOrders => snapshot.orders
      .where((order) => order.status == PaperOrderStatus.rejected)
      .toList();

  Future<void> start() async {
    if (isRunning || emergencyStopActive) return;
    await engine.setRunning(true);
    notifyListeners();
    final source = ReplayMarketDataSource(
      ReplayMarketDataSource.sampleTicks(),
      interval: const Duration(milliseconds: 500),
    );
    _subscription = source.ticks().listen(
      (tick) async {
        if (!isRunning) return;
        await engine.processTick(tick);
        notifyListeners();
      },
      onDone: () async {
        if (isRunning) await engine.setRunning(false);
        notifyListeners();
      },
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await engine.setRunning(false);
    notifyListeners();
  }

  Future<void> activateEmergencyStop(String reason) async {
    await engine.activateEmergencyStop(reason);
    await _subscription?.cancel();
    _subscription = null;
    notifyListeners();
  }

  Future<void> resetEmergencyStop() async {
    await engine.resetEmergencyStop();
    notifyListeners();
  }

  Future<void> resetPaperAccount() async {
    await _subscription?.cancel();
    _subscription = null;
    await engine.resetPaperAccount();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
