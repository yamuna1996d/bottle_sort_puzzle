import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class WinOverlayWidget extends StatefulWidget {
  const WinOverlayWidget({
    super.key,
    required this.level,
    required this.moves,
    required this.bestMoves,
    required this.hasNextLevel,
    required this.onNext,
    required this.onReplay,
    required this.onMenu,
  });

  final int level;
  final int moves;
  final int? bestMoves;
  final bool hasNextLevel;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final VoidCallback onMenu;

  @override
  State<WinOverlayWidget> createState() => _WinOverlayWidgetState();
}

class _WinOverlayWidgetState extends State<WinOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNewBest =
        widget.bestMoves == null || widget.moves <= widget.bestMoves!;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Trophy(),
                  const SizedBox(height: 16),
                  Text(
                    'Level ${widget.level} Complete!',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.moves} moves',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (isNewBest) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'New Best!',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (widget.hasNextLevel)
                    _PrimaryButton(
                      label: 'Next Level',
                      onTap: widget.onNext,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SecondaryButton(
                        label: 'Replay',
                        icon: Icons.replay_rounded,
                        onTap: widget.onReplay,
                      ),
                      const SizedBox(width: 12),
                      _SecondaryButton(
                        label: 'Menu',
                        icon: Icons.home_rounded,
                        onTap: widget.onMenu,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Trophy extends StatefulWidget {
  @override
  State<_Trophy> createState() => _TrophyState();
}

class _TrophyState extends State<_Trophy> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _ctrl,
        child: const Text('🏆', style: TextStyle(fontSize: 64)),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onTap, child: Text(label)),
      );
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
