// Data models for the no-code Strategy Builder.

class IndicatorDef {
  final String name;
  final String category;
  final String hint;
  final List<String> comparators;
  final bool
  supportsIndicatorCompare; // can be compared against another indicator
  final List<String>? periods;
  final List<String>?
  valueOptions; // fixed set of values (e.g. Market Regime states)

  const IndicatorDef({
    required this.name,
    required this.category,
    required this.hint,
    required this.comparators,
    this.supportsIndicatorCompare = false,
    this.periods,
    this.valueOptions,
  });
}

class StrategyCondition {
  static const List<String> noValueComparators = ['Rising', 'Falling'];

  final String indicator;
  final String? period;
  final String comparator;
  final String compareTo; // 'VALUE' | 'INDICATOR'
  final String
  value; // literal value or indicator name when compareTo == 'INDICATOR'
  final String connector; // 'FIRST' | 'AND' | 'OR'
  final bool not;

  const StrategyCondition({
    required this.indicator,
    required this.comparator,
    required this.compareTo,
    required this.value,
    required this.connector,
    this.period,
    this.not = false,
  });

  StrategyCondition copyWith({
    String? indicator,
    String? period,
    String? comparator,
    String? compareTo,
    String? value,
    String? connector,
    bool? not,
  }) {
    return StrategyCondition(
      indicator: indicator ?? this.indicator,
      period: period ?? this.period,
      comparator: comparator ?? this.comparator,
      compareTo: compareTo ?? this.compareTo,
      value: value ?? this.value,
      connector: connector ?? this.connector,
      not: not ?? this.not,
    );
  }

  bool get needsValue => !noValueComparators.contains(comparator);

  String describe() {
    final buffer = StringBuffer();
    if (not) buffer.write('NOT ');
    buffer.write(indicator);
    final p = period ?? '';
    if (p.isNotEmpty) buffer.write('($p)');
    buffer.write(' $comparator');
    if (needsValue && value.isNotEmpty) buffer.write(' $value');
    return buffer.toString();
  }
}

class ExitRuleConfig {
  final bool targetEnabled;
  final double targetPercent;
  final bool stopLossEnabled;
  final double stopLossPercent;
  final bool trailingEnabled;
  final double trailingPercent;
  final bool timeExitEnabled;
  final int timeExitBars;
  final bool indicatorReversalEnabled;
  final String reversalIndicator;
  final bool eodExitEnabled;

  const ExitRuleConfig({
    this.targetEnabled = true,
    this.targetPercent = 2.0,
    this.stopLossEnabled = true,
    this.stopLossPercent = 1.0,
    this.trailingEnabled = false,
    this.trailingPercent = 1.5,
    this.timeExitEnabled = false,
    this.timeExitBars = 60,
    this.indicatorReversalEnabled = false,
    this.reversalIndicator = 'RSI',
    this.eodExitEnabled = false,
  });
}

class AdvancedRiskConfig {
  final String positionSizingMethod;
  final double positionSizingValue;
  final double riskPerTradePercent;
  final int maxTradesPerDay;
  final double maxDailyLossPercent;
  final String tradingSession;
  final int cooldownMinutes;

  const AdvancedRiskConfig({
    this.positionSizingMethod = 'Percent of Equity',
    this.positionSizingValue = 10.0,
    this.riskPerTradePercent = 1.0,
    this.maxTradesPerDay = 5,
    this.maxDailyLossPercent = 3.0,
    this.tradingSession = '24/7 Continuous',
    this.cooldownMinutes = 15,
  });
}

class StrategyConfig {
  final String id;
  final String name;
  final String description;
  final String market;
  final String instrument;
  final String timeframe;
  final String version;
  final String status; // DRAFT, BACKTESTING, BETA, PRODUCTION, ARCHIVED

  // Performance snapshot (mock stats shown in the strategies grid)
  final String type;
  final double winRate;
  final double totalProfit;
  final double sharpeRatio;

  final List<StrategyCondition> entryConditions;
  final ExitRuleConfig exitRules;
  final AdvancedRiskConfig advanced;
  final DateTime lastModified;

  const StrategyConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.market,
    required this.instrument,
    required this.timeframe,
    required this.version,
    required this.status,
    required this.entryConditions,
    required this.exitRules,
    required this.advanced,
    required this.lastModified,
    this.type = 'Rule-Based',
    this.winRate = 0.0,
    this.totalProfit = 0.0,
    this.sharpeRatio = 0.0,
  });

  StrategyConfig copyWith({
    String? id,
    String? name,
    String? description,
    String? market,
    String? instrument,
    String? timeframe,
    String? version,
    String? status,
    String? type,
    double? winRate,
    double? totalProfit,
    double? sharpeRatio,
    List<StrategyCondition>? entryConditions,
    ExitRuleConfig? exitRules,
    AdvancedRiskConfig? advanced,
    DateTime? lastModified,
  }) {
    return StrategyConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      market: market ?? this.market,
      instrument: instrument ?? this.instrument,
      timeframe: timeframe ?? this.timeframe,
      version: version ?? this.version,
      status: status ?? this.status,
      type: type ?? this.type,
      winRate: winRate ?? this.winRate,
      totalProfit: totalProfit ?? this.totalProfit,
      sharpeRatio: sharpeRatio ?? this.sharpeRatio,
      entryConditions: entryConditions ?? this.entryConditions,
      exitRules: exitRules ?? this.exitRules,
      advanced: advanced ?? this.advanced,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class StrategyVersion {
  final String version;
  final DateTime timestamp;
  final String changeNote;
  final StrategyConfig snapshot;

  const StrategyVersion({
    required this.version,
    required this.timestamp,
    required this.changeNote,
    required this.snapshot,
  });
}
