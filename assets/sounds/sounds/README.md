# ISTO Game Sound Assets

## Current Sound Files ✓

The following sound files are installed and working:

| File | Description | Status |
|------|-------------|--------|
| `roll.mp3` | Cowry shells rolling/rattling sound | ✓ Installed |
| `move.mp3` | Pawn sliding/movement sound | ✓ Installed |
| `tap.mp3` | Pawn selection tap sound | ✓ Installed |
| `enter.mp3` | Pawn entering board sound | ✓ Installed |
| `blocked.mp3` | No valid moves sound | ✓ Installed |

## Optional Additional Sounds

For a richer audio experience, you can add these additional sounds:

| File | Description | Used For |
|------|-------------|----------|
| `capture.mp3` | Dramatic capture/hit sound | When capturing opponent pawns |
| `grace.mp3` | Special roll fanfare | CHOWKA (4) or ASHTA (8) rolls |
| `extra.mp3` | Extra turn notification | When extra turn is granted |
| `finish.mp3` | Pawn reaching home | When pawn reaches center |
| `win.mp3` | Victory celebration | When a player wins |

## Audio Settings

Players can toggle sound on/off from the in-game settings:
1. During gameplay, tap the **⚙️ Settings** button (top-right)
2. Toggle **Sound** on/off
3. Toggle **Vibration** on/off

## Technical Notes

- Audio is handled by the `audioplayers` package
- Sounds are preloaded on app initialization
- Sound plays alongside haptic feedback for better UX
- If a sound file is missing, the game falls back to haptic-only feedback

## Recommended Sources for Free Game Sounds

- [Freesound.org](https://freesound.org/)
- [OpenGameArt.org](https://opengameart.org/)
- [Pixabay](https://pixabay.com/sound-effects/)
- [Zapsplat](https://www.zapsplat.com/)
