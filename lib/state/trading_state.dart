import 'dart:async';

import 'package:flutter/material.dart';
import '../application/paper_trading_controller.dart';
import '../application/paper_trading_engine.dart';
import '../data/strategy_persistence_mapper.dart';
import '../data/trading_repositories.dart';
import '../domain/paper_trading_models.dart' as paper;
import '../models/trading_models.dart';
import '../models/strategy_builder_models.dart';
import '../services/mock_trading_service.dart';
import '../services/mock_strategy_service.dart';

class TradingState extends ChangeNotifier {
  final PaperTradingController paperController;
  int _currentSectionIndex = 0;
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  int get currentSectionIndex => _currentSectionIndex;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  paper.TradingSnapshot get paperSnapshot => paperController.snapshot;
  bool get isPaperEngineRunning => paperController.isRunning;
  bool get emergencyStopActive => paperController.emergencyStopActive;

  TradingState({PaperTradingController? paperController})
    : paperController = paperController ?? _newInMemoryController() {
    this.paperController.addListener(_onPaperStateChanged);
    _restoreStrategyData();
    _syncPaperProjection();
  }

  static PaperTradingController _newInMemoryController() {
    final snapshot = paper.TradingSnapshot.initial();
    final repository = InMemoryTradingRepository(snapshot);
    return PaperTradingController(
      PaperTradingEngine(repository: repository, snapshot: snapshot),
    );
  }

  static Future<TradingState> createPersistent() async {
    final repository = SharedPreferencesTradingRepository();
    final engine = await PaperTradingEngine.load(repository: repository);
    final state = TradingState(paperController: PaperTradingController(engine));
    await state.persistNow();
    return state;
  }

  final List<String> sections = [
    'Dashboard',
    'Markets',
    'Strategies',
    'Bots',
    'Signals',
    'Positions',
    'Orders',
    'Portfolio',
    'Risk',
    'Backtesting',
    'AI Research Lab',
    'Options',
    'News & Events',
    'Analytics',
    'Logs',
    'Broker',
    'Settings',
  ];

  // Data lists
  List<MarketTicker> tickers = MockTradingService.getMockTickers();
  List<TradingBot> bots = [];
  List<TradingPosition> positions = [];
  List<MarketSignal> signals = [];
  RiskMetrics risk = MockTradingService.getMockRisk();
  List<LogEntry> logs = [];
  List<TradingOrder> orders = [];

  List<PortfolioAsset> assets = [
    PortfolioAsset(
      asset: 'USDT',
      name: 'Tether USD',
      balance: 145200.0,
      available: 95000.0,
      valueUsd: 145200.0,
      allocationPercent: 54.2,
    ),
    PortfolioAsset(
      asset: 'BTC',
      name: 'Bitcoin',
      balance: 0.85,
      available: 0.60,
      valueUsd: 81957.4,
      allocationPercent: 30.6,
    ),
    PortfolioAsset(
      asset: 'ETH',
      name: 'Ethereum',
      balance: 8.5,
      available: 8.5,
      valueUsd: 29331.3,
      allocationPercent: 11.0,
    ),
    PortfolioAsset(
      asset: 'SOL',
      name: 'Solana',
      balance: 60.0,
      available: 60.0,
      valueUsd: 11118.0,
      allocationPercent: 4.2,
    ),
  ];

  List<BacktestResult> backtests = [
    BacktestResult(
      strategyName: 'Alpha Grid V2',
      symbol: 'BTC/USDT',
      timeframe: '1H',
      totalTrades: 342,
      winRate: 68.4,
      profitFactor: 1.85,
      netReturnPercent: 42.6,
      maxDrawdownPercent: 4.5,
    ),
    BacktestResult(
      strategyName: 'Neural Momentum',
      symbol: 'ETH/USDT',
      timeframe: '15M',
      totalTrades: 812,
      winRate: 54.2,
      profitFactor: 1.32,
      netReturnPercent: 18.9,
      maxDrawdownPercent: 8.2,
    ),
  ];

  List<OptionContract> optionsContracts = [
    OptionContract(
      symbol: 'BTC-28MAR26-100000-C',
      strikePrice: 100000.0,
      expiration: DateTime(2026, 3, 28),
      type: 'CALL',
      premium: 1420.0,
      impliedVolPercent: 48.5,
      delta: 0.42,
      openInterest: 1250,
    ),
    OptionContract(
      symbol: 'BTC-28MAR26-90000-P',
      strikePrice: 90000.0,
      expiration: DateTime(2026, 3, 28),
      type: 'PUT',
      premium: 850.0,
      impliedVolPercent: 52.1,
      delta: -0.28,
      openInterest: 840,
    ),
  ];

  List<NewsItem> news = [
    NewsItem(
      id: 'n1',
      title: 'Federal Reserve Announces Interest Rate Stability',
      source: 'Bloomberg',
      sentiment: 'NEUTRAL',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      summary:
          'The Fed held steady on rates signaling strong underlying macro indicators.',
    ),
    NewsItem(
      id: 'n2',
      title: 'Bitcoin Hash Rate Reaches New All-Time High',
      source: 'CoinDesk',
      sentiment: 'BULLISH',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      summary:
          'Network security grows as active miners deploy next-gen ASIC systems globally.',
    ),
    NewsItem(
      id: 'n3',
      title: 'Tech Stocks Experience Sudden Liquidation Wave',
      source: 'Reuters',
      sentiment: 'BEARISH',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      summary:
          'Overleveraged long liquidations pull broad market indices down 2.1%.',
    ),
  ];

  // Strategy Builder data (mock)
  List<StrategyConfig> strategies = MockStrategyService.getMockStrategies();
  Map<String, List<StrategyVersion>> versionHistory =
      MockStrategyService.getMockVersionHistory();
  int _strategyIdCounter = 100;

  // Toast message tracking
  List<String> activeToasts = [];

  double get paperCash => paperSnapshot.account.cash;
  double get paperEquity => paperSnapshot.equity;
  double get realizedPnl => paperSnapshot.account.realizedPnl;
  double get unrealizedPnl => paperSnapshot.unrealizedPnl;

  Future<void> startPaperEngine() async {
    if (emergencyStopActive) {
      showToast('Reset the emergency stop before starting the paper engine');
      return;
    }
    await paperController.start();
  }

  Future<void> stopPaperEngine() => paperController.stop();

  Future<void> activateEmergencyStop([
    String reason = 'Activated by the user from the Paper Trading dashboard',
  ]) => paperController.activateEmergencyStop(reason);

  Future<void> resetEmergencyStop() => paperController.resetEmergencyStop();
  Future<void> resetPaperAccount() => paperController.resetPaperAccount();

  Future<void> persistNow() async {
    _storeStrategyData();
    await paperController.engine.persist();
  }

  void _restoreStrategyData() {
    final snapshot = paperSnapshot;
    if (snapshot.strategyDefinitions.isEmpty) {
      _storeStrategyData();
      return;
    }
    strategies = snapshot.strategyDefinitions
        .map(StrategyPersistenceMapper.configFromJson)
        .toList();
    versionHistory = snapshot.strategyVersions.map(
      (key, values) => MapEntry(
        key,
        values.map(StrategyPersistenceMapper.versionFromJson).toList(),
      ),
    );
    final numericIds = strategies
        .map((value) => int.tryParse(value.id.replaceAll(RegExp(r'\D'), '')))
        .whereType<int>();
    if (numericIds.isNotEmpty) {
      _strategyIdCounter = numericIds.reduce((a, b) => a > b ? a : b);
    }
  }

  void _storeStrategyData() {
    paperSnapshot.strategyDefinitions = strategies
        .map(StrategyPersistenceMapper.configToJson)
        .toList();
    paperSnapshot.strategyVersions = versionHistory.map(
      (key, values) => MapEntry(
        key,
        values.map(StrategyPersistenceMapper.versionToJson).toList(),
      ),
    );
  }

  void _onPaperStateChanged() {
    _syncPaperProjection();
    notifyListeners();
  }

  void _syncPaperProjection() {
    final snapshot = paperSnapshot;
    bots = [
      TradingBot(
        id: snapshot.bot.id,
        name: 'Paper MA Bot',
        strategyName: snapshot.bot.strategyName,
        marketSymbol: snapshot.bot.symbol,
        status: snapshot.bot.status.name.toUpperCase(),
        netProfit: snapshot.account.realizedPnl + snapshot.unrealizedPnl,
        allocation: snapshot.account.startingCash,
        runtime: 'Replay session',
      ),
    ];
    positions = snapshot.openPositions
        .map(
          (position) => TradingPosition(
            id: position.id,
            symbol: position.symbol,
            side: position.quantity >= 0 ? 'LONG' : 'SHORT',
            entryPrice: position.averageEntryPrice,
            markPrice: position.markPrice,
            size: position.quantity.abs(),
            pnl: position.unrealizedPnl,
            pnlPercent: position.averageEntryPrice == 0
                ? 0
                : position.unrealizedPnl /
                      (position.quantity.abs() * position.averageEntryPrice) *
                      100,
            leverage: 1,
          ),
        )
        .toList();
    orders = snapshot.orders
        .map(
          (order) => TradingOrder(
            id: order.id,
            symbol: order.symbol,
            type: 'PAPER MARKET',
            side: order.side.name.toUpperCase(),
            price: order.requestedPrice,
            amount: order.quantity,
            filledAmount: order.status == paper.PaperOrderStatus.filled
                ? order.quantity
                : 0,
            status: order.status.name.toUpperCase(),
            timestamp: order.createdAt,
          ),
        )
        .toList();
    signals = snapshot.orders
        .take(10)
        .map(
          (order) => MarketSignal(
            id: order.signalId,
            symbol: order.symbol,
            type: order.side.name.toUpperCase(),
            source: snapshot.bot.strategyName,
            strength: 1,
            price: order.requestedPrice,
            timestamp: order.createdAt,
          ),
        )
        .toList();
    logs = snapshot.events
        .map(
          (event) => LogEntry(
            id: event.id,
            timestamp: event.timestamp,
            type: event.type.contains('REJECTED') ? 'WARNING' : 'INFO',
            source: 'PAPER_ENGINE',
            message: event.message,
          ),
        )
        .toList();
    assets = [
      PortfolioAsset(
        asset: 'USD',
        name: 'Paper Cash',
        balance: snapshot.account.cash,
        available: snapshot.account.cash,
        valueUsd: snapshot.account.cash,
        allocationPercent: snapshot.equity == 0
            ? 0
            : snapshot.account.cash / snapshot.equity * 100,
      ),
    ];
  }

  void setSection(int index) {
    if (index >= 0 && index < sections.length) {
      _currentSectionIndex = index;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void showToast(String message) {
    activeToasts.add(message);
    notifyListeners();
    Future.delayed(const Duration(seconds: 4), () {
      activeToasts.remove(message);
      notifyListeners();
    });
  }

  void toggleBotStatus(String botId) {
    if (botId != paperSnapshot.bot.id) return;
    if (isPaperEngineRunning) {
      unawaited(stopPaperEngine());
      showToast('Paper engine stopped');
    } else if (emergencyStopActive) {
      showToast('Reset the emergency stop before starting the paper engine');
    } else {
      unawaited(startPaperEngine());
      showToast('Paper engine started');
    }
  }

  void closePosition(String positionId) {
    showToast(
      'Direct position mutation is disabled; positions change through paper fills only.',
    );
  }

  void cancelOrder(String orderId) {
    showToast(
      'Paper market orders fill or reject immediately and cannot be cancelled.',
    );
  }

  void addOrder(
    String symbol,
    String side,
    String type,
    double price,
    double amount,
  ) {
    showToast(
      'Manual orders are disabled; start the deterministic paper engine instead.',
    );
  }

  // ---------------------------------------------------------------------
  // Strategy Builder operations
  // ---------------------------------------------------------------------

  String generateStrategyId() {
    _strategyIdCounter++;
    return 'STR-${_strategyIdCounter.toString().padLeft(3, '0')}';
  }

  void saveNewStrategy(StrategyConfig config) {
    strategies.insert(0, config);
    versionHistory[config.id] = [
      StrategyVersion(
        version: config.version,
        timestamp: DateTime.now(),
        changeNote: 'Initial strategy definition created',
        snapshot: config,
      ),
    ];
    showToast('Strategy "${config.name}" saved as ${config.version}');
    unawaited(persistNow());
    notifyListeners();
  }

  void updateStrategy(StrategyConfig config, String changeNote) {
    final index = strategies.indexWhere((s) => s.id == config.id);
    if (index != -1) {
      strategies[index] = config;
    }
    versionHistory.putIfAbsent(config.id, () => []);
    versionHistory[config.id]!.insert(
      0,
      StrategyVersion(
        version: config.version,
        timestamp: DateTime.now(),
        changeNote: changeNote,
        snapshot: config,
      ),
    );
    showToast('Strategy "${config.name}" updated to ${config.version}');
    unawaited(persistNow());
    notifyListeners();
  }

  void duplicateStrategy(StrategyConfig source) {
    final newId = generateStrategyId();
    final copy = source.copyWith(
      id: newId,
      name: '${source.name} (Copy)',
      version: 'v1.0',
      status: 'DRAFT',
      lastModified: DateTime.now(),
    );
    strategies.insert(0, copy);
    versionHistory[newId] = [
      StrategyVersion(
        version: 'v1.0',
        timestamp: DateTime.now(),
        changeNote: 'Duplicated from ${source.id} (${source.version})',
        snapshot: copy,
      ),
    ];
    showToast('Strategy duplicated as "${copy.name}"');
    unawaited(persistNow());
    notifyListeners();
  }

  @override
  void dispose() {
    paperController.removeListener(_onPaperStateChanged);
    paperController.dispose();
    super.dispose();
  }
}
