/// Represents a board position with row and column
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  String get id => '$row,$col';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => '[$row,$col]';

  /// Create Position from path list format
  factory Position.fromList(List<int> pos) => Position(pos[0], pos[1]);

  List<int> toList() => [row, col];
}
