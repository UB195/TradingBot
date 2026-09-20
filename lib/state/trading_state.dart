import 'package:flutter/material.dart';
import '../models/trading_models.dart';
import '../models/strategy_builder_models.dart';
import '../services/mock_trading_service.dart';
import '../services/mock_strategy_service.dart';

class TradingState extends ChangeNotifier {
  int _currentSectionIndex = 0;
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  int get currentSectionIndex => _currentSectionIndex;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

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
  List<TradingBot> bots = MockTradingService.getMockBots();
  List<TradingPosition> positions = MockTradingService.getMockPositions();
  List<MarketSignal> signals = MockTradingService.getMockSignals();
  RiskMetrics risk = MockTradingService.getMockRisk();
  List<LogEntry> logs = MockTradingService.getMockLogs();

  List<TradingOrder> orders = [
    TradingOrder(
      id: 'o1',
      symbol: 'BTC/USDT',
      type: 'LIMIT',
      side: 'BUY',
      price: 95000.0,
      amount: 0.1,
      filledAmount: 0.0,
      status: 'PENDING',
      timestamp: DateTime.now(),
    ),
    TradingOrder(
      id: 'o2',
      symbol: 'ETH/USDT',
      type: 'MARKET',
      side: 'SELL',
      price: 3450.0,
      amount: 1.5,
      filledAmount: 1.5,
      status: 'FILLED',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

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
    final index = bots.indexWhere((b) => b.id == botId);
    if (index != -1) {
      final currentBot = bots[index];
      String newStatus = 'RUNNING';
      if (currentBot.status == 'RUNNING') {
        newStatus = 'PAUSED';
      } else if (currentBot.status == 'PAUSED') {
        newStatus = 'STOPPED';
      }
      bots[index] = TradingBot(
        id: currentBot.id,
        name: currentBot.name,
        strategyName: currentBot.strategyName,
        marketSymbol: currentBot.marketSymbol,
        status: newStatus,
        netProfit: currentBot.netProfit,
        allocation: currentBot.allocation,
        runtime: currentBot.runtime,
      );
      showToast('Bot ${currentBot.name} status changed to $newStatus');
      notifyListeners();
    }
  }

  void closePosition(String positionId) {
    positions.removeWhere((p) => p.id == positionId);
    showToast('Position $positionId closed successfully');
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final o = orders[index];
      orders[index] = TradingOrder(
        id: o.id,
        symbol: o.symbol,
        type: o.type,
        side: o.side,
        price: o.price,
        amount: o.amount,
        filledAmount: o.filledAmount,
        status: 'CANCELLED',
        timestamp: o.timestamp,
      );
      showToast('Order ${o.id} cancelled');
      notifyListeners();
    }
  }

  void addOrder(
    String symbol,
    String side,
    String type,
    double price,
    double amount,
  ) {
    final newOrder = TradingOrder(
      id: 'o${orders.length + 1}',
      symbol: symbol,
      type: type,
      side: side,
      price: price,
      amount: amount,
      filledAmount: 0.0,
      status: 'PENDING',
      timestamp: DateTime.now(),
    );
    orders.insert(0, newOrder);
    showToast('New $side $type order placed for $symbol');
    notifyListeners();
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
    notifyListeners();
  }
}
