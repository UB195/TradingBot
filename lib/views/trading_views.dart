import 'package:flutter/material.dart';
import '../state/trading_state.dart';
import '../theme/trading_theme.dart';
import '../models/trading_models.dart';
import '../components/kpi_card.dart';
import '../components/custom_widgets.dart';
import 'strategy_builder_view.dart';

class ViewContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  const ViewContainer({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TradingTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              if (actions != null) Row(children: actions!),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// 1. Dashboard View - Professional Trading Command Center
class DashboardView extends StatelessWidget {
  final TradingState state;
  const DashboardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Trading Command Center',
      subtitle: 'Account: TRADER_PRO_01 | Last Update: Just Now',
      actions: [
        const StatusIndicator(label: 'Paper Simulator', isConnected: true),
        const SizedBox(width: 16),
        const StatusIndicator(label: 'Data', isConnected: true),
        const SizedBox(width: 24),
        TradingButton(
          label: 'Refresh',
          icon: Icons.refresh,
          onPressed: () => state.showToast('Refreshing system data...'),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Main Analytics (3/4 width)
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                // KPI Grid
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.6,
                  children: const [
                    KpiCard(
                      title: 'Portfolio Value',
                      value: '\$267,606.70',
                      subtext: '+2.4%',
                      icon: Icons.account_balance_wallet,
                    ),
                    KpiCard(
                      title: 'Available Capital',
                      value: '\$95,000.00',
                      subtext: 'Ready for deployment',
                      icon: Icons.monetization_on,
                    ),
                    KpiCard(
                      title: 'Today\'s P&L',
                      value: '+\$1,240.50',
                      valueColor: TradingTheme.bullish,
                      subtext: '+1.1%',
                      icon: Icons.trending_up,
                    ),
                    KpiCard(
                      title: 'Overall P&L',
                      value: '+\$24,532.80',
                      valueColor: TradingTheme.bullish,
                      subtext: '+24.5%',
                      icon: Icons.show_chart,
                    ),
                    KpiCard(
                      title: 'Realized P&L',
                      value: '\$18,200.00',
                      subtext: 'Booked gains',
                      icon: Icons.attach_money,
                    ),
                    KpiCard(
                      title: 'Unrealized P&L',
                      value: '\$6,332.80',
                      subtext: 'Paper gains',
                      icon: Icons.bar_chart,
                    ),
                    KpiCard(
                      title: 'Drawdown',
                      value: '-1.2%',
                      valueColor: TradingTheme.bearish,
                      subtext: 'Current vs Peak',
                      icon: Icons.warning,
                    ),
                    KpiCard(
                      title: 'Risk Exposure',
                      value: '65%',
                      subtext: 'Portfolio at risk',
                      icon: Icons.gpp_maybe,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Charts Row
                const Row(
                  children: [
                    Expanded(
                      child: ChartContainer(
                        title: 'Portfolio Equity Curve',
                        child: MockChartPainter(color: TradingTheme.primary),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ChartContainer(
                        title: 'Drawdown History',
                        child: MockChartPainter(color: TradingTheme.bearish),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tables Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DashboardActivePositions(state: state),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DashboardRecentOrders(state: state),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right Column - Sidebar (1/4 width)
          Expanded(
            flex: 1,
            child: ListView(
              children: [
                const SidebarCard(
                  title: 'Market Status',
                  child: MarketStatusWidget(),
                ),
                const SizedBox(height: 16),
                SidebarCard(
                  title: 'Live Trading Signals',
                  child: LiveSignalsWidget(state: state),
                ),
                const SizedBox(height: 16),
                SidebarCard(
                  title: 'System Health',
                  child: SystemStatusWidget(state: state),
                ),
                const SizedBox(height: 16),
                const SidebarCard(
                  title: 'Risk Alerts',
                  backgroundColor: Color(0x33F44336),
                  child: RiskAlertsWidget(),
                ),
                const SizedBox(height: 24),
                EmergencyKillButton(
                  onPressed: () => _showConfirmation(
                    context,
                    'EMERGENCY KILL',
                    'Block all new simulated orders immediately?',
                    () {
                      state.activateEmergencyStop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Dashboard Supporting Widgets ---

class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isConnected;
  const StatusIndicator({
    super.key,
    required this.label,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class ChartContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const ChartContainer({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 150, width: double.infinity, child: child),
          ],
        ),
      ),
    );
  }
}

class MockChartPainter extends StatelessWidget {
  final Color color;
  const MockChartPainter({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ChartPainter(color));
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  _ChartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SidebarCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;
  const SidebarCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class MarketStatusWidget extends StatelessWidget {
  const MarketStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row('Market Status', 'OPEN', color: TradingTheme.bullish),
        _row('Regime', 'BULLISH', color: TradingTheme.accentCyan),
        _row('VIX Index', '14.2'),
      ],
    );
  }

  Widget _row(String l, String v, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: const TextStyle(
              color: TradingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            v,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveSignalsWidget extends StatelessWidget {
  final TradingState state;
  const LiveSignalsWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: state.signals
          .take(3)
          .map(
            (s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 14,
                    color: s.type.contains('BUY')
                        ? TradingTheme.bullish
                        : TradingTheme.bearish,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.symbol}: ${s.type}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          s.source,
                          style: const TextStyle(
                            fontSize: 10,
                            color: TradingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class SystemStatusWidget extends StatelessWidget {
  final TradingState state;
  const SystemStatusWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final runningCount = state.bots.where((b) => b.status == 'RUNNING').length;
    final totalCount = state.bots.length;
    final progress = totalCount > 0 ? runningCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Running Bots: $runningCount / $totalCount',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          color: TradingTheme.accentCyan,
          backgroundColor: TradingTheme.surfaceLight,
        ),
        const SizedBox(height: 8),
        const Text('Orders Today: 124', style: TextStyle(fontSize: 12)),
        const Text(
          'Active Tasks: MeanReversion Processor',
          style: TextStyle(fontSize: 10, color: TradingTheme.textSecondary),
        ),
      ],
    );
  }
}

class RiskAlertsWidget extends StatelessWidget {
  const RiskAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• High Slippage on ETH/USDT',
          style: TextStyle(fontSize: 11, color: TradingTheme.bearish),
        ),
        Text(
          '• Margin usage approaching 70%',
          style: TextStyle(fontSize: 11, color: Colors.orange),
        ),
      ],
    );
  }
}

class EmergencyKillButton extends StatelessWidget {
  final VoidCallback onPressed;
  const EmergencyKillButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: TradingTheme.bearish,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.close, color: Colors.white),
        label: const Text(
          'EMERGENCY KILL SWITCH',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DashboardActivePositions extends StatelessWidget {
  final TradingState state;
  const DashboardActivePositions({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Positions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text('Symbol', style: TextStyle(fontSize: 12)),
                ),
                DataColumn(label: Text('Side', style: TextStyle(fontSize: 12))),
                DataColumn(label: Text('Size', style: TextStyle(fontSize: 12))),
                DataColumn(
                  label: Text('Entry', style: TextStyle(fontSize: 12)),
                ),
                DataColumn(label: Text('PnL', style: TextStyle(fontSize: 12))),
              ],
              rows: state.positions
                  .map(
                    (p) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            p.symbol,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          StatusBadge(
                            label: p.side,
                            color: p.side == 'LONG'
                                ? TradingTheme.bullish
                                : TradingTheme.bearish,
                          ),
                        ),
                        DataCell(
                          Text(
                            p.size.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${p.entryPrice}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${p.pnl.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: p.pnl >= 0
                                  ? TradingTheme.bullish
                                  : TradingTheme.bearish,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardRecentOrders extends StatelessWidget {
  final TradingState state;
  const DashboardRecentOrders({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...state.orders
                .take(5)
                .map(
                  (o) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.symbol,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              o.timestamp.toIso8601String().substring(11, 16),
                              style: const TextStyle(
                                fontSize: 9,
                                color: TradingTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          o.side,
                          style: TextStyle(
                            fontSize: 10,
                            color: o.side == 'BUY'
                                ? TradingTheme.bullish
                                : TradingTheme.bearish,
                          ),
                        ),
                        StatusBadge(
                          label: o.status,
                          color: o.status == 'FILLED'
                              ? TradingTheme.bullish
                              : TradingTheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// 2. Markets View
class MarketsView extends StatelessWidget {
  final TradingState state;
  const MarketsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Global Markets Terminal',
      actions: [
        SizedBox(
          width: 200,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search asset...',
              prefixIcon: Icon(Icons.search, size: 16),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (v) => state.setSearchQuery(v),
          ),
        ),
      ],
      child: Card(
        child: ListView.separated(
          itemCount: state.tickers.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final t = state.tickers[index];
            if (state.searchQuery.isNotEmpty &&
                !t.symbol.toLowerCase().contains(
                  state.searchQuery.toLowerCase(),
                )) {
              return const SizedBox.shrink();
            }
            final isPos = t.change24h >= 0;
            return ListTile(
              title: Text(
                t.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Vol 24h: \$${(t.volume24h / 1000000000).toStringAsFixed(2)}B',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiniSparkline(
                    values: t.sparkline,
                    color: isPos ? TradingTheme.bullish : TradingTheme.bearish,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${t.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${isPos ? '+' : ''}${t.change24h}%',
                        style: TextStyle(
                          color: isPos
                              ? TradingTheme.bullish
                              : TradingTheme.bearish,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 3. Strategies View
class StrategiesView extends StatelessWidget {
  final TradingState state;
  const StrategiesView({super.key, required this.state});

  Color _statusColor(String status) {
    switch (status) {
      case 'PRODUCTION':
        return TradingTheme.accentCyan;
      case 'BETA':
        return TradingTheme.primary;
      case 'BACKTESTING':
        return TradingTheme.accentPurple;
      default:
        return TradingTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Algorithmic Strategies Core',
      actions: [
        TradingButton(
          label: 'Build New Strategy',
          icon: Icons.architecture,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StrategyBuilderScreen(state: state),
            ),
          ),
        ),
      ],
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
        ),
        itemCount: state.strategies.length,
        itemBuilder: (context, index) {
          final s = state.strategies[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(
                            label: s.status,
                            color: _statusColor(s.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${s.id} • ${s.version} • ${s.market} • ${s.timeframe} • ${s.instrument}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Win Rate',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            '${s.winRate}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sharpe Ratio',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            '${s.sharpeRatio}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Profit',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            '+\$${s.totalProfit.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: TradingTheme.bullish,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TradingTheme.textPrimary,
                          side: const BorderSide(color: TradingTheme.border),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StrategyBuilderScreen(
                              state: state,
                              existing: s,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TradingTheme.textPrimary,
                          side: const BorderSide(color: TradingTheme.border),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => state.duplicateStrategy(s),
                        icon: const Icon(Icons.copy_outlined, size: 14),
                        label: const Text('Duplicate'),
                      ),
                      const Spacer(),
                      Text(
                        '${s.entryConditions.length} entry rules',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 4. Bots View - Professional Fleet Management
class BotsView extends StatelessWidget {
  final TradingState state;
  const BotsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Bot Fleet Management',
      subtitle: 'Monitor and control your automated execution nodes',
      actions: [
        TradingButton(
          label: 'Deploy New Bot',
          icon: Icons.add,
          onPressed: () =>
              state.showToast('Deploying new bot infrastructure...'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: TradingTheme.bearish,
          ),
          onPressed: () => state.showToast('HALTING ALL BOTS'),
          child: const Text(
            'HALT ALL BOTS',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: state.bots.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final bot = state.bots[index];
                return BotCardWidget(bot: bot, state: state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        const FilterChip(
          label: Text('All Bots (5)'),
          selected: true,
          onSelected: null,
        ),
        const SizedBox(width: 8),
        const FilterChip(
          label: Text('Market: Crypto'),
          selected: false,
          onSelected: null,
        ),
        const SizedBox(width: 8),
        const FilterChip(
          label: Text('Status: Running'),
          selected: false,
          onSelected: null,
        ),
        const Spacer(),
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search Bots...',
              prefixIcon: Icon(Icons.search, size: 16),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class BotCardWidget extends StatelessWidget {
  final TradingBot bot;
  final TradingState state;
  const BotCardWidget({super.key, required this.bot, required this.state});

  @override
  Widget build(BuildContext context) {
    Color statusColor = TradingTheme.textSecondary;
    if (bot.status == 'RUNNING') statusColor = TradingTheme.bullish;
    if (bot.status == 'PAUSED') statusColor = TradingTheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bot.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusBadge(label: bot.status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bot.id} | Strategy: ${bot.strategyName} | Pair: ${bot.marketSymbol}',
                      style: const TextStyle(
                        color: TradingTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    bot.status == 'RUNNING' ? Icons.pause : Icons.play_arrow,
                    color: bot.status == 'RUNNING'
                        ? Colors.orange
                        : Colors.green,
                  ),
                  onPressed: () => state.toggleBotStatus(bot.id),
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: TradingTheme.bearish),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {},
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metric(
                  'Allocated Capital',
                  '\$${bot.allocation.toStringAsFixed(0)}',
                ),
                _metric(
                  'Today\'s P&L',
                  '+\$142.20',
                  color: TradingTheme.bullish,
                ),
                _metric(
                  'Net Profit',
                  '${bot.netProfit >= 0 ? '+' : ''}\$${bot.netProfit.toStringAsFixed(0)}',
                  color: bot.netProfit >= 0
                      ? TradingTheme.bullish
                      : TradingTheme.bearish,
                ),
                _metric('Win Rate', '64%'),
                _metric('Max Drawdown', '4.2%', color: TradingTheme.bearish),
                _metric('Uptime', bot.runtime),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _tag(Icons.speed, 'Trades Today: 12'),
                const SizedBox(width: 16),
                _tag(Icons.radar, 'Last Signal: BUY (88%)'),
                const Spacer(),
                const Text(
                  'Version v2.4.1',
                  style: TextStyle(
                    fontSize: 10,
                    color: TradingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String l, String v, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l,
          style: const TextStyle(
            fontSize: 10,
            color: TradingTheme.textSecondary,
          ),
        ),
        Text(
          v,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _tag(IconData i, String t) {
    return Row(
      children: [
        Icon(i, size: 12, color: TradingTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          t,
          style: const TextStyle(
            fontSize: 11,
            color: TradingTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// 5. Signals Terminal View
class SignalsView extends StatelessWidget {
  final TradingState state;
  const SignalsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Real-Time Signals Engine',
      child: Card(
        child: ListView.separated(
          itemCount: state.signals.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final sig = state.signals[index];
            final isBuy = sig.type.contains('BUY');
            return ListTile(
              leading: Icon(
                Icons.radar,
                color: isBuy ? TradingTheme.bullish : TradingTheme.bearish,
              ),
              title: Text(
                '${sig.symbol} - Entry Target: \$${sig.price}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Trigger Node: ${sig.source} | Confidence Quotient: ${(sig.strength * 100).toStringAsFixed(1)}%',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: sig.type,
                    color: isBuy ? TradingTheme.bullish : TradingTheme.bearish,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sig.timestamp.toIso8601String().substring(11, 19),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 6. Positions Grid View
class PositionsView extends StatelessWidget {
  final TradingState state;
  const PositionsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Open Paper Positions',
      child: Card(
        child: state.positions.isEmpty
            ? const Center(child: Text('No active inventory positions open.'))
            : ListView.separated(
                itemCount: state.positions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final pos = state.positions[index];
                  final isLong = pos.side == 'LONG';
                  return ListTile(
                    leading: StatusBadge(
                      label: '${pos.side} ${pos.leverage}x',
                      color: isLong
                          ? TradingTheme.bullish
                          : TradingTheme.bearish,
                    ),
                    title: Text(
                      pos.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Size: ${pos.size} units | Entry: \$${pos.entryPrice} | Mark: \$${pos.markPrice}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${pos.pnl.toStringAsFixed(2)} (${pos.pnlPercent}%)',
                          style: TextStyle(
                            color: pos.pnl >= 0
                                ? TradingTheme.bullish
                                : TradingTheme.bearish,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 24),
                        OutlinedButton(
                          onPressed: () => _showConfirmation(
                            context,
                            'Market Close Position',
                            'Execute immediate market clearance for ${pos.symbol}?',
                            () {
                              state.closePosition(pos.id);
                            },
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: TradingTheme.bearish),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// 7. Orders Terminal
class OrdersView extends StatelessWidget {
  final TradingState state;
  const OrdersView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Order Fulfillment Registry',
      actions: [
        TradingButton(
          label: state.isPaperEngineRunning
              ? 'Stop Paper Engine'
              : 'Start Paper Engine',
          onPressed: () => state.isPaperEngineRunning
              ? state.stopPaperEngine()
              : state.startPaperEngine(),
        ),
      ],
      child: Card(
        child: ListView.separated(
          itemCount: state.orders.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final order = state.orders[index];
            return ListTile(
              title: Text(
                '${order.side} ${order.type} - ${order.symbol}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Amount: ${order.amount} | Price: \$${order.price} | Time: ${order.timestamp.toIso8601String().substring(11, 19)}',
              ),
              leading: Icon(
                order.side == 'BUY' ? Icons.south_west : Icons.north_east,
                color: order.side == 'BUY'
                    ? TradingTheme.bullish
                    : TradingTheme.bearish,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(
                    label: order.status,
                    color: order.status == 'FILLED'
                        ? TradingTheme.bullish
                        : (order.status == 'PENDING'
                              ? TradingTheme.primary
                              : TradingTheme.textSecondary),
                  ),
                  if (order.status == 'PENDING') ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: TradingTheme.textSecondary,
                      ),
                      onPressed: () => state.cancelOrder(order.id),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 8. Portfolio Ledger View
class PortfolioView extends StatelessWidget {
  final TradingState state;
  const PortfolioView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Treasury & Asset Balance Allocation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Total Wallet Equity',
                  value: '\$267,606.70',
                  subtext: 'Collateralized asset valuation',
                  icon: Icons.pie_chart,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: 'Available Margin',
                  value: '\$95,000.00',
                  subtext: 'Free for next algorithmic strategy hooks',
                  icon: Icons.lock_open,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: state.assets.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final a = state.assets[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: TradingTheme.surfaceLight,
                      child: Text(
                        a.asset,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      a.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Total Balance: ${a.balance} | Available: ${a.available}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${a.valueUsd.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${a.allocationPercent}% weight',
                          style: const TextStyle(
                            color: TradingTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 9. Risk Matrix View - Advanced Risk Safeguard
class RiskView extends StatelessWidget {
  final TradingState state;
  const RiskView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Risk Control Center',
      subtitle: 'Pre-Execution Risk Firewall | Active Gatekeeper',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ListView(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    _riskLimitCard(
                      'Max Risk per Trade',
                      '0.8%',
                      '1.0%',
                      0.8,
                      Colors.green,
                    ),
                    _riskLimitCard(
                      'Max Daily Loss',
                      '\$1,200',
                      '\$2,000',
                      0.6,
                      Colors.green,
                    ),
                    _riskLimitCard(
                      'Max Weekly Loss',
                      '\$4,500',
                      '\$5,000',
                      0.9,
                      Colors.orange,
                    ),
                    _riskLimitCard(
                      'Max Drawdown',
                      '4.2%',
                      '5.0%',
                      0.84,
                      Colors.orange,
                    ),
                    _riskLimitCard(
                      'Max Leverage',
                      '3.4x',
                      '5.0x',
                      0.68,
                      Colors.green,
                    ),
                    _riskLimitCard(
                      'Sector Exposure (TECH)',
                      '28%',
                      '30%',
                      0.93,
                      Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  color: TradingTheme.primary.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const Icon(Icons.security, color: TradingTheme.primary),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Global Risk Safeguard Active',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Pre-execution engine is blocking all orders exceeding these limits.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: TradingTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Edit Risk Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: ListView(
              children: [
                SidebarCard(
                  title: 'Exposure Monitoring',
                  child: Column(
                    children: [
                      _monitoringRow('Total Exposure', '\$142,500'),
                      _monitoringRow('Margin Used', '22%'),
                      _monitoringRow('Daily VaR (99%)', '\$4,200'),
                      _monitoringRow('Beta vs SPY', '1.45'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SidebarCard(
                  title: 'Risk Alerts Log',
                  child: Column(
                    children: [
                      _alertItem('TECH Sector limit reached (93%)', Colors.red),
                      _alertItem(
                        'Weekly loss approaching threshold',
                        Colors.orange,
                      ),
                      _alertItem(
                        'High volatility detected in Crypto',
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                EmergencyKillButton(
                  onPressed: () => state.activateEmergencyStop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskLimitCard(
    String name,
    String cur,
    String lim,
    double prog,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    prog > 0.9 ? 'CRITICAL' : (prog > 0.8 ? 'WARNING' : 'SAFE'),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current: $cur', style: const TextStyle(fontSize: 12)),
                Text(
                  'Limit: $lim',
                  style: const TextStyle(
                    fontSize: 12,
                    color: TradingTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: prog,
              color: color,
              backgroundColor: TradingTheme.surfaceLight,
              minHeight: 6,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _monitoringRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: const TextStyle(
              color: TradingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(v, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _alertItem(String m, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.warning, size: 14, color: c),
          const SizedBox(width: 8),
          Expanded(child: Text(m, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }
}

// ... remaining views (Backtesting, etc.)
// 10. Backtesting Engine View
class BacktestingView extends StatelessWidget {
  final TradingState state;
  const BacktestingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Historical Sandbox Backtester',
      actions: [
        TradingButton(
          label: 'Execute Historic Run',
          icon: Icons.play_arrow,
          onPressed: () =>
              state.showToast('Backtest engine thread spawned successfully.'),
        ),
      ],
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: 'Alpha Mean Reversion',
                      decoration: const InputDecoration(
                        labelText: 'Strategy Model',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Alpha Mean Reversion',
                          child: Text('Alpha Mean Reversion'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: 'BTC/USDT',
                      decoration: const InputDecoration(
                        labelText: 'Target Ticker Pair',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'BTC/USDT',
                          child: Text('BTC/USDT'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: '30 Days',
                      decoration: const InputDecoration(
                        labelText: 'Backtest Window',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '30 Days',
                          child: Text('Last 30 Days'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: state.backtests.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final b = state.backtests[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.analytics,
                      color: TradingTheme.accentCyan,
                    ),
                    title: Text(
                      b.strategyName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Pair: ${b.symbol} | Frame: ${b.timeframe} | Total Trades: ${b.totalTrades}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Net Return: +${b.netReturnPercent}%',
                          style: const TextStyle(
                            color: TradingTheme.bullish,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Max DD: -${b.maxDrawdownPercent}% | Profit Factor: ${b.profitFactor}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 11. AI Research Lab View
class AiResearchLabView extends StatelessWidget {
  final TradingState state;
  const AiResearchLabView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'AI Advanced Research Lab',
      child: ListView(
        children: [
          const Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Transformer Precision',
                  value: '94.2%',
                  subtext: 'Directional bias matrix accuracy',
                  icon: Icons.memory,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: 'Feature Vector Dimension',
                  value: '1,024',
                  subtext: 'Real-time telemetry inputs mapped',
                  icon: Icons.hub,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: 'Sentiment Index Score',
                  value: '+0.68',
                  valueColor: TradingTheme.bullish,
                  subtext: 'Highly optimistic market stance',
                  icon: Icons.mood,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Active Neural Inference Pipeline Weights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Book Imbalance Ratio Weights (Inference Confidence: 87.5%)',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.875,
                    color: TradingTheme.accentCyan,
                    backgroundColor: TradingTheme.surfaceLight,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Macro Sentiment Analysis Correlation (Inference Confidence: 68.2%)',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.682,
                    color: TradingTheme.accentPurple,
                    backgroundColor: TradingTheme.surfaceLight,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Funding Rate Arbitrage Index (Inference Confidence: 91.4%)',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.914,
                    color: TradingTheme.bullish,
                    backgroundColor: TradingTheme.surfaceLight,
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 12. Options View
class OptionsView extends StatelessWidget {
  final TradingState state;
  const OptionsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Derivatives Options Chain',
      child: Card(
        child: ListView.separated(
          itemCount: state.optionsContracts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final opt = state.optionsContracts[index];
            final isCall = opt.type == 'CALL';
            return ListTile(
              leading: Icon(
                isCall ? Icons.arrow_upward : Icons.arrow_downward,
                color: isCall ? TradingTheme.bullish : TradingTheme.bearish,
              ),
              title: Text(
                opt.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Premium Cost: \$${opt.premium} | Delta: ${opt.delta} | Open Interest: ${opt.openInterest}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Strike: \$${opt.strikePrice}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TradingTheme.primary,
                    ),
                  ),
                  Text(
                    'IV: ${opt.impliedVolPercent}%',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 13. News & Events View
class NewsEventsView extends StatelessWidget {
  final TradingState state;
  const NewsEventsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Sentiment Macro Stream',
      child: ListView.separated(
        itemCount: state.news.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = state.news[index];
          Color sc = TradingTheme.textSecondary;
          if (n.sentiment == 'BULLISH') sc = TradingTheme.bullish;
          if (n.sentiment == 'BEARISH') sc = TradingTheme.bearish;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n.source.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      StatusBadge(label: n.sentiment, color: sc),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 14. Analytics View
class AnalyticsView extends StatelessWidget {
  final TradingState state;
  const AnalyticsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Advanced Core Performance Analytics',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: 'Profit Factor Index',
                  value: '1.92',
                  subtext: 'Gross gains vs gross losses ratio',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: 'Sortino Risk Multiplier',
                  value: '2.45',
                  subtext: 'Downside deviation benchmark ratio',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  title: 'Average Trade Duration',
                  value: '42 mins',
                  subtext: 'High-velocity automation profile',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Equity Growth Trajectory Placeholder Canvas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: TradingTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: TradingTheme.border),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stacked_line_chart,
                      size: 64,
                      color: TradingTheme.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'High-resolution Vector Chart rendering pipeline engine nominal.',
                      style: TextStyle(color: TradingTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 15. Logs View
class LogsView extends StatelessWidget {
  final TradingState state;
  const LogsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'System Execution Logs',
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: TradingTheme.border),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: state.logs.length,
          itemBuilder: (context, index) {
            final log = state.logs[index];
            Color logColor = Colors.white;
            if (log.type == 'ERROR') logColor = TradingTheme.bearish;
            if (log.type == 'WARNING') logColor = TradingTheme.primary;
            if (log.type == 'EXECUTION') logColor = TradingTheme.accentCyan;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '[${log.timestamp.toIso8601String().substring(11, 19)}] [${log.type}] [${log.source}]: ${log.message}',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: logColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 16. Broker View
class BrokerView extends StatelessWidget {
  final TradingState state;
  const BrokerView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Paper Execution Adapter',
      child: const Card(
        child: ListTile(
          leading: Icon(Icons.science_outlined, color: TradingTheme.primary),
          title: Text(
            'Local deterministic simulator',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'No broker is connected. No credentials are accepted. All fills are simulated locally with configured fees and slippage.',
          ),
          trailing: StatusBadge(
            label: 'PAPER ONLY',
            color: TradingTheme.primary,
          ),
        ),
      ),
    );
  }
}

// 17. Settings View
class SettingsView extends StatelessWidget {
  final TradingState state;
  const SettingsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ViewContainer(
      title: 'Global System Configurations',
      child: ListView(
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Dark Pro Fintech UI Mode'),
                  subtitle: const Text('High-contrast optimized layout grid'),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Maximum Order Leverage Threshold Cap'),
                  subtitle: Text(
                    'Safety engine auto-rejects risk parameters exceeding cap',
                  ),
                  trailing: Text(
                    '20x Max Cap',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Persistent Paper-Trading Emergency Stop'),
                  subtitle: const Text(
                    'Immediately blocks new simulated orders until explicitly reset',
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TradingTheme.bearish,
                    ),
                    onPressed: () => _showConfirmation(
                      context,
                      'Paper-Trading Emergency Stop',
                      'Block every new simulated order?',
                      () {
                        state.activateEmergencyStop();
                      },
                    ),
                    child: const Text(
                      'ARM TRIGGER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Global modal workflow confirmation helper
void _showConfirmation(
  BuildContext context,
  String title,
  String message,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: TradingTheme.textSecondary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TradingTheme.bearish,
            ),
            child: const Text(
              'Confirm Execution',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}
