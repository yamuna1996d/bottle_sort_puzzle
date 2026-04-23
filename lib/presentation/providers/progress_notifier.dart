import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/repositories/game_repository.dart';

@immutable
class ProgressModel {
  const ProgressModel({
    required this.completedLevels,
    required this.bestMoves,
  });

  final Set<int> completedLevels;
  final Map<int, int> bestMoves;

  int get highestUnlocked {
    if (completedLevels.isEmpty) return 1;
    final max = completedLevels.reduce((a, b) => a > b ? a : b);
    return (max + 1).clamp(1, GameConstants.totalLevels);
  }

  bool isUnlocked(int level) => level == 1 || completedLevels.contains(level - 1);
  bool isCompleted(int level) => completedLevels.contains(level);

  ProgressModel copyWith({Set<int>? completedLevels, Map<int, int>? bestMoves}) =>
      ProgressModel(
        completedLevels: completedLevels ?? this.completedLevels,
        bestMoves: bestMoves ?? this.bestMoves,
      );
}

class ProgressNotifier extends StateNotifier<ProgressModel> {
  ProgressNotifier(this._repo)
      : super(ProgressModel(
          completedLevels: _repo.getCompletedLevels(),
          bestMoves: {
            for (int i = 1; i <= GameConstants.totalLevels; i++)
              if (_repo.getBestMoves(i) != null) i: _repo.getBestMoves(i)!,
          },
        ));

  final GameRepository _repo;

  Future<void> refresh() async {
    state = ProgressModel(
      completedLevels: _repo.getCompletedLevels(),
      bestMoves: {
        for (int i = 1; i <= GameConstants.totalLevels; i++)
          if (_repo.getBestMoves(i) != null) i: _repo.getBestMoves(i)!,
      },
    );
  }
}
