import '../entities/level_entity.dart';
import '../repositories/game_repository.dart';

class GetLevelUseCase {
  const GetLevelUseCase(this._repo);

  final GameRepository _repo;

  LevelEntity execute(int levelNumber) => _repo.getLevel(levelNumber);
}
