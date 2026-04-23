import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/entities/game_state_entity.dart';
import '../providers/game_notifier.dart';
import '../providers/providers.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/win_overlay_widget.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameNotifierProvider(level));
    final progress = ref.watch(progressNotifierProvider);

    // Refresh progress whenever win state changes.
    ref.listen<GameStateModel>(
      gameNotifierProvider(level),
      (_, next) {
        if (next.entity.isWon) {
          ref.read(progressNotifierProvider.notifier).refresh();
        }
      },
    );

    final entity = gameState.entity;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _GameAppBar(level: level, entity: entity),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GameBoardWidget(
                            bottles: entity.bottles,
                            selectedIndex: entity.selectedBottleIndex,
                            onBottleTap: (i) => ref
                                .read(gameNotifierProvider(level).notifier)
                                .tapBottle(i),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _MovesBar(moves: entity.moves),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Win overlay – layered on top.
            if (entity.isWon)
              WinOverlayWidget(
                level: level,
                moves: entity.moves,
                bestMoves: progress.bestMoves[level],
                hasNextLevel: level < GameConstants.totalLevels,
                onNext: () {
                  context.pushReplacement('/game/${level + 1}');
                },
                onReplay: () {
                  ref.read(gameNotifierProvider(level).notifier).reset();
                },
                onMenu: () => context.go('/menu'),
              ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _GameAppBar extends ConsumerWidget {
  const _GameAppBar({required this.level, required this.entity});

  final int level;
  final GameStateEntity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameNotifierProvider(level).notifier);
    final canUndo = entity.canUndo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go('/menu'),
            tooltip: 'Menu',
          ),
          Expanded(
            child: Center(
              child: Text(
                'Level $level',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: canUndo ? notifier.undo : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: notifier.reset,
            tooltip: 'Restart',
          ),
        ],
      ),
    );
  }
}

// ── Moves bar ─────────────────────────────────────────────────────────────────

class _MovesBar extends StatelessWidget {
  const _MovesBar({required this.moves});

  final int moves;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz_rounded, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Text(
            '$moves ${moves == 1 ? "move" : "moves"}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
