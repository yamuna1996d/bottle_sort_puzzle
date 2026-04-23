import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';
import '../providers/providers.dart';

class LevelSelectPage extends ConsumerWidget {
  const LevelSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/menu'),
        ),
        title: const Text('Select Level'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: GameConstants.totalLevels,
        itemBuilder: (context, i) {
          final level = i + 1;
          final unlocked = progress.isUnlocked(level);
          final completed = progress.isCompleted(level);
          final best = progress.bestMoves[level];

          return _LevelTile(
            level: level,
            unlocked: unlocked,
            completed: completed,
            bestMoves: best,
            onTap: unlocked ? () => context.push('/game/$level') : null,
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.unlocked,
    required this.completed,
    this.bestMoves,
    this.onTap,
  });

  final int level;
  final bool unlocked;
  final bool completed;
  final int? bestMoves;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = completed
        ? AppColors.primary.withValues(alpha: 0.2)
        : unlocked
            ? AppColors.surfaceLight
            : AppColors.surface;

    final Color border = completed
        ? AppColors.primary.withValues(alpha: 0.6)
        : unlocked
            ? AppColors.bottleBorder
            : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!unlocked)
                  const Icon(Icons.lock_rounded,
                      color: AppColors.textSecondary, size: 20)
                else
                  Text(
                    '$level',
                    style: TextStyle(
                      color: completed
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (completed && bestMoves != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$bestMoves',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
            if (completed)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
