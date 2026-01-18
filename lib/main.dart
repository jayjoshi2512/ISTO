import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Hide system UI for immersive experience
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  runApp(const ISTOApp());
}

class ISTOApp extends StatelessWidget {
  const ISTOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISTO - Chauka Bara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECCA3),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      home: const GameScreen(),
    );
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
          ISTOGame.rollButtonOverlay: (context, game) =>
              RollButtonOverlay(game: game),
          ISTOGame.turnIndicatorOverlay: (context, game) =>
              TurnIndicatorOverlay(game: game),
          ISTOGame.winOverlay: (context, game) => WinOverlay(game: game),
          ISTOGame.menuOverlay: (context, game) => MenuOverlay(game: game),
          'extraTurn': (context, game) => ExtraTurnOverlay(game: game),
          'capture': (context, game) => CaptureOverlay(game: game),
          'noMoves': (context, game) => _NoMovesOverlay(game: game),
        },
        loadingBuilder: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF4ECCA3),
              ),
              SizedBox(height: 24),
              Text(
                'Loading ISTO...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        errorBuilder: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple no moves overlay
class _NoMovesOverlay extends StatelessWidget {
  final ISTOGame game;
  
  const _NoMovesOverlay({required this.game});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withAlpha(100),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Text(
            'No valid moves!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
