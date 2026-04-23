import 'package:flutter/foundation.dart';

/// Immutable representation of a single bottle and its water contents.
///
/// [segments] contains color indices from bottom (index 0) to top.
/// An empty [segments] list means the bottle is empty.
@immutable
class BottleEntity {
  const BottleEntity({
    required this.id,
    required this.segments,
    required this.capacity,
  });

  final int id;

  /// Color indices stored bottom→top. Values are indices into AppColors.waterColors.
  final List<int> segments;

  final int capacity;

  // ── Derived helpers ───────────────────────────────────────────────────────

  bool get isEmpty => segments.isEmpty;
  bool get isFull => segments.length >= capacity;
  int? get topColorIndex => isEmpty ? null : segments.last;

  /// A bottle is "complete" when it is empty OR fully filled with a single color.
  bool get isComplete {
    if (isEmpty) return true;
    if (segments.length != capacity) return false;
    final first = segments.first;
    for (final s in segments) {
      if (s != first) return false;
    }
    return true;
  }

  /// How many consecutive top-color units sit at the top.
  int get topRunLength {
    if (isEmpty) return 0;
    final top = segments.last;
    int count = 0;
    for (int i = segments.length - 1; i >= 0; i--) {
      if (segments[i] == top) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  // ── Copy helpers ──────────────────────────────────────────────────────────

  BottleEntity withSegments(List<int> newSegments) => BottleEntity(
        id: id,
        segments: newSegments,
        capacity: capacity,
      );

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottleEntity &&
          other.id == id &&
          listEquals(other.segments, segments) &&
          other.capacity == capacity;

  @override
  int get hashCode => Object.hash(id, Object.hashAll(segments), capacity);

  @override
  String toString() => 'Bottle($id, $segments)';
}
