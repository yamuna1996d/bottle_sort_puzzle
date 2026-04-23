abstract final class GameConstants {
  /// Number of water units each bottle can hold.
  static const bottleCapacity = 4;

  /// Total number of levels in the game.
  static const totalLevels = 30;

  /// Bottle visual dimensions (logical pixels).
  static const bottleWidth = 58.0;
  static const bottleBodyHeight = 148.0;
  static const bottleBottomRadius = 29.0; // = bottleWidth / 2
  static const bottleTotalHeight = bottleBodyHeight + bottleBottomRadius;

  /// Pour animation duration in milliseconds.
  static const pourAnimationMs = 350;

  /// Wave animation period in milliseconds (full cycle).
  static const waveAnimationMs = 2000;

  /// Amplitude of the water surface wave in pixels.
  static const waveAmplitude = 2.5;

  /// Number of complete waves visible across a single bottle.
  static const waveFrequency = 2.5;
}
