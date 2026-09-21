import '../models/strategy_builder_models.dart';

class StrategyPersistenceMapper {
  const StrategyPersistenceMapper._();

  static Map<String, dynamic> configToJson(StrategyConfig value) => {
    'id': value.id,
    'name': value.name,
    'description': value.description,
    'market': value.market,
    'instrument': value.instrument,
    'timeframe': value.timeframe,
    'version': value.version,
    'status': value.status,
    'type': value.type,
    'winRate': value.winRate,
    'totalProfit': value.totalProfit,
    'sharpeRatio': value.sharpeRatio,
    'entryConditions': value.entryConditions
        .map(
          (condition) => {
            'indicator': condition.indicator,
            'period': condition.period,
            'comparator': condition.comparator,
            'compareTo': condition.compareTo,
            'value': condition.value,
            'connector': condition.connector,
            'not': condition.not,
          },
        )
        .toList(),
    'exitRules': {
      'targetEnabled': value.exitRules.targetEnabled,
      'targetPercent': value.exitRules.targetPercent,
      'stopLossEnabled': value.exitRules.stopLossEnabled,
      'stopLossPercent': value.exitRules.stopLossPercent,
      'trailingEnabled': value.exitRules.trailingEnabled,
      'trailingPercent': value.exitRules.trailingPercent,
      'timeExitEnabled': value.exitRules.timeExitEnabled,
      'timeExitBars': value.exitRules.timeExitBars,
      'indicatorReversalEnabled': value.exitRules.indicatorReversalEnabled,
      'reversalIndicator': value.exitRules.reversalIndicator,
      'eodExitEnabled': value.exitRules.eodExitEnabled,
    },
    'advanced': {
      'positionSizingMethod': value.advanced.positionSizingMethod,
      'positionSizingValue': value.advanced.positionSizingValue,
      'riskPerTradePercent': value.advanced.riskPerTradePercent,
      'maxTradesPerDay': value.advanced.maxTradesPerDay,
      'maxDailyLossPercent': value.advanced.maxDailyLossPercent,
      'tradingSession': value.advanced.tradingSession,
      'cooldownMinutes': value.advanced.cooldownMinutes,
    },
    'lastModified': value.lastModified.toIso8601String(),
  };

  static StrategyConfig configFromJson(Map<String, dynamic> json) {
    final exit = Map<String, dynamic>.from(json['exitRules'] as Map);
    final advanced = Map<String, dynamic>.from(json['advanced'] as Map);
    return StrategyConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      market: json['market'] as String,
      instrument: json['instrument'] as String,
      timeframe: json['timeframe'] as String,
      version: json['version'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      winRate: (json['winRate'] as num).toDouble(),
      totalProfit: (json['totalProfit'] as num).toDouble(),
      sharpeRatio: (json['sharpeRatio'] as num).toDouble(),
      entryConditions: (json['entryConditions'] as List)
          .map((raw) => Map<String, dynamic>.from(raw as Map))
          .map(
            (condition) => StrategyCondition(
              indicator: condition['indicator'] as String,
              period: condition['period'] as String?,
              comparator: condition['comparator'] as String,
              compareTo: condition['compareTo'] as String,
              value: condition['value'] as String,
              connector: condition['connector'] as String,
              not: condition['not'] as bool? ?? false,
            ),
          )
          .toList(),
      exitRules: ExitRuleConfig(
        targetEnabled: exit['targetEnabled'] as bool,
        targetPercent: (exit['targetPercent'] as num).toDouble(),
        stopLossEnabled: exit['stopLossEnabled'] as bool,
        stopLossPercent: (exit['stopLossPercent'] as num).toDouble(),
        trailingEnabled: exit['trailingEnabled'] as bool,
        trailingPercent: (exit['trailingPercent'] as num).toDouble(),
        timeExitEnabled: exit['timeExitEnabled'] as bool,
        timeExitBars: exit['timeExitBars'] as int,
        indicatorReversalEnabled: exit['indicatorReversalEnabled'] as bool,
        reversalIndicator: exit['reversalIndicator'] as String,
        eodExitEnabled: exit['eodExitEnabled'] as bool,
      ),
      advanced: AdvancedRiskConfig(
        positionSizingMethod: advanced['positionSizingMethod'] as String,
        positionSizingValue: (advanced['positionSizingValue'] as num)
            .toDouble(),
        riskPerTradePercent: (advanced['riskPerTradePercent'] as num)
            .toDouble(),
        maxTradesPerDay: advanced['maxTradesPerDay'] as int,
        maxDailyLossPercent: (advanced['maxDailyLossPercent'] as num)
            .toDouble(),
        tradingSession: advanced['tradingSession'] as String,
        cooldownMinutes: advanced['cooldownMinutes'] as int,
      ),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  static Map<String, dynamic> versionToJson(StrategyVersion value) => {
    'version': value.version,
    'timestamp': value.timestamp.toIso8601String(),
    'changeNote': value.changeNote,
    'snapshot': configToJson(value.snapshot),
  };

  static StrategyVersion versionFromJson(Map<String, dynamic> json) =>
      StrategyVersion(
        version: json['version'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        changeNote: json['changeNote'] as String,
        snapshot: configFromJson(
          Map<String, dynamic>.from(json['snapshot'] as Map),
        ),
      );
}
