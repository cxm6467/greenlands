import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/di/injection.dart';
import 'core/services/settings_storage_service.dart';
import 'presentation/providers/character_provider.dart';
import 'presentation/screens/character/character_creation_screen.dart';
import 'presentation/screens/settings/admin_settings_screen.dart';

final _logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _logger.i('🏰 Starting The Greenlands...');

    // Setup dependency injection first (includes settings storage)
    await setupDependencies();

    // Initialize AppConfig with settings storage
    AppConfig.setSettingsStorage(getIt<SettingsStorageService>());

    // Load configuration (will use stored settings if available)
    await AppConfig.load();
    _logger.i(AppConfig.getConfigSummary());

    // Validate all required dependencies are registered
    validateDependencies();

    _logger.i('✨ The Greenlands initialized successfully!');

    runApp(const ProviderScope(child: ShireApp()));
  } catch (e, stackTrace) {
    _logger.e(
      'Failed to initialize The Greenlands',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(ErrorApp(error: e.toString()));
  }
}

class ShireApp extends StatelessWidget {
  const ShireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Greenlands',
      debugShowCheckedModeBanner: false,
      theme: GreenlandsTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  Future<void> _checkInitialization() async {
    // Wait a bit to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Check if user has a character
    // For now, show a welcome screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GreenlandsTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Title
            Text(
              '🏰 THE GREENLANDS 🏰',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Subtitle
            Text(
              'A Fantasy Adventure',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: GreenlandsTheme.accentGold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            // Loading indicator
            const CircularProgressIndicator(color: GreenlandsTheme.accentGold),
            const SizedBox(height: 16),
            Text('Loading...', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterState = ref.watch(characterProvider);

    return characterState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading character: $error')),
      ),
      data: (character) {
        if (character == null) {
          return _buildWelcomeContent(context, ref);
        }
        // TODO: Navigate to home screen with character
        return _buildWelcomeContent(context, ref);
      },
    );
  }

  Widget _buildWelcomeContent(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('THE GREENLANDS')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome message
              Text(
                'Welcome to The Greenlands!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '🔮 Guided by Lumina 🔮',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Embark on an epic fantasy quest. '
                        'Create your character, form your company of heroes, '
                        'complete quests, and let Lumina the Seer guide your journey '
                        'with ancient wisdom.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Features list
              _buildFeatureRow(context, '⚔️', 'Quest-based Adventure'),
              const SizedBox(height: 12),
              _buildFeatureRow(context, '👥', 'Company of Heroes'),
              const SizedBox(height: 12),
              _buildFeatureRow(context, '🔮', 'AI-Powered Dialogue'),
              const SizedBox(height: 12),
              _buildFeatureRow(context, '📜', 'Dynamic Quests'),
              const SizedBox(height: 48),
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CharacterCreationScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('BEGIN YOUR JOURNEY'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Debug info
              if (AppConfig.debugMode)
                OutlinedButton(
                  onPressed: () => _showDebugInfo(context),
                  child: const Text('DEBUG INFO'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  void _showDebugInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DEBUG INFO'),
        content: SingleChildScrollView(
          child: Text(
            AppConfig.getConfigSummary(),
            style: const TextStyle(fontFamily: 'Courier New', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
            child: const Text('ADMIN SETTINGS'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Failed to initialize The Greenlands',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'Courier New',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Check that your .env file is configured correctly.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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
