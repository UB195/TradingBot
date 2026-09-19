import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_bot/main.dart';

void main() {
  testWidgets('Trading platform dashboard smoke test', (WidgetTester tester) async {
    // Set a desktop-like viewport size via binding to prevent any constraints overflows
    await tester.binding.setSurfaceSize(const Size(1920, 1080));

    // Build our app and trigger a frame.
    await tester.pumpWidget(const TradingBotApp());
    await tester.pumpAndSettle();

    // Verify that the trading platform title is found.
    expect(find.text('TRADINGBOT'), findsOneWidget);
    expect(find.text('System Dashboard'), findsOneWidget);

    // Reset surface size
    await tester.binding.setSurfaceSize(null);
  });
}
