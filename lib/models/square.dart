import 'enums.dart';
import 'pawn.dart';
import 'position.dart';

/// Represents a single square on the board
class Square {
  final Position position;
  final SquareType type;
  final List<Pawn> pawns = [];

  Square({
    required this.position,
    required this.type,
  });

  int get row => position.row;
  int get col => position.col;
  String get id => position.id;

  bool get isEmpty => pawns.isEmpty;
  bool get hasSinglePawn => pawns.length == 1;
  bool get hasPairedPawns => pawns.length == 2;

  /// Check if square has enemy pawns for a given player
  bool hasEnemyPawns(int playerId) =>
      pawns.any((p) => p.playerId != playerId);

  /// Get all enemy pawns on this square
  List<Pawn> getEnemyPawns(int playerId) =>
      pawns.where((p) => p.playerId != playerId).toList();

  /// Get all friendly pawns on this square
  List<Pawn> getFriendlyPawns(int playerId) =>
      pawns.where((p) => p.playerId == playerId).toList();

  void addPawn(Pawn pawn) {
    pawns.add(pawn);
  }

  void removePawn(Pawn pawn) {
    pawns.remove(pawn);
  }

  void clearPawns() {
    pawns.clear();
  }

  @override
  String toString() => 'Square($id, $type, pawns: ${pawns.length})';
}
