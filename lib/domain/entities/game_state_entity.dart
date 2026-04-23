import 'package:flutter/foundation.dart';
import 'bottle_entity.dart';

@immutable
class GameStateEntity {
  const GameStateEntity({
    required this.bottles,
    required this.moves,
    required this.isWon,
    required this.level,
    required this.history,
    this.selectedBottleIndex,
    this.lastPouredToIndex,
  });

  final List<BottleEntity> bottles;
  final int moves;
  final bool isWon;
  final int level;

  /// Stack of previous states for undo support.
  final List<List<BottleEntity>> history;

  /// Index of the currently selected (highlighted) bottle, or null if none.
  final int? selectedBottleIndex;

  /// Index of the bottle that last received water (drives pour animation).
  final int? lastPouredToIndex;

  bool get canUndo => history.isNotEmpty;

  GameStateEntity copyWith({
    List<BottleEntity>? bottles,
    int? moves,
    bool? isWon,
    int? level,
    List<List<BottleEntity>>? history,
    Object? selectedBottleIndex = _sentinel,
    Object? lastPouredToIndex = _sentinel,
  }) =>
      GameStateEntity(
        bottles: bottles ?? this.bottles,
        moves: moves ?? this.moves,
        isWon: isWon ?? this.isWon,
        level: level ?? this.level,
        history: history ?? this.history,
        selectedBottleIndex: selectedBottleIndex == _sentinel
            ? this.selectedBottleIndex
            : selectedBottleIndex as int?,
        lastPouredToIndex: lastPouredToIndex == _sentinel
            ? this.lastPouredToIndex
            : lastPouredToIndex as int?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateEntity &&
          listEquals(other.bottles, bottles) &&
          other.moves == moves &&
          other.isWon == isWon &&
          other.level == level &&
          other.selectedBottleIndex == selectedBottleIndex &&
          other.lastPouredToIndex == lastPouredToIndex;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(bottles),
        moves,
        isWon,
        level,
        selectedBottleIndex,
        lastPouredToIndex,
      );
}

const _sentinel = Object();
