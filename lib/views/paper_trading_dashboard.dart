import 'package:flutter/material.dart';

import '../components/custom_widgets.dart';
import '../components/kpi_card.dart';
import '../domain/paper_trading_models.dart';
import '../state/trading_state.dart';
import '../theme/trading_theme.dart';

class PaperTradingDashboardView extends StatelessWidget {
  final TradingState state;

  const PaperTradingDashboardView({super.key, required this.state});

  String _money(double value) =>
      '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final snapshot = state.paperSnapshot;
    final emergency = snapshot.emergencyStop;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paper Trading Command Center',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SIMULATED ONLY • No broker connected • ${snapshot.bot.strategyName}',
                      style: const TextStyle(
                        color: TradingTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: state.isPaperEngineRunning
                    ? 'ENGINE RUNNING'
                    : 'ENGINE STOPPED',
                color: state.isPaperEngineRunning
                    ? TradingTheme.bullish
                    : TradingTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              StatusBadge(
                label: emergency.active
                    ? 'EMERGENCY STOP ACTIVE'
                    : 'RISK GATE READY',
                color: emergency.active
                    ? TradingTheme.bearish
                    : TradingTheme.accentCyan,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TradingButton(
                label: 'Start Paper Engine',
                icon: Icons.play_arrow,
                onPressed: () => state.startPaperEngine(),
              ),
              OutlinedButton.icon(
                onPressed: () => state.stopPaperEngine(),
                icon: const Icon(Icons.stop),
                label: const Text('Stop Engine'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradingTheme.bearish,
                ),
                onPressed: emergency.active
                    ? null
                    : () => _confirm(
                        context,
                        title: 'Activate emergency stop?',
                        message:
                            'This immediately blocks every new simulated order and persists across restarts.',
                        confirmLabel: 'Activate stop',
                        action: () => state.activateEmergencyStop(),
                      ),
                icon: const Icon(Icons.emergency, color: Colors.white),
                label: const Text(
                  'Emergency Stop',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (emergency.active)
                OutlinedButton.icon(
                  onPressed: () => _confirm(
                    context,
                    title: 'Reset emergency stop?',
                    message:
                        'Resetting only unlocks the risk gate. It does not start the paper engine.',
                    confirmLabel: 'Reset stop',
                    action: () => state.resetEmergencyStop(),
                  ),
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Reset Emergency Stop'),
                ),
              OutlinedButton.icon(
                onPressed: () => _confirm(
                  context,
                  title: 'Reset paper account?',
                  message:
                      'This clears simulated orders, fills, positions, P&L, and replay progress. Strategy definitions and an active emergency stop are preserved.',
                  confirmLabel: 'Reset paper account',
                  action: () => state.resetPaperAccount(),
                ),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset Paper Account'),
              ),
            ],
          ),
          if (emergency.active) ...[
            const SizedBox(height: 12),
            Text(
              'Emergency stop activated ${emergency.activatedAt?.toLocal().toIso8601String() ?? ''}: ${emergency.reason}',
              style: const TextStyle(color: TradingTheme.bearish),
            ),
          ],
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: [
              KpiCard(title: 'Paper Cash', value: _money(state.paperCash)),
              KpiCard(title: 'Total Equity', value: _money(state.paperEquity)),
              KpiCard(
                title: 'Realized P&L',
                value: _money(state.realizedPnl),
                valueColor: state.realizedPnl >= 0
                    ? TradingTheme.bullish
                    : TradingTheme.bearish,
              ),
              KpiCard(
                title: 'Unrealized P&L',
                value: _money(state.unrealizedPnl),
                valueColor: state.unrealizedPnl >= 0
                    ? TradingTheme.bullish
                    : TradingTheme.bearish,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _positions(snapshot)),
                const SizedBox(width: 12),
                Expanded(child: _orders(snapshot)),
                const SizedBox(width: 12),
                Expanded(child: _rejections(snapshot)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _positions(TradingSnapshot snapshot) => _panel(
    'Open Positions',
    snapshot.openPositions.isEmpty
        ? const [Text('No open paper positions.')]
        : snapshot.openPositions
              .map(
                (position) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${position.symbol} • ${position.quantity >= 0 ? 'LONG' : 'SHORT'} ${position.quantity.abs()}',
                  ),
                  subtitle: Text(
                    'Entry ${position.averageEntryPrice.toStringAsFixed(4)} • Mark ${position.markPrice.toStringAsFixed(4)}',
                  ),
                  trailing: Text(_money(position.unrealizedPnl)),
                ),
              )
              .toList(),
  );

  Widget _orders(TradingSnapshot snapshot) => _panel(
    'Recent Simulated Orders',
    snapshot.orders.isEmpty
        ? const [Text('Start the replay to generate paper orders.')]
        : snapshot.orders
              .take(8)
              .map(
                (order) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${order.side.name.toUpperCase()} ${order.quantity} ${order.symbol}',
                  ),
                  subtitle: Text(order.createdAt.toLocal().toIso8601String()),
                  trailing: StatusBadge(
                    label: order.status.name.toUpperCase(),
                    color: order.status == PaperOrderStatus.filled
                        ? TradingTheme.bullish
                        : TradingTheme.bearish,
                  ),
                ),
              )
              .toList(),
  );

  Widget _rejections(TradingSnapshot snapshot) {
    final rejected = snapshot.orders
        .where((order) => order.status == PaperOrderStatus.rejected)
        .take(8)
        .toList();
    return _panel(
      'Risk Rejections',
      rejected.isEmpty
          ? const [Text('No rejected paper orders.')]
          : rejected
                .map(
                  (order) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${order.side.name.toUpperCase()} ${order.symbol}',
                    ),
                    subtitle: Text(order.rejectionReason ?? 'Rejected'),
                  ),
                )
                .toList(),
    );
  }

  Widget _panel(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    ),
  );

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }
}
