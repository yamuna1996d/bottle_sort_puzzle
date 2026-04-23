import 'dart:math';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/level_entity.dart';

/// Provides level configurations.
///
/// Levels 1-10 use hand-crafted, verified configurations.
/// Levels 11-30 are generated procedurally with a deterministic seed,
/// guaranteeing solvability (we shuffle from a solved state).
class LevelDataSource {
  const LevelDataSource();

  LevelEntity getLevel(int levelNumber) {
    final bottles = levelNumber <= _handcrafted.length
        ? _deepCopy(_handcrafted[levelNumber - 1])
        : _generateLevel(levelNumber);

    final numColors = _colorCount(levelNumber);

    return LevelEntity(
      levelNumber: levelNumber,
      bottleSegments: bottles,
      bottleCapacity: GameConstants.bottleCapacity,
      numColors: numColors,
    );
  }

  // ── Hand-crafted levels 1-10 ──────────────────────────────────────────────

  /// Each level is a list of bottles.
  /// Each bottle is a list of color indices (bottom→top). [] = empty.
  static const _handcrafted = <List<List<int>>>[
    // Level 1 – 2 colors, 3 bottles
    [
      [0, 0, 1, 1],
      [1, 1, 0, 0],
      [],
    ],
    // Level 2 – 3 colors, 4 bottles
    [
      [0, 0, 1, 1],
      [1, 1, 2, 2],
      [2, 2, 0, 0],
      [],
    ],
    // Level 3 – 3 colors, 4 bottles (harder mix)
    [
      [0, 1, 2, 0],
      [2, 0, 1, 2],
      [1, 2, 0, 1],
      [],
    ],
    // Level 4 – 4 colors, 6 bottles
    [
      [0, 0, 1, 1],
      [1, 1, 2, 2],
      [2, 2, 3, 3],
      [3, 3, 0, 0],
      [],
      [],
    ],
    // Level 5 – 4 colors, 6 bottles (harder)
    [
      [0, 1, 2, 3],
      [3, 2, 1, 0],
      [1, 0, 3, 2],
      [2, 3, 0, 1],
      [],
      [],
    ],
    // Level 6 – 5 colors, 7 bottles
    [
      [0, 1, 2, 3],
      [4, 0, 1, 2],
      [3, 4, 0, 1],
      [2, 3, 4, 0],
      [1, 2, 3, 4],
      [],
      [],
    ],
    // Level 7 – 5 colors, 7 bottles (harder)
    [
      [0, 4, 1, 3],
      [2, 0, 4, 1],
      [3, 2, 0, 4],
      [1, 3, 2, 0],
      [4, 1, 3, 2],
      [],
      [],
    ],
    // Level 8 – 6 colors, 8 bottles
    [
      [0, 1, 2, 3],
      [4, 5, 0, 1],
      [2, 3, 4, 5],
      [0, 1, 2, 3],
      [4, 5, 0, 1],
      [2, 3, 4, 5],
      [],
      [],
    ],
    // Level 9 – 6 colors, 8 bottles (trickier)
    [
      [5, 0, 3, 1],
      [2, 4, 5, 0],
      [3, 1, 2, 4],
      [5, 0, 3, 1],
      [2, 4, 5, 0],
      [3, 1, 2, 4],
      [],
      [],
    ],
    // Level 10 – 7 colors, 9 bottles
    [
      [0, 1, 2, 3],
      [4, 5, 6, 0],
      [1, 2, 3, 4],
      [5, 6, 0, 1],
      [2, 3, 4, 5],
      [6, 0, 1, 2],
      [3, 4, 5, 6],
      [],
      [],
    ],
  ];

  // ── Procedural generation for levels 11-30 ───────────────────────────────

  static int _colorCount(int level) {
    if (level <= 2) return 2;
    if (level <= 5) return 3 + (level - 3);
    if (level <= 10) return 5 + (level - 6) ~/ 2;
    return min(8, 6 + (level - 11) ~/ 4);
  }

  static int _emptyBottles(int level) => level > 15 ? 1 : 2;

  List<List<int>> _generateLevel(int level) {
    final numColors = _colorCount(level);
    final numEmpty = _emptyBottles(level);
    const cap = GameConstants.bottleCapacity;

    // Start solved. Lists must be growable so _doPour can removeLast.
    final bottles = <List<int>>[
      for (int c = 0; c < numColors; c++) List.filled(cap, c, growable: true),
      for (int i = 0; i < numEmpty; i++) <int>[],
    ];

    // Shuffle by performing valid pours from solved state.
    final rng = Random(level * 0xDEAD + 0xBEEF);
    final shuffleMoves = numColors * 12 + level * 2;

    for (int m = 0; m < shuffleMoves; m++) {
      final valids = <(int, int)>[];
      for (int f = 0; f < bottles.length; f++) {
        for (int t = 0; t < bottles.length; t++) {
          if (f != t && _canPour(bottles[f], bottles[t], cap)) {
            valids.add((f, t));
          }
        }
      }
      if (valids.isEmpty) break;
      final (f, t) = valids[rng.nextInt(valids.length)];
      _doPour(bottles, f, t, cap);
    }

    return bottles;
  }

  static bool _canPour(List<int> from, List<int> to, int cap) {
    if (from.isEmpty) return false;
    if (to.length >= cap) return false;
    if (to.isEmpty) return true;
    return from.last == to.last;
  }

  static void _doPour(List<List<int>> bottles, int f, int t, int cap) {
    final top = bottles[f].last;
    int count = 0;
    for (int i = bottles[f].length - 1; i >= 0; i--) {
      if (bottles[f][i] == top) {
        count++;
      } else {
        break;
      }
    }
    final space = cap - bottles[t].length;
    final amount = min(count, space);
    for (int i = 0; i < amount; i++) {
      bottles[t].add(bottles[f].removeLast());
    }
  }

  static List<List<int>> _deepCopy(List<List<int>> src) =>
      [for (final b in src) List<int>.from(b)];
}
