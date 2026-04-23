import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/bottle_entity.dart';
import 'bottle_widget.dart';

/// Arranges bottles in a responsive grid.
///
/// Calculates the optimal number of columns based on available width,
/// never exceeding 4 per row.
class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({
    super.key,
    required this.bottles,
    required this.selectedIndex,
    required this.onBottleTap,
  });

  final List<BottleEntity> bottles;
  final int? selectedIndex;
  final void Function(int index) onBottleTap;

  static const _hGap = 14.0;
  static const _vGap = 24.0;
  static const _bottleSlotWidth = GameConstants.bottleWidth + _hGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // cols is computed but Wrap handles layout; keeping for future grid switch.
      _computeColumns(constraints.maxWidth, bottles.length);

      return Center(
        child: Wrap(
          spacing: _hGap,
          runSpacing: _vGap,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < bottles.length; i++)
              SizedBox(
                width: _bottleSlotWidth,
                child: Center(
                  child: BottleWidget(
                    key: ValueKey(bottles[i].id),
                    bottle: bottles[i],
                    isSelected: selectedIndex == i,
                    onTap: () => onBottleTap(i),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  int _computeColumns(double availableWidth, int count) {
    for (int cols = 4; cols >= 2; cols--) {
      if (availableWidth >= cols * _bottleSlotWidth) return cols;
    }
    return 2;
  }
}
