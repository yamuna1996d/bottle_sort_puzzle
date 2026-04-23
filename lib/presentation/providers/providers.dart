import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/level_data_source.dart';
import '../../data/datasources/progress_data_source.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/check_win_usecase.dart';
import '../../domain/usecases/get_level_usecase.dart';
import '../../domain/usecases/pour_water_usecase.dart';
import 'game_notifier.dart';
import 'progress_notifier.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final levelDataSourceProvider = Provider<LevelDataSource>(
  (_) => const LevelDataSource(),
);

final progressDataSourceProvider = Provider<ProgressDataSource>(
  (_) => ProgressDataSource(),
);

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    levelDataSource: ref.watch(levelDataSourceProvider),
    progressDataSource: ref.watch(progressDataSourceProvider),
  );
});

// ── Use-cases ─────────────────────────────────────────────────────────────────

final getLevelUseCaseProvider = Provider<GetLevelUseCase>(
  (ref) => GetLevelUseCase(ref.watch(gameRepositoryProvider)),
);

final pourWaterUseCaseProvider = Provider<PourWaterUseCase>(
  (_) => const PourWaterUseCase(),
);

final checkWinUseCaseProvider = Provider<CheckWinUseCase>(
  (_) => const CheckWinUseCase(),
);

// ── Game state ────────────────────────────────────────────────────────────────

/// Family provider: one notifier per level number.
final gameNotifierProvider =
    StateNotifierProvider.family<GameNotifier, GameStateModel, int>(
  (ref, level) => GameNotifier(
    level: level,
    getLevelUseCase: ref.watch(getLevelUseCaseProvider),
    pourWaterUseCase: ref.watch(pourWaterUseCaseProvider),
    checkWinUseCase: ref.watch(checkWinUseCaseProvider),
    gameRepository: ref.watch(gameRepositoryProvider),
  ),
);

// ── Progress ──────────────────────────────────────────────────────────────────

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, ProgressModel>((ref) {
  return ProgressNotifier(ref.watch(gameRepositoryProvider));
});
