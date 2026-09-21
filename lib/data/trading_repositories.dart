import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/paper_trading_models.dart';
import '../domain/paper_trading_ports.dart';

class InMemoryTradingStore {
  String? encoded;
}

class InMemoryTradingRepository implements TradingRepository {
  final InMemoryTradingStore store;

  InMemoryTradingRepository([
    TradingSnapshot? initial,
    InMemoryTradingStore? store,
  ]) : store = store ?? InMemoryTradingStore() {
    if (initial != null) {
      this.store.encoded = jsonEncode(initial.toJson());
    }
  }

  @override
  Future<void> clear() async => store.encoded = null;

  @override
  Future<TradingSnapshot?> load() async {
    if (store.encoded == null) return null;
    return TradingSnapshot.fromJson(
      Map<String, dynamic>.from(jsonDecode(store.encoded!) as Map),
    );
  }

  @override
  Future<void> save(TradingSnapshot snapshot) async {
    store.encoded = jsonEncode(snapshot.toJson());
  }
}

class SharedPreferencesTradingRepository implements TradingRepository {
  static const _snapshotKey = 'paper_trading_snapshot_v1';
  final SharedPreferencesAsync _preferences;

  SharedPreferencesTradingRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  @override
  Future<void> clear() => _preferences.remove(_snapshotKey);

  @override
  Future<TradingSnapshot?> load() async {
    final encoded = await _preferences.getString(_snapshotKey);
    if (encoded == null || encoded.isEmpty) return null;
    return TradingSnapshot.fromJson(
      Map<String, dynamic>.from(jsonDecode(encoded) as Map),
    );
  }

  @override
  Future<void> save(TradingSnapshot snapshot) =>
      _preferences.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
}
