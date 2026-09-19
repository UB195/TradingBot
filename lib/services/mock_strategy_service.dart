import '../models/strategy_builder_models.dart';

class MockStrategyService {
  static const List<String> markets = ['Crypto', 'US Equities', 'Forex', 'Futures', 'Options'];
  static const List<String> timeframes = ['1m', '5m', '15m', '30m', '1H', '4H', '1D', '1W'];
  static const List<String> statuses = ['DRAFT', 'BACKTESTING', 'BETA', 'PRODUCTION', 'ARCHIVED'];
  static const List<String> instruments = [
    'BTC/USDT', 'ETH/USDT', 'SOL/USDT', 'AVAX/USDT', 'LINK/USDT', 'ADA/USDT',
    'AAPL', 'TSLA', 'NVDA', 'SPY', 'EUR/USD', 'XAU/USD',
  ];
  static const List<String> sessions = [
    '24/7 Continuous',
    'US Session (13:30 - 20:00 UTC)',
    'European Session (07:00 - 16:00 UTC)',
    'Asian Session (00:00 - 09:00 UTC)',
    'Custom Window',
  ];
  static const List<String> sizingMethods = [
    'Fixed Amount',
    'Percent of Equity',
    'Risk-Per-Trade Based',
    'Volatility Adjusted',
  ];

  static const List<IndicatorDef> indicators = [
    IndicatorDef(
      name: 'Price',
      category: 'Price Action',
      hint: 'Last traded price of the instrument',
      comparators: ['>', '<', '>=', '<=', '=', 'Crosses Above', 'Crosses Below'],
      supportsIndicatorCompare: true,
    ),
    IndicatorDef(
      name: 'EMA',
      category: 'Trend',
      hint: 'Exponential Moving Average',
      comparators: ['>', '<', '>=', '<=', '=', 'Crosses Above', 'Crosses Below'],
      supportsIndicatorCompare: true,
      periods: ['9', '21', '50', '100', '200'],
    ),
    IndicatorDef(
      name: 'SMA',
      category: 'Trend',
      hint: 'Simple Moving Average',
      comparators: ['>', '<', '>=', '<=', '=', 'Crosses Above', 'Crosses Below'],
      supportsIndicatorCompare: true,
      periods: ['9', '21', '50', '100', '200'],
    ),
    IndicatorDef(
      name: 'VWAP',
      category: 'Volume',
      hint: 'Volume Weighted Average Price',
      comparators: ['>', '<', '>=', '<=', '=', 'Crosses Above', 'Crosses Below'],
      supportsIndicatorCompare: true,
    ),
    IndicatorDef(
      name: 'RSI',
      category: 'Momentum',
      hint: 'Relative Strength Index (0-100)',
      comparators: ['>', '<', '>=', '<=', '=', 'Crosses Above', 'Crosses Below'],
      periods: ['7', '14', '21'],
    ),
    IndicatorDef(
      name: 'MACD',
      category: 'Momentum',
      hint: 'MACD line vs signal line',
      comparators: ['Crosses Above', 'Crosses Below', '>', '<'],
      supportsIndicatorCompare: true,
    ),
    IndicatorDef(
      name: 'Bollinger Bands',
      category: 'Volatility',
      hint: 'Standard deviation bands around a moving average',
      comparators: ['='],
      periods: ['20', '50'],
      valueOptions: [
        'Above Upper Band', 'Below Lower Band', 'Inside Bands', 'Bandwidth Squeeze',
      ],
    ),
    IndicatorDef(
      name: 'ATR',
      category: 'Volatility',
      hint: 'Average True Range (volatility measure)',
      comparators: ['>', '<', '>=', '<=', 'Rising', 'Falling'],
      periods: ['14', '20'],
    ),
    IndicatorDef(
      name: 'Volume',
      category: 'Volume',
      hint: 'Traded volume; supports expressions like "1.5 × Average Volume"',
      comparators: ['>', '<', '>=', '<=', '=', 'Rising', 'Falling'],
      supportsIndicatorCompare: true,
    ),
    IndicatorDef(
      name: 'Open Interest',
      category: 'Derivatives',
      hint: 'Total outstanding derivative contracts',
      comparators: ['>', '<', '>=', '<=', 'Rising', 'Falling'],
    ),
    IndicatorDef(
      name: 'Support/Resistance',
      category: 'Price Action',
      hint: 'Key structural price levels',
      comparators: ['Crosses Above', 'Crosses Below', '>', '<', '>=', '<='],
      valueOptions: [
        'Support Level', 'Resistance Level', 'Previous Day High', 'Previous Day Low', 'Weekly Pivot',
      ],
    ),
    IndicatorDef(
      name: 'Breakout',
      category: 'Price Action',
      hint: 'Breakout event detection',
      comparators: ['='],
      valueOptions: [
        'Resistance Breakout', 'Support Breakdown', 'Range High Breakout', 'Range Low Breakdown', 'Failed Breakout',
      ],
    ),
    IndicatorDef(
      name: 'Market Regime',
      category: 'Meta',
      hint: 'Detected broad market state',
      comparators: ['='],
      valueOptions: ['Bullish', 'Bearish', 'Neutral', 'High Volatility', 'Range-Bound', 'Trending'],
    ),
  ];

  static const List<StrategyCondition> exampleConditions = [
    StrategyCondition(indicator: 'RSI', period: '14', comparator: '>', compareTo: 'VALUE', value: '60', connector: 'FIRST'),
    StrategyCondition(indicator: 'Price', comparator: '>', compareTo: 'INDICATOR', value: 'VWAP', connector: 'AND'),
    StrategyCondition(indicator: 'Volume', comparator: '>', compareTo: 'VALUE', value: '1.5 × Average Volume', connector: 'AND'),
    StrategyCondition(indicator: 'Market Regime', comparator: '=', compareTo: 'VALUE', value: 'Bullish', connector: 'AND'),
  ];

  static List<StrategyConfig> getMockStrategies() {
    final now = DateTime.now();
    return [
      StrategyConfig(
        id: 'STR-001',
        name: 'Alpha Mean Reversion',
        description: 'Exploits mathematical pricing imbalances across correlated token clusters.',
        market: 'Crypto',
        instrument: 'BTC/USDT',
        timeframe: '15m',
        version: 'v2.1.0',
        status: 'PRODUCTION',
        type: 'Statistical Arbitrage',
        winRate: 64.2,
        totalProfit: 45200.0,
        sharpeRatio: 2.4,
        lastModified: now.subtract(const Duration(days: 6)),
        entryConditions: [
          const StrategyCondition(indicator: 'RSI', period: '14', comparator: '<', compareTo: 'VALUE', value: '30', connector: 'FIRST'),
          const StrategyCondition(indicator: 'Bollinger Bands', period: '20', comparator: '=', compareTo: 'VALUE', value: 'Below Lower Band', connector: 'AND'),
          const StrategyCondition(indicator: 'Market Regime', comparator: '=', compareTo: 'VALUE', value: 'Range-Bound', connector: 'AND'),
          const StrategyCondition(indicator: 'ATR', period: '14', comparator: '<', compareTo: 'VALUE', value: '2.0', connector: 'AND'),
        ],
        exitRules: const ExitRuleConfig(
          targetEnabled: true, targetPercent: 1.8,
          stopLossEnabled: true, stopLossPercent: 0.9,
          trailingEnabled: true, trailingPercent: 0.8,
          timeExitEnabled: true, timeExitBars: 48,
          indicatorReversalEnabled: true, reversalIndicator: 'RSI',
        ),
        advanced: const AdvancedRiskConfig(
          positionSizingMethod: 'Volatility Adjusted', positionSizingValue: 12.0,
          riskPerTradePercent: 0.8, maxTradesPerDay: 8,
          maxDailyLossPercent: 2.5, tradingSession: '24/7 Continuous', cooldownMinutes: 10,
        ),
      ),
      StrategyConfig(
        id: 'STR-002',
        name: 'LSTM Neural Momentum',
        description: 'Predicts high-probability trend breakouts using sequential pattern history.',
        market: 'Crypto',
        instrument: 'ETH/USDT',
        timeframe: '1H',
        version: 'v1.4.2',
        status: 'BETA',
        type: 'Deep Learning',
        winRate: 58.7,
        totalProfit: 21900.0,
        sharpeRatio: 1.8,
        lastModified: now.subtract(const Duration(days: 2)),
        entryConditions: [
          const StrategyCondition(indicator: 'MACD', comparator: 'Crosses Above', compareTo: 'INDICATOR', value: 'EMA', connector: 'FIRST'),
          const StrategyCondition(indicator: 'Price', comparator: '>', compareTo: 'INDICATOR', value: 'EMA', connector: 'AND'),
          const StrategyCondition(indicator: 'Volume', comparator: '>', compareTo: 'VALUE', value: '1.5 × Average Volume', connector: 'AND'),
          const StrategyCondition(indicator: 'Market Regime', comparator: '=', compareTo: 'VALUE', value: 'Bullish', connector: 'AND'),
        ],
        exitRules: const ExitRuleConfig(
          targetEnabled: true, targetPercent: 3.5,
          stopLossEnabled: true, stopLossPercent: 1.5,
          trailingEnabled: true, trailingPercent: 1.2,
          eodExitEnabled: true,
        ),
        advanced: const AdvancedRiskConfig(
          positionSizingMethod: 'Risk-Per-Trade Based', positionSizingValue: 1.2,
          riskPerTradePercent: 1.2, maxTradesPerDay: 3,
          maxDailyLossPercent: 4.0, tradingSession: 'US Session (13:30 - 20:00 UTC)', cooldownMinutes: 45,
        ),
      ),
      StrategyConfig(
        id: 'STR-003',
        name: 'Dynamic High-Frequency Grid',
        description: 'Places structural buy/sell grids to secure delta-neutral execution profits.',
        market: 'Crypto',
        instrument: 'SOL/USDT',
        timeframe: '5m',
        version: 'v3.0.1',
        status: 'PRODUCTION',
        type: 'Market Making',
        winRate: 72.1,
        totalProfit: 89000.0,
        sharpeRatio: 3.1,
        lastModified: now.subtract(const Duration(hours: 20)),
        entryConditions: [
          const StrategyCondition(indicator: 'Price', comparator: '>', compareTo: 'INDICATOR', value: 'VWAP', connector: 'FIRST'),
          const StrategyCondition(indicator: 'Breakout', comparator: '=', compareTo: 'VALUE', value: 'Range High Breakout', connector: 'AND'),
          const StrategyCondition(indicator: 'Volume', comparator: '>', compareTo: 'VALUE', value: '2.0 × Average Volume', connector: 'AND'),
          const StrategyCondition(indicator: 'Open Interest', comparator: '=', compareTo: 'VALUE', value: 'Rising', connector: 'OR'),
        ],
        exitRules: const ExitRuleConfig(
          targetEnabled: true, targetPercent: 0.6,
          stopLossEnabled: true, stopLossPercent: 0.4,
          timeExitEnabled: true, timeExitBars: 12,
        ),
        advanced: const AdvancedRiskConfig(
          positionSizingMethod: 'Fixed Amount', positionSizingValue: 2500.0,
          riskPerTradePercent: 0.5, maxTradesPerDay: 25,
          maxDailyLossPercent: 1.5, tradingSession: '24/7 Continuous', cooldownMinutes: 5,
        ),
      ),
    ];
  }

  static Map<String, List<StrategyVersion>> getMockVersionHistory() {
    final now = DateTime.now();
    final strategies = getMockStrategies();
    final alpha = strategies[0];
    final lstm = strategies[1];
    final grid = strategies[2];
    return {
      alpha.id: [
        StrategyVersion(
          version: alpha.version,
          timestamp: now.subtract(const Duration(days: 6)),
          changeNote: 'Tightened ATR volatility ceiling and reduced per-trade risk to 0.8%.',
          snapshot: alpha,
        ),
        StrategyVersion(
          version: 'v2.0.0',
          timestamp: now.subtract(const Duration(days: 34)),
          changeNote: 'Added Range-Bound market regime filter to avoid trend-driven false signals.',
          snapshot: alpha,
        ),
        StrategyVersion(
          version: 'v1.1.0',
          timestamp: now.subtract(const Duration(days: 78)),
          changeNote: 'Initial production release with RSI oversold + lower Bollinger Band entry.',
          snapshot: alpha,
        ),
      ],
      lstm.id: [
        StrategyVersion(
          version: lstm.version,
          timestamp: now.subtract(const Duration(days: 2)),
          changeNote: 'Switched volume filter threshold to 1.5× average volume.',
          snapshot: lstm,
        ),
        StrategyVersion(
          version: 'v1.2.0',
          timestamp: now.subtract(const Duration(days: 26)),
          changeNote: 'Replaced SMA(50) trend filter with EMA cross confirmation.',
          snapshot: lstm,
        ),
      ],
      grid.id: [
        StrategyVersion(
          version: grid.version,
          timestamp: now.subtract(const Duration(hours: 20)),
          changeNote: 'Added Open Interest OR-condition to capture derivatives-driven breakouts.',
          snapshot: grid,
        ),
        StrategyVersion(
          version: 'v2.4.0',
          timestamp: now.subtract(const Duration(days: 15)),
          changeNote: 'Reduced grid step and cooldown to improve fill frequency.',
          snapshot: grid,
        ),
      ],
    };
  }
}