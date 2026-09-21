enum TradeSide { buy, sell }

enum PaperOrderStatus { filled, rejected }

enum EngineStatus { stopped, running }

class MarketTick {
  final String eventId;
  final String symbol;
  final double price;
  final DateTime timestamp;

  const MarketTick({
    required this.eventId,
    required this.symbol,
    required this.price,
    required this.timestamp,
  });
}

class TradeSignal {
  final String id;
  final String eventId;
  final String strategyId;
  final String symbol;
  final TradeSide side;
  final double quantity;
  final double referencePrice;
  final DateTime timestamp;

  const TradeSignal({
    required this.id,
    required this.eventId,
    required this.strategyId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.referencePrice,
    required this.timestamp,
  });
}

class PaperOrder {
  final String id;
  final String signalId;
  final String symbol;
  final TradeSide side;
  final double quantity;
  final double requestedPrice;
  final PaperOrderStatus status;
  final String? rejectionReason;
  final DateTime createdAt;

  const PaperOrder({
    required this.id,
    required this.signalId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.requestedPrice,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'signalId': signalId,
    'symbol': symbol,
    'side': side.name,
    'quantity': quantity,
    'requestedPrice': requestedPrice,
    'status': status.name,
    'rejectionReason': rejectionReason,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PaperOrder.fromJson(Map<String, dynamic> json) => PaperOrder(
    id: json['id'] as String,
    signalId: json['signalId'] as String,
    symbol: json['symbol'] as String,
    side: TradeSide.values.byName(json['side'] as String),
    quantity: (json['quantity'] as num).toDouble(),
    requestedPrice: (json['requestedPrice'] as num).toDouble(),
    status: PaperOrderStatus.values.byName(json['status'] as String),
    rejectionReason: json['rejectionReason'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class TradeFill {
  final String id;
  final String orderId;
  final String symbol;
  final TradeSide side;
  final double quantity;
  final double price;
  final double fee;
  final DateTime timestamp;

  const TradeFill({
    required this.id,
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.fee,
    required this.timestamp,
  });

  double get notional => quantity * price;

  Map<String, Object?> toJson() => {
    'id': id,
    'orderId': orderId,
    'symbol': symbol,
    'side': side.name,
    'quantity': quantity,
    'price': price,
    'fee': fee,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TradeFill.fromJson(Map<String, dynamic> json) => TradeFill(
    id: json['id'] as String,
    orderId: json['orderId'] as String,
    symbol: json['symbol'] as String,
    side: TradeSide.values.byName(json['side'] as String),
    quantity: (json['quantity'] as num).toDouble(),
    price: (json['price'] as num).toDouble(),
    fee: (json['fee'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class PaperPosition {
  final String id;
  final String symbol;
  final TradeSide openingSide;
  final double quantity;
  final double averageEntryPrice;
  final double markPrice;
  final double realizedPnl;
  final DateTime openedAt;
  final DateTime? closedAt;

  const PaperPosition({
    required this.id,
    required this.symbol,
    required this.openingSide,
    required this.quantity,
    required this.averageEntryPrice,
    required this.markPrice,
    required this.realizedPnl,
    required this.openedAt,
    this.closedAt,
  });

  bool get isOpen => closedAt == null && quantity.abs() > 1e-9;
  TradeSide get side => quantity >= 0 ? TradeSide.buy : TradeSide.sell;
  double get marketValue => quantity * markPrice;
  double get exposure => quantity.abs() * markPrice;
  double get unrealizedPnl =>
      isOpen ? (markPrice - averageEntryPrice) * quantity : 0;

  PaperPosition copyWith({
    double? quantity,
    double? averageEntryPrice,
    double? markPrice,
    double? realizedPnl,
    DateTime? closedAt,
  }) => PaperPosition(
    id: id,
    symbol: symbol,
    openingSide: openingSide,
    quantity: quantity ?? this.quantity,
    averageEntryPrice: averageEntryPrice ?? this.averageEntryPrice,
    markPrice: markPrice ?? this.markPrice,
    realizedPnl: realizedPnl ?? this.realizedPnl,
    openedAt: openedAt,
    closedAt: closedAt ?? this.closedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'symbol': symbol,
    'openingSide': openingSide.name,
    'quantity': quantity,
    'averageEntryPrice': averageEntryPrice,
    'markPrice': markPrice,
    'realizedPnl': realizedPnl,
    'openedAt': openedAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
  };

  factory PaperPosition.fromJson(Map<String, dynamic> json) => PaperPosition(
    id: json['id'] as String,
    symbol: json['symbol'] as String,
    openingSide: TradeSide.values.byName(json['openingSide'] as String),
    quantity: (json['quantity'] as num).toDouble(),
    averageEntryPrice: (json['averageEntryPrice'] as num).toDouble(),
    markPrice: (json['markPrice'] as num).toDouble(),
    realizedPnl: (json['realizedPnl'] as num).toDouble(),
    openedAt: DateTime.parse(json['openedAt'] as String),
    closedAt: json['closedAt'] == null
        ? null
        : DateTime.parse(json['closedAt'] as String),
  );
}

class PaperAccount {
  final double startingCash;
  final double cash;
  final double realizedPnl;

  const PaperAccount({
    required this.startingCash,
    required this.cash,
    required this.realizedPnl,
  });

  factory PaperAccount.initial([double cash = 100000]) =>
      PaperAccount(startingCash: cash, cash: cash, realizedPnl: 0);

  PaperAccount copyWith({double? cash, double? realizedPnl}) => PaperAccount(
    startingCash: startingCash,
    cash: cash ?? this.cash,
    realizedPnl: realizedPnl ?? this.realizedPnl,
  );

  Map<String, Object?> toJson() => {
    'startingCash': startingCash,
    'cash': cash,
    'realizedPnl': realizedPnl,
  };

  factory PaperAccount.fromJson(Map<String, dynamic> json) => PaperAccount(
    startingCash: (json['startingCash'] as num).toDouble(),
    cash: (json['cash'] as num).toDouble(),
    realizedPnl: (json['realizedPnl'] as num).toDouble(),
  );
}

class RiskSettings {
  final double maxPositionValue;
  final double maxOrderValue;
  final double maxTotalExposure;

  const RiskSettings({
    this.maxPositionValue = 25000,
    this.maxOrderValue = 10000,
    this.maxTotalExposure = 50000,
  });

  Map<String, Object?> toJson() => {
    'maxPositionValue': maxPositionValue,
    'maxOrderValue': maxOrderValue,
    'maxTotalExposure': maxTotalExposure,
  };

  factory RiskSettings.fromJson(Map<String, dynamic> json) => RiskSettings(
    maxPositionValue: (json['maxPositionValue'] as num).toDouble(),
    maxOrderValue: (json['maxOrderValue'] as num).toDouble(),
    maxTotalExposure: (json['maxTotalExposure'] as num).toDouble(),
  );
}

class EmergencyStopState {
  final bool active;
  final String? reason;
  final DateTime? activatedAt;

  const EmergencyStopState({
    this.active = false,
    this.reason,
    this.activatedAt,
  });

  Map<String, Object?> toJson() => {
    'active': active,
    'reason': reason,
    'activatedAt': activatedAt?.toIso8601String(),
  };

  factory EmergencyStopState.fromJson(Map<String, dynamic> json) =>
      EmergencyStopState(
        active: json['active'] as bool? ?? false,
        reason: json['reason'] as String?,
        activatedAt: json['activatedAt'] == null
            ? null
            : DateTime.parse(json['activatedAt'] as String),
      );
}

class PaperBotConfiguration {
  final String id;
  final String strategyId;
  final String strategyName;
  final String symbol;
  final double orderQuantity;
  final double feeRate;
  final double slippageRate;
  final int fastWindow;
  final int slowWindow;
  final EngineStatus status;

  const PaperBotConfiguration({
    this.id = 'paper-bot-001',
    this.strategyId = 'ma-crossover-v1',
    this.strategyName = 'Moving Average Crossover',
    this.symbol = 'BTC/USDT',
    this.orderQuantity = 0.05,
    this.feeRate = 0.001,
    this.slippageRate = 0.0005,
    this.fastWindow = 3,
    this.slowWindow = 5,
    this.status = EngineStatus.stopped,
  });

  PaperBotConfiguration copyWith({EngineStatus? status}) =>
      PaperBotConfiguration(
        id: id,
        strategyId: strategyId,
        strategyName: strategyName,
        symbol: symbol,
        orderQuantity: orderQuantity,
        feeRate: feeRate,
        slippageRate: slippageRate,
        fastWindow: fastWindow,
        slowWindow: slowWindow,
        status: status ?? this.status,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'strategyId': strategyId,
    'strategyName': strategyName,
    'symbol': symbol,
    'orderQuantity': orderQuantity,
    'feeRate': feeRate,
    'slippageRate': slippageRate,
    'fastWindow': fastWindow,
    'slowWindow': slowWindow,
    'status': status.name,
  };

  factory PaperBotConfiguration.fromJson(Map<String, dynamic> json) =>
      PaperBotConfiguration(
        id: json['id'] as String,
        strategyId: json['strategyId'] as String,
        strategyName: json['strategyName'] as String,
        symbol: json['symbol'] as String,
        orderQuantity: (json['orderQuantity'] as num).toDouble(),
        feeRate: (json['feeRate'] as num).toDouble(),
        slippageRate: (json['slippageRate'] as num).toDouble(),
        fastWindow: json['fastWindow'] as int,
        slowWindow: json['slowWindow'] as int,
        status: EngineStatus.values.byName(json['status'] as String),
      );
}

class AuditEvent {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;

  const AuditEvent({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AuditEvent.fromJson(Map<String, dynamic> json) => AuditEvent(
    id: json['id'] as String,
    type: json['type'] as String,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class TradingSnapshot {
  PaperAccount account;
  RiskSettings riskSettings;
  EmergencyStopState emergencyStop;
  PaperBotConfiguration bot;
  final List<PaperOrder> orders;
  final List<TradeFill> fills;
  final List<PaperPosition> openPositions;
  final List<PaperPosition> closedPositions;
  final List<AuditEvent> events;
  final Map<String, double> lastPrices;
  final Set<String> processedEventIds;
  final Set<String> processedSignalIds;
  final List<double> strategyPrices;
  List<Map<String, dynamic>> strategyDefinitions;
  Map<String, List<Map<String, dynamic>>> strategyVersions;
  int sequence;

  TradingSnapshot({
    required this.account,
    required this.riskSettings,
    required this.emergencyStop,
    required this.bot,
    required this.orders,
    required this.fills,
    required this.openPositions,
    required this.closedPositions,
    required this.events,
    required this.lastPrices,
    required this.processedEventIds,
    required this.processedSignalIds,
    required this.strategyPrices,
    required this.strategyDefinitions,
    required this.strategyVersions,
    required this.sequence,
  });

  factory TradingSnapshot.initial({double startingCash = 100000}) =>
      TradingSnapshot(
        account: PaperAccount.initial(startingCash),
        riskSettings: const RiskSettings(),
        emergencyStop: const EmergencyStopState(),
        bot: const PaperBotConfiguration(),
        orders: [],
        fills: [],
        openPositions: [],
        closedPositions: [],
        events: [],
        lastPrices: {},
        processedEventIds: {},
        processedSignalIds: {},
        strategyPrices: [],
        strategyDefinitions: [],
        strategyVersions: {},
        sequence: 0,
      );

  double get unrealizedPnl => openPositions.fold(
    0,
    (total, position) => total + position.unrealizedPnl,
  );
  double get totalExposure =>
      openPositions.fold(0, (total, position) => total + position.exposure);
  double get equity =>
      account.cash + openPositions.fold(0, (v, p) => v + p.marketValue);

  String nextId(String prefix) {
    sequence += 1;
    return '$prefix-${sequence.toString().padLeft(6, '0')}';
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'account': account.toJson(),
    'riskSettings': riskSettings.toJson(),
    'emergencyStop': emergencyStop.toJson(),
    'bot': bot.toJson(),
    'orders': orders.map((value) => value.toJson()).toList(),
    'fills': fills.map((value) => value.toJson()).toList(),
    'openPositions': openPositions.map((value) => value.toJson()).toList(),
    'closedPositions': closedPositions.map((value) => value.toJson()).toList(),
    'events': events.map((value) => value.toJson()).toList(),
    'lastPrices': lastPrices,
    'processedEventIds': processedEventIds.toList(),
    'processedSignalIds': processedSignalIds.toList(),
    'strategyPrices': strategyPrices,
    'strategyDefinitions': strategyDefinitions,
    'strategyVersions': strategyVersions,
    'sequence': sequence,
  };

  factory TradingSnapshot.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> maps(String key) =>
        (json[key] as List? ?? const [])
            .map((value) => Map<String, dynamic>.from(value as Map))
            .toList();

    return TradingSnapshot(
      account: PaperAccount.fromJson(
        Map<String, dynamic>.from(json['account'] as Map),
      ),
      riskSettings: RiskSettings.fromJson(
        Map<String, dynamic>.from(json['riskSettings'] as Map),
      ),
      emergencyStop: EmergencyStopState.fromJson(
        Map<String, dynamic>.from(json['emergencyStop'] as Map),
      ),
      bot: PaperBotConfiguration.fromJson(
        Map<String, dynamic>.from(json['bot'] as Map),
      ),
      orders: maps('orders').map(PaperOrder.fromJson).toList(),
      fills: maps('fills').map(TradeFill.fromJson).toList(),
      openPositions: maps('openPositions').map(PaperPosition.fromJson).toList(),
      closedPositions: maps(
        'closedPositions',
      ).map(PaperPosition.fromJson).toList(),
      events: maps('events').map(AuditEvent.fromJson).toList(),
      lastPrices: (json['lastPrices'] as Map? ?? const {}).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()),
      ),
      processedEventIds: Set<String>.from(
        json['processedEventIds'] as List? ?? const [],
      ),
      processedSignalIds: Set<String>.from(
        json['processedSignalIds'] as List? ?? const [],
      ),
      strategyPrices: (json['strategyPrices'] as List? ?? const [])
          .map((value) => (value as num).toDouble())
          .toList(),
      strategyDefinitions: maps('strategyDefinitions'),
      strategyVersions: (json['strategyVersions'] as Map? ?? const {}).map((
        key,
        value,
      ) {
        final versions = (value as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        return MapEntry(key as String, versions);
      }),
      sequence: json['sequence'] as int? ?? 0,
    );
  }
}
