import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0D1B2A);
  static const surface = Color(0xFF1B2B3C);
  static const surfaceLight = Color(0xFF253545);
  static const primary = Color(0xFF4ECDC4);
  static const primaryDark = Color(0xFF3BADA6);
  static const accent = Color(0xFFFFE66D);
  static const textPrimary = Color(0xFFEAF0FB);
  static const textSecondary = Color(0xFF8DA3B8);
  static const bottleGlass = Color(0x22FFFFFF);
  static const bottleBorder = Color(0x66FFFFFF);
  static const bottleSelected = Color(0xFFFFE66D);
  static const bottleComplete = Color(0xFF4ECDC4);
  static const error = Color(0xFFFF6B6B);

  /// The 8 water colors used in the game (ordered by difficulty – added one at a time).
  static const waterColors = <Color>[
    Color(0xFFE53935), // 0 – Red
    Color(0xFF1E88E5), // 1 – Blue
    Color(0xFF43A047), // 2 – Green
    Color(0xFFFFA726), // 3 – Orange
    Color(0xFF8E24AA), // 4 – Purple
    Color(0xFF00ACC1), // 5 – Cyan
    Color(0xFFEC407A), // 6 – Pink
    Color(0xFF78909C), // 7 – Blue-Grey
  ];

  /// Lighter tint of each water color (used for highlights).
  static const waterColorsTint = <Color>[
    Color(0xFFEF9A9A),
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFFFCC80),
    Color(0xFFCE93D8),
    Color(0xFF80DEEA),
    Color(0xFFF48FB1),
    Color(0xFFB0BEC5),
  ];
}
