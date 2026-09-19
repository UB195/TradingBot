import 'package:flutter/material.dart';
import '../models/trading_models.dart';
import '../theme/trading_theme.dart';

class TopMarketTicker extends StatelessWidget {
  final List<MarketTicker> tickers;

  const TopMarketTicker({super.key, required this.tickers});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: TradingTheme.surface,
        border: Border(bottom: BorderSide(color: TradingTheme.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tickers.length,
        itemBuilder: (context, index) {
          final ticker = tickers[index];
          final isPos = ticker.change24h >= 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: TradingTheme.border)),
            ),
            child: Row(
              children: [
                Text(
                  ticker.symbol,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${ticker.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  '${isPos ? '+' : ''}${ticker.change24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPos ? TradingTheme.bullish : TradingTheme.bearish,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
