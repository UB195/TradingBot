import 'dart:math';
import '../models/trading_models.dart';

class MockTradingService {
  static final Random _random = Random();

  static List<MarketTicker> getMockTickers() {
    return [
      MarketTicker(symbol: 'BTC/USDT', currentPrice: 96420.50, change24h: 2.45, volume24h: 45000000000, high24h: 97100.0, low24h: 93800.0, sparkline: _genSpark()),
      MarketTicker(symbol: 'ETH/USDT', currentPrice: 3450.75, change24h: -1.20, volume24h: 18000000000, high24h: 3550.0, low24h: 3410.0, sparkline: _genSpark()),
      MarketTicker(symbol: 'SOL/USDT', currentPrice: 185.30, change24h: 5.67, volume24h: 5200000000, high24h: 190.0, low24h: 172.0, sparkline: _genSpark()),
      MarketTicker(symbol: 'AVAX/USDT', currentPrice: 38.45, change24h: 0.85, volume24h: 850000000, high24h: 39.50, low24h: 37.20, sparkline: _genSpark()),
      MarketTicker(symbol: 'LINK/USDT', currentPrice: 15.20, change24h: -3.45, volume24h: 420000000, high24h: 16.10, low24h: 14.80, sparkline: _genSpark()),
      MarketTicker(symbol: 'ADA/USDT', currentPrice: 0.58, change24h: 1.12, volume24h: 320000000, high24h: 0.60, low24h: 0.56, sparkline: _genSpark()),
    ];
  }

  static List<double> _genSpark() => List.generate(20, (i) => _random.nextDouble() * 100);

  static List<TradingBot> getMockBots() {
    return [
      TradingBot(id: '1', name: 'Alpha-Grid-01', strategyName: 'Grid Trading', marketSymbol: 'BTC/USDT', status: 'RUNNING', netProfit: 1240.50, allocation: 5000.0, runtime: '12d 4h'),
      TradingBot(id: '2', name: 'Neural-Trend', strategyName: 'LSTM Momentum', marketSymbol: 'ETH/USDT', status: 'RUNNING', netProfit: -45.20, allocation: 2500.0, runtime: '3d 18h'),
      TradingBot(id: '3', name: 'Macro-Scaler', strategyName: 'Mean Reversion', marketSymbol: 'SOL/USDT', status: 'PAUSED', netProfit: 890.15, allocation: 3000.0, runtime: '45d 2h'),
      TradingBot(id: '4', name: 'Sniper-V2', strategyName: 'Breakout Scalp', marketSymbol: 'LINK/USDT', status: 'STOPPED', netProfit: 210.00, allocation: 1000.0, runtime: '1d 12h'),
    ];
  }

  static List<TradingPosition> getMockPositions() {
    return [
      TradingPosition(id: 'p1', symbol: 'BTC/USDT', side: 'LONG', entryPrice: 94200.0, markPrice: 96420.50, size: 0.25, pnl: 555.12, pnlPercent: 2.35, leverage: 10),
      TradingPosition(id: 'p2', symbol: 'SOL/USDT', side: 'SHORT', entryPrice: 192.50, markPrice: 185.30, size: 50.0, pnl: 360.00, pnlPercent: 3.74, leverage: 5),
    ];
  }

  static List<MarketSignal> getMockSignals() {
    return [
      MarketSignal(id: 's1', symbol: 'BTC/USDT', type: 'STRONG BUY', source: 'AI Research Lab', strength: 0.92, price: 96200.0, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      MarketSignal(id: 's2', symbol: 'ETH/USDT', type: 'SELL', source: 'RSI-Divergence', strength: 0.65, price: 3465.0, timestamp: DateTime.now().subtract(const Duration(minutes: 12))),
      MarketSignal(id: 's3', symbol: 'DOT/USDT', type: 'BUY', source: 'MACD-Cross', strength: 0.78, price: 7.20, timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
    ];
  }

  static RiskMetrics getMockRisk() {
    return RiskMetrics(
      dailyDrawdown: 0.85,
      maxDrawdown: 12.4,
      beta: 1.15,
      valueAtRisk: 4250.0,
      marginUsagePercent: 32.5,
      sharpeRatio: 2.1,
      volatility: 18.2,
    );
  }

  static List<LogEntry> getMockLogs() {
    return [
      LogEntry(id: 'l1', timestamp: DateTime.now().subtract(const Duration(seconds: 10)), type: 'EXECUTION', source: 'Alpha-Grid-01', message: 'Order filled: BUY 0.01 BTC at 96350.20'),
      LogEntry(id: 'l2', timestamp: DateTime.now().subtract(const Duration(minutes: 2)), type: 'INFO', source: 'ENGINE', message: 'Risk manager heart-beat check: OK'),
      LogEntry(id: 'l3', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), type: 'WARNING', source: 'BROKER_API', message: 'Latency increased to 150ms on Binance Stream'),
      LogEntry(id: 'l4', timestamp: DateTime.now().subtract(const Duration(minutes: 15)), type: 'ERROR', source: 'BOT_02', message: 'Strategy execution failed: insufficient margin'),
    ];
  }
}
