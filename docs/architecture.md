# Planned Trading Architecture

The Flutter application is currently a paper-trading prototype. The archived
native Android implementation is a conceptual reference only; it is not
suitable for live trading.

## Order flow and responsibilities

Strategies may produce trade signals and order requests, but they must not
route orders directly. Every order must pass through a central risk gate before
an execution component can accept it. This keeps three responsibilities
separate:

1. **Strategy:** turns market inputs into proposed orders.
2. **Risk:** validates every proposed order and either approves or rejects it.
3. **Execution:** routes only approved orders to the selected paper or broker
   adapter.

The risk gate is expected to enforce at least:

- a maximum value for each order;
- a daily-loss limit that prevents further orders once reached;
- a leverage limit; and
- an emergency stop that blocks new activity and coordinates cancellation or
  shutdown behavior across strategies and execution.

These controls must fail closed: an order that cannot be validated must not be
executed.

## Status of the archived Kotlin prototype

The Kotlin code demonstrates boundaries and control flow, not a production
trading system. Its risk values and current exposure values are hardcoded.
Its broker execution path only writes an Android log message, and its emergency
halt also only writes a log message; neither performs the stated external
action. It has no real broker integration and must not be used for live trading.

Future implementation should preserve the separation and mandatory risk gate
while replacing mocks with tested state management, durable audit records, and
explicit paper-trading adapters before any separately reviewed live-trading
work is considered.
