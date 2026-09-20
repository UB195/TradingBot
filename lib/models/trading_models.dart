class MarketTicker {
  final String symbol;
  final double currentPrice;
  final double change24h;
  final double volume24h;
  final double high24h;
  final double low24h;
  final List<double> sparkline;

  MarketTicker({
    required this.symbol,
    required this.currentPrice,
    required this.change24h,
    required this.volume24h,
    required this.high24h,
    required this.low24h,
    required this.sparkline,
  });
}

class Strategy {
  final String id;
  final String name;
  final String type;
  final double winRate;
  final double totalProfit;
  final double sharpeRatio;
  final String status;
  final String description;

  Strategy({
    required this.id,
    required this.name,
    required this.type,
    required this.winRate,
    required this.totalProfit,
    required this.sharpeRatio,
    required this.status,
    required this.description,
  });
}

class TradingBot {
  final String id;
  final String name;
  final String strategyName;
  final String marketSymbol;
  final String status; // 'RUNNING', 'PAUSED', 'STOPPED'
  final double netProfit;
  final double allocation;
  final String runtime;

  TradingBot({
    required this.id,
    required this.name,
    required this.strategyName,
    required this.marketSymbol,
    required this.status,
    required this.netProfit,
    required this.allocation,
    required this.runtime,
  });
}

class MarketSignal {
  final String id;
  final String symbol;
  final String type; // 'BUY', 'STRONG BUY', 'SELL', 'STRONG SELL'
  final String source; // 'AI Core', 'MACD-Cross', 'RSI-Oversold'
  final double strength; // 0.0 to 1.0
  final double price;
  final DateTime timestamp;

  MarketSignal({
    required this.id,
    required this.symbol,
    required this.type,
    required this.source,
    required this.strength,
    required this.price,
    required this.timestamp,
  });
}

class TradingPosition {
  final String id;
  final String symbol;
  final String side; // 'LONG', 'SHORT'
  final double entryPrice;
  final double markPrice;
  final double size;
  final double pnl;
  final double pnlPercent;
  final int leverage;

  TradingPosition({
    required this.id,
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.markPrice,
    required this.size,
    required this.pnl,
    required this.pnlPercent,
    required this.leverage,
  });
}

class TradingOrder {
  final String id;
  final String symbol;
  final String type; // 'LIMIT', 'MARKET', 'STOP-LIMIT'
  final String side; // 'BUY', 'SELL'
  final double price;
  final double amount;
  final double filledAmount;
  final String status; // 'PENDING', 'FILLED', 'CANCELLED'
  final DateTime timestamp;

  TradingOrder({
    required this.id,
    required this.symbol,
    required this.type,
    required this.side,
    required this.price,
    required this.amount,
    required this.filledAmount,
    required this.status,
    required this.timestamp,
  });
}

class PortfolioAsset {
  final String asset;
  final String name;
  final double balance;
  final double available;
  final double valueUsd;
  final double allocationPercent;

  PortfolioAsset({
    required this.asset,
    required this.name,
    required this.balance,
    required this.available,
    required this.valueUsd,
    required this.allocationPercent,
  });
}

class RiskMetrics {
  final double dailyDrawdown;
  final double maxDrawdown;
  final double beta;
  final double valueAtRisk;
  final double marginUsagePercent;
  final double sharpeRatio;
  final double volatility;

  RiskMetrics({
    required this.dailyDrawdown,
    required this.maxDrawdown,
    required this.beta,
    required this.valueAtRisk,
    required this.marginUsagePercent,
    required this.sharpeRatio,
    required this.volatility,
  });
}

class BacktestResult {
  final String strategyName;
  final String symbol;
  final String timeframe;
  final int totalTrades;
  final double winRate;
  final double profitFactor;
  final double netReturnPercent;
  final double maxDrawdownPercent;

  BacktestResult({
    required this.strategyName,
    required this.symbol,
    required this.timeframe,
    required this.totalTrades,
    required this.winRate,
    required this.profitFactor,
    required this.netReturnPercent,
    required this.maxDrawdownPercent,
  });
}

class OptionContract {
  final String symbol;
  final double strikePrice;
  final DateTime expiration;
  final String type; // 'CALL', 'PUT'
  final double premium;
  final double impliedVolPercent;
  final double delta;
  final int openInterest;

  OptionContract({
    required this.symbol,
    required this.strikePrice,
    required this.expiration,
    required this.type,
    required this.premium,
    required this.impliedVolPercent,
    required this.delta,
    required this.openInterest,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String source;
  final String sentiment; // 'BULLISH', 'BEARISH', 'NEUTRAL'
  final DateTime timestamp;
  final String summary;

  NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.sentiment,
    required this.timestamp,
    required this.summary,
  });
}

class LogEntry {
  final String id;
  final DateTime timestamp;
  final String type; // 'INFO', 'WARNING', 'ERROR', 'EXECUTION'
  final String source; // 'ENGINE', 'BROKER_API', 'RISK_MANAGER', 'BOT_04'
  final String message;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.source,
    required this.message,
  });
}
