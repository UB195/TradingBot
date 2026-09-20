import 'package:flutter/material.dart';
import '../models/strategy_builder_models.dart';
import '../services/mock_strategy_service.dart';
import '../state/trading_state.dart';
import '../theme/trading_theme.dart';
import '../components/custom_widgets.dart';

// Advanced no-code Strategy Builder: compose entry/exit logic from
// indicator conditions without writing any code. All data is mock.
class StrategyBuilderScreen extends StatefulWidget {
  final TradingState state;
  final StrategyConfig? existing; // null = create a brand new strategy

  const StrategyBuilderScreen({super.key, required this.state, this.existing});

  @override
  State<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends State<StrategyBuilderScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _versionCtrl;

  String _market = MockStrategyService.markets.first;
  String _instrument = MockStrategyService.instruments.first;
  String _timeframe = MockStrategyService.timeframes.first;
  String _status = MockStrategyService.statuses.first;

  List<StrategyCondition> _entryConditions = [];

  // Exit rules
  bool _targetOn = true;
  bool _stopLossOn = true;
  bool _trailingOn = false;
  bool _timeExitOn = false;
  bool _reversalOn = false;
  bool _eodOn = false;
  final _targetCtrl = TextEditingController(text: '2.0');
  final _stopLossCtrl = TextEditingController(text: '1.0');
  final _trailingCtrl = TextEditingController(text: '1.5');
  final _timeExitCtrl = TextEditingController(text: '60');
  String _reversalIndicator = 'RSI';

  // Advanced
  String _sizingMethod = MockStrategyService.sizingMethods[1];
  String _session = MockStrategyService.sessions.first;
  final _sizingValueCtrl = TextEditingController(text: '10.0');
  final _riskPerTradeCtrl = TextEditingController(text: '1.0');
  final _maxTradesCtrl = TextEditingController(text: '5');
  final _maxDailyLossCtrl = TextEditingController(text: '3.0');
  final _cooldownCtrl = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _idCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _versionCtrl = TextEditingController(text: 'v1.0');
    if (widget.existing != null) {
      _applyConfig(widget.existing!);
    } else {
      _idCtrl.text = widget.state.generateStrategyId();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _descCtrl.dispose();
    _versionCtrl.dispose();
    _targetCtrl.dispose();
    _stopLossCtrl.dispose();
    _trailingCtrl.dispose();
    _timeExitCtrl.dispose();
    _sizingValueCtrl.dispose();
    _riskPerTradeCtrl.dispose();
    _maxTradesCtrl.dispose();
    _maxDailyLossCtrl.dispose();
    _cooldownCtrl.dispose();
    super.dispose();
  }

  void _applyConfig(StrategyConfig c) {
    _nameCtrl.text = c.name;
    _idCtrl.text = c.id;
    _descCtrl.text = c.description;
    _versionCtrl.text = c.version;
    _market = c.market;
    _instrument = c.instrument;
    _timeframe = c.timeframe;
    _status = c.status;
    _entryConditions = c.entryConditions.map((x) => x.copyWith()).toList();

    final exit = c.exitRules;
    _targetOn = exit.targetEnabled;
    _stopLossOn = exit.stopLossEnabled;
    _trailingOn = exit.trailingEnabled;
    _timeExitOn = exit.timeExitEnabled;
    _reversalOn = exit.indicatorReversalEnabled;
    _eodOn = exit.eodExitEnabled;
    _targetCtrl.text = exit.targetPercent.toString();
    _stopLossCtrl.text = exit.stopLossPercent.toString();
    _trailingCtrl.text = exit.trailingPercent.toString();
    _timeExitCtrl.text = exit.timeExitBars.toString();
    _reversalIndicator = exit.reversalIndicator;

    final adv = c.advanced;
    _sizingMethod = adv.positionSizingMethod;
    _session = adv.tradingSession;
    _sizingValueCtrl.text = adv.positionSizingValue.toString();
    _riskPerTradeCtrl.text = adv.riskPerTradePercent.toString();
    _maxTradesCtrl.text = adv.maxTradesPerDay.toString();
    _maxDailyLossCtrl.text = adv.maxDailyLossPercent.toString();
    _cooldownCtrl.text = adv.cooldownMinutes.toString();
  }

  IndicatorDef _defFor(String name) {
    return MockStrategyService.indicators.firstWhere(
      (d) => d.name == name,
      orElse: () => MockStrategyService.indicators.first,
    );
  }

  // ---------------------------------------------------------------------
  // Entry condition mutation helpers
  // ---------------------------------------------------------------------

  void _updateCondition(
    int i,
    StrategyCondition Function(StrategyCondition) f,
  ) {
    setState(() {
      _entryConditions[i] = f(_entryConditions[i]);
    });
  }

  void _addCondition() {
    setState(() {
      _entryConditions.add(
        StrategyCondition(
          indicator: 'Price',
          comparator: '>',
          compareTo: 'VALUE',
          value: '',
          connector: _entryConditions.isEmpty ? 'FIRST' : 'AND',
        ),
      );
    });
  }

  void _removeCondition(int i) {
    setState(() {
      _entryConditions.removeAt(i);
      if (_entryConditions.isNotEmpty) {
        _entryConditions[0] = _entryConditions[0].copyWith(connector: 'FIRST');
      }
    });
  }

  void _loadExample() {
    setState(() {
      _entryConditions = MockStrategyService.exampleConditions
          .map((c) => c.copyWith())
          .toList();
      if (_nameCtrl.text.trim().isEmpty) {
        _nameCtrl.text = 'Momentum Breakout Prototype';
        _descCtrl.text =
            'Momentum continuation entry: strong RSI expansion above VWAP with volume confirmation in a bullish market regime.';
      }
    });
    widget.state.showToast('Example entry template loaded into the builder.');
  }

  void _onIndicatorChanged(int i, String name) {
    final def = _defFor(name);
    _updateCondition(i, (c) {
      return c.copyWith(
        indicator: name,
        period: def.periods?.first,
        comparator: def.comparators.first,
        compareTo: def.supportsIndicatorCompare ? c.compareTo : 'VALUE',
        value: def.valueOptions?.first ?? '',
      );
    });
  }

  String _entrySentence() {
    if (_entryConditions.isEmpty) {
      return 'No entry conditions defined yet. Add a condition or load the example template.';
    }
    final sb = StringBuffer('ENTER WHEN: ');
    for (int i = 0; i < _entryConditions.length; i++) {
      final c = _entryConditions[i];
      if (i > 0) sb.write(' ${c.connector} ');
      sb.write(c.describe());
    }
    return sb.toString();
  }

  // ---------------------------------------------------------------------
  // Save / Duplicate / Version History
  // ---------------------------------------------------------------------

  StrategyConfig _buildConfig() {
    return StrategyConfig(
      id: _idCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      market: _market,
      instrument: _instrument,
      timeframe: _timeframe,
      version: _versionCtrl.text.trim().isEmpty
          ? 'v1.0'
          : _versionCtrl.text.trim(),
      status: _status,
      type: widget.existing?.type ?? 'Rule-Based',
      winRate: widget.existing?.winRate ?? 0.0,
      totalProfit: widget.existing?.totalProfit ?? 0.0,
      sharpeRatio: widget.existing?.sharpeRatio ?? 0.0,
      entryConditions: List.of(_entryConditions),
      exitRules: ExitRuleConfig(
        targetEnabled: _targetOn,
        targetPercent: double.tryParse(_targetCtrl.text) ?? 0.0,
        stopLossEnabled: _stopLossOn,
        stopLossPercent: double.tryParse(_stopLossCtrl.text) ?? 0.0,
        trailingEnabled: _trailingOn,
        trailingPercent: double.tryParse(_trailingCtrl.text) ?? 0.0,
        timeExitEnabled: _timeExitOn,
        timeExitBars: int.tryParse(_timeExitCtrl.text) ?? 0,
        indicatorReversalEnabled: _reversalOn,
        reversalIndicator: _reversalIndicator,
        eodExitEnabled: _eodOn,
      ),
      advanced: AdvancedRiskConfig(
        positionSizingMethod: _sizingMethod,
        positionSizingValue: double.tryParse(_sizingValueCtrl.text) ?? 0.0,
        riskPerTradePercent: double.tryParse(_riskPerTradeCtrl.text) ?? 0.0,
        maxTradesPerDay: int.tryParse(_maxTradesCtrl.text) ?? 0,
        maxDailyLossPercent: double.tryParse(_maxDailyLossCtrl.text) ?? 0.0,
        tradingSession: _session,
        cooldownMinutes: int.tryParse(_cooldownCtrl.text) ?? 0,
      ),
      lastModified: DateTime.now(),
    );
  }

  String _bumpVersion(String current) {
    final segments = current.replaceAll(RegExp(r'[^0-9.]'), '').split('.');
    if (segments.isEmpty || segments.last.isEmpty) return 'v1.1';
    final last = int.tryParse(segments.last) ?? 0;
    segments[segments.length - 1] = '${last + 1}';
    return 'v${segments.join('.')}';
  }

  void _saveStrategy() {
    if (_nameCtrl.text.trim().isEmpty) {
      widget.state.showToast('Strategy name is required before saving.');
      return;
    }
    if (_entryConditions.isEmpty) {
      widget.state.showToast(
        'At least one entry condition is required before saving.',
      );
      return;
    }
    var config = _buildConfig();
    if (widget.existing != null && config.version == widget.existing!.version) {
      // Auto-bump the patch version when the user did not change it manually.
      config = config.copyWith(version: _bumpVersion(config.version));
      _versionCtrl.text = config.version;
    }
    if (widget.existing == null) {
      widget.state.saveNewStrategy(config);
    } else {
      widget.state.updateStrategy(
        config,
        'Entry/exit logic and risk parameters revised in Strategy Builder.',
      );
    }
    Navigator.of(context).pop();
  }

  void _duplicateStrategy() {
    final config = _buildConfig();
    widget.state.duplicateStrategy(config);
  }

  void _showVersionHistory() {
    final history = widget.state.versionHistory[_idCtrl.text.trim()] ?? [];
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: TradingTheme.surface,
          title: Text(
            'Version History — ${_nameCtrl.text.isEmpty ? _idCtrl.text : _nameCtrl.text}',
          ),
          content: SizedBox(
            width: 520,
            height: 380,
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'No saved versions yet.\nSave the strategy to start tracking its history.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TradingTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final v = history[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: StatusBadge(
                          label: v.version,
                          color: TradingTheme.accentCyan,
                        ),
                        title: Text(v.changeNote),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(_fmtDate(v.timestamp)),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            _applyConfig(v.snapshot);
                            setState(() {});
                            Navigator.pop(dialogContext);
                            widget.state.showToast(
                              'Snapshot ${v.version} restored into the builder.',
                            );
                          },
                          child: const Text('Restore'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(color: TradingTheme.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  // ---------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------

  Widget _sectionCard(String title, IconData icon, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: TradingTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                decoration: _fieldDecoration(
                  'Strategy Name',
                  hint: 'e.g. Momentum Breakout V2',
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: TextField(
                controller: _idCtrl,
                readOnly: true,
                decoration: _fieldDecoration('Strategy ID'),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _versionCtrl,
                decoration: _fieldDecoration('Version', hint: 'v1.0'),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: MockStrategyService.statuses.contains(_status)
                    ? _status
                    : MockStrategyService.statuses.first,
                decoration: _fieldDecoration('Status'),
                items: MockStrategyService.statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          maxLines: 3,
          decoration: _fieldDecoration(
            'Description',
            hint: 'What market behavior does this strategy exploit?',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _market,
                decoration: _fieldDecoration('Market'),
                items: MockStrategyService.markets
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _market = v ?? _market),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _instrument,
                decoration: _fieldDecoration('Instrument'),
                items: MockStrategyService.instruments
                    .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _instrument = v ?? _instrument),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 140,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _timeframe,
                decoration: _fieldDecoration('Timeframe'),
                items: MockStrategyService.timeframes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _timeframe = v ?? _timeframe),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionRow(int i) {
    final c = _entryConditions[i];
    final def = _defFor(c.indicator);
    final isFirst = i == 0;
    final showValue = c.needsValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst)
            SizedBox(
              width: 90,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: c.connector,
                decoration: _fieldDecoration('Logic'),
                items: ['AND', 'OR']
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => _updateCondition(
                  i,
                  (x) => x.copyWith(connector: v ?? 'AND'),
                ),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Tooltip(
              message: 'Negate this condition',
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                ),
                child: DropdownButton<String>(
                  value: c.not ? 'NOT' : '—',
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: const [
                    DropdownMenuItem(value: '—', child: Text('—')),
                    DropdownMenuItem(
                      value: 'NOT',
                      child: Text(
                        'NOT',
                        style: TextStyle(
                          color: TradingTheme.accentPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      _updateCondition(i, (x) => x.copyWith(not: v == 'NOT')),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 190,
            child: Tooltip(
              message: def.hint,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: c.indicator,
                decoration: _fieldDecoration('Indicator'),
                items: MockStrategyService.indicators
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.name,
                        child: Text('${d.name} · ${d.category}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) _onIndicatorChanged(i, v);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (def.periods != null) ...[
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: def.periods!.contains(c.period)
                    ? c.period
                    : def.periods!.first,
                decoration: _fieldDecoration('Period'),
                items: def.periods!
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) =>
                    _updateCondition(i, (x) => x.copyWith(period: v)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: def.comparators.contains(c.comparator)
                  ? c.comparator
                  : def.comparators.first,
              decoration: _fieldDecoration('Comparator'),
              items: def.comparators
                  .map((cmp) => DropdownMenuItem(value: cmp, child: Text(cmp)))
                  .toList(),
              onChanged: (v) => _updateCondition(
                i,
                (x) => x.copyWith(comparator: v ?? x.comparator),
              ),
            ),
          ),
          if (showValue) ...[
            const SizedBox(width: 12),
            if (def.supportsIndicatorCompare) ...[
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: def.valueOptions != null
                      ? 'VALUE'
                      : c.compareTo,
                  decoration: _fieldDecoration('Compare To'),
                  items: const [
                    DropdownMenuItem(value: 'VALUE', child: Text('Value')),
                    DropdownMenuItem(
                      value: 'INDICATOR',
                      child: Text('Indicator'),
                    ),
                  ],
                  onChanged: (v) => _updateCondition(
                    i,
                    (x) => x.copyWith(
                      compareTo: v ?? 'VALUE',
                      value: def.valueOptions?.first ?? '',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (def.supportsIndicatorCompare && c.compareTo == 'INDICATOR')
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue:
                      MockStrategyService.indicators.any(
                        (d) => d.name == c.value,
                      )
                      ? c.value
                      : MockStrategyService.indicators.first.name,
                  decoration: _fieldDecoration('Against'),
                  items: MockStrategyService.indicators
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.name,
                          child: Text(d.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => _updateCondition(
                    i,
                    (x) => x.copyWith(value: v ?? x.value),
                  ),
                ),
              )
            else if (def.valueOptions != null)
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: def.valueOptions!.contains(c.value)
                      ? c.value
                      : def.valueOptions!.first,
                  decoration: _fieldDecoration('Value'),
                  items: def.valueOptions!
                      .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                      .toList(),
                  onChanged: (v) => _updateCondition(
                    i,
                    (x) => x.copyWith(value: v ?? x.value),
                  ),
                ),
              )
            else
              SizedBox(
                width: 200,
                child: TextFormField(
                  key: ValueKey('cond-value-$i-${c.indicator}-${c.compareTo}'),
                  initialValue: c.value,
                  decoration: _fieldDecoration(
                    'Value',
                    hint: c.indicator == 'Volume'
                        ? 'e.g. 1.5 × Average Volume'
                        : 'e.g. 60',
                  ),
                  onChanged: (v) => _entryConditions[i] = _entryConditions[i]
                      .copyWith(value: v),
                ),
              ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: TradingTheme.bearish),
            tooltip: 'Remove condition',
            onPressed: () => _removeCondition(i),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_entryConditions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TradingTheme.border),
              color: TradingTheme.background,
            ),
            child: const Column(
              children: [
                Icon(Icons.rule, size: 40, color: TradingTheme.textSecondary),
                SizedBox(height: 12),
                Text(
                  'No entry conditions yet.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Combine indicators with AND / OR / NOT logic — no code required.',
                  style: TextStyle(
                    color: TradingTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            _entryConditions.length,
            (i) => _buildConditionRow(i),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: TradingTheme.textPrimary,
                side: const BorderSide(color: TradingTheme.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onPressed: _addCondition,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Condition'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: TradingTheme.accentCyan,
                side: const BorderSide(color: TradingTheme.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onPressed: _loadExample,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Load Example Template'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: TradingTheme.border),
          ),
          child: Text(
            _entrySentence(),
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 13,
              color: TradingTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _exitTile({
    required bool enabled,
    required String title,
    required String subtitle,
    required IconData icon,
    required ValueChanged<bool> onToggle,
    Widget? field,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(
        icon,
        color: enabled ? TradingTheme.primary : TradingTheme.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enabled && field != null) ...[field, const SizedBox(width: 16)],
          Switch(
            value: enabled,
            activeThumbColor: TradingTheme.primary,
            onChanged: (v) => setState(() => onToggle(v)),
          ),
        ],
      ),
    );
  }

  Widget _pctField(TextEditingController ctrl, String label) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: ctrl,
        decoration: _fieldDecoration(label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _buildExitSection() {
    return Card(
      color: TradingTheme.background,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          _exitTile(
            enabled: _targetOn,
            title: 'Profit Target',
            subtitle:
                'Close the position when unrealized gain reaches the target',
            icon: Icons.flag,
            onToggle: (v) => _targetOn = v,
            field: _pctField(_targetCtrl, 'Target %'),
          ),
          const Divider(height: 1),
          _exitTile(
            enabled: _stopLossOn,
            title: 'Stop Loss',
            subtitle: 'Hard protective stop when loss threshold is breached',
            icon: Icons.shield,
            onToggle: (v) => _stopLossOn = v,
            field: _pctField(_stopLossCtrl, 'Stop %'),
          ),
          const Divider(height: 1),
          _exitTile(
            enabled: _trailingOn,
            title: 'Trailing Stop',
            subtitle:
                'Stop follows the price, locking in gains as the trend extends',
            icon: Icons.moving,
            onToggle: (v) => _trailingOn = v,
            field: _pctField(_trailingCtrl, 'Trail %'),
          ),
          const Divider(height: 1),
          _exitTile(
            enabled: _timeExitOn,
            title: 'Time-Based Exit',
            subtitle: 'Flatten the position after N bars regardless of PnL',
            icon: Icons.timer,
            onToggle: (v) => _timeExitOn = v,
            field: SizedBox(
              width: 180,
              child: TextField(
                controller: _timeExitCtrl,
                decoration: _fieldDecoration('Bars'),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          const Divider(height: 1),
          _exitTile(
            enabled: _reversalOn,
            title: 'Indicator Reversal Exit',
            subtitle:
                'Exit when a chosen indicator reverses against the position',
            icon: Icons.swap_vert,
            onToggle: (v) => _reversalOn = v,
            field: SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _reversalIndicator,
                decoration: _fieldDecoration('Indicator'),
                items: MockStrategyService.indicators
                    .map(
                      (d) =>
                          DropdownMenuItem(value: d.name, child: Text(d.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(
                  () => _reversalIndicator = v ?? _reversalIndicator,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _exitTile(
            enabled: _eodOn,
            title: 'End-of-Day Exit',
            subtitle: 'Square off all exposure before the session close',
            icon: Icons.bedtime,
            onToggle: (v) => _eodOn = v,
          ),
        ],
      ),
    );
  }

  Widget _advancedRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget field,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: TradingTheme.accentCyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TradingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 240, child: field),
        ],
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      children: [
        _advancedRow(
          title: 'Position Sizing',
          subtitle: 'How much capital each new trade is allocated',
          icon: Icons.crop_square,
          field: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _sizingMethod,
                  decoration: _fieldDecoration('Method'),
                  items: MockStrategyService.sizingMethods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _sizingMethod = v ?? _sizingMethod),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _sizingValueCtrl,
                  decoration: _fieldDecoration('Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        _advancedRow(
          title: 'Risk Per Trade',
          subtitle: 'Maximum percent of equity risked on a single trade',
          icon: Icons.local_fire_department,
          field: TextField(
            controller: _riskPerTradeCtrl,
            decoration: _fieldDecoration('% of Equity'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        _advancedRow(
          title: 'Maximum Trades',
          subtitle: 'Hard cap on executed trades per day',
          icon: Icons.repeat,
          field: TextField(
            controller: _maxTradesCtrl,
            decoration: _fieldDecoration('Trades / Day'),
            keyboardType: TextInputType.number,
          ),
        ),
        _advancedRow(
          title: 'Maximum Daily Loss',
          subtitle: 'Kill-switch threshold; halts the strategy when reached',
          icon: Icons.block,
          field: TextField(
            controller: _maxDailyLossCtrl,
            decoration: _fieldDecoration('% Daily Loss'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        _advancedRow(
          title: 'Trading Session',
          subtitle: 'Window during which new entries are permitted',
          icon: Icons.schedule,
          field: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _session,
            decoration: _fieldDecoration('Session'),
            items: MockStrategyService.sessions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _session = v ?? _session),
          ),
        ),
        _advancedRow(
          title: 'Cooldown Period',
          subtitle: 'Minutes to wait after an exit before re-entering',
          icon: Icons.hourglass_empty,
          field: TextField(
            controller: _cooldownCtrl,
            decoration: _fieldDecoration('Minutes'),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      backgroundColor: TradingTheme.background,
      appBar: AppBar(
        backgroundColor: TradingTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.architecture,
              color: TradingTheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEditing
                    ? 'Strategy Builder — ${widget.existing!.name}'
                    : 'Strategy Builder — New Strategy',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: TradingTheme.accentCyan,
            ),
            onPressed: _showVersionHistory,
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Version History'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: TradingTheme.textPrimary,
            ),
            onPressed: _duplicateStrategy,
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Duplicate Strategy'),
          ),
          const SizedBox(width: 16),
          TradingButton(
            label: isEditing ? 'Save Changes' : 'Save Strategy',
            icon: Icons.save,
            onPressed: _saveStrategy,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionCard(
            'Strategy Information',
            Icons.info_outline,
            _buildInfoSection(),
          ),
          const SizedBox(height: 16),
          _sectionCard('Entry Rules', Icons.rule, _buildEntrySection()),
          const SizedBox(height: 16),
          _sectionCard('Exit Rules', Icons.logout, _buildExitSection()),
          const SizedBox(height: 16),
          _sectionCard(
            'Advanced Risk Management',
            Icons.tune,
            _buildAdvancedSection(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
