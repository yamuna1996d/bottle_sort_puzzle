import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/bottle_entity.dart';
import '../../domain/entities/game_state_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/check_win_usecase.dart';
import '../../domain/usecases/get_level_usecase.dart';
import '../../domain/usecases/pour_water_usecase.dart';

// ── View model ────────────────────────────────────────────────────────────────

@immutable
class GameStateModel {
  const GameStateModel({
    required this.entity,
    this.isLoading = false,
    this.errorMessage,
  });

  final GameStateEntity entity;
  final bool isLoading;
  final String? errorMessage;

  GameStateModel copyWith({
    GameStateEntity? entity,
    bool? isLoading,
    String? errorMessage,
  }) =>
      GameStateModel(
        entity: entity ?? this.entity,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class GameNotifier extends StateNotifier<GameStateModel> {
  GameNotifier({
    required int level,
    required GetLevelUseCase getLevelUseCase,
    required PourWaterUseCase pourWaterUseCase,
    required CheckWinUseCase checkWinUseCase,
    required GameRepository gameRepository,
  })  : _pour = pourWaterUseCase,
        _checkWin = checkWinUseCase,
        _repo = gameRepository,
        super(GameStateModel(entity: _buildInitial(level, getLevelUseCase)));

  final PourWaterUseCase _pour;
  final CheckWinUseCase _checkWin;
  final GameRepository _repo;

  // ── Public actions ──────────────────────────────────────────────────────

  void tapBottle(int index) {
    final current = state.entity;

    if (current.isWon) return;

    final selected = current.selectedBottleIndex;

    if (selected == null) {
      // Nothing selected yet – select this bottle if it has water.
      if (current.bottles[index].isEmpty) return;
      state = state.copyWith(
        entity: current.copyWith(selectedBottleIndex: index),
      );
      return;
    }

    if (selected == index) {
      // Tap same bottle → deselect.
      state = state.copyWith(
        entity: current.copyWith(selectedBottleIndex: null),
      );
      return;
    }

    // Attempt pour from selected → index.
    final updated = _pour.execute(current, selected, index);
    if (updated == null) {
      // Invalid pour – switch selection to tapped bottle if it has water.
      if (!current.bottles[index].isEmpty) {
        state = state.copyWith(
          entity: current.copyWith(selectedBottleIndex: index),
        );
      } else {
        state = state.copyWith(
          entity: current.copyWith(selectedBottleIndex: null),
        );
      }
      return;
    }

    final isWon = _checkWin.execute(updated.bottles);
    final finalState = updated.copyWith(isWon: isWon);
    state = state.copyWith(entity: finalState);

    if (isWon) {
      _repo.markLevelComplete(current.level, updated.moves);
    }
  }

  void undo() {
    final current = state.entity;
    if (!current.canUndo) return;

    final prevBottles = current.history.last;
    final newHistory = current.history.sublist(0, current.history.length - 1);

    state = state.copyWith(
      entity: current.copyWith(
        bottles: prevBottles,
        moves: current.moves > 0 ? current.moves - 1 : 0,
        history: newHistory,
        selectedBottleIndex: null,
        lastPouredToIndex: null,
        isWon: false,
      ),
    );
  }

  void reset() {
    // Re-build from the same level config.
    final levelNumber = state.entity.level;
    final levelEntity = _repo.getLevel(levelNumber);
    final bottles = _bottlesFromLevel(levelEntity.bottleSegments);

    state = state.copyWith(
      entity: GameStateEntity(
        bottles: bottles,
        moves: 0,
        isWon: false,
        level: levelNumber,
        history: const [],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static GameStateEntity _buildInitial(int level, GetLevelUseCase getLevel) {
    final levelEntity = getLevel.execute(level);
    final bottles = _bottlesFromLevel(levelEntity.bottleSegments);
    return GameStateEntity(
      bottles: bottles,
      moves: 0,
      isWon: false,
      level: level,
      history: const [],
    );
  }

  static List<BottleEntity> _bottlesFromLevel(List<List<int>> segs) {
    return [
      for (int i = 0; i < segs.length; i++)
        BottleEntity(
          id: i,
          segments: List<int>.from(segs[i]),
          capacity: GameConstants.bottleCapacity,
        ),
    ];
  }
}
