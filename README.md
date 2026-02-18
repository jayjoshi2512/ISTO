# ISTO (ઇસ્ટો) - Chauka Bara

A digital implementation of the traditional Indian board game **ISTO** (also known as Chauka Bara, Chowka Bhara, or Ashta Chamma), built with **Flutter** and **Flame** game engine.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Flame](https://img.shields.io/badge/Flame-1.30-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 🎮 About the Game

ISTO is a classic cross-and-circle board game from India, similar to Pachisi and Ludo. Players race their 4 pawns from home base, around the outer path, through the inner path, and into the center to win.

### Key Features

- **Authentic Rules**: True to traditional ISTO gameplay
- **2-4 Players**: Local pass-and-play multiplayer
- **Cowry Dice**: Traditional cowry shell mechanics
- **How to Play**: Comprehensive in-game rules reference (accessible from menu & settings)
- **Visual Guides**: Colored arrows showing inner ring entry points per player
- **Clean UI/UX**: Modern, minimal, professional design
- **Smooth Animations**: Subtle, purposeful animations

## 📜 Game Rules

### Cowry (Dwaries) Rolls

| Cowries Up | Name | Steps | Extra Turn |
| ---------- | ---- | ----- | ---------- |
| 0          | ISTO | 8     | ✅         |
| 1          | —    | 1     | ❌         |
| 2          | —    | 2     | ❌         |
| 3          | —    | 3     | ❌         |
| 4          | ચોમ  | 4     | ✅         |

### Entry Rules

- Pawns can only exit home on **ISTO** (0-up) or **ચોમ** (4-up)

### Path Rules

- **Outer Path**: Max 1 pawn per square, single kills only
- **Inner Path**: Multiple pawns allowed, single or paired kills
- **Center**: Safe zone, final destination

### Inner Ring Entry Requirement

- **A pawn can only enter the inner ring after capturing at least one opponent pawn**
- Colored arrows (➜) on the board show each player's inner ring entry point
- Until a capture is made, pawns must remain on the outer ring

### Extra Turn Triggers

- Rolling ISTO or ચોમ
- Reaching the center
- Killing an opponent pawn

### Safe Squares

- 4 starting positions (marked with X) + center are safe zones
- No captures allowed on safe squares

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── config/                # Configuration files
│   ├── board_config.dart  # Board layout & paths
│   ├── theme_config.dart  # Colors & styling
│   └── animation_config.dart
├── models/                # Data models
│   ├── pawn.dart
│   ├── square.dart
│   ├── cowry_roll.dart
│   └── ...
├── controllers/           # Game logic
│   ├── board_controller.dart
│   ├── pawn_controller.dart
│   ├── cowry_controller.dart
│   └── turn_state_machine.dart
├── game/                  # Flame game classes
│   ├── isto_game.dart
│   └── game_manager.dart
├── components/            # Flame components
│   ├── board_component.dart
│   ├── pawn_component.dart
│   └── ...
├── overlays/              # Flutter overlay widgets
│   ├── roll_button_overlay.dart
│   └── ...
└── utils/                 # Utility functions
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/isto-game.git

# Navigate to project
cd isto-game

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
flutter test
```

## 🎨 Design Principles

- **Clean & Minimal**: No visual clutter
- **Professional**: Apple Arcade quality standards
- **Intuitive**: Zero ambiguity in game state
- **Responsive**: Immediate feedback for actions
- **Subtle Animations**: Enhance clarity, not distract

## 📱 Platforms

- Android ✅
- iOS ✅
- Web ✅
- Windows ✅
- macOS ✅
- Linux ✅

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Traditional ISTO game from Gujarat, India
- Flame game engine community
- Flutter team
