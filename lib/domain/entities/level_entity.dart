import 'package:flutter/foundation.dart';

@immutable
class LevelEntity {
  const LevelEntity({
    required this.levelNumber,
    required this.bottleSegments,
    required this.bottleCapacity,
    required this.numColors,
  });

  final int levelNumber;

  /// Initial bottle configurations. Each element is one bottle's segments
  /// (color indices, bottom→top). An empty list = empty bottle.
  final List<List<int>> bottleSegments;

  final int bottleCapacity;
  final int numColors;

  int get numBottles => bottleSegments.length;

  @override
  bool operator ==(Object other) =>
      other is LevelEntity && other.levelNumber == levelNumber;

  @override
  int get hashCode => levelNumber.hashCode;
}
