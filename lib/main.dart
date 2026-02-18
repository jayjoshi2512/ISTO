import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/design_system.dart';
import 'theme/isto_tokens.dart';
import 'game/isto_game.dart';
import 'overlays/overlays.dart';
import 'services/feedback_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize feedback service (haptics + audio)
  await feedbackService.initialize();

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI to match bg-primary (Terracotta Dusk)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: IstoColorsDark.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ISTOApp());
}

class ISTOApp extends StatelessWidget {
  const ISTOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISTO - Chowka Bara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: IstoColorsDark.bgPrimary,
        colorScheme: ColorScheme.dark(
          primary: IstoColorsDark.accentPrimary,
          secondary: IstoColorsDark.accentWarm,
          surface: IstoColorsDark.bgSurface,
          error: IstoColorsDark.danger,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const SplashWrapper(),
    );
  }
}

/// Wrapper widget that shows splash screen first, then game
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }
    return const GameScreen();
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ISTOGame game;

  @override
  void initState() {
    super.initState();
    game = ISTOGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<ISTOGame>(
        game: game,
        overlayBuilderMap: {
          ISTOGame.turnIndicatorOverlay:
              (context, game) => TurnIndicatorOverlay(game: game),
          ISTOGame.winOverlay: (context, game) => WinOverlay(game: game),
          ISTOGame.menuOverlay: (context, game) => MenuOverlay(game: game),
          ISTOGame.stackedPawnDialogOverlay:
              (context, game) => StackedPawnDialog(
                game: game,
                stackedPawns: game.pendingStackedPawns ?? [],
                rollValue: game.currentRollValue,
                onChoice: (pawnCount) => game.onStackedPawnChoice(pawnCount),
              ),
          'extraTurn': (context, game) => ExtraTurnOverlay(game: game),
          'capture': (context, game) => CaptureOverlay(game: game),
          'noMoves': (context, game) => NoMovesOverlay(game: game),
          'settings': (context, game) => SettingsOverlay(game: game),
          'howToPlay': (context, game) => HowToPlayOverlay(game: game),
        },
        loadingBuilder:
            (context) => Container(
              decoration: const BoxDecoration(
                gradient: DesignSystem.bgGradient,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: DesignSystem.accent,
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading...',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        errorBuilder:
            (context, error) => Container(
              decoration: const BoxDecoration(
                gradient: DesignSystem.bgGradient,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: DesignSystem.textMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: DesignSystem.headingSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: DesignSystem.caption.copyWith(
                          color: DesignSystem.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
