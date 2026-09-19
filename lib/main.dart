import 'package:flutter/material.dart';
import 'theme/trading_theme.dart';
import 'state/trading_state.dart';
import 'components/side_navigation.dart';
import 'components/top_market_ticker.dart';
import 'components/custom_widgets.dart';
import 'views/trading_views.dart';

void main() {
  runApp(const TradingBotApp());
}

class TradingBotApp extends StatelessWidget {
  final TradingState? state; // injectable for tests; defaults to a fresh instance

  const TradingBotApp({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Algorithmic Trading Platform',
      theme: TradingTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: MainLayoutScreen(state: state),
    );
  }
}

class MainLayoutScreen extends StatefulWidget {
  final TradingState? state;

  const MainLayoutScreen({super.key, this.state});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late final TradingState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.state ?? TradingState();
  }

  Widget _buildActiveView(int index) {
    switch (index) {
      case 0: return DashboardView(state: _state);
      case 1: return MarketsView(state: _state);
      case 2: return StrategiesView(state: _state);
      case 3: return BotsView(state: _state);
      case 4: return SignalsView(state: _state);
      case 5: return PositionsView(state: _state);
      case 6: return OrdersView(state: _state);
      case 7: return PortfolioView(state: _state);
      case 8: return RiskView(state: _state);
      case 9: return BacktestingView(state: _state);
      case 10: return AiResearchLabView(state: _state);
      case 11: return OptionsView(state: _state);
      case 12: return NewsEventsView(state: _state);
      case 13: return AnalyticsView(state: _state);
      case 14: return LogsView(state: _state);
      case 15: return BrokerView(state: _state);
      case 16: return SettingsView(state: _state);
      default: return DashboardView(state: _state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              Row(
                children: [
                  SideNavigation(
                    selectedIndex: _state.currentSectionIndex,
                    onDestinationSelected: (idx) => _state.setSection(idx),
                    sections: _state.sections,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TopMarketTicker(tickers: _state.tickers),
                        Expanded(
                          child: _buildActiveView(_state.currentSectionIndex),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Global Toast overlay renderer
              if (_state.activeToasts.isNotEmpty)
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _state.activeToasts
                        .map((msg) => CustomToast(message: msg))
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
