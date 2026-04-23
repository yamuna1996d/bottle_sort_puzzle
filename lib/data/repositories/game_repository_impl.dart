import '../../domain/entities/level_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/level_data_source.dart';
import '../datasources/progress_data_source.dart';

class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl({
    required LevelDataSource levelDataSource,
    required ProgressDataSource progressDataSource,
  })  : _levels = levelDataSource,
        _progress = progressDataSource;

  final LevelDataSource _levels;
  final ProgressDataSource _progress;

  @override
  LevelEntity getLevel(int levelNumber) => _levels.getLevel(levelNumber);

  @override
  Set<int> getCompletedLevels() => _progress.getCompletedLevels();

  @override
  Future<void> markLevelComplete(int levelNumber, int moves) =>
      _progress.markComplete(levelNumber, moves);

  @override
  int? getBestMoves(int levelNumber) => _progress.getBestMoves()[levelNumber];
}
