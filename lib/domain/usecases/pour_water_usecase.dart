import '../entities/bottle_entity.dart';
import '../entities/game_state_entity.dart';

/// Attempts to pour water from [fromIndex] into [toIndex].
///
/// Returns the updated [GameStateEntity] on success, or null if the pour
/// is invalid (source empty, target full, or mismatched top colors).
class PourWaterUseCase {
  const PourWaterUseCase();

  GameStateEntity? execute(GameStateEntity state, int fromIndex, int toIndex) {
    final from = state.bottles[fromIndex];
    final to = state.bottles[toIndex];

    if (!_canPour(from, to)) return null;

    final count = _pourCount(from, to);
    final topColor = from.topColorIndex!;

    final newFrom = from.withSegments(
      from.segments.sublist(0, from.segments.length - count),
    );
    final newTo = to.withSegments(
      [...to.segments, ...List.filled(count, topColor)],
    );

    final newBottles = List<BottleEntity>.from(state.bottles);
    newBottles[fromIndex] = newFrom;
    newBottles[toIndex] = newTo;

    // Push current bottles snapshot onto history for undo.
    final newHistory = [
      ...state.history,
      List<BottleEntity>.from(state.bottles),
    ];

    // Cap history depth to avoid excessive memory use.
    const maxHistory = 50;
    final trimmedHistory = newHistory.length > maxHistory
        ? newHistory.sublist(newHistory.length - maxHistory)
        : newHistory;

    return state.copyWith(
      bottles: newBottles,
      moves: state.moves + 1,
      history: trimmedHistory,
      selectedBottleIndex: null,
      lastPouredToIndex: toIndex,
    );
  }

  bool _canPour(BottleEntity from, BottleEntity to) {
    if (from.isEmpty) return false;
    if (to.isFull) return false;
    if (to.isEmpty) return true;
    return from.topColorIndex == to.topColorIndex;
  }

  int _pourCount(BottleEntity from, BottleEntity to) {
    final count = from.topRunLength;
    final space = to.capacity - to.segments.length;
    return count < space ? count : space;
  }
}
