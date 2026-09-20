import 'package:flutter/material.dart';
import '../theme/trading_theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData? icon;
  final Color? valueColor;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtext = '',
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 1),
                ),
                if (icon != null)
                  Icon(icon, size: 18, color: TradingTheme.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: valueColor ?? TradingTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtext.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subtext, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
