# ISTO Game Assets

## Sound Effects Required

For full audio experience, add the following sound files to this folder:

1. `roll.mp3` - Cowry shells rolling/rattling sound
2. `settle.mp3` - Shells landing/settling
3. `tap.mp3` - Pawn selection tap
4. `move.mp3` - Pawn sliding sound
5. `enter.mp3` - Pawn entering board
6. `capture.mp3` - Dramatic capture/hit sound
7. `grace.mp3` - Special roll (Chowka/Ashta) fanfare
8. `extra.mp3` - Extra turn notification
9. `finish.mp3` - Pawn reaching home
10. `win.mp3` - Victory celebration
11. `blocked.mp3` - No valid moves
12. `error.mp3` - Invalid action

## Recommended Sources for Free Game Sounds

- [Freesound.org](https://freesound.org/)
- [OpenGameArt.org](https://opengameart.org/)
- [Pixabay](https://pixabay.com/sound-effects/)
- [Zapsplat](https://www.zapsplat.com/)

## Notes

The game will still work without sound files - it uses haptic feedback as the primary feedback mechanism. Sound is supplementary.

Currently, the AudioService is configured to print sound names to console in debug mode, which helps during development without actual audio files.
