import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/game_constants.dart';

/// CustomPainter that renders a single bottle and its water contents.
///
/// Performance notes:
///   • [shouldRepaint] is strict – only repaints when visible state changes.
///   • Wave is drawn using a step of 3 px (~20 points per bottle width).
///   • Only the selected bottle animates; all others are static.
class BottlePainter extends CustomPainter {
  const BottlePainter({
    required this.segments,
    required this.capacity,
    required this.isSelected,
    required this.isComplete,
    this.wavePhase = 0.0,
  });

  final List<int> segments;
  final int capacity;
  final bool isSelected;
  final bool isComplete;

  /// 0→1 phase drives the wave animation (only used when [isSelected]).
  final double wavePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    const bodyH = GameConstants.bottleBodyHeight;
    const r = GameConstants.bottleBottomRadius;

    final bottlePath = _buildBottlePath(W, bodyH, r);

    // ── Selection / complete glow ───────────────────────────────────────────
    if (isSelected || isComplete) {
      final glowColor = isComplete ? AppColors.bottleComplete : AppColors.bottleSelected;
      canvas.drawPath(
        bottlePath,
        Paint()
          ..color = glowColor.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
      );
    }

    // ── Water segments ─────────────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(bottlePath);

    final segH = bodyH / capacity;

    for (int i = 0; i < segments.length; i++) {
      final color = AppColors.waterColors[segments[i]];
      final tint = AppColors.waterColorsTint[segments[i]];
      final startY = bodyH - (i + 1) * segH;
      final endY = bodyH - i * segH;
      final isTop = i == segments.length - 1;

      if (isTop && isSelected && segments.isNotEmpty) {
        _drawWaveSegment(canvas, W, startY, endY, color, tint);
      } else {
        _drawFlatSegment(canvas, W, startY, endY, color);
      }
    }

    canvas.restore();

    // ── Glass overlay (shine) ───────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(bottlePath);
    _drawGlassShine(canvas, W, bodyH);
    canvas.restore();

    // ── Bottle border ───────────────────────────────────────────────────────
    final borderColor =
        isComplete ? AppColors.bottleComplete : (isSelected ? AppColors.bottleSelected : AppColors.bottleBorder);
    canvas.drawPath(
      bottlePath,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.5,
    );
  }

  void _drawFlatSegment(Canvas canvas, double W, double startY, double endY, Color color) {
    canvas.drawRect(
      Rect.fromLTRB(0, startY, W, endY),
      Paint()..color = color,
    );
  }

  void _drawWaveSegment(
    Canvas canvas,
    double W,
    double startY,
    double endY,
    Color color,
    Color tint,
  ) {
    const step = 3.0;
    const amp = GameConstants.waveAmplitude;
    const freq = GameConstants.waveFrequency;

    final path = Path();
    path.moveTo(-step, endY);
    path.lineTo(-step, startY);

    for (double x = 0; x <= W + step; x += step) {
      final y = startY + amp * sin((x / W * freq + wavePhase) * 2 * pi);
      path.lineTo(x, y);
    }

    path.lineTo(W + step, endY);
    path.close();

    canvas.drawPath(path, Paint()..color = color);

    // Subtle lighter band at the wave surface.
    final highlightPath = Path();
    highlightPath.moveTo(0, startY - amp - 1);
    for (double x = 0; x <= W + step; x += step) {
      final y = startY + amp * sin((x / W * freq + wavePhase) * 2 * pi);
      highlightPath.lineTo(x, y - 2);
    }
    highlightPath.lineTo(W, startY - amp - 1);
    highlightPath.close();
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = tint.withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.fill,
    );
  }

  void _drawGlassShine(Canvas canvas, double W, double bodyH) {
    final shineRect = Rect.fromLTWH(W * 0.12, 0, W * 0.18, bodyH * 0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shineRect, const Radius.circular(4)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(shineRect),
    );
  }

  // ── Bottle outline path ────────────────────────────────────────────────────

  Path _buildBottlePath(double W, double bodyH, double r) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, bodyH)
      // Bottom semicircle: from left (0, bodyH) → through bottom → right (W, bodyH)
      // Sweep -pi = counterclockwise mathematically = clockwise visually (y-down coords)
      ..arcTo(
        Rect.fromCircle(center: Offset(W / 2, bodyH), radius: r),
        pi, // start at left point
        -pi, // sweep through the bottom
        false,
      )
      ..lineTo(W, 0)
      ..close();
  }

  @override
  bool shouldRepaint(BottlePainter old) =>
      old.isSelected != isSelected ||
      old.isComplete != isComplete ||
      old.wavePhase != wavePhase ||
      old.segments.length != segments.length ||
      _segmentsDiffer(old.segments, segments);

  static bool _segmentsDiffer(List<int> a, List<int> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }
}
