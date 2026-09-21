# TradingBot — Paper Trading

TradingBot is a cross-platform Flutter paper-trading application. Phase 2 adds
a deterministic, persistent simulation pipeline:

```text
replay ticks → moving-average strategy → central risk gate → simulated fill
             → positions, cash, equity and P&L → local persistence → dashboard
```

This project does not connect to a broker, accept API credentials, consume live
market data, or place real orders. Every displayed order and fill is simulated.

## Features

- timestamped, replayable BTC/USDT sample ticks;
- moving-average crossover signals that occur only on crossings;
- mandatory pre-order risk validation;
- configurable fees and directional slippage;
- long and short position opening, increasing, reducing, closing and reversal;
- paper cash, equity, realized P&L and mark-to-market unrealized P&L;
- persistent orders, fills, positions, risk settings, strategies and audit log;
- persistent emergency stop with an explicit reset action;
- duplicate market-event and signal protection; and
- start, stop and confirmed reset controls in the Paper Trading dashboard.

## Supported platforms

Flutter runners are retained for Android, iOS, web, macOS, Linux and Windows.
The host still needs the platform's normal Flutter toolchain. The local snapshot
store uses Flutter's `shared_preferences` plugin, which has implementations for
all six targets.

## Project structure

- `lib/domain/` — models, ports, moving-average strategy, risk gate and fill math
- `lib/application/` — paper engine and Flutter-facing controller
- `lib/data/` — replay data, strategy mapping and persistence adapters
- `lib/state/` — application state and legacy-view projections
- `lib/views/` — dashboard, Strategy Builder and supporting screens
- `test/` — deterministic domain, persistence, state and widget tests
- `docs/architecture.md` — architecture, formulas and design trade-offs

The deleted native Android prototype remains only on
`archive/native-android-before-flutter-cleanup` and is not part of this branch.

## Setup and run

Install Flutter and the toolchain for the desired target, then run:

```sh
flutter pub get
flutter doctor
flutter devices
flutter run -d <device-id>
```

Open the dashboard and select **Start Paper Engine**. The bundled replay runs
at a fixed cadence and stops when its deterministic ticks are exhausted. Use
**Reset Paper Account** (with confirmation) to clear simulated trading history
and replay progress. Strategy definitions and an active emergency stop are
deliberately preserved by an account reset.

## Quality checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Tests require no network, broker account, market-data service or credentials.

## Risk controls

Every signal passes through one central gate before a simulated fill. The gate
rejects invalid quantities or prices, duplicate signals/orders, an active
emergency stop, insufficient paper cash, excessive order value, excessive
position value and excessive total exposure. Rejected orders and reasons are
stored and shown on the dashboard.

The emergency stop immediately stops the replay, blocks every new order,
records its reason and timestamp, and persists across restarts. Launching the
application never clears it; only **Reset Emergency Stop** does so, and reset
does not restart the engine.

## Limitations and safety

- Prices and timestamps come from a small bundled replay, not a live feed.
- Market orders fill immediately; there is no order book, partial fill, latency,
  corporate-action, funding, margin or exchange-calendar model.
- Amounts use Dart `double`, which is adequate for this prototype but not for a
  production financial ledger.
- Persistence is a single local JSON snapshot and is not an append-only,
  transactional or multi-process database.
- Legacy research, news, options and backtest screens still contain illustrative
  sample content; only the paper-trading pipeline and connected dashboard state
  are operational.
- Strategy Builder definitions and versions are persisted, but Phase 2 executes
  only the built-in moving-average crossover strategy.

Never use this project for real-money trading. Live trading is not implemented.
