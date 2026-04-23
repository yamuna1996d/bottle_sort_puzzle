import '../entities/bottle_entity.dart';

/// Returns true when every bottle is either empty or completely filled
/// with a single color.
class CheckWinUseCase {
  const CheckWinUseCase();

  bool execute(List<BottleEntity> bottles) {
    for (final bottle in bottles) {
      if (!bottle.isComplete) return false;
    }
    return true;
  }
}
