# ISTO GAME — Flutter App UI/UX Design Guidelines
### A Complete Design System for Chowka Bara / Ashta Chamma / Isto

> *Document Type: Senior UI/UX + Product Design Specification*
> *Scope: Visual Design, Theming, Animation, Micro-interactions — NOT Business Logic*

---

## TABLE OF CONTENTS

1. Game Context & Design Philosophy
2. Color System & Themes
3. Typography System
4. Splash Screen
5. Home Screen / Main Menu
6. Game Board — The 5×5 Grid
7. Player Pieces (Pawns / Coins)
8. The Cowry Shell — Design & Animation
9. Piece Movement Animation
10. Kill / Cut Animation
11. Safe Square & Home Square Visual Design
12. Player HUD & Scoreboard
13. Turn Indicator
14. Victory / Defeat Screen
15. Micro-interactions Catalogue
16. Haptics & Sound UI Cues
17. Responsive Layout Rules
18. Component Design Notes (Buttons, Modals, Toasts)
19. Accessibility Notes
20. Design Tokens Summary

---

## 1. GAME CONTEXT & DESIGN PHILOSOPHY

### What Isto Is
Isto (also called Chowka Bara, Ashta Chamma, Chauka Bara) is one of India's oldest strategy-chance board games. It originates from Gujarat (specifically popular in Ahmedabad) and is a direct ancestor of Ludo. The game is played on a **5×5 grid** with 4 players, each controlling 4 pawns, moving **anticlockwise** in the outer ring and **clockwise** in the inner ring, aiming to reach the center. The "dice" are **4 cowry shells**, which is the game's most iconic and culturally distinct element.

The game's soul is:
- **Nostalgic** — played on cloth mats, wooden boards, under evening light
- **Community-driven** — loud, social, family-friendly
- **Tactile** — the sound and throw of cowries is central to the experience
- **Ancient** — this game is referenced in the Mahabharata era

### Design Philosophy: "Digital Cloth Mat"
The entire design language must feel like you've lifted a traditional cloth Isto mat off the floor and digitised it — not gamified it like a casino app, not over-polished it into oblivion. The goal is:

- **Warm, not cold.** Wood tones, ivory, deep reds.
- **Minimal, not sparse.** Every element earns its place.
- **Playful, not cringe.** No cartoonish mascots. No bouncing coins.
- **Cultural, not cliché.** No generic "Indian pattern overload." Restraint.
- **Tactile feel through motion.** Animations should feel physical, weighted.

### Design Inspirations to Study
- Traditional Indian textile weave patterns (subtle grid texture)
- Kerala wooden carved game boards (earth tones, engraved feel)
- The visual grammar of old hand-woven Patta fabric games
- The minimalism of games like Monument Valley and Alto's Odyssey (restraint in UI)
- The cultural warmth of Google's Material You + earthy Indian tones

---

## 2. COLOR SYSTEM & THEMES

### Core Palette — "Terracotta Dusk" (Default / Dark Theme)

This is the primary theme. Rich, warm, dim-lit. Feels like playing at dusk.

| Token Name               | Hex       | Usage                                        |
|--------------------------|-----------|----------------------------------------------|
| `bg-primary`             | `#1A1209`  | App background, darkest base                |
| `bg-surface`             | `#2B1E0F`  | Board background, cards, panels             |
| `bg-elevated`            | `#3D2A14`  | Modals, elevated panels                     |
| `board-cell`             | `#4A3320`  | Default empty grid cell                     |
| `board-cell-alt`         | `#3C2A18`  | Alternating cell (chess-pattern subtle)      |
| `board-line`             | `#6B4C2A`  | Grid lines between cells                    |
| `accent-primary`         | `#E8A44A`  | Cowry highlight, active borders, CTA buttons|
| `accent-warm`            | `#D4763A`  | Secondary accent, hover states              |
| `accent-glow`            | `#FFD98A`  | Glow, active pawn ring, winning shimmer     |
| `text-primary`           | `#F5E6C8`  | Main text, headings                         |
| `text-secondary`         | `#A8865A`  | Subtitles, labels, inactive text            |
| `text-muted`             | `#6B5240`  | Placeholder, disabled text                 |
| `success`                | `#4CAF73`  | Safe square, home arrival confirmation      |
| `danger`                 | `#E05252`  | Kill/cut event highlight                    |
| `safe-square`            | `#2D5A3D`  | Safe square fill                            |
| `safe-square-border`     | `#4CAF73`  | Safe square stroke/cross marker            |
| `center-home`            | `#3A1A05`  | Center square (home destination) fill       |
| `center-home-glow`       | `#FFD98A`  | Center square active glow                  |

### Player Piece Colors

Each of the 4 players gets a distinct, rich color. These must be distinct at a glance, even in peripheral vision. Avoid primary red/green/blue/yellow — they're too Ludo-generic. Use more heritage tones:

| Player   | Piece Color | Hex       | Shadow/Glow Hex  |
|----------|-------------|-----------|------------------|
| Player 1 | Crimson     | `#C0392B` | `#E85444`        |
| Player 2 | Cobalt      | `#1B4F9C` | `#3A73D4`        |
| Player 3 | Forest      | `#2E7D4F` | `#4DB377`        |
| Player 4 | Saffron     | `#C07A00` | `#F0A820`        |

### Light Theme — "Ivory Noon" (Optional / Toggle)

| Token Name        | Hex       | Usage                                  |
|-------------------|-----------|----------------------------------------|
| `bg-primary`      | `#FDF6EC`  | App background                        |
| `bg-surface`      | `#F0DFC0`  | Board background                      |
| `board-cell`      | `#E8CFA0`  | Default cell                          |
| `board-cell-alt`  | `#D6BB8A`  | Alternate cell                        |
| `accent-primary`  | `#A0530A`  | Active elements                       |
| `text-primary`    | `#2A1A08`  | Main text                             |
| `board-line`      | `#B89060`  | Grid lines                            |

**Rule:** Never switch palettes mid-session. Theme is chosen once (system preference default) and stays.

---

## 3. TYPOGRAPHY SYSTEM

### Typeface Strategy

Use **two fonts only.** Any more and the game feels cluttered.

**Primary — Poppins (Heading, UI, Scores)**
- Weight in use: 400, 600, 700
- Why: Geometric, clean, South Asian-friendly letterforms. Available on Google Fonts.
- Usage: All headings, player names, score numbers, button labels

**Secondary — Lora (Cultural accents only)**
- Weight in use: 400, 600 (Italic for special moments)
- Why: Serif with warmth — reads like a manuscript. Use sparingly.
- Usage: "Isto" game logo text on splash, victory messages, any "cultural flavor" text

**Do NOT use:**
- Comic Sans / bubbly gaming fonts (cringe)
- Decorative Hindi/Gujarati-inspired fonts (unless you have native script support — don't fake culture)
- System fonts (inconsistent across platforms)

### Scale (in Flutter sp units)

| Role                  | Font       | Size  | Weight | Color Token          |
|-----------------------|------------|-------|--------|----------------------|
| App Title (Splash)    | Lora       | 40sp  | 600    | `accent-glow`        |
| Screen Title          | Poppins    | 24sp  | 700    | `text-primary`       |
| Section Label         | Poppins    | 16sp  | 600    | `text-primary`       |
| Body / Rules text     | Poppins    | 14sp  | 400    | `text-secondary`     |
| Score / Big Number    | Poppins    | 32sp  | 700    | `accent-primary`     |
| Cowry count display   | Poppins    | 28sp  | 700    | `accent-glow`        |
| Player name label     | Poppins    | 12sp  | 600    | player color token   |
| Small caption / note  | Poppins    | 11sp  | 400    | `text-muted`         |

### Letter Spacing Rules
- Headings: `letterSpacing: 0.5` (open, airy)
- Labels: `letterSpacing: 1.0` (especially ALL-CAPS labels like "YOUR TURN")
- Game title: `letterSpacing: 2.5` (grand, stamp-like)
- Body: `letterSpacing: 0.2` (normal readability)

---

## 4. SPLASH SCREEN

### Concept: "The Cloth Mat Unrolls"

The splash screen should feel like you're unrolling a traditional game mat on the floor. This is the game's first impression — make it cultural and weighted.

### Visual Composition

**Background:** `bg-primary` (#1A1209) — near-black warm brown. Full bleed.

**Center Animation Sequence (0ms → 2200ms total):**

1. **0ms:** Black screen. Silence in design.
2. **200ms:** A faint grid pattern fades in — like the cloth mat texture materialising. Use a very subtle repeating SVG pattern of thin lines (opacity goes 0% → 6%). It's subconscious, not obvious.
3. **400ms:** The 5×5 board center cell illuminates first — a soft golden bloom radiates outward (`accent-glow`, bloom radius expands from 0dp → 40dp, over 400ms, `Curves.easeOut`).
4. **600ms:** The full board grid draws itself. Each row of grid lines animate in from center outward (line draw animation, stroke-dashoffset technique). Duration: 300ms. Easing: `Curves.decelerate`.
5. **900ms:** The 4 safe squares (corner cross marks) appear with a brief pulse — a ring expands from each and disappears (`safe-square-border` color, 150ms pulse).
6. **1100ms:** The game title appears. **"ISTO"** — rendered in Lora, 40sp, `accent-glow` color. Animate: `FadeTransition` + very slight upward slide (`dy: 8 → 0`, 400ms, `Curves.easeOutCubic`). Below it, smaller: *"Chowka Bara"* or a regional subtitle in Poppins 12sp `text-muted` with letter-spacing 2.0. Fade in 200ms delayed.
7. **1600ms:** A single cowry shell icon (custom SVG) drops from above the title, bounces once (like a real shell landing on a wooden board), and settles below the title as a subtle logo accent. The bounce: `BounceInDown`-like curve — fast drop, one natural bounce, settle. Shell is ivory-white with a faint warm shadow.
8. **2200ms:** Fade to Home Screen (crossfade 300ms).

### Splash Screen Do Nots
- No loading bar (binary: content loads or it doesn't)
- No app version number (save for settings)
- No tagline ("Play with family!") — let the board speak
- No mascot or anthropomorphic character
- No neon glow — keep glow warm gold only

### Logo Mark
The "ISTO" wordmark should have a subtle **cross/X mark** incorporated — either as a dot on the "I" replaced by a tiny cross (referencing the safe squares on the board) or as a small cross symbol between "IS" and "TO." This ties the logo directly to the game's identity. Keep it minimal — it should be noticed on second look, not screamed.

---

## 5. HOME SCREEN / MAIN MENU

### Layout: Clean Vertical Stack, Board-Centric

The board should always be visible in the home screen — small, centered, decorative, like a table centerpiece. This creates context: you always know what you're about to play.

**Structure (top to bottom):**

1. **Top Bar (56dp height):** Game logo left-aligned ("ISTO" wordmark, 20sp), Settings icon (gear/cog, right-aligned, `text-secondary` color). No hamburger menu. No cluttered top bar.
2. **Decorative Mini Board (200dp × 200dp):** A non-interactive, decorative render of the 5×5 board floating in the center of the screen. Rotate it slightly — exactly 45° (diamond orientation, like a board placed casually on a table). Apply a subtle ambient glow behind it. This is purely aesthetic.
3. **4 Cowry Shell Icons** arranged in a gentle arc below the mini board, as a decorative element — like shells just thrown and settling.
4. **Action Buttons (vertical stack, center-aligned, full-width within 320dp container):**
   - `[PLAY]` — Primary CTA. Filled button. `accent-primary` background. Poppins 16sp 700. Letter spacing 2.0. Corner radius 12dp. Height 56dp.
   - `[HOW TO PLAY]` — Outlined button. `accent-primary` border, transparent fill. Same sizing.
   - `[SETTINGS]` — Ghost button (text only, no border). `text-secondary`.

5. **Bottom Subtle Element:** A single thin horizontal decorative line (`board-line` color, 1dp height, 80dp wide) centered at the very bottom. Nothing else. No footer navigation bar for a single-feature app.

### Atmosphere
- The background should have a very faint texture — use a custom `ShaderMask` or `BackdropFilter` with an SVG noise texture to mimic old cloth/canvas. Opacity: 4–6% only.
- Avoid status bar color clash: set `SystemUiOverlayStyle` to match `bg-primary`.

---

## 6. GAME BOARD — THE 5×5 GRID

This is the centrepiece of the entire application. Every design decision here must be deliberate.

### The Board's Anatomy (What We're Designing)

The 5×5 grid has 25 cells. Key special cells are:

| Cell Position      | Type              | Visual Treatment                      |
|--------------------|-------------------|---------------------------------------|
| (0,2) Top-center   | Safe Square / P1 Start | Cross mark, `safe-square` color   |
| (2,4) Right-center | Safe Square / P2 Start | Cross mark                        |
| (4,2) Bottom-center| Safe Square / P3 Start | Cross mark                        |
| (2,0) Left-center  | Safe Square / P4 Start | Cross mark                        |
| (2,2) Center       | Home / Destination | Star or target mark, golden glow   |
| All other 20 cells | Normal path cells  | Uniform base color                |

### Grid Proportions

- The board should be **square** and take up the **maximum available width** on screen, leaving only a minimum 16dp padding on each side.
- For a 390dp wide device: board = 390 − 32 = 358dp → each cell = ~71dp × 71dp
- Board is always centered horizontally and positioned in the upper 60% of the screen (below the HUD and above the cowry throw zone).
- Corner radius of the full board container: `16dp`
- Board has a `BoxDecoration` with a subtle wooden texture (dark brown, slightly embossed). Use a `DecorationImage` with a seamless wood grain asset at very low opacity, or a programmatic gradient.

### Cell Design

**Normal Cell:**
- Fill: alternating `board-cell` and `board-cell-alt` in a subtle checkerboard pattern. The contrast between the two should be very low (ΔL ~5% in HSL) — not obvious, but perceptible up close. This gives texture without distracting from pieces.
- Border: 1dp `board-line` color on all sides
- Corner radius: 0dp — cells butt up against each other cleanly

**Safe Square Cell (4 corner-midpoints + center):**
- Fill: `safe-square` color (dark green tint)
- Overlay: a drawn **"X" cross** mark in the center of the cell. Stroke width: 2dp. Color: `safe-square-border`. The cross is NOT a background pattern — it's drawn on top, suggesting engraving.
- The safe square should have a barely perceptible inner glow (`safe-square-border` at 15% opacity as a radial gradient center fill).
- No animation when idle — safe squares are static, trustworthy-looking.

**Home / Center Cell (2,2):**
- Fill: `center-home` color (very deep, near-black brown)
- Overlay: a **4-pointed star / asterisk / Chowka mark** drawn at center. Stroke width 2.5dp. Color: `accent-glow`. This references the traditional "Chowka" mark (asterisk cross shape used in the original game).
- Idle state: A very slow, continuous pulse animation — the center star pulses `opacity: 0.6 → 1.0 → 0.6` over 3 seconds on a loop. This draws attention to the goal without being annoying.
- When a piece enters: brief gold bloom (described in animation section).

### Grid Lines
- All grid lines are `1dp` width, color `board-line`.
- The outer border of the entire board is `2.5dp` width, same color but 20% brighter (`#8A6035`).
- The lines should look *engraved*, not painted. Achieve this with a subtle inner shadow on the board container.

### Board Orientation
- The board always stays in **square orientation** (not rotated 45°).
- Each player's "home side" is visually implied by the safe square color — the safe square on each side belongs to that player and can have a faint tint of their player color.
- For 4-player game: P1 = top, P2 = right, P3 = bottom, P4 = left.

### Board Elevation & Depth
- The board should appear to float slightly off the background. Use `BoxShadow` with:
  - Offset: `(0, 8)`
  - Blur: `24dp`
  - Color: `Colors.black.withOpacity(0.5)`
  - A second shadow for ambient: offset `(0, 2)`, blur `6dp`, color `Colors.black.withOpacity(0.3)`
- This floating effect makes the board feel like a physical object on the table.

---

## 7. PLAYER PIECES (PAWNS / COINS)

### Physical Reference
Traditional Isto pieces are smooth, flat stones or carved wooden tokens — round discs, often two-tone. The digital design should echo this: **flat disc, NOT 3D cylinder**.

### Piece Design Anatomy

Each piece is a **circular widget, 60–70% of a cell's size** (so ~42–50dp for a 71dp cell).

**Layers from bottom to top:**

1. **Shadow layer:** `BoxShadow` beneath the disc — `(0, 3)`, blur `8dp`, `player-color.withOpacity(0.5)`. This makes pieces look like they're sitting on the board.
2. **Base disc:** Filled circle. Color = player's piece color. Slight radial gradient from center (lighter, ~15% lighter) to edge (exact color). This mimics a polished stone catching light.
3. **Inner ring:** A thin ring (2dp stroke) inside the disc edge, in a slightly lighter shade of the player color. This is the "carved groove" detail, referencing traditional carved pieces.
4. **Symbol:** A small, centered symbol unique to each player (optional but elevated). Suggestions:
   - P1 (Crimson): A simple upward triangle (▲)
   - P2 (Cobalt): A small circle (○)
   - P3 (Forest): A diamond (◆)
   - P4 (Saffron): A cross/plus (+)
   These are Poppins or custom SVG symbols, ~14sp, white color, slightly transparent (0.8 opacity).
5. **Active ring (only when it's your turn and piece is selectable):** An animated dashed ring outside the disc — color `accent-glow`, stroke-dasharray animated to rotate slowly. It's like the piece is "breathing." Only visible when the piece is interactive.

### Piece States

| State           | Visual Change                                                                |
|-----------------|------------------------------------------------------------------------------|
| `idle`          | Base disc only, shadow present                                               |
| `selectable`    | + Animated rotating dashed ring (accent-glow), slight scale: 1.05           |
| `selected`      | + Scale: 1.15, ring becomes solid (not dashed), brief pulse on click         |
| `moving`        | Animated along path (see movement section), shadow trails slightly            |
| `at-home`       | Greyed out, at starting position. Base color desaturated ~50%                |
| `at-center`     | Piece "sinks" into center with a golden absorption animation and disappears   |
| `killed`        | Brief shatter-scatter then disappears back to start (see kill animation)      |
| `safe`          | Small green dot appears below the piece (on the safe cell, not on piece)      |

### Multiple Pieces on Same Cell
In traditional Isto, a "safe square" can hold multiple pieces. Show stacked pieces as an offset cluster:
- If 2 pieces: slightly offset left-right by 30% of piece size
- If 3+ pieces: small stack overlap with a badge counter (e.g., "×3") in `accent-glow` color, Poppins 10sp
- Never overlap pieces completely — always maintain some visual distinction

---

## 8. THE COWRY SHELL — DESIGN & ANIMATION

This is the most culturally important element. The cowry shell IS the dice. It deserves the most care.

### Visual Design of One Cowry Shell

A cowry shell is a small oval shell with a distinctive **toothed slit** on the underside. It's ivory-white to cream colored, with subtle brownish-tan banding.

**SVG-based design (not emoji, not generic dice):**
- Shape: oval, wider in middle, tapered at ends
- Color: `#F5F0E0` base (ivory), subtle `#C4A882` for the bands
- The "mouth" (slit/teeth side): rendered as a horizontal line with small vertical notch marks — this determines face-up vs face-down
- Face-up (mouth visible / value = 1): slit side up, slightly open appearance
- Face-down (back side visible / value = 0): smooth dome side up

Create this as a Flutter `CustomPainter` or SVG asset. It must be crisp, not a photo texture.

### Cowry Throw Area Design

Position: **Below the board**, in a dedicated "throw zone" — a roughly rectangular region (280dp × 100dp), with a very subtle `bg-elevated` fill and rounded corners (20dp). Faint inset shadow.

When idle: 4 cowry shells displayed in a loose casual arrangement inside this zone — like they're sitting on the mat between throws. Small, ~24dp each, at slightly random angles (±15° rotation for each). Not perfectly aligned.

**Throw Zone Label (above the zone):** "THROW" in Poppins 10sp, letter-spacing 2.0, `text-muted` color. Disappears during animation. Returns when waiting.

### Cowry Throw Animation — This Is The Show

When the player taps the throw zone, this sequence plays:

**Phase 1 — Gather (0–150ms):**
All 4 shells animate toward the center of the throw zone — like being gathered into a hand. Scale down to 0.7×, slight rotation toward center. `Curves.easeIn`.

**Phase 2 — Shake (150–550ms):**
A "cupped hands shake" effect — the 4 shells vibrate as a group. Implement as a rapid `shake` translation animation (random dx ±4dp, dy ±4dp every 50ms, 8 cycles). Scale stays at 0.7×. This is where you play the haptic buzz (`HapticFeedback.heavyImpact()` at start, light buzz during).

**Phase 3 — Scatter / Throw (550–900ms):**
The shells scatter outward from center. Each shell:
- Animates to a **randomised final position** within the throw zone (pre-calculated at throw-start, different each time)
- Rotates to a **random final angle** (pre-calculated, 0°–360°)
- Follows a `Curves.bounceOut` easing — fast initial, then a little bounce as they "land"
- Scale returns to 1.0×

The landing moment for each shell is slightly staggered (0ms, 60ms, 120ms, 180ms offsets) so they don't all land simultaneously. This makes it feel like a real throw where shells land one by one.

**Phase 4 — Settle (900–1100ms):**
Each shell has a tiny final "rock" — it rotates ±3° twice quickly (like a spinning coin settling). Then freezes.

**Phase 5 — Result Display (1100ms+):**
- Shells in their landed state are now clearly "face up" (slit visible) or "face down" (dome visible), based on the game's computed result
- The count badge appears above the throw zone: a large number in Poppins 28sp, `accent-glow` color, with a `ScaleTransition` pop (scale 0.5 → 1.2 → 1.0, over 300ms)
- If result is 4 or 8 (bonus turn): the count badge pulses gold, and a subtle "BONUS TURN" text appears below in Poppins 11sp, `accent-primary` color, with a `SlideTransition` up
- If result is 8 (ashta — all face down): a very brief warm glow radiates from the throw zone. All shells have a faint golden outline for 600ms.
- If result is 4 (chamma — all face up): similar but slightly smaller glow.

### Cowry "Tap to Throw" Feedback
Before the throw, the throw zone has a gentle "breathing" idle animation — scale 1.0 → 1.02 → 1.0 over 2 seconds, looping. This signals "tap me." Stop it the moment the throw begins.

---

## 9. PIECE MOVEMENT ANIMATION

When a pawn moves N squares, the animation must follow the board path — not jump directly from start to end.

### Movement Style: "Hop Along Path"

**Principle:** Each square-to-square move is a small arc ("hop"), not a straight slide. The piece lifts slightly off the board and lands on the next cell. This mimics the tactile feeling of physically picking up and placing a stone.

### Per-hop Animation (each cell transition):

1. **Lift phase (0–80ms):** Piece scales from 1.0 → 1.1 and translates upward by `−8dp`. `Curves.easeOut`.
2. **Arc phase (80–160ms):** Piece follows a parabolic path to the next cell (parametric arc — not a straight line). At arc peak, shadow below piece stretches and lightens (simulating height).
3. **Land phase (160–220ms):** Piece scales 1.1 → 0.92 → 1.0 (squash on landing), and shadow snaps back. `Curves.elasticOut` for the squash.

**Timing per hop:** ~220ms total. For a 3-square move, total animation = ~660ms.

**Between hops:** No pause. Each hop chains immediately after the previous one. If moving more than 5 squares, slightly reduce per-hop time to 170ms to keep it snappy.

**Shadow during movement:** The piece shadow follows but with a 40ms delay — it lags slightly behind, making the height illusion stronger.

**Trail effect (optional, subtle):** A faint afterimage trail of the piece (opacity 20%, decreasing) following 1 cell behind. Use `FadeTransition` on a ghost copy of the piece widget. This is subtle — if it looks too busy, remove it.

### Inner Ring Transition Animation
When a piece crosses from the outer path (anticlockwise) to the inner path (clockwise), there should be a **direction-change signal**:
- Brief white flash on the piece (opacity 0 → 0.6 → 0, 200ms)
- A small "rotation" of the symbol on the piece — it spins 360° in 300ms, confirming direction change
- The piece leaves a tiny "turn marker" fade: a small circular ripple at the transition cell

---

## 10. KILL / CUT ANIMATION

The "kill" is the most dramatic moment in the game. It needs weight.

### Sequence:

1. **Impact moment (0–100ms):**
   - The attacking piece slides into the cell. On contact: screen micro-shake (`dx: 0→4→−4→2→−2→0`, 80ms, `Curves.easeInOut`). Very subtle — 4dp max. Not jarring.
   - The killed piece flashes `danger` color (#E05252) — its fill color transitions from player-color → `danger` → transparent over 200ms.

2. **Scatter effect (100–400ms):**
   - The killed piece "breaks" into 3–4 small circular fragments (small dots, 8–12dp, player color). These scatter outward from the kill position using particle animation — each fragment has a randomised velocity vector (outward), travels ~30–50dp, and fades to transparent. `Curves.decelerate` for fragment trajectory.
   - NOT an explosion with sparks. Very restrained — it looks like a stone skittering across the mat, not a fireworks show.

3. **Return journey (400–700ms):**
   - The killed piece re-materialises at its home starting position with a `FadeIn` + scale `0 → 1.0`, 300ms.
   - A brief grey ring pulses once around the returned piece (like "you're back at start").

4. **Attacker triumph (0–600ms, concurrent):**
   - The attacking piece's active ring (if still shown) briefly intensifies — brighter glow for 400ms.
   - If it's a bonus turn (kills always grant bonus): the "BONUS TURN" toast appears.

### Kill Toast
A non-blocking toast at the top of the game screen (below the HUD): 
- Background: `danger` color (#E05252), 80% opacity, `BackdropFilter` blur
- Text: "[Player Name] captured!" — Poppins 13sp, white
- Appears from top (`SlideTransition` from -100% → 0), auto-dismisses in 1800ms, slides back up
- Never blocks the board

---

## 11. SAFE SQUARE & HOME SQUARE VISUAL DESIGN

### Safe Square — Idle State
- Cell fill: `safe-square` (#2D5A3D) — a muted, heritage green. Not neon. Not loud.
- Cross mark: drawn with `CustomPainter` as two diagonal lines crossing at cell center. Stroke: 2dp, `safe-square-border` color.
- Subtle glow: a very faint radial gradient at cell center — `safe-square-border` at 10% opacity.

### Safe Square — When Piece Is Present
- The cross mark doesn't disappear — it remains visible *under* the piece.
- A small green dot indicator appears at the bottom edge of the piece (like a status dot on an avatar) — 6dp, `safe-square-border` color. This reassures players "I'm safe here."
- The cell gets a very faint pulsing glow: `safe-square-border` at opacity cycling `0.05 → 0.15 → 0.05` over 2 seconds.

### Safe Square — When Opponent Tries to Enter (UI feedback only)
- Cell briefly shakes: `dx: 0→3→−3→0`, 200ms
- A small red X fades in over the cell (not the piece) and fades out within 300ms — communicating "access denied"

### Home / Center Square
- Resting state: the 4-pointed asterisk mark pulses slowly as described in section 6.
- When a piece approaches (1 square away): the center glow intensifies, and the asterisk rotates slowly at 1 revolution per 4 seconds.
- When a piece enters and wins: **golden light bloom** — a radial gradient erupts from the center cell, expanding to cover the full board momentarily, then recedes. The piece "sinks" into the center (scale 1.0 → 0.7 → 0, with a bright `accent-glow` flash). A "coin-absorbed" sound cue.
- After 4 pieces enter (player wins): see Victory Screen.

---

## 12. PLAYER HUD & SCOREBOARD

### Position: Top strip, above the board

Layout: A 4-player info strip split across the top of the game screen. On a phone, use a 2×2 grid layout for the 4 players — two players on top, two on bottom (or all four across if landscape).

### Player Card Design

Each player gets a compact card widget:

- **Size:** ~88dp wide × 64dp tall
- **Background:** `bg-surface` with a 2dp left border in the player's color
- **Content:**
  - Player avatar: A simple circular icon (16dp radius) in the player's color
  - Player name: Poppins 12sp, `text-primary`, single line truncated
  - Piece count: A row of 4 small circular indicators (8dp each) showing how many of their 4 pieces have reached home (filled = reached home, hollow = in play, greyed = at starting position)
  - Nothing else. No points. No timers on the card.

### Active Player Indicator
When it's a player's turn:
- Their player card gets a `border: 2dp solid player-color` on all sides (normally only left border)
- A subtle `BoxShadow` of `player-color.withOpacity(0.4)`, spread 2dp, blur 8dp
- The player's name briefly scales `1.0 → 1.08 → 1.0` when it becomes their turn (single beat pulse)
- A small animated "turn arrow" (►) appears next to their name — color = `accent-primary`, subtle bounce

### Piece Count Indicators
These 4 small circles on each player card are the most informative elements on the HUD:
- **Grey fill, solid:** Piece is at home/starting position (not yet released)
- **Player-color fill, outlined:** Piece is on the board (active)
- **Gold fill (`accent-glow`):** Piece has reached the home center (done)
- **Red fill (`danger`):** Piece was just killed (fades back to grey after 1s)

---

## 13. TURN INDICATOR

A small persistent overlay at the bottom of the board (between board and cowry zone):

- Design: A pill-shaped badge (width ~140dp, height 32dp, `bg-elevated` fill, `border-radius: 16dp`)
- Content: Colored dot (player color, 8dp) + "YOUR TURN" or "[Name]'s Turn" in Poppins 11sp, letter-spacing 1.5
- Animation on turn change: The badge slides out to the left (300ms `Curves.easeIn`) and the new one slides in from the right (300ms `Curves.easeOut`)
- During AI thinking (if applicable): badge shows a pulsing ellipsis `...` animation

---

## 14. VICTORY / DEFEAT SCREEN

### Victory Screen

**Concept:** Like throwing confetti on a cloth mat — festive but not chaotic.

**Background:** Full screen `bg-primary` darkened further with a radial gradient. A confetti/particle system rains from top — but NOT generic circle confetti. Use **tiny cowry shell icons** (8–12dp) and **small diamond shapes** in the player's color. Max 40 particles. They drift down at varying speeds, tumbling gently. `Opacity 0.7–1.0`. Stop after 4 seconds.

**Center Card:** A modal-style card (`bg-elevated`, corner-radius `24dp`, `BoxShadow` heavy) with:
- Crown or star SVG icon (40dp) in `accent-glow` color
- "Victory!" in Lora 36sp italic, `accent-glow` color, fade-in + slight bounce
- Player's name in Poppins 18sp 600, their player color
- 4 gold-filled piece indicators in a row (all reached home)
- Divider line (`board-line` color)
- Time taken / moves count (optional, subtle, Poppins 12sp `text-muted`)
- `[PLAY AGAIN]` button (filled, `accent-primary`)
- `[MAIN MENU]` text button (`text-secondary`)

### Defeat Screen
Same structure but:
- No confetti
- Background slightly desaturated
- Icon: A simple unfilled crown or hourglass
- Text: "Better Luck!" in Poppins (not Lora — Lora only for winners)
- Their pieces shown as incomplete (not all gold)

---

## 15. MICRO-INTERACTIONS CATALOGUE

Every tap, state change, and transition should have a micro-interaction. This is what separates a good game UI from a great one.

| Trigger                        | Micro-interaction                                                                |
|--------------------------------|----------------------------------------------------------------------------------|
| Button press (any)             | Scale `1.0 → 0.95` on press, `0.95 → 1.0` on release. 80ms each.               |
| Piece tap (selectable)         | Brief ripple effect (`InkWell`), scale pulse `1.0 → 1.15 → 1.0`, 200ms           |
| Piece tap (not selectable)     | Horizontal micro-shake `±3dp`, 150ms. Communicates "not your turn / can't select" |
| Safe square hover/tap          | Cell brightens `+15% lightness` for 150ms, then returns                          |
| Cowry zone idle                | Breathing scale `1.0 ↔ 1.02`, 2s loop, sinusoidal easing                        |
| Cowry throw tap                | Gather → shake → scatter sequence (see section 8)                               |
| Bonus turn granted             | Golden ring ripple from score badge, "BONUS" text slides up from below          |
| Score number changes            | Number counts up/down with `AnimatedSwitcher` + vertical flip, 400ms            |
| Player card becomes active     | Left border pulses from 2dp → 4dp → 2dp, border color brightens, 300ms          |
| Settings panel open            | Bottom sheet slides up (`DraggableScrollableSheet`), backdrop blurs             |
| Screen transition (any)        | `FadeTransition` + very slight scale `0.98 → 1.0`, 250ms                        |
| Kill confirmed                 | Screen micro-shake 4dp, 80ms (see kill animation)                               |
| Home arrival (center reached)  | Center cell gold bloom, piece absorption animation                               |
| Error / invalid action         | Red pulse on the invalid element + gentle 2-cycle shake                         |

---

## 16. HAPTICS & SOUND UI CUES (Design Perspective)

Sound is outside the scope of game logic but it's a UI signal. Design them as functional UI responses:

| Event                  | Haptic Type                          | Sound Character (describe, not implement)     |
|------------------------|--------------------------------------|-----------------------------------------------|
| Cowry shake            | `HapticFeedback.heavyImpact()`       | Rattling / shuffling shells in cupped hands   |
| Cowry land (each one)  | `HapticFeedback.selectionClick()`    | A single small click per shell on wood        |
| Piece move (each hop)  | `HapticFeedback.lightImpact()`       | Soft wooden 'tock' — like placing a stone     |
| Kill / capture         | `HapticFeedback.heavyImpact()`       | Sharp wooden crack                            |
| Bonus turn granted     | `HapticFeedback.mediumImpact()`      | Two quick ascending tones                     |
| Home / center arrival  | `HapticFeedback.heavyImpact()`       | Satisfying resonant bell tone (warm, not shrill)|
| Victory                | Pattern: heavy + 200ms gap + heavy   | Rising flourish, culturally flavored          |
| Button tap             | `HapticFeedback.selectionClick()`    | Soft click                                    |
| Invalid action         | `HapticFeedback.vibrate()` — 3 short | Low buzz / error tone                         |

**Rule:** Never use sound without a visual counterpart. Never use haptics during opponent's turn. Always respect OS sound/haptic settings.

---

## 17. RESPONSIVE LAYOUT RULES

### Phone Portrait (Primary Target)
- Board occupies 80–85% of screen width
- HUD above board, 4 player cards in 2×2 or 1×4 layout
- Cowry throw zone below board
- Turn indicator between board and throw zone

### Phone Landscape
- Board stays square, positioned left-center
- HUD moves to right side: 4 player cards stacked vertically
- Cowry throw zone below the HUD column (right side)
- Maximum board size: screen height minus safe area insets

### Tablet Portrait
- Board centered, max size 520dp × 520dp
- HUD above board
- More breathing room between all elements

### Tablet Landscape
- Board centered, HUD above
- Additional decorative space on sides — can place a subtle decorative Isto border pattern (traditional cross-hatch border motif, subdued, not overwhelming)

### Small Phone (< 360dp width)
- Reduce board to 92% screen width
- Compress HUD player cards: 2-row layout, hide piece count indicators, show only player color + name
- Reduce font sizes by 1sp tier

---

## 18. COMPONENT DESIGN NOTES

### Buttons

**Primary Button (filled):**
- Height: 52dp
- Corner radius: 12dp
- Background: `accent-primary` (#E8A44A)
- Text: Poppins 14sp 700, `bg-primary` color (dark text on warm gold)
- State pressed: background → `accent-warm`, scale 0.95
- State disabled: opacity 0.4, no haptic on press

**Secondary Button (outlined):**
- Same dimensions
- Border: 1.5dp `accent-primary`
- Background: transparent
- Text: `accent-primary` color
- State pressed: background fills to `accent-primary` at 15% opacity

**Ghost Button (text only):**
- No border, no background
- Text: `text-secondary` color
- Pressed: background `text-secondary` at 10% opacity

### Bottom Sheet (Settings, How to Play)
- `DraggableScrollableSheet`: min 40%, initial 60%, max 90%
- Background: `bg-elevated`
- Drag handle: 4dp × 40dp rounded pill in `text-muted` color, centered at top
- Title: Poppins 16sp 700, `text-primary`
- Content: Poppins 14sp 400, `text-secondary`
- `BackdropFilter` (blur 8, saturation 0.8) on the backdrop overlay

### Toast / Snackbar
- Position: top of game screen (not bottom — bottom is the cowry zone)
- Width: screen width minus 32dp margins
- Height: auto, min 48dp
- Corner radius: 10dp
- Background: `bg-elevated` at 90% opacity + blur
- Text: Poppins 13sp, `text-primary`
- Auto-dismiss: 2000ms. Slide in from top (300ms), slide out upward (200ms)
- For important events (kill, bonus): tinted background (`danger` or `accent-primary` at 40%)

### Overlay / Dialog (confirmations)
- `BackdropFilter` blur 12 over the board
- Card: `bg-elevated`, corner radius 20dp, padding 24dp
- Content top-to-bottom: Icon → Title → Body text → Buttons
- Never dim the board to pure black — maintain the warm atmosphere

---

## 19. ACCESSIBILITY NOTES

- All interactive elements must have minimum `48dp × 48dp` touch targets
- Player color is never the ONLY identifier — always pair color with a shape symbol (the triangle/circle/diamond/cross on pieces)
- Text contrast ratio: minimum 4.5:1 against background (WCAG AA)
- All animations must respect `MediaQuery.disableAnimations` — if true, reduce all animations to simple fades (0 movement, 0 bounce)
- Cowry throw must be triggerable by a button (accessibility mode) — not only by tap gesture, so users with motor impairments can play
- Font sizes should scale with system `textScaleFactor` up to 1.3× (beyond that, clamp to prevent layout breaks)
- Language: All UI text should be externalized to an `l10n` ARB file — support Gujarati and English at minimum

---

## 20. DESIGN TOKENS SUMMARY

All values in one place — map these to Flutter `ThemeExtension` for clean implementation.

```
// Spacing
spacing-xs:     4dp
spacing-sm:     8dp
spacing-md:     16dp
spacing-lg:     24dp
spacing-xl:     32dp

// Radii
radius-sm:      8dp
radius-md:      12dp
radius-lg:      16dp
radius-xl:      24dp
radius-pill:    999dp

// Duration
anim-fast:      150ms
anim-normal:    250ms
anim-slow:      400ms
anim-very-slow: 600ms

// Board
cell-size:      device-dependent (board-width / 5)
piece-size:     cell-size × 0.65
cowry-size:     24dp (idle in zone)
cowry-size-lg:  36dp (during throw animation)

// Shadows
shadow-sm:      BoxShadow(offset:0,2, blur:6, color:rgba(0,0,0,0.3))
shadow-md:      BoxShadow(offset:0,4, blur:12, color:rgba(0,0,0,0.4))
shadow-lg:      BoxShadow(offset:0,8, blur:24, color:rgba(0,0,0,0.5))
```

---

## APPENDIX: WHAT NOT TO DO

A brief list of common UI mistakes to actively avoid in this app:

1. **Do NOT use a generic dice** — the cowry shell is the identity of this game
2. **Do NOT use neon colors** — they're culturally inconsistent with Isto's heritage
3. **Do NOT animate everything simultaneously** — stagger, layer, and prioritize
4. **Do NOT use generic Ludo-style board colors** — the red/green/blue/yellow quadrant Ludo board is not Isto
5. **Do NOT show ads as pop-ups during gameplay** — if monetized, use only between-game interstitials
6. **Do NOT over-texture** — one subtle texture (wood grain or cloth) is enough; layering multiple patterns creates visual noise
7. **Do NOT use drop shadows on text** — use color contrast instead
8. **Do NOT make the center home square the same as a safe square** — they have different game meanings and must look different
9. **Do NOT skip the cowry landing stagger** — simultaneous landing kills the physicality illusion
10. **Do NOT use `showDialog` for in-game events** — use contextual toasts and overlays to avoid interrupting flow

---

*End of Design Guidelines — Version 1.0*
*Designed for: Flutter (Dart) — Target: Android + iOS*
*Cultural Reference Region: Gujarat, India (Isto / Ahmedabad Baji)*
