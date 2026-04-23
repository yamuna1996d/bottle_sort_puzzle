import '../entities/level_entity.dart';

abstract interface class GameRepository {
  /// Returns the [LevelEntity] for [levelNumber] (1-indexed).
  LevelEntity getLevel(int levelNumber);

  /// Returns the set of completed level numbers.
  Set<int> getCompletedLevels();

  /// Persists [levelNumber] as completed with [moves] count.
  Future<void> markLevelComplete(int levelNumber, int moves);

  /// Best (minimum) moves for [levelNumber], or null if never completed.
  int? getBestMoves(int levelNumber);
}
