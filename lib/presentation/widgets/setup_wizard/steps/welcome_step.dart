import 'package:flutter/material.dart';

import '../../../../core/config/theme_config.dart';

/// Welcome step for the setup wizard
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🏰 WELCOME TO THE GREENLANDS 🏰',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: GreenlandsTheme.accentGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.settings,
                        size: 64,
                        color: GreenlandsTheme.accentGold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SETUP WIZARD',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: GreenlandsTheme.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This wizard will help you configure optional features for your Greenlands adventure. '
                        'You can skip any integrations you don\'t need.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'WE\'LL CONFIGURE:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: GreenlandsTheme.accentGold,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('🤖', 'AI-powered quest generation'),
                      _buildFeatureItem('💬', 'Chat platform integrations'),
                      _buildFeatureItem('🎮', 'Game settings & preferences'),
                      _buildFeatureItem('🔔', 'Notification preferences'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
