import 'dart:ui';

/// Represents a player in the game
class Player {
  final int id;
  final String name;
  final Color color;
  int rank; // 0 = not finished, 1-4 = placement

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.rank = 0,
  });

  bool get hasFinished => rank > 0;

  @override
  String toString() => 'Player($id, $name, rank: $rank)';
}
