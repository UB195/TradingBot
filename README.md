# Trading Bot

Trading Bot is a cross-platform Flutter paper-trading prototype. It presents a
trading dashboard, mock strategies, simulated positions and orders, risk views,
and backtesting-style sample data.

No real broker is connected. Market data, account values, strategy results,
orders, fills, and trading actions are simulated in local application state.
Nothing in this repository should be used to place or manage live trades.

## Supported platforms

The repository contains Flutter runners for:

- Android
- iOS
- Web
- macOS
- Linux
- Windows

Platform availability at runtime depends on the host operating system and its
installed toolchains. For example, iOS and macOS builds require macOS and
Xcode, while Windows desktop builds require Windows and Visual Studio.

## Project structure

- `lib/` — application UI, models, mock services, state, and theme
- `test/` — Flutter widget and application tests
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/` — Flutter platform
  runners
- `docs/architecture.md` — planned separation of strategy, risk, and execution
- `pubspec.yaml` — Dart and Flutter dependencies and project metadata

The previous root-level native Android/Jetpack Compose prototype has been
archived in the `archive/native-android-before-flutter-cleanup` Git branch and
is not part of the active application.

## Setup and run

Install a current Flutter SDK and the toolchain for the platform you want to
run. Then, from the repository root:

```sh
flutter doctor
flutter pub get
flutter devices
flutter run -d <device-id>
```

Common examples include `flutter run -d chrome` for web and
`flutter run -d macos` on a configured Mac. Use an ID reported by
`flutter devices` for other targets.

## Formatting, analysis, and tests

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Run `dart format lib test` to apply formatting changes.

## Safety limitations

- There is no broker connection or live order route.
- Displayed market, portfolio, profit-and-loss, risk, and execution data is
  mock data and may not reflect real market behavior.
- UI controls that appear to place, cancel, pause, or stop trading only mutate
  simulated local state.
- Risk limits and emergency controls shown by the prototype are not operational
  safeguards for real capital.
- The project has not been validated for production availability, security,
  regulatory compliance, or financial decision-making.

Do not provide API credentials or use this prototype for live trading.

## Planned architecture

Future paper-trading work should keep strategy generation, centralized risk
validation, and order execution as separate responsibilities. Every proposed
order must pass a fail-closed risk gate that enforces maximum order value,
daily-loss, leverage, and emergency-stop controls before execution. See
[`docs/architecture.md`](docs/architecture.md) for the preserved design notes
and the limitations of the archived Kotlin concept.
