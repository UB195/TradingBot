import 'package:flutter/material.dart';
import '../theme/trading_theme.dart';

class SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<String> sections;

  const SideNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.sections,
  });

  IconData _getIcon(String section) {
    switch (section) {
      case 'Dashboard': return Icons.dashboard_outlined;
      case 'Markets': return Icons.show_chart;
      case 'Strategies': return Icons.psychology_outlined;
      case 'Bots': return Icons.smart_toy_outlined;
      case 'Signals': return Icons.sensors_outlined;
      case 'Positions': return Icons.account_balance_wallet_outlined;
      case 'Orders': return Icons.receipt_long_outlined;
      case 'Portfolio': return Icons.pie_chart_outline;
      case 'Risk': return Icons.gpp_maybe_outlined;
      case 'Backtesting': return Icons.history_outlined;
      case 'AI Research Lab': return Icons.science_outlined;
      case 'Options': return Icons.layers_outlined;
      case 'News & Events': return Icons.newspaper_outlined;
      case 'Analytics': return Icons.analytics_outlined;
      case 'Logs': return Icons.terminal_outlined;
      case 'Broker': return Icons.account_tree_outlined;
      case 'Settings': return Icons.settings_outlined;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: TradingTheme.surface,
        border: Border(right: BorderSide(color: TradingTheme.border)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.auto_graph, color: TradingTheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'TRADINGBOT',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 2,
                      color: TradingTheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final isSelected = selectedIndex == index;
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    leading: Icon(
                      _getIcon(section),
                      color: isSelected ? TradingTheme.primary : TradingTheme.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      section,
                      style: TextStyle(
                        color: isSelected ? TradingTheme.textPrimary : TradingTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => onDestinationSelected(index),
                    selected: isSelected,
                    selectedTileColor: TradingTheme.primary.withOpacity(0.08),
                    hoverColor: TradingTheme.surfaceLight,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              radius: 12,
              backgroundColor: TradingTheme.surfaceLight,
              child: Icon(Icons.person, size: 16, color: TradingTheme.textSecondary),
            ),
            title: const Text('Dev User', style: TextStyle(fontSize: 13)),
            subtitle: const Text('Pro Account', style: TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.more_vert, size: 18),
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
