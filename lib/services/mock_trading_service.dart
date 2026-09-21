import 'dart:math';
import '../models/trading_models.dart';

class MockTradingService {
  static final Random _random = Random();

  static List<MarketTicker> getMockTickers() {
    return [
      MarketTicker(
        symbol: 'BTC/USDT',
        currentPrice: 96420.50,
        change24h: 2.45,
        volume24h: 45000000000,
        high24h: 97100.0,
        low24h: 93800.0,
        sparkline: _genSpark(),
      ),
      MarketTicker(
        symbol: 'ETH/USDT',
        currentPrice: 3450.75,
        change24h: -1.20,
        volume24h: 18000000000,
        high24h: 3550.0,
        low24h: 3410.0,
        sparkline: _genSpark(),
      ),
      MarketTicker(
        symbol: 'SOL/USDT',
        currentPrice: 185.30,
        change24h: 5.67,
        volume24h: 5200000000,
        high24h: 190.0,
        low24h: 172.0,
        sparkline: _genSpark(),
      ),
      MarketTicker(
        symbol: 'AVAX/USDT',
        currentPrice: 38.45,
        change24h: 0.85,
        volume24h: 850000000,
        high24h: 39.50,
        low24h: 37.20,
        sparkline: _genSpark(),
      ),
      MarketTicker(
        symbol: 'LINK/USDT',
        currentPrice: 15.20,
        change24h: -3.45,
        volume24h: 420000000,
        high24h: 16.10,
        low24h: 14.80,
        sparkline: _genSpark(),
      ),
      MarketTicker(
        symbol: 'ADA/USDT',
        currentPrice: 0.58,
        change24h: 1.12,
        volume24h: 320000000,
        high24h: 0.60,
        low24h: 0.56,
        sparkline: _genSpark(),
      ),
    ];
  }

  static List<double> _genSpark() =>
      List.generate(20, (i) => _random.nextDouble() * 100);

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
}
