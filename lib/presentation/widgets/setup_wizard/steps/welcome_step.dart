import 'package:flutter/material.dart';

import '../../../../core/config/theme_config.dart';
import '../../common/pixel_art_icon.dart';

/// Welcome step for the setup wizard
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GreenlandsTheme.primaryGreen.withValues(alpha: 0.3),
            GreenlandsTheme.primaryGreen.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '🏰 WELCOME TO THE GREENLANDS 🏰',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: GreenlandsTheme.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Feature list with pixel art icons
                _buildFeatureItem(
                  context,
                  PixelArtIconType.swords,
                  'Quest-based Adventure',
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  context,
                  PixelArtIconType.heroes,
                  'Company of Heroes',
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  context,
                  PixelArtIconType.magic,
                  'AI-Powered Dialogue',
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  context,
                  PixelArtIconType.scroll,
                  'Dynamic Quests',
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: GreenlandsTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: GreenlandsTheme.accentGold,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    'This wizard will help you configure optional features for your adventure. '
                    'You can skip any integrations you don\'t need.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    PixelArtIconType iconType,
    String text,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PixelArtIcon(type: iconType, size: 48),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
