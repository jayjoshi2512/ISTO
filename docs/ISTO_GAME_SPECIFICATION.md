# ISTO (Chauka Bara) - Game Design & Implementation Specification

**Version:** 1.0.0  
**Target Platform:** Flutter + Flame  
**Date:** January 17, 2026

---

## 1. Board Layout & Coordinate System

### 1.1 Grid Structure

```
     [0,1] [0,2] [0,3]
           │
[1,0]─[1,1]─[1,2]─[1,3]─[1,4]
           │
[2,0]─[2,1]─[2,2]─[2,3]─[2,4]
           │
[3,0]─[3,1]─[3,2]─[3,3]─[3,4]
           │
     [4,1] [4,2] [4,3]
```

### 1.2 Square Classification

| Type | Coordinates | Count |
|------|-------------|-------|
| **Center** | `[2,2]` | 1 |
| **Home Bases** | `[0,0]`, `[0,4]`, `[4,0]`, `[4,4]` | 4 |
| **Outer Path** | See §1.3 | 20 |
| **Inner Path** | See §1.4 | 4 |

### 1.3 Outer Path (Clockwise Order)

Starting positions per player and full outer loop:

```dart
const List<List<int>> OUTER_PATH = [
  // Top arm (descending)
  [0,2], [0,1],
  // Left column (descending)
  [1,0], [2,0], [3,0],
  // Bottom arm (ascending)
  [4,1], [4,2], [4,3],
  // Right column (ascending)
  [3,4], [2,4], [1,4],
  // Top arm (descending from right)
  [0,3], [0,2],
  // ... continues in loop
];
```

**Explicit Outer Path Sequence (20 squares, looping):**

```dart
const List<List<int>> OUTER_PATH_SEQUENCE = [
  [0,1], [0,2], [0,3],           // Top horizontal
  [1,4], [2,4], [3,4],           // Right vertical
  [4,3], [4,2], [4,1],           // Bottom horizontal
  [3,0], [2,0], [1,0],           // Left vertical
  [1,1], [1,2], [1,3],           // Inner top row
  [3,3], [3,2], [3,1],           // Inner bottom row
  [2,1], [2,3],                  // Inner middle (excluding center)
];
```

**Corrected Outer Ring (perimeter only, 12 squares):**

```dart
const List<List<int>> OUTER_RING = [
  [0,1], [0,2], [0,3],  // Top
  [1,4], [2,4], [3,4],  // Right
  [4,3], [4,2], [4,1],  // Bottom
  [3,0], [2,0], [1,0],  // Left
];
```

### 1.4 Inner Path (Cross Interior)

```dart
const List<List<int>> INNER_PATH = [
  [1,2],        // Top of cross
  [2,1], [2,3], // Left and right of center
  [3,2],        // Bottom of cross
];
```

### 1.5 Player Home Bases & Entry Points

| Player | Color | Home Base | Entry Square | Path Direction |
|--------|-------|-----------|--------------|----------------|
| P1 | Blue | `[4,0]` | `[4,1]` | Clockwise |
| P2 | Red | `[0,0]` | `[0,1]` | Clockwise |
| P3 | Green | `[0,4]` | `[0,3]` | Clockwise |
| P4 | Yellow | `[4,4]` | `[4,3]` | Clockwise |

### 1.6 Full Movement Path Per Player

Each player follows the outer ring, then enters inner path, then center.

**Player 1 (Blue) Complete Path:**

```dart
const List<List<int>> P1_FULL_PATH = [
  // Outer Ring (start from entry)
  [4,1], [4,2], [4,3],
  [3,4], [2,4], [1,4],
  [0,3], [0,2], [0,1],
  [1,0], [2,0], [3,0],
  // Inner Path
  [3,1], [3,2], [3,3],
  [2,3], [1,3], [1,2], [1,1],
  [2,1],
  // Center (destination)
  [2,2],
];
```

**Path Index:** Each pawn tracks `pathIndex: int` (0 to path.length-1).

---

## 2. Pawn Rules

### 2.1 Pawn States

```dart
enum PawnState {
  home,      // In home base, not yet entered
  active,    // On board (outer or inner path)
  finished,  // Reached center [2,2]
}
```

### 2.2 Pawn Data Structure

```dart
class Pawn {
  final String id;           // "P1_0", "P1_1", etc.
  final int playerId;        // 0-3
  PawnState state;
  int pathIndex;             // -1 when home, 0+ when active
  PathType currentPath;      // outer | inner
  
  List<int> get position => playerPaths[playerId][pathIndex];
}
```

### 2.3 Entry Conditions

A pawn may exit home and enter the board **only** when:
- Roll result is **ISTO (0-up, 8 steps)** OR **ચોમ (4-up, 4 steps)**

### 2.4 Movement Constraints

| Path Type | Max Pawns Per Square | Stacking Allowed | Kill Type Allowed |
|-----------|---------------------|------------------|-------------------|
| Outer | 1 | No | Single only |
| Inner | Unlimited | Yes | Single or Paired |
| Center | Unlimited | Yes | None (safe) |

---

## 3. Cowry (Dwaries) Mechanics

### 3.1 Roll Calculation

```dart
class CowryRoll {
  final List<bool> cowries; // 4 elements, true = up
  
  int get upCount => cowries.where((c) => c).length;
  
  int get steps {
    switch (upCount) {
      case 0: return 8;  // ISTO
      case 1: return 1;
      case 2: return 2;
      case 3: return 3;
      case 4: return 4;  // ચોમ
    }
  }
  
  bool get isISTO => upCount == 0;
  bool get isChom => upCount == 4;
  bool get grantsExtraTurn => isISTO || isChom;
  bool get allowsEntry => isISTO || isChom;
}
```

### 3.2 Roll Result Table

| Up Count | Name | Steps | Extra Turn | Allows Entry |
|----------|------|-------|------------|--------------|
| 0 | ISTO | 8 | ✓ | ✓ |
| 1 | — | 1 | ✗ | ✗ |
| 2 | — | 2 | ✗ | ✗ |
| 3 | — | 3 | ✗ | ✗ |
| 4 | ચોમ | 4 | ✓ | ✓ |

---

## 4. Turn & Extra Turn Logic

### 4.1 Turn State Machine

```dart
enum TurnPhase {
  waitingForRoll,
  rolled,
  selectingPawn,
  moving,
  resolving,
  checkingExtraTurn,
  turnEnd,
}
```

### 4.2 Turn Flow

```
┌─────────────────────────────────────────────────────────┐
│                    TURN START                           │
└─────────────────────┬───────────────────────────────────┘
                      ▼
              ┌───────────────┐
              │  Roll Cowries │
              └───────┬───────┘
                      ▼
              ┌───────────────┐
              │ Calculate     │
              │ Valid Moves   │
              └───────┬───────┘
                      ▼
          ┌───────────┴───────────┐
          │ Any valid moves?      │
          └───────────┬───────────┘
               No     │     Yes
          ┌───────────┘     │
          ▼                 ▼
    ┌──────────┐    ┌───────────────┐
    │ Skip Turn│    │ Select Pawn   │
    └────┬─────┘    └───────┬───────┘
         │                  ▼
         │          ┌───────────────┐
         │          │ Execute Move  │
         │          └───────┬───────┘
         │                  ▼
         │          ┌───────────────┐
         │          │ Resolve:      │
         │          │ - Collision   │
         │          │ - Kill        │
         │          │ - Finish      │
         │          └───────┬───────┘
         │                  ▼
         │          ┌───────────────┐
         │          │ Check Extra   │
         │          │ Turn Trigger  │
         │          └───────┬───────┘
         │           Yes    │    No
         │          ┌───────┘    │
         │          ▼            │
         │   ┌────────────┐      │
         │   │ EXTRA TURN │      │
         │   │ (max 1)    │──────┘
         │   └────────────┘      │
         │                       │
         └───────────┬───────────┘
                     ▼
              ┌──────────────┐
              │  TURN END    │
              │  Next Player │
              └──────────────┘
```

### 4.3 Extra Turn Rules (Strict)

**Triggers (any one grants extra turn):**
1. Roll ISTO (0-up)
2. Roll ચોમ (4-up)
3. Pawn reaches center `[2,2]`
4. Kill opponent pawn (single or paired)

**Constraint:**
```dart
bool extraTurnGranted = false;

void checkExtraTurn(MoveResult result) {
  if (extraTurnGranted) return; // Already granted this turn
  
  if (result.rollWasISTO || 
      result.rollWasChom || 
      result.pawnReachedCenter || 
      result.killedOpponent) {
    extraTurnGranted = true;
    grantExtraTurn();
  }
}
```

**Key Rule:** Maximum ONE extra turn per action. Multiple triggers in same move = still ONE extra turn.

---

## 5. Kill Mechanics

### 5.1 Outer Path Kill

```dart
// Outer path: only single pawn allowed
bool canKillOnOuter(Square target, Pawn attacker) {
  if (target.pawns.length != 1) return false;
  if (target.pawns[0].playerId == attacker.playerId) return false;
  return true;
}

void executeOuterKill(Square target) {
  Pawn victim = target.pawns[0];
  victim.state = PawnState.home;
  victim.pathIndex = -1;
  target.pawns.clear();
  // Trigger extra turn
}
```

### 5.2 Inner Path Kill

```dart
// Inner path: single OR paired kill allowed
KillResult canKillOnInner(Square target, Pawn attacker, {bool isPair = false}) {
  List<Pawn> enemies = target.pawns
    .where((p) => p.playerId != attacker.playerId)
    .toList();
    
  if (enemies.isEmpty) return KillResult.none;
  
  if (isPair && enemies.length == 2 && 
      enemies[0].playerId == enemies[1].playerId) {
    return KillResult.pairedKill;
  }
  
  if (enemies.length == 1) {
    return KillResult.singleKill;
  }
  
  return KillResult.none;
}
```

### 5.3 Paired Pawn Movement (Inner Path Only)

```dart
class PairedMove {
  final Pawn pawn1;
  final Pawn pawn2;
  
  bool canMoveTogether() {
    return pawn1.currentPath == PathType.inner &&
           pawn2.currentPath == PathType.inner &&
           pawn1.position == pawn2.position;
  }
  
  void execute(int steps) {
    // Both pawns move together
    pawn1.pathIndex += steps;
    pawn2.pathIndex += steps;
  }
}
```

---

## 6. Winning Conditions

### 6.1 Win Detection

```dart
bool checkWin(int playerId) {
  return pawns
    .where((p) => p.playerId == playerId)
    .every((p) => p.state == PawnState.finished);
}
```

### 6.2 Game End Flow

1. First player to finish all 4 pawns = **Winner (1st place)**
2. Game continues for remaining players
3. Ranking assigned as players finish
4. Game ends when 3 players finish (last = 4th place)

---

## 7. Architecture

### 7.1 Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        GameManager                          │
│  - Orchestrates all controllers                             │
│  - Handles game lifecycle                                   │
└─────────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   Board     │ │   Pawn      │ │   Cowry     │ │   Turn      │
│ Controller  │ │ Controller  │ │ Controller  │ │ StateMachine│
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
         │              │              │              │
         └──────────────┴──────────────┴──────────────┘
                                │
                                ▼
                    ┌─────────────────────┐
                    │   AnimationLayer    │
                    │  (Decoupled, event  │
                    │   driven only)      │
                    └─────────────────────┘
```

### 7.2 BoardController

```dart
class BoardController {
  static const int BOARD_SIZE = 5;
  
  final Map<String, Square> squares = {};
  
  // Path definitions
  final Map<int, List<List<int>>> playerPaths;
  
  // Initialize board
  void initBoard() {
    for (int r = 0; r < BOARD_SIZE; r++) {
      for (int c = 0; c < BOARD_SIZE; c++) {
        if (isValidSquare(r, c)) {
          squares['$r,$c'] = Square(
            row: r,
            col: c,
            type: getSquareType(r, c),
          );
        }
      }
    }
  }
  
  bool isValidSquare(int r, int c) {
    // Cross shape validation
    bool inVerticalArm = c >= 1 && c <= 3;
    bool inHorizontalArm = r >= 1 && r <= 3;
    return inVerticalArm || inHorizontalArm;
  }
  
  SquareType getSquareType(int r, int c) {
    if (r == 2 && c == 2) return SquareType.center;
    if (isInnerPath(r, c)) return SquareType.inner;
    return SquareType.outer;
  }
  
  bool isInnerPath(int r, int c) {
    return (r == 1 && c == 2) ||
           (r == 2 && c == 1) ||
           (r == 2 && c == 3) ||
           (r == 3 && c == 2);
  }
  
  List<Pawn> getValidMoves(int playerId, int steps, List<Pawn> pawns) {
    // Returns list of pawns that can legally move
  }
  
  bool isPathBlocked(Pawn pawn, int steps) {
    // Check if movement is blocked
  }
}
```

### 7.3 PawnController

```dart
class PawnController {
  final List<Pawn> pawns = [];
  
  void initPawns(int playerCount) {
    for (int p = 0; p < playerCount; p++) {
      for (int i = 0; i < 4; i++) {
        pawns.add(Pawn(
          id: 'P${p}_$i',
          playerId: p,
          state: PawnState.home,
          pathIndex: -1,
          currentPath: PathType.outer,
        ));
      }
    }
  }
  
  MoveResult movePawn(Pawn pawn, int steps, BoardController board) {
    int newIndex = pawn.pathIndex + steps;
    List<List<int>> path = board.playerPaths[pawn.playerId]!;
    
    // Check if reaching center
    if (newIndex >= path.length - 1) {
      pawn.pathIndex = path.length - 1;
      pawn.state = PawnState.finished;
      return MoveResult(reachedCenter: true);
    }
    
    // Normal movement
    pawn.pathIndex = newIndex;
    List<int> newPos = path[newIndex];
    
    // Check for kills
    return resolveCollision(pawn, newPos, board);
  }
  
  MoveResult resolveCollision(Pawn pawn, List<int> pos, BoardController board) {
    Square square = board.squares['${pos[0]},${pos[1]}']!;
    
    if (square.type == SquareType.outer) {
      return resolveOuterCollision(pawn, square);
    } else {
      return resolveInnerCollision(pawn, square);
    }
  }
  
  void enterBoard(Pawn pawn) {
    pawn.state = PawnState.active;
    pawn.pathIndex = 0;
  }
}
```

### 7.4 CowryController

```dart
class CowryController {
  final Random _random = Random();
  
  CowryRoll roll() {
    List<bool> cowries = List.generate(4, (_) => _random.nextBool());
    return CowryRoll(cowries: cowries);
  }
}
```

### 7.5 TurnStateMachine

```dart
class TurnStateMachine {
  int currentPlayer = 0;
  int playerCount;
  TurnPhase phase = TurnPhase.waitingForRoll;
  bool extraTurnPending = false;
  
  final List<int> finishedPlayers = [];
  
  void startTurn() {
    phase = TurnPhase.waitingForRoll;
    extraTurnPending = false;
  }
  
  void onRollComplete(CowryRoll roll) {
    phase = TurnPhase.selectingPawn;
    
    if (roll.grantsExtraTurn) {
      extraTurnPending = true;
    }
  }
  
  void onMoveComplete(MoveResult result) {
    if (!extraTurnPending) {
      if (result.killedOpponent || result.reachedCenter) {
        extraTurnPending = true;
      }
    }
    
    phase = TurnPhase.checkingExtraTurn;
  }
  
  void endTurn() {
    if (extraTurnPending) {
      extraTurnPending = false;
      startTurn(); // Same player goes again
    } else {
      advancePlayer();
      startTurn();
    }
  }
  
  void advancePlayer() {
    do {
      currentPlayer = (currentPlayer + 1) % playerCount;
    } while (finishedPlayers.contains(currentPlayer));
  }
  
  void markPlayerFinished(int playerId) {
    if (!finishedPlayers.contains(playerId)) {
      finishedPlayers.add(playerId);
    }
  }
  
  bool get isGameOver => finishedPlayers.length >= playerCount - 1;
}
```

### 7.6 AnimationLayer

```dart
class AnimationLayer {
  // Decoupled from game logic
  // Triggered by state change events only
  
  void onCowryRoll(CowryRoll roll) {
    // Animate cowry flip
    // Duration: 800ms
  }
  
  void onPawnMove(Pawn pawn, List<List<int>> path) {
    // Smooth glide along path
    // Duration: 300ms per square
  }
  
  void onKill(Pawn victim, KillType type) {
    // Brief glow effect
    // Single: 400ms gold glow
    // Paired: 500ms red glow
  }
  
  void onExtraTurn(int playerId) {
    // Soft pulse on player indicator
    // Duration: 600ms
  }
  
  void onWin(int playerId) {
    // Center glow + subtle particles
    // Duration: 2000ms
  }
}
```

---

## 8. UI/UX Specification

### 8.1 Design Tokens

```dart
class ISTOTheme {
  // Colors
  static const Color boardBackground = Color(0xFF1A1A2E);
  static const Color squareDefault = Color(0xFF16213E);
  static const Color squareInner = Color(0xFF1F3460);
  static const Color squareCenter = Color(0xFFE8D5B7);
  static const Color squareHighlight = Color(0xFF4ECCA3);
  
  // Player Colors
  static const Color player1 = Color(0xFF4A90D9); // Blue
  static const Color player2 = Color(0xFFE85D75); // Red
  static const Color player3 = Color(0xFF4ECCA3); // Green
  static const Color player4 = Color(0xFFF5CD47); // Yellow
  
  // Typography
  static const String fontFamily = 'Inter';
  static const double fontSizeLabel = 14.0;
  static const double fontSizeHeading = 24.0;
  
  // Spacing
  static const double squareGap = 2.0;
  static const double boardPadding = 16.0;
  static const double cornerRadius = 8.0;
  
  // Shadows
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x20000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
}
```

### 8.2 Layout Structure

```
┌─────────────────────────────────────────┐
│            Status Bar (system)          │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────┐           ┌─────────┐      │
│  │ P2 Home │           │ P3 Home │      │
│  │ [pawns] │           │ [pawns] │      │
│  └─────────┘           └─────────┘      │
│                                         │
│         ┌─────────────────┐             │
│         │                 │             │
│         │   GAME BOARD    │             │
│         │   (5x5 cross)   │             │
│         │                 │             │
│         └─────────────────┘             │
│                                         │
│  ┌─────────┐           ┌─────────┐      │
│  │ P1 Home │           │ P4 Home │      │
│  │ [pawns] │           │ [pawns] │      │
│  └─────────┘           └─────────┘      │
│                                         │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │       Cowry Roll Area           │    │
│  │     [🐚] [🐚] [🐚] [🐚]          │    │
│  │         Result: ISTO            │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│  [ Roll Button / Turn Indicator ]       │
└─────────────────────────────────────────┘
```

### 8.3 Component Specifications

#### Board Square

```dart
class BoardSquareWidget {
  final double size = 56.0; // Adaptive based on screen
  final double borderRadius = 6.0;
  final double pawnSize = 32.0;
  
  Color getColor(SquareType type, bool isHighlighted) {
    if (isHighlighted) return ISTOTheme.squareHighlight;
    switch (type) {
      case SquareType.outer: return ISTOTheme.squareDefault;
      case SquareType.inner: return ISTOTheme.squareInner;
      case SquareType.center: return ISTOTheme.squareCenter;
    }
  }
}
```

#### Pawn

```dart
class PawnWidget {
  final double size = 28.0;
  final double borderWidth = 2.0;
  
  // Circle with player color
  // White border for visibility
  // Subtle inner shadow
}
```

#### Cowry Shell

```dart
class CowryWidget {
  final double width = 32.0;
  final double height = 20.0;
  
  // Elliptical shape
  // Cream color when up (0xFFF5F0E1)
  // Brown color when down (0xFF8B7355)
  // Subtle rotation during roll animation
}
```

### 8.4 Interaction States

| State | Visual Feedback |
|-------|-----------------|
| Idle square | Default color |
| Valid move target | Green highlight + subtle pulse |
| Selected pawn | Elevated + glow ring |
| Opponent pawn (killable) | Red tint overlay |
| Current player | Border highlight on home |
| Extra turn pending | Pulsing player indicator |

### 8.5 Animation Timings

```dart
class AnimationDurations {
  static const Duration cowryRoll = Duration(milliseconds: 800);
  static const Duration cowrySettle = Duration(milliseconds: 200);
  static const Duration pawnMovePerSquare = Duration(milliseconds: 250);
  static const Duration pawnKillEffect = Duration(milliseconds: 400);
  static const Duration extraTurnPulse = Duration(milliseconds: 600);
  static const Duration winCelebration = Duration(milliseconds: 2000);
  static const Duration turnTransition = Duration(milliseconds: 300);
}
```

### 8.6 Sound Design (Optional)

| Event | Sound Character |
|-------|-----------------|
| Cowry roll | Soft wooden clatter |
| Cowry land | Gentle tap |
| Pawn move | Soft slide/click |
| Kill | Brief whoosh |
| Extra turn | Subtle chime |
| Win | Gentle fanfare |

---

## 9. Data Models

### 9.1 Core Types

```dart
enum SquareType { outer, inner, center, home }
enum PathType { outer, inner }
enum PawnState { home, active, finished }
enum TurnPhase { waitingForRoll, rolled, selectingPawn, moving, resolving, checkingExtraTurn, turnEnd }
enum KillType { none, single, paired }

class Square {
  final int row;
  final int col;
  final SquareType type;
  List<Pawn> pawns = [];
  
  String get id => '$row,$col';
}

class Pawn {
  final String id;
  final int playerId;
  PawnState state;
  int pathIndex;
  PathType currentPath;
}

class CowryRoll {
  final List<bool> cowries; // true = up
  int get upCount => cowries.where((c) => c).length;
  int get steps => [8, 1, 2, 3, 4][upCount];
  bool get isISTO => upCount == 0;
  bool get isChom => upCount == 4;
  bool get grantsExtraTurn => isISTO || isChom;
  bool get allowsEntry => isISTO || isChom;
}

class MoveResult {
  final bool reachedCenter;
  final bool killedOpponent;
  final KillType killType;
  final Pawn? victim;
}

class Player {
  final int id;
  final String name;
  final Color color;
  int rank = 0; // 0 = not finished, 1-4 = placement
}

class GameState {
  final List<Player> players;
  final List<Pawn> pawns;
  final Map<String, Square> board;
  int currentPlayerId;
  TurnPhase phase;
  CowryRoll? lastRoll;
  bool extraTurnPending;
  List<int> rankings;
}
```

---

## 10. File Structure

```
lib/
├── main.dart
├── game/
│   ├── isto_game.dart           # Main Flame game class
│   ├── game_manager.dart        # Orchestrator
│   └── config/
│       ├── board_config.dart    # Path definitions
│       ├── theme_config.dart    # Colors, sizes
│       └── animation_config.dart
├── controllers/
│   ├── board_controller.dart
│   ├── pawn_controller.dart
│   ├── cowry_controller.dart
│   └── turn_state_machine.dart
├── models/
│   ├── square.dart
│   ├── pawn.dart
│   ├── player.dart
│   ├── cowry_roll.dart
│   └── game_state.dart
├── components/
│   ├── board_component.dart     # Flame component
│   ├── square_component.dart
│   ├── pawn_component.dart
│   ├── cowry_component.dart
│   └── player_hud_component.dart
├── overlays/
│   ├── roll_button_overlay.dart
│   ├── turn_indicator_overlay.dart
│   ├── win_overlay.dart
│   └── menu_overlay.dart
├── animations/
│   ├── cowry_roll_animation.dart
│   ├── pawn_move_animation.dart
│   ├── kill_effect_animation.dart
│   └── celebration_animation.dart
├── services/
│   ├── audio_service.dart
│   └── firebase_service.dart    # Optional multiplayer
└── utils/
    ├── path_utils.dart
    └── position_utils.dart
```

---

## 11. Implementation Checklist

### Phase 1: Core Setup
- [ ] Project initialization (Flutter + Flame)
- [ ] Define board configuration constants
- [ ] Implement data models
- [ ] Create BoardController with path logic

### Phase 2: Game Logic
- [ ] Implement PawnController
- [ ] Implement CowryController
- [ ] Build TurnStateMachine
- [ ] Integrate kill mechanics
- [ ] Add win detection

### Phase 3: Rendering
- [ ] Create board component
- [ ] Create square components
- [ ] Create pawn components
- [ ] Implement cowry visuals
- [ ] Add player HUD

### Phase 4: Interactions
- [ ] Roll button functionality
- [ ] Pawn selection
- [ ] Move highlighting
- [ ] Touch/click handling

### Phase 5: Animations
- [ ] Cowry roll animation
- [ ] Pawn movement animation
- [ ] Kill effects
- [ ] Extra turn indicator
- [ ] Win celebration

### Phase 6: Polish
- [ ] Audio integration
- [ ] Screen transitions
- [ ] Error handling
- [ ] Performance optimization

### Phase 7: Optional
- [ ] Firebase multiplayer
- [ ] AI opponent
- [ ] Statistics tracking

---

## 12. Testing Strategy

### Unit Tests
- Path calculation correctness
- Kill detection logic
- Extra turn trigger validation
- Win condition detection

### Integration Tests
- Full turn flow
- Multi-kill scenarios
- Edge cases (blocked paths, no valid moves)

### Visual Tests
- Animation smoothness
- Layout responsiveness
- Color accessibility

---

## 13. Appendix: Quick Reference

### Valid Move Check

```dart
bool canMove(Pawn pawn, int steps, BoardController board) {
  // Home pawn needs ISTO or ચોમ to enter
  if (pawn.state == PawnState.home) {
    return lastRoll.allowsEntry;
  }
  
  // Check path bounds
  int newIndex = pawn.pathIndex + steps;
  if (newIndex >= path.length) return false;
  
  // Check outer path blocking
  if (isOnOuterPath(pawn) && isOnOuterPath(newIndex)) {
    Square target = getSquare(path[newIndex]);
    if (target.pawns.isNotEmpty && 
        target.pawns[0].playerId == pawn.playerId) {
      return false; // Can't land on own pawn on outer
    }
  }
  
  return true;
}
```

### Kill Resolution

```dart
MoveResult resolveKill(Pawn attacker, Square target) {
  if (target.type == SquareType.center) {
    return MoveResult(killedOpponent: false);
  }
  
  List<Pawn> enemies = target.pawns
    .where((p) => p.playerId != attacker.playerId)
    .toList();
    
  if (enemies.isEmpty) {
    return MoveResult(killedOpponent: false);
  }
  
  if (target.type == SquareType.outer && enemies.length == 1) {
    sendHome(enemies[0]);
    return MoveResult(killedOpponent: true, killType: KillType.single);
  }
  
  if (target.type == SquareType.inner) {
    if (enemies.length == 2 && attacker.isPaired) {
      sendHome(enemies[0]);
      sendHome(enemies[1]);
      return MoveResult(killedOpponent: true, killType: KillType.paired);
    }
    if (enemies.length == 1) {
      sendHome(enemies[0]);
      return MoveResult(killedOpponent: true, killType: KillType.single);
    }
  }
  
  return MoveResult(killedOpponent: false);
}
```

---

**End of Specification**
