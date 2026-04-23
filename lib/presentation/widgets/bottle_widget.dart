import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/bottle_entity.dart';
import 'bottle_painter.dart';

/// Renders a single bottle with optional wave animation when selected.
///
/// Wraps [BottlePainter] in a [RepaintBoundary] so only this widget
/// repaints when wave phase changes. Non-selected bottles are always static.
class BottleWidget extends StatefulWidget {
  const BottleWidget({
    super.key,
    required this.bottle,
    required this.isSelected,
    required this.onTap,
  });

  final BottleEntity bottle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<BottleWidget> createState() => _BottleWidgetState();
}

class _BottleWidgetState extends State<BottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: GameConstants.waveAnimationMs),
    );
    if (widget.isSelected) _waveCtrl.repeat();
  }

  @override
  void didUpdateWidget(BottleWidget old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !_waveCtrl.isAnimating) {
      _waveCtrl.repeat();
    } else if (!widget.isSelected && _waveCtrl.isAnimating) {
      _waveCtrl
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: widget.isSelected ? 1.06 : 1.0,
        curve: Curves.easeOutBack,
        child: RepaintBoundary(
          child: SizedBox(
            width: GameConstants.bottleWidth,
            height: GameConstants.bottleTotalHeight,
            child: widget.isSelected
                ? AnimatedBuilder(
                    animation: _waveCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: BottlePainter(
                        segments: widget.bottle.segments,
                        capacity: widget.bottle.capacity,
                        isSelected: widget.isSelected,
                        isComplete: widget.bottle.isComplete,
                        wavePhase: _waveCtrl.value,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: BottlePainter(
                      segments: widget.bottle.segments,
                      capacity: widget.bottle.capacity,
                      isSelected: false,
                      isComplete: widget.bottle.isComplete,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
