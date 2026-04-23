import 'package:hive_flutter/hive_flutter.dart';

/// Thin wrapper around a Hive box for persisting game progress.
/// Uses plain dynamic maps – no code generation required.
class ProgressDataSource {
  static const _boxName = 'progress';
  static const _completedKey = 'completed';
  static const _bestMovesKey = 'bestMoves';

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  Set<int> getCompletedLevels() {
    final raw = _box.get(_completedKey);
    if (raw is List) return raw.cast<int>().toSet();
    return {};
  }

  Map<int, int> getBestMoves() {
    final raw = _box.get(_bestMovesKey);
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(int.parse(k.toString()), v as int));
    }
    return {};
  }

  Future<void> markComplete(int level, int moves) async {
    final completed = getCompletedLevels()..add(level);
    await _box.put(_completedKey, completed.toList());

    final best = getBestMoves();
    if (!best.containsKey(level) || moves < best[level]!) {
      best[level] = moves;
      await _box.put(_bestMovesKey, best.map((k, v) => MapEntry('$k', v)));
    }
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_boxName);
  }
}
