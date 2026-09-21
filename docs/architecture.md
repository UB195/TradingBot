# Paper-Trading Architecture

Phase 2 implements a local, deterministic paper-trading vertical slice in Dart.
Flutter remains the presentation layer. There is no live broker adapter, live
market-data client, credential storage or real-money execution path.

## Layers and data flow

```text
Presentation                  application/state
Flutter dashboard ──────────► TradingState / PaperTradingController
                                      │
                                      ▼
Domain                       PaperTradingEngine
Replay tick ─► MA strategy ─► central risk gate ─► simulated executor
                                      │                    │
                                      └── rejection        └── fill
                                                            │
                                                            ▼
                              account, positions, P&L, audit snapshot
                                                            │
                                                            ▼
Data                         TradingRepository interface
                              ├── SharedPreferences repository
                              └── in-memory deterministic test repository
```

The domain owns trading rules and has no Flutter dependency. Interfaces isolate
market data, persistence, time and order execution. A later phase can add other
implementations without allowing strategies or presentation code to bypass the
risk gate.

## Persistence

`SharedPreferencesTradingRepository` stores one versioned JSON snapshot using
Flutter's `shared_preferences` plugin. It was selected because the project
supports Android, iOS, web, macOS, Linux and Windows and the plugin supports all
of those targets without a server or platform-specific database schema.

The snapshot persists:

- Strategy Builder definitions and complete version history;
- the paper bot and moving-average configuration;
- cash, starting balance and realized P&L;
- filled and rejected orders, fills, open and closed positions;
- last prices and mark-to-market unrealized P&L inputs;
- risk settings;
- emergency-stop state, reason and activation time;
- engine audit events;
- replay strategy history and processed event/signal identifiers.

The repository interface makes storage replaceable. A whole-snapshot preference
is intentionally small and simple, but it is not transactional, append-only or
suited to a large tick/fill history. A future local database could implement the
same interface.

Engine-running state is always restored as stopped. This avoids silently
resuming work after launch. Emergency-stop state is restored exactly and is
never silently cleared.

## Domain model

- `MarketTick`: unique event ID, symbol, price and timestamp.
- `TradeSignal`: deterministic strategy/event identity, side and quantity.
- `PaperOrder`: filled or rejected order with the recorded rejection reason.
- `TradeFill`: execution price, quantity and fee.
- `PaperPosition`: signed quantity, average entry, mark, realized P&L and open or
  closed timestamps.
- `PaperAccount`: starting cash, current cash and realized P&L.
- `RiskSettings`: maximum position value, order value and total exposure.
- `EmergencyStopState`: persistent active flag, reason and activation time.
- `AuditEvent`: timestamped engine, fill, rejection, reset and emergency events.

## Strategy and idempotency

The initial strategy compares a short and long simple moving average. It emits a
buy only when the fast average crosses from at-or-below to above the slow
average, and a sell only on the opposite crossing. It does not order on every
tick.

Tick event IDs and signal IDs are persisted. Replaying an already processed tick
does not re-evaluate it, and an already processed signal/order is rejected as a
duplicate. Identical input ticks, configuration and starting snapshot produce
identical signals and calculations.

## Mandatory risk gate

Every order path calls `CentralRiskGate` before the simulator. It fails closed
for:

1. active emergency stop;
2. non-finite or non-positive quantity or price;
3. duplicate signal or order;
4. maximum order value;
5. insufficient paper cash for a buy including estimated fee and slippage;
6. maximum resulting position value; and
7. maximum resulting total absolute exposure.

Rejections create no fill or position mutation. The rejected order and exact
reason are persisted and displayed.

## Fill, cash and P&L formulas

For reference price `P`, quantity `Q`, fee rate `f` and slippage rate `s`:

```text
buy fill price  = P × (1 + s)
sell fill price = P × (1 - s)
fee             = |Q × fill price| × f
buy cash delta  = -(Q × fill price + fee)
sell cash delta = +(Q × fill price - fee)
```

Same-direction fills use quantity-weighted average entry price. A reduction
realizes:

```text
gross realized P&L = closing quantity × (fill price - entry price)
                     × sign(existing signed quantity)
realized delta      = gross realized P&L - fill fee
unrealized P&L      = (mark price - average entry) × signed quantity
equity              = cash + Σ(signed quantity × mark price)
```

A fill larger than the existing opposite position closes it and opens the
remainder in the new direction at the fill price. Closed position records are
retained.

## Emergency stop and reset

Activation cancels the replay subscription, marks the engine stopped, records
the reason and time, persists immediately and causes the risk gate to reject all
new orders. Only the explicit reset control clears it. Resetting the paper
account clears simulated trading history but preserves risk settings, strategy
definitions and an active emergency stop.

## Known limitations

The source is a short built-in replay and the execution model is immediate. The
prototype does not model partial fills, liquidity depth, latency, borrowing,
margin, interest, funding, taxes or exchange calendars. Dart `double` is used
rather than fixed-point decimal arithmetic. The UI retains some clearly
illustrative legacy research screens; they are not connected to a live service.
Strategy Builder definitions and versions are durable, but the Phase 2 engine
executes only the built-in moving-average crossover strategy.

Live trading is not implemented and must not be inferred from any interface
name. Adding a broker, external service, paid dependency, credentials or
real-money execution is outside Phase 2.
